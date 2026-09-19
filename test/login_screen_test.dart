import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lema_access_app/src/screens/login_screen.dart';
import 'package:lema_access_app/src/providers/auth_providers.dart';
import 'package:lema_access_app/src/theme/app_theme.dart';

class _EmailRegistrationController extends AccessAuthController {
  _EmailRegistrationController(this.registered);

  final bool registered;

  @override
  Future<bool> checkEmailRegistration(String email) async => registered;
}

void main() {
  testWidgets('groups the email and password for credential autofill', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.build(), home: const LoginScreen()),
      ),
    );

    expect(find.byType(AutofillGroup), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).autofillHints,
      const [AutofillHints.username, AutofillHints.email],
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(
              const Key('email-autofill-password'),
              skipOffstage: false,
            ),
          )
          .autofillHints,
      const [AutofillHints.password],
    );
  });

  testWidgets('focuses the password only for a registered email', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessAuthActionProvider.overrideWith(
            () => _EmailRegistrationController(true),
          ),
        ],
        child: MaterialApp(theme: AppTheme.build(), home: const LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'staff@lema.club');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Contraseña'))
          .focusNode!
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('does not focus a registration field for a new email', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessAuthActionProvider.overrideWith(
            () => _EmailRegistrationController(false),
          ),
        ],
        child: MaterialApp(theme: AppTheme.build(), home: const LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'new@lema.club');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Nombre visible'))
          .focusNode!
          .hasFocus,
      isFalse,
    );
  });

  testWidgets('shows every missing password requirement after signup submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.build(),
          home: const LoginScreen(
            initialStep: AccessAuthStep.signup,
            initialEmail: 'staff@lema.club',
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
