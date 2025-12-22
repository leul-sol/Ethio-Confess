// // import 'package:graphql_flutter/graphql_flutter.dart';
// // import 'package:ethioconfess/models/popular_entity.dart';
// // import 'package:ethioconfess/services/biography_service.dart';
// // import 'package:ethioconfess/utils/biography_queries.dart';

// // enum Category { Family, Relationship, Health }

// // // Convert the enum to a string for GraphQL queries
// // String categoryToString(Category category) {
// //   return category.toString().split('.').last;
// // }

// // class BiographyGraphQLService {
// //   static GraphQLService biographygraphqlservice = GraphQLService();
// //   GraphQLClient client = biographygraphqlservice.clientTOQuery();

// //   Future<List<dynamic>> fetchBiographies(String category) async {
// //     final QueryOptions options = QueryOptions(
// //       fetchPolicy: FetchPolicy.noCache,
// //       document: gql(biographyQuery),
// //       variables: {'category': category},
// //     );

// //     final QueryResult result = await client.query(options);

// //     if (result.hasException) {
// //       throw Exception(result.exception.toString());
// //     }

// //     return result.data?['biography'] ?? [];
// //   }

// //   Future<bool> addBiography({
// //     required String userId,
// //     required Category category,
// //     required String content,
// //     required String createdAt,
// //   }) async {
// //     final MutationOptions options = MutationOptions(
// //       document: gql(addBiographyMutation),
// //       variables: {
// //         'user_id': userId,
// //         'category': categoryToString(category),
// //         'content': content.trim(),
// //         'created_at': createdAt,
// //       },
// //     );

// //     final QueryResult result = await client.mutate(options);

// //     if (result.hasException) {
// //       throw Exception(result.exception.toString());
// //     }

// //     // Ensure that the data includes the expected returning fields
// //     final insertedBiography = result.data?['insert_biography']['returning'];
// //     if (insertedBiography != null && insertedBiography.isNotEmpty) {
// //       return true;
// //     } else {
// //       return false;
// //     }
// //   }

// //   Future<int> fetchLikes(String biographyId) async {
// //     final QueryOptions options = QueryOptions(
// //       fetchPolicy: FetchPolicy.noCache,
// //       document: gql(getBiographyLikesQuery),
// //       variables: {'biographyId': biographyId},
// //     );

// //     final QueryResult result = await client.query(options);

// //     if (result.hasException) {
// //       throw Exception(result.exception.toString());
// //     }

// //     return result.data?['biographylikes_aggregate']['aggregate']['count'] ?? 0;
// //   }

// //   Future<List<dynamic>> fetchTopLikedBiographies() async {
// //     final QueryOptions options = QueryOptions(
// //       fetchPolicy: FetchPolicy.noCache,
// //       document: gql(topLikedBiographiesQuery), // Use your top liked query
// //     );

// //     final QueryResult result = await client.query(options);

// //     if (result.hasException) {
// //       throw Exception(result.exception.toString());
// //     }

// //     return result.data?['biography'] ?? [];
// //   }

// //   Future<List<VentEntity>> fetchVentPosts(String userId) async {
// //     print('Fetching Vent Posts for User ID: $userId');

// //     final QueryOptions options = QueryOptions(
// //       document: gql(ventPostsQuery),
// //       variables: {'userid': userId},
// //     );

// //     final QueryResult result = await client.query(options);

// //     if (result.hasException) {
// //       print('GraphQL Exception: ${result.exception.toString()}');
// //       throw Exception(result.exception.toString());
// //     }

// //     print('Raw GraphQL Data: ${result.data}');

// //     return (result.data?['vent'] as List)
// //         .map((json) => VentEntity.fromJson(json))
// //         .toList();
// //   }

// //   Future<PopularEntity> fetchPopularEntityById(String id) async {
// //     final QueryOptions options = QueryOptions(
// //       fetchPolicy: FetchPolicy.noCache,
// //       document: gql(getPopularEntityByIdQuery),
// //       variables: {'id': id},
// //     );

// //     final QueryResult result = await client.query(options);

// //     if (result.hasException) {
// //       throw Exception(result.exception.toString());
// //     }

// //     final data = result.data?['biography_by_pk'];

// //     if (data == null) {
// //       throw Exception('No data found for the provided ID');
// //     }

// //     return PopularEntity.fromJson(data);
// //   }

// //   Future<UserEntity> fetchUserInfo(String id) async {
// //     final String fetchUserInfoQuery = """
// //     query GetUserInfo(\$id: uuid!) {
// //       user(id: \$id) {
// //         username
// //         created_at
// //       }
// //     }
// //     """;

// //     final QueryOptions options = QueryOptions(
// //       document: gql(fetchUserInfoQuery),
// //       variables: {'id': id},
// //     );

// //     final QueryResult result = await client.query(options);

// //     if (result.hasException) {
// //       throw Exception(result.exception.toString());
// //     }

// //     final data = result.data?['user'];
// //     if (data == null) {
// //       throw Exception('No user found for the provided ID');
// //     }

// //     return UserEntity.fromJson(data);
// //   }
// // }

// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:ethioconfess/models/popular_entity.dart';
// import 'package:ethioconfess/utils/biography_queries.dart';

// enum Category { Family, Relationship, Health }

// // Convert the enum to a string for GraphQL queries
// // String categoryToString(Category category) {
// //   print('categoryToString: ${category.toString().split('.').last}');
// //   return category.toString().split('.').last;
// // }
// String categoryToString(Category category) {
//   print("the category is ${category.toString().split('.').last}");
//   return category.toString().split('.').last;
// }

// class BiographyGraphQLService {
//   final GraphQLClient client;

//   BiographyGraphQLService(this.client);

//   Future<List<dynamic>> fetchBiographies(String category) async {
//     final QueryOptions options = QueryOptions(
//       fetchPolicy: FetchPolicy.noCache,
//       document: gql(biographyQuery),
//       variables: {'category': category},
//       // timeout: Duration(seconds: 10),
//     );

//     final QueryResult result = await client.query(options);

//     if (result.hasException) {
//       print('GraphQL tException: ${result.exception.toString()}');
//       throw Exception(result.exception.toString());
//     }

//     return result.data?['biography'] ?? [];
//   }

//   Future<bool> addBiography({
//     required String userId,
//     required Category category,
//     required String content,
//     required String createdAt,
//   }) async {
//     final MutationOptions options = MutationOptions(
//       document: gql(addBiographyMutation),
//       variables: {
//         'user_id': userId,
//         'category': categoryToString(category),
//         'content': content.trim(),
//         'created_at': createdAt,
//       },
//     );

//     final QueryResult result = await client.mutate(options);

//     if (result.hasException) {
//       throw Exception(result.exception.toString());
//     }

//     final insertedBiography = result.data?['insert_biography']['returning'];
//     return insertedBiography != null && insertedBiography.isNotEmpty;
//   }

//   Future<int> fetchLikes(String biographyId) async {
//     final QueryOptions options = QueryOptions(
//       fetchPolicy: FetchPolicy.noCache,
//       document: gql(getBiographyLikesQuery),
//       variables: {'biographyId': biographyId},
//     );

//     final QueryResult result = await client.query(options);

//     if (result.hasException) {
//       throw Exception(result.exception.toString());
//     }

//     return result.data?['biographylikes_aggregate']['aggregate']['count'] ?? 0;
//   }

//   Future<List<dynamic>> fetchTopLikedBiographies() async {
//     final QueryOptions options = QueryOptions(
//       fetchPolicy: FetchPolicy.noCache,
//       document: gql(topLikedBiographiesQuery),
//     );

//     final QueryResult result = await client.query(options);

//     if (result.hasException) {
//       throw Exception(result.exception.toString());
//     }

//     return result.data?['biography'] ?? [];
//   }

//   Future<List<VentEntity>> fetchVentPosts(String userId) async {
//     final QueryOptions options = QueryOptions(
//       document: gql(ventPostsQuery),
//       variables: {'userid': userId},
//     );

//     final QueryResult result = await client.query(options);

//     if (result.hasException) {
//       throw Exception(result.exception.toString());
//     }

//     return (result.data?['vent'] as List)
//         .map((json) => VentEntity.fromJson(json))
//         .toList();
//   }

//   Future<PopularEntity> fetchPopularEntityById(String id) async {
//     final QueryOptions options = QueryOptions(
//       fetchPolicy: FetchPolicy.noCache,
//       document: gql(getPopularEntityByIdQuery),
//       variables: {'id': id},
//     );

//     final QueryResult result = await client.query(options);

//     if (result.hasException) {
//       throw Exception(result.exception.toString());
//     }

//     final data = result.data?['biography_by_pk'];

//     if (data == null) {
//       throw Exception('No data found for the provided ID');
//     }

//     return PopularEntity.fromJson(data);
//   }

//   Future<UserEntity> fetchUserInfo(String id) async {
//     final String fetchUserInfoQuery = """
//     query GetUserInfo(\$id: uuid!) {
//       user(id: \$id) {
//         username
//         created_at
//       }
//     }
//     """;

//     final QueryOptions options = QueryOptions(
//       document: gql(fetchUserInfoQuery),
//       variables: {'id': id},
//     );

//     final QueryResult result = await client.query(options);

//     if (result.hasException) {
//       throw Exception(result.exception.toString());
//     }

//     final data = result.data?['user'];
//     if (data == null) {
//       throw Exception('No user found for the provided ID');
//     }

//     return UserEntity.fromJson(data);
//   }

//   Future<bool> deleteVent(String id) async {
//     const String deleteVentMutation = """
//       mutation DeleteVent(\$id: uuid!) {
//         delete_vent_by_pk(id: \$id) {
//           id
//         }
//       }
//     """;

//     final MutationOptions options = MutationOptions(
//       document: gql(deleteVentMutation),
//       variables: {'id': id},
//     );

//     final QueryResult result = await client.mutate(options);

//     if (result.hasException) {
//       throw Exception(result.exception.toString());
//     }

//     // Check if the deletion was successful
//     final deletedVent = result.data?['delete_vent_by_pk'];
//     return deletedVent != null;
//   }
// }
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:ethioconfess/models/category_model.dart';
import 'package:ethioconfess/models/popular_entity.dart';
import 'package:ethioconfess/utils/biography_queries.dart';
import '../core/error/error_handler_service.dart';
import '../core/error/app_error.dart';
import 'dart:developer' as developer;

// This function accepts a string category name and returns it directly
String getCategoryString(String categoryName) {
  developer.log('Processing category: $categoryName', name: 'BiographyGraphQLService');
  return categoryName;
}

class BiographyGraphQLService {
  final GraphQLClient client;
  static const String _serviceName = 'BiographyGraphQLService';

  BiographyGraphQLService(this.client);

  Future<List<dynamic>> fetchBiographies(String category) async {
    final startTime = DateTime.now();
    developer.log(
      'Fetching biographies for category: $category',
      name: _serviceName,
    );

    try {
      final QueryOptions options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql(biographyQuery),
        variables: {'category': category},
      );

      final QueryResult result = await client.query(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error fetching biographies: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final data = result.data?['biography'] ?? [];
      developer.log(
        'Successfully fetched ${data.length} biographies in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return data;
    } catch (e, stackTrace) {
      developer.log(
        'Exception in fetchBiographies',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }

  Future<bool> addBiography({
    required String userId,
    required String category,
    required String content,
    required String createdAt,
  }) async {
    final startTime = DateTime.now();
    developer.log(
      'Adding biography for user: $userId, category: $category',
      name: _serviceName,
    );

    try {
      final MutationOptions options = MutationOptions(
        document: gql(addBiographyMutation),
        variables: {
          'user_id': userId,
          'category': category,
          'content': content.trim(),
        },
      );

      final QueryResult result = await client.mutate(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error adding biography: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final insertedBiography = result.data?['insert_biography']['returning'];
      final success = insertedBiography != null && insertedBiography.isNotEmpty;
      
      developer.log(
        'Biography ${success ? 'successfully added' : 'failed to add'} in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return success;
    } catch (e, stackTrace) {
      developer.log(
        'Exception in addBiography',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }

  Future<int> fetchLikes(String biographyId) async {
    final startTime = DateTime.now();
    developer.log(
      'Fetching likes for biography: $biographyId',
      name: _serviceName,
    );

    try {
      final QueryOptions options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql(getBiographyLikesQuery),
        variables: {'biographyId': biographyId},
      );

      final QueryResult result = await client.query(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error fetching likes: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final likes = result.data?['biography_likes_aggregate']['aggregate']['count'] ?? 0;
      developer.log(
        'Successfully fetched $likes likes in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return likes;
    } catch (e, stackTrace) {
      developer.log(
        'Exception in fetchLikes',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }

  Future<List<dynamic>> fetchTopLikedBiographies() async {
    final startTime = DateTime.now();
    developer.log('Fetching top liked biographies', name: _serviceName);

    try {
      final QueryOptions options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql(topLikedBiographiesQuery),
      );

      final QueryResult result = await client.query(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error fetching top liked biographies: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final data = result.data?['biography'] ?? [];
      developer.log(
        'Successfully fetched ${data.length} top liked biographies in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return data;
    } catch (e, stackTrace) {
      developer.log(
        'Exception in fetchTopLikedBiographies',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }

  Future<List<VentEntity>> fetchVentPosts(String userId) async {
    final startTime = DateTime.now();
    developer.log(
      'Fetching vent posts for user: $userId',
      name: _serviceName,
    );

    try {
      final QueryOptions options = QueryOptions(
        document: gql(ventPostsQuery),
        variables: {'userid': userId},
      );

      final QueryResult result = await client.query(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error fetching vent posts: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final vents = (result.data?['vent'] as List)
          .map((json) => VentEntity.fromJson(json))
          .toList();
      
      developer.log(
        'Successfully fetched ${vents.length} vent posts in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return vents;
    } catch (e, stackTrace) {
      developer.log(
        'Exception in fetchVentPosts',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }

  Future<PopularEntity> fetchPopularEntityById(String id) async {
    final startTime = DateTime.now();
    developer.log(
      'Fetching popular entity by id: $id',
      name: _serviceName,
    );

    try {
      final QueryOptions options = QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql(getPopularEntityByIdQuery),
        variables: {'id': id},
      );

      final QueryResult result = await client.query(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error fetching popular entity: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final data = result.data?['biography_by_pk'];
      if (data == null) {
        developer.log(
          'No data found for id: $id',
          name: _serviceName,
        );
        throw AppError.server('No data found for the provided ID');
      }

      developer.log(
        'Successfully fetched popular entity in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return PopularEntity.fromJson(data);
    } catch (e, stackTrace) {
      developer.log(
        'Exception in fetchPopularEntityById',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }

  Future<UserEntity> fetchUserInfo(String id) async {
    final startTime = DateTime.now();
    developer.log(
      'Fetching user info for id: $id',
      name: _serviceName,
    );

    try {
      final String fetchUserInfoQuery = """
      query GetUserInfo(\$id: uuid!) {
        user(id: \$id) {
          username
          created_at
        }
      }
      """;

      final QueryOptions options = QueryOptions(
        document: gql(fetchUserInfoQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      );

      final QueryResult result = await client.query(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error fetching user info: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final data = result.data?['user'];
      if (data == null) {
        developer.log(
          'No user found for id: $id',
          name: _serviceName,
        );
        throw AppError.server('No user found for the provided ID');
      }

      developer.log(
        'Successfully fetched user info in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return UserEntity.fromJson(data);
    } catch (e, stackTrace) {
      developer.log(
        'Exception in fetchUserInfo',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }

  Future<bool> deleteVent(String id) async {
    final startTime = DateTime.now();
    developer.log(
      'Deleting vent with id: $id',
      name: _serviceName,
    );

    try {
      const String deleteVentMutation = """
        mutation DeleteVent(\$id: uuid!) {
          delete_vent_by_pk(id: \$id) {
            id
          }
        }
      """;

      final MutationOptions options = MutationOptions(
        document: gql(deleteVentMutation),
        variables: {'id': id},
      );

      final QueryResult result = await client.mutate(options);
      final duration = DateTime.now().difference(startTime);

      if (result.hasException) {
        developer.log(
          'Error deleting vent: ${result.exception}',
          name: _serviceName,
          error: result.exception,
        );
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final deletedVent = result.data?['delete_vent_by_pk'];
      if (deletedVent == null) {
        developer.log(
          'Failed to delete vent with id: $id',
          name: _serviceName,
        );
        throw AppError.server('Failed to delete vent');
      }
      
      developer.log(
        'Successfully deleted vent in ${duration.inMilliseconds}ms',
        name: _serviceName,
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Exception in deleteVent',
        name: _serviceName,
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandlerService.handleError(e, stackTrace);
    }
  }
}
