import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethioconfess/providers/auth_provider.dart';
import '../graphql/biography_query.dart';
import '../graphql/graphql_client.dart';
import '../graphql/vent_mutation.dart';
import '../graphql/vent_query.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';
import '../models/vent.dart';
import '../services/queue_service.dart';
import 'service_providers.dart';
import 'package:hive/hive.dart';

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

final ventProvider = StateNotifierProvider.family<VentNotifier, AsyncValue<List<Vent>>, String?>((ref, categoryId) {
  return VentNotifier(ref, categoryId);
});

class VentNotifier extends StateNotifier<AsyncValue<List<Vent>>> {
  final Ref ref;
  final String? categoryId;
  
  VentNotifier(this.ref, this.categoryId) : super(const AsyncValue.loading()) {
    _initializeVents();
  }

  Future<void> _initializeVents() async {
    final connectivity = await Connectivity().checkConnectivity();
    final box = await Hive.openBox('ventCache');
    if (connectivity == ConnectivityResult.none) {
      // Offline: load from cache
      final cached = box.get('list');
      if (cached != null) {
        try {
          final vents = <Vent>[];
          for (final e in cached as List) {
            try {
              final vent = Vent.fromJson(Map<String, dynamic>.from(e));
              vents.add(vent);
            } catch (parseError) {
              print('Error parsing cached vent: $parseError');
              print('Cached vent data: $e');
              continue;
            }
          }
          if (vents.isNotEmpty) {
            state = AsyncValue.data(vents);
          } else {
            await box.delete('list'); // Clear corrupted cache
            state = AsyncValue.error('All cached vents are corrupted. Please reconnect to refresh.', StackTrace.current);
          }
          return;
        } catch (e, stackTrace) {
          print('Error parsing offline cache in _initializeVents:');
          print(e);
          print(stackTrace);
          await box.delete('list'); // Clear corrupted cache
          state = AsyncValue.error('Offline cache is corrupted. Please reconnect to refresh.', stackTrace);
          return;
        }
      } else {
        state = AsyncValue.error('No cached data available', StackTrace.current);
        return;
      }
    }
    try {
      if (categoryId == null) {
        await loadAllVents();
      } else {
        await loadVentsByCategory(categoryId!);
      }
    } catch (e, stackTrace) {
      print('Error in _initializeVents:');
      print(e);
      print(stackTrace);
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AsyncValue.error(appError, stackTrace);
    }
  }

  Future<void> loadAllVents() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final box = await Hive.openBox('ventCache');
      if (connectivity == ConnectivityResult.none) {
        // Offline: load from cache
        final cached = box.get('list');
        if (cached != null) {
                  try {
          final vents = <Vent>[];
          for (final e in cached as List) {
            try {
              final vent = Vent.fromJson(Map<String, dynamic>.from(e));
              vents.add(vent);
            } catch (parseError) {
              print('Error parsing cached vent: $parseError');
              print('Cached vent data: $e');
              continue;
            }
          }
          if (vents.isNotEmpty) {
            state = AsyncValue.data(vents);
          } else {
            await box.delete('list'); // Clear corrupted cache
            state = AsyncValue.error('All cached vents are corrupted. Please reconnect to refresh.', StackTrace.current);
          }
          return;
        } catch (e, stackTrace) {
          print('Error parsing offline cache in loadAllVents:');
          print(e);
          print(stackTrace);
          await box.delete('list'); // Clear corrupted cache
          state = AsyncValue.error('Offline cache is corrupted. Please reconnect to refresh.', stackTrace);
          return;
        }
        } else {
          state = AsyncValue.error('No cached data available', StackTrace.current);
          return;
        }
      }
      final currentState = state;
      List<Vent> optimisticVents = [];
      if (currentState is AsyncData<List<Vent>>) {
        optimisticVents = currentState.value.where((v) => v.id != null && v.id.toString().startsWith('temp-') || v.id == null).toList();
      }
      state = const AsyncValue.loading();
      final client = await ref.read(graphQLClientProvider);
      
      final result = await client.query(
        QueryOptions(
          document: gql(getAllVentsQuery),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: const {},
          onError: (error) {
            print('GraphQL onError in loadAllVents:');
            print(error);
            final appError = ErrorHandlerService.handleError(error);
            state = AsyncValue.error(appError, StackTrace.current);
          },
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
          errorPolicy: ErrorPolicy.all,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return client.query(
            QueryOptions(
              document: gql(getAllVentsQuery),
              fetchPolicy: FetchPolicy.networkOnly,
              variables: const {},
              errorPolicy: ErrorPolicy.all,
            ),
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Failed to load vents after retry. Please check your connection.'),
          );
        },
      );

      if (result.hasException) {
        print('GraphQL Exception in loadAllVents:');
        print(result.exception);
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final List<dynamic> ventsData = result.data?['vent'] ?? [];
      final vents = <Vent>[];
      for (final ventData in ventsData) {
        try {
          final vent = Vent.fromJson(ventData);
          vents.add(vent);
        } catch (e) {
          print('Error parsing vent data: $e');
          print('Vent data: $ventData');
          // Skip malformed vents instead of failing entirely
          continue;
        }
      }
      // Remove optimistic vents that are now present in backend data (by content and createdAt)
      optimisticVents = optimisticVents.where((optimistic) =>
        !vents.any((real) =>
          real.content == optimistic.content &&
          (real.createdAt?.difference(optimistic.createdAt ?? DateTime(1970)).inSeconds.abs() ?? 9999) < 60 // within 1 min
        )
      ).toList();
      final mergedVents = [...optimisticVents, ...vents];
      // Save to cache
      await box.put('list', mergedVents.map((e) => e.toJson()).toList());
      if (mounted) {
        state = AsyncValue.data(mergedVents);
      }
    } catch (e, stackTrace) {
      print('Error in loadAllVents:');
      print(e);
      print(stackTrace);
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      if (mounted) {
        state = AsyncValue.error(appError, stackTrace);
      }
    }
  }

  Future<void> loadVentsByCategory(String categoryId) async {
    try {
      final currentState = state;
      List<Vent> optimisticVents = [];
      if (currentState is AsyncData<List<Vent>>) {
        optimisticVents = currentState.value.where((v) => v.id != null && v.id.toString().startsWith('temp-') || v.id == null).toList();
      }
      state = const AsyncValue.loading();
      final client = await ref.read(graphQLClientProvider);
      
      final result = await client.query(
        QueryOptions(
          document: gql(getVentsByCategoryQuery),
          variables: {'categoryId': categoryId},
          fetchPolicy: FetchPolicy.networkOnly,
          cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
        ),
      );

      if (result.hasException) {
        print('result.hasException' + result.exception.toString());
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final List<dynamic> ventsData = result.data?['vent'] ?? [];
      final vents = <Vent>[];
      for (final ventData in ventsData) {
        try {
          final vent = Vent.fromJson(ventData);
          vents.add(vent);
        } catch (e) {
          print('Error parsing vent data: $e');
          print('Vent data: $ventData');
          // Skip malformed vents instead of failing entirely
          continue;
        }
      }
      
      if (mounted) {
        state = AsyncValue.data(vents);
      }
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      if (mounted) {
        state = AsyncValue.error(appError, stackTrace);
      }
    }
  }

  Future<void> refresh() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        // Offline: load from cache
        await loadAllVents();
        return;
      }
      if (categoryId == null) {
        await loadAllVents();
      } else {
        await loadVentsByCategory(categoryId!);
      }
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      if (mounted) {
        state = AsyncValue.error(appError, stackTrace);
      }
    }
  }
}

final ventDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, ventId) async {
  try {
    final client = await ref.read(graphQLClientProvider);

    final options = QueryOptions(
      document: gql(ventDetailQuery),
      variables: {'id': ventId},
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      cacheRereadPolicy: CacheRereadPolicy.mergeOptimistic,
    );
    final result = await client.query(options);

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    return result.data?['vent_by_pk'];
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final createVentProvider = FutureProvider.autoDispose
    .family<void, Map<String, String>>((ref, data) async {
  try {
    final client = await ref.read(graphQLClientProvider);
    final userId = ref.read(userIdProvider);

    if (userId == null) {
      throw AppError.authentication('User must be authenticated to create a vent');
    }

    final mutationVariables = {
      'objects': [
        {
          'category_id': data['category'],
          'content': data['content'],
        }
      ],
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(createVentMutation),
        variables: mutationVariables,
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final addReplyProvider = FutureProvider.autoDispose
    .family<void, Map<String, dynamic>>((ref, input) async {
  try {
    final client = await ref.read(graphQLClientProvider);
    final queueService = ref.watch(queueServiceProvider);
    final connectivityResult = await Connectivity().checkConnectivity();

    // If offline, queue the reply
    if (connectivityResult == ConnectivityResult.none) {
      await queueService.addReplyToQueue(
        input['vent_id'],
        input['user_id'],
        input['reply'],
      );
      return;
    }

    // If online, perform the reply action
    final result = await client.mutate(
      MutationOptions(
        document: gql(insertVentReplyMutation),
        variables: {
          'objects': [input],
        },
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final featuredbiographyProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final client = await ref.read(graphQLClientProvider);

    final result = await client.query(
      QueryOptions(
        document: gql(featuredBiographyQuery),
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    final biographies = (result.data?['featured_bios'] as List?)
            ?.map((bio) => bio as Map<String, dynamic>)
            .toList() ??
        [];

    return biographies;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});

final deleteReplyProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, replyId) async {
  try {
    final client = await ref.read(graphQLClientProvider);

    final result = await client.mutate(
      MutationOptions(
        document: gql("""
          mutation DeleteVentReply(\$id: uuid!) {
            delete_ventreplies(where: {id: {_eq: \$id}}) {
              affected_rows
              returning {
                id
                created_at
                reply
                updated_at
                user_id
                vent_id
              }
            }
          }
        """),
        variables: {'id': replyId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      throw ErrorHandlerService.handleError(result.exception!);
    }

    // Force a refresh of the vent detail data
    if (result.data != null) {
      final ventId = result.data!['delete_ventreplies']['returning'][0]['vent_id'];
      final client2 = await ref.read(graphQLClientProvider);
      await client2.query(
        QueryOptions(
          document: gql(ventDetailQuery),
          variables: {'id': ventId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
    }

    return (result.data?['delete_ventreplies']['affected_rows'] ?? 0) > 0;
  } catch (e, stackTrace) {
    final appError = ErrorHandlerService.handleError(e, stackTrace);
    throw appError;
  }
});
