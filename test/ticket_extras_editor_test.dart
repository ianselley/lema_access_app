import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/models/add_on_models.dart';
import 'package:lema_access_app/src/widgets/ticket_extras_editor.dart';

void main() {
  testWidgets('extras edit can be reverted and sends only changed rows', (
    tester,
  ) async {
    List<String>? undos;
    List<Map<String, dynamic>>? redeemed;
    Map<String, int>? expected;
    final addOn = AccessTicketAddOn.fromJson({
      'assignment_id': 'extra',
      'name': 'Bebida',
      'quantity': 3,
      'redeemed_quantity': 1,
      'remaining_quantity': 2,
      'active_redemptions': [
        {'id': 'redemption', 'quantity': 1},
      ],
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketExtrasEditor(
            addOns: [addOn],
            onSave: (a, b, c) async {
              undos = a;
              redeemed = b;
              expected = c;
            },
          ),
        ),
      ),
    );
    expect(
      find.text('Marca los extras que se hayan consumido'),
      findsOneWidget,
    );
    expect(find.text('Cerrar sin cambios'), findsOneWidget);
    await tester.tap(find.text('1 × Bebida'));
    await tester.pump();
    expect(find.byTooltip('Modificado'), findsOneWidget);
    expect(find.text('Confirmar cambios'), findsOneWidget);
    await tester.tap(find.text('1 × Bebida'));
    await tester.pump();
    expect(find.text('Cerrar sin cambios'), findsOneWidget);
    expect(find.byTooltip('Modificado'), findsNothing);
    await tester.tap(find.text('1 × Bebida'));
    await tester.tap(find.text('2 × Bebida'));
    await tester.pump();
    await tester.tap(find.text('Confirmar cambios'));
    await tester.pump();
    expect(undos, ['redemption']);
    expect(redeemed, [
      {'assignment_id': 'extra', 'quantity': 2},
    ]);
    expect(expected, {'extra': 1});
  });
  testWidgets(
    'extras remain scrollable on a narrow phone and close without saving',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var saved = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TicketExtrasEditor(
                    addOns: List.generate(
                      25,
                      (i) => AccessTicketAddOn.fromJson({
                        'assignment_id': '$i',
                        'name': 'Extra $i',
                        'remaining_quantity': 1,
                      }),
                    ),
                    onSave: (_, _, _) async {
                      saved = true;
                    },
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1600),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 × Extra 24').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Cerrar sin cambios'));
      await tester.pumpAndSettle();
      expect(find.byType(TicketExtrasEditor), findsNothing);
      expect(saved, isFalse);
    },
  );
}
