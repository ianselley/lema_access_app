import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/failure.dart';
import '../models/event_models.dart';
import '../services/membership_service.dart';
import 'activity_refresh_providers.dart';
import 'auth_providers.dart';
import 'profile_providers.dart';

final accessMembershipServiceProvider = Provider<AccessMembershipService>((
  ref,
) {
  return AccessMembershipService(ref.watch(accessRpcClientProvider));
});

final accessScannerInviteClaimControllerProvider =
    NotifierProvider<
      AccessScannerInviteClaimController,
      AccessScannerInviteClaimState
    >(AccessScannerInviteClaimController.new);

class AccessScannerInviteClaimController
    extends Notifier<AccessScannerInviteClaimState> {
  AccessMembershipService get _service =>
      ref.read(accessMembershipServiceProvider);

  @override
  AccessScannerInviteClaimState build() {
    return const AccessScannerInviteClaimState.idle();
  }

  void reset() {
    state = const AccessScannerInviteClaimState.idle();
  }

  Future<AccessScannerInviteClaimResult?> claimCode(String rawCode) async {
    final normalizedCode = _normalizeInviteCode(rawCode);
    if (normalizedCode.length != 6) {
      state = const AccessScannerInviteClaimState.failure(
        code: 'INVALID_CODE',
        message: 'Introduce un código válido de 6 caracteres.',
      );
      return null;
    }

    state = const AccessScannerInviteClaimState.processing();
    try {
      final result = await _service.claimScannerInviteCode(normalizedCode);
      bumpAccessActivityRefreshTick(ref);
      ref.invalidate(accessMeProvider);
      state = AccessScannerInviteClaimState.success(result);
      return result;
    } on AccessFailure catch (error) {
      state = AccessScannerInviteClaimState.failure(
        code: error.code ?? 'ACCESS_FAILURE',
        message: _localizedErrorMessage(error),
      );
      return null;
    } catch (error) {
      state = AccessScannerInviteClaimState.failure(
        code: 'UNKNOWN_ERROR',
        message: 'No se pudo aplicar el código. Inténtalo de nuevo.',
      );
      return null;
    }
  }

  String _localizedErrorMessage(AccessFailure error) {
    switch (error.code) {
      case 'PROFILE_NOT_FOUND':
        return 'Completa tu perfil antes de usar un código.';
      case 'INVALID_CODE':
        return 'Introduce un código válido de 6 caracteres.';
      case 'CODE_NOT_FOUND':
        return 'El código no existe o ya no está disponible.';
      case 'CODE_ALREADY_CLAIMED':
        return 'Este código ya fue utilizado.';
      case 'CODE_EXPIRED':
        return 'Este código ha caducado.';
      case 'CODE_UNAVAILABLE':
        return 'Este código ya no está disponible.';
      case 'AUTH_REQUIRED':
        return 'Tu sesión ha caducado. Vuelve a iniciar sesión.';
    }

    switch (error.kind) {
      case AccessFailureKind.network:
        return 'No se pudo conectar con el backend. Revisa tu conexión.';
      case AccessFailureKind.auth:
        return 'Tu sesión no es válida. Vuelve a iniciar sesión.';
      case AccessFailureKind.backend:
        return 'No se pudo aplicar el código.';
      case AccessFailureKind.contract:
        return 'La respuesta del backend no fue válida.';
    }
  }
}

@immutable
class AccessScannerInviteClaimState {
  const AccessScannerInviteClaimState._({
    required this.status,
    this.result,
    this.code,
    this.message,
  });

  const AccessScannerInviteClaimState.idle()
    : this._(status: AccessScannerInviteClaimStatus.idle);

  const AccessScannerInviteClaimState.processing()
    : this._(status: AccessScannerInviteClaimStatus.processing);

  const AccessScannerInviteClaimState.success(
    AccessScannerInviteClaimResult result,
  ) : this._(status: AccessScannerInviteClaimStatus.success, result: result);

  const AccessScannerInviteClaimState.failure({
    required String code,
    required String message,
  }) : this._(
         status: AccessScannerInviteClaimStatus.failure,
         code: code,
         message: message,
       );

  final AccessScannerInviteClaimStatus status;
  final AccessScannerInviteClaimResult? result;
  final String? code;
  final String? message;

  bool get isLoading => status == AccessScannerInviteClaimStatus.processing;
}

enum AccessScannerInviteClaimStatus { idle, processing, success, failure }

String normalizeScannerInviteCode(String rawCode) {
  return _normalizeInviteCode(rawCode);
}

String _normalizeInviteCode(String rawCode) {
  final compact = rawCode.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (compact.length <= 6) {
    return compact;
  }

  return compact.substring(0, 6);
}
