import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/activity_refresh_providers.dart';
import 'providers/auth_providers.dart';
import 'providers/bootstrap_providers.dart';
import 'core/env_config.dart';
import 'screens/gate_screen.dart';
import 'services/deep_link_service.dart';
import 'theme/app_theme.dart';
import 'widgets/keyboard_dismiss_region.dart';

class LemaAccessApp extends StatelessWidget {
  const LemaAccessApp({super.key, this.deepLinks});

  final AccessDeepLinkService? deepLinks;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LEMA Access',
      theme: AppTheme.build(),
      restorationScopeId: 'lema_access_app',
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<AppEnvironment>(
          valueListenable: EnvConfig.environmentNotifier,
          builder: (context, environment, _) {
            final content = KeyboardDismissRegion(child: child);
            if (environment != AppEnvironment.staging) {
              return content;
            }

            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const _StagingBanner(),
                  const SizedBox(height: 4),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: content,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      home: _AccessLifecycleBoundary(
        child: deepLinks == null
            ? const AccessGateScreen()
            : AnimatedBuilder(
                animation: deepLinks!,
                builder: (context, child) =>
                    AccessGateScreen(deepLinks: deepLinks),
              ),
      ),
    );
  }
}

class _StagingBanner extends StatelessWidget {
  const _StagingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: double.infinity,
      alignment: Alignment.center,
      color: AppColors.warning,
      child: const Text(
        'ESTÁS EN STAGING',
        style: TextStyle(
          color: AppColors.black,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _AccessLifecycleBoundary extends ConsumerStatefulWidget {
  const _AccessLifecycleBoundary({required this.child});

  final Widget child;

  @override
  ConsumerState<_AccessLifecycleBoundary> createState() =>
      _AccessLifecycleBoundaryState();
}

class _AccessLifecycleBoundaryState
    extends ConsumerState<_AccessLifecycleBoundary>
    with WidgetsBindingObserver {
  static const _refreshAfterIdle = Duration(minutes: 10);

  DateTime? _lastInactiveAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAfterExtendedIdle();
      return;
    }

    _lastInactiveAt ??= DateTime.now();
  }

  void _refreshAfterExtendedIdle() {
    final lastInactiveAt = _lastInactiveAt;
    _lastInactiveAt = null;

    if (lastInactiveAt == null) {
      return;
    }

    final idleTime = DateTime.now().difference(lastInactiveAt);
    if (idleTime < _refreshAfterIdle) {
      return;
    }

    ref.invalidate(authSessionProvider);
    ref.read(accessActivityRefreshTickProvider.notifier).state++;
    ref.invalidate(accessBootstrapProvider);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
