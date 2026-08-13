import 'package:flutter/foundation.dart';

@immutable
class AccessTicketSelection {
  const AccessTicketSelection({
    required this.eventId,
    required this.ticketId,
    required this.query,
    required this.matchReason,
    required this.ticket,
    this.contextLabel,
  });

  final String eventId;
  final String ticketId;
  final String query;
  final TicketSearchMatchReason matchReason;
  final AccessTicketSnapshot ticket;
  final String? contextLabel;

  String get detailContextLabel {
    final value = contextLabel?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return matchReason.label;
  }
}

enum TicketSearchMatchReason {
  ticketId,
  orderId,
  code,
  scanToken,
  attendeePhone,
  buyerPhone,
  attendeeEmail,
  buyerEmail,
  attendeeName,
  buyerName,
  attendeeNameFuzzy,
  buyerNameFuzzy,
  other,
}

extension TicketSearchMatchReasonX on TicketSearchMatchReason {
  static TicketSearchMatchReason fromBackend(String value) {
    switch (value) {
      case 'ticket_id':
        return TicketSearchMatchReason.ticketId;
      case 'order_id':
        return TicketSearchMatchReason.orderId;
      case 'code':
        return TicketSearchMatchReason.code;
      case 'scan_token':
        return TicketSearchMatchReason.scanToken;
      case 'attendee_phone':
        return TicketSearchMatchReason.attendeePhone;
      case 'buyer_phone':
        return TicketSearchMatchReason.buyerPhone;
      case 'attendee_email':
        return TicketSearchMatchReason.attendeeEmail;
      case 'buyer_email':
        return TicketSearchMatchReason.buyerEmail;
      case 'attendee_name':
        return TicketSearchMatchReason.attendeeName;
      case 'buyer_name':
        return TicketSearchMatchReason.buyerName;
      case 'attendee_name_fuzzy':
        return TicketSearchMatchReason.attendeeNameFuzzy;
      case 'buyer_name_fuzzy':
        return TicketSearchMatchReason.buyerNameFuzzy;
      default:
        return TicketSearchMatchReason.other;
    }
  }

  String get backendValue {
    switch (this) {
      case TicketSearchMatchReason.ticketId:
        return 'ticket_id';
      case TicketSearchMatchReason.orderId:
        return 'order_id';
      case TicketSearchMatchReason.code:
        return 'code';
      case TicketSearchMatchReason.scanToken:
        return 'scan_token';
      case TicketSearchMatchReason.attendeePhone:
        return 'attendee_phone';
      case TicketSearchMatchReason.buyerPhone:
        return 'buyer_phone';
      case TicketSearchMatchReason.attendeeEmail:
        return 'attendee_email';
      case TicketSearchMatchReason.buyerEmail:
        return 'buyer_email';
      case TicketSearchMatchReason.attendeeName:
        return 'attendee_name';
      case TicketSearchMatchReason.buyerName:
        return 'buyer_name';
      case TicketSearchMatchReason.attendeeNameFuzzy:
        return 'attendee_name_fuzzy';
      case TicketSearchMatchReason.buyerNameFuzzy:
        return 'buyer_name_fuzzy';
      case TicketSearchMatchReason.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case TicketSearchMatchReason.ticketId:
        return 'ID del ticket';
      case TicketSearchMatchReason.orderId:
        return 'Pedido';
      case TicketSearchMatchReason.code:
        return 'Código';
      case TicketSearchMatchReason.scanToken:
        return 'Token';
      case TicketSearchMatchReason.attendeePhone:
        return 'Teléfono asistente';
      case TicketSearchMatchReason.buyerPhone:
        return 'Teléfono comprador';
      case TicketSearchMatchReason.attendeeEmail:
        return 'Email asistente';
      case TicketSearchMatchReason.buyerEmail:
        return 'Email comprador';
      case TicketSearchMatchReason.attendeeName:
        return 'Nombre asistente';
      case TicketSearchMatchReason.buyerName:
        return 'Nombre comprador';
      case TicketSearchMatchReason.attendeeNameFuzzy:
        return 'Nombre asistente similar';
      case TicketSearchMatchReason.buyerNameFuzzy:
        return 'Nombre comprador similar';
      case TicketSearchMatchReason.other:
        return 'Coincidencia';
    }
  }
}

enum TicketAccessResultCode {
  valid,
  alreadyUsed,
  cancelledOrInvalid,
  notFound,
  wrongEvent,
  forbidden,
  temporaryError,
}

extension TicketAccessResultCodeX on TicketAccessResultCode {
  static TicketAccessResultCode fromBackend(String value) {
    switch (value) {
      case 'valid':
        return TicketAccessResultCode.valid;
      case 'already_used':
        return TicketAccessResultCode.alreadyUsed;
      case 'cancelled_or_invalid':
        return TicketAccessResultCode.cancelledOrInvalid;
      case 'not_found':
        return TicketAccessResultCode.notFound;
      case 'wrong_event':
        return TicketAccessResultCode.wrongEvent;
      case 'forbidden':
        return TicketAccessResultCode.forbidden;
      case 'temporary_error':
        return TicketAccessResultCode.temporaryError;
      default:
        return TicketAccessResultCode.temporaryError;
    }
  }

  String get backendValue {
    switch (this) {
      case TicketAccessResultCode.valid:
        return 'valid';
      case TicketAccessResultCode.alreadyUsed:
        return 'already_used';
      case TicketAccessResultCode.cancelledOrInvalid:
        return 'cancelled_or_invalid';
      case TicketAccessResultCode.notFound:
        return 'not_found';
      case TicketAccessResultCode.wrongEvent:
        return 'wrong_event';
      case TicketAccessResultCode.forbidden:
        return 'forbidden';
      case TicketAccessResultCode.temporaryError:
        return 'temporary_error';
    }
  }

  String get label {
    switch (this) {
      case TicketAccessResultCode.valid:
        return 'Válido';
      case TicketAccessResultCode.alreadyUsed:
        return 'Ya usado';
      case TicketAccessResultCode.cancelledOrInvalid:
        return 'Inválido';
      case TicketAccessResultCode.notFound:
        return 'No encontrado';
      case TicketAccessResultCode.wrongEvent:
        return 'Evento incorrecto';
      case TicketAccessResultCode.forbidden:
        return 'Sin permiso';
      case TicketAccessResultCode.temporaryError:
        return 'Error temporal';
    }
  }
}

class AccessTicketSearchPage {
  const AccessTicketSearchPage({
    required this.items,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  final List<AccessTicketSearchItem> items;
  final int totalCount;
  final int limit;
  final int offset;

  bool get isEmpty => items.isEmpty;
  bool get hasMore => offset + items.length < totalCount;

  factory AccessTicketSearchPage.fromJson(Map<String, dynamic> json) {
    final itemsJson = _readList(json['items']);
    return AccessTicketSearchPage(
      items: itemsJson
          .map((item) => AccessTicketSearchItem.fromJson(_readMap(item)))
          .toList(growable: false),
      totalCount: _readInt(json['total_count']),
      limit: _readInt(json['limit']),
      offset: _readInt(json['offset']),
    );
  }
}

class AccessTicketSearchItem {
  const AccessTicketSearchItem({
    required this.matchReason,
    required this.ticket,
  });

  final TicketSearchMatchReason matchReason;
  final AccessTicketSnapshot ticket;

  factory AccessTicketSearchItem.fromJson(Map<String, dynamic> json) {
    return AccessTicketSearchItem(
      matchReason: TicketSearchMatchReasonX.fromBackend(
        _readString(json['match_reason']),
      ),
      ticket: AccessTicketSnapshot.fromJson(_readMap(json['ticket'])),
    );
  }
}

class AccessTicketDetail {
  const AccessTicketDetail({
    required this.ticket,
    required this.attendee,
    required this.ticketType,
    required this.order,
    required this.canCheckIn,
    required this.validationHistory,
    this.buyer,
    this.lastScanResult,
  });

  final AccessTicketSnapshot ticket;
  final AccessTicketAttendee attendee;
  final AccessTicketType ticketType;
  final AccessTicketOrder order;
  final AccessTicketBuyer? buyer;
  final bool canCheckIn;
  final AccessTicketScanLog? lastScanResult;
  final List<AccessTicketScanLog> validationHistory;

  factory AccessTicketDetail.fromJson(Map<String, dynamic> json) {
    final ticketMap = _readMap(json['ticket']);
    final historyJson = json['validation_history'] is List
        ? _readList(json['validation_history'])
        : const <dynamic>[];

    return AccessTicketDetail(
      ticket: AccessTicketSnapshot.fromJson(ticketMap),
      attendee: AccessTicketAttendee.fromJson(_readMap(json['attendee'])),
      ticketType: AccessTicketType.fromJson(_readMap(json['ticket_type'])),
      order: AccessTicketOrder.fromJson(_readMap(json['order'])),
      buyer: _maybeReadMap(json['buyer']) == null
          ? null
          : AccessTicketBuyer.fromJson(_readMap(json['buyer'])),
      canCheckIn: _readBool(json['can_check_in']),
      lastScanResult: _maybeReadMap(json['last_scan_result']) == null
          ? null
          : AccessTicketScanLog.fromJson(_readMap(json['last_scan_result'])),
      validationHistory: historyJson
          .map((item) => AccessTicketScanLog.fromJson(_readMap(item)))
          .toList(growable: false),
    );
  }
}

class AccessTicketSnapshot {
  const AccessTicketSnapshot({
    required this.id,
    required this.eventId,
    required this.code,
    required this.status,
    required this.canCheckIn,
    required this.ticketType,
    required this.attendee,
    required this.order,
    required this.issuedAt,
    required this.checkedInAt,
    required this.updatedAt,
    this.buyer,
  });

  final String id;
  final String eventId;
  final String code;
  final String status;
  final bool canCheckIn;
  final AccessTicketType ticketType;
  final AccessTicketAttendee attendee;
  final AccessTicketOrder order;
  final AccessTicketBuyer? buyer;
  final DateTime? issuedAt;
  final DateTime? checkedInAt;
  final DateTime? updatedAt;

  factory AccessTicketSnapshot.fromJson(Map<String, dynamic> json) {
    return AccessTicketSnapshot(
      id: _readString(json['id']),
      eventId: _readString(json['event_id']),
      code: _readNullableString(json['code']) ?? '',
      status: _readString(json['status']),
      canCheckIn: _readBool(json['can_check_in']),
      ticketType: AccessTicketType.fromJson(_readMap(json['ticket_type'])),
      attendee: AccessTicketAttendee.fromJson(_readMap(json['attendee'])),
      buyer: _maybeReadMap(json['buyer']) == null
          ? null
          : AccessTicketBuyer.fromJson(_readMap(json['buyer'])),
      order: AccessTicketOrder.fromJson(_readMap(json['order'])),
      issuedAt: _readNullableDateTime(json['issued_at']),
      checkedInAt: _readNullableDateTime(json['checked_in_at']),
      updatedAt: _readNullableDateTime(json['updated_at']),
    );
  }
}

class AccessTicketType {
  const AccessTicketType({
    required this.id,
    required this.name,
    required this.description,
  });

  final String? id;
  final String? name;
  final String? description;

  factory AccessTicketType.fromJson(Map<String, dynamic> json) {
    return AccessTicketType(
      id: _readNullableString(json['id']),
      name: _readNullableString(json['name']),
      description: _readNullableString(json['description']),
    );
  }
}

class AccessTicketAttendee {
  const AccessTicketAttendee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.documentId,
    required this.isOrderBuyer,
  });

  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? documentId;
  final bool isOrderBuyer;

  factory AccessTicketAttendee.fromJson(Map<String, dynamic> json) {
    return AccessTicketAttendee(
      id: _readNullableString(json['id']),
      fullName: _readNullableString(json['full_name']),
      email: _readNullableString(json['email']),
      phone: _readNullableString(json['phone']),
      birthDate: _readNullableDateTime(json['birth_date']),
      documentId: _readNullableString(json['document_id']),
      isOrderBuyer: _readBool(json['is_order_buyer']),
    );
  }
}

class AccessTicketBuyer {
  const AccessTicketBuyer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;

  factory AccessTicketBuyer.fromJson(Map<String, dynamic> json) {
    return AccessTicketBuyer(
      id: _readNullableString(json['id']),
      fullName: _readNullableString(json['full_name']),
      email: _readNullableString(json['email']),
      phone: _readNullableString(json['phone']),
    );
  }
}

class AccessTicketOrder {
  const AccessTicketOrder({
    required this.id,
    required this.status,
    required this.currency,
    required this.paidAt,
  });

  final String? id;
  final String? status;
  final String? currency;
  final DateTime? paidAt;

  factory AccessTicketOrder.fromJson(Map<String, dynamic> json) {
    return AccessTicketOrder(
      id: _readNullableString(json['id']),
      status: _readNullableString(json['status']),
      currency: _readNullableString(json['currency']),
      paidAt: _readNullableDateTime(json['paid_at']),
    );
  }
}

class AccessTicketScanLog {
  const AccessTicketScanLog({
    required this.id,
    required this.createdAt,
    required this.resultCode,
    required this.reasonCode,
    required this.source,
    required this.inputKind,
    required this.actor,
    this.rawInput,
    this.normalizedInput,
  });

  final String? id;
  final DateTime? createdAt;
  final String? resultCode;
  final String? reasonCode;
  final String? source;
  final String? inputKind;
  final AccessTicketActor actor;
  final String? rawInput;
  final String? normalizedInput;

  factory AccessTicketScanLog.fromJson(Map<String, dynamic> json) {
    return AccessTicketScanLog(
      id: _readNullableString(json['id']),
      createdAt: _readNullableDateTime(json['created_at']),
      resultCode: _readNullableString(json['result_code']),
      reasonCode: _readNullableString(json['reason_code']),
      source: _readNullableString(json['source']),
      inputKind: _readNullableString(json['input_kind']),
      actor: AccessTicketActor.fromJson(
        _maybeReadMap(json['actor']) ?? const <String, dynamic>{},
      ),
      rawInput: _readNullableString(json['raw_input']),
      normalizedInput: _readNullableString(json['normalized_input']),
    );
  }

  TicketAccessResultCode get result =>
      TicketAccessResultCodeX.fromBackend(resultCode ?? 'temporary_error');
}

class AccessTicketActor {
  const AccessTicketActor({
    required this.userId,
    required this.profileId,
    required this.displayName,
    required this.username,
  });

  final String? userId;
  final String? profileId;
  final String? displayName;
  final String? username;

  factory AccessTicketActor.fromJson(Map<String, dynamic> json) {
    return AccessTicketActor(
      userId: _readNullableString(json['user_id']),
      profileId: _readNullableString(json['profile_id']),
      displayName: _readNullableString(json['display_name']),
      username: _readNullableString(json['username']),
    );
  }

  String get displayLabel {
    final candidates = <String?>[displayName, username, userId];
    for (final candidate in candidates) {
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }

    return 'Operador';
  }
}

class AccessTicketCheckInOutcome {
  const AccessTicketCheckInOutcome({
    required this.resultCode,
    required this.reasonCode,
    required this.canCheckIn,
    required this.scanLog,
    required this.ticket,
  });

  final TicketAccessResultCode resultCode;
  final String reasonCode;
  final bool canCheckIn;
  final AccessTicketScanLog? scanLog;
  final AccessTicketSnapshot? ticket;

  factory AccessTicketCheckInOutcome.fromJson(Map<String, dynamic> json) {
    final ticketJson = _maybeReadMap(json['ticket']);
    return AccessTicketCheckInOutcome(
      resultCode: TicketAccessResultCodeX.fromBackend(
        _readString(json['result_code']),
      ),
      reasonCode: _readString(json['reason_code']),
      canCheckIn: _readBool(json['can_check_in']),
      scanLog: _maybeReadMap(json['scan_log']) == null
          ? null
          : AccessTicketScanLog.fromJson(_readMap(json['scan_log'])),
      ticket: ticketJson == null
          ? null
          : AccessTicketSnapshot.fromJson(ticketJson),
    );
  }
}

String _readString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    throw const FormatException('Missing required string value.');
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

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _readBool(Object? value) {
  return value == true;
}

DateTime? _readNullableDateTime(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map(
      (key, dynamic nestedValue) => MapEntry(key.toString(), nestedValue),
    );
  }

  throw const FormatException('Missing required map value.');
}

Map<String, dynamic>? _maybeReadMap(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map(
      (key, dynamic nestedValue) => MapEntry(key.toString(), nestedValue),
    );
  }

  return null;
}

List<dynamic> _readList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }

  if (value is List) {
    return value.toList(growable: false);
  }

  throw const FormatException('Missing required list value.');
}
