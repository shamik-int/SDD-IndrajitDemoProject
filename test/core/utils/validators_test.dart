import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/utils/validators.dart';

void main() {
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
