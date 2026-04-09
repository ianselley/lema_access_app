import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bootstrap_models.dart';
import '../services/bootstrap_service.dart';
import 'auth_providers.dart';

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
