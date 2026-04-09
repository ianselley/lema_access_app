import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/history_service.dart';
import 'auth_providers.dart';

final accessHistoryServiceProvider = Provider<AccessHistoryService>((ref) {
  return AccessHistoryService(ref.watch(accessRpcClientProvider));
});
