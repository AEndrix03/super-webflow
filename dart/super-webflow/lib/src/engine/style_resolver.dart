import 'package:flutter/material.dart';

import '../models/primitives.dart';
import '../models/style_props.dart';
import '../models/theme.dart';
import 'theme_resolver.dart';

class StyleResolver {
  final ThemeResolver theme;

  StyleResolver(this.theme);

  Widget wrap(Widget child, StyleProps? style, ThemeSchema themeSchema) {
    if (style == null) {
      return child;
    }
    final margin = resolveMargin(style);
    final padding = resolvePadding(style);
    final decoration = resolveDecoration(style, themeSchema);

    Widget result = Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    final overlay = style.backgroundOverlay;
    if (overlay != null) {
      result = Stack(
        fit: StackFit.passthrough,
        children: [
          result,
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: theme.parseCssColor(
                  theme.resolveColor(overlay, themeSchema),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return result;
  }

  EdgeInsetsGeometry resolvePadding(StyleProps? style) {
    if (style == null) {
      return EdgeInsets.zero;
    }

    var top = 0.0;
    var right = 0.0;
    var bottom = 0.0;
    var left = 0.0;

    final base = style.padding;
    switch (base) {
      case SpacingAll(:final value):
        top = right = bottom = left = value;
      case SpacingAxes(:final v, :final h):
        top = bottom = v;
        left = right = h;
      case SpacingFour(:final t, :final r, :final b, :final l):
        top = t;
        right = r;
        bottom = b;
        left = l;
      case SpacingExplicit():
        top = base.top;
        right = base.right;
        bottom = base.bottom;
        left = base.left;
      case null:
        break;
    }

    if (style.paddingX != null) {
      left = style.paddingX!;
      right = style.paddingX!;
    }
    if (style.paddingY != null) {
      top = style.paddingY!;
      bottom = style.paddingY!;
    }
    if (style.paddingTop != null) {
      top = style.paddingTop!;
    }
    if (style.paddingRight != null) {
      right = style.paddingRight!;
    }
    if (style.paddingBottom != null) {
      bottom = style.paddingBottom!;
    }
    if (style.paddingLeft != null) {
      left = style.paddingLeft!;
    }

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  EdgeInsetsGeometry resolveMargin(StyleProps? style) {
    if (style == null) {
      return EdgeInsets.zero;
    }
    var top = 0.0;
    var right = 0.0;
    var bottom = 0.0;
    var left = 0.0;

    final base = style.margin;
    switch (base) {
      case SpacingAll(:final value):
        top = right = bottom = left = value;
      case SpacingAxes(:final v, :final h):
        top = bottom = v;
        left = right = h;
      case SpacingFour(:final t, :final r, :final b, :final l):
        top = t;
        right = r;
        bottom = b;
        left = l;
      case SpacingExplicit():
        top = base.top;
        right = base.right;
        bottom = base.bottom;
        left = base.left;
      case null:
        break;
    }

    if (style.marginX != null) {
      left = style.marginX!;
      right = style.marginX!;
    }
    if (style.marginY != null) {
      top = style.marginY!;
      bottom = style.marginY!;
    }
    if (style.marginTop != null) {
      top = style.marginTop!;
    }
    if (style.marginRight != null) {
      right = style.marginRight!;
    }
    if (style.marginBottom != null) {
      bottom = style.marginBottom!;
    }
    if (style.marginLeft != null) {
      left = style.marginLeft!;
    }

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  BoxDecoration? resolveDecoration(StyleProps? style, ThemeSchema themeSchema) {
    if (style == null) {
      return null;
    }
    final bg = style.backgroundColor;
    final border = style.border;
    BorderRadius? radius;
    final br = style.borderRadius;
    if (br is BorderRadiusSingle) {
      radius = BorderRadius.circular(br.value);
    } else if (br is BorderRadiusFour) {
      final v = br.values;
      if (v.length == 4) {
        radius = BorderRadius.only(
          topLeft: Radius.circular(v[0]),
          topRight: Radius.circular(v[1]),
          bottomRight: Radius.circular(v[2]),
          bottomLeft: Radius.circular(v[3]),
        );
      }
    }

    return BoxDecoration(
      color: bg != null
          ? theme.parseCssColor(theme.resolveColor(bg, themeSchema))
          : null,
      border: border != null
          ? Border.all(
              width: border.width,
              color: theme.parseCssColor(
                theme.resolveColor(border.color, themeSchema),
              ),
            )
          : null,
      borderRadius: radius,
      boxShadow: theme.resolveShadow(style.shadow, themeSchema),
      image: style.backgroundImage != null
          ? DecorationImage(
              image: NetworkImage(style.backgroundImage!),
              fit: BoxFit.cover,
            )
          : null,
    );
  }

  TextStyle resolveTextStyle(StyleProps? style, ThemeSchema themeSchema) {
    final s = style;
    if (s == null) {
      return TextStyle(
        color: theme.parseCssColor(themeSchema.colors.text),
        fontSize: themeSchema.typography.scale.base,
        fontFamily: themeSchema.typography.fonts.body,
      );
    }

    String? resolveFamily(String? family) {
      return switch (family) {
        null => themeSchema.typography.fonts.body,
        'heading' => themeSchema.typography.fonts.heading,
        'body' => themeSchema.typography.fonts.body,
        'mono' => themeSchema.typography.fonts.mono ?? 'monospace',
        _ => family,
      };
    }

    FontWeight? resolveWeight(Object? fw) {
      if (fw is num) {
        return FontWeight.values[(fw.toInt() ~/ 100).clamp(1, 9) - 1];
      }
      if (fw == 'bold') {
        return FontWeight.w700;
      }
      return FontWeight.normal;
    }

    return TextStyle(
      color: s.color != null
          ? theme.parseCssColor(theme.resolveColor(s.color, themeSchema))
          : null,
      fontSize: theme.resolveFontSize(s.fontSize, themeSchema),
      fontFamily: resolveFamily(s.fontFamily),
      fontWeight: resolveWeight(s.fontWeight),
      fontStyle: s.fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal,
      height: s.lineHeight,
      letterSpacing: s.letterSpacing,
      decoration: switch (s.textDecoration) {
        'underline' => TextDecoration.underline,
        'line-through' => TextDecoration.lineThrough,
        'overline' => TextDecoration.overline,
        _ => TextDecoration.none,
      },
    );
  }

  StyleProps mergeResponsive(
    StyleProps? base,
    Map<String, Map<String, dynamic>>? responsive,
    Breakpoint breakpoint,
  ) {
    final merged = <String, dynamic>{...?(base?.toJson())};

    final keys = switch (breakpoint) {
      Breakpoint.base => <String>[],
      Breakpoint.sm => ['sm'],
      Breakpoint.md => ['sm', 'md'],
      Breakpoint.lg => ['sm', 'md', 'lg'],
      Breakpoint.xl => ['sm', 'md', 'lg', 'xl'],
    };

    for (final key in keys) {
      final override = responsive?[key];
      if (override != null) {
        merged.addAll(override);
      }
    }

    return StyleProps.fromJson(merged);
  }
}
