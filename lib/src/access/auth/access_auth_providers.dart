import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/access_rpc_client.dart';
import '../core/access_rpc_exception.dart';
import 'access_auth_service.dart';

final accessRpcClientProvider = Provider<AccessRpcClient>((ref) {
  return AccessRpcClient(Supabase.instance.client);
});

final accessAuthServiceProvider = Provider<AccessAuthService>((ref) {
  return AccessAuthService(Supabase.instance.client);
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

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _service.signInWithPassword(email: email, password: password);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
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
