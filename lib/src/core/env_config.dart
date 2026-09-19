import 'package:flutter/foundation.dart';


enum AppEnvironment {
  local,
  staging,
  prod;

  static AppEnvironment fromName(String name) {
    return switch (name.toLowerCase()) {
      'local' => AppEnvironment.local,
      'staging' => AppEnvironment.staging,
      'prod' || 'production' => AppEnvironment.prod,
      _ => throw ArgumentError.value(
        name,
        'name',
        'Unsupported APP_ENV. Expected local, staging, or prod.',
      ),
    };
  }
}

class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  static const String defaultEnvironmentName =
      'prod'; // TODO: ALWAYS CHECK BEFORE DEPLOYING.

  static final AppEnvironment _buildEnvironment = AppEnvironment.fromName(
    const String.fromEnvironment(
      'APP_ENV',
      defaultValue: defaultEnvironmentName,
    ),
  );
  static final ValueNotifier<AppEnvironment> environmentNotifier =
      ValueNotifier<AppEnvironment>(_buildEnvironment);

  static const EnvConfig local = EnvConfig(
    environment: AppEnvironment.local,
    supabaseUrl: 'http://127.0.0.1:54321',
    supabaseAnonKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
  );

  static const EnvConfig staging = EnvConfig(
    environment: AppEnvironment.staging,
    supabaseUrl: 'https://wcwcfxzjrxzxalaswzdt.supabase.co',
    supabaseAnonKey: 'sb_publishable_7uJbYK21atLDgBR370m0ag_5n5QIYuL',
  );

  static const EnvConfig prod = EnvConfig(
    environment: AppEnvironment.prod,
    supabaseUrl: 'https://eatblkdojlpjdscxmual.supabase.co',
    supabaseAnonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVhdGJsa2RvamxwamRzY3htdWFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTUwMzE3MDgsImV4cCI6MjAxMDYwNzcwOH0.mGDeeCeN0UR8FRrw4T1xB1mrjT51TjmO1TFk4-mgmNg',
  );

  factory EnvConfig.fromEnvironment() {
    const supabaseUrlOverride = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    const supabaseAnonKeyOverride = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    final baseConfig = switch (environmentNotifier.value) {
      AppEnvironment.local => local,
      AppEnvironment.staging => staging,
      AppEnvironment.prod => prod,
    };

    return baseConfig.copyWith(
      supabaseUrl: supabaseUrlOverride.isEmpty ? null : supabaseUrlOverride,
      supabaseAnonKey: supabaseAnonKeyOverride.isEmpty
          ? null
          : supabaseAnonKeyOverride,
    );
  }

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;

  String get environmentName => environment.name;

  static bool get canSwitchDatabase =>
      _buildEnvironment != AppEnvironment.local;

  static bool canSwitchDatabaseFor(String? email) =>
      canSwitchDatabaseForEnvironment(_buildEnvironment, email);

  static bool canSwitchDatabaseForEnvironment(
    AppEnvironment buildEnvironment,
    String? email,
  ) =>
      buildEnvironment != AppEnvironment.local &&
      (email?.trim().toLowerCase().endsWith('@lema.club') ?? false);

  static void setDatabaseEnvironment(AppEnvironment value) {
    if (!canSwitchDatabase || value == AppEnvironment.local) {
      throw StateError(
        'Database switching is unavailable in local development.',
      );
    }
    environmentNotifier.value = value;
  }

  String get accessEmailRedirectUrl => switch (environment) {
    AppEnvironment.local => 'https://127.0.0.1:3000/access',
    AppEnvironment.staging => 'https://staging.lema.club/access',
    AppEnvironment.prod => 'https://lema.club/access',
  };

  String get accessDeepLinkHost => switch (environment) {
    AppEnvironment.local => '127.0.0.1',
    AppEnvironment.staging => 'staging.lema.club',
    AppEnvironment.prod => 'lema.club',
  };

  EnvConfig copyWith({
    AppEnvironment? environment,
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) {
    return EnvConfig(
      environment: environment ?? this.environment,
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
    );
  }
}
