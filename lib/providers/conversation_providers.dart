import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import 'auth_provider.dart';
import 'dart:async';

// StreamProvider for real-time chat updates
final conversationStreamProvider = StreamProvider<List<Conversation>>((ref) async* {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) {
    yield [];
    return;
  }
  final chatService = ref.read(chatServiceProvider(currentUserId));
  await for (final chats in chatService.getChats()) {
    final conversationList = chats.map<Conversation>((chat) {
      try {
        final isUser1 = chat['user1'] == currentUserId;
        final otherUser = isUser1 ? chat['userByUser2'] : chat['user'];
        final otherUserId = isUser1 ? chat['user2'] : chat['user1'];
        final username = otherUser?['username'] ?? 'Unknown User';
        final profileImage = otherUser?['profile_image'];
        final unreadMessages = List<Map<String, dynamic>>.from(chat['messages_unread'] ?? []);
        print('Unread messages for chat ${chat['id']}: ${unreadMessages.length}');
        final latestMessages = List<Map<String, dynamic>>.from(chat['messages_latest'] ?? []);
        final lastMessage = latestMessages.isNotEmpty ? latestMessages.first : null;
        final DateTime timeForSorting = lastMessage != null
            ? DateTime.parse(lastMessage['created_at']).toLocal()
            : DateTime.parse(chat['created_at']).toLocal();
        final unreadCount = unreadMessages.length;
        return Conversation(
          id: chat['id'] ?? '',
          participantId: otherUserId ?? '',
          participantName: username,
          participantAvatar: profileImage,
          lastMessage: lastMessage?['message'] ?? '',
          lastMessageTime: timeForSorting,
          isRead: lastMessage?['is_read'] ?? true,
          unreadCount: unreadCount,
        );
      } catch (e) {
                  return Conversation(
            id: chat['id'] ?? '',
            participantId: '',
            participantName: 'Unknown User',
            participantAvatar: null,
            lastMessage: '',
            lastMessageTime: DateTime.now(),
            isRead: true,
            unreadCount: 0,
          );
      }
    }).toList();
    conversationList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    yield conversationList;
  }
});

// StateNotifier to hold the latest conversation list
class ConversationListNotifier extends StateNotifier<List<Conversation>> {
  final Ref ref;
  final String userId;
  StreamSubscription? _subscription;
  ConversationListNotifier(this.ref, this.userId) : super([]) {
    _listen();
  }
  void _listen() {
    final chatService = ref.read(chatServiceProvider(userId));
    _subscription?.cancel();
    _subscription = chatService.getChats().listen((chats) {
      final conversationList = chats.map<Conversation>((chat) {
        try {
          final isUser1 = chat['user1'] == userId;
          final otherUser = isUser1 ? chat['userByUser2'] : chat['user'];
          final otherUserId = isUser1 ? chat['user2'] : chat['user1'];
          final username = otherUser?['username'] ?? 'Unknown User';
          final profileImage = otherUser?['profile_image'];
          final messages = List<Map<String, dynamic>>.from(chat['messages'] ?? []);
          final lastMessage = messages.isNotEmpty ? messages.first : null;
          final DateTime timeForSorting = lastMessage != null
              ? DateTime.parse(lastMessage['created_at']).toLocal()
              : DateTime.parse(chat['created_at']).toLocal();
          final unreadCount = messages.where((msg) =>
              msg['sender_id'] != userId && !msg['is_read']).length;
          return Conversation(
            id: chat['id'] ?? '',
            participantId: otherUserId ?? '',
            participantName: username,
            participantAvatar: profileImage,
            lastMessage: lastMessage?['message'] ?? '',
            lastMessageTime: timeForSorting,
            isRead: lastMessage?['is_read'] ?? true,
            unreadCount: unreadCount,
          );
        } catch (e) {
                  return Conversation(
          id: chat['id'] ?? '',
          participantId: '',
          participantName: 'Unknown User',
          participantAvatar: null,
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          isRead: true,
          unreadCount: 0,
        );
        }
      }).toList();
      conversationList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      state = conversationList;
    });
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  void clear() => state = [];
}

final conversationListProvider = StateNotifierProvider.autoDispose.family<ConversationListNotifier, List<Conversation>, String>(
  (ref, userId) => ConversationListNotifier(ref, userId),
);

final hasUnreadMessagesProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return false;
  final conversations = ref.watch(conversationListProvider(userId));
  return conversations.any((c) => c.unreadCount > 0);
}); 