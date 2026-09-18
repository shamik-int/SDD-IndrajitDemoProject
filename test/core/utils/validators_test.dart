import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty value', () {
      expect(Validators.email(''), isNotNull);
    });

    test('rejects a malformed address', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('accepts a valid address', () {
      expect(Validators.email('person@intglobal.com'), isNull);
    });
  });

  group('Validators.phone', () {
    test('rejects empty value', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('rejects non-numeric input', () {
      expect(Validators.phone('abc123'), isNotNull);
    });

    test('accepts a valid number', () {
      expect(Validators.phone('+919876543210'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty value', () {
      expect(Validators.password(''), isNotNull);
    });

    test('rejects fewer than 8 characters', () {
      expect(Validators.password('ab1'), isNotNull);
    });

    test('rejects a password with no digit', () {
      expect(Validators.password('longenoughpassword'), isNotNull);
    });

    test('rejects a password with no letter', () {
      expect(Validators.password('12345678'), isNotNull);
    });

    test('accepts an 8-character password with a letter and a number', () {
      expect(Validators.password('abcd1234'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects null and whitespace-only input', () {
      expect(Validators.required(null, fieldName: 'Reason'), isNotNull);
      expect(Validators.required('   ', fieldName: 'Reason'), isNotNull);
    });

    test('accepts non-empty value', () {
      expect(Validators.required('Relocation'), isNull);
    });
  });
}
