import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'access_debug_log.dart';

class AccessSupabaseConfig {
  const AccessSupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  factory AccessSupabaseConfig.fromEnvironment() {
    final configuredUrl = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'http://127.0.0.1:54321',
    );
    final configuredAnonKey = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    );

    final resolvedUrl = configuredUrl.startsWith('http://127.0.0.1') &&
            defaultTargetPlatform == TargetPlatform.android
        ? configuredUrl.replaceFirst('127.0.0.1', '10.0.2.2')
        : configuredUrl;

    return AccessSupabaseConfig(
      url: resolvedUrl,
      anonKey: configuredAnonKey,
    );
  }

  final String url;
  final String anonKey;
}

Future<void> initializeAccessSupabase() async {
  final config = AccessSupabaseConfig.fromEnvironment();
  accessLog('Initializing Supabase for ${config.url}', scope: 'supabase');

  await Supabase.initialize(
    url: config.url,
    anonKey: config.anonKey,
  );

  accessLog(
    'Supabase initialized. hasSession=${Supabase.instance.client.auth.currentSession != null}',
    scope: 'supabase',
  );
}
