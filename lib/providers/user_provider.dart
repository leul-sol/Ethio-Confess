import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../models/user.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;

  UserNotifier(this.ref) : super(const UserState());

  Future<void> fetchUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final client = await ref.read(graphQLClientProvider);
      final result = await client.query(
        QueryOptions(
          document: gql('''
            query GetUser(\$userId: uuid!) {
              users_by_pk(id: \$userId) {
                id
                username
                email
                created_at
                updated_at
              }
            }
          '''),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final userData = result.data?['users_by_pk'];
      if (userData == null) {
        throw AppError.notFound('User not found');
      }

      final user = User.fromJson(userData);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: appError.message,
      );
    }
  }

  void clearUser() {
    state = const UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});
