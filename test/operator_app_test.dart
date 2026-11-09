import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lema_access_app/src/providers/event_providers.dart';
import 'package:lema_access_app/src/providers/profile_providers.dart';
import 'package:lema_access_app/src/screens/event_list_screen.dart';
import 'package:lema_access_app/src/screens/operator_app.dart';
import 'package:lema_access_app/src/widgets/lema_scaffold.dart';

Future<void> _pumpOperatorApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accessEventsProvider.overrideWith((ref) async => []),
        accessEventHomeProvider.overrideWith(
          (ref, eventId) async => throw StateError('Event unavailable'),
        ),
        accessMeProvider.overrideWith(
          (ref) async => throw StateError('Profile unavailable'),
        ),
      ],
      child: const MaterialApp(restorationScopeId: 'app', home: OperatorApp()),
    ),
  );
  await tester.pumpAndSettle();
}

Navigator _navigator(WidgetTester tester) => tester.widget<Navigator>(
  find.descendant(
    of: find.byType(OperatorApp),
    matching: find.byType(Navigator),
  ),
);

void _goBack(WidgetTester tester) {
  tester
      .widget<OperatorNavigationScope>(find.byType(OperatorNavigationScope))
      .onBack!();
}

void main() {
  testWidgets(
    'repeated destinations have stable unique keys',
    (tester) async {
      await _pumpOperatorApp(tester);
      final openEvent = tester
          .widget<EventListScreen>(find.byType(EventListScreen))
          .onOpenEvent!;
      final rootKey = _navigator(tester).pages.single.key;

      openEvent('event');
      await tester.pumpAndSettle();
      final firstHomeKey = _navigator(tester).pages.last.key;

      openEvent('event');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final pages = _navigator(tester).pages;
      expect(pages.map((page) => page.name), [
        'eventList',
        'eventHome',
        'eventHome',
      ]);
      expect(pages.map((page) => page.key).toSet(), hasLength(3));
      expect(pages.first.key, rootKey);
      expect(pages[1].key, firstHomeKey);

      tester.element(find.byType(OperatorApp)).markNeedsBuild();
      await tester.pump();
      expect(
        _navigator(tester).pages.map((page) => page.key),
        pages.map((page) => page.key),
      );

      _goBack(tester);
      await tester.pumpAndSettle();
      expect(_navigator(tester).pages.map((page) => page.key), [
        rootKey,
        firstHomeKey,
      ]);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('a removed page does not pop another stack entry', (
    tester,
  ) async {
    await _pumpOperatorApp(tester);
    final openEvent = tester
        .widget<EventListScreen>(find.byType(EventListScreen))
        .onOpenEvent!;
    openEvent('first-event');
    await tester.pumpAndSettle();
    openEvent('second-event');
    await tester.pumpAndSettle();
    final removedPage = _navigator(tester).pages.last;

    _goBack(tester);
    await tester.pumpAndSettle();
    _navigator(tester).onDidRemovePage!(removedPage);
    await tester.pumpAndSettle();

    expect(_navigator(tester).pages.map((page) => page.name), [
      'eventList',
      'eventHome',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigator pop removes only the matching page', (tester) async {
    await _pumpOperatorApp(tester);
    final openEvent = tester
        .widget<EventListScreen>(find.byType(EventListScreen))
        .onOpenEvent!;
    openEvent('first-event');
    await tester.pumpAndSettle();
    openEvent('second-event');
    await tester.pumpAndSettle();
    final remainingKeys = _navigator(
      tester,
    ).pages.take(2).map((page) => page.key).toList();

    tester
        .state<NavigatorState>(
          find.descendant(
            of: find.byType(OperatorApp),
            matching: find.byType(Navigator),
          ),
        )
        .pop();
    await tester.pumpAndSettle();

    expect(_navigator(tester).pages.map((page) => page.key), remainingKeys);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restores repeated destinations with distinct page keys', (
    tester,
  ) async {
    await _pumpOperatorApp(tester);
    final openProfile = tester
        .widget<EventListScreen>(find.byType(EventListScreen))
        .onOpenProfile!;
    openProfile();
    openProfile();
    await tester.pumpAndSettle();

    await tester.restartAndRestore();
    await tester.pumpAndSettle();

    final pages = _navigator(tester).pages;
    expect(pages.map((page) => page.name), [
      'eventList',
      'profileSession',
      'profileSession',
    ]);
    expect(pages.map((page) => page.key).toSet(), hasLength(3));
    expect(tester.takeException(), isNull);

    _goBack(tester);
    await tester.pumpAndSettle();
    expect(_navigator(tester).pages, hasLength(2));
  });
}
