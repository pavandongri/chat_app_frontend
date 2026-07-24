class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String home = '/home';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String searchFriends = '/search-friends';
  static const String friendRequests = '/friend-requests';
  static const String friendsList = '/friends-list';
  static const String chatList = '/chats';

  /// Reached from Friends List's Chat button and Chat List rows, both via
  /// `extra: friend`.
  static const String chat = '/chat';
}
