import 'package:flutter/material.dart';

import 'access/auth/access_gate_screen.dart';
import 'theme/app_theme.dart';

class LemaAccessApp extends StatelessWidget {
  const LemaAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LEMA Access',
      theme: AppTheme.build(),
      home: const AccessGateScreen(),
    );
  }
}
