import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_settings_provider.dart';
import 'dart:developer' as developer;
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../providers/service_providers.dart' as service;
import '../../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool? _cachedAllowChat;
  bool _isAllowChatLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedAllowChat();
    _checkUserChatSettings();
    _loadNotificationPreference();
  }

  Future<void> _loadCachedAllowChat() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool('allow_chat');
    setState(() {
      _cachedAllowChat = cached;
      _isAllowChatLoading = false;
    });
  }

  Future<void> _cacheAllowChat(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allow_chat', value);
    setState(() {
      _cachedAllowChat = value;
    });
  }

  Future<void> _checkUserChatSettings() async {
    try {
      final client = await ref.read(service.graphQLClientProvider);
      if (client == null) return;

      final userId = ref.read(userIdProvider);
      if (userId == null) return;

      final result = await client.query(
        QueryOptions(
          document: gql('''
            query GetUserChatSettings(\$userId: uuid!) {
              users_by_pk(id: \$userId) {
                id
                username
                allow_chat
              }
            }
          '''),
          variables: {
            'userId': userId,
          },
        ),
      );

      if (result.hasException) {
        developer.log('Error fetching user chat settings: ${result.exception}');
        return;
      }

      final userData = result.data?['users_by_pk'];
      if (userData != null) {
        final allowChat = userData['allow_chat'] ?? true;
        await _cacheAllowChat(allowChat);
        developer.log('User chat settings:');
        developer.log('User ID: ${userData['id']}');
        developer.log('Username: ${userData['username']}');
        developer.log('Allow Chat: $allowChat');
      }
    } catch (e) {
      developer.log('Error checking user chat settings: $e');
    }
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled');
    setState(() {
      _notificationsEnabled = enabled ?? true;
    });
    // Ensure OneSignal state matches stored preference
    if (_notificationsEnabled) {
      await OneSignal.User.pushSubscription.optIn();
    } else {
      await OneSignal.User.pushSubscription.optOut();
    }
  }

  Future<void> _setNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
    if (value) {
      await OneSignal.User.pushSubscription.optIn();
    } else {
      await OneSignal.User.pushSubscription.optOut();
    }
  }

  Future<void> _onChatToggleChanged(bool value) async {
    setState(() {
      _cachedAllowChat = value;
    });
    try {
      await ref.read(chatSettingsProvider.notifier).updateChatSettings(value);
      await _cacheAllowChat(value);
      developer.log('allow_chat updated to: $value');
      _checkUserChatSettings();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Chat enabled successfully' : 'Chat disabled successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert the toggle to previous state
      setState(() {
        _cachedAllowChat = !value;
      });
      
      if (mounted) {
        // Show user-friendly error message
        String errorMessage = 'Failed to update chat settings.';
        if (e.toString().contains('No internet connection')) {
          errorMessage = 'No internet connection. Please check your network and try again.';
        } else if (e.toString().contains('Server error')) {
          errorMessage = 'Server error. Please try again later.';
        } else if (e.toString().contains('Please sign in')) {
          errorMessage = 'Please sign in to update your chat settings.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry the operation
                _onChatToggleChanged(value);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowChat = ref.watch(chatSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF1E232C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E232C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsSection(
            context,
            title: 'Account',
            items: [
              ListTile(
                leading: const Icon(
                  Icons.chat_outlined,
                  color: Color(0xFF4169E1),
                ),
                title: const Text(
                  'Enable Chat',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E232C),
                  ),
                ),
                subtitle: Text(
                  (_cachedAllowChat ?? true)
                      ? 'Others can chat with you'
                      : 'Chat is disabled',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: _isAllowChatLoading
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : Switch(
                        value: _cachedAllowChat ?? true,
                        onChanged: (bool value) async {
                          await _onChatToggleChanged(value);
                        },
                        activeColor: const Color(0xFF4169E1),
                      ),
              ),
              // Notification toggle
              ListTile(
                leading: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF4169E1),
                ),
                title: const Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E232C),
                  ),
                ),
                subtitle: Text(
                  _notificationsEnabled ? 'Notifications are ON' : 'Notifications are OFF',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (bool value) async {
                    await _setNotificationPreference(value);
                  },
                  activeColor: const Color(0xFF4169E1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E232C),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
} 