import 'package:flutter_test/flutter_test.dart';
import 'package:super_webflow/super_webflow.dart';

import '../helpers/base_document.dart';

void main() {
  final resolver = ThemeResolver();
  final theme = baseDocument().theme;

  test('token "primary" resolves to hex', () {
    final resolved = resolver.resolveColor('primary', theme);
    expect(resolved, equals(theme.colors.primary));
  });

  test('raw hex passes through unchanged', () {
    expect(resolver.resolveColor('#FF0000', theme), equals('#FF0000'));
  });

  test('unknown token passes through as raw', () {
    expect(resolver.resolveColor('notAToken', theme), equals('notAToken'));
  });
}
