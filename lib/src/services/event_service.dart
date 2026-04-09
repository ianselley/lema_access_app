import '../core/debug_log.dart';
import '../core/rpc_client.dart';
import '../models/event_models.dart';

class AccessEventsService {
  AccessEventsService(this._rpc);

  final AccessRpcClient _rpc;

  Future<List<AccessEventSummary>> getEvents() async {
    final response = await _rpc.call('access_get_events');
    final data = readMap(response['data']);
    final events = readMapList(data['items'])
        .map(AccessEventSummary.fromJson)
        .toList(growable: false);
    accessLog('Events loaded: count=${events.length}', scope: 'events');
    return events;
  }

  Future<AccessEventHome> getEventHome(String eventId) async {
    final response = await _rpc.call(
      'access_get_event_home',
      params: {'p_event_id': eventId},
    );
    final home = AccessEventHome.fromJson(readMap(response['data']));
    accessLog(
      'Event home loaded: eventId=$eventId membershipRole=${home.membershipRole} accessScope=${home.accessScope} operationalState=${home.operationalState}',
      scope: 'events',
    );
    return home;
  }
}
