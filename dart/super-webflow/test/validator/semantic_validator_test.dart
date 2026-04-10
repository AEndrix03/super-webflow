// ignore_for_file: prefer_const_constructors, prefer_const_declarations
import 'package:flutter_test/flutter_test.dart';
import 'package:super_webflow/super_webflow.dart';

import '../helpers/base_document.dart';

void main() {
  group('R01 — unique IDs', () {
    test('unique IDs pass', () {
      final result = Validator().validateDocument(baseDocument());
      expect(result.errors.where((e) => e.rule == 'R01'), isEmpty);
    });

    test('duplicate ID in same page fails', () {
      final doc = baseDocument();
      final home = doc.pages['home']!;
      final dup = const ComponentNode(id: 'child-a', type: ComponentType.text);
      final updated = doc.copyWith(
        pages: {
          ...doc.pages,
          'home': home.copyWith(children: [...?home.children, dup]),
        },
      );
      final result = Validator().validateDocument(updated);
      expect(result.errors.where((e) => e.rule == 'R01'), isNotEmpty);
    });

    test('duplicate ID across pages fails', () {
      final doc = baseDocument();
      final updated = doc.copyWith(
        pages: {
          ...doc.pages,
          'about': const ComponentNode(id: 'home-root', type: ComponentType.container),
        },
      );
      final result = Validator().validateDocument(updated);
      expect(result.errors.where((e) => e.rule == 'R01'), isNotEmpty);
    });

    test('duplicate ID between page and global fails', () {
      final doc = baseDocument();
      final updated = doc.copyWith(
        globals: const TemplateGlobals(
          navbar: ComponentNode(id: 'home-root', type: ComponentType.navbar),
          footer: ComponentNode(id: 'global-footer', type: ComponentType.footer),
        ),
      );
      final result = Validator().validateDocument(updated);
      expect(result.errors.where((e) => e.rule == 'R01'), isNotEmpty);
    });
  });

  group('R03 — listField requires children', () {
    test('listField with children passes', () {
      final doc = baseDocument();
      final home = doc.pages['home']!;
      final updated = doc.copyWith(
        pages: {
          ...doc.pages,
          'home': home.copyWith(
            data: const DataBinding(listField: 'coach.services', itemAlias: 'service'),
            children: const [ComponentNode(id: 'svc', type: ComponentType.text)],
          ),
        },
      );
      final result = Validator().validateDocument(updated);
      expect(result.errors.where((e) => e.rule == 'R03'), isEmpty);
    });

    test('listField without children fails', () {
      final doc = baseDocument();
      final home = doc.pages['home']!;
      final updated = doc.copyWith(
        pages: {
          ...doc.pages,
          'home': home.copyWith(
            data: const DataBinding(listField: 'coach.services'),
            children: const [],
          ),
        },
      );
      final result = Validator().validateDocument(updated);
      expect(result.errors.where((e) => e.rule == 'R03'), isNotEmpty);
    });
  });
}

