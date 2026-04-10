import 'package:flutter/widgets.dart';

import '../models/primitives.dart';
import '../models/template_document.dart';
import 'data_context.dart';
import 'template_engine.dart';

class TemplateRenderer extends StatelessWidget {
  final TemplateDocument document;
  final Map<String, dynamic> data;
  final String pageId;
  final TemplateEngine? engine;

  const TemplateRenderer({
    super.key,
    required this.document,
    required this.data,
    this.pageId = 'home',
    this.engine,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final breakpoint = breakpointFromWidth(width);
    final ctx = DataContext(
      data: data,
      theme: document.theme,
      breakpoint: breakpoint,
      reduceMotion: document.engineHints?.reduceMotion ?? false,
    );
    final eng = engine ?? TemplateEngine();
    return eng.buildPage(pageId, document, ctx);
  }
}
