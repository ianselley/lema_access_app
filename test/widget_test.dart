import 'package:flutter_test/flutter_test.dart';

import 'package:lema_access_app/src/app.dart';

void main() {
  testWidgets('shows the login screen on launch', (tester) async {
    await tester.pumpWidget(const LemaAccessApp());
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Credenciales del operador'), findsOneWidget);
  });
}
