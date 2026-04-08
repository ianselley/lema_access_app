import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/access/core/access_supabase.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAccessSupabase();
  runApp(const ProviderScope(child: LemaAccessApp()));
}
