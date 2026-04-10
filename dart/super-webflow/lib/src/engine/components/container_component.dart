import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class ContainerComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final width = (node.props?['width'] as num?)?.toDouble();
    final height = (node.props?['height'] as num?)?.toDouble();
    return SizedBox(width: width, height: height);
  }
}
