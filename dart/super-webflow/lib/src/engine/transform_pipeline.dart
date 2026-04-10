import 'package:intl/intl.dart';

import '../models/data_binding.dart';

class TransformPipeline {
  dynamic apply(dynamic value, List<TransformFn> transforms) {
    var current = value;
    for (final t in transforms) {
      current = applyOne(current, t);
    }
    return current;
  }

  dynamic applyOne(dynamic value, TransformFn transform) {
    try {
      if (transform == 'uppercase') {
        return value is String ? value.toUpperCase() : value;
      }
      if (transform == 'lowercase') {
        return value is String ? value.toLowerCase() : value;
      }
      if (transform == 'capitalize') {
        if (value is! String) {
          return value;
        }
        return value
            .split(' ')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join(' ');
      }
      if (transform == 'trim') {
        return value is String ? value.trim() : value;
      }
      if (transform.startsWith('truncate:')) {
        final n = int.tryParse(transform.split(':')[1]) ?? 0;
        final s = value?.toString() ?? '';
        return s.length > n ? '${s.substring(0, n)}…' : s;
      }
      if (transform.startsWith('prefix:')) {
        final p = transform.substring('prefix:'.length);
        return '$p${value ?? ''}';
      }
      if (transform.startsWith('suffix:')) {
        final s = transform.substring('suffix:'.length);
        return '${value ?? ''}$s';
      }
      if (transform.startsWith('replace:')) {
        final parts = transform.split(':');
        if (parts.length < 3 || value is! String) {
          return value;
        }
        return value.replaceAll(parts[1], parts[2]);
      }
      if (transform.startsWith('default:')) {
        final fallback = transform.substring('default:'.length);
        return _isFalsy(value) ? fallback : value;
      }
      if (transform == 'format:currency') {
        final n = _toNum(value);
        return NumberFormat.currency(locale: 'it_IT', symbol: '€').format(n);
      }
      if (transform == 'format:currency-compact') {
        final n = _toNum(value);
        return NumberFormat.compactCurrency(locale: 'it_IT', symbol: '€').format(n);
      }
      if (transform == 'format:percent') {
        final n = _toNum(value);
        return NumberFormat.percentPattern('it_IT').format(n);
      }
      if (transform == 'format:number') {
        final n = _toNum(value);
        return NumberFormat.decimalPattern('it_IT').format(n);
      }
      if (transform == 'format:date') {
        final dt = DateTime.tryParse(value.toString());
        if (dt == null) {
          return value;
        }
        return DateFormat('d MMMM yyyy', 'it_IT').format(dt);
      }
      if (transform == 'format:date-short') {
        final dt = DateTime.tryParse(value.toString());
        if (dt == null) {
          return value;
        }
        return DateFormat('dd/MM/yyyy', 'it_IT').format(dt);
      }
      if (transform == 'format:time') {
        final dt = DateTime.tryParse(value.toString());
        if (dt == null) {
          return value;
        }
        return DateFormat('HH:mm', 'it_IT').format(dt);
      }
      if (transform == 'format:datetime') {
        final dt = DateTime.tryParse(value.toString());
        if (dt == null) {
          return value;
        }
        return DateFormat('d MMM yyyy, HH:mm', 'it_IT').format(dt);
      }
      if (transform == 'format:duration') {
        final minutes = _toNum(value).toInt();
        final h = minutes ~/ 60;
        final m = minutes % 60;
        if (h == 0) {
          return '${m}m';
        }
        if (m == 0) {
          return '${h}h';
        }
        return '${h}h ${m}m';
      }
      if (transform.startsWith('join:')) {
        if (value is! List) {
          return value;
        }
        final sep = transform.substring('join:'.length);
        return value.join(sep);
      }
      if (transform == 'count') {
        return value is List ? value.length.toString() : value;
      }
      if (transform == 'first') {
        return value is List && value.isNotEmpty ? value.first : value;
      }
      if (transform == 'last') {
        return value is List && value.isNotEmpty ? value.last : value;
      }
      if (transform.startsWith('slice:')) {
        if (value is! List) {
          return value;
        }
        final parts = transform.split(':');
        if (parts.length < 3) {
          return value;
        }
        final start = int.tryParse(parts[1]) ?? 0;
        final end = int.tryParse(parts[2]) ?? value.length;
        return value.sublist(start, end.clamp(start, value.length));
      }
      if (transform == 'boolean') {
        if (value is bool) {
          return value;
        }
        if (value is num) {
          return value != 0;
        }
        final s = value?.toString().toLowerCase();
        return s == 'true' || s == '1';
      }
      if (transform == 'string') {
        return value?.toString() ?? '';
      }
      if (transform == 'number') {
        return _toNum(value);
      }
      return value;
    } catch (_) {
      return value;
    }
  }

  bool _isFalsy(dynamic value) {
    if (value == null) {
      return true;
    }
    if (value is bool) {
      return !value;
    }
    if (value is num) {
      return value == 0;
    }
    if (value is String) {
      return value.isEmpty;
    }
    if (value is List || value is Map) {
      return (value as dynamic).isEmpty as bool;
    }
    return false;
  }

  double _toNum(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    final parsed = double.tryParse(value?.toString() ?? '');
    return parsed ?? 0;
  }
}
