import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_webflow/super_webflow.dart';

void main() {
  group('SchemaValidator', () {
    test('minimal.json passes', () {
      final json = File('test/fixtures/minimal.json').readAsStringSync();
      final result = Validator().validateJson(json);
      expect(result.valid, isTrue);
    });

    test('coach_landing.json passes', () {
      final json = File('test/fixtures/coach_landing.json').readAsStringSync();
      final result = Validator().validateJson(json);
      expect(result.valid, isTrue);
    });

    test('wrong schema URL fails', () {
      final map = jsonDecode(File('test/fixtures/minimal.json').readAsStringSync())
          as Map<String, dynamic>;
      map[r'$schema'] = 'https://example.com/wrong.json';
      final doc = TemplateDocument.fromJson(map);
      final errors = SchemaValidator().validate(doc);
      expect(errors.any((e) => e.path == '/\$schema'), isTrue);
    });

    test('version != 1.0 fails', () {
      final map = jsonDecode(File('test/fixtures/minimal.json').readAsStringSync())
          as Map<String, dynamic>;
      map['version'] = '2.0';
      final doc = TemplateDocument.fromJson(map);
      final errors = SchemaValidator().validate(doc);
      expect(errors.any((e) => e.path == '/version'), isTrue);
    });

    test('id with uppercase fails', () {
      final map = jsonDecode(File('test/fixtures/minimal.json').readAsStringSync())
          as Map<String, dynamic>;
      map['id'] = 'Bad-ID';
      final doc = TemplateDocument.fromJson(map);
      final errors = SchemaValidator().validate(doc);
      expect(errors.any((e) => e.path == '/id'), isTrue);
    });

    test('missing pages.home fails', () {
      final map = jsonDecode(File('test/fixtures/minimal.json').readAsStringSync())
          as Map<String, dynamic>;
      final pages = map['pages'] as Map<String, dynamic>;
      pages.remove('home');
      final doc = TemplateDocument.fromJson(map);
      final errors = SchemaValidator().validate(doc);
      expect(errors.any((e) => e.rule == 'R07'), isTrue);
    });
  });
}
