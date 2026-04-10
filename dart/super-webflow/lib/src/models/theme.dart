import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

@freezed
class ThemeColors with _$ThemeColors {
  const factory ThemeColors({
    required String primary,
    required String primaryLight,
    required String primaryDark,
    required String secondary,
    required String secondaryLight,
    required String secondaryDark,
    required String accent,
    required String accentLight,
    required String background,
    required String backgroundAlt,
    required String surface,
    required String surfaceAlt,
    required String overlay,
    required String text,
    required String textSecondary,
    required String textMuted,
    required String textInverse,
    required String textOnPrimary,
    required String border,
    required String borderStrong,
    required String borderFocus,
    required String success,
    required String successLight,
    required String warning,
    required String warningLight,
    required String danger,
    required String dangerLight,
    required String info,
    required String infoLight,
  }) = _ThemeColors;

  factory ThemeColors.fromJson(Map<String, dynamic> json) =>
      _$ThemeColorsFromJson(json);
}

@freezed
class ThemeTypographyScale with _$ThemeTypographyScale {
  const factory ThemeTypographyScale({
    required double xs,
    required double sm,
    required double base,
    required double lg,
    required double xl,
    @JsonKey(name: '2xl') required double xl2,
    @JsonKey(name: '3xl') required double xl3,
    @JsonKey(name: '4xl') required double xl4,
    @JsonKey(name: '5xl') required double xl5,
    @JsonKey(name: '6xl') required double xl6,
    @JsonKey(name: '7xl') required double xl7,
  }) = _ThemeTypographyScale;

  factory ThemeTypographyScale.fromJson(Map<String, dynamic> json) =>
      _$ThemeTypographyScaleFromJson(json);
}

@freezed
class ThemeFonts with _$ThemeFonts {
  const factory ThemeFonts({
    required String heading,
    required String body,
    String? mono,
  }) = _ThemeFonts;

  factory ThemeFonts.fromJson(Map<String, dynamic> json) =>
      _$ThemeFontsFromJson(json);
}

@freezed
class ThemeTypography with _$ThemeTypography {
  const factory ThemeTypography({
    required ThemeFonts fonts,
    List<int>? availableWeights,
    required ThemeTypographyScale scale,
    required ThemeTypographyScale lineHeights,
    Map<String, double>? letterSpacings,
  }) = _ThemeTypography;

  factory ThemeTypography.fromJson(Map<String, dynamic> json) =>
      _$ThemeTypographyFromJson(json);
}

@freezed
class ThemeSpacing with _$ThemeSpacing {
  const factory ThemeSpacing({
    required double base,
    required Map<String, double> scale,
  }) = _ThemeSpacing;

  factory ThemeSpacing.fromJson(Map<String, dynamic> json) =>
      _$ThemeSpacingFromJson(json);
}

@freezed
class ThemeRadii with _$ThemeRadii {
  const factory ThemeRadii({
    @Default(0.0) double none,
    required double xs,
    required double sm,
    required double md,
    required double lg,
    required double xl,
    @JsonKey(name: '2xl') required double xl2,
    @JsonKey(name: '3xl') required double xl3,
    @Default(9999.0) double full,
  }) = _ThemeRadii;

  factory ThemeRadii.fromJson(Map<String, dynamic> json) =>
      _$ThemeRadiiFromJson(json);
}

@freezed
class ShadowDef with _$ShadowDef {
  const factory ShadowDef({
    required double offsetX,
    required double offsetY,
    required double blur,
    double? spread,
    required String color,
    @Default(false) bool inset,
  }) = _ShadowDef;

  factory ShadowDef.fromJson(Map<String, dynamic> json) =>
      _$ShadowDefFromJson(json);
}

sealed class ThemeShadowValue {
  const ThemeShadowValue();

  factory ThemeShadowValue.fromJson(Object? json) {
    if (json == null) {
      return const SvNone();
    }
    if (json is Map<String, dynamic>) {
      return SvSingle(ShadowDef.fromJson(json));
    }
    if (json is List) {
      return SvMultiple(
        json
            .map((e) => ShadowDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid ThemeShadowValue: $json');
  }

  Object? toJson();
}

final class SvNone extends ThemeShadowValue {
  const SvNone();

  @override
  Object? toJson() => null;
}

final class SvSingle extends ThemeShadowValue {
  final ShadowDef def;

  const SvSingle(this.def);

  @override
  Object? toJson() => def.toJson();
}

final class SvMultiple extends ThemeShadowValue {
  final List<ShadowDef> defs;

  const SvMultiple(this.defs);

  @override
  Object? toJson() => defs.map((e) => e.toJson()).toList();
}

class ThemeShadowValueConverter
    implements JsonConverter<ThemeShadowValue, Object?> {
  const ThemeShadowValueConverter();

  @override
  ThemeShadowValue fromJson(Object? json) => ThemeShadowValue.fromJson(json);

  @override
  Object? toJson(ThemeShadowValue object) => object.toJson();
}

@freezed
class ThemeShadows with _$ThemeShadows {
  const factory ThemeShadows({
    @ThemeShadowValueConverter() required ThemeShadowValue sm,
    @ThemeShadowValueConverter() required ThemeShadowValue md,
    @ThemeShadowValueConverter() required ThemeShadowValue lg,
    @ThemeShadowValueConverter() required ThemeShadowValue xl,
    required ShadowDef inner,
  }) = _ThemeShadows;

  factory ThemeShadows.fromJson(Map<String, dynamic> json) =>
      _$ThemeShadowsFromJson(json);
}

@freezed
class ThemeEasing with _$ThemeEasing {
  const factory ThemeEasing({
    @JsonKey(name: 'default') required String defaultValue,
    @JsonKey(name: 'in') required String inValue,
    required String out,
    required String inOut,
    required String spring,
  }) = _ThemeEasing;

  factory ThemeEasing.fromJson(Map<String, dynamic> json) =>
      _$ThemeEasingFromJson(json);
}

@freezed
class ThemeTransitions with _$ThemeTransitions {
  const factory ThemeTransitions({
    required int fast,
    required int normal,
    required int slow,
    required ThemeEasing easing,
  }) = _ThemeTransitions;

  factory ThemeTransitions.fromJson(Map<String, dynamic> json) =>
      _$ThemeTransitionsFromJson(json);
}

@freezed
class ThemeZIndex with _$ThemeZIndex {
  const factory ThemeZIndex({
    required int base,
    required int raised,
    required int sticky,
    required int overlay,
    required int modal,
    required int popup,
    required int tooltip,
    required int max,
  }) = _ThemeZIndex;

  factory ThemeZIndex.fromJson(Map<String, dynamic> json) =>
      _$ThemeZIndexFromJson(json);
}

@freezed
class ThemeSchema with _$ThemeSchema {
  const factory ThemeSchema({
    required String id,
    required String name,
    required String version,
    required ThemeColors colors,
    required ThemeTypography typography,
    required ThemeSpacing spacing,
    required ThemeRadii radii,
    required ThemeShadows shadows,
    required ThemeTransitions transitions,
    required ThemeZIndex zIndex,
  }) = _ThemeSchema;

  factory ThemeSchema.fromJson(Map<String, dynamic> json) =>
      _$ThemeSchemaFromJson(json);
}
