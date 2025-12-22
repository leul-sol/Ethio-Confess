import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/profile_image.dart';
import '../graphql/profile_image_queries.dart';
import '../graphql/graphql_client.dart';
import '../core/error/error_handler_service.dart';

// Provider for fetching profile images from backend
final profileImagesProvider = FutureProvider<List<ProfileImage>>((ref) async {
  try {
    final client = await graphqlClient();
    
    final result = await client.query(
      QueryOptions(
        document: gql(getProfileImagesQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    final profileImagesData = result.data?['profile_images'] as List?;
    if (profileImagesData == null) {
      return [];
    }

    return profileImagesData
        .map((json) => ProfileImage.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw ErrorHandlerService.handleError(e);
  }
});

// Provider for updating user's profile image
final updateUserProfileImageProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  try {
    final client = await graphqlClient();
    
    final result = await client.mutate(
      MutationOptions(
        document: gql(updateUserProfileImageMutation),
        variables: {
          'userId': params['userId'],
          'profileImageUrl': params['profileImageUrl'],
        },
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    final updatedUser = result.data?['update_users_by_pk'];
    return updatedUser != null;
  } catch (e) {
    throw ErrorHandlerService.handleError(e);
  }
});
