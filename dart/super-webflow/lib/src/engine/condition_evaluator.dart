import '../models/data_binding.dart';
import 'data_binding_resolver.dart';
import 'data_context.dart';

class ConditionEvaluator {
  final DataBindingResolver resolver;

  ConditionEvaluator(this.resolver);

  bool evaluate(DataCondition condition, DataContext context) {
    final actual = resolver.resolvePath(condition.field, context);
    var result = _evaluateOperator(condition.operator, actual, condition.value);

    final orList = condition.or;
    if (orList != null && orList.isNotEmpty) {
      result = result && orList.any((c) => evaluate(c, context));
    }
    final andList = condition.and;
    if (andList != null && andList.isNotEmpty) {
      result = result && andList.every((c) => evaluate(c, context));
    }

    return result;
  }

  bool _evaluateOperator(String op, dynamic actual, dynamic expected) {
    switch (op) {
      case '==':
        return _coerce(actual) == _coerce(expected);
      case '!=':
        return _coerce(actual) != _coerce(expected);
      case '>':
        return _num(actual) > _num(expected);
      case '<':
        return _num(actual) < _num(expected);
      case '>=':
        return _num(actual) >= _num(expected);
      case '<=':
        return _num(actual) <= _num(expected);
      case 'exists':
        return actual != null;
      case 'not-exists':
        return actual == null;
      case 'contains':
        if (actual is String) {
          return actual.contains(expected?.toString() ?? '');
        }
        if (actual is List) {
          return actual.any((e) => _coerce(e) == _coerce(expected));
        }
        return false;
      case 'not-contains':
        return !_evaluateOperator('contains', actual, expected);
      case 'empty':
        return _isEmpty(actual);
      case 'not-empty':
        return !_isEmpty(actual);
      case 'starts-with':
        return actual is String &&
            actual.startsWith(expected?.toString() ?? '');
      case 'ends-with':
        return actual is String && actual.endsWith(expected?.toString() ?? '');
      default:
        return false;
    }
  }

  dynamic _coerce(dynamic value) {
    if (value is num || value is bool || value == null) {
      return value;
    }
    final n = num.tryParse(value.toString());
    return n ?? value.toString();
  }

  double _num(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isEmpty(dynamic value) {
    if (value == null) {
      return true;
    }
    if (value is String) {
      return value.trim().isEmpty;
    }
    if (value is List || value is Map) {
      return (value as dynamic).isEmpty as bool;
    }
    return false;
  }
}
