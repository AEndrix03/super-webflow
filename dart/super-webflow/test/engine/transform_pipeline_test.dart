import 'package:flutter_test/flutter_test.dart';

import 'package:super_webflow/src/engine/transform_pipeline.dart';

void main() {
  final pipeline = TransformPipeline();

  test('uppercase', () => expect(pipeline.applyOne('hello', 'uppercase'), 'HELLO'));
  test('truncate:5', () => expect(pipeline.applyOne('hello world', 'truncate:5'), 'hello…'));
  test('prefix:€', () => expect(pipeline.applyOne('100', 'prefix:€'), '€100'));
  test('count on list', () => expect(pipeline.applyOne([1, 2, 3], 'count'), '3'));
  test('first', () => expect(pipeline.applyOne(['a', 'b', 'c'], 'first'), 'a'));
  test('join:, ', () => expect(pipeline.applyOne(['a', 'b', 'c'], 'join:, '), 'a, b, c'));
  test('type mismatch returns input unchanged', () {
    expect(pipeline.applyOne(42, 'uppercase'), equals(42));
  });
  test('pipeline applies transforms in order', () {
    expect(pipeline.apply('hello world', ['uppercase', 'truncate:5']), 'HELLO…');
  });
}
