import 'package:flutter/material.dart';

import '../../chat/screens/chat_list_screen.dart';
import '../../friends/screens/friend_requests_screen.dart';
import '../../friends/screens/search_friends_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Post-login landing route: a WhatsApp-style 4-tab bottom navigation
/// shell. Each tab hosts an existing feature screen unchanged — this widget
/// is purely the navigation host (Story 23). Tab content/visual redesign is
/// Stories 24–27.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOut,
  );

  /// Built once and kept alive by [IndexedStack] so switching tabs never
  /// disposes a tab's state (scroll position, in-progress search, etc.) —
  /// only the active one is shown, the rest stay mounted off-screen.
  static const _tabs = [
    ChatListScreen(),
    FriendRequestsScreen(),
    SearchFriendsScreen(),
    ProfileScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Chats',
    ),
    NavigationDestination(
      icon: Icon(Icons.mark_email_unread_outlined),
      selectedIcon: Icon(Icons.mark_email_unread),
      label: 'Requests',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_search_outlined),
      selectedIcon: Icon(Icons.person_search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
    _fadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: IndexedStack(index: _tabIndex, children: _tabs),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _selectTab,
        destinations: _destinations,
      ),
    );
  }
}
