import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethioconfess/graphql/graphql_client.dart';
import 'package:ethioconfess/models/category_enum.dart';
import 'package:ethioconfess/models/popular_entity.dart';
import 'package:ethioconfess/models/user.dart';
import 'package:ethioconfess/services/biography_page_services.dart';
import 'package:ethioconfess/services/queue_service.dart';
import 'package:ethioconfess/utils/biography_queries.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';
import 'auth_provider.dart';
import 'service_providers.dart';
import '../models/vent.dart';
import 'package:hive/hive.dart';

void main() {
  print('🚨🚨🚨 [biography_providers.dart] FILE LOADED! 🚨🚨🚨');
}

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  print('🚨🚨🚨 [graphQLClientProvider] PROVIDER DEFINED! 🚨🚨🚨');
  return graphqlClient();
});

// Provider for BiographyGraphQLService
final biographyGraphQLServiceProvider = Provider<Future<BiographyGraphQLService>>((ref) async {
  final client = await ref.watch(graphQLClientProvider);
  return BiographyGraphQLService(client);
});

final biographyProvider = FutureProvider<List<PopularEntity>>((ref) async {
  print('🚨🚨🚨 [biographyProvider] PROVIDER CALLED! 🚨🚨🚨');
  print('🔄 [biographyProvider] Starting to fetch biographies...');
  final connectivity = await Connectivity().checkConnectivity();
  final box = await Hive.openBox('biographyCache');
  if (connectivity == ConnectivityResult.none) {
    print('📱 [biographyProvider] Offline mode - loading from cache');
    // Offline: load from cache
    final cached = box.get('list');
    if (cached != null) {
      print('📱 [biographyProvider] Found cached data, loading ${cached.length} biographies');
      return (cached as List).map((e) => PopularEntity.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      print('📱 [biographyProvider] No cached data available');
      throw Exception('No cached data available');
    }
  } else {
    print('🌐 [biographyProvider] Online mode - fetching from network');
    // Online: fetch from network
    final service = await ref.watch(biographyGraphQLServiceProvider);
    try {
      final QueryOptions options = QueryOptions(
        fetchPolicy: FetchPolicy.networkOnly,
        document: gql(biographyQuery),
      );
      
      print('📡 [biographyProvider] Executing GraphQL query: ${biographyQuery}');
      final QueryResult result = await service.client.query(options);
      if (result.hasException) {
        print('❌ [biographyProvider] GraphQL exception: ${result.exception}');
        throw ErrorHandlerService.handleError(result.exception!);
      }
      
      print('✅ [biographyProvider] GraphQL query successful');
      print('📊 [biographyProvider] Raw GraphQL result: ${result.data}');
      
      final biographyData = result.data?['biography'];
      print('📚 [biographyProvider] Biography data array: $biographyData');
      print('📚 [biographyProvider] Biography data type: ${biographyData.runtimeType}');
      print('📚 [biographyProvider] Biography data length: ${biographyData?.length ?? 'null'}');

      if (biographyData != null && biographyData is List) {
        print('🔍 [biographyProvider] Processing ${biographyData.length} biographies...');
        
        for (int i = 0; i < biographyData.length; i++) {
          final bio = biographyData[i];
          print('📝 [biographyProvider] Biography $i:');
          print('   - Raw data: $bio');
          print('   - User data: ${bio['user']}');
          print('   - Profile image: ${bio['user']?['profile_image']}');
          print('   - Username: ${bio['user']?['username']}');
        }
      }

      final list = (result.data?['biography'] as List)
          .map((json) => PopularEntity.fromJson(json))
          .toList();
          
      print('🎯 [biographyProvider] Successfully parsed ${list.length} biographies');
      print('🎯 [biographyProvider] Final biography objects:');
      for (int i = 0; i < list.length; i++) {
        final bio = list[i];
        print('   - Biography $i: id=${bio.id}, username=${bio.username}, profileImage=${bio.profileImage}');
      }
      
      print('💾 [biographyProvider] Caching ${list.length} biographies');
      await box.put('list', list.map((e) => e.toJson()).toList());
      print('✅ [biographyProvider] Successfully cached biographies');
      
      return list;
    } catch (e, stackTrace) {
      print('❌ [biographyProvider] Error fetching biographies: $e');
      print('❌ [biographyProvider] Stack trace: $stackTrace');
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      throw appError;
    }
  }
});

// Provider for adding a new biography
final addBiographyProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  const int maxRetries = 2;
  int retryCount = 0;
  
  while (retryCount <= maxRetries) {
    try {
      final userId = ref.read(userIdProvider);

      if (userId == null) {
        throw AppError.authentication('User must be authenticated to add a biography');
      }

      final service = await ref.watch(biographyGraphQLServiceProvider);
      final MutationOptions options = MutationOptions(
        document: gql(addBiographyMutation),
        variables: {
          'content': params['content'].trim(),
        },
      );

      final QueryResult result = await service.client.mutate(options);

      if (result.hasException) {
        // Log the specific error for debugging
        print('Biography creation error (attempt ${retryCount + 1}): ${result.exception}');
        
        // Check if it's a timeout or network error that might be temporary
        final isTemporaryError = result.exception.toString().contains('timeout') ||
                                result.exception.toString().contains('network') ||
                                result.exception.toString().contains('connection');
        
        // If it's the last retry or not a temporary error, throw the error
        if (retryCount == maxRetries || !isTemporaryError) {
          throw ErrorHandlerService.handleError(result.exception!);
        }
        
        // Otherwise, increment retry count and try again
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount)); // Exponential backoff
        continue;
      }

      final insertedBiography = result.data?['insert_biography_one'];
      final success = insertedBiography != null;
      
      // Log success/failure for debugging
      print('Biography creation result (attempt ${retryCount + 1}): ${success ? 'SUCCESS' : 'FAILED'}');
      if (success) {
        print('Created biography ID: ${insertedBiography['id']}');
      }
      
      return success;
    } catch (e, stackTrace) {
      // Log the error for debugging
      print('Biography creation exception (attempt ${retryCount + 1}): $e');
      
      // Check if it's a timeout or network error that might be temporary
      final isTemporaryError = e.toString().contains('timeout') ||
                              e.toString().contains('network') ||
                              e.toString().contains('connection') ||
                              e.toString().contains('SocketException');
      
      // If it's the last retry or not a temporary error, throw the error
      if (retryCount == maxRetries || !isTemporaryError) {
        print('Stack trace: $stackTrace');
        final appError = ErrorHandlerService.handleError(e, stackTrace);
        throw appError;
      }
      
      // Otherwise, increment retry count and try again
      retryCount++;
      await Future.delayed(Duration(seconds: retryCount)); // Exponential backoff
    }
  }
  
  // This should never be reached, but just in case
  throw AppError.unknown('Failed to add biography after $maxRetries attempts');
});

// Provider to verify if a biography was actually created
final verifyBiographyCreationProvider = FutureProvider.family<bool, String>((ref, content) async {
  try {
    // Add a small delay to allow for server-side processing
    await Future.delayed(const Duration(milliseconds: 500));
    
    final userId = ref.read(userIdProvider);
    if (userId == null) return false;

    final client = await ref.watch(graphQLClientProvider);
    
    // Query for recent biographies by this user with the same content
    final result = await client.query(
      QueryOptions(
        document: gql("""
          query VerifyBiographyCreation(\$userId: uuid!, \$content: String!) {
            biography(
              where: {
                user_id: {_eq: \$userId},
                content: {_eq: \$content}
              },
              order_by: {created_at: desc},
              limit: 1
            ) {
              id
              created_at
            }
          }
        """),
        variables: {
          'userId': userId,
          'content': content,
        },
      ),
    );

    if (result.hasException) {
      print('Verification query error: ${result.exception}');
      return false;
    }

    final biographies = result.data?['biography'] as List?;
    if (biographies != null && biographies.isNotEmpty) {
      final latestBiography = biographies.first;
      final createdAt = DateTime.parse(latestBiography['created_at']);
      final now = DateTime.now();
      
      // Check if the biography was created within the last 5 minutes
      if (now.difference(createdAt).inMinutes <= 5) {
        print('Biography verification successful: ${latestBiography['id']}');
        return true;
      }
    }
    
    return false;
  } catch (e) {
    print('Biography verification error: $e');
    return false;
  }
});

// Provider for fetching likes count for a biography
final fetchLikesProvider = FutureProvider.family<int, String>((ref, biographyId) async {
  try {
    final service = await ref.watch(biographyGraphQLServiceProvider);

    final QueryOptions options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      document: gql(getBiographyLikesQuery),
      variables: {'biographyId': biographyId},
    );

    final QueryResult result = await service.client.query(options);

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data?['biographylikes_aggregate']['aggregate']['count'] ?? 0;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

// Provider for fetching top liked biographies
final fetchTopLikedBiographiesProvider = FutureProvider<List<PopularEntity>>((ref) async {
  print('🚨🚨🚨 [fetchTopLikedBiographiesProvider] PROVIDER CALLED! 🚨🚨🚨');
  print('🔄 [fetchTopLikedBiographiesProvider] Starting to fetch top liked biographies...');
  final client = await ref.watch(graphQLClientProvider);

  try {
    final options = QueryOptions(
      document: gql(getTopLikedBiographies),
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );

    print('📡 [fetchTopLikedBiographiesProvider] Executing GraphQL query: ${getTopLikedBiographies}');
    final result = await client.query(options);

    if (result.hasException) {
      print('❌ [fetchTopLikedBiographiesProvider] GraphQL exception: ${result.exception}');
      throw ErrorHandlerService.handleError(result.exception!);
    }

    print('✅ [fetchTopLikedBiographiesProvider] GraphQL query successful');
    print('📊 [fetchTopLikedBiographiesProvider] Raw GraphQL result: ${result.data}');
    
    final biographyData = result.data?['biography'];
    print('📚 [fetchTopLikedBiographiesProvider] Biography data array: $biographyData');
    print('📚 [fetchTopLikedBiographiesProvider] Biography data type: ${biographyData.runtimeType}');
    print('📚 [fetchTopLikedBiographiesProvider] Biography data length: ${biographyData?.length ?? 'null'}');

    if (biographyData != null && biographyData is List) {
      print('🔍 [fetchTopLikedBiographiesProvider] Processing ${biographyData.length} top biographies...');
      
      for (int i = 0; i < biographyData.length; i++) {
        final bio = biographyData[i];
        print('📝 [fetchTopLikedBiographiesProvider] Top Biography $i:');
        print('   - Raw data: $bio');
        print('   - User data: ${bio['user']}');
        print('   - Profile image: ${bio['user']?['profile_image']}');
        print('   - Username: ${bio['user']?['username']}');
      }
    }

    final biographies = (result.data?['biography'] as List)
        .map((json) => PopularEntity.fromJson(json))
        .toList();

    print('🎯 [fetchTopLikedBiographiesProvider] Successfully parsed ${biographies.length} top biographies');
    print('🎯 [fetchTopLikedBiographiesProvider] Final top biography objects:');
    for (int i = 0; i < biographies.length; i++) {
      final bio = biographies[i];
      print('   - Top Biography $i: id=${bio.id}, username=${bio.username}, profileImage=${bio.profileImage}');
    }

    print('✅ [fetchTopLikedBiographiesProvider] Returning ${biographies.length} top biographies');
    return biographies;
  } catch (e, stackTrace) {
    print('❌ [fetchTopLikedBiographiesProvider] Error fetching top biographies: $e');
    print('❌ [fetchTopLikedBiographiesProvider] Stack trace: $stackTrace');
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

// Provider for fetching vent posts by user ID
final fetchVentPostsProvider =
    FutureProvider.family<List<VentEntity>, String>((ref, userId) async {
  try {
    final service = await ref.watch(biographyGraphQLServiceProvider);

    final QueryOptions options = QueryOptions(
      document: gql(ventPostsQuery),
      variables: {'userid': userId},
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );

    final QueryResult result = await service.client.query(options);

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return (result.data?['vent'] as List)
        .map((json) => VentEntity.fromJson(json))
        .toList();
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

// Provider for fetching a popular entity by ID
final fetchPopularEntityByIdProvider =
    FutureProvider.family<PopularEntity, String>((ref, id) async {
  try {
    final service = await ref.watch(biographyGraphQLServiceProvider);

    final QueryOptions options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      document: gql(getPopularEntityByIdQuery),
      variables: {'id': id},
    );

    final QueryResult result = await service.client.query(options);

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    final data = result.data?['biography_by_pk'];

    if (data == null) {
      throw AppError.notFound('No data found for the provided ID');
    }

    return PopularEntity.fromJson(data);
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

// Provider for fetching user information by ID
final fetchUserInfoProvider =
    FutureProvider.family<User, String>((ref, id) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final String fetchUserInfoQuery = """
    query GetUserInfo(\$id: uuid!) {
      users_by_pk(id: \$id) {
        id
        username
        created_at
      }
    }
    """;

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(fetchUserInfoQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    final data = result.data?['users_by_pk'];
    if (data == null) {
      throw AppError.notFound('No user found for the provided ID');
    }

    return User.fromJson(data);
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final deleteVentProvider =
    FutureProvider.family<bool, String>((ref, ventId) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final result = await client.mutate(
      MutationOptions(
        document: gql("""
          mutation DeleteVent(\$id: uuid!) {
            delete_vent_by_pk(id: \$id) {
              id
            }
          }
        """),
        variables: {'id': ventId},
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data?['delete_vent_by_pk'] != null;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final deleteBiographyProvider =
    FutureProvider.family<bool, String>((ref, biographyId) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final result = await client.mutate(
      MutationOptions(
        document: gql("""
          mutation DeleteBiography(\$id: uuid!) {
            delete_biography_by_pk(id: \$id) {
              id
            }
          }
        """),
        variables: {'id': biographyId},
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data?['delete_biography_by_pk'] != null;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final updateVentProvider =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final result = await client.mutate(
      MutationOptions(
        document: gql(updateVentMutation),
        variables: {
          'id': params['id'],
          'content': params['content'],
        },
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data?['update_vent_by_pk'] != null;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final userProfileProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final result = await client.query(
      QueryOptions(
        document: gql(fetchUserProfileQuery),
        variables: {'userId': userId},
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data!['users_by_pk'];
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final userBiographiesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, userId) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final result = await client.query(
      QueryOptions(
        document: gql(fetchUserBiographiesQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      print('result.hasException' + result.exception.toString());
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return List<Map<String, dynamic>>.from(result.data!['biography']);
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

class UserVentsNotifier extends StateNotifier<AsyncValue<List<Vent>>> {
  final Ref ref;
  final String userId;
  UserVentsNotifier(this.ref, this.userId) : super(const AsyncValue.loading()) {
    fetchVents();
  }

  Future<void> fetchVents() async {
    try {
      final client = await ref.read(graphQLClientProvider);
      final result = await client.query(
        QueryOptions(
          document: gql(fetchUserVentsQuery),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }
      final vents = (result.data?['vent'] as List)
          .map((json) => Vent.fromJson(json))
          .toList();
      state = AsyncValue.data(vents);
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AsyncValue.error(appError, stackTrace);
    }
  }

  Future<void> deleteVent(String ventId) async {
    // Optimistically remove the vent
    state = state.whenData((vents) => vents.where((v) => v.id != ventId).toList());
    try {
      final client = await ref.read(graphQLClientProvider);
      final result = await client.mutate(
        MutationOptions(
          document: gql(deleteVentMutation),
          variables: {'ventId': ventId},
        ),
      );
      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }
      // Optionally, refresh from backend to ensure sync
      await fetchVents();
    } catch (e, stackTrace) {
      // Optionally, handle error and re-add the vent if needed
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AsyncValue.error(appError, stackTrace);
    }
  }
}

final userVentsProvider = StateNotifierProvider.family<UserVentsNotifier, AsyncValue<List<Vent>>, String>((ref, userId) {
  return UserVentsNotifier(ref, userId);
});

final updateBiographyProvider =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final result = await client.mutate(
      MutationOptions(
        document: gql("""
          mutation UpdateBiography(
            \$id: uuid!,
            \$content: String!,
            \$category: category!
          ) {
            update_biography_by_pk(
              pk_columns: {id: \$id},
              _set: {
                content: \$content,
                category: \$category,
                updated_at: "now()"
              }
            ) {
              id
              content
              category
              updated_at
            }
          }
        """),
        variables: {
          'id': params['id'],
          'content': params['content'],
          'category': params['category'],
        },
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data?['update_biography_by_pk'] != null;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

// State provider for like status
final likeStateProvider =
    StateProvider.family<bool, String>((ref, biographyId) => false);

// Check if user has liked the biography
final hasUserLikedProvider =
    FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

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
          'biography_id': params['biography_id'],
          'user_id': params['user_id'],
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    final likes = result.data?['biographylikes'] as List?;
    return likes?.isNotEmpty ?? false;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

// State provider for tracking like count
final likeCountProvider =
    StateProvider.family<int, PopularEntity>((ref, entity) {
  return entity.likeCount;
});

// Like a biography
final likeBiographyProvider =
    FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  try {
    final client = await ref.watch(graphQLClientProvider);
    final queueService = ref.watch(queueServiceProvider);
    final connectivityResult = await Connectivity().checkConnectivity();

    // If offline, queue the like action
    if (connectivityResult == ConnectivityResult.none) {
      await queueService.addLikeToQueue(
        params['biography_id']!,
        params['user_id']!,
      );
      return true;
    }

    // If online, perform the like action
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
          'biography_id': params['biography_id'],
          'user_id': params['user_id'],
        },
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data?['insert_biographylikes_one'] != null;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

// Unlike a biography
final unlikeBiographyProvider =
    FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  try {
    final client = await ref.watch(graphQLClientProvider);

    final result = await client.mutate(
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
          'biography_id': params['biography_id'],
          'user_id': params['user_id'],
        },
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return (result.data?['delete_biographylikes']['affected_rows'] ?? 0) > 0;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final allbiographyProvider =
    StateNotifierProvider<BiographyNotifier, AsyncValue<List<PopularEntity>>>(
        (ref) {
  return BiographyNotifier(ref);
});

class BiographyNotifier extends StateNotifier<AsyncValue<List<PopularEntity>>> {
  final Ref ref;

  BiographyNotifier(this.ref) : super(const AsyncValue.loading()) {
    print('🚨🚨🚨 [BiographyNotifier] CONSTRUCTOR CALLED! 🚨🚨🚨');
    loadBiographies();
  }

  void addBiographyOptimistically(PopularEntity newBio) {
    final current = state.value ?? [];
    state = AsyncValue.data([newBio, ...current]);
  }

  Future<void> loadBiographies() async {
    print('🚨🚨🚨 [BiographyNotifier] loadBiographies METHOD CALLED! 🚨🚨🚨');
    try {
      print('🔄 [BiographyNotifier] Starting to load biographies...');
      state = const AsyncValue.loading();
      final client = await ref.watch(graphQLClientProvider);

      final QueryOptions options = QueryOptions(
        fetchPolicy: FetchPolicy.networkOnly, // Force network fetch for debugging
        document: gql(biographyQuery),
      );

      print('📡 [BiographyNotifier] Executing GraphQL query: ${biographyQuery}');
      final result = await client.query(options);

      if (result.hasException) {
        print('❌ [BiographyNotifier] GraphQL exception: ${result.exception}');
        throw ErrorHandlerService.handleError(result.exception!);
      }

      print('✅ [BiographyNotifier] GraphQL query successful');
      print('📊 [BiographyNotifier] Raw GraphQL result: ${result.data}');
      
      final biographyData = result.data?['biography'];
      print('📚 [BiographyNotifier] Biography data array: $biographyData');
      print('📚 [BiographyNotifier] Biography data type: ${biographyData.runtimeType}');
      print('📚 [BiographyNotifier] Biography data length: ${biographyData?.length ?? 'null'}');

      if (biographyData != null && biographyData is List) {
        print('🔍 [BiographyNotifier] Processing ${biographyData.length} biographies...');
        
        for (int i = 0; i < biographyData.length; i++) {
          final bio = biographyData[i];
          print('📝 [BiographyNotifier] Biography $i:');
          print('   - Raw data: $bio');
          print('   - User data: ${bio['user']}');
          print('   - Profile image: ${bio['user']?['profile_image']}');
          print('   - Username: ${bio['user']?['username']}');
        }
      }

      final biographies = (result.data?['biography'] as List)
          .map((json) => PopularEntity.fromJson(json))
          .toList();

      print('🎯 [BiographyNotifier] Successfully parsed ${biographies.length} biographies');
      print('🎯 [BiographyNotifier] Final biography objects:');
      for (int i = 0; i < biographies.length; i++) {
        final bio = biographies[i];
        print('   - Biography $i: id=${bio.id}, username=${bio.username}, profileImage=${bio.profileImage}');
      }

      state = AsyncValue.data(biographies);
      print('✅ [BiographyNotifier] State updated with ${biographies.length} biographies');
    } catch (e, stackTrace) {
      print('❌ [BiographyNotifier] Error loading biographies: $e');
      print('❌ [BiographyNotifier] Stack trace: $stackTrace');
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AsyncValue.error(appError, stackTrace);
    }
  }
}
