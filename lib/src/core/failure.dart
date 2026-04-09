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

  @override
  String toString() {
    return 'AccessFailure(kind: $kind, code: $code, message: $message)';
  }
}
