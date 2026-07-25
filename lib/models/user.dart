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
    this.bio,
    this.isEmailVerified = false,
  });

  final String id;
  final String username;
  final String email;
  final String? name;
  final String? gender;
  final String? avatarUrl;

  /// Not yet sent by the backend — UI-ready ahead of that support (Story
  /// 27). Always null until a future story adds the API field.
  final String? bio;
  final bool isEmailVerified;

  /// Note: unlike most of the backend's JSON (`snake_case`), `/api/profile`
  /// returns these two fields as camelCase (`avatarUrl`, `isEmailVerified`) —
  /// match the wire format here, not the general convention.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'name': name,
    'gender': gender,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'isEmailVerified': isEmailVerified,
  };

  User copyWith({bool? isEmailVerified}) => User(
    id: id,
    username: username,
    email: email,
    name: name,
    gender: gender,
    avatarUrl: avatarUrl,
    bio: bio,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
  );
}
