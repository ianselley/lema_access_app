import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/access_auth_providers.dart';
import '../bootstrap/access_bootstrap_providers.dart' as bootstrap;
import '../core/access_rpc_exception.dart';
import '../tickets/access_ticket_providers.dart';
import 'access_scan_models.dart';
import 'access_scan_service.dart';

class AccessScanController extends Notifier<AccessScanState> {
  @override
  AccessScanState build() => const AccessScanIdle();

  Future<AccessScanOutcome?> submitScanInput(String rawInput) {
    return _runOperation(
      rawInput: rawInput,
      source: AccessScanSource.scanner,
      label: 'Validando lectura',
      operation: _performScanCheckIn,
    );
  }

  Future<AccessScanOutcome?> previewManualInput(String rawInput) {
    return _runOperation(
      rawInput: rawInput,
      source: AccessScanSource.manualCode,
      label: 'Resolviendo ticket',
      operation: _performPreview,
    );
  }

  Future<AccessScanOutcome?> confirmTicket(String ticketId) {
    return _runOperation(
      rawInput: ticketId,
      source: AccessScanSource.manualDetail,
      label: 'Confirmando acceso',
      operation: _performTicketConfirmation,
    );
  }

  void reset() {
    state = const AccessScanIdle();
  }

  Future<AccessScanOutcome?> _runOperation({
    required String rawInput,
    required AccessScanSource source,
    required String label,
    required Future<AccessScanOutcome> Function({
      required String eventId,
      required String rawInput,
      required AccessScanSource source,
    }) operation,
  }) async {
    final normalizedInput = rawInput.trim();
    if (normalizedInput.isEmpty) {
      state = AccessScanFailure(
        const AccessScanFailureInfo(
          kind: AccessScanFailureKind.contract,
          code: 'INVALID_INPUT',
          message: 'El código de entrada no puede estar vacío.',
        ),
      );
      return null;
    }

    state = AccessScanProcessing(
      source: source,
      rawInput: normalizedInput,
      label: label,
    );

    try {
      final eventId = await _resolveEventId();
      if (eventId == null) {
        state = const AccessScanFailure(
          AccessScanFailureInfo(
            kind: AccessScanFailureKind.backend,
            code: 'EVENT_NOT_SELECTED',
            message: 'No hay un evento activo disponible para esta sesión.',
          ),
        );
        return null;
      }

      final outcome = await operation(
        eventId: eventId,
        rawInput: normalizedInput,
        source: source,
      );

      state = AccessScanSuccess(outcome);
      return outcome;
    } on AccessRpcException catch (error) {
      state = AccessScanFailure(
        AccessScanFailureInfo(
          kind: _failureKindForCode(error.code),
          code: error.code,
          message: error.message,
          details: error.details,
        ),
      );
      return null;
    } catch (error) {
      state = AccessScanFailure(
        AccessScanFailureInfo(
          kind: AccessScanFailureKind.unknown,
          code: 'UNKNOWN_ERROR',
          message: error.toString(),
          details: error,
        ),
      );
      return null;
    }
  }

  Future<AccessScanOutcome> _performScanCheckIn({
    required String eventId,
    required String rawInput,
    required AccessScanSource source,
  }) {
    return AccessScanService(ref.read(accessRpcClientProvider))
        .checkInFromScan(
          eventId: eventId,
          rawInput: rawInput,
          source: source,
        );
  }

  Future<AccessScanOutcome> _performPreview({
    required String eventId,
    required String rawInput,
    required AccessScanSource source,
  }) {
    return AccessScanService(ref.read(accessRpcClientProvider))
        .resolveScanInput(
          eventId: eventId,
          rawInput: rawInput,
          source: source,
        );
  }

  Future<AccessScanOutcome> _performTicketConfirmation({
    required String eventId,
    required String rawInput,
    required AccessScanSource source,
  }) {
    return AccessScanService(ref.read(accessRpcClientProvider)).checkInTicket(
          eventId: eventId,
          ticketId: rawInput,
          source: source,
        );
  }

  Future<String?> _resolveEventId() async {
    final currentEventId = ref.read(accessCurrentEventIdProvider)?.trim();
    if (currentEventId != null && currentEventId.isNotEmpty) {
      return currentEventId;
    }

    final snapshot = await ref.read(bootstrap.accessBootstrapProvider.future);
    if (snapshot == null) {
      return null;
    }

    final suggestedEventId = snapshot.suggestedEventId?.trim();
    if (suggestedEventId != null && suggestedEventId.isNotEmpty) {
      return suggestedEventId;
    }

    final preview =
        snapshot.eventsPreview.isEmpty ? null : snapshot.eventsPreview.first;
    final fallback = preview?.id.trim();
    if (fallback == null || fallback.isEmpty) {
      return null;
    }

    return fallback;
  }

  AccessScanFailureKind _failureKindForCode(String code) {
    switch (code) {
      case 'AUTH_REQUIRED':
      case 'PROFILE_NOT_FOUND':
        return AccessScanFailureKind.auth;
      case 'NETWORK_ERROR':
        return AccessScanFailureKind.network;
      case 'INVALID_RESPONSE':
      case 'INVALID_INPUT':
      case 'INVALID_EVENT_ID':
      case 'INVALID_TICKET_ID':
      case 'INVALID_SOURCE':
      case 'INVALID_INPUT_KIND':
        return AccessScanFailureKind.contract;
      default:
        return AccessScanFailureKind.backend;
    }
  }
}
