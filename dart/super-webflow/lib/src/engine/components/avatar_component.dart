import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class AvatarComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final src = node.props?['src'] as String?;
    final size = (node.props?['size'] as num?)?.toDouble() ?? 40;
    final initials = (node.props?['initials'] as String?) ?? '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: src != null && src.isNotEmpty ? NetworkImage(src) : null,
      child: src == null || src.isEmpty ? Text(initials) : null,
    );
  }
}
