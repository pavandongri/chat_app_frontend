/// Minimal public projection of another user — returned by user search and
/// nested inside friend request payloads. Distinct from [User] (the current
/// session's own profile), which carries fields (email, verification) the
/// backend never exposes for other users.
class PublicUser {
  const PublicUser({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarUrl,
    this.friendRequestId,
  });

  final String id;
  final String username;
  final String name;
  final String? avatarUrl;

  /// Id of the pending friend request the current user already sent this
  /// user, if any — only set by `GET /users/search`. `null` means no
  /// outgoing request exists yet.
  final String? friendRequestId;

  factory PublicUser.fromJson(Map<String, dynamic> json) {
    return PublicUser(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      friendRequestId: json['friendRequestId'] as String?,
    );
  }
}
