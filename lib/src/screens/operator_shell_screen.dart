import 'package:flutter/material.dart';

import '../widgets/lema_scaffold.dart';

class OperatorShellScreen extends StatelessWidget {
  const OperatorShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OperatorShellScope(child: child);
  }
}
