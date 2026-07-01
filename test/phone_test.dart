import 'package:dcpl_shared/dcpl_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizePhone', () {
    test('prepends 91 to a bare 10-digit number', () {
      expect(normalizePhone('9876543210'), '919876543210');
    });

    test('strips formatting before normalizing', () {
      expect(normalizePhone('+91 98765-43210'), '919876543210');
      expect(normalizePhone('(987) 654 3210'), '919876543210');
    });

    test('keeps a 12-digit number already starting with 91', () {
      expect(normalizePhone('919876543210'), '919876543210');
    });

    test('returns null for the wrong number of digits', () {
      expect(normalizePhone('12345'), isNull);
      expect(normalizePhone('98765432100'), isNull); // 11 digits
      expect(normalizePhone(''), isNull);
    });

    test('returns null for a 12-digit number not starting with 91', () {
      expect(normalizePhone('929876543210'), isNull);
    });
  });

  group('syntheticEmailForPhone', () {
    test('builds the synthetic email from the normalized phone', () {
      expect(
        syntheticEmailForPhone('9876543210'),
        '919876543210@phone.dcpl-interiors.app',
      );
    });

    test('returns null when the phone is invalid', () {
      expect(syntheticEmailForPhone('12345'), isNull);
    });
  });

  group('formatPhone', () {
    test('formats a normalized 12-digit number', () {
      expect(formatPhone('919876543210'), '+91 98765 43210');
    });

    test('formats a bare 10-digit number', () {
      expect(formatPhone('9876543210'), '+91 98765 43210');
    });

    test('returns the input unchanged when unrecognizable', () {
      expect(formatPhone('12345'), '12345');
    });
  });
}
