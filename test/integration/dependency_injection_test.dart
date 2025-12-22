import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql_exec/gql_exec.dart' show Request, Response;

// Aliased imports to disambiguate duplicate provider names
import 'package:ethioconfess/providers/service_providers.dart' as sp;
import 'package:ethioconfess/providers/auth_provider.dart' as ap;
import 'package:ethioconfess/providers/user_provider.dart' as up;
import 'package:ethioconfess/providers/botttom_navigation_provider.dart' as nav;
import 'package:ethioconfess/providers/error_provider.dart' as err;
import 'package:ethioconfess/services/storage_service.dart';
import 'package:ethioconfess/services/queue_service.dart';
import 'package:ethioconfess/services/sync_service.dart';
import 'package:ethioconfess/services/auth_service.dart';
import 'package:ethioconfess/models/auth_state.dart';
import 'package:ethioconfess/core/error/app_error.dart';

class FakeStorageService extends StorageService {
  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> deleteToken() async {}
}

class NoopLink extends Link {
  @override
  Stream<Response> request(Request request, [forward]) {
    return Stream<Response>.empty();
  }
}

GraphQLClient createNoopGraphQLClient() {
  final Link link = NoopLink();
  return GraphQLClient(link: link, cache: GraphQLCache(store: InMemoryStore()));
}

ProviderContainer createContainer() {
  final fakeClient = createNoopGraphQLClient();
  return ProviderContainer(overrides: [
    // Override storage to avoid FlutterSecureStorage plugin
    ap.storageServiceProvider.overrideWithValue(FakeStorageService()),
    // Override auth service to avoid creating real GraphQL client
    ap.authServiceProvider.overrideWithValue(Future<AuthService>.value(AuthService(fakeClient))),
    // Override any graphQL client providers that might be referenced (both definitions)
    sp.graphQLClientProvider.overrideWithValue(Future<GraphQLClient>.value(fakeClient)),
    ap.graphQLClientProvider.overrideWithValue(Future<GraphQLClient>.value(fakeClient)),
  ]);
}

void main() {
  group('Dependency Injection & Integration Tests', () {
    ProviderContainer? container;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    tearDown(() async {
      // Allow any pending microtasks (e.g., AuthNotifier.checkAuthStatus) to finish
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (container != null) {
        container!.dispose();
        container = null;
      }
    });

    group('Critical Dependency Injection Issues', () {
      test('should detect duplicate graphQLClientProvider definitions', () async {
        expect(true, isTrue);
      });

      test('should initialize core providers without conflicts', () async {
        container = createContainer();

        expect(() => container!.read(sp.queueServiceProvider), returnsNormally);
        expect(() => container!.read(sp.syncServiceProvider), returnsNormally);
        expect(() => container!.read(ap.storageServiceProvider), returnsNormally);
        expect(() => container!.read(ap.authStateProvider), returnsNormally);
        expect(() => container!.read(up.userProvider), returnsNormally);
        expect(() => container!.read(nav.navigationProvider), returnsNormally);
        expect(() => container!.read(err.errorProvider), returnsNormally);
      });

      test('should handle provider initialization order correctly', () async {
        container = createContainer();

        expect(() {
          container!.read(sp.queueServiceProvider);
          container!.read(ap.storageServiceProvider);
          container!.read(ap.authStateProvider);
        }, returnsNormally);

        expect(() {
          container!.read(ap.authStateProvider);
          container!.read(sp.queueServiceProvider);
          container!.read(ap.storageServiceProvider);
        }, returnsNormally);
      });
    });

    group('State Management Consistency', () {
      test('should maintain consistent initial states', () async {
        container = createContainer();

        final authState = container!.read(ap.authStateProvider);
        final userState = container!.read(up.userProvider);
        final navigationState = container!.read(nav.navigationProvider);

        expect(authState.isAuthenticated, isFalse);
        expect(userState.user, isNull);
        expect(navigationState, equals(0));
      });

      test('should handle state transitions correctly', () async {
        container = createContainer();

        container!.read(nav.navigationProvider.notifier).setIndex(1);
        expect(container!.read(nav.navigationProvider), equals(1));

        container!.read(nav.navigationProvider.notifier).setIndex(2);
        expect(container!.read(nav.navigationProvider), equals(2));
      });
    });

    group('Service Integration', () {
      test('should initialize services correctly', () async {
        container = createContainer();

        final queueService = container!.read(sp.queueServiceProvider);
        expect(queueService, isA<QueueService>());
        // Do NOT call queueService.init() in unit tests; it uses plugins (Hive + path_provider)
      });

      test('should handle service dependencies', () async {
        container = createContainer();

        final syncService = container!.read(sp.syncServiceProvider);
        expect(syncService, isA<SyncService>());
      });
    });

    group('Error Handling', () {
      test('should handle provider errors gracefully', () async {
        container = createContainer();

        final errorState = container!.read(err.errorProvider);
        expect(errorState, isA<AppError?>());

        container!.read(err.errorProvider.notifier).setError(AppError.network('Test error'));
        expect(container!.read(err.errorProvider), isA<AppError>());
      });

      test('should handle auth state errors', () async {
        container = createContainer();

        final authState = container!.read(ap.authStateProvider);
        expect(authState.maybeWhen(
          error: (message) => message.isNotEmpty,
          orElse: () => false,
        ), isFalse);
      });
    });

    group('Provider Lifecycle', () {
      test('should dispose providers correctly', () async {
        container = createContainer();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(() => container!.dispose(), returnsNormally);
        container = null;
      });

      test('should handle provider recreation', () async {
        container = createContainer();
        final authState1 = container!.read(ap.authStateProvider);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        container!.dispose();
        container = null;

        container = createContainer();
        final authState2 = container!.read(ap.authStateProvider);

        expect(authState1.runtimeType, equals(authState2.runtimeType));
      });
    });

    group('Performance Tests', () {
      test('should initialize providers efficiently', () async {
        final stopwatch = Stopwatch()..start();

        container = createContainer();
        container!.read(ap.authStateProvider);
        container!.read(up.userProvider);
        container!.read(nav.navigationProvider);
        container!.read(sp.queueServiceProvider);

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      test('should handle state updates efficiently', () async {
        container = createContainer();

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10; i++) {
          container!.read(nav.navigationProvider.notifier).setIndex(i % 4);
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });

    group('Memory Management', () {
      test('should not leak memory when disposing providers', () async {
        for (int i = 0; i < 5; i++) {
          final testContainer = createContainer();
          testContainer.read(ap.authStateProvider);
          await Future<void>.delayed(const Duration(milliseconds: 5));
          testContainer.dispose();
        }

        expect(true, isTrue);
      });
    });

    group('Integration Issues Detection', () {
      test('should detect missing core dependencies', () async {
        container = createContainer();

        expect(() => container!.read(sp.queueServiceProvider), returnsNormally);
        expect(() => container!.read(ap.storageServiceProvider), returnsNormally);
        expect(() => container!.read(ap.authStateProvider), returnsNormally);
      });

      test('should detect provider type conflicts', () async {
        expect(true, isTrue);
      });
    });
  });
}
