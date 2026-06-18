import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/rpc_client.dart';
import '../core/rpc_exception.dart';
import '../services/auth_service.dart';

final accessRpcClientProvider = Provider<AccessRpcClient>((ref) {
  return AccessRpcClient(Supabase.instance.client);
});

final accessAuthServiceProvider = Provider<AccessAuthService>((ref) {
  return AccessAuthService(
    Supabase.instance.client,
    ref.watch(accessRpcClientProvider),
  );
});

Stream<Session?> _sessionStream(SupabaseClient client) async* {
  yield client.auth.currentSession;
  await for (final event in client.auth.onAuthStateChange) {
    yield event.session;
  }
}

final authSessionProvider = StreamProvider<Session?>((ref) {
  return _sessionStream(Supabase.instance.client);
});

final accessSessionProvider = authSessionProvider;

final accessCurrentUserProvider = Provider<User?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull?.user;
});

AccessRpcException authRequiredException() {
  return const AccessRpcException(
    code: 'AUTH_REQUIRED',
    message: 'Authentication required.',
  );
}

class AccessAuthController extends AsyncNotifier<void> {
  AccessAuthService get _service => ref.read(accessAuthServiceProvider);

  void reset() {
    state = const AsyncData(null);
  }

  Future<bool> checkEmailRegistration(String email) {
    return _service.isEmailRegistered(email);
  }

  Future<bool> checkUsernameAvailability({
    required String username,
    String? excludeProfileId,
  }) {
    return _service.isUsernameAvailable(
      username: username,
      excludeProfileId: excludeProfileId,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _service.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return response;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _service.signUpWithPassword(
        email: email,
        password: password,
        displayName: displayName,
        username: username,
      );
      state = const AsyncData(null);
      return response;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> completeProfile({
    required String displayName,
    required String username,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.completeProfile(
        displayName: displayName,
        username: username,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _service.signOut();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  @override
  FutureOr<void> build() {}
}

final accessAuthControllerProvider =
    AsyncNotifierProvider<AccessAuthController, void>(AccessAuthController.new);

final accessAuthActionProvider = accessAuthControllerProvider;
