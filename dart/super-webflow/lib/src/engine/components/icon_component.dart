import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class IconComponent {
  static const _map = <String, IconData>{
    'arrow-right': Icons.arrow_forward,
    'star': Icons.star,
    'check': Icons.check,
    'send': Icons.send,
  };

  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final name = (node.props?['name'] as String?) ?? 'star';
    return Icon(_map[name] ?? Icons.help_outline);
  }
}
