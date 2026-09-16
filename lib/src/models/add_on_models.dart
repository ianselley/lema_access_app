class AccessTicketAddOn {
  const AccessTicketAddOn({
    required this.assignmentId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.refundedQuantity,
    required this.redeemedQuantity,
    required this.pendingRefundQuantity,
    required this.remainingQuantity,
    required this.redemptions,
  });

  factory AccessTicketAddOn.fromJson(Map<String, dynamic> json) {
    return AccessTicketAddOn(
      assignmentId: _readString(json['assignment_id']),
      name: _readString(json['name']),
      description: _readNullableString(json['description']),
      quantity: _readInt(json['quantity']),
      refundedQuantity: _readInt(json['refunded_quantity']),
      redeemedQuantity: _readInt(json['redeemed_quantity']),
      pendingRefundQuantity: _readInt(json['pending_refund_quantity']),
      remainingQuantity: _readInt(json['remaining_quantity']),
      redemptions: _readList(json['active_redemptions'])
          .map((item) => AccessAddOnRedemption.fromJson(_readMap(item)))
          .toList(growable: false),
    );
  }

  final String assignmentId;
  final String name;
  final String? description;
  final int quantity;
  final int refundedQuantity;
  final int redeemedQuantity;
  final int pendingRefundQuantity;
  final int remainingQuantity;
  final List<AccessAddOnRedemption> redemptions;

  String get displayName => name.isEmpty ? 'Extra' : name;
}

class AccessTicketZoneOffer {
  const AccessTicketZoneOffer({
    required this.name,
    required this.serviceStartsAt,
    required this.serviceEndsAt,
  });

  factory AccessTicketZoneOffer.fromJson(Map<String, dynamic> json) {
    return AccessTicketZoneOffer(
      name: _readNullableString(json['zone_name']),
      serviceStartsAt: DateTime.tryParse(
        _readString(json['service_starts_at']),
      ),
      serviceEndsAt: DateTime.tryParse(_readString(json['service_ends_at'])),
    );
  }

  final String? name;
  final DateTime? serviceStartsAt;
  final DateTime? serviceEndsAt;

  String get displayName => name == null ? 'Reservado' : 'Reservado · $name';
}

class AccessTicketValidityWindow {
  const AccessTicketValidityWindow({
    required this.startsAt,
    required this.endsAt,
  });

  factory AccessTicketValidityWindow.fromJson(Map<String, dynamic> json) {
    return AccessTicketValidityWindow(
      startsAt: DateTime.tryParse(_readString(json['starts_at'])),
      endsAt: DateTime.tryParse(_readString(json['ends_at'])),
    );
  }

  final DateTime? startsAt;
  final DateTime? endsAt;
}

class AccessAddOnRedemption {
  const AccessAddOnRedemption({
    required this.id,
    required this.quantity,
    required this.createdAt,
    required this.source,
  });

  factory AccessAddOnRedemption.fromJson(Map<String, dynamic> json) {
    return AccessAddOnRedemption(
      id: _readString(json['id']),
      quantity: _readInt(json['quantity']),
      createdAt: DateTime.tryParse(_readString(json['created_at'])),
      source: _readString(json['source']),
    );
  }

  final String id;
  final int quantity;
  final DateTime? createdAt;
  final String source;
}

List<AccessTicketAddOn> readAccessTicketAddOns(Object? value) {
  return _readList(value)
      .map((item) => AccessTicketAddOn.fromJson(_readMap(item)))
      .toList(growable: false);
}

AccessTicketZoneOffer? readAccessTicketZoneOffer(Object? value) {
  return value is Map
      ? AccessTicketZoneOffer.fromJson(Map<String, dynamic>.from(value))
      : null;
}

AccessTicketValidityWindow? readAccessTicketValidityWindow(Object? value) {
  if (value is! Map) return null;
  final window = AccessTicketValidityWindow.fromJson(
    Map<String, dynamic>.from(value),
  );
  return window.startsAt == null && window.endsAt == null ? null : window;
}

String _readString(Object? value) => value?.toString().trim() ?? '';

String? _readNullableString(Object? value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}

int _readInt(Object? value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

List<dynamic> _readList(Object? value) =>
    value is List ? value.toList(growable: false) : const <dynamic>[];

Map<String, dynamic> _readMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};
