import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/screens/manual_search_screen.dart';

void main() {
  testWidgets('search entry keeps the query field', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [accessCurrentEventIdProvider.overrideWith((ref) => null)],
        child: const MaterialApp(home: ManualSearchScreen()),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Buscar ticket'), findsOneWidget);
  });
}
