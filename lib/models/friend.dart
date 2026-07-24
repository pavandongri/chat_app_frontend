/// An accepted friend, as returned by `GET /api/friends`. `isOnline` is
/// computed server-side from `last_seen` as of the last fetch — never
/// pushed live (per the manual-refresh-only rule in `coding-standards.md`).
class Friend {
  const Friend({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }
}
