import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/debug_log.dart';
import '../core/failure.dart';
import '../core/scan_input_normalizer.dart';
import '../core/rpc_exception.dart';
import '../models/scan_models.dart';
import '../providers/activity_refresh_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/bootstrap_providers.dart' as bootstrap;
import '../providers/event_providers.dart';
import '../services/scan_service.dart';

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
    })
    operation,
  }) async {
    final normalizedInput = normalizeAccessScanInput(rawInput);
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

      if (outcome.stage == AccessScanStage.checkIn && outcome.scanLog != null) {
        bumpAccessActivityRefreshTick(ref);
      }

      _logDeniedOrInvalidOutcome(outcome);
      state = AccessScanSuccess(outcome);
      return outcome;
    } on AccessFailure catch (error, stackTrace) {
      _logOperationFailure(
        source: source,
        rawInput: normalizedInput,
        code: error.code ?? 'ACCESS_FAILURE',
        message: error.message,
        details: error.cause,
        error: error,
        stackTrace: stackTrace,
      );
      state = AccessScanFailure(
        AccessScanFailureInfo(
          kind: _scanFailureKindForAccessFailure(error.kind),
          code: error.code ?? 'ACCESS_FAILURE',
          message: error.message,
          details: error.cause,
        ),
      );
      return null;
    } on AccessRpcException catch (error) {
      _logOperationFailure(
        source: source,
        rawInput: normalizedInput,
        code: error.code,
        message: error.message,
        details: error.details,
        error: error,
      );
      state = AccessScanFailure(
        AccessScanFailureInfo(
          kind: _failureKindForCode(error.code),
          code: error.code,
          message: error.message,
          details: error.details,
        ),
      );
      return null;
    } catch (error, stackTrace) {
      _logOperationFailure(
        source: source,
        rawInput: normalizedInput,
        code: 'UNKNOWN_ERROR',
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
      );
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
    return AccessScanService(
      ref.read(accessRpcClientProvider),
    ).checkInFromScan(eventId: eventId, rawInput: rawInput, source: source);
  }

  Future<AccessScanOutcome> _performPreview({
    required String eventId,
    required String rawInput,
    required AccessScanSource source,
  }) {
    return AccessScanService(
      ref.read(accessRpcClientProvider),
    ).resolveScanInput(eventId: eventId, rawInput: rawInput, source: source);
  }

  Future<AccessScanOutcome> _performTicketConfirmation({
    required String eventId,
    required String rawInput,
    required AccessScanSource source,
  }) {
    return AccessScanService(
      ref.read(accessRpcClientProvider),
    ).checkInTicket(eventId: eventId, ticketId: rawInput, source: source);
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

    final preview = snapshot.eventsPreview.isEmpty
        ? null
        : snapshot.eventsPreview.first;
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

  AccessScanFailureKind _scanFailureKindForAccessFailure(
    AccessFailureKind kind,
  ) {
    switch (kind) {
      case AccessFailureKind.network:
        return AccessScanFailureKind.network;
      case AccessFailureKind.auth:
        return AccessScanFailureKind.auth;
      case AccessFailureKind.backend:
        return AccessScanFailureKind.backend;
      case AccessFailureKind.contract:
        return AccessScanFailureKind.contract;
    }
  }

  void _logDeniedOrInvalidOutcome(AccessScanOutcome outcome) {
    if (outcome.uiVariant != AccessScanUiVariant.invalid) {
      return;
    }

    final scanLogInfo = outcome.scanLog == null
        ? 'none'
        : 'id=${outcome.scanLog!.id} result=${outcome.scanLog!.resultCode} '
              'reason=${outcome.scanLog!.reasonCode ?? '-'} '
              'created_at=${outcome.scanLog!.createdAt?.toIso8601String() ?? '-'} '
              'source=${outcome.scanLog!.source}';

    accessLog(
      'Access denied/invalid: '
      'source=${outcome.source.name} '
      'stage=${outcome.stage.name} '
      'result=${outcome.resultCode} '
      'reason=${outcome.reasonCode ?? '-'} '
      'raw_input=${outcome.rawInput} '
      'normalized_input=${outcome.normalizedInput ?? '-'} '
      'ticket_id=${outcome.ticket?.id ?? '-'} '
      'ticket_status=${outcome.ticketStatus ?? outcome.ticket?.status ?? '-'} '
      'event_match=${outcome.eventMatch?.toString() ?? '-'} '
      'supabase_scan_log={$scanLogInfo}',
      scope: 'scan',
    );
  }

  void _logOperationFailure({
    required AccessScanSource source,
    required String rawInput,
    required String code,
    required String message,
    Object? details,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final detailsText = _stringifyForLog(details);
    accessLog(
      'Access operation failed: '
      'source=${source.name} '
      'raw_input=$rawInput '
      'code=$code '
      'message=$message'
      '${detailsText == null ? '' : ' supabase_details=$detailsText'}',
      scope: 'scan',
      error: error,
      stackTrace: stackTrace,
    );
  }

  String? _stringifyForLog(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }
}
