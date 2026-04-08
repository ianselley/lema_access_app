import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/tickets/access_ticket_providers.dart';
import '../widgets/lema_scaffold.dart';
import 'event_home_screen.dart';
import 'event_list_screen.dart';
import 'invalid_result_screen.dart';
import 'login_screen.dart';
import 'manual_code_screen.dart';
import 'manual_confirmation_screen.dart';
import 'manual_search_screen.dart';
import 'network_error_result_screen.dart';
import 'not_found_result_screen.dart';
import 'operator_shell_screen.dart';
import 'profile_session_screen.dart';
import 'recent_history_screen.dart';
import 'scanner_active_screen.dart';
import 'search_results_screen.dart';
import 'ticket_detail_screen.dart';
import 'used_result_screen.dart';
import 'valid_result_screen.dart';

enum DemoPage {
  login,
  eventList,
  eventHome,
  scannerActive,
  validResult,
  usedResult,
  invalidResult,
  notFoundResult,
  networkErrorResult,
  manualCode,
  manualSearch,
  searchResults,
  ticketDetail,
  manualConfirmation,
  recentHistory,
  profileSession,
}

class OperatorDemoApp extends ConsumerStatefulWidget {
  const OperatorDemoApp({super.key});

  @override
  ConsumerState<OperatorDemoApp> createState() => _OperatorDemoAppState();
}

class _OperatorDemoAppState extends ConsumerState<OperatorDemoApp> {
  final List<_DemoRouteEntry> _stack = <_DemoRouteEntry>[
    _DemoRouteEntry(DemoPage.eventList),
  ];

  bool get _canGoBack => _stack.length > 1;

  String? get _currentEventId =>
      ref.read(accessCurrentEventIdProvider)?.trim().isEmpty == true
      ? null
      : ref.read(accessCurrentEventIdProvider);

  void _push(DemoPage page, {String? eventId}) {
    if (eventId != null && eventId.trim().isNotEmpty) {
      ref.read(accessCurrentEventIdProvider.notifier).state = eventId;
    }

    setState(() {
      _stack.add(_DemoRouteEntry(page, eventId: eventId));
    });
  }

  void _replaceRoot(DemoPage page, {String? eventId}) {
    if (eventId != null && eventId.trim().isNotEmpty) {
      ref.read(accessCurrentEventIdProvider.notifier).state = eventId;
    } else if (page == DemoPage.eventList || page == DemoPage.login) {
      ref.read(accessCurrentEventIdProvider.notifier).state = null;
    }

    setState(() {
      _stack
        ..clear()
        ..add(_DemoRouteEntry(page, eventId: eventId));
    });
  }

  void _pop() {
    if (!_canGoBack) {
      return;
    }

    setState(() {
      _stack.removeLast();
    });
  }

  void _popToOrPush(DemoPage page, {String? eventId}) {
    final index = _stack.lastIndexWhere((entry) => entry.page == page);

    if (index == -1) {
      _push(page, eventId: eventId);
      return;
    }

    if (eventId != null && eventId.trim().isNotEmpty) {
      ref.read(accessCurrentEventIdProvider.notifier).state = eventId;
    }

    setState(() {
      _stack.removeRange(index + 1, _stack.length);
    });
  }

  void _openEventHome(String eventId) {
    _push(DemoPage.eventHome, eventId: eventId);
  }

  Widget _wrapShell({required OperatorShellTab tab, required Widget child}) {
    return OperatorShellScreen(
      tab: tab,
      onSelectScanner: () => _popToOrPush(DemoPage.scannerActive),
      onSelectManual: () => _popToOrPush(DemoPage.manualCode),
      onSelectHistory: () => _popToOrPush(
        DemoPage.recentHistory,
        eventId: _currentEventId,
      ),
      child: child,
    );
  }

  Widget _buildScreen(_DemoRouteEntry entry) {
    switch (entry.page) {
      case DemoPage.login:
        return LoginScreen(
          onLogin: () => _replaceRoot(DemoPage.eventList),
        );
      case DemoPage.eventList:
        return EventListScreen(
          onOpenEvent: _openEventHome,
          onOpenProfile: () => _push(DemoPage.profileSession),
        );
      case DemoPage.eventHome:
        return EventHomeScreen(
          eventId: entry.eventId ?? _currentEventId ?? '',
          onOpenScanner: () => _push(DemoPage.scannerActive),
          onOpenHistory: () => _push(
            DemoPage.recentHistory,
            eventId: entry.eventId ?? _currentEventId,
          ),
        );
      case DemoPage.scannerActive:
        return _wrapShell(
          tab: OperatorShellTab.scanner,
          child: ScannerActiveScreen(
            onOpenValid: () => _push(DemoPage.validResult),
            onOpenUsed: () => _push(DemoPage.usedResult),
            onOpenInvalid: () => _push(DemoPage.invalidResult),
            onOpenNotFound: () => _push(DemoPage.notFoundResult),
            onOpenNetworkError: () => _push(DemoPage.networkErrorResult),
            onManualEntry: () => _push(DemoPage.manualCode),
            onManualSearch: () => _push(DemoPage.manualSearch),
          ),
        );
      case DemoPage.validResult:
        return ValidResultScreen(
          onContinueScanning: () => _popToOrPush(DemoPage.scannerActive),
        );
      case DemoPage.usedResult:
        return UsedResultScreen(
          onContinueScanning: () => _popToOrPush(DemoPage.scannerActive),
        );
      case DemoPage.invalidResult:
        return InvalidResultScreen(
          onContinueScanning: () => _popToOrPush(DemoPage.scannerActive),
        );
      case DemoPage.notFoundResult:
        return NotFoundResultScreen(
          onManualSearch: () => _push(DemoPage.manualSearch),
          onContinueScanning: () => _popToOrPush(DemoPage.scannerActive),
        );
      case DemoPage.networkErrorResult:
        return NetworkErrorResultScreen(
          onRetry: () => _popToOrPush(DemoPage.scannerActive),
          onManualEntry: () => _push(DemoPage.manualCode),
        );
      case DemoPage.manualCode:
        return _wrapShell(
          tab: OperatorShellTab.manual,
          child: ManualCodeScreen(
            onSubmitCode: () => _push(DemoPage.manualConfirmation),
            onOpenSearch: () => _push(DemoPage.manualSearch),
          ),
        );
      case DemoPage.manualSearch:
        return _wrapShell(
          tab: OperatorShellTab.manual,
          child: ManualSearchScreen(
            onSearch: () => _push(DemoPage.searchResults),
          ),
        );
      case DemoPage.searchResults:
        return _wrapShell(
          tab: OperatorShellTab.manual,
          child: SearchResultsScreen(
            onOpenTicketDetail: () => _push(DemoPage.ticketDetail),
          ),
        );
      case DemoPage.ticketDetail:
        return TicketDetailScreen(
          onConfirmManualAccess: () => _push(DemoPage.manualConfirmation),
        );
      case DemoPage.manualConfirmation:
        return ManualConfirmationScreen(
          onContinue: () => _popToOrPush(DemoPage.scannerActive),
        );
      case DemoPage.recentHistory:
        return _wrapShell(
          tab: OperatorShellTab.history,
          child: RecentHistoryScreen(
            eventId: entry.eventId ?? _currentEventId,
            onOpenTicketDetail: () => _push(DemoPage.ticketDetail),
          ),
        );
      case DemoPage.profileSession:
        return ProfileSessionScreen(
          onLogout: () => _replaceRoot(DemoPage.login),
        );
    }
  }

  Page<void> _buildPage(_DemoRouteEntry entry) {
    final child = _buildScreen(entry);
    final name = entry.page.name;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPage<void>(
        key: entry.key,
        name: name,
        child: child,
      );
    }

    return MaterialPage<void>(
      key: entry.key,
      name: name,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OperatorNavigationScope(
      canGoBack: _canGoBack,
      onBack: _pop,
      child: Navigator(
        pages: _stack.map(_buildPage).toList(growable: false),
        onDidRemovePage: (page) {
          _pop();
        },
      ),
    );
  }
}

class _DemoRouteEntry {
  _DemoRouteEntry(this.page, {this.eventId}) : key = UniqueKey();

  final DemoPage page;
  final String? eventId;
  final LocalKey key;
}
