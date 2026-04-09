import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bootstrap_models.dart';
import '../services/profile_service.dart';
import 'auth_providers.dart';

final accessProfileServiceProvider = Provider<AccessProfileService>((ref) {
  return AccessProfileService(ref.watch(accessRpcClientProvider));
});

final accessMeProvider = FutureProvider<AccessMeData?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) {
    return null;
  }

  return ref.watch(accessProfileServiceProvider).fetchMe();
});
