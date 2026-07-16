import 'package:flutter_test/flutter_test.dart';

import 'package:goexperts_app/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('compactCurrency abbreviates large amounts', () {
      expect(Formatters.compactCurrency(1500), '\u20B91.5K');
      expect(Formatters.compactCurrency(250000), '\u20B92.5L');
      expect(Formatters.compactCurrency(20000000), '\u20B92Cr');
    });

    test('initials handles single and multi-word names', () {
      expect(Formatters.initials('Aarav'), 'A');
      expect(Formatters.initials('Priya Nair'), 'PN');
    });
  });
}
