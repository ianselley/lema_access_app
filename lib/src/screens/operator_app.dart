import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/operator_route_observer.dart';
import '../providers/event_providers.dart';
import '../providers/ticket_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_scaffold.dart';
import 'event_home_screen.dart';
import 'event_list_screen.dart';
import 'invalid_result_screen.dart';
import 'login_screen.dart';
import 'manual_confirmation_screen.dart';
import 'manual_search_screen.dart';
import 'network_error_result_screen.dart';
import 'not_found_result_screen.dart';
import 'operator_shell_screen.dart';

import 'profile_session_screen.dart';

import 'scanner_active_screen.dart';
import 'search_results_screen.dart';
import 'ticket_detail_screen.dart';
import 'used_result_screen.dart';
import 'valid_result_screen.dart';

enum OperatorPage {
  login,
  eventList,
  eventHome,
  scannerActive,
  validResult,
  usedResult,
  invalidResult,
  notFoundResult,
  networkErrorResult,
  manualSearch,
  searchResults,
  ticketDetail,
  manualConfirmation,

  profileSession,
}

class OperatorApp extends ConsumerStatefulWidget {
  const OperatorApp({super.key});

  @override
  ConsumerState<OperatorApp> createState() => _OperatorAppState();
}

class _OperatorAppState extends ConsumerState<OperatorApp>
    with RestorationMixin {
  final RestorableStringN _navigationState = RestorableStringN(null);

  late List<_RouteEntry> _stack = _defaultStack();

  @override
  String? get restorationId => 'operator_app';

  bool get _canGoBack => _stack.length > 1;

  String? get _currentEventId =>
      ref.read(accessCurrentEventIdProvider)?.trim().isEmpty == true
      ? null
      : ref.read(accessCurrentEventIdProvider);

  List<_RouteEntry> _defaultStack() => <_RouteEntry>[
    _RouteEntry(OperatorPage.eventList),
  ];

  void _syncRestorationState() {
    _navigationState.value = jsonEncode(<String, Object?>{
      'eventId': _currentEventId,
      'stack': _stack
          .map(
            (entry) => <String, String?>{
              'page': entry.page.name,
              'eventId': entry.eventId,
            },
          )
          .toList(growable: false),
    });
  }

  void _restoreNavigationState() {
    final rawState = _navigationState.value;
    if (rawState == null || rawState.isEmpty) {
      _stack = _defaultStack();
      return;
    }

    try {
      final decoded = jsonDecode(rawState);
      if (decoded is! Map<String, dynamic>) {
        _stack = _defaultStack();
        return;
      }

      final restoredEventId = decoded['eventId'] as String?;
      final stackJson = decoded['stack'];
      final restoredStack = <_RouteEntry>[];

      if (stackJson is List<dynamic>) {
        for (final item in stackJson) {
          if (item is! Map<String, dynamic>) {
            continue;
          }

          final pageName = item['page'] as String?;
          final page = OperatorPage.values.where(
            (value) => value.name == pageName,
          );
          if (page.isEmpty) {
            continue;
          }

          restoredStack.add(
            _RouteEntry(page.first, eventId: item['eventId'] as String?),
          );
        }
      }

      _stack = restoredStack.isEmpty ? _defaultStack() : restoredStack;
      ref.read(accessCurrentEventIdProvider.notifier).state = restoredEventId;
    } catch (_) {
      _stack = _defaultStack();
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_navigationState, 'navigation_state');
    _restoreNavigationState();
  }

  void _push(OperatorPage page, {String? eventId}) {
    if (!mounted) {
      return;
    }

    if (eventId != null && eventId.trim().isNotEmpty) {
      ref.read(accessCurrentEventIdProvider.notifier).state = eventId;
    }

    setState(() {
      _stack.add(_RouteEntry(page, eventId: eventId));
    });
    _syncRestorationState();
  }

  void _replaceRoot(OperatorPage page, {String? eventId}) {
    if (!mounted) {
      return;
    }

    if (eventId != null && eventId.trim().isNotEmpty) {
      ref.read(accessCurrentEventIdProvider.notifier).state = eventId;
    } else if (page == OperatorPage.eventList || page == OperatorPage.login) {
      ref.read(accessCurrentEventIdProvider.notifier).state = null;
    }

    setState(() {
      _stack
        ..clear()
        ..add(_RouteEntry(page, eventId: eventId));
    });
    _syncRestorationState();
  }

  void _pop() {
    if (!mounted || !_canGoBack) {
      return;
    }

    if (_stack.last.page == OperatorPage.ticketDetail) {
      ref.read(accessTicketCheckInControllerProvider.notifier).reset();
    }

    setState(() {
      _stack.removeLast();
    });
    _syncRestorationState();
  }

  void _popToOrPush(OperatorPage page, {String? eventId}) {
    if (!mounted) {
      return;
    }

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
    _syncRestorationState();
  }

  void _openEventHome(String eventId) {
    _push(OperatorPage.eventHome, eventId: eventId);
  }

  void _switchPrimaryTool(OperatorPage page, {String? eventId}) {
    if (!mounted) {
      return;
    }

    if (_stack.isNotEmpty && _stack.last.page == page) {
      return;
    }

    final resolvedEventId = eventId ?? _currentEventId;
    final homeIndex = _stack.lastIndexWhere(
      (entry) => entry.page == OperatorPage.eventHome,
    );

    if (resolvedEventId != null && resolvedEventId.trim().isNotEmpty) {
      ref.read(accessCurrentEventIdProvider.notifier).state = resolvedEventId;
    }

    if (homeIndex == -1) {
      _push(page, eventId: resolvedEventId);
      return;
    }

    setState(() {
      _stack.removeRange(homeIndex + 1, _stack.length);
      _stack.add(_RouteEntry(page, eventId: resolvedEventId));
    });
    _syncRestorationState();
  }

  Widget _wrapShell({required Widget child}) {
    return OperatorShellScreen(child: child);
  }

  Widget _buildScreen(_RouteEntry entry) {
    switch (entry.page) {
      case OperatorPage.login:
        return LoginScreen(onLogin: () => _replaceRoot(OperatorPage.eventList));
      case OperatorPage.eventList:
        return EventListScreen(
          onOpenEvent: _openEventHome,
          onOpenProfile: () => _push(OperatorPage.profileSession),
        );
      case OperatorPage.eventHome:
        return EventHomeScreen(
          eventId: entry.eventId ?? _currentEventId ?? '',
          onOpenScanner: () => _switchPrimaryTool(
            OperatorPage.scannerActive,
            eventId: entry.eventId ?? _currentEventId,
          ),
          onOpenTicketDetail: () => _push(OperatorPage.ticketDetail),
          bottomOverlay: _EventHomeScanCta(
            onPressed: () => _switchPrimaryTool(
              OperatorPage.scannerActive,
              eventId: entry.eventId ?? _currentEventId,
            ),
          ),
        );
      case OperatorPage.scannerActive:
        return _wrapShell(
          child: ScannerActiveScreen(
            onOpenManualSearch: () =>
                _push(OperatorPage.manualSearch, eventId: _currentEventId),
            onOpenTicketDetail: () => _push(OperatorPage.ticketDetail),
          ),
        );
      case OperatorPage.validResult:
        return ValidResultScreen(
          onContinueScanning: () => _popToOrPush(OperatorPage.scannerActive),
        );
      case OperatorPage.usedResult:
        return UsedResultScreen(
          onContinueScanning: () => _popToOrPush(OperatorPage.scannerActive),
        );
      case OperatorPage.invalidResult:
        return InvalidResultScreen(
          onContinueScanning: () => _popToOrPush(OperatorPage.scannerActive),
        );
      case OperatorPage.notFoundResult:
        return NotFoundResultScreen(
          onManualSearch: () => _push(
            OperatorPage.manualSearch,
            eventId: _currentEventId,
          ),
          onContinueScanning: () => _popToOrPush(OperatorPage.scannerActive),
        );
      case OperatorPage.networkErrorResult:
        return NetworkErrorResultScreen(
          onRetry: () => _popToOrPush(OperatorPage.scannerActive),
          onManualSearch: () => _push(
            OperatorPage.manualSearch,
            eventId: _currentEventId,
          ),
        );
      case OperatorPage.manualSearch:
        return ManualSearchScreen(
          onSearch: () => _push(OperatorPage.searchResults),
        );
      case OperatorPage.searchResults:
        return SearchResultsScreen(
          onOpenTicketDetail: () => _push(OperatorPage.ticketDetail),
        );
      case OperatorPage.ticketDetail:
        return TicketDetailScreen(
          onConfirmManualAccess: () => _push(OperatorPage.manualConfirmation),
        );
      case OperatorPage.manualConfirmation:
        return ManualConfirmationScreen(
          onContinue: () => _popToOrPush(OperatorPage.scannerActive),
        );

      case OperatorPage.profileSession:
        return ProfileSessionScreen(
          onLogout: () => _replaceRoot(OperatorPage.login),
        );
    }
  }

  Page<void> _buildPage(_RouteEntry entry) {
    final child = _buildScreen(entry);
    final name = entry.page.name;
    final key = ValueKey<String>('${entry.page.name}:${entry.eventId ?? ''}');

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPage<void>(key: key, name: name, child: child);
    }

    return MaterialPage<void>(key: key, name: name, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return OperatorNavigationScope(
      canGoBack: _canGoBack,
      onBack: _pop,
      child: Navigator(
        observers: [operatorRouteObserver],
        pages: _stack.map(_buildPage).toList(growable: false),
        onDidRemovePage: (page) {
          _pop();
        },
      ),
    );
  }
}

class _RouteEntry {
  _RouteEntry(this.page, {this.eventId});

  final OperatorPage page;
  final String? eventId;
}

class _EventHomeScanCta extends StatelessWidget {
  const _EventHomeScanCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shadow gradient overlay
          IgnorePointer(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 1.0],
                  colors: [
                    AppColors.background.withValues(alpha: 0.0),
                    AppColors.background.withValues(alpha: 0.65),
                    AppColors.background.withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
          ),
          // CTA button area
          Container(
            color: AppColors.background.withValues(alpha: 0.98),
            padding: EdgeInsets.only(
              left: 28,
              right: 28,
              top: 0,
              bottom: 6 + bottomPadding,
            ),
            child: _ScanButton(onPressed: onPressed),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatefulWidget {
  const _ScanButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowOpacity = 0.25 + (_glowController.value * 0.2);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryStrong.withValues(alpha: glowOpacity),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.primaryStrong, Color(0xFFFF9B6A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 24,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Escanear QR',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
