import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:ethioconfess/graphql/graphql_client.dart';
import 'package:ethioconfess/models/category_enum.dart';
import 'package:ethioconfess/models/biography_entity.dart';
import '../core/error/error_handler_service.dart';

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

// Provider for fetching biographies with likes by category
final biographyWithLikesProvider = StateNotifierProvider.family<
    BiographyWithLikesNotifier,
    AsyncValue<List<BiographyEntity>>,
    Category>((ref, category) {
  return BiographyWithLikesNotifier(ref, category);
});

class BiographyWithLikesNotifier extends StateNotifier<AsyncValue<List<BiographyEntity>>> {
  final Ref ref;
  final Category category;

  BiographyWithLikesNotifier(this.ref, this.category)
      : super(const AsyncValue.loading()) {
    loadBiographies();
  }

  Future<void> loadBiographies() async {
    try {
      state = const AsyncValue.loading();
      final client = await ref.read(graphQLClientProvider);

      final graphqlCategory = categoryToGraphQLEnum(category);
      print("Using GraphQL category value: $graphqlCategory");

      final QueryOptions options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql("""
          query MyQuery(\$category: category!) {
            biography_with_likes(where: {category: {_eq: \$category}}) {
              category
              content
              created_at
              id
              total_like_count
              updated_at 
              user_id
              user {
                username
                profile_image
              }
            }
          }
        """),
        variables: {
          'category': graphqlCategory
        },
      );

      final result = await client.query(options);

      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final biographies = (result.data?['biography_with_likes'] as List)
          .map((json) => BiographyEntity.fromJson(json))
          .toList();

      state = AsyncValue.data(biographies);
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AsyncValue.error(appError, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadBiographies();
  }
} 