import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'access_history_models.dart';
import 'access_history_service.dart';

const int _defaultHistoryPageSize = 12;

final accessHistoryControllerProvider =
    AsyncNotifierProviderFamily<
      AccessHistoryController,
      AccessHistoryState,
      String?
    >(AccessHistoryController.new);

class AccessHistoryController
    extends FamilyAsyncNotifier<AccessHistoryState, String?> {
  String? _eventId;

  AccessHistoryService get _service => ref.read(accessHistoryServiceProvider);

  @override
  FutureOr<AccessHistoryState> build(String? eventId) async {
    _eventId = _normalizedEventId(eventId);

    if (_eventId == null) {
      return AccessHistoryState.empty();
    }

    final page = await _service.fetchEventScanHistory(
      eventId: _eventId!,
      limit: _defaultHistoryPageSize,
      offset: 0,
    );
    return AccessHistoryState.fromPage(page);
  }

  Future<void> refresh() async {
    if (_eventId == null) {
      return;
    }
    ref.invalidateSelf();
  }

  Future<void> loadMore() async {
    final eventId = _eventId;
    final currentState = state.valueOrNull;

    if (eventId == null || currentState == null) {
      return;
    }

    if (!currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    final nextOffset = currentState.items.length;
    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final page = await _service.fetchEventScanHistory(
        eventId: eventId,
        limit: currentState.limit == 0
            ? _defaultHistoryPageSize
            : currentState.limit,
        offset: nextOffset,
      );
      state = AsyncData(currentState.appendPage(page));
    } catch (_) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  String? _normalizedEventId(String? eventId) {
    final value = eventId?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
