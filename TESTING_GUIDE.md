# Testing Guide for Metsnagna App

## Overview

This guide outlines the testing strategy and implementation for the Metsnagna Flutter application. The app uses Riverpod for state management, GraphQL for API communication, and follows a clean architecture pattern.

## Testing Structure

### 1. Unit Tests (`test/`)

#### Services (`test/services/`)
- **auth_service_test.dart**: Tests for authentication logic
- **biography_service_test.dart**: Tests for biography-related operations
- **chat_service_test.dart**: Tests for chat functionality
- **storage_service_test.dart**: Tests for local storage operations

#### Utils (`test/utils/`)
- **validators_test.dart**: Tests for validation functions
- **time_duration_test.dart**: Tests for time formatting utilities
- **text_preview_test.dart**: Tests for text preview functionality

#### Models (`test/models/`)
- **auth_state_test.dart**: Tests for auth state management
- **user_model_test.dart**: Tests for user data models
- **vent_model_test.dart**: Tests for vent data models

#### Providers (`test/providers/`)
- **auth_provider_test.dart**: Tests for auth state management
- **biography_provider_test.dart**: Tests for biography state management
- **vent_provider_test.dart**: Tests for vent state management

### 2. Widget Tests (`test/widgets/`)

#### Core Widgets
- **auth_wrapper_test.dart**: Tests for authentication wrapper
- **error_widget_test.dart**: Tests for error handling widgets
- **loading_widget_test.dart**: Tests for loading states

#### Feature Widgets
- **biography_widget_test.dart**: Tests for biography display widgets
- **vent_widget_test.dart**: Tests for vent display widgets
- **chat_widget_test.dart**: Tests for chat interface widgets

### 3. Integration Tests (`test/integration/`)

- **auth_flow_test.dart**: End-to-end authentication flow
- **biography_flow_test.dart**: Complete biography creation and viewing flow
- **vent_flow_test.dart**: Complete vent creation and interaction flow

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Categories
```bash
# Unit tests only
flutter test test/services/
flutter test test/utils/
flutter test test/models/

# Widget tests only
flutter test test/widgets/

# Integration tests only
flutter test test/integration/
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Testing Best Practices

### 1. Unit Testing
- Test business logic in isolation
- Mock external dependencies (GraphQL, storage, etc.)
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

### 2. Widget Testing
- Test widget rendering and interactions
- Mock providers when needed
- Test error states and loading states
- Verify user interactions (taps, scrolls, etc.)

### 3. Integration Testing
- Test complete user flows
- Use real providers and services
- Test navigation between screens
- Verify data persistence

## Mocking Strategy

### GraphQL Client Mocking
```dart
@GenerateMocks([GraphQLClient])
class MockGraphQLClient extends Mock implements GraphQLClient {}

// Usage
final mockClient = MockGraphQLClient();
when(mockClient.mutate(any)).thenAnswer((_) async => mockResult);
```

### Provider Mocking
```dart
// Override providers for testing
final mockAuthProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return MockAuthNotifier();
});
```

### Storage Mocking
```dart
@GenerateMocks([StorageService])
class MockStorageService extends Mock implements StorageService {}

// Usage
final mockStorage = MockStorageService();
when(mockStorage.getToken()).thenAnswer((_) async => 'mock_token');
```

## Test Data

### Sample Test Data
```dart
// Create test data factories
class TestData {
  static User createTestUser() {
    return User(
      id: 'test_user_id',
      username: 'testuser',
      email: 'test@example.com',
    );
  }

  static Vent createTestVent() {
    return Vent(
      id: 'test_vent_id',
      title: 'Test Vent',
      content: 'Test content',
      userId: 'test_user_id',
    );
  }
}
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter build apk --debug
```

## Coverage Targets

- **Unit Tests**: 80%+ coverage for business logic
- **Widget Tests**: 70%+ coverage for UI components
- **Integration Tests**: 60%+ coverage for user flows

## Common Test Patterns

### Testing Async Operations
```dart
test('should handle async operation', () async {
  // Arrange
  final service = TestService();
  
  // Act
  final result = await service.performAsyncOperation();
  
  // Assert
  expect(result, isNotNull);
});
```

### Testing State Changes
```dart
test('should update state on action', () {
  // Arrange
  final notifier = TestNotifier();
  
  // Act
  notifier.performAction();
  
  // Assert
  expect(notifier.state, isA<ExpectedState>());
});
```

### Testing Widget Interactions
```dart
testWidgets('should respond to tap', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(TestWidget());
  
  // Act
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Assert
  expect(find.text('Updated'), findsOneWidget);
});
```

## Debugging Tests

### Common Issues
1. **Provider not found**: Wrap widgets with ProviderScope
2. **Async operations**: Use `await tester.pumpAndSettle()`
3. **Mock not working**: Ensure mocks are properly configured
4. **State not updating**: Check if providers are properly overridden

### Debug Commands
```bash
# Run tests with verbose output
flutter test --verbose

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run tests with coverage report
flutter test --coverage
```

## Next Steps

1. **Implement remaining unit tests** for all services
2. **Add widget tests** for all major UI components
3. **Create integration tests** for critical user flows
4. **Set up CI/CD** with automated testing
5. **Monitor test coverage** and maintain targets
6. **Add performance tests** for critical operations
7. **Implement accessibility tests** for UI components

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/testing)
- [GraphQL Testing Best Practices](https://graphql.org/learn/testing/)
- [Mockito Documentation](https://pub.dev/packages/mockito) 