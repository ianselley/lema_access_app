import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/core/env_config.dart';

void main() {
  test('uses the matching LEMA domain for Access confirmation emails', () {
    expect(
      EnvConfig.staging.accessEmailRedirectUrl,
      'https://staging.lema.club/access',
    );
    expect(EnvConfig.prod.accessEmailRedirectUrl, 'https://lema.club/access');
    expect(EnvConfig.staging.accessDeepLinkHost, 'staging.lema.club');
  });

  test('allows anyone to leave staging, but only LEMA accounts to enter it', () {
    expect(
      EnvConfig.canSwitchDatabaseForEnvironment(
        AppEnvironment.prod,
        AppEnvironment.staging,
        'user@example.com',
      ),
      isTrue,
    );
    expect(
      EnvConfig.canSwitchDatabaseForEnvironment(
        AppEnvironment.prod,
        AppEnvironment.staging,
        null,
      ),
      isFalse,
    );
    expect(
      EnvConfig.canSwitchDatabaseForEnvironment(
        AppEnvironment.prod,
        AppEnvironment.prod,
        'admin@lema.club',
      ),
      isTrue,
    );
    expect(
      EnvConfig.canSwitchDatabaseForEnvironment(
        AppEnvironment.prod,
        AppEnvironment.prod,
        'user@example.com',
      ),
      isFalse,
    );
    expect(
      EnvConfig.canSwitchDatabaseForEnvironment(
        AppEnvironment.local,
        AppEnvironment.staging,
        'admin@lema.club',
      ),
      isFalse,
    );
  });
}
