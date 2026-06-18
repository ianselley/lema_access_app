import 'package:flutter/material.dart';

class KeyboardDismissRegion extends StatelessWidget {
  const KeyboardDismissRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: child,
    );
  }

  void _handleTap() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
