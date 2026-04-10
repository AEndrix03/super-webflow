import 'package:freezed_annotation/freezed_annotation.dart';

import 'primitives.dart';

part 'layout_props.freezed.dart';
part 'layout_props.g.dart';

sealed class GapValue {
  const GapValue();

  factory GapValue.fromJson(Object? json) {
    if (json is num) {
      return GapSingle(json.toDouble());
    }
    if (json is List) {
      final values = json.map((e) => (e as num).toDouble()).toList();
      return GapPair(values[0], values[1]);
    }
    throw FormatException('Invalid gap value: $json');
  }

  Object toJson();
}

final class GapSingle extends GapValue {
  final double value;

  const GapSingle(this.value);

  @override
  Object toJson() => value;
}

final class GapPair extends GapValue {
  final double rowGap;
  final double columnGap;

  const GapPair(this.rowGap, this.columnGap);

  @override
  Object toJson() => [rowGap, columnGap];
}

class GapConverter implements JsonConverter<GapValue?, Object?> {
  const GapConverter();

  @override
  GapValue? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    return GapValue.fromJson(json);
  }

  @override
  Object? toJson(GapValue? object) => object?.toJson();
}

@freezed
class LayoutProps with _$LayoutProps {
  const factory LayoutProps({
    String? direction,
    Object? wrap,
    String? justifyContent,
    String? alignItems,
    String? alignContent,
    String? alignSelf,
    double? flex,
    double? flexGrow,
    double? flexShrink,
    @SizeValueConverter() SizeValue? flexBasis,
    @GapConverter() GapValue? gap,
    Object? columns,
    Object? rows,
    double? columnGap,
    double? rowGap,
    int? spanColumns,
    int? spanRows,
    Object? columnStart,
    Object? rowStart,
    int? stackIndex,
  }) = _LayoutProps;

  factory LayoutProps.fromJson(Map<String, dynamic> json) =>
      _$LayoutPropsFromJson(json);
}
