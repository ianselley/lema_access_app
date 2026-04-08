import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/access_debug_log.dart';
import '../core/access_rpc_client.dart';
import '../models/access_models.dart';

class AccessAuthService {
  AccessAuthService(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  Stream<Session?> authStateChanges() async* {
    accessLog(
      'Auth session stream opened. currentSession=${_client.auth.currentSession?.user.id}',
      scope: 'auth',
    );
    yield _client.auth.currentSession;
    yield* _client.auth.onAuthStateChange.map((event) {
      accessLog(
        'Auth state changed: event=${event.event} session=${event.session?.user.id}',
        scope: 'auth',
      );
      return event.session;
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    accessLog('Signing in with email=$email', scope: 'auth');
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    accessLog(
      'Sign-in succeeded for email=$email session=${_client.auth.currentSession?.user.id}',
      scope: 'auth',
    );
  }

  Future<void> signOut() async {
    accessLog(
      'Signing out session=${_client.auth.currentSession?.user.id}',
      scope: 'auth',
    );
    await _client.auth.signOut();
    accessLog('Sign-out completed', scope: 'auth');
  }
}

class AccessBootstrapService {
  AccessBootstrapService(this._rpc);

  final AccessRpcClient _rpc;

  Future<AccessBootstrap> getBootstrap() async {
    final response = await _rpc.call('access_get_bootstrap');
    final bootstrap = AccessBootstrap.fromJson(readMap(response['data']));
    accessLog(
      'Bootstrap loaded: authenticated=${bootstrap.authenticated} profileExists=${bootstrap.profileExists} accessibleEventCount=${bootstrap.accessibleEventCount} suggestedEventId=${bootstrap.suggestedEventId}',
      scope: 'bootstrap',
    );
    return bootstrap;
  }
}

class AccessProfileService {
  AccessProfileService(this._rpc);

  final AccessRpcClient _rpc;

  Future<AccessMe> getMe() async {
    final response = await _rpc.call('access_get_me');
    final me = AccessMe.fromJson(readMap(response['data']));
    accessLog(
      'Profile loaded: userId=${me.userId} profileExists=${me.profileExists} accessibleEventCount=${me.accessibleEventCount}',
      scope: 'profile',
    );
    return me;
  }
}

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

class AccessScanService {
  AccessScanService(this._rpc);

  final AccessRpcClient _rpc;

  Future<AccessResolvedScan> resolveScanInput({
    required String eventId,
    required String rawInput,
  }) async {
    final response = await _rpc.call(
      'access_resolve_scan_input',
      params: {
        'p_event_id': eventId,
        'p_raw_input': rawInput,
      },
    );
    return AccessResolvedScan.fromJson(readMap(response['data']));
  }

  Future<AccessScanResult> checkInFromScan({
    required String eventId,
    required String rawInput,
    required String source,
  }) async {
    final response = await _rpc.call(
      'access_check_in_from_scan',
      params: {
        'p_event_id': eventId,
        'p_raw_input': rawInput,
        'p_source': source,
      },
    );
    return AccessScanResult.fromJson(readMap(response['data']));
  }

  Future<AccessScanResult> checkInTicket({
    required String eventId,
    required String ticketId,
    required String source,
  }) async {
    final response = await _rpc.call(
      'access_check_in_ticket',
      params: {
        'p_event_id': eventId,
        'p_ticket_id': ticketId,
        'p_source': source,
      },
    );
    return AccessScanResult.fromJson(readMap(response['data']));
  }
}

class AccessTicketSearchService {
  AccessTicketSearchService(this._rpc);

  final AccessRpcClient _rpc;

  Future<AccessSearchPage> searchTickets({
    required String eventId,
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _rpc.call(
      'access_search_event_tickets',
      params: {
        'p_event_id': eventId,
        'p_query': query,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return AccessSearchPage.fromJson(readMap(response['data']));
  }

  Future<AccessTicketDetail> getTicketDetail({
    required String eventId,
    required String ticketId,
  }) async {
    final response = await _rpc.call(
      'access_get_ticket_detail',
      params: {
        'p_event_id': eventId,
        'p_ticket_id': ticketId,
      },
    );
    return AccessTicketDetail.fromJson(readMap(response['data']));
  }
}

class AccessHistoryService {
  AccessHistoryService(this._rpc);

  final AccessRpcClient _rpc;

  Future<AccessHistoryPage> getHistory({
    required String eventId,
    String? resultCode,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _rpc.call(
      'access_event_scan_history',
      params: {
        'p_event_id': eventId,
        'p_limit': limit,
        'p_offset': offset,
        'p_result_code': resultCode,
      },
    );
    return AccessHistoryPage.fromJson(readMap(response['data']));
  }
}
