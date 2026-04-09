import 'package:flutter_test/flutter_test.dart';
import 'package:lema_access_app/src/core/scan_input_normalizer.dart';

void main() {
  group('normalizeAccessScanInput', () {
    test('extracts token from lema ticket url', () {
      expect(
        normalizeAccessScanInput(
          'https://lema.club/ticket/eff7df0fc34e5c7d7bb156669303b311b454da37be6b6e23',
        ),
        'eff7df0fc34e5c7d7bb156669303b311b454da37be6b6e23',
      );
    });

    test('supports trailing slash and query parameters', () {
      expect(
        normalizeAccessScanInput(
          'https://www.lema.club/ticket/abc123/?utm_source=qr',
        ),
        'abc123',
      );
    });

    test('keeps non ticket inputs untouched', () {
      expect(normalizeAccessScanInput('VSGJ13U9'), 'VSGJ13U9');
      expect(
        normalizeAccessScanInput('https://example.com/ticket/abc123'),
        'https://example.com/ticket/abc123',
      );
    });
  });

  group('extractLemaTicketToken', () {
    test('returns token for lema ticket url', () {
      expect(
        extractLemaTicketToken('https://lema.club/ticket/abc123'),
        'abc123',
      );
    });

    test('returns bare scan token when already extracted', () {
      expect(
        extractLemaTicketToken(
          'eff7df0fc34e5c7d7bb156669303b311b454da37be6b6e23',
        ),
        'eff7df0fc34e5c7d7bb156669303b311b454da37be6b6e23',
      );
    });

    test('returns null for non lema ticket input', () {
      expect(extractLemaTicketToken('VSGJ13U9'), isNull);
      expect(
        extractLemaTicketToken('https://example.com/ticket/abc123'),
        isNull,
      );
    });
  });
}
