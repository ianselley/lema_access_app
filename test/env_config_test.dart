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

  test('only enables database switching for LEMA accounts outside local', () {
    expect(EnvConfig.canSwitchDatabaseFor('admin@lema.club'), isTrue);
    expect(EnvConfig.canSwitchDatabaseFor('admin@example.com'), isFalse);
    expect(
      EnvConfig.canSwitchDatabaseForEnvironment(
        AppEnvironment.local,
        'admin@lema.club',
      ),
      isFalse,
    );
  });
}
