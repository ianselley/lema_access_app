import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/event_models.dart';
import 'package:lema_access_app/src/screens/event_ui.dart';

void main() {
  test('unknown home membership has no visible label', () {
    final home = AccessEventHome(
      membershipRole: null,
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
        checkedInCount: 0,
        pendingCheckInCount: 0,
        cancelledOrVoidedCount: 0,
        capacityTotal: 0,
        ticketTypeCount: 0,
      ),
      recentHistoryPreview: const [],
      lastActivityAt: null,
      canViewCurrentOccupancy: false,
    );

    expect(home.membershipLabel, isNull);
  });

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
    final startsAt = DateTime(2026, 9, 21, 22);

    expect(
      formatEventSchedule(startsAt, startsAt.add(const Duration(hours: 6))),
      '21/09 · 22:00 - 04:00',
    );
    expect(
      formatEventSchedule(startsAt, startsAt.add(const Duration(hours: 25))),
      '21/09 · 22:00 - 22/09 · 23:00',
    );
  });

  test('includes the year outside the next 365 days', () {
    final date = DateTime.now().add(const Duration(days: 366));

    expect(formatEventDate(date), endsWith('/${date.year}'));
  });
}
