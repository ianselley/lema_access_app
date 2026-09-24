import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/event_models.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/providers/ticket_providers.dart';
import 'package:lema_access_app/src/models/ticket_models.dart' as ticket_models;
import 'package:lema_access_app/src/screens/event_home_screen.dart';
import 'package:lema_access_app/src/screens/event_ui.dart';

void main() {
  testWidgets(
    'event home explains access and capacity without showing a role',
    (tester) async {
      final home = AccessEventHome(
        membershipRole: 'brand_owner',
        accessScope: null,
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
          checkedInCount: 3,
          pendingCheckInCount: 0,
          cancelledOrVoidedCount: 0,
          capacityTotal: 12,
          ticketTypeCount: 0,
        ),
        recentHistoryPreview: const [],
        lastActivityAt: null,
        canViewCurrentOccupancy: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accessEventHomeProvider('event').overrideWith((ref) async => home),
            accessRecentEventTicketsProvider('event').overrideWith(
              (ref) async => (
                vip: const ticket_models.AccessTicketBrowsePage(
                  items: [],
                  hasMore: false,
                ),
                normal: const ticket_models.AccessTicketBrowsePage(
                  items: [],
                  hasMore: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: EventHomeScreen(eventId: 'event')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EVENTO ACTIVO'), findsNothing);
      expect(find.text('EN VIVO'), findsOneWidget);
      expect(
        (tester.getTopLeft(find.text('Evento')).dy -
                tester.getTopLeft(find.text('EN VIVO')).dy)
            .abs(),
        lessThan(16),
      );
      expect(find.text('Propietario de marca'), findsNothing);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Accesos validados'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('Ocupación del aforo'), findsOneWidget);
      expect(find.textContaining('de 12 plazas'), findsOneWidget);
    },
  );

  test('home history falls back to the scanned reference', () {
    const item = AccessHistoryItem(
      id: 'history-1',
      createdAt: null,
      resultCode: 'not_found',
      reasonCode: 'TICKET_NOT_FOUND',
      source: 'scanner',
      inputKind: 'manual',
      rawInput: '  GUEST-42  ',
      normalizedInput: null,
      ticket: null,
      actor: AccessActor(
        userId: null,
        profileId: null,
        displayName: null,
        username: null,
      ),
    );

    expect(item.detailLabels, ['Sin tipo de entrada', 'GUEST-42']);
  });

  test('formats the end time without a date only within 24 hours', () {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final startsAt = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 22);

    expect(
      formatEventSchedule(startsAt, startsAt.add(const Duration(hours: 6))),
      '${formatEventDate(startsAt)} · 22:00 - 04:00',
    );
    expect(
      formatEventSchedule(startsAt, startsAt.add(const Duration(hours: 25))),
      '${formatEventDate(startsAt)} · 22:00 - ${formatEventDate(startsAt.add(const Duration(hours: 25)))} · 23:00',
    );
  });

  test('includes the year outside the next 365 days', () {
    final date = DateTime.now().add(const Duration(days: 366));

    expect(formatEventDate(date), endsWith('/${date.year}'));
  });
}
