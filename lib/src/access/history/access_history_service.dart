import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/access_auth_providers.dart';
import '../core/access_rpc_client.dart';
import '../core/access_rpc_exception.dart';
import 'access_history_models.dart';

final accessHistoryServiceProvider = Provider<AccessHistoryService>((ref) {
  return AccessHistoryService(ref.watch(accessRpcClientProvider));
});

class AccessHistoryService {
  AccessHistoryService(this._client);

  final AccessRpcClient _client;

  Future<AccessHistoryPage> fetchEventScanHistory({
    required String eventId,
    int limit = 20,
    int offset = 0,
    String? resultCode,
  }) async {
    final response = await _client.call(
      'access_event_scan_history',
      params: <String, dynamic>{
        'p_event_id': eventId,
        'p_limit': limit,
        'p_offset': offset,
        if (resultCode != null && resultCode.isNotEmpty)
          'p_result_code': resultCode,
      },
    );

    if (response['ok'] != true) {
      throw AccessRpcException(
        code: response['error_code']?.toString() ?? 'UNKNOWN_ERROR',
        message: response['message']?.toString() ?? 'Unexpected backend error.',
        details: response,
      );
    }

    final data = response['data'];
    if (data is! Map) {
      throw const AccessRpcException(
        code: 'INVALID_RESPONSE',
        message: 'The history response did not include a data object.',
      );
    }

    return AccessHistoryPage.fromJson(Map<String, dynamic>.from(data));
  }
}
