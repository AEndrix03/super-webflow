import '../models/data_binding.dart';
import 'data_context.dart';
import 'transform_pipeline.dart';

class DataBindingResolver {
  final TransformPipeline pipeline;

  DataBindingResolver() : pipeline = TransformPipeline();

  dynamic resolvePath(String path, DataContext context) {
    final tokens = RegExp(r'([^\.\[]+)|\[(\d+)\]').allMatches(path);
    dynamic current = context.data;

    for (final m in tokens) {
      final key = m.group(1);
      final idx = m.group(2);

      if (key != null) {
        if (current is Map<String, dynamic>) {
          if (!current.containsKey(key)) {
            return null;
          }
          current = current[key];
          continue;
        }
        if (current is Map) {
          if (!current.containsKey(key)) {
            return null;
          }
          current = current[key];
          continue;
        }
        return null;
      }

      if (idx != null) {
        if (current is List) {
          final i = int.parse(idx);
          if (i < 0 || i >= current.length) {
            return null;
          }
          current = current[i];
          continue;
        }
        return null;
      }
    }

    return current;
  }

  dynamic resolveField(DataBinding binding, DataContext context) {
    final field = binding.field;
    if (field == null) {
      return binding.fallback;
    }
    var value = resolvePath(field, context);
    value ??= binding.fallback;
    return pipeline.apply(value, transformList(binding));
  }

  List<dynamic> resolveList(DataBinding binding, DataContext context) {
    final field = binding.listField;
    if (field == null) {
      return const [];
    }
    final value = resolvePath(field, context);
    if (value is List) {
      return value;
    }
    return const [];
  }

  Map<String, dynamic> resolveAttributes(DataBinding binding, DataContext context) {
    final attrs = binding.bindAttributes;
    if (attrs == null) {
      return const {};
    }
    final out = <String, dynamic>{};
    for (final entry in attrs.entries) {
      out[entry.key] = resolvePath(entry.value, context);
    }
    return out;
  }

  List<dynamic> applyListModifiers(List<dynamic> items, DataBinding binding) {
    var out = [...items];

    final sort = binding.sort;
    if (sort != null) {
      out.sort((a, b) {
        final av = _extractValue(a, sort.field);
        final bv = _extractValue(b, sort.field);
        final cmp = _compareValues(av, bv);
        return sort.direction == 'desc' ? -cmp : cmp;
      });
    }

    final limit = binding.limit;
    if (limit != null && limit >= 0 && out.length > limit) {
      out = out.take(limit).toList();
    }

    return out;
  }

  dynamic _extractValue(dynamic item, String path) {
    var working = path;
    if (working.contains('.')) {
      working = working.substring(working.indexOf('.') + 1);
    }
    final tokens = RegExp(r'([^\.\[]+)|\[(\d+)\]').allMatches(working);
    dynamic current = item;
    for (final m in tokens) {
      final key = m.group(1);
      final idx = m.group(2);
      if (key != null) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          return null;
        }
      } else if (idx != null) {
        if (current is List) {
          final i = int.parse(idx);
          if (i >= 0 && i < current.length) {
            current = current[i];
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    }
    return current;
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a is num && b is num) {
      return a.compareTo(b);
    }
    return a.toString().compareTo(b.toString());
  }
}
