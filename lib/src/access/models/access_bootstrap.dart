import 'access_profile.dart';

class AccessBootstrapFlags {
  const AccessBootstrapFlags({
    required this.profileExists,
    required this.hasAccessibleEvents,
    required this.hasLiveEvent,
  });

  factory AccessBootstrapFlags.fromJson(Map<String, dynamic> json) {
    return AccessBootstrapFlags(
      profileExists: json['profile_exists'] == true,
      hasAccessibleEvents: json['has_accessible_events'] == true,
      hasLiveEvent: json['has_live_event'] == true,
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
    required this.operationalState,
    this.brandName,
    this.placeName,
    this.startTime,
    this.endTime,
  });

  factory AccessBootstrapEventPreview.fromJson(Map<String, dynamic> json) {
    return AccessBootstrapEventPreview(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brandName: _readString(json['brand_name']),
      placeName: _readString(json['place_name']),
      startTime: _readDateTime(json['start_time']),
      endTime: _readDateTime(json['end_time']),
      operationalState: json['operational_state']?.toString() ?? 'unknown',
    );
  }

  final String id;
  final String name;
  final String? brandName;
  final String? placeName;
  final DateTime? startTime;
  final DateTime? endTime;
  final String operationalState;

  String get title => name;

  static String? _readString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _readDateTime(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}

class AccessBootstrapData {
  const AccessBootstrapData({
    required this.authenticated,
    required this.userId,
    required this.profileExists,
    required this.accessibleEventCount,
    required this.flags,
    required this.eventsPreview,
    this.email,
    this.profile,
    this.suggestedEventId,
  });

  factory AccessBootstrapData.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    final eventsJson = json['events_preview'];
    final flagsJson = json['flags'];

    return AccessBootstrapData(
      authenticated: json['authenticated'] == true,
      userId: json['user_id']?.toString() ?? '',
      email: _readString(json['email']),
      profileExists: json['profile_exists'] == true,
      profile: profileJson is Map
          ? AccessProfile.fromJson(Map<String, dynamic>.from(profileJson))
          : null,
      accessibleEventCount:
          int.tryParse(json['accessible_event_count']?.toString() ?? '') ?? 0,
      suggestedEventId: _readString(json['suggested_event_id']),
      flags: flagsJson is Map
          ? AccessBootstrapFlags.fromJson(Map<String, dynamic>.from(flagsJson))
          : const AccessBootstrapFlags(
              profileExists: false,
              hasAccessibleEvents: false,
              hasLiveEvent: false,
            ),
      eventsPreview: eventsJson is List
          ? eventsJson
                .whereType<Map>()
                .map(
                  (item) => AccessBootstrapEventPreview.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const <AccessBootstrapEventPreview>[],
    );
  }

  final bool authenticated;
  final String userId;
  final String? email;
  final bool profileExists;
  final AccessProfile? profile;
  final int accessibleEventCount;
  final String? suggestedEventId;
  final AccessBootstrapFlags flags;
  final List<AccessBootstrapEventPreview> eventsPreview;

  AccessBootstrapEventPreview? get suggestedEventPreview {
    if (suggestedEventId == null) {
      return eventsPreview.isEmpty ? null : eventsPreview.first;
    }

    for (final event in eventsPreview) {
      if (event.id == suggestedEventId) {
        return event;
      }
    }

    return eventsPreview.isEmpty ? null : eventsPreview.first;
  }

  static String? _readString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class AccessMeData {
  const AccessMeData({
    required this.userId,
    required this.profileExists,
    required this.roles,
    required this.accessibleEventCount,
    this.email,
    this.profile,
  });

  factory AccessMeData.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    final rolesJson = json['roles'];

    return AccessMeData(
      userId: json['user_id']?.toString() ?? '',
      email: _readString(json['email']),
      profileExists: json['profile_exists'] == true,
      profile: profileJson is Map
          ? AccessProfile.fromJson(Map<String, dynamic>.from(profileJson))
          : null,
      roles: rolesJson is List
          ? rolesJson.map((role) => role.toString()).toList(growable: false)
          : const <String>[],
      accessibleEventCount:
          int.tryParse(json['accessible_event_count']?.toString() ?? '') ?? 0,
    );
  }

  final String userId;
  final String? email;
  final bool profileExists;
  final AccessProfile? profile;
  final List<String> roles;
  final int accessibleEventCount;

  String get displayName {
    final profileTitle = profile?.title;
    if (profileTitle != null && profileTitle.isNotEmpty) {
      return profileTitle;
    }

    return email ?? userId;
  }

  String get primaryRole {
    if (roles.isEmpty) {
      return 'Sin rol';
    }

    return roles.first;
  }

  static String? _readString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
