/// An accepted friend, as returned by `GET /api/friends`. `isOnline` and
/// `lastSeen` are computed/read server-side as of the last fetch — never
/// pushed live (per the manual-refresh-only rule in `coding-standards.md`).
class Friend {
  const Friend({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
    required this.lastSeen,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
    );
  }
}
