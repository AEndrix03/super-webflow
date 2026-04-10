import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class ImageComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final src = node.props?['src'] as String?;
    if (src == null || src.isEmpty) {
      return const SizedBox.shrink();
    }
    return Image.network(src, fit: BoxFit.cover);
  }
}
