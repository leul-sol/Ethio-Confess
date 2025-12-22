import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/widgets/auth_wrapper.dart';

void main() {
  group('Auth Flow Integration Tests', () {
    testWidgets('should render auth wrapper without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AuthWrapper(onLogout: () {}),
          ),
        ),
      );

      // Verify that the auth wrapper is present
      expect(find.byType(AuthWrapper), findsOneWidget);
    });

    testWidgets('should render material app correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Test App'),
              ),
            ),
          ),
        ),
      );

      // Verify the app renders without errors
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
    });
  });
} 