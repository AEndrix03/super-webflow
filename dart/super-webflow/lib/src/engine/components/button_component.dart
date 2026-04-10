import 'package:flutter/material.dart';

import '../../models/component_node.dart';
import '../data_context.dart';
import '../template_engine.dart';

class ButtonComponent {
  static Widget build(ComponentNode node, DataContext ctx, TemplateEngine engine) {
    final label = (node.props?['label'] as String?) ?? 'Button';
    final variant = (node.props?['variant'] as String?) ?? 'primary';

    return switch (variant) {
      'outline' => OutlinedButton(onPressed: () {}, child: Text(label)),
      'ghost' => TextButton(onPressed: () {}, child: Text(label)),
      'destructive' => FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor:
                engine.styleResolver.theme.parseCssColor(ctx.theme.colors.danger),
          ),
          child: Text(label),
        ),
      _ => FilledButton(onPressed: () {}, child: Text(label)),
    };
  }
}
