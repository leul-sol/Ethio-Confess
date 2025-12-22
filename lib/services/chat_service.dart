import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:metsnagna/services/queue_service.dart';
import '../providers/auth_provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../graphql/chat_subscriptions.dart';
import 'package:metsnagna/providers/service_providers.dart';

class ChatService {
  final String currentUserId;
  final Ref ref;
  late GraphQLClient client;
  bool _isInitialized = false;
  final StreamController<List<Map<String, dynamic>>> _chatsController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _messagesController = StreamController<List<Map<String, dynamic>>>.broadcast();
  StreamSubscription<QueryResult>? _messagesSubscription;
  StreamSubscription<QueryResult>? _chatsSubscription;

  ChatService(this.currentUserId, this.ref) {
    if (currentUserId.isEmpty) {
      throw Exception('Current user ID cannot be empty');
    }
    _initializeClient();
    developer.log('ChatService initialized for user: $currentUserId');
  }

  Future<void> _initializeClient() async {
    try {
      client = await graphqlClient();
      _isInitialized = true;
      developer.log('ChatService client initialized successfully');
    } catch (e) {
      developer.log('Error initializing ChatService client: $e');
      rethrow;
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeClient();
    }
  }

  Stream<List<Map<String, dynamic>>> getChats() async* {
    await ensureInitialized();
    developer.log('Subscribing to chats for user: $currentUserId');
    
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        // Cancel any existing subscription
        _chatsSubscription?.cancel();

        // Subscribe to chat updates
        _chatsSubscription = client.subscribe(
          SubscriptionOptions(
            document: gql(getChatsSubscription),
            variables: {
              'userId': currentUserId,
            },
          ),
        ).listen(
          (result) {
            if (result.hasException) {
              developer.log('Error in chat subscription: ${result.exception}');
              return;
            }

            final chats = List<Map<String, dynamic>>.from(result.data?['chats'] ?? []);
            developer.log('Received ${chats.length} chats in subscription');
            _chatsController.add(chats);
          },
          onError: (error) {
            developer.log('Error in chat subscription: $error');
            // Don't throw here, just log the error
          },
          cancelOnError: false, // Keep subscription alive even after errors
        );

        yield* _chatsController.stream;
        break; // If we get here, everything worked, so break the retry loop
      } catch (e) {
        developer.log('Error in getChats (attempt ${retryCount + 1}/$maxRetries): $e');
        retryCount++;
        
        if (retryCount < maxRetries) {
          developer.log('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        } else {
          developer.log('Max retries reached. Giving up.');
          rethrow;
        }
      }
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId) async* {
    await ensureInitialized();
    developer.log('Subscribing to messages for chat: $chatId');
    
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        // Cancel any existing subscription
        _messagesSubscription?.cancel();

        // First, get initial messages
        final initialResult = await client.query(
          QueryOptions(
            document: gql(getMessagesQuery),
            variables: {
              'chatId': chatId,
            },
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
        );

        if (initialResult.hasException) {
          developer.log('Error fetching initial messages: ${initialResult.exception}');
          throw initialResult.exception!;
        }

        final chat = initialResult.data?['chats_by_pk'];
        if (chat == null) {
          developer.log('No chat found with ID: $chatId');
          throw Exception('Chat not found');
        }

        final initialMessages = List<Map<String, dynamic>>.from(chat['messages'] ?? []);
        developer.log('Received ${initialMessages.length} initial messages');
        _messagesController.add(initialMessages);

        // Then subscribe to real-time updates
        _messagesSubscription = client.subscribe(
          SubscriptionOptions(
            document: gql(getMessagesSubscription),
            variables: {
              'chatId': chatId,
            },
          ),
        ).listen(
          (result) {
            if (result.hasException) {
              developer.log('Error in message subscription: ${result.exception}');
              return;
            }

            final messages = List<Map<String, dynamic>>.from(result.data?['messages'] ?? []);
            developer.log('Received ${messages.length} messages in subscription');
            _messagesController.add(messages);
          },
          onError: (error) {
            developer.log('Error in message subscription: $error');
            // Don't throw here, just log the error
          },
          cancelOnError: false, // Keep subscription alive even after errors
        );

        yield* _messagesController.stream;
        break; // If we get here, everything worked, so break the retry loop
      } catch (e) {
        developer.log('Error in getMessages (attempt ${retryCount + 1}/$maxRetries): $e');
        retryCount++;
        
        if (retryCount < maxRetries) {
          developer.log('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        } else {
          developer.log('Max retries reached. Giving up.');
          throw e;
        }
      }
    }
  }

  Future<void> sendMessage(String chatId, String message) async {
    developer.log('Sending message to chat $chatId: $message');

    final connectivityResult = await Connectivity().checkConnectivity();
    final queueService = ref.read(queueServiceProvider);

    if (connectivityResult == ConnectivityResult.none) {
      developer.log('Offline: Queuing message for chat $chatId');
      await queueService.addMessageToQueue(chatId, message, currentUserId);
      return;
    }

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(sendMessageMutation),
          variables: {
            'chatId': chatId,
            'message': message,
            'senderId': currentUserId,
          },
        ),
      );

      if (result.hasException) {
        developer.log('Error sending message: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      developer.log('Message sent successfully');
    } catch (e) {
      developer.log('Error sending message: $e');
      rethrow;
    }
  }

  Future<String> getOrCreateChatRoom(String otherUserId) async {
    developer.log('Getting or creating chat room with user: $otherUserId');
    
    try {
      // First, try to find an existing chat
      final result = await client.query(
        QueryOptions(
          document: gql(getChatsQuery),
          variables: {
            'userId': currentUserId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        developer.log('Error finding chat room: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final chats = List<Map<String, dynamic>>.from(result.data?['chats'] ?? []);
      final existingChat = chats.firstWhere(
        (chat) {
          developer.log('Checking chat: id=${chat['id']}, user1=${chat['user1']}, user2=${chat['user2']}');
          developer.log('Comparing with: currentUserId=$currentUserId, otherUserId=$otherUserId');
          return (chat['user1'] == currentUserId && chat['user2'] == otherUserId) ||
                 (chat['user1'] == otherUserId && chat['user2'] == currentUserId);
        },
        orElse: () => {},
      );

      // Check if an actual chat object with a non-null and non-empty 'id' was found
      if (existingChat['id'] != null && existingChat['id'].isNotEmpty) {
        developer.log('Found existing chat room: ${existingChat['id']}');
        return existingChat['id'];
      }

      // If no valid existing chat found, create a new one
      final createResult = await client.mutate(
        MutationOptions(
          document: gql(createChatMutation),
          variables: {
            'user1': currentUserId,
            'user2': otherUserId,
          },
        ),
      );

      if (createResult.hasException) {
        developer.log('Error creating chat room: ${createResult.exception}');
        throw Exception(createResult.exception.toString());
      }

      final chatId = createResult.data?['insert_chats_one']?['id'];
      if (chatId == null) {
        throw Exception('Failed to create chat room');
      }

      developer.log('Created new chat room with ID: $chatId');
      return chatId;
    } catch (e) {
      developer.log('Error in getOrCreateChatRoom: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      await client.mutate(
        MutationOptions(
          document: gql(markMessagesAsReadMutation),
          variables: {
            'chatId': chatId,
            'userId': currentUserId,
          },
        ),
      );
      developer.log('Marked messages as read for chat $chatId');
    } catch (e) {
      developer.log('Error marking messages as read: $e');
    }
  }

  Future<void> updateMessage(String messageId, String newContent) async {
    developer.log('Updating message $messageId with new content: $newContent');

    final connectivityResult = await Connectivity().checkConnectivity();
    final queueService = ref.read(queueServiceProvider);

    if (connectivityResult == ConnectivityResult.none) {
      developer.log('Offline: Queuing message update for message $messageId');
      await queueService.addMessageUpdateToQueue(messageId, newContent, currentUserId);
      return;
    }

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateMessageMutation),
          variables: {
            'messageId': messageId,
            'newContent': newContent,
          },
        ),
      );

      if (result.hasException) {
        developer.log('Error updating message: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      developer.log('Message updated successfully');
    } catch (e) {
      developer.log('Error updating message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    developer.log('Deleting message $messageId');

    final connectivityResult = await Connectivity().checkConnectivity();
    final queueService = ref.read(queueServiceProvider);

    if (connectivityResult == ConnectivityResult.none) {
      developer.log('Offline: Queuing message deletion for message $messageId');
      await queueService.addMessageDeletionToQueue(messageId, currentUserId);
      return;
    }

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(deleteMessageMutation),
          variables: {
            'messageId': messageId,
          },
        ),
      );

      if (result.hasException) {
        developer.log('Error deleting message: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      developer.log('Message deleted successfully');
    } catch (e) {
      developer.log('Error deleting message: $e');
      rethrow;
    }
  }

  void dispose() {
    developer.log('Disposing ChatService');
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel();
    _chatsController.close();
    _messagesController.close();
  }
}

// Provider for ChatService
final chatServiceProvider = Provider.family<ChatService, String>((ref, currentUserId) {
  return ChatService(currentUserId, ref);
}); 