import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/rpc_exception.dart';
import '../core/failure.dart';
import '../models/ticket_models.dart';
import '../services/ticket_service.dart';
import 'activity_refresh_providers.dart';
import 'auth_providers.dart';

final accessManualSearchQueryProvider = StateProvider<String>((ref) => '');

final accessTicketServiceProvider = Provider<AccessTicketService>((ref) {
  return AccessTicketService(ref.watch(accessRpcClientProvider));
});

final accessRecentEventTicketsProvider = FutureProvider.autoDispose
    .family<
      ({AccessTicketBrowsePage vip, AccessTicketBrowsePage normal}),
      String
    >((ref, eventId) async {
      ref.watch(accessActivityRefreshTickProvider);
      final service = ref.watch(accessTicketServiceProvider);
      final pages = await Future.wait([
        service.listEventTickets(
          eventId: eventId,
          query: '',
          checkedIn: null,
          vip: true,
          offset: 0,
          limit: 3,
          sortByIssuedAt: true,
        ),
        service.listEventTickets(
          eventId: eventId,
          query: '',
          checkedIn: null,
          vip: false,
          offset: 0,
          limit: 3,
          sortByIssuedAt: true,
        ),
      ]);
      return (vip: pages[0], normal: pages[1]);
    });

final accessSelectedTicketProvider = StateProvider<AccessTicketSelection?>(
  (ref) => null,
);

final accessLatestCheckInOutcomeProvider =
    StateProvider<AccessTicketCheckInOutcome?>((ref) => null);

final accessSelectedTicketDetailProvider =
    FutureProvider.autoDispose<AccessTicketDetail>((ref) async {
      ref.watch(accessActivityRefreshTickProvider);
      final selection = ref.watch(accessSelectedTicketProvider);

      if (selection == null) {
        throw const AccessRpcException(
          code: 'MISSING_TICKET_CONTEXT',
          message: 'A selected ticket is required to load ticket detail.',
        );
      }

      return ref
          .watch(accessTicketServiceProvider)
          .getTicketDetail(
            eventId: selection.eventId,
            ticketId: selection.ticketId,
          );
    });

final accessTicketCheckInControllerProvider =
    NotifierProvider<AccessTicketCheckInController, AccessTicketCheckInState>(
      AccessTicketCheckInController.new,
    );

class AccessTicketCheckInController extends Notifier<AccessTicketCheckInState> {
  AccessTicketService get _service => ref.read(accessTicketServiceProvider);

  @override
  AccessTicketCheckInState build() {
    return const AccessTicketCheckInState.idle();
  }

  void reset() {
    state = const AccessTicketCheckInState.idle();
  }

  Future<void> confirmSelectedTicket() async {
    final selection = ref.read(accessSelectedTicketProvider);
    ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;

    if (selection == null) {
      state = const AccessTicketCheckInState.failure(
        code: 'MISSING_TICKET_CONTEXT',
        message: 'A selected ticket is required to confirm access.',
      );
      return;
    }

    state = const AccessTicketCheckInState.processing();
    try {
      final outcome = await _service.checkInTicket(
        eventId: selection.eventId,
        ticketId: selection.ticketId,
        source: 'manual_detail',
      );
      ref.read(accessLatestCheckInOutcomeProvider.notifier).state = outcome;
      if (outcome.scanLog != null) {
        bumpAccessActivityRefreshTick(ref);
      }
      state = AccessTicketCheckInState.success(outcome);
    } on AccessFailure catch (error) {
      state = AccessTicketCheckInState.failure(
        code: error.code ?? 'UNKNOWN_ERROR',
        message: error.displayMessage,
        details: error,
      );
    } on AccessRpcException catch (error) {
      ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;
      state = AccessTicketCheckInState.failure(
        code: error.code,
        message: error.message,
        details: error.details,
      );
    } catch (error) {
      ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;
      state = AccessTicketCheckInState.failure(
        code: 'UNKNOWN_ERROR',
        message: error.toString(),
        details: error,
      );
    }
  }

  Future<void> undoSelectedTicketCheckIn() async {
    final selection = ref.read(accessSelectedTicketProvider);
    ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;

    if (selection == null) {
      state = const AccessTicketCheckInState.failure(
        code: 'MISSING_TICKET_CONTEXT',
        message: 'A selected ticket is required to undo access.',
      );
      return;
    }

    state = const AccessTicketCheckInState.processing();
    try {
      final outcome = await _service.undoTicketCheckIn(
        eventId: selection.eventId,
        ticketId: selection.ticketId,
      );
      ref.read(accessLatestCheckInOutcomeProvider.notifier).state = outcome;
      if (outcome.scanLog != null) {
        bumpAccessActivityRefreshTick(ref);
      }
      state = AccessTicketCheckInState.success(outcome);
    } on AccessFailure catch (error) {
      state = AccessTicketCheckInState.failure(
        code: error.code ?? 'UNKNOWN_ERROR',
        message: error.displayMessage,
        details: error,
      );
    } on AccessRpcException catch (error) {
      state = AccessTicketCheckInState.failure(
        code: error.code,
        message: error.message,
        details: error.details,
      );
    } catch (error) {
      state = AccessTicketCheckInState.failure(
        code: 'UNKNOWN_ERROR',
        message: error.toString(),
        details: error,
      );
    }
  }
}

@immutable
class AccessTicketCheckInState {
  const AccessTicketCheckInState._({
    required this.status,
    this.outcome,
    this.code,
    this.message,
    this.details,
  });

  const AccessTicketCheckInState.idle()
    : this._(status: AccessActionStatus.idle);

  const AccessTicketCheckInState.processing()
    : this._(status: AccessActionStatus.processing);

  const AccessTicketCheckInState.success(AccessTicketCheckInOutcome outcome)
    : this._(status: AccessActionStatus.success, outcome: outcome);

  const AccessTicketCheckInState.failure({
    required String code,
    required String message,
    Object? details,
  }) : this._(
         status: AccessActionStatus.failure,
         code: code,
         message: message,
         details: details,
       );

  final AccessActionStatus status;
  final AccessTicketCheckInOutcome? outcome;
  final String? code;
  final String? message;
  final Object? details;

  bool get isLoading => status == AccessActionStatus.processing;
  bool get hasOutcome => outcome != null;
}

enum AccessActionStatus { idle, processing, success, failure }
