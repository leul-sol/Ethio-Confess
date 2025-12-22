import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Test configuration and utilities
class TestConfig {
  /// Creates a test app with ProviderScope
  static Widget createTestApp(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// Creates a test app with custom theme
  static Widget createTestAppWithTheme(Widget child, ThemeData theme) {
    return ProviderScope(
      child: MaterialApp(
        theme: theme,
        home: child,
      ),
    );
  }
} 