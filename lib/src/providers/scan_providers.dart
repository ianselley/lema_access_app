import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/scan_controller.dart';
import '../models/scan_models.dart';
import '../services/scan_service.dart';
import 'auth_providers.dart';

final accessScanServiceProvider = Provider<AccessScanService>((ref) {
  return AccessScanService(ref.watch(accessRpcClientProvider));
});

final accessScanControllerProvider =
    NotifierProvider<AccessScanController, AccessScanState>(
  AccessScanController.new,
);
