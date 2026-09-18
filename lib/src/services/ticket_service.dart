import '../core/rpc_client.dart';
import '../core/rpc_exception.dart';
import '../models/ticket_models.dart';

class AccessTicketService {
  AccessTicketService(this._client);

  final AccessRpcClient _client;

  Future<AccessTicketSearchPage> searchEventTickets({
    required String eventId,
    required String query,
    required bool checkedIn,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.call(
      'access_search_event_tickets',
      params: <String, dynamic>{
        'p_event_id': eventId,
        'p_query': query,
        'p_checked_in': checkedIn,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return _readEnvelope(response, AccessTicketSearchPage.fromJson);
  }

  Future<AccessTicketDetail> getTicketDetail({
    required String eventId,
    required String ticketId,
  }) async {
    final response = await _client.call(
      'access_get_ticket_detail',
      params: <String, dynamic>{'p_event_id': eventId, 'p_ticket_id': ticketId},
    );
    return _readEnvelope(response, AccessTicketDetail.fromJson);
  }

  Future<AccessTicketCheckInOutcome> checkInTicket({
    required String eventId,
    required String ticketId,
    String source = 'manual_detail',
  }) async {
    final response = await _client.call(
      'access_check_in_ticket',
      params: <String, dynamic>{
        'p_event_id': eventId,
        'p_ticket_id': ticketId,
        'p_source': source,
      },
    );
    return _readEnvelope(response, AccessTicketCheckInOutcome.fromJson);
  }

  Future<AccessTicketCheckInOutcome> undoTicketCheckIn({
    required String eventId,
    required String ticketId,
  }) async {
    final response = await _client.call(
      'access_undo_ticket_check_in',
      params: <String, dynamic>{'p_event_id': eventId, 'p_ticket_id': ticketId},
    );
    return _readEnvelope(response, AccessTicketCheckInOutcome.fromJson);
  }

  Future<AccessTicketSnapshot> editAddOns({
    required String eventId,
    required String ticketId,
    required List<String> undoRedemptionIds,
    required List<Map<String, dynamic>> redemptions,
    required Map<String, int> expectedQuantities,
  }) async {
    final response = await _client.call(
      'access_edit_ticket_add_ons',
      params: {
        'p_event_id': eventId,
        'p_ticket_id': ticketId,
        'p_undo_redemption_ids': undoRedemptionIds,
        'p_redemptions': redemptions,
        'p_expected_quantities': expectedQuantities,
      },
    );
    return _readEnvelope(
      response,
      (data) => AccessTicketSnapshot.fromJson(
        Map<String, dynamic>.from(data['ticket'] as Map),
      ),
    );
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
        message: 'The ticket RPC did not include a data object.',
      );
    }

    return parseData(Map<String, dynamic>.from(data));
  }
}
