import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class FooterComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final text =
        (node.props?['copyrightText'] as String?) ?? '© ${DateTime.now().year}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
