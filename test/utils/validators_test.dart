import 'package:flutter_test/flutter_test.dart';
import 'package:ethioconfess/utils/validators.dart';

void main() {
  group('Validators', () {
    group('isValidEmail', () {
      test('should return true for valid email addresses', () {
        expect(isValidEmail('test@example.com'), true);
        expect(isValidEmail('user.name@domain.co.uk'), true);
        expect(isValidEmail('user+tag@example.org'), true);
        expect(isValidEmail('123@numbers.com'), true);
      });

      test('should return false for invalid email addresses', () {
        expect(isValidEmail('invalid-email'), false);
        expect(isValidEmail('@example.com'), false);
        expect(isValidEmail('user@'), false);
        expect(isValidEmail('user@.com'), false);
        expect(isValidEmail('user.example.com'), false);
        expect(isValidEmail(''), false);
        expect(isValidEmail('user name@example.com'), false);
      });
    });
  });
} 