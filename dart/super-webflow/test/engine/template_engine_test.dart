// ignore_for_file: prefer_const_constructors, prefer_const_declarations
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_webflow/super_webflow.dart';

import '../helpers/base_document.dart';

void main() {
  testWidgets('builds minimal template without error', (tester) async {
    final doc = baseDocument();
    final ctx = DataContext(
      data: {
        'coach': {
          'fullName': 'Test Coach',
          'tagline': 'Test',
          'avatar': 'https://example.com/img.jpg',
        }
      },
      theme: doc.theme,
      breakpoint: Breakpoint.base,
    );
    final engine = TemplateEngine();
    final widget = engine.buildPage('home', doc, ctx);
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(child: widget),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('condition false hides node', (tester) async {
    final doc = baseDocument();
    final home = doc.pages['home']!;
    final conditionalNode = const ComponentNode(
      id: 'conditional',
      type: ComponentType.text,
      props: {'text': 'Visible only true'},
      condition: DataCondition(field: 'show', operator: '==', value: true),
    );
    final updated = doc.copyWith(
      pages: {
        ...doc.pages,
        'home': home.copyWith(children: [...?home.children, conditionalNode]),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TemplateRenderer(
          document: updated,
          data: const {'show': false},
          pageId: 'home',
        ),
      ),
    );

    expect(find.text('Visible only true'), findsNothing);
  });

  testWidgets('listField renders N children', (tester) async {
    final doc = baseDocument();
    final home = doc.pages['home']!;
    final updated = doc.copyWith(
      pages: {
        ...doc.pages,
        'home': home.copyWith(
          data: const DataBinding(listField: 'services', itemAlias: 'service'),
          children: const [ComponentNode(id: 'service-tpl', type: ComponentType.text, props: {'text': 'service'})],
        ),
      },
    );

    final ctx = DataContext(
      data: {
        'services': [1, 2, 3],
      },
      theme: updated.theme,
      breakpoint: Breakpoint.base,
    );

    final widget = TemplateEngine().buildPage('home', updated, ctx);
    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('service'), findsNWidgets(3));
  });
}

