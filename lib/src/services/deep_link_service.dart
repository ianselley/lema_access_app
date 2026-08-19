import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env_config.dart';

const _pendingScannerInviteCodeKey = 'pending_scanner_invite_code';

class AccessDeepLinkService extends ChangeNotifier {
  AccessDeepLinkService(this._preferences, this._appLinks);

  final SharedPreferences _preferences;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  String? get pendingScannerInviteCode =>
      _preferences.getString(_pendingScannerInviteCodeKey);

  Future<void> start() async {
    await _handleUri(await _appLinks.getInitialLink());
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  Future<void> clearPendingScannerInviteCode() async {
    await _preferences.remove(_pendingScannerInviteCodeKey);
    notifyListeners();
  }

  void disposeService() {
    _subscription?.cancel();
  }

  Future<void> _handleUri(Uri? uri) async {
    if (isAccessAuthCallback(uri)) {
      final tokenHash = uri!.queryParameters['token_hash'];
      if (tokenHash != null) {
        await Supabase.instance.client.auth.verifyOTP(
          tokenHash: tokenHash,
          type: OtpType.signup,
        );
        return;
      }

      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      return;
    }

    final code = extractScannerInviteCode(uri);
    if (code == null) {
      return;
    }

    await _preferences.setString(_pendingScannerInviteCodeKey, code);
    notifyListeners();
  }
}

bool isAccessAuthCallback(Uri? uri) {
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host.toLowerCase() ==
          EnvConfig.fromEnvironment().accessDeepLinkHost &&
      uri.path == '/access' &&
      (uri.queryParameters.containsKey('code') ||
          uri.queryParameters['type'] == 'signup' &&
              uri.queryParameters.containsKey('token_hash') ||
          uri.fragment.contains('access_token'));
}

String? extractScannerInviteCode(Uri? uri) {
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.toLowerCase() !=
          EnvConfig.fromEnvironment().accessDeepLinkHost ||
      uri.path != '/access/join') {
    return null;
  }

  final compact = (uri.queryParameters['invite_code'] ?? '')
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return compact.length == 6 ? compact : null;
}
