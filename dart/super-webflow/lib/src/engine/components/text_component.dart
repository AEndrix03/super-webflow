import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class TextComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final text = (node.props?['text'] as String?) ?? '';
    return Text(
      text,
      style: engine.styleResolver.resolveTextStyle(node.style, ctx.theme),
    );
  }
}
