import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Math Tests', () {
    test('should add two numbers correctly', () {
      // Arrange - Set up your test data
      int a = 5;
      int b = 3;
      
      // Act - Perform the action you want to test
      int result = a + b;
      
      // Assert - Check if the result is what you expect
      expect(result, equals(8));
    });

    test('should multiply two numbers correctly', () {
      // Arrange
      int a = 4;
      int b = 6;
      
      // Act
      int result = a * b;
      
      // Assert
      expect(result, equals(24));
    });
  });

  group('String Tests', () {
    test('should check if string contains text', () {
      // Arrange
      String message = "Hello World";
      
      // Act & Assert
      expect(message.contains("Hello"), isTrue);
      expect(message.contains("Goodbye"), isFalse);
    });
  });
} 