import 'package:flutter_test/flutter_test.dart';
import 'package:metsnagna/models/auth_state.dart';

void main() {
  group('AuthState Model Tests', () {
    test('should return correct loading state', () {
      const state = AuthState.loading();
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('should return correct authenticated state', () {
      const state = AuthState.authenticated(
        token: 'mock_token',
        userId: 'user123',
      );
      expect(state.isLoading, false);
      expect(state.isAuthenticated, true);
    });

    test('should return correct unauthenticated state', () {
      const state = AuthState.unauthenticated();
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
    });

    test('should return correct error state', () {
      const state = AuthState.error('Test error message');
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
    });
  });
} 