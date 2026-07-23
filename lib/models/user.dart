/// Matches the backend's user resource. Signup only returns `id`/
/// `username`/`email`; the rest are populated once Login/Profile endpoints
/// return the full record.
class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.gender,
    this.avatarUrl,
    this.isEmailVerified = false,
  });

  final String id;
  final String username;
  final String email;
  final String? name;
  final String? gender;
  final String? avatarUrl;
  final bool isEmailVerified;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'name': name,
        'gender': gender,
        'avatar_url': avatarUrl,
        'is_email_verified': isEmailVerified,
      };

  User copyWith({bool? isEmailVerified}) => User(
        id: id,
        username: username,
        email: email,
        name: name,
        gender: gender,
        avatarUrl: avatarUrl,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      );
}
