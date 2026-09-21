import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/ticket_models.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/providers/ticket_providers.dart';
import 'package:lema_access_app/src/screens/search_results_screen.dart';

void main() {
  testWidgets('filters results by an explicit ticket status', (tester) async {
    final container = ProviderContainer(
      overrides: [
        accessCurrentEventIdProvider.overrideWith((ref) => 'event-1'),
        accessManualSearchQueryProvider.overrideWith((ref) => 'Ana'),
        accessTicketSearchResultsProvider.overrideWith(
          (ref) async => const AccessTicketSearchPage(
            items: [],
            totalCount: 0,
            limit: 20,
            offset: 0,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SearchResultsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Estado del ticket'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Ya escaneados'), findsOneWidget);
    expect(container.read(accessManualSearchCheckedInProvider), isFalse);

    await tester.tap(find.text('Ya escaneados'));
    await tester.pump();

    expect(container.read(accessManualSearchCheckedInProvider), isTrue);
  });
}
