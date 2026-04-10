import 'package:flutter/material.dart';

import '../models/style_props.dart';
import '../models/theme.dart';

class ThemeResolver {
  String resolveColor(String? colorValue, ThemeSchema theme) {
    if (colorValue == null) {
      return 'transparent';
    }
    final map = theme.colors.toJson();
    final resolved = map[colorValue];
    if (resolved is String) {
      return resolved;
    }
    return colorValue;
  }

  double resolveFontSize(Object? fontSize, ThemeSchema theme) {
    if (fontSize is num) {
      return fontSize.toDouble();
    }
    if (fontSize is FontSizePixels) {
      return fontSize.value;
    }
    if (fontSize is FontSizeToken) {
      final scale = theme.typography.scale.toJson();
      return (scale[fontSize.value] as num?)?.toDouble() ??
          theme.typography.scale.base;
    }
    if (fontSize is String) {
      final scale = theme.typography.scale.toJson();
      return (scale[fontSize] as num?)?.toDouble() ?? theme.typography.scale.base;
    }
    return theme.typography.scale.base;
  }

  List<BoxShadow> resolveShadow(Object? shadow, ThemeSchema theme) {
    if (shadow == null) {
      return const [];
    }

    ThemeShadowValue? fromTheme(String key) {
      return switch (key) {
        'sm' => theme.shadows.sm,
        'md' => theme.shadows.md,
        'lg' => theme.shadows.lg,
        'xl' => theme.shadows.xl,
        'inner' => SvSingle(theme.shadows.inner),
        'none' => const SvNone(),
        _ => null,
      };
    }

    List<ShadowDef> toDefs(Object? value) {
      if (value == null) {
        return const [];
      }
      if (value is ShadowStyleKey) {
        final themed = fromTheme(value.key);
        return toDefs(themed);
      }
      if (value is ThemeShadowValue) {
        return switch (value) {
          SvNone() => const [],
          SvSingle(:final def) => [def],
          SvMultiple(:final defs) => defs,
        };
      }
      if (value is ShadowStyleSingle) {
        return [value.value];
      }
      if (value is ShadowStyleList) {
        return value.value;
      }
      if (value is String) {
        final themed = fromTheme(value);
        if (themed != null) {
          return toDefs(themed);
        }
      }
      return const [];
    }

    final defs = toDefs(shadow);
    return defs
        .map(
          (d) => BoxShadow(
            color: parseCssColor(d.color),
            offset: Offset(d.offsetX, d.offsetY),
            blurRadius: d.blur,
            spreadRadius: d.spread ?? 0,
          ),
        )
        .toList();
  }

  int resolveZIndex(Object? zIndex, ThemeSchema theme) {
    if (zIndex is int) {
      return zIndex;
    }
    if (zIndex is num) {
      return zIndex.toInt();
    }
    if (zIndex is String) {
      final map = theme.zIndex.toJson();
      return (map[zIndex] as int?) ?? 0;
    }
    return 0;
  }

  Duration resolveTransitionDuration(Object? transition, ThemeSchema theme) {
    if (transition is TransitionStyleKey) {
      return _fromKey(transition.key, theme);
    }
    if (transition is String) {
      return _fromKey(transition, theme);
    }
    if (transition is TransitionStyleSingle) {
      return Duration(milliseconds: transition.value.duration);
    }
    return Duration(milliseconds: theme.transitions.normal);
  }

  Duration _fromKey(String key, ThemeSchema theme) {
    return switch (key) {
      'fast' => Duration(milliseconds: theme.transitions.fast),
      'normal' => Duration(milliseconds: theme.transitions.normal),
      'slow' => Duration(milliseconds: theme.transitions.slow),
      _ => Duration(milliseconds: theme.transitions.normal),
    };
  }

  Color parseCssColor(String value) {
    final input = value.trim();
    if (input.startsWith('#')) {
      final hex = input.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }

    final rgba = RegExp(
      r'^rgba?\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*([0-9]*\.?[0-9]+))?\)$',
      caseSensitive: false,
    ).firstMatch(input);
    if (rgba != null) {
      final r = int.parse(rgba.group(1)!);
      final g = int.parse(rgba.group(2)!);
      final b = int.parse(rgba.group(3)!);
      final a = rgba.group(4) != null
          ? (double.parse(rgba.group(4)!) * 255).round().clamp(0, 255)
          : 255;
      return Color.fromARGB(a, r, g, b);
    }

    return Colors.transparent;
  }
}
