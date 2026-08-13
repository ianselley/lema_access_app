import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/scan_input_normalizer.dart';
import '../models/history_models.dart';
import '../models/ticket_models.dart';
import '../providers/activity_refresh_providers.dart';
import '../providers/history_providers.dart';
import '../providers/ticket_providers.dart';
import '../services/history_service.dart';
import '../services/ticket_service.dart';

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
  AccessTicketService get _ticketService =>
      ref.read(accessTicketServiceProvider);

  @override
  FutureOr<AccessHistoryState> build(String? eventId) async {
    ref.watch(accessActivityRefreshTickProvider);
    _eventId = _normalizedEventId(eventId);

    if (_eventId == null) {
      return AccessHistoryState.empty();
    }

    final page = await _service.fetchEventScanHistory(
      eventId: _eventId!,
      limit: _defaultHistoryPageSize,
      offset: 0,
    );
    return AccessHistoryState.fromPage(
      page.copyWith(items: await _enrichHistoryItems(_eventId!, page.items)),
    );
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
      state = AsyncData(
        currentState.appendPage(
          page.copyWith(items: await _enrichHistoryItems(eventId, page.items)),
        ),
      );
    } catch (_) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<List<AccessHistoryEntry>> _enrichHistoryItems(
    String eventId,
    List<AccessHistoryEntry> items,
  ) async {
    final codesByToken = <String, String?>{};
    final enrichedItems = <AccessHistoryEntry>[];

    for (final item in items) {
      if (item.ticket != null) {
        enrichedItems.add(item);
        continue;
      }

      final token = extractLemaTicketToken(item.rawInput ?? '');
      if (token == null || token.isEmpty) {
        enrichedItems.add(item);
        continue;
      }

      String? relatedCode = codesByToken[token];
      if (!codesByToken.containsKey(token)) {
        relatedCode = await _findCodeForToken(eventId, token);
        codesByToken[token] = relatedCode;
      }

      enrichedItems.add(
        item.copyWith(
          relatedTicketCode: relatedCode,
          extractedScanToken: token,
        ),
      );
    }

    return List<AccessHistoryEntry>.unmodifiable(enrichedItems);
  }

  Future<String?> _findCodeForToken(String eventId, String token) async {
    try {
      final searchPage = await _ticketService.searchEventTickets(
        eventId: eventId,
        query: token,
        checkedIn: true,
        limit: 10,
      );

      for (final item in searchPage.items) {
        if (item.matchReason == TicketSearchMatchReason.scanToken) {
          return item.ticket.code;
        }
      }

      return null;
    } catch (_) {
      return null;
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
