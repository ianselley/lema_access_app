import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/access_failure.dart';
import '../core/access_rpc_client.dart';
import '../models/access_models.dart';
import '../services/access_services.dart';

final accessRpcClientProvider = Provider<AccessRpcClient>((ref) {
  return AccessRpcClient(Supabase.instance.client);
});

final accessAuthServiceProvider = Provider<AccessAuthService>((ref) {
  return AccessAuthService(Supabase.instance.client);
});

final accessBootstrapServiceProvider = Provider<AccessBootstrapService>((ref) {
  return AccessBootstrapService(ref.watch(accessRpcClientProvider));
});

final accessProfileServiceProvider = Provider<AccessProfileService>((ref) {
  return AccessProfileService(ref.watch(accessRpcClientProvider));
});

final accessEventsServiceProvider = Provider<AccessEventsService>((ref) {
  return AccessEventsService(ref.watch(accessRpcClientProvider));
});

final accessScanServiceProvider = Provider<AccessScanService>((ref) {
  return AccessScanService(ref.watch(accessRpcClientProvider));
});

final accessTicketSearchServiceProvider = Provider<AccessTicketSearchService>((
  ref,
) {
  return AccessTicketSearchService(ref.watch(accessRpcClientProvider));
});

final accessHistoryServiceProvider = Provider<AccessHistoryService>((ref) {
  return AccessHistoryService(ref.watch(accessRpcClientProvider));
});

final authSessionProvider = StreamProvider<Session?>((ref) {
  return ref.watch(accessAuthServiceProvider).authStateChanges();
});

final selectedEventIdProvider = StateProvider<String?>((ref) => null);

final accessBootstrapProvider = FutureProvider<AccessBootstrap>((ref) async {
  ref.watch(authSessionProvider);
  return ref.watch(accessBootstrapServiceProvider).getBootstrap();
});

final accessMeProvider = FutureProvider<AccessMe>((ref) async {
  ref.watch(authSessionProvider);
  return ref.watch(accessProfileServiceProvider).getMe();
});

final accessEventsProvider = FutureProvider<List<AccessEventSummary>>((ref) {
  ref.watch(authSessionProvider);
  return ref.watch(accessEventsServiceProvider).getEvents();
});

final accessEventHomeProvider =
    FutureProvider.family<AccessEventHome, String>((ref, eventId) {
      ref.watch(authSessionProvider);
      return ref.watch(accessEventsServiceProvider).getEventHome(eventId);
    });

final accessTicketDetailProvider =
    FutureProvider.family<AccessTicketDetail, ({String eventId, String ticketId})>(
      (ref, request) {
        ref.watch(authSessionProvider);
        return ref.watch(accessTicketSearchServiceProvider).getTicketDetail(
          eventId: request.eventId,
          ticketId: request.ticketId,
        );
      },
    );

class AccessAuthActionController extends StateNotifier<AsyncValue<void>> {
  AccessAuthActionController(this._service) : super(const AsyncData(null));

  final AccessAuthService _service;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.signIn(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.signOut);
  }
}

final accessAuthActionProvider =
    StateNotifierProvider<AccessAuthActionController, AsyncValue<void>>((ref) {
      return AccessAuthActionController(ref.watch(accessAuthServiceProvider));
    });

enum AccessActionPhase { idle, processing, success, failure }

class AccessScanActionState {
  const AccessScanActionState({
    required this.phase,
    this.result,
    this.failure,
    this.rawInput,
  });

  const AccessScanActionState.idle()
    : this(phase: AccessActionPhase.idle);

  const AccessScanActionState.processing(String rawInput)
    : this(
        phase: AccessActionPhase.processing,
        rawInput: rawInput,
      );

  const AccessScanActionState.success({
    required AccessScanResult result,
    required String rawInput,
  }) : this(
         phase: AccessActionPhase.success,
         result: result,
         rawInput: rawInput,
       );

  const AccessScanActionState.failure({
    required AccessFailure failure,
    required String rawInput,
  }) : this(
         phase: AccessActionPhase.failure,
         failure: failure,
         rawInput: rawInput,
       );

  final AccessActionPhase phase;
  final AccessScanResult? result;
  final AccessFailure? failure;
  final String? rawInput;
}

class AccessScanActionController extends StateNotifier<AccessScanActionState> {
  AccessScanActionController(this._service)
    : super(const AccessScanActionState.idle());

  final AccessScanService _service;

  Future<void> checkInFromScan({
    required String eventId,
    required String rawInput,
    required String source,
  }) async {
    state = AccessScanActionState.processing(rawInput);
    try {
      final result = await _service.checkInFromScan(
        eventId: eventId,
        rawInput: rawInput,
        source: source,
      );
      state = AccessScanActionState.success(result: result, rawInput: rawInput);
    } on AccessFailure catch (failure) {
      state = AccessScanActionState.failure(
        failure: failure,
        rawInput: rawInput,
      );
    }
  }

  Future<void> checkInTicket({
    required String eventId,
    required String ticketId,
    required String source,
  }) async {
    state = AccessScanActionState.processing(ticketId);
    try {
      final result = await _service.checkInTicket(
        eventId: eventId,
        ticketId: ticketId,
        source: source,
      );
      state = AccessScanActionState.success(result: result, rawInput: ticketId);
    } on AccessFailure catch (failure) {
      state = AccessScanActionState.failure(
        failure: failure,
        rawInput: ticketId,
      );
    }
  }

  void reset() {
    state = const AccessScanActionState.idle();
  }
}

final accessScanActionProvider = StateNotifierProvider.autoDispose
    .family<AccessScanActionController, AccessScanActionState, String>((
      ref,
      eventId,
    ) {
      return AccessScanActionController(ref.watch(accessScanServiceProvider));
    });

class AccessTicketSearchState {
  const AccessTicketSearchState({
    required this.query,
    required this.items,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.loading,
    this.failure,
  });

  const AccessTicketSearchState.initial()
    : this(
        query: '',
        items: const [],
        totalCount: 0,
        limit: 20,
        offset: 0,
        loading: false,
      );

  final String query;
  final List<AccessSearchResultItem> items;
  final int totalCount;
  final int limit;
  final int offset;
  final bool loading;
  final AccessFailure? failure;

  AccessTicketSearchState copyWith({
    String? query,
    List<AccessSearchResultItem>? items,
    int? totalCount,
    int? limit,
    int? offset,
    bool? loading,
    AccessFailure? failure,
    bool clearFailure = false,
  }) {
    return AccessTicketSearchState(
      query: query ?? this.query,
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      loading: loading ?? this.loading,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

class AccessTicketSearchController
    extends StateNotifier<AccessTicketSearchState> {
  AccessTicketSearchController(this._service)
    : super(const AccessTicketSearchState.initial());

  final AccessTicketSearchService _service;

  Future<void> search({
    required String eventId,
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    state = state.copyWith(
      query: query,
      loading: true,
      clearFailure: true,
    );
    try {
      final page = await _service.searchTickets(
        eventId: eventId,
        query: query,
        limit: limit,
        offset: offset,
      );
      state = state.copyWith(
        query: query,
        items: page.items,
        totalCount: page.totalCount,
        limit: page.limit,
        offset: page.offset,
        loading: false,
        clearFailure: true,
      );
    } on AccessFailure catch (failure) {
      state = state.copyWith(loading: false, failure: failure);
    }
  }
}

final accessTicketSearchProvider = StateNotifierProvider.autoDispose
    .family<AccessTicketSearchController, AccessTicketSearchState, String>((
      ref,
      eventId,
    ) {
      return AccessTicketSearchController(
        ref.watch(accessTicketSearchServiceProvider),
      );
    });

class AccessHistoryState {
  const AccessHistoryState({
    required this.items,
    required this.summary,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.loading,
    required this.hasMore,
    this.failure,
  });

  const AccessHistoryState.initial()
    : this(
        items: const [],
        summary: const AccessHistorySummary(
          validCount: 0,
          alreadyUsedCount: 0,
          incidentCount: 0,
        ),
        totalCount: 0,
        limit: 50,
        offset: 0,
        loading: false,
        hasMore: true,
      );

  final List<AccessHistoryItem> items;
  final AccessHistorySummary summary;
  final int totalCount;
  final int limit;
  final int offset;
  final bool loading;
  final bool hasMore;
  final AccessFailure? failure;

  AccessHistoryState copyWith({
    List<AccessHistoryItem>? items,
    AccessHistorySummary? summary,
    int? totalCount,
    int? limit,
    int? offset,
    bool? loading,
    bool? hasMore,
    AccessFailure? failure,
    bool clearFailure = false,
  }) {
    return AccessHistoryState(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      loading: loading ?? this.loading,
      hasMore: hasMore ?? this.hasMore,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

class AccessHistoryController extends StateNotifier<AccessHistoryState> {
  AccessHistoryController(this._service)
    : super(const AccessHistoryState.initial());

  final AccessHistoryService _service;

  Future<void> loadInitial({
    required String eventId,
    String? resultCode,
  }) async {
    state = state.copyWith(loading: true, clearFailure: true);
    try {
      final page = await _service.getHistory(
        eventId: eventId,
        resultCode: resultCode,
      );
      state = state.copyWith(
        items: page.items,
        summary: page.summary,
        totalCount: page.totalCount,
        limit: page.limit,
        offset: page.offset,
        loading: false,
        hasMore: page.items.length + page.offset < page.totalCount,
        clearFailure: true,
      );
    } on AccessFailure catch (failure) {
      state = state.copyWith(loading: false, failure: failure);
    }
  }

  Future<void> loadMore({
    required String eventId,
    String? resultCode,
  }) async {
    if (state.loading || !state.hasMore) {
      return;
    }

    final nextOffset = state.offset + state.items.length;
    state = state.copyWith(loading: true, clearFailure: true);
    try {
      final page = await _service.getHistory(
        eventId: eventId,
        resultCode: resultCode,
        limit: state.limit,
        offset: nextOffset,
      );
      final mergedItems = [...state.items, ...page.items];
      state = state.copyWith(
        items: mergedItems,
        summary: page.summary,
        totalCount: page.totalCount,
        limit: page.limit,
        offset: page.offset,
        loading: false,
        hasMore: mergedItems.length + page.offset < page.totalCount,
        clearFailure: true,
      );
    } on AccessFailure catch (failure) {
      state = state.copyWith(loading: false, failure: failure);
    }
  }
}

final accessHistoryProvider = StateNotifierProvider.autoDispose
    .family<AccessHistoryController, AccessHistoryState, String>((ref, eventId) {
      return AccessHistoryController(ref.watch(accessHistoryServiceProvider));
    });
