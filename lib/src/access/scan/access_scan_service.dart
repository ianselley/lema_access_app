import '../core/access_rpc_client.dart';
import '../core/access_rpc_exception.dart';
import 'access_scan_models.dart';

class AccessScanService {
  AccessScanService(this._client);

  final AccessRpcClient _client;

  Future<AccessScanOutcome> resolveScanInput({
    required String eventId,
    required String rawInput,
    required AccessScanSource source,
  }) async {
    final response = await _client.call(
      'access_resolve_scan_input',
      params: <String, dynamic>{
        'p_event_id': eventId,
        'p_raw_input': rawInput,
      },
    );

    return _readOutcome(
      response,
      stage: AccessScanStage.preview,
      source: source,
      rawInput: rawInput,
    );
  }

  Future<AccessScanOutcome> checkInFromScan({
    required String eventId,
    required String rawInput,
    required AccessScanSource source,
  }) async {
    final response = await _client.call(
      'access_check_in_from_scan',
      params: <String, dynamic>{
        'p_event_id': eventId,
        'p_raw_input': rawInput,
        'p_source': _sourceValue(source),
      },
    );

    return _readOutcome(
      response,
      stage: AccessScanStage.checkIn,
      source: source,
      rawInput: rawInput,
    );
  }

  Future<AccessScanOutcome> checkInTicket({
    required String eventId,
    required String ticketId,
    required AccessScanSource source,
  }) async {
    final response = await _client.call(
      'access_check_in_ticket',
      params: <String, dynamic>{
        'p_event_id': eventId,
        'p_ticket_id': ticketId,
        'p_source': _sourceValue(source),
      },
    );

    return _readOutcome(
      response,
      stage: AccessScanStage.checkIn,
      source: source,
      rawInput: ticketId,
    );
  }

  AccessScanOutcome _readOutcome(
    Map<String, dynamic> response, {
    required AccessScanStage stage,
    required AccessScanSource source,
    required String rawInput,
  }) {
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
        message: 'The scan response did not include a data object.',
      );
    }

    return AccessScanOutcome.fromJson(
      stage: stage,
      source: source,
      rawInput: rawInput,
      json: Map<String, dynamic>.from(data),
    );
  }

  String _sourceValue(AccessScanSource source) {
    switch (source) {
      case AccessScanSource.scanner:
        return 'scanner';
      case AccessScanSource.manualCode:
        return 'manual_code';
      case AccessScanSource.manualSearch:
        return 'manual_search';
      case AccessScanSource.manualDetail:
        return 'manual_detail';
    }
  }
}
