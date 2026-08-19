import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lema_access_app/src/screens/login_screen.dart';
import 'package:lema_access_app/src/theme/app_theme.dart';

void main() {
  testWidgets('shows every missing password requirement after signup submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const LoginScreen(
            initialStep: AccessAuthStep.signup,
            initialEmail: 'staff@lema.io',
          ),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre visible'),
      'Equipo LEMA',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre de usuario'),
      'equipo-lema',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Contraseña'), 'abc');
    final createAccountButton = find.widgetWithText(
      ElevatedButton,
      'Crear cuenta',
    );
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pump();

    expect(
      find.text(
        'Falta en la contraseña: al menos 6 caracteres, una mayúscula, un número.',
      ),
      findsOneWidget,
    );
  });
}
