import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/access_auth_providers.dart';
import '../models/access_bootstrap.dart';
import 'access_bootstrap_service.dart';

final accessBootstrapServiceProvider = Provider<AccessBootstrapService>((ref) {
  return AccessBootstrapService(ref.watch(accessRpcClientProvider));
});

final accessBootstrapProvider = FutureProvider<AccessBootstrapData?>((
  ref,
) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) {
    return null;
  }

  return ref.watch(accessBootstrapServiceProvider).fetchBootstrap();
});
