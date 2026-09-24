import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/event_models.dart';
import 'package:lema_access_app/src/models/ticket_models.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/providers/ticket_providers.dart';
import 'package:lema_access_app/src/screens/event_home_screen.dart';

AccessEventHome eventHome(bool canBrowse) => AccessEventHome(
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

AccessTicketSearchItem ticket(String name, {required bool vip}) =>
    AccessTicketSearchItem.fromJson({
      'match_reason': 'other',
      'ticket': {
        'id': name,
        'event_id': 'event',
        'code': name,
        'status': 'issued',
        'can_check_in': true,
        'ticket_type': {'name': vip ? 'Mesa' : 'General'},
        'attendee': {'full_name': name},
        'order': {'id': 'order'},
        if (vip) 'zone_offer': {'zone_name': 'VIP'},
      },
    });

void main() {
  testWidgets(
    'home shows three recent tickets per group above scans and opens the full list',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer(
        overrides: [
          accessEventHomeProvider(
            'event',
          ).overrideWith((ref) async => eventHome(true)),
          accessRecentEventTicketsProvider('event').overrideWith(
            (ref) async => (
              vip: AccessTicketBrowsePage(
                items: [
                  for (var i = 1; i <= 4; i++) ticket('VIP $i', vip: true),
                ],
                hasMore: true,
              ),
              normal: AccessTicketBrowsePage(
                items: [
                  for (var i = 1; i <= 4; i++) ticket('Normal $i', vip: false),
                ],
                hasMore: true,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      var openedSearch = false;
      var openedDetail = false;
      container.read(accessManualSearchQueryProvider.notifier).state =
          'old query';

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: EventHomeScreen(
              eventId: 'event',
              onOpenSearch: () => openedSearch = true,
              onOpenTicketDetail: () => openedDetail = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Últimos tickets'), findsOneWidget);
      expect(find.text('VIP 1'), findsOneWidget);
      expect(find.text('VIP 4'), findsNothing);
      expect(find.text('Normal 3'), findsOneWidget);
      expect(find.text('Normal 4'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Últimos tickets')).dy,
        lessThan(tester.getTopLeft(find.text('Últimos accesos')).dy),
      );

      await tester.tap(find.text('Ver más >'));
      await tester.pump();
      expect(openedSearch, isTrue);
      expect(container.read(accessManualSearchQueryProvider), isEmpty);

      await tester.ensureVisible(find.text('VIP 1'));
      await tester.tap(find.text('VIP 1'));
      await tester.pump();
      expect(openedDetail, isTrue);
      expect(container.read(accessSelectedTicketProvider)?.ticketId, 'VIP 1');
    },
  );

  testWidgets('home does not fetch ticket previews without occupancy access', (
    tester,
  ) async {
    var previewCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessEventHomeProvider(
            'event',
          ).overrideWith((ref) async => eventHome(false)),
          accessRecentEventTicketsProvider('event').overrideWith((ref) async {
            previewCalls++;
            return (
              vip: const AccessTicketBrowsePage(items: [], hasMore: false),
              normal: const AccessTicketBrowsePage(items: [], hasMore: false),
            );
          }),
        ],
        child: const MaterialApp(home: EventHomeScreen(eventId: 'event')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Últimos tickets'), findsNothing);
    expect(previewCalls, 0);
  });
}
