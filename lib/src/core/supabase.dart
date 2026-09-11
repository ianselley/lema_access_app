import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'debug_log.dart';
import 'env_config.dart';

const _databaseEnvironmentPreferenceKey = 'access_database_environment';

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
  await _restoreDatabaseEnvironment();
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

Future<void> switchAccessDatabase({
  required String email,
  required AppEnvironment target,
}) async {
  if (!EnvConfig.canSwitchDatabaseFor(email)) {
    throw StateError('No tienes permiso para cambiar la base de datos.');
  }

  final current = EnvConfig.fromEnvironment().environment;
  final expectedTarget = current == AppEnvironment.staging
      ? AppEnvironment.prod
      : AppEnvironment.staging;
  if (target != expectedTarget) {
    throw StateError('Solo se puede cambiar entre staging y producción.');
  }
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(_databaseEnvironmentPreferenceKey, target.name);

  await Supabase.instance.dispose();
  EnvConfig.setDatabaseEnvironment(target);
  await initializeAccessSupabase();
}

Future<void> _restoreDatabaseEnvironment() async {
  if (!EnvConfig.canSwitchDatabase) {
    return;
  }

  final savedEnvironment = (await SharedPreferences.getInstance()).getString(
    _databaseEnvironmentPreferenceKey,
  );
  if (savedEnvironment == null) {
    return;
  }

  try {
    EnvConfig.setDatabaseEnvironment(AppEnvironment.fromName(savedEnvironment));
  } on ArgumentError {
    // Ignore obsolete preference values and keep the build environment.
  }
}
