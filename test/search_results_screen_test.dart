import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/core/rpc_client.dart';
import 'package:lema_access_app/src/models/event_models.dart';
import 'package:lema_access_app/src/models/ticket_models.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/providers/ticket_providers.dart';
import 'package:lema_access_app/src/screens/search_results_screen.dart';
import 'package:lema_access_app/src/services/ticket_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

AccessEventHome home(bool canBrowse) => AccessEventHome(
  membershipRole: 'scanner',
  accessScope: 'event_member',
  operationalState: 'live',
  event: const AccessEventRecord(
    id: 'event',
    status: 'published',
    currency: 'EUR',
    salesStartAt: null,
    salesEndAt: null,
    createdAt: null,
    updatedAt: null,
  ),
  brand: const AccessBrand(
    id: 'brand',
    name: 'Marca',
    username: null,
    logoUrl: null,
  ),
  party: const AccessParty(
    id: 'event',
    name: 'Evento',
    poster: null,
    description: null,
    startTime: null,
    endTime: null,
    isArchived: false,
  ),
  place: const AccessPlace(
    id: null,
    name: null,
    city: null,
    address: null,
    timezone: null,
  ),
  counters: const AccessEventCounters(
    issuedCount: 0,
    checkedInCount: 0,
    pendingCheckInCount: 0,
    cancelledOrVoidedCount: 0,
    capacityTotal: 0,
    ticketTypeCount: 0,
  ),
  recentHistoryPreview: const [],
  lastActivityAt: null,
  canViewCurrentOccupancy: canBrowse,
);

AccessTicketSearchItem item(String name, String status, {bool vip = false}) =>
    AccessTicketSearchItem.fromJson({
      'match_reason': 'other',
      'ticket': {
        'id': name,
        'event_id': 'event',
        'code': name,
        'status': status,
        'can_check_in': status == 'issued',
        'ticket_type': {'name': vip ? 'Mesa' : 'General'},
        'attendee': {'full_name': name},
        'order': {'id': 'order'},
        if (vip) 'zone_offer': {'zone_name': 'VIP'},
      },
    });

class FakeBrowseService extends AccessTicketService {
  FakeBrowseService()
    : super(
        AccessRpcClient(
          SupabaseClient(
            'http://localhost',
            'test',
            authOptions: const AuthClientOptions(autoRefreshToken: false),
          ),
        ),
      );

  final calls = <(bool, int, String, bool?)>[];
  int countCalls = 0;

  @override
  Future<AccessTicketBrowsePage> listEventTickets({
    required String eventId,
    required String query,
    required bool? checkedIn,
    required bool vip,
    required int offset,
    int limit = 20,
    bool sortByIssuedAt = false,
  }) async {
    calls.add((vip, offset, query, checkedIn));
    if (vip) {
      if (offset > 0) {
        return AccessTicketBrowsePage(
          items: [item('VIP Berta', 'issued', vip: true)],
          hasMore: false,
        );
      }
      return AccessTicketBrowsePage(
        items: [item('VIP Ana', 'checked_in', vip: true)],
        hasMore: true,
      );
    }
    if (offset == 0) {
      return AccessTicketBrowsePage(
        items: [item('Normal Ana', 'issued')],
        hasMore: true,
      );
    }
    return AccessTicketBrowsePage(
      items: [item('Normal Berta', 'checked_in')],
      hasMore: false,
    );
  }

  @override
  Future<AccessTicketBrowseCount> countEventTickets({
    required String eventId,
    required String query,
    required bool? checkedIn,
  }) async {
    countCalls++;
    return const AccessTicketBrowseCount(total: 3, vip: 1);
  }
}

void main() {
  testWidgets('privileged browse shows and prefetches both ticket groups', (
    tester,
  ) async {
    final service = FakeBrowseService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessCurrentEventIdProvider.overrideWith((ref) => 'event'),
          accessEventHomeProvider(
            'event',
          ).overrideWith((ref) async => home(true)),
          accessTicketServiceProvider.overrideWithValue(service),
        ],
        child: const MaterialApp(home: SearchResultsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('3 resultados'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('VIP Ana'), findsOneWidget);
    expect(find.text('Normal Ana'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
    expect(service.countCalls, 1);
    expect(
      service.calls.any((call) => call.$1 == true && call.$2 == 1),
      isTrue,
    );
    expect(
      service.calls.any((call) => call.$1 == false && call.$2 == 1),
      isTrue,
    );
    expect(find.text('ESCANEADA'), findsWidgets);
  });

  testWidgets(
    'scanner without occupancy sees results only after searching and no count',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = FakeBrowseService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessCurrentEventIdProvider.overrideWith((ref) => 'event'),
            accessEventHomeProvider(
              'event',
            ).overrideWith((ref) async => home(false)),
            accessTicketServiceProvider.overrideWithValue(service),
          ],
          child: const MaterialApp(home: SearchResultsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Todas'), findsNothing);
      expect(service.calls, isEmpty);

      await tester.enterText(find.byType(TextField), 'Ana');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Todas'), findsOneWidget);
      expect(find.textContaining('resultados'), findsNothing);
      expect(service.countCalls, 0);
      expect(service.calls.every((call) => call.$3 == 'Ana'), isTrue);

      await tester.tap(find.text('Escaneadas'));
      await tester.pumpAndSettle();
      expect(service.calls.any((call) => call.$4 == true), isTrue);
      expect(service.countCalls, 0);

      await tester.scrollUntilVisible(
        find.text('Normal Ana'),
        250,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ).first,
      );
      expect(find.text('Normal Ana'), findsOneWidget);
    },
  );
}
