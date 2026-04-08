import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/access_auth_providers.dart';
import '../models/access_bootstrap.dart';
import 'access_profile_service.dart';

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
