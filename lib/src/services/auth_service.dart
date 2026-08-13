import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/rpc_client.dart';

class AccessAuthService {
  AccessAuthService(this._client, this._rpcClient);

  final SupabaseClient _client;
  final AccessRpcClient _rpcClient;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'https://lema.club/access',
      data: <String, dynamic>{
        'displayName': displayName,
        'username': username,
        'signupSource': 'access_app',
      },
    );
  }

  Future<void> completeProfile({
    required String displayName,
    required String username,
  }) async {
    await _rpcClient.call(
      'access_complete_profile',
      params: <String, dynamic>{
        'p_display_name': displayName,
        'p_username': username,
      },
    );
  }

  Future<bool> isEmailRegistered(String email) async {
    final response = await _rpcClient.call(
      'access_check_email_registration',
      params: <String, dynamic>{'p_email': email},
    );
    return _readBooleanFlag(
      response['data'],
      preferredKeys: const <String>[
        'registered',
        'is_registered',
        'exists',
        'is_existing',
      ],
      defaultValue: false,
    );
  }

  Future<bool> isUsernameAvailable({
    required String username,
    String? excludeProfileId,
  }) async {
    final params = <String, dynamic>{'p_username': username};
    if (excludeProfileId != null && excludeProfileId.trim().isNotEmpty) {
      params['p_exclude_profile_id'] = excludeProfileId.trim();
    }

    final response = await _rpcClient.call(
      'access_check_username_available',
      params: params,
    );
    return _readBooleanFlag(
      response['data'],
      preferredKeys: const <String>['available', 'is_available', 'can_use'],
      defaultValue: true,
      invertForKeys: const <String>['taken', 'is_taken', 'exists'],
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  bool _readBooleanFlag(
    Object? payload, {
    required List<String> preferredKeys,
    required bool defaultValue,
    List<String> invertForKeys = const <String>[],
  }) {
    if (payload is bool) {
      return payload;
    }

    if (payload is Map) {
      final data = Map<String, dynamic>.from(payload);
      for (final key in preferredKeys) {
        final value = data[key];
        if (value is bool) {
          return value;
        }
      }

      for (final key in invertForKeys) {
        final value = data[key];
        if (value is bool) {
          return !value;
        }
      }
    }

    return defaultValue;
  }
}
