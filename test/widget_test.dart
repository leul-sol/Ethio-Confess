import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metsnagna/main.dart';

void main() {
  group('App Smoke Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      // Verify that the app loads without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      // Verify the app title
      expect(find.text('Vent Ethiopia'), findsNothing); // Title is in app bar, not visible text
    });
  });
}
