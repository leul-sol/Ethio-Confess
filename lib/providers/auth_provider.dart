import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:metsnagna/providers/vent_provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/auth_state.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';
import 'biography_providers.dart';
import 'botttom_navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../graphql/auth_mutation.dart';
import 'package:metsnagna/providers/conversation_providers.dart';
import 'package:metsnagna/providers/profile_provider.dart';
import 'package:metsnagna/providers/user_provider.dart';
import 'package:metsnagna/providers/chat_settings_provider.dart';
import 'package:metsnagna/providers/biography_providers.dart';
import 'package:metsnagna/providers/biography_like_provider.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/queue_service.dart';


final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

final authServiceProvider = Provider<Future<AuthService>>((ref) async {
  final client = await ref.watch(graphQLClientProvider);
  return AuthService(client);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authService, storageService, ref);
});

// Canonical provider for the current user ID, always set immediately after login
final currentUserIdProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends StateNotifier<AuthState> {
  final Future<AuthService> _authService;
  final StorageService _storageService;
  final Ref ref;

  AuthNotifier(this._authService, this._storageService, this.ref)
      : super(const AuthState.unauthenticated()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await _storageService.getToken();

      if (token == null) {
        return;
      }

      if (JwtDecoder.isExpired(token)) {
        await _storageService.deleteToken();
        state = const AuthState.unauthenticated();
        return;
      }

      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final String? userId =
          decodedToken['https://hasura.io/jwt/claims']?['x-hasura-user-id'];

      if (userId != null) {
        state = AuthState.authenticated(token: token, userId: userId);
        // Set currentUserIdProvider so user-specific features work after restart
        ref.read(currentUserIdProvider.notifier).state = userId;
      }
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AuthState.error(appError.message);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AuthState.loading();
      final authService = await _authService;
      final authState = await authService.login(email, password);

      await authState.maybeWhen(
        authenticated: (token, userId) async {
          await _storageService.saveToken(token);
          // Immediately update the canonical userId provider
          ref.read(currentUserIdProvider.notifier).state = userId;
          debugPrint('[AuthNotifier] Login successful, new userId: ' + userId);
          
          // Set authenticated state immediately
          state = AuthState.authenticated(token: token, userId: userId);
          
          // Do OneSignal operations in the background
          _handleOneSignalSetup(userId);
        },
        orElse: () async {},
      );

      // Only set state if it wasn't already set to authenticated
      if (!state.maybeWhen(
        authenticated: (token, userId) => true,
        orElse: () => false,
      )) {
        state = authState;
      }
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AuthState.error(appError.message);
    }
  }

  // Handle OneSignal setup in the background
  Future<void> _handleOneSignalSetup(String userId) async {
    try {
      // Prompt for notification permission after login
      final permissionGranted = await OneSignal.Notifications.requestPermission(true);

      String? playerId;

      if (permissionGranted) {
        playerId = OneSignal.User.pushSubscription.id;
        // Optionally, listen for changes if it's null
        if (playerId == null) {
          OneSignal.User.pushSubscription.addObserver((state) {
            final newPlayerId = state.current.id;
            debugPrint('Push Subscription ID changed: $newPlayerId');
            // Send newPlayerId to backend here if needed
          });
        }
      }
      
      if (playerId != null && playerId.isNotEmpty && userId.isNotEmpty) {
        final client = await ref.read(graphQLClientProvider);
        try {
          final result = await client.mutate(
            MutationOptions(
              document: gql(updateUserOneSignalIdMutation),
              variables: {
                'id': userId,
                'playerId': playerId,
              },
            ),
          );
          debugPrint('OneSignal player ID update result: ${result.data}');
          if (result.hasException) {
            debugPrint('OneSignal player ID update error: ${result.exception}');
          }
        } catch (e, stack) {
          debugPrint('Exception while updating OneSignal player ID: $e');
          debugPrint('$stack');
        }
      }
    } catch (e) {
      debugPrint('Error in OneSignal setup: $e');
      // Don't fail the login if OneSignal setup fails
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String phoneNo,
    required String username,
  }) async {
    try {
      print('=== AUTH PROVIDER SIGNUP START ===');
      print('Email: $email');
      print('Username: $username');
      print('Phone: $phoneNo');
      print('Password length: ${password.length}');
      
      state = const AuthState.loading();
      print('Auth state set to loading');
      
      final authService = await _authService;
      print('Auth service initialized');
      
      print('Calling authService.signup...');
      state = await authService.signup(
        email: email,
        password: password,
        phoneNo: phoneNo,
        username: username,
      );
      print('Auth service signup completed');
      print('Final state: $state');
      print('=== AUTH PROVIDER SIGNUP END ===');
    } catch (e, stackTrace) {
      print('=== AUTH PROVIDER SIGNUP ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AuthState.error(appError.message);
      print('Error state set: ${appError.message}');
      print('=== AUTH PROVIDER SIGNUP ERROR END ===');
    }
  }

  Future<void> requestResetCode(String email) async {
    try {
      state = const AuthState.loading();
      final authService = await _authService;
      final result = await authService.getResetCode(email);
      state = result;
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AuthState.error(appError.message);
    }
  }

  Future<void> verifyCode(String code, String email) async {
    try {
      state = const AuthState.loading();
      final authService = await _authService;
      final result = await authService.verifyCode(code, email);
      state = result;
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AuthState.error(appError.message);
    }
  }

  Future<void> resetPassword(
      String code, String email, String newPassword) async {
    try {
      state = const AuthState.loading();
      final authService = await _authService;
      final result = await authService.resetPassword(code, email, newPassword);
      state = result;
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AuthState.error(appError.message);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // state = const AuthState.loading();
      
      // Clear the stored token
    

      // Clear queue service boxes
      final queueService = QueueService();
      await queueService.init();
      await queueService.likeQueueBox.clear();
      await queueService.replyQueueBox.clear();
      await queueService.messageQueueBox.clear();

      // Clear SharedPreferences (if you store user-specific data)
      // (If you have app-wide preferences you want to keep, selectively remove only user keys)
      final prefs = await SharedPreferences.getInstance();
      // Only remove user-specific keys, not global app flags like onboarding
      await prefs.remove('user_token');
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('user_profile_image');
      // Add any other user-specific keys here

      // // Invalidate all user-related providers and data
      ref.invalidate(ventProvider);
      ref.invalidate(userVentsProvider);
      ref.invalidate(userBiographiesProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(navigationProvider);
      ref.invalidate(conversationListProvider); // Chat list
      ref.invalidate(profileStateProvider); // Profile state
      ref.invalidate(userProvider); // User info
      ref.invalidate(chatSettingsProvider); // Chat settings
      ref.invalidate(biographyProvider); // Biography list
      ref.invalidate(biographyLikeProvider); // Biography likes
      ref.invalidate(biographyLikeCountProvider); // Like counts
      // Invalidate any other user-specific providers here
      // ...
  await _storageService.deleteToken();

      // Clear Hive caches
      await Hive.boxExists('biographyCache').then((exists) async {
        if (exists) await Hive.box('biographyCache').clear();
      });
      await Hive.boxExists('ventCache').then((exists) async {
        if (exists) await Hive.box('ventCache').clear();
      });
      await Hive.boxExists('graphql_cache').then((exists) async {
        if (exists) await Hive.box('graphql_cache').clear();
      });
      // Update state to unauthenticated
      state = const AuthState.unauthenticated();
      debugPrint('[AuthNotifier] Logout: state set to unauthenticated');
      
      // // Remove loading dialog if it exists
      // if (context.mounted) {
      //   Navigator.of(context).popUntil((route) => route.isFirst);
      // }
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = AuthState.error(appError.message);
    }
  }

  // Helper getter to access userId
  String? get userId => state.maybeWhen(
        authenticated: (token, userId) => userId,
        orElse: () => null,
      );

  // Method to clear error states and return to unauthenticated
  void clearError() {
    state = const AuthState.unauthenticated();
  }
}

// Convenience provider for accessing userId
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider.notifier).userId;
});

// Removed currentUserIdProvider to avoid confusion and ensure a single source of truth for userId.

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  static AuthProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AuthProviderInherited>()!
        .provider;
  }

  // Removed duplicate isAuthenticated() method since we already have
  // the isAuthenticated getter above that serves the same purpose

  // Add your auth methods here
  Future<void> signIn() async {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    notifyListeners();
  }
}

class _AuthProviderInherited extends InheritedWidget {
  final AuthProvider provider;

  const _AuthProviderInherited({
    required this.provider,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_AuthProviderInherited oldWidget) => true;
}

class AuthProviderWidget extends StatelessWidget {
  final Widget child;
  final AuthProvider provider;

  const AuthProviderWidget({
    required this.child,
    required this.provider,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AuthProviderInherited(
      provider: provider,
      child: child,
    );
  }
}
