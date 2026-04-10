import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_binding.freezed.dart';
part 'data_binding.g.dart';

typedef TransformFn = String;

@freezed
class DataCondition with _$DataCondition {
  const factory DataCondition({
    required String field,
    required String operator,
    Object? value,
    List<DataCondition>? or,
    List<DataCondition>? and,
  }) = _DataCondition;

  factory DataCondition.fromJson(Map<String, dynamic> json) =>
      _$DataConditionFromJson(json);
}

@freezed
class DataBindingSort with _$DataBindingSort {
  const factory DataBindingSort({
    required String field,
    required String direction,
  }) = _DataBindingSort;

  factory DataBindingSort.fromJson(Map<String, dynamic> json) =>
      _$DataBindingSortFromJson(json);
}

@freezed
class DataBinding with _$DataBinding {
  const factory DataBinding({
    String? field,
    String? listField,
    @Default('item') String itemAlias,
    @Default('index') String indexAlias,
    Object? transform,
    Object? fallback,
    Map<String, String>? bindAttributes,
    int? limit,
    DataBindingSort? sort,
  }) = _DataBinding;

  factory DataBinding.fromJson(Map<String, dynamic> json) =>
      _$DataBindingFromJson(json);
}

List<TransformFn> transformList(DataBinding binding) {
  final t = binding.transform;
  if (t == null) {
    return const [];
  }
  if (t is String) {
    return [t];
  }
  if (t is List) {
    return t.cast<TransformFn>();
  }
  return const [];
}

@freezed
class DataFieldOption with _$DataFieldOption {
  const factory DataFieldOption({
    required String value,
    required String label,
  }) = _DataFieldOption;

  factory DataFieldOption.fromJson(Map<String, dynamic> json) =>
      _$DataFieldOptionFromJson(json);
}

@freezed
class FieldValidation with _$FieldValidation {
  const factory FieldValidation({
    int? minLength,
    int? maxLength,
    double? min,
    double? max,
    String? pattern,
    List<DataFieldOption>? options,
    Map<String, DataFieldDef>? itemSchema,
    Map<String, DataFieldDef>? fields,
  }) = _FieldValidation;

  factory FieldValidation.fromJson(Map<String, dynamic> json) =>
      _$FieldValidationFromJson(json);
}

@freezed
class DataFieldDef with _$DataFieldDef {
  const factory DataFieldDef({
    required String type,
    bool? required,
    required String label,
    String? hint,
    @JsonKey(name: 'default')
    Object? defaultValue,
    String? group,
    int? order,
    FieldValidation? validation,
  }) = _DataFieldDef;

  factory DataFieldDef.fromJson(Map<String, dynamic> json) =>
      _$DataFieldDefFromJson(json);
}
