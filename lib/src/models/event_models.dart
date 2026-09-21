import 'add_on_models.dart';

class AccessProfile {
  const AccessProfile({
    required this.id,
    required this.displayName,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  factory AccessProfile.fromJson(Map<String, dynamic> json) {
    return AccessProfile(
      id: readString(json['id']),
      displayName: readNullableString(json['display_name']),
      username: readNullableString(json['username']),
      email: readNullableString(json['email']),
      createdAt: readNullableDateTime(json['created_at']),
    );
  }

  final String id;
  final String? displayName;
  final String? username;
  final String? email;
  final DateTime? createdAt;

  String get displayLabel =>
      displayName ?? username ?? email ?? 'Operador sin nombre';
}

class AccessBootstrapFlags {
  const AccessBootstrapFlags({
    required this.profileExists,
    required this.hasAccessibleEvents,
    required this.hasLiveEvent,
  });

  factory AccessBootstrapFlags.fromJson(Map<String, dynamic> json) {
    return AccessBootstrapFlags(
      profileExists: readBool(json['profile_exists']),
      hasAccessibleEvents: readBool(json['has_accessible_events']),
      hasLiveEvent: readBool(json['has_live_event']),
    );
  }

  final bool profileExists;
  final bool hasAccessibleEvents;
  final bool hasLiveEvent;
}

class AccessBootstrapEventPreview {
  const AccessBootstrapEventPreview({
    required this.id,
    required this.name,
    required this.brandName,
    required this.placeName,
    required this.startTime,
    required this.endTime,
    required this.operationalState,
  });

  factory AccessBootstrapEventPreview.fromJson(Map<String, dynamic> json) {
    return AccessBootstrapEventPreview(
      id: readString(json['id']),
      name: readString(json['name']),
      brandName: readNullableString(json['brand_name']),
      placeName: readNullableString(json['place_name']),
      startTime: readNullableDateTime(json['start_time']),
      endTime: readNullableDateTime(json['end_time']),
      operationalState: readString(json['operational_state']),
    );
  }

  final String id;
  final String name;
  final String? brandName;
  final String? placeName;
  final DateTime? startTime;
  final DateTime? endTime;
  final String operationalState;
}

class AccessBootstrap {
  const AccessBootstrap({
    required this.authenticated,
    required this.userId,
    required this.email,
    required this.profileExists,
    required this.profile,
    required this.accessibleEventCount,
    required this.eventsPreview,
    required this.suggestedEventId,
    required this.flags,
  });

  factory AccessBootstrap.fromJson(Map<String, dynamic> json) {
    return AccessBootstrap(
      authenticated: readBool(json['authenticated']),
      userId: readString(json['user_id']),
      email: readNullableString(json['email']),
      profileExists: readBool(json['profile_exists']),
      profile: readNullableMap(json['profile']) == null
          ? null
          : AccessProfile.fromJson(readMap(json['profile'])),
      accessibleEventCount: readInt(json['accessible_event_count']),
      eventsPreview: readMapList(
        json['events_preview'],
      ).map(AccessBootstrapEventPreview.fromJson).toList(growable: false),
      suggestedEventId: readNullableString(json['suggested_event_id']),
      flags: AccessBootstrapFlags.fromJson(readMap(json['flags'])),
    );
  }

  final bool authenticated;
  final String userId;
  final String? email;
  final bool profileExists;
  final AccessProfile? profile;
  final int accessibleEventCount;
  final List<AccessBootstrapEventPreview> eventsPreview;
  final String? suggestedEventId;
  final AccessBootstrapFlags flags;
}

class AccessMe {
  const AccessMe({
    required this.userId,
    required this.email,
    required this.profileExists,
    required this.profile,
    required this.roles,
    required this.accessibleEventCount,
  });

  factory AccessMe.fromJson(Map<String, dynamic> json) {
    return AccessMe(
      userId: readString(json['user_id']),
      email: readNullableString(json['email']),
      profileExists: readBool(json['profile_exists']),
      profile: readNullableMap(json['profile']) == null
          ? null
          : AccessProfile.fromJson(readMap(json['profile'])),
      roles: readStringList(json['roles']),
      accessibleEventCount: readInt(json['accessible_event_count']),
    );
  }

  final String userId;
  final String? email;
  final bool profileExists;
  final AccessProfile? profile;
  final List<String> roles;
  final int accessibleEventCount;
}

class AccessBrand {
  const AccessBrand({
    required this.id,
    required this.name,
    required this.username,
    required this.logoUrl,
  });

  factory AccessBrand.fromJson(Map<String, dynamic> json) {
    return AccessBrand(
      id: readString(json['id']),
      name: readNullableString(json['name']),
      username: readNullableString(json['username']),
      logoUrl: readNullableString(json['logo_url']),
    );
  }

  final String id;
  final String? name;
  final String? username;
  final String? logoUrl;
}

class AccessParty {
  const AccessParty({
    required this.id,
    required this.name,
    required this.poster,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.isArchived,
  });

  factory AccessParty.fromJson(Map<String, dynamic> json) {
    return AccessParty(
      id: readString(json['id']),
      name: readNullableString(json['name']),
      poster: readNullableString(json['poster']),
      description: readNullableString(json['description']),
      startTime: readNullableDateTime(json['start_time']),
      endTime: readNullableDateTime(json['end_time']),
      isArchived: readBool(json['is_archived']),
    );
  }

  final String id;
  final String? name;
  final String? poster;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isArchived;
}

class AccessPlace {
  const AccessPlace({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.timezone,
  });

  factory AccessPlace.fromJson(Map<String, dynamic> json) {
    return AccessPlace(
      id: readNullableString(json['id']),
      name: readNullableString(json['name']),
      city: readNullableString(json['city']),
      address: readNullableString(json['address']),
      timezone: readNullableString(json['timezone']),
    );
  }

  final String? id;
  final String? name;
  final String? city;
  final String? address;
  final String? timezone;
}

class AccessEventRecord {
  const AccessEventRecord({
    required this.id,
    required this.status,
    required this.currency,
    required this.salesStartAt,
    required this.salesEndAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccessEventRecord.fromJson(Map<String, dynamic> json) {
    return AccessEventRecord(
      id: readString(json['id']),
      status: readString(json['status']),
      currency: readNullableString(json['currency']),
      salesStartAt: readNullableDateTime(json['sales_start_at']),
      salesEndAt: readNullableDateTime(json['sales_end_at']),
      createdAt: readNullableDateTime(json['created_at']),
      updatedAt: readNullableDateTime(json['updated_at']),
    );
  }

  final String id;
  final String status;
  final String? currency;
  final DateTime? salesStartAt;
  final DateTime? salesEndAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AccessEventCounters {
  const AccessEventCounters({
    required this.issuedCount,
    required this.checkedInCount,
    required this.pendingCheckInCount,
    required this.cancelledOrVoidedCount,
    required this.capacityTotal,
    required this.ticketTypeCount,
  });

  factory AccessEventCounters.fromJson(Map<String, dynamic> json) {
    return AccessEventCounters(
      issuedCount: readInt(json['issued_count']),
      checkedInCount: readInt(json['checked_in_count']),
      pendingCheckInCount: readInt(json['pending_check_in_count']),
      cancelledOrVoidedCount: readInt(json['cancelled_or_voided_count']),
      capacityTotal: readInt(json['capacity_total']),
      ticketTypeCount: readInt(json['ticket_type_count']),
    );
  }

  final int issuedCount;
  final int checkedInCount;
  final int pendingCheckInCount;
  final int cancelledOrVoidedCount;
  final int capacityTotal;
  final int ticketTypeCount;
}

class AccessEventSummary {
  const AccessEventSummary({
    required this.event,
    required this.membershipRole,
    required this.accessScope,
    required this.operationalState,
    required this.brand,
    required this.party,
    required this.place,
    required this.issuedCount,
    required this.checkedInCount,
    required this.pendingCheckInCount,
    required this.capacityTotal,
    required this.lastActivityAt,
    required this.canViewCurrentOccupancy,
  });

  factory AccessEventSummary.fromJson(Map<String, dynamic> json) {
    return AccessEventSummary(
      event: AccessEventRecord.fromJson(readMap(json['event'])),
      membershipRole: readNullableString(json['membership_role']),
      accessScope: readNullableString(json['access_scope']),
      operationalState: readString(json['operational_state']),
      brand: AccessBrand.fromJson(readMap(json['brand'])),
      party: AccessParty.fromJson(readMap(json['party'])),
      place: AccessPlace.fromJson(readMap(json['place'])),
      issuedCount: readInt(json['issued_count']),
      checkedInCount: readInt(json['checked_in_count']),
      pendingCheckInCount: readInt(json['pending_check_in_count']),
      capacityTotal: readInt(json['capacity_total']),
      lastActivityAt: readNullableDateTime(json['last_activity_at']),
      canViewCurrentOccupancy: readBool(json['can_view_current_occupancy']),
    );
  }

  final AccessEventRecord event;
  final String? membershipRole;
  final String? accessScope;
  final String operationalState;
  final AccessBrand brand;
  final AccessParty party;
  final AccessPlace place;
  final int issuedCount;
  final int checkedInCount;
  final int pendingCheckInCount;
  final int capacityTotal;
  final DateTime? lastActivityAt;
  final bool canViewCurrentOccupancy;
}

class AccessScannerInviteClaimResult {
  const AccessScannerInviteClaimResult({
    required this.scope,
    required this.brandId,
    required this.brandMemberId,
    required this.eventIds,
    required this.eventCount,
    required this.claimedAt,
    required this.expiresAt,
  });

  factory AccessScannerInviteClaimResult.fromJson(Map<String, dynamic> json) {
    return AccessScannerInviteClaimResult(
      scope: readString(json['scope']),
      brandId: readNullableString(json['brand_id']),
      brandMemberId: readNullableString(json['brand_member_id']),
      eventIds: readStringList(json['event_ids']),
      eventCount: _readNullableInt(json['event_count']),
      claimedAt: readNullableDateTime(json['claimed_at']),
      expiresAt: readNullableDateTime(json['expires_at']),
    );
  }

  final String scope;
  final String? brandId;
  final String? brandMemberId;
  final List<String> eventIds;
  final int? eventCount;
  final DateTime? claimedAt;
  final DateTime? expiresAt;

  bool get isBrandMemberClaim => scope == 'brand_member';

  int get resolvedEventCount => eventCount ?? eventIds.length;

  static int? _readNullableInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }
}

class AccessActor {
  const AccessActor({
    required this.userId,
    required this.profileId,
    required this.displayName,
    required this.username,
  });

  factory AccessActor.fromJson(Map<String, dynamic> json) {
    return AccessActor(
      userId: readNullableString(json['user_id']),
      profileId: readNullableString(json['profile_id']),
      displayName: readNullableString(json['display_name']),
      username: readNullableString(json['username']),
    );
  }

  final String? userId;
  final String? profileId;
  final String? displayName;
  final String? username;

  String get label => displayName ?? username ?? 'Operador';
}

class AccessTicketType {
  const AccessTicketType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory AccessTicketType.fromJson(Map<String, dynamic> json) {
    return AccessTicketType(
      id: readString(json['id']),
      name: readNullableString(json['name']),
      description: readNullableString(json['description']),
    );
  }

  final String id;
  final String? name;
  final String? description;
}

class AccessPerson {
  const AccessPerson({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.documentId,
    required this.isOrderBuyer,
  });

  factory AccessPerson.fromJson(Map<String, dynamic> json) {
    return AccessPerson(
      id: readString(json['id']),
      fullName: readNullableString(json['full_name']),
      email: readNullableString(json['email']),
      phone: readNullableString(json['phone']),
      birthDate: readNullableDateTime(json['birth_date']),
      documentId: readNullableString(json['document_id']),
      isOrderBuyer: readNullableBool(json['is_order_buyer']),
    );
  }

  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? documentId;
  final bool? isOrderBuyer;
}

class AccessOrder {
  const AccessOrder({
    required this.id,
    required this.status,
    required this.currency,
    required this.paidAt,
  });

  factory AccessOrder.fromJson(Map<String, dynamic> json) {
    return AccessOrder(
      id: readString(json['id']),
      status: readNullableString(json['status']),
      currency: readNullableString(json['currency']),
      paidAt: readNullableDateTime(json['paid_at']),
    );
  }

  final String id;
  final String? status;
  final String? currency;
  final DateTime? paidAt;
}

class AccessTicketSnapshot {
  const AccessTicketSnapshot({
    required this.id,
    required this.eventId,
    required this.ticketOrderId,
    required this.ticketOrderAttendeeId,
    required this.ticketTypeId,
    required this.code,
    required this.status,
    required this.issuedAt,
    required this.checkedInAt,
    required this.updatedAt,
    this.zoneOffer,
    this.addOns = const [],
    this.validityWindow,
    required this.canCheckIn,
    required this.ticketType,
    required this.attendee,
    required this.buyer,
    required this.order,
  });

  factory AccessTicketSnapshot.fromJson(Map<String, dynamic> json) {
    return AccessTicketSnapshot(
      zoneOffer: readAccessTicketZoneOffer(json['zone_offer']),
      addOns: readAccessTicketAddOns(json['add_ons']),
      validityWindow: readAccessTicketValidityWindow(json['validity_window']),
      id: readString(json['id']),
      eventId: readString(json['event_id']),
      ticketOrderId: readNullableString(json['ticket_order_id']),
      ticketOrderAttendeeId: readNullableString(
        json['ticket_order_attendee_id'],
      ),
      ticketTypeId: readNullableString(json['ticket_type_id']),
      code: readNullableString(json['code']),
      status: readString(json['status']),
      issuedAt: readNullableDateTime(json['issued_at']),
      checkedInAt: readNullableDateTime(json['checked_in_at']),
      updatedAt: readNullableDateTime(json['updated_at']),
      canCheckIn: readBool(json['can_check_in']),
      ticketType: AccessTicketType.fromJson(readMap(json['ticket_type'])),
      attendee: AccessPerson.fromJson(readMap(json['attendee'])),
      buyer: readNullableMap(json['buyer']) == null
          ? null
          : AccessPerson.fromJson(readMap(json['buyer'])),
      order: AccessOrder.fromJson(readMap(json['order'])),
    );
  }

  final AccessTicketZoneOffer? zoneOffer;
  final List<AccessTicketAddOn> addOns;
  final AccessTicketValidityWindow? validityWindow;
  String get ticketTypeLabel =>
      accessTicketTypeLabel(ticketType.name, zoneOffer);

  final String id;
  final String eventId;
  final String? ticketOrderId;
  final String? ticketOrderAttendeeId;
  final String? ticketTypeId;
  final String? code;
  final String status;
  final DateTime? issuedAt;
  final DateTime? checkedInAt;
  final DateTime? updatedAt;
  final bool canCheckIn;
  final AccessTicketType ticketType;
  final AccessPerson attendee;
  final AccessPerson? buyer;
  final AccessOrder order;
}

class AccessScanLog {
  const AccessScanLog({
    required this.id,
    required this.createdAt,
    required this.resultCode,
    required this.reasonCode,
    required this.source,
  });

  factory AccessScanLog.fromJson(Map<String, dynamic> json) {
    return AccessScanLog(
      id: readNullableString(json['id']),
      createdAt: readNullableDateTime(json['created_at']),
      resultCode: readNullableString(json['result_code']),
      reasonCode: readNullableString(json['reason_code']),
      source: readNullableString(json['source']),
    );
  }

  final String? id;
  final DateTime? createdAt;
  final String? resultCode;
  final String? reasonCode;
  final String? source;
}

class AccessResolvedScan {
  const AccessResolvedScan({
    required this.inputKind,
    required this.normalizedInput,
    required this.resultCode,
    required this.eventMatch,
    required this.ticketStatus,
    required this.canCheckIn,
    required this.ticket,
  });

  factory AccessResolvedScan.fromJson(Map<String, dynamic> json) {
    return AccessResolvedScan(
      inputKind: readNullableString(json['input_kind']),
      normalizedInput: readNullableString(json['normalized_input']),
      resultCode: readString(json['result_code']),
      eventMatch: readBool(json['event_match']),
      ticketStatus: readNullableString(json['ticket_status']),
      canCheckIn: readBool(json['can_check_in']),
      ticket: readNullableMap(json['ticket']) == null
          ? null
          : AccessTicketSnapshot.fromJson(readMap(json['ticket'])),
    );
  }

  final String? inputKind;
  final String? normalizedInput;
  final String resultCode;
  final bool eventMatch;
  final String? ticketStatus;
  final bool canCheckIn;
  final AccessTicketSnapshot? ticket;
}

class AccessScanResult {
  const AccessScanResult({
    required this.resultCode,
    required this.reasonCode,
    required this.canCheckIn,
    required this.ticket,
    required this.scanLog,
  });

  factory AccessScanResult.fromJson(Map<String, dynamic> json) {
    return AccessScanResult(
      resultCode: readString(json['result_code']),
      reasonCode: readNullableString(json['reason_code']),
      canCheckIn: readBool(json['can_check_in']),
      ticket: readNullableMap(json['ticket']) == null
          ? null
          : AccessTicketSnapshot.fromJson(readMap(json['ticket'])),
      scanLog: readNullableMap(json['scan_log']) == null
          ? null
          : AccessScanLog.fromJson(readMap(json['scan_log'])),
    );
  }

  final String resultCode;
  final String? reasonCode;
  final bool canCheckIn;
  final AccessTicketSnapshot? ticket;
  final AccessScanLog? scanLog;
}

class AccessSearchResultItem {
  const AccessSearchResultItem({
    required this.matchReason,
    required this.ticket,
  });

  factory AccessSearchResultItem.fromJson(Map<String, dynamic> json) {
    return AccessSearchResultItem(
      matchReason: readNullableString(json['match_reason']),
      ticket: AccessTicketSnapshot.fromJson(readMap(json['ticket'])),
    );
  }

  final String? matchReason;
  final AccessTicketSnapshot ticket;
}

class AccessSearchPage {
  const AccessSearchPage({
    required this.items,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  factory AccessSearchPage.fromJson(Map<String, dynamic> json) {
    return AccessSearchPage(
      items: readMapList(
        json['items'],
      ).map(AccessSearchResultItem.fromJson).toList(growable: false),
      totalCount: readInt(json['total_count']),
      limit: readInt(json['limit']),
      offset: readInt(json['offset']),
    );
  }

  final List<AccessSearchResultItem> items;
  final int totalCount;
  final int limit;
  final int offset;
}

class AccessValidationHistoryItem {
  const AccessValidationHistoryItem({
    required this.id,
    required this.createdAt,
    required this.resultCode,
    required this.reasonCode,
    required this.source,
    required this.inputKind,
    required this.rawInput,
    required this.normalizedInput,
    required this.actor,
  });

  factory AccessValidationHistoryItem.fromJson(Map<String, dynamic> json) {
    return AccessValidationHistoryItem(
      id: readNullableString(json['id']),
      createdAt: readNullableDateTime(json['created_at']),
      resultCode: readNullableString(json['result_code']),
      reasonCode: readNullableString(json['reason_code']),
      source: readNullableString(json['source']),
      inputKind: readNullableString(json['input_kind']),
      rawInput: readNullableString(json['raw_input']),
      normalizedInput: readNullableString(json['normalized_input']),
      actor: AccessActor.fromJson(readMap(json['actor'])),
    );
  }

  final String? id;
  final DateTime? createdAt;
  final String? resultCode;
  final String? reasonCode;
  final String? source;
  final String? inputKind;
  final String? rawInput;
  final String? normalizedInput;
  final AccessActor actor;
}

class AccessTicketDetail {
  const AccessTicketDetail({
    required this.ticket,
    required this.attendee,
    required this.buyer,
    required this.ticketType,
    required this.order,
    required this.canCheckIn,
    required this.lastScanResult,
    required this.validationHistory,
  });

  factory AccessTicketDetail.fromJson(Map<String, dynamic> json) {
    return AccessTicketDetail(
      ticket: AccessTicketSnapshot.fromJson(readMap(json['ticket'])),
      attendee: AccessPerson.fromJson(readMap(json['attendee'])),
      buyer: readNullableMap(json['buyer']) == null
          ? null
          : AccessPerson.fromJson(readMap(json['buyer'])),
      ticketType: AccessTicketType.fromJson(readMap(json['ticket_type'])),
      order: AccessOrder.fromJson(readMap(json['order'])),
      canCheckIn: readBool(json['can_check_in']),
      lastScanResult: readNullableMap(json['last_scan_result']) == null
          ? null
          : AccessScanLog.fromJson(readMap(json['last_scan_result'])),
      validationHistory: readMapList(
        json['validation_history'],
      ).map(AccessValidationHistoryItem.fromJson).toList(growable: false),
    );
  }

  final AccessTicketSnapshot ticket;
  final AccessPerson attendee;
  final AccessPerson? buyer;
  final AccessTicketType ticketType;
  final AccessOrder order;
  final bool canCheckIn;
  final AccessScanLog? lastScanResult;
  final List<AccessValidationHistoryItem> validationHistory;
}

class AccessHistorySummary {
  const AccessHistorySummary({
    required this.validCount,
    required this.alreadyUsedCount,
    required this.incidentCount,
  });

  factory AccessHistorySummary.fromJson(Map<String, dynamic> json) {
    return AccessHistorySummary(
      validCount: readInt(json['valid_count']),
      alreadyUsedCount: readInt(json['already_used_count']),
      incidentCount: readInt(json['incident_count']),
    );
  }

  final int validCount;
  final int alreadyUsedCount;
  final int incidentCount;
}

class AccessHistoryItem {
  const AccessHistoryItem({
    required this.id,
    required this.createdAt,
    required this.resultCode,
    required this.reasonCode,
    required this.source,
    required this.inputKind,
    required this.rawInput,
    required this.normalizedInput,
    required this.ticket,
    required this.actor,
  });

  factory AccessHistoryItem.fromJson(Map<String, dynamic> json) {
    return AccessHistoryItem(
      id: readNullableString(json['id']),
      createdAt: readNullableDateTime(json['created_at']),
      resultCode: readNullableString(json['result_code']),
      reasonCode: readNullableString(json['reason_code']),
      source: readNullableString(json['source']),
      inputKind: readNullableString(json['input_kind']),
      rawInput: readNullableString(json['raw_input']),
      normalizedInput: readNullableString(json['normalized_input']),
      ticket: readNullableMap(json['ticket']) == null
          ? null
          : AccessTicketSnapshot.fromJson(readMap(json['ticket'])),
      actor: AccessActor.fromJson(readMap(json['actor'])),
    );
  }

  final String? id;
  final DateTime? createdAt;
  final String? resultCode;
  final String? reasonCode;
  final String? source;
  final String? inputKind;
  final String? rawInput;
  final String? normalizedInput;
  final AccessTicketSnapshot? ticket;
  final AccessActor actor;
}

class AccessHistoryPage {
  const AccessHistoryPage({
    required this.items,
    required this.totalCount,
    required this.summary,
    required this.limit,
    required this.offset,
  });

  factory AccessHistoryPage.fromJson(Map<String, dynamic> json) {
    return AccessHistoryPage(
      items: readMapList(
        json['items'],
      ).map(AccessHistoryItem.fromJson).toList(growable: false),
      totalCount: readInt(json['total_count']),
      summary: AccessHistorySummary.fromJson(readMap(json['summary'])),
      limit: readInt(json['limit']),
      offset: readInt(json['offset']),
    );
  }

  final List<AccessHistoryItem> items;
  final int totalCount;
  final AccessHistorySummary summary;
  final int limit;
  final int offset;
}

class AccessEventHome {
  const AccessEventHome({
    required this.membershipRole,
    required this.accessScope,
    required this.operationalState,
    required this.event,
    required this.brand,
    required this.party,
    required this.place,
    required this.counters,
    required this.recentHistoryPreview,
    required this.lastActivityAt,
    required this.canViewCurrentOccupancy,
  });

  factory AccessEventHome.fromJson(Map<String, dynamic> json) {
    return AccessEventHome(
      membershipRole: readNullableString(json['membership_role']),
      accessScope: readNullableString(json['access_scope']),
      operationalState: readString(json['operational_state']),
      event: AccessEventRecord.fromJson(readMap(json['event'])),
      brand: AccessBrand.fromJson(readMap(json['brand'])),
      party: AccessParty.fromJson(readMap(json['party'])),
      place: AccessPlace.fromJson(readMap(json['place'])),
      counters: AccessEventCounters.fromJson(readMap(json['counters'])),
      recentHistoryPreview: readMapList(
        json['recent_history_preview'],
      ).map(AccessHistoryItem.fromJson).toList(growable: false),
      lastActivityAt: readNullableDateTime(json['last_activity_at']),
      canViewCurrentOccupancy: false,
    );
  }

  final String? membershipRole;
  final String? accessScope;
  final String operationalState;
  final AccessEventRecord event;
  final AccessBrand brand;
  final AccessParty party;
  final AccessPlace place;
  final AccessEventCounters counters;
  final List<AccessHistoryItem> recentHistoryPreview;
  final DateTime? lastActivityAt;
  final bool canViewCurrentOccupancy;

  AccessEventHome copyWith({required bool canViewCurrentOccupancy}) {
    return AccessEventHome(
      membershipRole: membershipRole,
      accessScope: accessScope,
      operationalState: operationalState,
      event: event,
      brand: brand,
      party: party,
      place: place,
      counters: counters,
      recentHistoryPreview: recentHistoryPreview,
      lastActivityAt: lastActivityAt,
      canViewCurrentOccupancy: canViewCurrentOccupancy,
    );
  }
}

Map<String, dynamic> readMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw const FormatException('Expected JSON object.');
}

Map<String, dynamic>? readNullableMap(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

List<Map<String, dynamic>> readMapList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  return const [];
}

List<String> readStringList(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList(growable: false);
  }

  return const [];
}

String readString(dynamic value) {
  final string = readNullableString(value);
  if (string == null) {
    throw const FormatException('Expected string value.');
  }

  return string;
}

String? readNullableString(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }

  return null;
}

bool readBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  return false;
}

bool? readNullableBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  return null;
}

int readInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return 0;
}

DateTime? readNullableDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }

  return null;
}
