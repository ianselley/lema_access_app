import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lema_access_app/src/app.dart';
import 'package:lema_access_app/src/providers/auth_providers.dart';

void main() {
  testWidgets('shows the login screen on launch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            (ref) => Stream<Session?>.value(null),
          ),
        ],
        child: const LemaAccessApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Identifícate'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });
}
