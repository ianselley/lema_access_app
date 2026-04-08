import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/access_auth_providers.dart';
import 'access_scan_controller.dart';
import 'access_scan_models.dart';
import 'access_scan_service.dart';

final accessScanServiceProvider = Provider<AccessScanService>((ref) {
  return AccessScanService(ref.watch(accessRpcClientProvider));
});

final accessScanControllerProvider =
    NotifierProvider<AccessScanController, AccessScanState>(
  AccessScanController.new,
);
