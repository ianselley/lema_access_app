import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/supabase.dart';
import 'src/app.dart';
import 'src/services/deep_link_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAccessSupabase();
  final deepLinks = AccessDeepLinkService(
    await SharedPreferences.getInstance(),
    AppLinks(),
  );
  await deepLinks.start();
  runApp(AccessAppBootstrap(deepLinks: deepLinks));
}

class AccessAppBootstrap extends StatefulWidget {
  const AccessAppBootstrap({super.key, required this.deepLinks});

  final AccessDeepLinkService deepLinks;

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
    return ProviderScope(
      key: _providerScopeKey,
      child: LemaAccessApp(deepLinks: widget.deepLinks),
    );
  }

  @override
  void dispose() {
    widget.deepLinks.disposeService();
    super.dispose();
  }
}
