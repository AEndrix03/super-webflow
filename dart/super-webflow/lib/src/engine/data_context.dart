import '../models/primitives.dart';
import '../models/theme.dart';

class DataContext {
  final Map<String, dynamic> data;
  final ThemeSchema theme;
  final Breakpoint breakpoint;
  final bool reduceMotion;

  const DataContext({
    required this.data,
    required this.theme,
    required this.breakpoint,
    this.reduceMotion = false,
  });

  DataContext withAlias(String alias, dynamic value, String indexAlias, int index) =>
      DataContext(
        data: {...data, alias: value, indexAlias: index},
        theme: theme,
        breakpoint: breakpoint,
        reduceMotion: reduceMotion,
      );

  DataContext withBreakpoint(Breakpoint bp) => DataContext(
        data: data,
        theme: theme,
        breakpoint: bp,
        reduceMotion: reduceMotion,
      );
}
