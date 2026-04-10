import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class DividerComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final vertical = node.props?['vertical'] == true;
    return vertical ? const VerticalDivider() : const Divider();
  }
}
