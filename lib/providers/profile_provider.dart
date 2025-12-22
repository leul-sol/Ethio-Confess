import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../graphql/auth_mutation.dart';
import '../models/profile_state.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

class ProfileStateNotifier extends StateNotifier<ProfileState> {
  final Ref ref;

  ProfileStateNotifier(this.ref) : super(const ProfileState.initial());

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? profile_image,
  }) async {
    try {
      print('=== PROFILE UPDATE START ===');
      print('User ID: $userId');
      print('Name: $name');
      print('Email: $email');
      print('Profile Image: ${profile_image ?? 'null'}');
      
      state = const ProfileState.loading();
      print('Profile state set to loading');

      final client = await ref.read(graphQLClientProvider);
      print('GraphQL client initialized');
      
      print('Executing GraphQL mutation...');
      final result = await client.mutate(
        MutationOptions(
          document: gql('''
            mutation UpdateUserProfile(
              \$userId: uuid!,
              \$name: String!,
              \$email: String!,
              \$profile_image: String
            ) {
              update_users_by_pk(
                pk_columns: {id: \$userId},
                _set: {
                  username: \$name,
                  email: \$email,
                  profile_image: \$profile_image
                }
              ) {
                id
                username
                email
                profile_image
              }
            }
          '''),
          variables: {
            'userId': userId,
            'name': name,
            'email': email,
            'profile_image': profile_image,
          },
        ),
      );
      
      print('GraphQL mutation completed');
      print('Has data: ${result.data != null}');
      print('Has exception: ${result.hasException}');
      
      if (result.hasException) {
        print('GraphQL errors:');
        for (var error in result.exception!.graphqlErrors) {
          print('  - ${error.message}');
        }
      }
      
      if (result.data != null) {
        print('Mutation result data: ${result.data}');
      }

      if (result.hasException) {
        final error = result.exception!;
        if (error.graphqlErrors.isNotEmpty) {
          final firstError = error.graphqlErrors.first;
          if (firstError.message.contains('unique constraint')) {
            throw AppError.validation('This email is already in use');
          }
        }
        throw ErrorHandlerService.handleError(error);
      }

      state = const ProfileState.success('Profile updated successfully');
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = ProfileState.error(appError.message);
    }
  }

  Future<void> updateUserPassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      state = const ProfileState.loading();

      final client = await ref.read(graphQLClientProvider);
      
      // Call API updatePassword mutation which validates current password server-side
      final result = await client.mutate(
        MutationOptions(
          document: gql(updatePasswordMutation),
          variables: {
            'currentPassword': currentPassword,
            'email': email,
            'newPassword': newPassword,
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        // Surface the server message like "Current password is incorrect."
        throw ErrorHandlerService.handleError(result.exception!);
      }

      state = const ProfileState.success('Password updated successfully.');
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = ProfileState.error(appError.message);
    }
  }

  void resetState() {
    state = const ProfileState.initial();
  }
}

final profileStateProvider =
    StateNotifierProvider<ProfileStateNotifier, ProfileState>((ref) {
  return ProfileStateNotifier(ref);
});
