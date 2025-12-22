import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/botttom_navigation_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'biography/biography_display.dart';
import 'chat/chat_list_screen.dart';
import 'guest/guest_screen.dart';
import 'profile/profile_screen.dart';
import 'vent/vent_list_screen.dart';

class MainScreen extends ConsumerWidget {
  final VoidCallback? onLogout;
  const MainScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add auth state check
    final authState = ref.watch(authStateProvider);
    
    // Use the isAuthenticated getter from AuthState
    if (!authState.isAuthenticated) {
      return const GuestScreen();
    }

    final currentIndex = ref.watch(navigationProvider);

    // List of screens corresponding to bottom nav items (Vent first)
    final screens = [
      const VentListScreen(),
      BiographyDisplay(),
      const ChatListScreen(),
      ProfileScreen(onLogout: onLogout),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
        },
      ),
    );
  }
}
