import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/screens/manual_search_screen.dart';

void main() {
  testWidgets('presents and clears the ticket search query', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessCurrentEventIdProvider.overrideWith((ref) => 'event-1'),
        ],
        child: const MaterialApp(home: ManualSearchScreen()),
      ),
    );

    expect(find.text('Datos del ticket'), findsOneWidget);
    expect(find.text('Ver resultados'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ana García');
    await tester.pump();
    expect(find.byTooltip('Borrar búsqueda'), findsOneWidget);

    await tester.tap(find.byTooltip('Borrar búsqueda'));
    await tester.pump();
    expect(find.text('Ana García'), findsNothing);
  });
}
