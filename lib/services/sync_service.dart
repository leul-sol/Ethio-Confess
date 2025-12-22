import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import 'queue_service.dart';

class SyncService {
  final ProviderContainer container;
  final QueueService queueService;
  final Future<GraphQLClient> clientFuture;

  SyncService(this.container, this.queueService, this.clientFuture);

  Future<void> startSync() async {
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        await syncQueuedActions();
      }
    });
  }

  Future<void> syncQueuedActions() async {
    await syncLikes();
    await syncReplies();
    await syncMessages();
  }

  Future<void> syncLikes() async {
    final likeQueue = await queueService.getLikeQueue();
    final client = await clientFuture;
    
    for (var i = 0; i < likeQueue.length; i++) {
      final like = likeQueue[i];
      try {
        final result = await client.mutate(
          MutationOptions(
            document: gql("""
              mutation LikeBiography(\$biography_id: uuid!, \$user_id: uuid!) {
                insert_biographylikes_one(object: {
                  biography_id: \$biography_id, 
                  user_id: \$user_id
                }) {
                  id
                }
              }
            """),
            variables: {
              'biography_id': like['biography_id'],
              'user_id': like['user_id'],
            },
          ),
        );

        if (!result.hasException) {
          await queueService.removeLikeFromQueue(i);
        }
      } catch (e) {
        print('Error syncing like: $e');
      }
    }
  }

  Future<void> syncReplies() async {
    final replyQueue = await queueService.getReplyQueue();
    final client = await clientFuture;
    
    for (var i = 0; i < replyQueue.length; i++) {
      final reply = replyQueue[i];
      try {
        final result = await client.mutate(
          MutationOptions(
            document: gql("""
              mutation InsertVentReply(\$objects: [ventreplies_insert_input!]!) {
                insert_ventreplies(objects: \$objects) {
                  affected_rows
                  returning {
                    id
                    reply
                    created_at
                    parent_id
                    user {
                      username
                    }
                  }
                }
              }
            """),
            variables: {
              'objects': [{
                'vent_id': reply['vent_id'],
                'user_id': reply['user_id'],
                'reply': reply['reply'],
                if (reply['parent_id'] != null) 'parent_id': reply['parent_id'],
              }],
            },
          ),
        );

        if (!result.hasException) {
          await queueService.removeReplyFromQueue(i);
        }
      } catch (e) {
        print('Error syncing reply: $e');
      }
    }
  }

  Future<void> syncMessages() async {
    final messageQueue = await queueService.getMessageQueue();
    final client = await clientFuture;
    
    for (var i = 0; i < messageQueue.length; i++) {
      final message = messageQueue[i];
      try {
        if (message['action'] == 'update') {
          final result = await client.mutate(
            MutationOptions(
              document: gql("""
                mutation UpdateMessage(\$messageId: uuid!, \$newContent: String!) {
                  update_messages_by_pk(
                    pk_columns: {id: \$messageId},
                    _set: {message: \$newContent}
                  ) {
                    id
                    message
                  }
                }
              """),
              variables: {
                'messageId': message['message_id'],
                'newContent': message['new_content'],
              },
            ),
          );

          if (!result.hasException) {
            await queueService.removeMessageFromQueue(i);
          }
        } else if (message['action'] == 'delete') {
          final result = await client.mutate(
            MutationOptions(
              document: gql("""
                mutation DeleteMessage(\$messageId: uuid!) {
                  delete_messages_by_pk(id: \$messageId) {
                    id
                  }
                }
              """),
              variables: {
                'messageId': message['message_id'],
              },
            ),
          );

          if (!result.hasException) {
            await queueService.removeMessageFromQueue(i);
          }
        } else {
          // Handle regular message sending
          final result = await client.mutate(
            MutationOptions(
              document: gql("""
                mutation SendMessage(\$chatId: uuid!, \$message: String!, \$senderId: uuid!) {
                  insert_messages_one(object: {
                    chat_id: \$chatId,
                    message: \$message,
                    sender_id: \$senderId,
                    is_read: false
                  }) {
                    id
                    chat_id
                    message
                    sender_id
                    created_at
                    is_read
                  }
                }
              """),
              variables: {
                'chatId': message['chat_id'],
                'message': message['message'],
                'senderId': message['sender_id'],
              },
            ),
          );

          if (!result.hasException) {
            await queueService.removeMessageFromQueue(i);
          }
        }
      } catch (e) {
        print('Error syncing message: $e');
      }
    }
  }
} 