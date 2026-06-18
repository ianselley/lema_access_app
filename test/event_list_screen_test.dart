import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lema_access_app/src/models/event_models.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/screens/event_list_screen.dart';

void main() {
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
    expect(find.textContaining('3 totales'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Evento Futuro C'), findsOneWidget);
  });
}

AccessEventSummary _eventSummary({
  required String id,
  required String name,
  String operationalState = 'scheduled',
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
      startTime: null,
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
    issuedCount: 0,
    checkedInCount: 0,
    pendingCheckInCount: 0,
    capacityTotal: 10,
    lastActivityAt: null,
  );
}
