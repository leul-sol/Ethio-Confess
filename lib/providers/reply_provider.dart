import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../graphql/graphql_client.dart';
import '../graphql/vent_mutation.dart';
import '../graphql/vent_query.dart';
import '../models/reply_state.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';
import 'vent_provider.dart';
import 'service_providers.dart';

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

class ReplyNotifier extends StateNotifier<ReplyState> {
  final Ref ref;

  ReplyNotifier(this.ref) : super(const ReplyState.initial());

  Future<void> addReply(Map<String, dynamic> input) async {
    try {
      state = const ReplyState.loading();

      final connectivityResult = await Connectivity().checkConnectivity();
      final queueService = ref.read(queueServiceProvider);

      // If offline, queue the reply
      if (connectivityResult == ConnectivityResult.none) {
        await queueService.addReplyToQueue(
          input['vent_id'],
          input['user_id'],
          input['reply'],
          parentId: input['parent_id'],
        );
        state = const ReplyState.success();
        return;
      }

      // If online, perform the reply action
      final client = await ref.read(graphQLClientProvider);
      final result = await client.mutate(
        MutationOptions(
          document: gql(insertVentReplyMutation),
          variables: {
            'objects': [input],
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }

      // Force a refresh of the vent detail data
      final ventId = input['vent_id'];
      final client2 = await ref.read(graphQLClientProvider);
      await client2.query(
        QueryOptions(
          document: gql(ventDetailQuery),
          variables: {'id': ventId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      state = const ReplyState.success();
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = ReplyState.error(appError.message);
    }
  }

  Future<void> updateReply(String replyId, String newReply) async {
    try {
      state = const ReplyState.loading();

      final client = await ref.read(graphQLClientProvider);
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateVentReplyMutation),
          variables: {
            'id': replyId,
            'reply': newReply,
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }

      // Force a refresh of the vent detail data
      if (result.data != null) {
        final ventId = result.data!['update_ventreplies']['returning'][0]['vent_id'];
        final client2 = await ref.read(graphQLClientProvider);
        await client2.query(
          QueryOptions(
            document: gql(ventDetailQuery),
            variables: {'id': ventId},
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        );
      }

      state = const ReplyState.success();
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = ReplyState.error(appError.message);
    }
  }

  void resetState() {
    state = const ReplyState.initial();
  }
}

final replyNotifierProvider =
    StateNotifierProvider<ReplyNotifier, ReplyState>((ref) {
  return ReplyNotifier(ref);
}); 