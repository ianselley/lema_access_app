import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/controllers/scan_controller.dart';
import 'package:lema_access_app/src/models/event_models.dart' as event_models;
import 'package:lema_access_app/src/models/scan_models.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/providers/scan_providers.dart';
import 'package:lema_access_app/src/screens/scanner_active_screen.dart';
import 'package:lema_access_app/src/theme/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

AccessScanOutcome outcome(
  String result, {
  int? remaining,
  String? reason,
  int extraCount = 1,
}) => AccessScanOutcome.fromJson(
  stage: AccessScanStage.checkIn,
  source: AccessScanSource.scanner,
  rawInput: 'VIP',
  json: {
    'result_code': result,
    'reason_code': reason,
    'ticket': {
      'id': 'ticket',
      'status': result == 'cancelled_or_invalid' ? 'issued' : 'checked_in',
      'ticket_type': {'name': 'Terraza'},
      'attendee': {'full_name': 'Ana'},
      'zone_offer': {
        'zone_name': 'Terraza',
        'people_count_current': 7,
        'service_starts_at': '2026-09-17T20:00:00Z',
        'service_ends_at': '2026-09-17T23:00:00Z',
      },
      'add_ons': [
        if (remaining != null)
          for (var index = 0; index < extraCount; index++)
            {
              'assignment_id': 'extra-$index',
              'name': 'Copa',
              'quantity': 1,
              'redeemed_quantity': remaining == 0 ? 1 : 0,
              'remaining_quantity': remaining,
            },
      ],
    },
  },
);

class FakeCamera extends MobileScannerPlatform {
  int starts = 0;
  int stops = 0;
  int disposals = 0;
  bool failStart = false;

  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();
  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();
  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();
  @override
  Widget buildCameraView() => const SizedBox.expand();
  @override
  Future<void> updateScanWindow(Rect? window) async {}
  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }

  @override
  Future<MobileScannerViewAttributes> start(StartOptions options) async {
    starts++;
    if (failStart) throw StateError('Camera disconnected');
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(640, 480),
      numberOfCameras: 1,
    );
  }
}

class FakeScanController extends AccessScanController {
  AccessScanOutcome response = outcome('already_used', remaining: 1);
  int scans = 0;
  @override
  Future<AccessScanOutcome?> submitScanInput(String input) async {
    scans++;
    return response;
  }
}

void main() {
  test('only pending extras keep used tickets open and orange', () {
    for (final remaining in [null, 0, 1]) {
      final result = outcome('already_used', remaining: remaining);
      expect(scannerNeedsPersistentResult(result), remaining == 1);
      expect(
        scannerResultAccent(result),
        remaining == 1 ? AppColors.warning : AppColors.error,
      );
    }
    for (final result in [
      'wrong_event',
      'not_found',
      'forbidden',
      'temporary_error',
    ]) {
      expect(
        scannerNeedsPersistentResult(outcome(result, remaining: 1)),
        isFalse,
      );
      expect(
        scannerResultAccent(outcome(result, remaining: 1)),
        AppColors.error,
      );
    }
    final expired = outcome(
      'cancelled_or_invalid',
      reason: 'TICKET_VALIDITY_EXPIRED',
    );
    expect(scannerNeedsPersistentResult(expired), isTrue);
    expect(scannerResultAccent(expired), AppColors.error);
    expect(scannerResultAccent(outcome('valid')), AppColors.success);
  });

  late FakeCamera camera;
  late FakeScanController scanner;
  late MobileScannerPlatform original;
  setUp(() {
    original = MobileScannerPlatform.instance;
    camera = FakeCamera();
    scanner = FakeScanController();
    MobileScannerPlatform.instance = camera;
  });
  tearDown(() => MobileScannerPlatform.instance = original);

  Future<void> openScanner(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [accessScanControllerProvider.overrideWith(() => scanner)],
        child: const MaterialApp(home: ScannerActiveScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('camera releases without a frame on lock and resumes', (
    tester,
  ) async {
    await openScanner(tester);
    expect(camera.starts, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.idle();
    expect(camera.stops, 1);
    expect(camera.disposals, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(camera.starts, 2);
    expect(find.byType(MobileScanner), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.idle();
    expect(camera.disposals, 2);
  });

  testWidgets(
    'recent activity blocks queued detections without stopping camera',
    (tester) async {
      await openScanner(tester);
      final detect = tester
          .widget<MobileScanner>(find.byType(MobileScanner))
          .onDetect!;
      await tester.tap(find.text('Ver todos'));
      detect(const BarcodeCapture(barcodes: [Barcode(rawValue: 'VIP')]));
      await tester.pumpAndSettle();
      expect(scanner.scans, 0);
      expect(camera.disposals, 0);
      Navigator.of(tester.element(find.byType(ScannerActiveScreen))).pop();
      await tester.pumpAndSettle();
      expect(camera.starts, 1);
    },
  );

  testWidgets('shows the event home latest activity while history loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessScanControllerProvider.overrideWith(() => scanner),
          accessCurrentEventIdProvider.overrideWith((ref) => 'event-1'),
          accessEventHomeProvider.overrideWith(
            (ref, eventId) async => _eventHomeWithHistory(),
          ),
        ],
        child: const MaterialApp(home: ScannerActiveScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.textContaining('ABC123'), findsOneWidget);
  });

  testWidgets(
    'pending extras use one reservation name, guest count and close wording',
    (tester) async {
      await openScanner(tester);
      tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
        const BarcodeCapture(barcodes: [Barcode(rawValue: 'VIP')]),
      );
      await tester.pumpAndSettle();
      expect(find.text('Puede canjear extras'), findsOneWidget);
      expect(find.text('Reservado · Terraza · 7 personas'), findsOneWidget);
      final ticketStyle = tester
          .widget<Text>(find.text('Reservado · Terraza · 7 personas'))
          .style!;
      expect(
        ticketStyle.fontSize,
        greaterThan(tester.widget<Text>(find.text('Ana')).style!.fontSize!),
      );
      expect(
        find.ancestor(
          of: find.text('Reservado · Terraza · 7 personas'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is ShapeDecoration &&
                (widget.decoration! as ShapeDecoration).color ==
                    AppColors.warning,
          ),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Horario de mesa:'), findsOneWidget);
      expect(find.text('REVISIÓN REQUERIDA'), findsNothing);
      expect(find.text('Validar entrada'), findsNothing);
      await tester.scrollUntilVisible(find.byType(CheckboxListTile), 100);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(find.text('Cerrar'), findsOneWidget);
      final resultBackground = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is ShapeDecoration &&
            (widget.decoration! as ShapeDecoration).color == AppColors.warning,
      );
      final modalHeight = tester.getSize(resultBackground).height;
      await tester.tap(find.text('Cerrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.getSize(resultBackground).height, lessThan(modalHeight));
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsNothing);
    },
  );
  testWidgets(
    'modal grows with extras, stays centered and only extras scroll',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final heights = <double>[];
      for (final count in [1, 3, 12]) {
        scanner = FakeScanController()
          ..response = outcome('already_used', remaining: 1, extraCount: count);
        await openScanner(tester);
        tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
          const BarcodeCapture(barcodes: [Barcode(rawValue: 'VIP')]),
        );
        await tester.pumpAndSettle();
        final modal = find.ancestor(
          of: find.text('Puede canjear extras'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is ShapeDecoration &&
                (widget.decoration! as ShapeDecoration).color ==
                    AppColors.warning,
          ),
        );
        final rect = tester.getRect(modal);
        heights.add(rect.height);
        expect(rect.center.dy, closeTo(844 / 2, 1));
        final extras = find.descendant(
          of: modal,
          matching: find.byType(Scrollable),
        );
        final position = tester.state<ScrollableState>(extras).position;
        expect(position.maxScrollExtent, count == 12 ? greaterThan(0) : 0);
        if (count == 12) {
          final headlinePosition = tester.getTopLeft(
            find.text('TICKET YA UTILIZADO'),
          );
          final actionPosition = tester.getTopLeft(
            find.widgetWithText(FilledButton, 'Canjear extras'),
          );
          await tester.drag(extras, const Offset(0, -300));
          await tester.pumpAndSettle();
          expect(position.pixels, greaterThan(0));
          expect(
            tester.getTopLeft(find.text('TICKET YA UTILIZADO')),
            headlinePosition,
          );
          expect(
            tester.getTopLeft(
              find.widgetWithText(FilledButton, 'Canjear extras'),
            ),
            actionPosition,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
      expect(heights[0], lessThan(heights[1]));
      expect(heights[1], lessThan(heights[2]));
    },
  );

  testWidgets('used tickets with consumed extras dismiss automatically', (
    tester,
  ) async {
    scanner.response = outcome('already_used', remaining: 0);
    await openScanner(tester);
    tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
      const BarcodeCapture(barcodes: [Barcode(rawValue: 'VIP')]),
    );
    await tester.pumpAndSettle();
    expect(find.text('TICKET YA UTILIZADO'), findsOneWidget);
    expect(find.text('Puede canjear extras'), findsNothing);
    expect(find.text('Validar entrada'), findsNothing);
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('TICKET YA UTILIZADO'), findsNothing);
  });

  testWidgets(
    'outside validity keeps decisions without the exception paragraph',
    (tester) async {
      scanner.response = outcome(
        'cancelled_or_invalid',
        reason: 'TICKET_VALIDITY_EXPIRED',
      );
      await openScanner(tester);
      tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
        const BarcodeCapture(barcodes: [Barcode(rawValue: 'VIP')]),
      );
      await tester.pumpAndSettle();
      expect(find.text('No validar'), findsOneWidget);
      expect(
        tester.getTopLeft(find.widgetWithText(FilledButton, 'No validar')).dy -
            tester.getBottomLeft(find.text('Ana')).dy,
        closeTo(24, 1),
      );
      expect(
        find.widgetWithText(OutlinedButton, 'Validar de todos modos'),
        findsOneWidget,
      );
      expect(find.text('Validar entrada'), findsNothing);
      expect(find.textContaining('de forma excepcional'), findsNothing);
      expect(
        tester.widget<Text>(find.text('FUERA DEL HORARIO VÁLIDO')).style?.color,
        AppColors.black,
      );
      await tester.tap(find.text('No validar'));
      await tester.pumpAndSettle();
    },
  );
}

event_models.AccessEventHome _eventHomeWithHistory() {
  return event_models.AccessEventHome(
    membershipRole: 'scanner',
    accessScope: 'event_member',
    operationalState: 'live',
    event: const event_models.AccessEventRecord(
      id: 'event-1',
      status: 'published',
      currency: 'EUR',
      salesStartAt: null,
      salesEndAt: null,
      createdAt: null,
      updatedAt: null,
    ),
    brand: const event_models.AccessBrand(
      id: 'brand-1',
      name: 'Marca',
      username: null,
      logoUrl: null,
    ),
    party: const event_models.AccessParty(
      id: 'event-1',
      name: 'Evento',
      poster: null,
      description: null,
      startTime: null,
      endTime: null,
      isArchived: false,
    ),
    place: const event_models.AccessPlace(
      id: null,
      name: null,
      city: null,
      address: null,
      timezone: null,
    ),
    counters: const event_models.AccessEventCounters(
      issuedCount: 1,
      checkedInCount: 1,
      pendingCheckInCount: 0,
      cancelledOrVoidedCount: 0,
      capacityTotal: 1,
      ticketTypeCount: 1,
    ),
    recentHistoryPreview: const [
      event_models.AccessHistoryItem(
        id: 'history-1',
        createdAt: null,
        resultCode: 'valid',
        reasonCode: null,
        source: 'scanner',
        inputKind: 'code',
        rawInput: 'ABC123',
        normalizedInput: 'ABC123',
        ticket: null,
        actor: event_models.AccessActor(
          userId: null,
          profileId: null,
          displayName: 'Ana',
          username: null,
        ),
      ),
    ],
    lastActivityAt: null,
    canViewCurrentOccupancy: false,
  );
}
