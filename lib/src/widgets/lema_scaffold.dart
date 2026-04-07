import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OperatorShellScope extends InheritedWidget {
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

class LemaScaffold extends StatelessWidget {
  const LemaScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigation,
    this.floatingActionButton,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 120),
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigation;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final shellBottomNavigation =
        bottomNavigation ??
        OperatorShellScope.maybeOf(context)?.bottomNavigation;

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
          child: Padding(padding: padding, child: body),
        ),
      ),
      bottomNavigationBar: shellBottomNavigation == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.84),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.28,
                          ),
                        ),
                      ),
                      child: shellBottomNavigation,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
