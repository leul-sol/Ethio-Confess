import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/queue_service.dart';
import '../services/sync_service.dart';
import '../graphql/graphql_client.dart';

final queueServiceProvider = Provider<QueueService>((ref) {
  return QueueService();
});

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final queueService = ref.watch(queueServiceProvider);
  final clientFuture = ref.watch(graphQLClientProvider);
  return SyncService(ref.container, queueService, clientFuture);
}); 