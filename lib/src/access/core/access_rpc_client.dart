import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'access_debug_log.dart';
import 'access_failure.dart';

class AccessRpcClient {
  AccessRpcClient(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> call(
    String functionName, {
    Map<String, dynamic> params = const {},
  }) async {
    accessLog('RPC start: $functionName params=$params', scope: 'rpc');
    try {
      final response = await _client.schema('ticketing').rpc(
        functionName,
        params: params,
      );

      if (response is! Map) {
        throw const AccessFailure(
          kind: AccessFailureKind.contract,
          message: 'El backend devolvió una respuesta inválida.',
        );
      }

      final envelope = Map<String, dynamic>.from(response);
      final ok = envelope['ok'];

      if (ok is! bool) {
        throw const AccessFailure(
          kind: AccessFailureKind.contract,
          message: 'El backend no devolvió un envelope válido.',
        );
      }

      if (!ok) {
        accessLog(
          'RPC business failure: $functionName code=${_readString(envelope['error_code'])} message=${_readString(envelope['message'])}',
          scope: 'rpc',
        );
        throw AccessFailure(
          kind: envelope['error_code'] == 'AUTH_REQUIRED'
              ? AccessFailureKind.auth
              : AccessFailureKind.backend,
          code: _readString(envelope['error_code']),
          message:
              _readString(envelope['message']) ??
              'La operación no pudo completarse.',
        );
      }

      accessLog('RPC success: $functionName', scope: 'rpc');
      return envelope;
    } on AuthException catch (error) {
      accessLog(
        'RPC auth exception: $functionName ${error.message}',
        scope: 'rpc',
        error: error,
        stackTrace: StackTrace.current,
      );
      throw AccessFailure(
        kind: AccessFailureKind.auth,
        code: error.statusCode,
        message: error.message,
        cause: error,
      );
    } on PostgrestException catch (error) {
      accessLog(
        'RPC Postgrest exception: $functionName ${error.message}',
        scope: 'rpc',
        error: error,
        stackTrace: StackTrace.current,
      );
      throw AccessFailure(
        kind: AccessFailureKind.backend,
        code: error.code,
        message: error.message,
        cause: error,
      );
    } on TimeoutException catch (error) {
      accessLog(
        'RPC timeout: $functionName',
        scope: 'rpc',
        error: error,
        stackTrace: StackTrace.current,
      );
      throw AccessFailure(
        kind: AccessFailureKind.network,
        message: 'La conexión con el backend ha expirado.',
        cause: error,
      );
    } on AccessFailure {
      rethrow;
    } catch (error) {
      accessLog(
        'RPC unknown exception: $functionName',
        scope: 'rpc',
        error: error,
        stackTrace: StackTrace.current,
      );
      throw AccessFailure(
        kind: AccessFailureKind.network,
        message: 'No se ha podido conectar con el backend.',
        cause: error,
      );
    }
  }

  String? _readString(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    return null;
  }
}
