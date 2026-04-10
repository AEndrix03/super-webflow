import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class SpacerComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final size = (node.props?['size'] as num?)?.toDouble();
    if (size != null) {
      return SizedBox(height: size, width: size);
    }
    return const Spacer();
  }
}
