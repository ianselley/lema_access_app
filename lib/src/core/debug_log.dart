import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

void accessLog(
  String message, {
  String scope = 'access',
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) {
    return;
  }

  developer.log(
    message,
    name: 'lema_access.$scope',
    error: error,
    stackTrace: stackTrace,
  );
}
