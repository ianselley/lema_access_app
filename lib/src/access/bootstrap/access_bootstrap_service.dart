import '../core/access_rpc_client.dart';
import '../core/access_rpc_exception.dart';
import '../models/access_bootstrap.dart';

class AccessBootstrapService {
  AccessBootstrapService(this._client);

  final AccessRpcClient _client;

  Future<AccessBootstrapData> fetchBootstrap() async {
    final response = await _client.call('access_get_bootstrap');
    return _readEnvelope(response, AccessBootstrapData.fromJson);
  }

  T _readEnvelope<T>(
    Map<String, dynamic> response,
    T Function(Map<String, dynamic> json) parseData,
  ) {
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
        message: 'The bootstrap response did not include a data object.',
      );
    }

    return parseData(Map<String, dynamic>.from(data));
  }
}
