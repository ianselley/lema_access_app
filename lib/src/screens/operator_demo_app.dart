import 'package:flutter/material.dart';

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

class OperatorDemoApp extends StatefulWidget {
  const OperatorDemoApp({super.key});

  @override
  State<OperatorDemoApp> createState() => _OperatorDemoAppState();
}

class _OperatorDemoAppState extends State<OperatorDemoApp> {
  DemoPage _page = DemoPage.login;

  void _open(DemoPage page) {
    setState(() {
      _page = page;
    });
  }

  Widget _wrapShell({required OperatorShellTab tab, required Widget child}) {
    return OperatorShellScreen(
      tab: tab,
      onSelectScanner: () => _open(DemoPage.scannerActive),
      onSelectManual: () => _open(DemoPage.manualCode),
      onSelectHistory: () => _open(DemoPage.recentHistory),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey(_page),
        child: switch (_page) {
          DemoPage.login => LoginScreen(
            onLogin: () => _open(DemoPage.eventList),
          ),
          DemoPage.eventList => EventListScreen(
            onOpenEvent: () => _open(DemoPage.eventHome),
            onOpenProfile: () => _open(DemoPage.profileSession),
          ),
          DemoPage.eventHome => EventHomeScreen(
            onOpenScanner: () => _open(DemoPage.scannerActive),
            onOpenHistory: () => _open(DemoPage.recentHistory),
          ),
          DemoPage.scannerActive => _wrapShell(
            tab: OperatorShellTab.scanner,
            child: ScannerActiveScreen(
              onOpenValid: () => _open(DemoPage.validResult),
              onOpenUsed: () => _open(DemoPage.usedResult),
              onOpenInvalid: () => _open(DemoPage.invalidResult),
              onOpenNotFound: () => _open(DemoPage.notFoundResult),
              onOpenNetworkError: () => _open(DemoPage.networkErrorResult),
              onManualEntry: () => _open(DemoPage.manualCode),
              onManualSearch: () => _open(DemoPage.manualSearch),
            ),
          ),
          DemoPage.validResult => ValidResultScreen(
            onContinueScanning: () => _open(DemoPage.scannerActive),
          ),
          DemoPage.usedResult => UsedResultScreen(
            onContinueScanning: () => _open(DemoPage.scannerActive),
          ),
          DemoPage.invalidResult => InvalidResultScreen(
            onContinueScanning: () => _open(DemoPage.scannerActive),
          ),
          DemoPage.notFoundResult => NotFoundResultScreen(
            onManualSearch: () => _open(DemoPage.manualSearch),
            onContinueScanning: () => _open(DemoPage.scannerActive),
          ),
          DemoPage.networkErrorResult => NetworkErrorResultScreen(
            onRetry: () => _open(DemoPage.scannerActive),
            onManualEntry: () => _open(DemoPage.manualCode),
          ),
          DemoPage.manualCode => _wrapShell(
            tab: OperatorShellTab.manual,
            child: ManualCodeScreen(
              onSubmitCode: () => _open(DemoPage.manualConfirmation),
              onOpenSearch: () => _open(DemoPage.manualSearch),
            ),
          ),
          DemoPage.manualSearch => _wrapShell(
            tab: OperatorShellTab.manual,
            child: ManualSearchScreen(
              onSearch: () => _open(DemoPage.searchResults),
            ),
          ),
          DemoPage.searchResults => _wrapShell(
            tab: OperatorShellTab.manual,
            child: SearchResultsScreen(
              onOpenTicketDetail: () => _open(DemoPage.ticketDetail),
            ),
          ),
          DemoPage.ticketDetail => TicketDetailScreen(
            onConfirmManualAccess: () => _open(DemoPage.manualConfirmation),
          ),
          DemoPage.manualConfirmation => ManualConfirmationScreen(
            onContinue: () => _open(DemoPage.scannerActive),
          ),
          DemoPage.recentHistory => _wrapShell(
            tab: OperatorShellTab.history,
            child: RecentHistoryScreen(
              onOpenTicketDetail: () => _open(DemoPage.ticketDetail),
            ),
          ),
          DemoPage.profileSession => ProfileSessionScreen(
            onLogout: () => _open(DemoPage.login),
          ),
        },
      ),
    );
  }
}
