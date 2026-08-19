import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/services/deep_link_service.dart';

void main() {
  test('extracts only valid LEMA Access scanner invite links', () {
    expect(
      extractScannerInviteCode(
        Uri.parse('https://staging.lema.club/access/join?invite_code=a1b-2c3'),
      ),
      'A1B2C3',
    );
    expect(
      extractScannerInviteCode(
        Uri.parse('https://staging.lema.club/access?invite_code=A1B-2C3'),
      ),
      isNull,
    );
    expect(
      extractScannerInviteCode(
        Uri.parse('https://example.com/access/join?invite_code=A1B-2C3'),
      ),
      isNull,
    );
  });

  test('recognizes Supabase signup callbacks used by the current email', () {
    expect(
      isAccessAuthCallback(
        Uri.parse(
          'https://staging.lema.club/access?token_hash=token&type=signup',
        ),
      ),
      isTrue,
    );
    expect(
      isAccessAuthCallback(
        Uri.parse(
          'https://staging.lema.club/access?token_hash=token&type=recovery',
        ),
      ),
      isFalse,
    );
  });
}
