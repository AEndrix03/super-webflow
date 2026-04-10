import 'package:flutter_test/flutter_test.dart';
import 'package:super_webflow/super_webflow.dart';

import '../helpers/base_document.dart';

void main() {
  final resolver = DataBindingResolver();
  final theme = baseDocument().theme;

  test('resolves simple path', () {
    final ctx = DataContext(
      data: {
        'coach': {'name': 'Mario'},
      },
      theme: theme,
      breakpoint: Breakpoint.base,
    );
    expect(resolver.resolvePath('coach.name', ctx), 'Mario');
  });

  test('resolves bracket notation', () {
    final ctx = DataContext(
      data: {
        'list': ['a', 'b', 'c'],
      },
      theme: theme,
      breakpoint: Breakpoint.base,
    );
    expect(resolver.resolvePath('list[1]', ctx), 'b');
  });

  test('missing path returns null without throwing', () {
    final ctx = DataContext(data: {}, theme: theme, breakpoint: Breakpoint.base);
    expect(resolver.resolvePath('coach.nonexistent', ctx), isNull);
  });
}
