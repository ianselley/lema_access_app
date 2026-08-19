import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/debug_log.dart';
import '../core/env_config.dart';

const _pendingScannerInviteCodeKey = 'pending_scanner_invite_code';

class AccessDeepLinkService extends ChangeNotifier {
  AccessDeepLinkService(this._preferences, this._appLinks);

  final SharedPreferences _preferences;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  final Set<String> _handledLinks = <String>{};

  String? get pendingScannerInviteCode =>
      _preferences.getString(_pendingScannerInviteCodeKey);

  void start() {
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
    unawaited(_handleInitialLink());
  }

  Future<void> clearPendingScannerInviteCode() async {
    await _preferences.remove(_pendingScannerInviteCodeKey);
    notifyListeners();
  }

  void disposeService() {
    _subscription?.cancel();
  }

  Future<void> _handleUri(Uri? uri) async {
    final isAuthCallback = isAccessAuthCallback(uri);
    final scannerInviteCode = extractScannerInviteCode(uri);
    if (!isAuthCallback && scannerInviteCode == null) {
      return;
    }

    if (!_handledLinks.add(uri.toString())) {
      return;
    }

    try {
      if (isAuthCallback) {
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

      await _preferences.setString(
        _pendingScannerInviteCodeKey,
        scannerInviteCode!,
      );
      notifyListeners();
    } catch (error, stackTrace) {
      accessLog(
        'Deep link processing failed',
        scope: 'deep-link',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleInitialLink() async {
    try {
      await _handleUri(await _appLinks.getInitialLink());
    } catch (error, stackTrace) {
      accessLog(
        'Initial deep link retrieval failed',
        scope: 'deep-link',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

bool isAccessAuthCallback(Uri? uri) {
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.toLowerCase() !=
          EnvConfig.fromEnvironment().accessDeepLinkHost ||
      uri.path != '/access') {
    return false;
  }

  return uri.queryParameters.containsKey('code') ||
      uri.queryParameters['type'] == 'signup' &&
          uri.queryParameters.containsKey('token_hash') ||
      uri.fragment.contains('access_token');
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
