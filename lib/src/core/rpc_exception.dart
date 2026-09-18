import 'access_labels.dart';

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

  String get displayMessage =>
      accessScanReasonLabel(code) ?? 'No se pudo completar la operación';

  @override
  String toString() {
    return 'AccessRpcException(code: $code, message: $message)';
  }
}
