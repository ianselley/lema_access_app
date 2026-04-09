class AccessProfile {
  const AccessProfile({
    required this.id,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.username,
  });

  factory AccessProfile.fromJson(Map<String, dynamic> json) {
    return AccessProfile(
      id: json['id']?.toString() ?? '',
      displayName: _readString(json['display_name']),
      username: _readString(json['username']),
      email: _readString(json['email']),
      createdAt: _readDateTime(json['created_at']),
    );
  }

  final String id;
  final String? displayName;
  final String? username;
  final String? email;
  final DateTime? createdAt;

  String get title {
    final candidates = <String?>[displayName, username, email, id];
    return candidates.firstWhere(
      (value) => value != null && value.isNotEmpty,
    )!;
  }

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
