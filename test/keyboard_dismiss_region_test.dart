import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/widgets/keyboard_dismiss_region.dart';

void main() {
  testWidgets('dismisses the keyboard when tapping outside the focused field', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KeyboardDismissRegion(
            child: Column(
              children: [
                TextField(autofocus: true),
                SizedBox(height: 24),
                Text('Outside'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));

    expect(editableText.focusNode.hasFocus, isTrue);

    await tester.tap(find.text('Outside'));
    await tester.pump();

    expect(editableText.focusNode.hasFocus, isFalse);
  });

  testWidgets('keeps focus when tapping inside the focused field', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KeyboardDismissRegion(child: TextField(autofocus: true)),
        ),
      ),
    );
    await tester.pump();

    final textField = find.byType(TextField);
    final editableText = tester.widget<EditableText>(find.byType(EditableText));

    expect(editableText.focusNode.hasFocus, isTrue);

    await tester.tap(textField);
    await tester.pump();

    expect(editableText.focusNode.hasFocus, isTrue);
  });

  testWidgets('keeps the keyboard open while scrolling', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyboardDismissRegion(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(focusNode: focusNode, autofocus: true),
                  const SizedBox(height: 1200),
                  const Text('Final'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('moves focus directly when tapping another input', (
    tester,
  ) async {
    final firstFocusNode = FocusNode();
    final secondFocusNode = FocusNode();
    addTearDown(firstFocusNode.dispose);
    addTearDown(secondFocusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyboardDismissRegion(
            child: Column(
              children: [
                TextField(focusNode: firstFocusNode, autofocus: true),
                const SizedBox(height: 24),
                TextField(focusNode: secondFocusNode),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(firstFocusNode.hasFocus, isTrue);
    expect(secondFocusNode.hasFocus, isFalse);

    await tester.tap(find.byType(TextField).last);
    await tester.pump();

    expect(firstFocusNode.hasFocus, isFalse);
    expect(secondFocusNode.hasFocus, isTrue);
  });
}
