class AccessRpcException implements Exception {
  const AccessRpcException({
    required this.code,
    required this.message,
    this.details,
    this.cause,
  });

  final String code;
  final String message;
  final Object? details;
  final Object? cause;

  @override
  String toString() {
    return 'AccessRpcException(code: $code, message: $message)';
  }
}
