import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metsnagna/widgets/auth_wrapper.dart';

void main() {
  group('AuthWrapper', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AuthWrapper(onLogout: () {}),
          ),
        ),
      );

      expect(find.byType(AuthWrapper), findsOneWidget);
    });
  });
} 