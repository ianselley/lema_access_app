import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'debug_log.dart';
import 'env_config.dart';

class AccessSupabaseConfig {
  const AccessSupabaseConfig({required this.url, required this.anonKey});

  factory AccessSupabaseConfig.fromEnvironment() {
    final envConfig = EnvConfig.fromEnvironment();

    final resolvedUrl =
        envConfig.supabaseUrl.startsWith('http://127.0.0.1') &&
            defaultTargetPlatform == TargetPlatform.android
        ? envConfig.supabaseUrl.replaceFirst('127.0.0.1', '10.0.2.2')
        : envConfig.supabaseUrl;

    final resolvedUri = Uri.tryParse(resolvedUrl);
    final isReleaseSafeUrl =
        resolvedUri != null &&
        resolvedUri.hasScheme &&
        resolvedUri.scheme == 'https' &&
        resolvedUri.host.isNotEmpty;

    if (kReleaseMode && !isReleaseSafeUrl) {
      throw StateError(
        'Release builds require an HTTPS Supabase URL. '
        'Current APP_ENV: ${envConfig.environmentName}. Current value: $resolvedUrl',
      );
    }

    return AccessSupabaseConfig(
      url: resolvedUrl,
      anonKey: envConfig.supabaseAnonKey,
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
    authOptions: const FlutterAuthClientOptions(detectSessionInUri: false),
  );

  accessLog(
    'Supabase initialized. hasSession=${Supabase.instance.client.auth.currentSession != null}',
    scope: 'supabase',
  );
}
