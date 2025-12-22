import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../providers/service_providers.dart' as service;
import '../providers/auth_provider.dart';

final chatSettingsProvider = StateNotifierProvider<ChatSettingsNotifier, bool>((ref) {
  return ChatSettingsNotifier(ref);
});

class ChatSettingsNotifier extends StateNotifier<bool> {
  final Ref ref;

  ChatSettingsNotifier(this.ref) : super(true) {
    _loadChatSettings();
  }

  Future<void> _loadChatSettings() async {
    try {
      final client = await ref.read(service.graphQLClientProvider);
      if (client == null) {
        state = true;
        return;
      }

      final userId = ref.watch(userIdProvider);
      if (userId == null) {
        state = true;
        return;
      }

      final result = await client.query(
        QueryOptions(
          document: gql('''
            query GetUserChatSettings(\$userId: uuid!) {
              users_by_pk(id: \$userId) {
                allow_chat
              }
            }
          '''),
          variables: {
            'userId': userId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final allowChat = result.data?['users_by_pk']['allow_chat'] ?? true;
      state = allowChat;
    } catch (e) {
      // Don't change state if there's an error
      return;
    }
  }

  Future<void> updateChatSettings(bool allowChat) async {
    try {
      final client = await ref.read(service.graphQLClientProvider);
      if (client == null) {
        throw Exception('Unable to connect to the server. Please check your internet connection and try again.');
      }

      final userId = ref.watch(userIdProvider);
      if (userId == null) {
        throw Exception('Please sign in to update your chat settings.');
      }

      final result = await client.mutate(
        MutationOptions(
          document: gql('''
            mutation UpdateChatSettings(\$userId: uuid!, \$allowChat: Boolean!) {
              update_users_by_pk(
                pk_columns: {id: \$userId},
                _set: {allow_chat: \$allowChat}
              ) {
                id
                allow_chat
              }
            }
          '''),
          variables: {
            'userId': userId,
            'allowChat': allowChat,
          },
        ),
      );

      if (result.hasException) {
        // Handle specific GraphQL errors
        if (result.exception is OperationException) {
          final operationException = result.exception as OperationException;
          if (operationException.linkException != null) {
            // Network/connection error
            throw Exception('No internet connection. Please check your network and try again.');
          } else if (operationException.graphqlErrors.isNotEmpty) {
            // GraphQL server error
            throw Exception('Server error. Please try again later.');
          }
        }
        // Generic error
        throw Exception('Failed to update settings. Please try again.');
      }

      // Only update state after successful mutation
      state = allowChat;
    } catch (e) {
      // Revert state if there's an error
      rethrow;
    }
  }
} 