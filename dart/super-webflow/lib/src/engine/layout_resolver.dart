import 'package:flutter/material.dart';

import '../models/layout_props.dart';

class LayoutResolver {
  Widget apply(List<Widget> children, LayoutProps? layout) {
    if (layout == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    final columns = layout.columns;
    if (columns != null) {
      return _grid(children, layout);
    }

    final direction = layout.direction;
    if (direction != null) {
      return _flex(children, layout, direction);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _withGap(children, layout.gap),
    );
  }

  Widget _grid(List<Widget> children, LayoutProps layout) {
    final columns = layout.columns;
    if (columns is int) {
      return GridView.count(
        crossAxisCount: columns,
        crossAxisSpacing: layout.columnGap ?? _gapX(layout.gap),
        mainAxisSpacing: layout.rowGap ?? _gapY(layout.gap),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
    }

    if (columns is String && columns.startsWith('auto-fill:')) {
      final parts = columns.split(':');
      final minWidth = (parts.length == 2 ? double.tryParse(parts[1]) : null) ??
          280;
      return Wrap(
        spacing: layout.columnGap ?? _gapX(layout.gap),
        runSpacing: layout.rowGap ?? _gapY(layout.gap),
        children: children
            .map(
              (c) => SizedBox(width: minWidth, child: c),
            )
            .toList(),
      );
    }

    return Wrap(
      spacing: layout.columnGap ?? _gapX(layout.gap),
      runSpacing: layout.rowGap ?? _gapY(layout.gap),
      children: children,
    );
  }

  Widget _flex(List<Widget> children, LayoutProps layout, String direction) {
    final withGap = _withGap(children, layout.gap);
    return switch (direction) {
      'row' => Row(children: withGap),
      'row-reverse' => Row(
          textDirection: TextDirection.rtl,
          children: withGap,
        ),
      'column-reverse' => Column(
          verticalDirection: VerticalDirection.up,
          children: withGap,
        ),
      _ => Column(children: withGap),
    };
  }

  List<Widget> _withGap(List<Widget> children, GapValue? gap) {
    if (children.length <= 1) {
      return children;
    }
    final spacing = _gapX(gap);
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i < children.length - 1) {
        out.add(SizedBox(width: spacing, height: spacing));
      }
    }
    return out;
  }

  double _gapX(GapValue? gap) {
    return switch (gap) {
      GapSingle(:final value) => value,
      GapPair(:final columnGap) => columnGap,
      _ => 0,
    };
  }

  double _gapY(GapValue? gap) {
    return switch (gap) {
      GapSingle(:final value) => value,
      GapPair(:final rowGap) => rowGap,
      _ => 0,
    };
  }
}
