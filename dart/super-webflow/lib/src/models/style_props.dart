import 'package:freezed_annotation/freezed_annotation.dart';

import 'primitives.dart';
import 'theme.dart';

part 'style_props.freezed.dart';
part 'style_props.g.dart';

sealed class ShadowStyleValue {
  const ShadowStyleValue();

  factory ShadowStyleValue.fromJson(Object? json) {
    if (json == null) {
      return const ShadowStyleNone();
    }
    if (json is String) {
      return ShadowStyleKey(json);
    }
    if (json is Map<String, dynamic>) {
      return ShadowStyleSingle(ShadowDef.fromJson(json));
    }
    if (json is List) {
      return ShadowStyleList(
        json.map((e) => ShadowDef.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
    throw FormatException('Invalid shadow style value: $json');
  }

  Object? toJson();
}

final class ShadowStyleNone extends ShadowStyleValue {
  const ShadowStyleNone();

  @override
  Object? toJson() => null;
}

final class ShadowStyleKey extends ShadowStyleValue {
  final String key;

  const ShadowStyleKey(this.key);

  @override
  Object? toJson() => key;
}

final class ShadowStyleSingle extends ShadowStyleValue {
  final ShadowDef value;

  const ShadowStyleSingle(this.value);

  @override
  Object? toJson() => value.toJson();
}

final class ShadowStyleList extends ShadowStyleValue {
  final List<ShadowDef> value;

  const ShadowStyleList(this.value);

  @override
  Object? toJson() => value.map((e) => e.toJson()).toList();
}

class ShadowStyleConverter implements JsonConverter<ShadowStyleValue?, Object?> {
  const ShadowStyleConverter();

  @override
  ShadowStyleValue? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    return ShadowStyleValue.fromJson(json);
  }

  @override
  Object? toJson(ShadowStyleValue? object) => object?.toJson();
}

sealed class TransitionStyleValue {
  const TransitionStyleValue();

  factory TransitionStyleValue.fromJson(Object? json) {
    if (json is String) {
      return TransitionStyleKey(json);
    }
    if (json is Map<String, dynamic>) {
      return TransitionStyleSingle(TransitionDef.fromJson(json));
    }
    if (json is List) {
      return TransitionStyleList(
        json
            .map((e) => TransitionDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid transition style value: $json');
  }

  Object toJson();
}

final class TransitionStyleKey extends TransitionStyleValue {
  final String key;

  const TransitionStyleKey(this.key);

  @override
  Object toJson() => key;
}

final class TransitionStyleSingle extends TransitionStyleValue {
  final TransitionDef value;

  const TransitionStyleSingle(this.value);

  @override
  Object toJson() => value.toJson();
}

final class TransitionStyleList extends TransitionStyleValue {
  final List<TransitionDef> value;

  const TransitionStyleList(this.value);

  @override
  Object toJson() => value.map((e) => e.toJson()).toList();
}

class TransitionStyleConverter
    implements JsonConverter<TransitionStyleValue?, Object?> {
  const TransitionStyleConverter();

  @override
  TransitionStyleValue? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    return TransitionStyleValue.fromJson(json);
  }

  @override
  Object? toJson(TransitionStyleValue? object) => object?.toJson();
}

sealed class BorderRadiusValue {
  const BorderRadiusValue();

  factory BorderRadiusValue.fromJson(Object? json) {
    if (json is num) {
      return BorderRadiusSingle(json.toDouble());
    }
    if (json is List) {
      final values = json.map((e) => (e as num).toDouble()).toList();
      return BorderRadiusFour(values);
    }
    throw FormatException('Invalid borderRadius value: $json');
  }

  Object toJson();
}

final class BorderRadiusSingle extends BorderRadiusValue {
  final double value;

  const BorderRadiusSingle(this.value);

  @override
  Object toJson() => value;
}

final class BorderRadiusFour extends BorderRadiusValue {
  final List<double> values;

  const BorderRadiusFour(this.values);

  @override
  Object toJson() => values;
}

class BorderRadiusValueConverter
    implements JsonConverter<BorderRadiusValue?, Object?> {
  const BorderRadiusValueConverter();

  @override
  BorderRadiusValue? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    return BorderRadiusValue.fromJson(json);
  }

  @override
  Object? toJson(BorderRadiusValue? object) => object?.toJson();
}

sealed class FontSizeValue {
  const FontSizeValue();

  factory FontSizeValue.fromJson(Object? json) {
    if (json is num) {
      return FontSizePixels(json.toDouble());
    }
    if (json is String) {
      return FontSizeToken(json);
    }
    throw FormatException('Invalid fontSize value: $json');
  }

  Object toJson();
}

final class FontSizePixels extends FontSizeValue {
  final double value;

  const FontSizePixels(this.value);

  @override
  Object toJson() => value;
}

final class FontSizeToken extends FontSizeValue {
  final String value;

  const FontSizeToken(this.value);

  @override
  Object toJson() => value;
}

class FontSizeConverter implements JsonConverter<FontSizeValue?, Object?> {
  const FontSizeConverter();

  @override
  FontSizeValue? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    return FontSizeValue.fromJson(json);
  }

  @override
  Object? toJson(FontSizeValue? object) => object?.toJson();
}

@freezed
class TransitionDef with _$TransitionDef {
  const factory TransitionDef({
    required String property,
    required int duration,
    String? easing,
    int? delay,
  }) = _TransitionDef;

  factory TransitionDef.fromJson(Map<String, dynamic> json) =>
      _$TransitionDefFromJson(json);
}

@freezed
class GradientStop with _$GradientStop {
  const factory GradientStop({
    required String color,
    required double position,
  }) = _GradientStop;

  factory GradientStop.fromJson(Map<String, dynamic> json) =>
      _$GradientStopFromJson(json);
}

@freezed
class GradientDef with _$GradientDef {
  const factory GradientDef({
    required String type,
    double? angle,
    required List<GradientStop> stops,
    String? radialShape,
  }) = _GradientDef;

  factory GradientDef.fromJson(Map<String, dynamic> json) =>
      _$GradientDefFromJson(json);
}

@freezed
class BorderDef with _$BorderDef {
  const factory BorderDef({
    required double width,
    String? style,
    required String color,
  }) = _BorderDef;

  factory BorderDef.fromJson(Map<String, dynamic> json) =>
      _$BorderDefFromJson(json);
}

@freezed
class TransformDef with _$TransformDef {
  const factory TransformDef({
    Object? translateX,
    Object? translateY,
    Object? translateZ,
    double? rotate,
    double? rotateX,
    double? rotateY,
    double? scale,
    double? scaleX,
    double? scaleY,
    double? skewX,
    double? skewY,
  }) = _TransformDef;

  factory TransformDef.fromJson(Map<String, dynamic> json) =>
      _$TransformDefFromJson(json);
}

@freezed
class EntranceAnimation with _$EntranceAnimation {
  const factory EntranceAnimation({
    required String type,
    required int duration,
    int? delay,
    String? easing,
    @Default('page-load') String trigger,
  }) = _EntranceAnimation;

  factory EntranceAnimation.fromJson(Map<String, dynamic> json) =>
      _$EntranceAnimationFromJson(json);
}

@freezed
class StyleProps with _$StyleProps {
  const factory StyleProps({
    @SizeValueConverter() SizeValue? width,
    @SizeValueConverter() SizeValue? height,
    @SizeValueConverter() SizeValue? minWidth,
    @SizeValueConverter() SizeValue? maxWidth,
    @SizeValueConverter() SizeValue? minHeight,
    @SizeValueConverter() SizeValue? maxHeight,
    String? aspectRatio,
    @SpacingConverter() Spacing? padding,
    double? paddingTop,
    double? paddingRight,
    double? paddingBottom,
    double? paddingLeft,
    double? paddingX,
    double? paddingY,
    @SpacingConverter() Spacing? margin,
    double? marginTop,
    double? marginRight,
    double? marginBottom,
    double? marginLeft,
    double? marginX,
    double? marginY,
    String? backgroundColor,
    GradientDef? backgroundGradient,
    String? backgroundImage,
    String? backgroundSize,
    String? backgroundPosition,
    String? backgroundRepeat,
    String? backgroundOverlay,
    double? backdropBlur,
    String? color,
    String? fill,
    String? stroke,
    double? strokeWidth,
    @FontSizeConverter() FontSizeValue? fontSize,
    Object? fontWeight,
    String? fontFamily,
    String? fontStyle,
    double? lineHeight,
    double? letterSpacing,
    String? textAlign,
    String? textTransform,
    String? textDecoration,
    String? textOverflow,
    String? whiteSpace,
    String? wordBreak,
    int? lineClamp,
    BorderDef? border,
    BorderDef? borderTop,
    BorderDef? borderRight,
    BorderDef? borderBottom,
    BorderDef? borderLeft,
    @BorderRadiusValueConverter() BorderRadiusValue? borderRadius,
    String? outlineColor,
    double? outlineWidth,
    double? outlineOffset,
    @ShadowStyleConverter() ShadowStyleValue? shadow,
    double? opacity,
    String? overflow,
    String? overflowX,
    String? overflowY,
    String? cursor,
    String? userSelect,
    @TransitionStyleConverter() TransitionStyleValue? transition,
    TransformDef? transform,
    String? position,
    @SizeValueConverter() SizeValue? top,
    @SizeValueConverter() SizeValue? right,
    @SizeValueConverter() SizeValue? bottom,
    @SizeValueConverter() SizeValue? left,
    Object? zIndex,
    String? display,
    String? visibility,
    EntranceAnimation? entranceAnimation,
  }) = _StyleProps;

  factory StyleProps.fromJson(Map<String, dynamic> json) =>
      _$StylePropsFromJson(json);
}
