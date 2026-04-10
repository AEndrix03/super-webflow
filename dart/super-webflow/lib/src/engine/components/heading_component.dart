import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../../models/theme.dart';
import '../data_context.dart';
import '../template_engine.dart';

class HeadingComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final level = (node.props?['level'] as num?)?.toInt() ?? 2;
    final text = (node.props?['text'] as String?) ?? '';
    return Text(
      text,
      style: engine.styleResolver.resolveTextStyle(node.style, ctx.theme).copyWith(
            fontSize: _levelSize(level, ctx.theme),
            fontWeight: FontWeight.w700,
          ),
    );
  }

  static double _levelSize(int level, ThemeSchema theme) => switch (level) {
        1 => theme.typography.scale.xl4,
        2 => theme.typography.scale.xl3,
        3 => theme.typography.scale.xl2,
        4 => theme.typography.scale.xl,
        _ => theme.typography.scale.lg,
      };
}
