// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ethioconfess/providers/auth_provider.dart';
// import 'package:ethioconfess/graphql/graphql_client.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';

// // Central repository for tracking liked biographies
// class BiographyLikeNotifier extends StateNotifier<Map<String, bool>> {
//   final Ref ref;

//   BiographyLikeNotifier(this.ref) : super({});

//   // Initialize likes for a specific biography
//   Future<void> initializeLike(String biographyId) async {
//     if (state.containsKey(biographyId)) return;

//     final userId = ref.read(userIdProvider);
//     if (userId == null) return;

//     try {
//       final client = graphqlClient();
//       final result = await client.query(
//         QueryOptions(
//           document: gql("""
//             query CheckUserLike(\$biography_id: uuid!, \$user_id: uuid!) {
//               biographylikes(where: {
//                 biography_id: {_eq: \$biography_id},
//                 user_id: {_eq: \$user_id}
//               }) {
//                 id
//               }
//             }
//           """),
//           variables: {
//             'biography_id': biographyId,
//             'user_id': userId,
//           },
//           fetchPolicy: FetchPolicy.networkOnly,
//         ),
//       );

//       final likes = result.data?['biographylikes'] as List?;
//       final isLiked = likes?.isNotEmpty ?? false;

//       state = {...state, biographyId: isLiked};
//     } catch (e) {
//       print("Error checking like status: $e");
//     }
//   }

//   // Toggle like status and update backend
//   Future<void> toggleLike(String biographyId, int currentLikeCount) async {
//     final userId = ref.read(userIdProvider);
//     if (userId == null) return;

//     final isCurrentlyLiked = state[biographyId] ?? false;

//     // Optimistically update UI
//     state = {...state, biographyId: !isCurrentlyLiked};

//     try {
//       final client = graphqlClient();

//       if (isCurrentlyLiked) {
//         // Unlike
//         await client.mutate(
//           MutationOptions(
//             document: gql("""
//               mutation UnlikeBiography(\$biography_id: uuid!, \$user_id: uuid!) {
//                 delete_biographylikes(where: {
//                   biography_id: {_eq: \$biography_id},
//                   user_id: {_eq: \$user_id}
//                 }) {
//                   affected_rows
//                 }
//               }
//             """),
//             variables: {
//               'biography_id': biographyId,
//               'user_id': userId,
//             },
//           ),
//         );

//         // Update like count
//         ref
//             .read(biographyLikeCountProvider.notifier)
//             .decrementLike(biographyId);
//       } else {
//         // Like
//         await client.mutate(
//           MutationOptions(
//             document: gql("""
//               mutation LikeBiography(\$biography_id: uuid!, \$user_id: uuid!) {
//                 insert_biographylikes_one(object: {
//                   biography_id: \$biography_id,
//                   user_id: \$user_id
//                 }) {
//                   id
//                 }
//               }
//             """),
//             variables: {
//               'biography_id': biographyId,
//               'user_id': userId,
//             },
//           ),
//         );

//         // Update like count
//         ref
//             .read(biographyLikeCountProvider.notifier)
//             .incrementLike(biographyId);
//       }
//     } catch (e) {
//       // Revert on error
//       state = {...state, biographyId: isCurrentlyLiked};
//       print("Error toggling like: $e");
//     }
//   }

//   // Check if a biography is liked
//   bool isLiked(String biographyId) {
//     return state[biographyId] ?? false;
//   }
// }

// // Provider for biography like status
// final biographyLikeProvider =
//     StateNotifierProvider<BiographyLikeNotifier, Map<String, bool>>((ref) {
//   return BiographyLikeNotifier(ref);
// });

// // Class to manage like counts
// class BiographyLikeCountNotifier extends StateNotifier<Map<String, int>> {
//   BiographyLikeCountNotifier() : super({});

//   void initializeLikeCount(String biographyId, int count) {
//     if (!state.containsKey(biographyId)) {
//       state = {...state, biographyId: count};
//     }
//   }

//   void incrementLike(String biographyId) {
//     final currentCount = state[biographyId] ?? 0;
//     state = {...state, biographyId: currentCount + 1};
//   }

//   void decrementLike(String biographyId) {
//     final currentCount = state[biographyId] ?? 0;
//     if (currentCount > 0) {
//       state = {...state, biographyId: currentCount - 1};
//     }
//   }

//   int getLikeCount(String biographyId) {
//     return state[biographyId] ?? 0;
//   }
// }

// // Provider for biography like counts
// final biographyLikeCountProvider =
//     StateNotifierProvider<BiographyLikeCountNotifier, Map<String, int>>((ref) {
//   return BiographyLikeCountNotifier();
// });
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/providers/auth_provider.dart';
import 'package:ethioconfess/graphql/graphql_client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

// Central repository for tracking liked biographies
class BiographyLikeNotifier extends StateNotifier<Map<String, bool>> {
  final Ref ref;

  BiographyLikeNotifier(this.ref) : super({});

  // Initialize likes for a specific biography
  Future<void> initializeLike(String biographyId) async {
    if (state.containsKey(biographyId)) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      final client = await ref.read(graphQLClientProvider);
      final result = await client.query(
        QueryOptions(
          document: gql("""
            query CheckUserLike(\$biography_id: uuid!, \$user_id: uuid!) {
              biographylikes(where: {
                biography_id: {_eq: \$biography_id}, 
                user_id: {_eq: \$user_id}
              }) {
                id
              }
            }
          """),
          variables: {
            'biography_id': biographyId,
            'user_id': userId,
          },
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final likes = result.data?['biographylikes'] as List?;
      final isLiked = likes?.isNotEmpty ?? false;

      state = {...state, biographyId: isLiked};
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      print("Error checking like status: ${appError.message}");
    }
  }

  // Toggle like status and update backend
  Future<void> toggleLike(String biographyId, int currentLikeCount) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final isCurrentlyLiked = state[biographyId] ?? false;
    final likeCountNotifier = ref.read(biographyLikeCountProvider.notifier);

    // Optimistically update UI for both like status and count
    state = {...state, biographyId: !isCurrentlyLiked};

    if (isCurrentlyLiked) {
      // Optimistically decrement count
      likeCountNotifier.decrementLike(biographyId);
    } else {
      // Optimistically increment count
      likeCountNotifier.incrementLike(biographyId);
    }

    try {
      final client = await ref.read(graphQLClientProvider);

      if (isCurrentlyLiked) {
        // Unlike
        await client.mutate(
          MutationOptions(
            document: gql("""
              mutation UnlikeBiography(\$biography_id: uuid!, \$user_id: uuid!) {
                delete_biographylikes(where: {
                  biography_id: {_eq: \$biography_id}, 
                  user_id: {_eq: \$user_id}
                }) {
                  affected_rows
                }
              }
            """),
            variables: {
              'biography_id': biographyId,
              'user_id': userId,
            },
          ),
        );
      } else {
        // Like
        await client.mutate(
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
              'biography_id': biographyId,
              'user_id': userId,
            },
          ),
        );
      }
    } catch (e, stackTrace) {
      // Revert on error
      state = {...state, biographyId: isCurrentlyLiked};
      if (isCurrentlyLiked) {
        likeCountNotifier.incrementLike(biographyId);
      } else {
        likeCountNotifier.decrementLike(biographyId);
      }
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      print("Error toggling like: ${appError.message}");
    }
  }

  // Check if a biography is liked
  bool isLiked(String biographyId) {
    return state[biographyId] ?? false;
  }
}

// Provider for biography like status
final biographyLikeProvider =
    StateNotifierProvider.autoDispose<BiographyLikeNotifier, Map<String, bool>>((ref) {
  return BiographyLikeNotifier(ref);
});

// Class to manage like counts
class BiographyLikeCountNotifier extends StateNotifier<Map<String, int>> {
  BiographyLikeCountNotifier() : super({});

  void initializeLikeCount(String biographyId, int count) {
    if (!state.containsKey(biographyId)) {
      state = {...state, biographyId: count};
    }
  }

  void incrementLike(String biographyId) {
    final currentCount = state[biographyId] ?? 0;
    state = {...state, biographyId: currentCount + 1};
  }

  void decrementLike(String biographyId) {
    final currentCount = state[biographyId] ?? 0;
    if (currentCount > 0) {
      state = {...state, biographyId: currentCount - 1};
    }
  }

  int getLikeCount(String biographyId) {
    return state[biographyId] ?? 0;
  }
}

// Provider for biography like counts
final biographyLikeCountProvider =
    StateNotifierProvider<BiographyLikeCountNotifier, Map<String, int>>((ref) {
  return BiographyLikeCountNotifier();
});
