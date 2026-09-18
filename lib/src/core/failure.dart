import 'access_labels.dart';

enum AccessFailureKind { network, auth, backend, contract }

class AccessFailure implements Exception {
  const AccessFailure({
    required this.kind,
    required this.message,
    this.code,
    this.cause,
  });

  final AccessFailureKind kind;
  final String message;
  final String? code;
  final Object? cause;

  bool get isAuthRelated =>
      kind == AccessFailureKind.auth || code == 'AUTH_REQUIRED';

  String get displayMessage {
    if (kind == AccessFailureKind.network) {
      return 'No se ha podido conectar. Inténtalo de nuevo';
    }
    if (kind == AccessFailureKind.auth) return 'Inicia sesión de nuevo';
    return accessScanReasonLabel(code) ?? 'No se pudo completar la operación';
  }

  @override
  String toString() {
    return 'AccessFailure(kind: $kind, code: $code, message: $message)';
  }
}
