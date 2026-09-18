import 'add_on_models.dart';

class AccessHistoryPage {
  const AccessHistoryPage({
    required this.items,
    required this.summary,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  final List<AccessHistoryEntry> items;
  final AccessHistorySummary summary;
  final int totalCount;
  final int limit;
  final int offset;

  bool get hasMore => items.length + offset < totalCount;

  AccessHistoryPage copyWith({
    List<AccessHistoryEntry>? items,
    AccessHistorySummary? summary,
    int? totalCount,
    int? limit,
    int? offset,
  }) {
    return AccessHistoryPage(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  factory AccessHistoryPage.fromJson(Map<String, dynamic> json) {
    final itemsJson = _readList(json['items']);
    final summaryJson = _readMap(json['summary']);

    return AccessHistoryPage(
      items: itemsJson
          .map((item) => AccessHistoryEntry.fromJson(_readMap(item)))
          .toList(growable: false),
      summary: AccessHistorySummary.fromJson(summaryJson),
      totalCount: _readInt(json['total_count']),
      limit: _readInt(json['limit']),
      offset: _readInt(json['offset']),
    );
  }
}

class AccessHistorySummary {
  const AccessHistorySummary({
    required this.validCount,
    required this.alreadyUsedCount,
    required this.incidentCount,
  });

  final int validCount;
  final int alreadyUsedCount;
  final int incidentCount;

  factory AccessHistorySummary.fromJson(Map<String, dynamic> json) {
    return AccessHistorySummary(
      validCount: _readInt(json['valid_count']),
      alreadyUsedCount: _readInt(json['already_used_count']),
      incidentCount: _readInt(json['incident_count']),
    );
  }

  static const empty = AccessHistorySummary(
    validCount: 0,
    alreadyUsedCount: 0,
    incidentCount: 0,
  );
}

class AccessHistoryEntry {
  const AccessHistoryEntry({
    required this.id,
    required this.createdAt,
    required this.resultCode,
    required this.reasonCode,
    required this.source,
    required this.inputKind,
    required this.actor,
    required this.ticket,
    required this.rawInput,
    required this.normalizedInput,
    this.relatedTicketCode,
    this.extractedScanToken,
  });

  final String id;
  final DateTime createdAt;
  final String resultCode;
  final String reasonCode;
  final String source;
  final String inputKind;
  final AccessHistoryActor actor;
  final AccessHistoryTicketSnapshot? ticket;
  final String? rawInput;
  final String? normalizedInput;
  final String? relatedTicketCode;
  final String? extractedScanToken;

  factory AccessHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AccessHistoryEntry(
      id: _readString(json['id']),
      createdAt: _readDateTime(json['created_at']),
      resultCode: _readString(json['result_code']),
      reasonCode: _readString(json['reason_code']),
      source: _readString(json['source']),
      inputKind: _readString(json['input_kind']),
      actor: AccessHistoryActor.fromJson(_readMap(json['actor'])),
      ticket: _maybeReadMap(json['ticket']) == null
          ? null
          : AccessHistoryTicketSnapshot.fromJson(_readMap(json['ticket'])),
      rawInput: _readNullableString(json['raw_input']),
      normalizedInput: _readNullableString(json['normalized_input']),
    );
  }

  AccessHistoryEntry copyWith({
    String? relatedTicketCode,
    String? extractedScanToken,
  }) {
    return AccessHistoryEntry(
      id: id,
      createdAt: createdAt,
      resultCode: resultCode,
      reasonCode: reasonCode,
      source: source,
      inputKind: inputKind,
      actor: actor,
      ticket: ticket,
      rawInput: rawInput,
      normalizedInput: normalizedInput,
      relatedTicketCode: relatedTicketCode ?? this.relatedTicketCode,
      extractedScanToken: extractedScanToken ?? this.extractedScanToken,
    );
  }
}

class AccessHistoryActor {
  const AccessHistoryActor({
    required this.userId,
    required this.profileId,
    required this.displayName,
    required this.username,
  });

  final String? userId;
  final String? profileId;
  final String? displayName;
  final String? username;

  factory AccessHistoryActor.fromJson(Map<String, dynamic> json) {
    return AccessHistoryActor(
      userId: _readNullableString(json['user_id']),
      profileId: _readNullableString(json['profile_id']),
      displayName: _readNullableString(json['display_name']),
      username: _readNullableString(json['username']),
    );
  }
}

class AccessHistoryTicketSnapshot {
  const AccessHistoryTicketSnapshot({
    required this.id,
    required this.eventId,
    required this.code,
    required this.status,
    required this.canCheckIn,
    required this.ticketType,
    required this.attendee,
    required this.buyer,
    required this.order,
    required this.issuedAt,
    required this.checkedInAt,
    required this.updatedAt,
    this.zoneOffer,
    this.addOns = const [],
    this.validityWindow,
  });

  final AccessTicketZoneOffer? zoneOffer;
  final List<AccessTicketAddOn> addOns;
  final AccessTicketValidityWindow? validityWindow;
  String get ticketTypeLabel =>
      accessTicketTypeLabel(ticketType.name, zoneOffer);

  final String id;
  final String eventId;
  final String code;
  final String status;
  final bool canCheckIn;
  final AccessHistoryTicketType ticketType;
  final AccessHistoryAttendee attendee;
  final AccessHistoryBuyer? buyer;
  final AccessHistoryOrder order;
  final DateTime? issuedAt;
  final DateTime? checkedInAt;
  final DateTime? updatedAt;

  factory AccessHistoryTicketSnapshot.fromJson(Map<String, dynamic> json) {
    return AccessHistoryTicketSnapshot(
      zoneOffer: readAccessTicketZoneOffer(json['zone_offer']),
      addOns: readAccessTicketAddOns(json['add_ons']),
      validityWindow: readAccessTicketValidityWindow(json['validity_window']),
      id: _readString(json['id']),
      eventId: _readString(json['event_id']),
      code: _readString(json['code']),
      status: _readString(json['status']),
      canCheckIn: _readBool(json['can_check_in']),
      ticketType: AccessHistoryTicketType.fromJson(
        _readMap(json['ticket_type']),
      ),
      attendee: AccessHistoryAttendee.fromJson(_readMap(json['attendee'])),
      buyer: _maybeReadMap(json['buyer']) == null
          ? null
          : AccessHistoryBuyer.fromJson(_readMap(json['buyer'])),
      order: AccessHistoryOrder.fromJson(_readMap(json['order'])),
      issuedAt: _readNullableDateTime(json['issued_at']),
      checkedInAt: _readNullableDateTime(json['checked_in_at']),
      updatedAt: _readNullableDateTime(json['updated_at']),
    );
  }
}

class AccessHistoryTicketType {
  const AccessHistoryTicketType({
    required this.id,
    required this.name,
    required this.description,
  });

  final String? id;
  final String? name;
  final String? description;

  factory AccessHistoryTicketType.fromJson(Map<String, dynamic> json) {
    return AccessHistoryTicketType(
      id: _readNullableString(json['id']),
      name: _readNullableString(json['name']),
      description: _readNullableString(json['description']),
    );
  }
}

class AccessHistoryAttendee {
  const AccessHistoryAttendee({
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

  factory AccessHistoryAttendee.fromJson(Map<String, dynamic> json) {
    return AccessHistoryAttendee(
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

class AccessHistoryBuyer {
  const AccessHistoryBuyer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;

  factory AccessHistoryBuyer.fromJson(Map<String, dynamic> json) {
    return AccessHistoryBuyer(
      id: _readNullableString(json['id']),
      fullName: _readNullableString(json['full_name']),
      email: _readNullableString(json['email']),
      phone: _readNullableString(json['phone']),
    );
  }
}

class AccessHistoryOrder {
  const AccessHistoryOrder({
    required this.id,
    required this.status,
    required this.currency,
    required this.paidAt,
  });

  final String? id;
  final String? status;
  final String? currency;
  final DateTime? paidAt;

  factory AccessHistoryOrder.fromJson(Map<String, dynamic> json) {
    return AccessHistoryOrder(
      id: _readNullableString(json['id']),
      status: _readNullableString(json['status']),
      currency: _readNullableString(json['currency']),
      paidAt: _readNullableDateTime(json['paid_at']),
    );
  }
}

class AccessHistoryState {
  const AccessHistoryState({
    required this.items,
    required this.summary,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.isLoadingMore,
  });

  final List<AccessHistoryEntry> items;
  final AccessHistorySummary summary;
  final int totalCount;
  final int limit;
  final int offset;
  final bool isLoadingMore;

  factory AccessHistoryState.empty() {
    return const AccessHistoryState(
      items: <AccessHistoryEntry>[],
      summary: AccessHistorySummary.empty,
      totalCount: 0,
      limit: 0,
      offset: 0,
      isLoadingMore: false,
    );
  }

  factory AccessHistoryState.fromPage(
    AccessHistoryPage page, {
    bool isLoadingMore = false,
  }) {
    return AccessHistoryState(
      items: List<AccessHistoryEntry>.unmodifiable(page.items),
      summary: page.summary,
      totalCount: page.totalCount,
      limit: page.limit,
      offset: page.offset,
      isLoadingMore: isLoadingMore,
    );
  }

  bool get hasMore => items.length < totalCount;

  AccessHistoryState copyWith({
    List<AccessHistoryEntry>? items,
    AccessHistorySummary? summary,
    int? totalCount,
    int? limit,
    int? offset,
    bool? isLoadingMore,
  }) {
    return AccessHistoryState(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  AccessHistoryState appendPage(AccessHistoryPage page) {
    return AccessHistoryState(
      items: List<AccessHistoryEntry>.unmodifiable(<AccessHistoryEntry>[
        ...items,
        ...page.items,
      ]),
      summary: page.summary,
      totalCount: page.totalCount,
      limit: page.limit,
      offset: page.offset,
      isLoadingMore: false,
    );
  }
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _readString(Object? value) {
  return value?.toString() ?? '';
}

String? _readNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  return value?.toString().toLowerCase() == 'true';
}

DateTime _readDateTime(Object? value) {
  final parsed = _readNullableDateTime(value);
  return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

DateTime? _readNullableDateTime(Object? value) {
  final text = _readNullableString(value);
  if (text == null) {
    return null;
  }

  return DateTime.tryParse(text);
}

Map<String, dynamic> _readMap(Object? value) {
  final map = _maybeReadMap(value);
  if (map == null) {
    return <String, dynamic>{};
  }
  return map;
}

Map<String, dynamic>? _maybeReadMap(Object? value) {
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

List<Object?> _readList(Object? value) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  return const <Object?>[];
}
