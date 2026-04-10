import 'package:json_annotation/json_annotation.dart';

sealed class SizeValue {
  const SizeValue();

  factory SizeValue.fromJson(Object? json) {
    if (json is num) {
      return SvPixels(json.toDouble());
    }
    if (json is String) {
      if (const {'auto', 'fill', 'wrap', 'screen'}.contains(json)) {
        return SvKeyword(json);
      }
      if (json.endsWith('%')) {
        return SvPercent(double.parse(json.replaceAll('%', '')));
      }
      if (json.endsWith('vw')) {
        return SvViewport(double.parse(json.replaceAll('vw', '')), isVh: false);
      }
      if (json.endsWith('vh')) {
        return SvViewport(double.parse(json.replaceAll('vh', '')), isVh: true);
      }
    }
    throw FormatException('Invalid SizeValue: $json');
  }

  Object toJson();
}

final class SvPixels extends SizeValue {
  final double px;

  const SvPixels(this.px);

  @override
  Object toJson() => px;
}

final class SvKeyword extends SizeValue {
  final String keyword;

  const SvKeyword(this.keyword);

  @override
  Object toJson() => keyword;
}

final class SvPercent extends SizeValue {
  final double pct;

  const SvPercent(this.pct);

  @override
  Object toJson() => '$pct%';
}

final class SvViewport extends SizeValue {
  final double value;
  final bool isVh;

  const SvViewport(this.value, {required this.isVh});

  @override
  Object toJson() => '$value${isVh ? 'vh' : 'vw'}';
}

sealed class Spacing {
  const Spacing();

  factory Spacing.fromJson(Object? json) {
    if (json is num) {
      return SpacingAll(json.toDouble());
    }
    if (json is List<dynamic>) {
      final vals = json.map((e) => (e as num).toDouble()).toList();
      if (vals.length == 2) {
        return SpacingAxes(v: vals[0], h: vals[1]);
      }
      if (vals.length == 4) {
        return SpacingFour(t: vals[0], r: vals[1], b: vals[2], l: vals[3]);
      }
    }
    if (json is Map<String, dynamic>) {
      return SpacingExplicit(
        top: (json['top'] as num?)?.toDouble() ?? 0,
        right: (json['right'] as num?)?.toDouble() ?? 0,
        bottom: (json['bottom'] as num?)?.toDouble() ?? 0,
        left: (json['left'] as num?)?.toDouble() ?? 0,
      );
    }
    throw FormatException('Invalid Spacing: $json');
  }

  Object toJson();
}

final class SpacingAll extends Spacing {
  final double value;

  const SpacingAll(this.value);

  @override
  Object toJson() => value;
}

final class SpacingAxes extends Spacing {
  final double v;
  final double h;

  const SpacingAxes({required this.v, required this.h});

  @override
  Object toJson() => [v, h];
}

final class SpacingFour extends Spacing {
  final double t;
  final double r;
  final double b;
  final double l;

  const SpacingFour({
    required this.t,
    required this.r,
    required this.b,
    required this.l,
  });

  @override
  Object toJson() => [t, r, b, l];
}

final class SpacingExplicit extends Spacing {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const SpacingExplicit({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  @override
  Object toJson() => {
        'top': top,
        'right': right,
        'bottom': bottom,
        'left': left,
      };
}

/// A CSS color string or a ThemeColors token key (e.g. 'primary', 'surface').
/// Resolution: engine checks theme.colors[value] first; falls back to raw CSS.
typedef ColorValue = String;

/// Named font-size scale key. Resolved via theme.typography.scale[key].
typedef FontSizeKey = String;

/// Viewport breakpoint. Thresholds: sm=640, md=768, lg=1024, xl=1280.
enum Breakpoint { base, sm, md, lg, xl }

/// Resolves viewport width to active breakpoint.
Breakpoint breakpointFromWidth(double width) {
  if (width >= 1280) {
    return Breakpoint.xl;
  }
  if (width >= 1024) {
    return Breakpoint.lg;
  }
  if (width >= 768) {
    return Breakpoint.md;
  }
  if (width >= 640) {
    return Breakpoint.sm;
  }
  return Breakpoint.base;
}

class SizeValueConverter implements JsonConverter<SizeValue?, Object?> {
  const SizeValueConverter();

  @override
  SizeValue? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    return SizeValue.fromJson(json);
  }

  @override
  Object? toJson(SizeValue? value) => value?.toJson();
}

class SpacingConverter implements JsonConverter<Spacing?, Object?> {
  const SpacingConverter();

  @override
  Spacing? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    return Spacing.fromJson(json);
  }

  @override
  Object? toJson(Spacing? value) => value?.toJson();
}
