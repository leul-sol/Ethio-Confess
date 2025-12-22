import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'dart:async';
import 'package:intl/intl.dart';  // Add this import for date formatting
// import 'dart:developer' as developer;
import '../../models/conversation.dart';
import 'chat_detail_screen.dart';
// import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_providers.dart';
import '../../utils/avatar_utils.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    print('[ChatListScreen] currentUserIdProvider: ' + userId.toString());
    final conversations = userId == null
        ? <Conversation>[]
        : ref.watch(conversationListProvider(userId));
    print('[ChatListScreen] conversations: ' + conversations.toString());
    final isLoading = userId == null;
    final hasConversations = conversations.isNotEmpty;

    Future<void> _refreshConversations() async {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        ref.invalidate(conversationListProvider(userId));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _ChatListLoadingWrapper(
        isLoading: isLoading,
        child: RefreshIndicator(
          onRefresh: _refreshConversations,
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : !hasConversations
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ConversationTile(conversation: conversation);
                      },
                    ),
        ),
      ),
    );
  }

  // Removed unused _buildErrorWidget
}

// Wrapper widget to show fallback if loading too long
class _ChatListLoadingWrapper extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  const _ChatListLoadingWrapper({required this.isLoading, required this.child});
  @override
  State<_ChatListLoadingWrapper> createState() => _ChatListLoadingWrapperState();
}

class _ChatListLoadingWrapperState extends State<_ChatListLoadingWrapper> {
  bool showFallback = false;
  @override
  void didUpdateWidget(covariant _ChatListLoadingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && widget.isLoading) {
          setState(() {
            showFallback = true;
          });
        }
      });
    } else if (!widget.isLoading) {
      showFallback = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && showFallback) {
      return const Center(
        child: Text('Still loading... Please check your login or network.'),
      );
    }
    return widget.child;
  }
}

class ConversationTile extends ConsumerWidget {
  final Conversation conversation;

  const ConversationTile({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  String _formatMessageTime(DateTime messageTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(messageTime.year, messageTime.month, messageTime.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      // Today - show time
      return DateFormat('h:mm a').format(messageTime);
    } else if (difference == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference < 7) {
      // Within a week - show day name
      return DateFormat('EEE').format(messageTime);
    } else {
      // More than a week - show date
      return DateFormat('MM/dd/yyyy').format(messageTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Debug print for lastMessage and unreadCount
    print('ConversationTile: ${conversation.participantName}, lastMessage: "${conversation.lastMessage}", unreadCount: ${conversation.unreadCount}');
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color.fromARGB(255, 153, 174, 239),
            width: 2,
          ),
        ),
        child: Builder(
          builder: (context) {
            final ImageProvider? avatarImage = AvatarUtils.getProfileImage(conversation.participantAvatar);
            return CircleAvatar(
              radius: 25,
              backgroundImage: avatarImage,
              backgroundColor: Colors.grey.shade200,
              child: avatarImage == null
                  ? const Icon(
                      Icons.person,
                      size: 25,
                      color: Colors.grey,
                    )
                  : null,
            );
          },
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.participantName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E232C),
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            _formatMessageTime(conversation.lastMessageTime),
            style: TextStyle(
              fontSize: 12,
              color: conversation.isRead ? const Color(0xFF8391A1) : const Color(0xFF1E232C),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: conversation.isRead ? const Color(0xFF8391A1) : const Color(0xFF1E232C),
                fontWeight: conversation.isRead ? FontWeight.normal : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (conversation.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF4169E1),
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversation: conversation,
            ),
          ),
        );
      },
    );
  }
} 