class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String home = '/home';

  /// Destination screens are placeholders until Stories 6–9 implement them.
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String searchFriends = '/search-friends';
  static const String friendRequests = '/friend-requests';
  static const String friendsList = '/friends-list';
  static const String chatList = '/chats';

  /// Chat Screen itself is Story 11 — this route currently resolves to a
  /// placeholder, reached from Friends List's Chat button.
  static const String chat = '/chat';
}
