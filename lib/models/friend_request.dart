import 'public_user.dart';

/// A pending friend request, as returned by `GET /api/friends/requests`
/// (split into `incoming`/`outgoing` lists by the backend).
class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.createdAt,
    required this.user,
  });

  final String id;
  final DateTime createdAt;
  final PublicUser user;

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: PublicUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
