import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('required validator should catch null or empty strings', () {
      expect(Validators.required(null), 'This field is required');
      expect(Validators.required(''), 'This field is required');
      expect(Validators.required('   '), 'This field is required');
      expect(Validators.required('Stanford Lab'), isNull);
    });

    test('email validator should validate institutional emails', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('erostova@stanford.edu'), isNull);
      expect(Validators.email('mchen@mit.edu'), isNull);
    });

    test('password validator should enforce minimum length', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('Password123!'), isNull);
    });

    test('positiveNumber validator should validate positive numeric input', () {
      expect(Validators.positiveNumber('abc'), isNotNull);
      expect(Validators.positiveNumber('-10'), isNotNull);
      expect(Validators.positiveNumber('0'), isNull);
      expect(Validators.positiveNumber('450'), isNull);
      expect(Validators.positiveNumber('12.5'), isNull);
    });

    test('minLength validator should enforce minimum character threshold', () {
      expect(Validators.minLength('short', 10), isNotNull);
      expect(Validators.minLength('valid long description text here', 10), isNull);
    });
  });
}
