import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OperatorShellScope extends InheritedWidget {
  static const double bottomNavigationOverlayHeight = 104;

  const OperatorShellScope({
    super.key,
    required super.child,
    this.bottomNavigation,
  });

  final Widget? bottomNavigation;

  static OperatorShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OperatorShellScope>();
  }

  @override
  bool updateShouldNotify(OperatorShellScope oldWidget) {
    return bottomNavigation != oldWidget.bottomNavigation;
  }
}

class OperatorNavigationScope extends InheritedWidget {
  const OperatorNavigationScope({
    super.key,
    required super.child,
    required this.canGoBack,
    this.onBack,
  });

  final bool canGoBack;
  final VoidCallback? onBack;

  static OperatorNavigationScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OperatorNavigationScope>();
  }

  @override
  bool updateShouldNotify(OperatorNavigationScope oldWidget) {
    return canGoBack != oldWidget.canGoBack || onBack != oldWidget.onBack;
  }
}

class OperatorShellBottomSpacer extends StatelessWidget {
  const OperatorShellBottomSpacer({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    if (OperatorShellScope.maybeOf(context) == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: height ?? OperatorShellScope.bottomNavigationOverlayHeight,
    );
  }
}

class LemaScaffold extends StatelessWidget {
  const LemaScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigation,
    this.floatingActionButton,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
    this.showAutomaticBackButton = true,
    this.compactBackButton = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigation;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final bool showAutomaticBackButton;
  final bool compactBackButton;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final resolvedPadding = padding.resolve(direction);
    final shellBottomNavigation =
        bottomNavigation ??
        OperatorShellScope.maybeOf(context)?.bottomNavigation;
    final navigationScope = OperatorNavigationScope.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    final canPopRoute = navigator?.canPop() ?? false;
    final canGoBack = navigationScope?.canGoBack ?? false;
    final showBackButton =
        showAutomaticBackButton && (canPopRoute || canGoBack);
    final topPadding = switch ((showBackButton, resolvedPadding.top)) {
      (true, final top) when top >= 16 => 2.0,
      (true, final top) when top >= 10 => 1.0,
      (true, _) => resolvedPadding.top,
      (false, final top) when top >= 18 => 6.0,
      (false, final top) when top >= 12 => 5.0,
      (false, _) => resolvedPadding.top,
    };
    final effectivePadding = resolvedPadding.copyWith(top: topPadding);

    return Scaffold(
      appBar: appBar,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [Color(0x14EF8354), AppColors.background],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: effectivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showBackButton) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: compactBackButton ? 0 : 12,
                        ),
                        minimumSize: Size(0, compactBackButton ? 24 : 48),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: compactBackButton
                            ? const VisualDensity(horizontal: -2, vertical: -4)
                            : VisualDensity.standard,
                        foregroundColor: compactBackButton
                            ? AppColors.onSurfaceMuted
                            : AppColors.onSurface,
                        textStyle: compactBackButton
                            ? null
                            : const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                      ),
                      onPressed: () async {
                        final didPop = await navigator?.maybePop() ?? false;
                        if (!didPop) {
                          navigationScope?.onBack?.call();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: compactBackButton ? 18 : 22,
                      ),
                      label: const Text('Volver'),
                    ),
                  ),
                  SizedBox(height: compactBackButton ? 12 : 6),
                ],
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: shellBottomNavigation == null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.84),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.28),
                      ),
                    ),
                    child: shellBottomNavigation,
                  ),
                ),
              ),
            ),
    );
  }
}
