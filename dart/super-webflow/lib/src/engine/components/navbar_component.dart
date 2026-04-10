import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class NavbarComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final title = (node.props?['logoText'] as String?) ?? 'Super WebFlow';
    return AppBar(title: Text(title));
  }
}
