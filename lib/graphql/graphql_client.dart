import 'dart:io';
import 'package:http/io_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

final StorageService _storageService = StorageService();

Future<GraphQLClient> graphqlClient() async {
  // Initialize Hive for persistent storage
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Create a Hive box for the cache with proper typing
  final cacheBox = await Hive.openBox<Map<dynamic, dynamic>>('graphql_cache');

  // Get the base URL from environment variables
  final baseUrl = dotenv.env['HTTP_URL'] ?? '';
  if (baseUrl.isEmpty) {
    developer.log('ERROR: HTTP_URL environment variable is not set');
    throw Exception('HTTP_URL environment variable is not set');
  }
  
  developer.log('Initializing GraphQL client with base URL: $baseUrl');

  final _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30)
    ..idleTimeout = const Duration(seconds: 30);
  
  final _ioClient = IOClient(_httpClient);

  // Convert HTTP URL to WebSocket URL for Hasura
  final wsUrl = baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');

  developer.log('Using WebSocket URL: $wsUrl');
  developer.log('Using HTTP URL: $baseUrl');

  // Create WebSocket link for subscriptions with error handling
  final WebSocketLink wsLink = WebSocketLink(
    wsUrl,
    config: SocketClientConfig(
      autoReconnect: true,
      delayBetweenReconnectionAttempts: const Duration(seconds: 5),
      inactivityTimeout: const Duration(seconds: 30),
      initialPayload: () async {
        try {
          final token = await _storageService.getToken();
          developer.log('WebSocket connection attempt with token: ${token != null ? 'Token exists' : 'No token'}');
          return {
            'headers': {
              if (token != null) 'Authorization': 'Bearer $token',
            },
          };
        } catch (e) {
          developer.log('Error getting token for WebSocket:', error: e);
          return {'headers': {}};
        }
      },
    ),
  );

  // Create HTTP link for queries and mutations with error handling
  final HttpLink httpLink = HttpLink(
    baseUrl,
    httpClient: _ioClient,
    defaultHeaders: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  // Create auth link for authenticated queries with error handling
  final Link authLink = AuthLink(
    getToken: () async {
      try {
        final token = await _storageService.getToken();
        developer.log('Token for GraphQL request: ${token != null ? 'Token exists' : 'No token'}');
        return token != null ? 'Bearer $token' : null;
      } catch (e) {
        developer.log('Error getting token for HTTP request:', error: e);
        return null;
      }
    },
  );

  // Create error handling link
  final Link errorLink = Link.function((request, [forward]) async* {
    try {
      yield* forward!(request);
    } catch (e) {
      developer.log('Error in GraphQL request:', error: e);
      rethrow;
    }
  });

  // Create a link that adds auth headers to both HTTP and WebSocket connections
  final Link authHeadersLink = Link.function((request, [forward]) async* {
    try {
      final token = await _storageService.getToken();
      final updatedRequest = request.updateContextEntry<HttpLinkHeaders>(
        (headers) => HttpLinkHeaders(
          headers: {
            ...headers?.headers ?? {},
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      yield* forward!(updatedRequest);
    } catch (e) {
      developer.log('Error in authHeadersLink: $e');
      yield* forward!(request);
    }
  });

  // Split the links based on operation type and add auth headers
  final Link link = Link.split(
    (request) => request.isSubscription,
    errorLink.concat(authHeadersLink).concat(wsLink),
    errorLink.concat(authLink).concat(httpLink),
  );

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(
      store: HiveStore(cacheBox),
    ),
    defaultPolicies: DefaultPolicies(
      query: Policies(
        fetch: FetchPolicy.cacheAndNetwork,
        error: ErrorPolicy.all,
        cacheReread: CacheRereadPolicy.mergeOptimistic,
      ),
      mutate: Policies(
        fetch: FetchPolicy.cacheAndNetwork,
        error: ErrorPolicy.all,
        cacheReread: CacheRereadPolicy.mergeOptimistic,
      ),
      subscribe: Policies(
        fetch: FetchPolicy.cacheAndNetwork,
        error: ErrorPolicy.all,
        cacheReread: CacheRereadPolicy.mergeOptimistic,
      ),
    ),
  );
}
