enum AccessScanSource { scanner, manualCode, manualSearch, manualDetail }

enum AccessScanStage { preview, checkIn }

enum AccessScanUiVariant { valid, used, invalid, notFound, networkError }

enum AccessScanFailureKind { auth, network, backend, contract, unknown }

String accessTicketStatusLabel(String? status) {
  switch (status) {
    case 'issued':
      return 'Emitido';
    case 'checked_in':
      return 'Registrado';
    case 'cancelled':
      return 'Cancelado';
    case 'voided':
      return 'Anulado';
    case null:
    case '':
      return 'Sin estado';
    default:
      return status;
  }
}

String? accessScanReasonLabel(String? reasonCode) {
  switch (reasonCode) {
    case 'EVENT_ACCESS_DENIED':
      return 'Sin acceso al evento';
    case 'TICKET_EVENT_MISMATCH':
      return 'Evento incorrecto';
    case 'TICKET_NOT_FOUND':
      return 'Ticket no encontrado';
    case 'TICKET_STATUS_INVALID':
      return 'Estado no válido';
    case 'ALREADY_CHECKED_IN':
      return 'Ya registrado';
    case 'CHECKED_IN':
      return 'Acceso registrado';
    case 'UNRESOLVED_SCAN_RESULT':
      return 'Resultado no resuelto';
    case null:
    case '':
      return null;
    default:
      return reasonCode;
  }
}

String? accessScanInvalidCategoryLabel(String? category) {
  switch (category) {
    case 'different_brand':
      return 'Otra marca';
    case 'different_day':
      return 'Otro día';
    case 'different_event':
      return 'Otro evento';
    case 'ticket_cancelled':
      return 'Ticket cancelado';
    case 'ticket_voided':
      return 'Ticket anulado';
    case 'ticket_status_invalid':
      return 'Estado no válido';
    case 'ticket_already_used':
      return 'Ya utilizado';
    case 'event_access_denied':
      return 'Sin acceso';
    case null:
    case '':
      return null;
    default:
      return category;
  }
}

AccessScanUiVariant accessScanUiVariantForResultCode(String resultCode) {
  switch (resultCode) {
    case 'valid':
      return AccessScanUiVariant.valid;
    case 'already_used':
      return AccessScanUiVariant.used;
    case 'not_found':
      return AccessScanUiVariant.notFound;
    case 'temporary_error':
      return AccessScanUiVariant.networkError;
    case 'wrong_event':
    case 'cancelled_or_invalid':
    case 'forbidden':
    default:
      return AccessScanUiVariant.invalid;
  }
}

String accessScanHeadlineForResultCode(String resultCode) {
  switch (resultCode) {
    case 'valid':
      return 'Ticket válido';
    case 'already_used':
      return 'Ticket ya utilizado';
    case 'not_found':
      return 'Ticket no encontrado';
    case 'wrong_event':
      return 'Ticket de otro evento';
    case 'cancelled_or_invalid':
      return 'Ticket no válido';
    case 'forbidden':
      return 'Acceso denegado';
    case 'temporary_error':
      return 'Error temporal';
    default:
      return 'Resultado desconocido';
  }
}

String accessScanBodyForResultCode(String resultCode) {
  switch (resultCode) {
    case 'valid':
      return 'El acceso está autorizado y ya quedó registrado en el backend.';
    case 'already_used':
      return 'El backend marcó este ticket como ya validado anteriormente.';
    case 'not_found':
      return 'No existe coincidencia para el código o el ticket solicitado.';
    case 'wrong_event':
      return 'El ticket existe, pero pertenece a otro evento distinto del activo.';
    case 'cancelled_or_invalid':
      return 'El ticket existe, pero su estado no permite el acceso.';
    case 'forbidden':
      return 'La sesión actual no tiene permisos para operar sobre este evento.';
    case 'temporary_error':
      return 'El backend devolvió un error temporal durante la operación.';
    default:
      return 'El backend devolvió un resultado no reconocido.';
  }
}

class AccessTicketSnapshot {
  const AccessTicketSnapshot({
    required this.id,
    required this.eventId,
    required this.ticketTypeName,
    required this.ticketTypeDescription,
    required this.attendeeFullName,
    required this.attendeeEmail,
    required this.attendeePhone,
    required this.orderId,
    required this.orderStatus,
    required this.orderCurrency,
    required this.code,
    required this.status,
    required this.canCheckIn,
    required this.issuedAt,
    required this.checkedInAt,
    required this.updatedAt,
    required this.buyerFullName,
    required this.buyerEmail,
    required this.buyerPhone,
  });

  factory AccessTicketSnapshot.fromJson(Map<String, dynamic> json) {
    final ticketTypeJson = _readMap(json['ticket_type']);
    final attendeeJson = _readMap(json['attendee']);
    final buyerJson = _maybeReadMap(json['buyer']);
    final orderJson = _readMap(json['order']);

    return AccessTicketSnapshot(
      id: _readString(json['id']),
      eventId: _readString(json['event_id']),
      code: _readString(json['code']),
      status: _readString(json['status']),
      canCheckIn: _readBool(json['can_check_in']),
      issuedAt: _readDateTime(json['issued_at']),
      checkedInAt: _readDateTime(json['checked_in_at']),
      updatedAt: _readDateTime(json['updated_at']),
      ticketTypeName: _readString(ticketTypeJson['name']),
      ticketTypeDescription: _readNullableString(ticketTypeJson['description']),
      attendeeFullName: _readNullableString(attendeeJson['full_name']),
      attendeeEmail: _readNullableString(attendeeJson['email']),
      attendeePhone: _readNullableString(attendeeJson['phone']),
      orderId: _readString(orderJson['id']),
      orderStatus: _readString(orderJson['status']),
      orderCurrency: _readNullableString(orderJson['currency']),
      buyerFullName: buyerJson == null
          ? null
          : _readNullableString(buyerJson['full_name']),
      buyerEmail: buyerJson == null
          ? null
          : _readNullableString(buyerJson['email']),
      buyerPhone: buyerJson == null
          ? null
          : _readNullableString(buyerJson['phone']),
    );
  }

  final String id;
  final String eventId;
  final String ticketTypeName;
  final String? ticketTypeDescription;
  final String? attendeeFullName;
  final String? attendeeEmail;
  final String? attendeePhone;
  final String orderId;
  final String orderStatus;
  final String? orderCurrency;
  final String code;
  final String status;
  final bool canCheckIn;
  final DateTime? issuedAt;
  final DateTime? checkedInAt;
  final DateTime? updatedAt;
  final String? buyerFullName;
  final String? buyerEmail;
  final String? buyerPhone;

  String get displayName => attendeeFullName ?? buyerFullName ?? 'Sin nombre';

  String get ticketTypeLabel =>
      ticketTypeName.isEmpty ? 'Sin tipo' : ticketTypeName;

  String? get ticketTypeDescriptionLabel {
    final value = ticketTypeDescription?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  String get orderLabel => '#$orderId';

  String get statusLabel => accessTicketStatusLabel(status);

  static String _readString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return '';
    }
    return text;
  }

  static String? _readNullableString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }
}

class AccessScanEventContext {
  const AccessScanEventContext({
    required this.id,
    required this.name,
    required this.brandName,
    required this.brandUsername,
    required this.startTime,
    required this.endTime,
    required this.placeName,
    required this.placeCity,
    required this.placeTimezone,
    required this.operationalState,
  });

  factory AccessScanEventContext.fromJson(Map<String, dynamic> json) {
    return AccessScanEventContext(
      id: _readString(json['id']),
      name: _readNullableString(json['name']),
      brandName: _readNullableString(json['brand_name']),
      brandUsername: _readNullableString(json['brand_username']),
      startTime: _readDateTime(json['start_time']),
      endTime: _readDateTime(json['end_time']),
      placeName: _readNullableString(json['place_name']),
      placeCity: _readNullableString(json['place_city']),
      placeTimezone: _readNullableString(json['place_timezone']),
      operationalState: _readNullableString(json['operational_state']),
    );
  }

  final String id;
  final String? name;
  final String? brandName;
  final String? brandUsername;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? placeName;
  final String? placeCity;
  final String? placeTimezone;
  final String? operationalState;

  String? get displayName {
    final value = name?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}

class AccessScanInvalidContext {
  const AccessScanInvalidContext({
    required this.category,
    required this.ticketStatus,
    required this.sameBrand,
    required this.sameDay,
    required this.currentEvent,
    required this.ticketEvent,
  });

  factory AccessScanInvalidContext.fromJson(Map<String, dynamic> json) {
    final currentEventJson = _maybeReadMap(json['current_event']);
    final ticketEventJson = _maybeReadMap(json['ticket_event']);

    return AccessScanInvalidContext(
      category: _readNullableString(json['category']),
      ticketStatus: _readNullableString(json['ticket_status']),
      sameBrand: _readNullableBool(json['same_brand']),
      sameDay: _readNullableBool(json['same_day']),
      currentEvent: currentEventJson == null
          ? null
          : AccessScanEventContext.fromJson(currentEventJson),
      ticketEvent: ticketEventJson == null
          ? null
          : AccessScanEventContext.fromJson(ticketEventJson),
    );
  }

  final String? category;
  final String? ticketStatus;
  final bool? sameBrand;
  final bool? sameDay;
  final AccessScanEventContext? currentEvent;
  final AccessScanEventContext? ticketEvent;
}

class AccessScanLogSnapshot {
  const AccessScanLogSnapshot({
    required this.id,
    required this.createdAt,
    required this.resultCode,
    required this.reasonCode,
    required this.source,
  });

  factory AccessScanLogSnapshot.fromJson(Map<String, dynamic> json) {
    return AccessScanLogSnapshot(
      id: _readString(json['id']),
      createdAt: _readDateTime(json['created_at']),
      resultCode: _readString(json['result_code']),
      reasonCode: _readNullableString(json['reason_code']),
      source: _readString(json['source']),
    );
  }

  final String id;
  final DateTime? createdAt;
  final String resultCode;
  final String? reasonCode;
  final String source;
}

class AccessScanOutcome {
  const AccessScanOutcome({
    required this.stage,
    required this.source,
    required this.resultCode,
    required this.reasonCode,
    required this.canCheckIn,
    required this.eventMatch,
    required this.inputKind,
    required this.normalizedInput,
    required this.ticketStatus,
    required this.invalidContext,
    required this.rawInput,
    required this.ticket,
    required this.scanLog,
  });

  factory AccessScanOutcome.fromJson({
    required AccessScanStage stage,
    required AccessScanSource source,
    required String rawInput,
    required Map<String, dynamic> json,
  }) {
    final ticketJson = _maybeReadMap(json['ticket']);
    final scanLogJson = _maybeReadMap(json['scan_log']);
    final invalidContextJson = _maybeReadMap(json['invalid_context']);

    return AccessScanOutcome(
      stage: stage,
      source: source,
      rawInput: rawInput,
      resultCode: _readString(json['result_code']),
      reasonCode: _readNullableString(json['reason_code']),
      canCheckIn: _readBool(json['can_check_in']),
      eventMatch: _readNullableBool(json['event_match']),
      inputKind: _readNullableString(json['input_kind']),
      normalizedInput: _readNullableString(json['normalized_input']),
      ticketStatus: _readNullableString(json['ticket_status']),
      invalidContext: invalidContextJson == null
          ? null
          : AccessScanInvalidContext.fromJson(invalidContextJson),
      ticket: ticketJson == null
          ? null
          : AccessTicketSnapshot.fromJson(ticketJson),
      scanLog: scanLogJson == null
          ? null
          : AccessScanLogSnapshot.fromJson(scanLogJson),
    );
  }

  final AccessScanStage stage;
  final AccessScanSource source;
  final String rawInput;
  final String resultCode;
  final String? reasonCode;
  final bool canCheckIn;
  final bool? eventMatch;
  final String? inputKind;
  final String? normalizedInput;
  final String? ticketStatus;
  final AccessScanInvalidContext? invalidContext;
  final AccessTicketSnapshot? ticket;
  final AccessScanLogSnapshot? scanLog;

  AccessScanUiVariant get uiVariant =>
      accessScanUiVariantForResultCode(resultCode);

  bool get isAccessGranted => resultCode == 'valid';

  String get headline => accessScanHeadlineForResultCode(resultCode);

  String get body => accessScanBodyForResultCode(resultCode);

  String get displayHeadline {
    switch (invalidContext?.category) {
      case 'different_brand':
        return 'Ticket de otra marca';
      case 'different_day':
        return 'Ticket de otro día';
      case 'different_event':
        return 'Ticket de otro evento';
      case 'ticket_cancelled':
        return 'Ticket cancelado';
      case 'ticket_voided':
        return 'Ticket anulado';
      case 'event_access_denied':
        return 'Sin acceso al evento';
      default:
        return headline;
    }
  }

  String get displayBody {
    final ticketEventName = invalidContext?.ticketEvent?.displayName;
    final currentEventName = invalidContext?.currentEvent?.displayName;

    switch (invalidContext?.category) {
      case 'different_brand':
        return _joinScanSentences([
          if (ticketEventName != null)
            'Este ticket corresponde a $ticketEventName.',
          if (currentEventName != null) 'No es válido para $currentEventName.',
          if (ticketEventName == null && currentEventName == null)
            'Este ticket corresponde a otra marca y no es válido para el evento activo.',
        ]);
      case 'different_day':
        return _joinScanSentences([
          if (ticketEventName != null)
            'Este ticket corresponde a $ticketEventName.',
          'No coincide con el día del evento activo.',
        ]);
      case 'different_event':
        return _joinScanSentences([
          if (ticketEventName != null)
            'Este ticket corresponde a $ticketEventName.',
          'No pertenece al evento que estás escaneando ahora.',
        ]);
      case 'ticket_cancelled':
        return 'Este ticket fue cancelado y no permite el acceso.';
      case 'ticket_voided':
        return 'Este ticket fue anulado y no permite el acceso.';
      case 'ticket_status_invalid':
        return 'El estado actual de este ticket no permite el acceso.';
      case 'event_access_denied':
        return 'Esta sesión no puede operar sobre el evento activo.';
      default:
        return body;
    }
  }

  String? get displayReasonLabel {
    return accessScanInvalidCategoryLabel(invalidContext?.category) ??
        accessScanReasonLabel(reasonCode);
  }
}

class AccessScanFailureInfo {
  const AccessScanFailureInfo({
    required this.kind,
    required this.code,
    required this.message,
    this.details,
  });

  final AccessScanFailureKind kind;
  final String code;
  final String message;
  final Object? details;
}

sealed class AccessScanState {
  const AccessScanState();
}

final class AccessScanIdle extends AccessScanState {
  const AccessScanIdle();
}

final class AccessScanProcessing extends AccessScanState {
  const AccessScanProcessing({
    required this.source,
    required this.rawInput,
    required this.label,
  });

  final AccessScanSource source;
  final String rawInput;
  final String label;
}

final class AccessScanSuccess extends AccessScanState {
  const AccessScanSuccess(this.outcome);

  final AccessScanOutcome outcome;
}

final class AccessScanFailure extends AccessScanState {
  const AccessScanFailure(this.failure);

  final AccessScanFailureInfo failure;
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

Map<String, dynamic>? _maybeReadMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

String _readString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return '';
  }
  return text;
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

bool _readBool(Object? value) {
  return value == true;
}

bool? _readNullableBool(Object? value) {
  if (value == null) {
    return null;
  }
  return value == true;
}

DateTime? _readDateTime(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }

  return DateTime.tryParse(text);
}

String _joinScanSentences(List<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' ');
}
