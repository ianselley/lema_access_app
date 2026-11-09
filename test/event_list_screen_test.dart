import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lema_access_app/src/models/event_models.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/screens/event_list_screen.dart';
import 'package:lema_access_app/src/screens/event_ui.dart';

void main() {
  testWidgets('expands the code form from the empty events card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [accessEventsProvider.overrideWith((ref) async => [])],
        child: const MaterialApp(home: EventListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Unirse con código'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Activar acceso'), findsOneWidget);
  });

  testWidgets('hides event occupancy without permission', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessEventsProvider.overrideWith(
            (ref) async => [
              _eventSummary(
                id: 'live',
                name: 'Evento',
                operationalState: 'live',
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: EventListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 en curso'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
    expect(find.text('0 / 10'), findsNothing);
  });

  for (final scenario in [
    (
      checkedIn: 3,
      pending: 5,
      capacity: 12,
      progress: 0.375,
      percentage: '38%',
    ),
    (checkedIn: 8, pending: 0, capacity: 12, progress: 1.0, percentage: '100%'),
    (checkedIn: 0, pending: 0, capacity: 12, progress: 0.0, percentage: '0%'),
    (checkedIn: 3, pending: 5, capacity: 0, progress: 0.375, percentage: '38%'),
  ]) {
    testWidgets(
      'event card uses sold tickets for ${scenario.checkedIn} scanned, '
      '${scenario.pending} pending and capacity ${scenario.capacity}',
      (tester) async {
        final event = _eventSummary(
          id: 'live',
          name: 'Evento',
          operationalState: 'live',
          issuedCount: 10,
          checkedInCount: scenario.checkedIn,
          pendingCheckInCount: scenario.pending,
          capacityTotal: scenario.capacity,
          canViewCurrentOccupancy: true,
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              accessEventsProvider.overrideWith((ref) async => [event]),
            ],
            child: const MaterialApp(home: EventListScreen()),
          ),
        );
        await tester.pumpAndSettle();

        final soldCount = scenario.checkedIn + scenario.pending;
        expect(event.soldCount, soldCount);
        expect(event.progress, scenario.progress);
        expect(find.text(scenario.percentage), findsOneWidget);
        expect(
          find.text('${scenario.checkedIn} / $soldCount vendidas'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          scenario.progress,
        );
      },
    );
  }

  testWidgets('hides draft events and does not duplicate primary events', (
    tester,
  ) async {
    final events = [
      _eventSummary(id: 'event-test', name: 'Evento TEST'),
      _eventSummary(id: 'event-b', name: 'Evento Futuro B'),
      _eventSummary(id: 'event-c', name: 'Evento Futuro C'),
      _eventSummary(
        id: 'event-draft',
        name: 'Evento Borrador',
        operationalState: 'draft',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [accessEventsProvider.overrideWith((ref) async => events)],
        child: const MaterialApp(home: EventListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Evento Borrador'), findsNothing);
    expect(find.text('Evento TEST'), findsOneWidget);
    expect(find.text('Evento Futuro B'), findsOneWidget);
    expect(find.textContaining('en curso'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Evento Futuro C'), findsOneWidget);
  });

  testWidgets('shows a compact date for upcoming events', (tester) async {
    final startsAt = DateTime.now().add(const Duration(days: 7));
    final expectedDate =
        '${startsAt.day.toString().padLeft(2, '0')}/${startsAt.month.toString().padLeft(2, '0')}';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessEventsProvider.overrideWith(
            (ref) async => [
              _eventSummary(id: 'a', name: 'A'),
              _eventSummary(id: 'b', name: 'B'),
              _eventSummary(id: 'c', name: 'C', startTime: startsAt),
            ],
          ),
        ],
        child: const MaterialApp(home: EventListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text(expectedDate), findsOneWidget);
  });
}

AccessEventSummary _eventSummary({
  required String id,
  required String name,
  String operationalState = 'scheduled',
  DateTime? startTime,
  int issuedCount = 0,
  int checkedInCount = 0,
  int pendingCheckInCount = 0,
  int capacityTotal = 10,
  bool canViewCurrentOccupancy = false,
}) {
  return AccessEventSummary(
    event: AccessEventRecord(
      id: id,
      status: operationalState,
      currency: 'EUR',
      salesStartAt: null,
      salesEndAt: null,
      createdAt: null,
      updatedAt: null,
    ),
    membershipRole: 'event_member',
    accessScope: 'event',
    operationalState: operationalState,
    brand: const AccessBrand(
      id: 'brand-1',
      name: 'Marca',
      username: null,
      logoUrl: null,
    ),
    party: AccessParty(
      id: 'party-$id',
      name: name,
      poster: null,
      description: null,
      startTime: startTime,
      endTime: null,
      isArchived: false,
    ),
    place: const AccessPlace(
      id: 'place-1',
      name: 'Sala',
      city: null,
      address: null,
      timezone: null,
    ),
    issuedCount: issuedCount,
    checkedInCount: checkedInCount,
    pendingCheckInCount: pendingCheckInCount,
    capacityTotal: capacityTotal,
    lastActivityAt: null,
    canViewCurrentOccupancy: canViewCurrentOccupancy,
  );
}
