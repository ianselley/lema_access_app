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

  static const String defaultEnvironmentName = 'staging';

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
    const configuredEnvironmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: defaultEnvironmentName,
    );
    const supabaseUrlOverride = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    const supabaseAnonKeyOverride = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    final baseConfig = switch (AppEnvironment.fromName(
      configuredEnvironmentName,
    )) {
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
