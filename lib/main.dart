import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/supabase.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAccessSupabase();
  runApp(const AccessAppBootstrap());
}

class AccessAppBootstrap extends StatefulWidget {
  const AccessAppBootstrap({super.key});

  static VoidCallback? restartActionOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_AccessAppBootstrapState>();
    if (state == null) {
      return null;
    }

    return state.restartApp;
  }

  @override
  State<AccessAppBootstrap> createState() => _AccessAppBootstrapState();
}

class _AccessAppBootstrapState extends State<AccessAppBootstrap> {
  Key _providerScopeKey = UniqueKey();

  void restartApp() {
    setState(() {
      _providerScopeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(key: _providerScopeKey, child: const LemaAccessApp());
  }
}
