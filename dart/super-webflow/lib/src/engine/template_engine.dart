import 'package:flutter/material.dart' hide Action;
import 'package:visibility_detector/visibility_detector.dart';

import '../models/component_node.dart';
import '../models/interaction.dart';
import '../models/style_props.dart';
import '../models/template_document.dart';
import 'component_registry.dart';
import 'condition_evaluator.dart';
import 'data_binding_resolver.dart';
import 'data_context.dart';
import 'layout_resolver.dart';
import 'style_resolver.dart';
import 'theme_resolver.dart';

class TemplateEngine {
  final ComponentRegistry registry;
  final StyleResolver styleResolver;
  final LayoutResolver layoutResolver;
  final DataBindingResolver dataResolver;
  final ConditionEvaluator conditionEvaluator;

  TemplateEngine({
    ComponentRegistry? registry,
    StyleResolver? styleResolver,
    LayoutResolver? layoutResolver,
    DataBindingResolver? dataResolver,
  })  : registry = registry ?? ComponentRegistry.defaults(),
        styleResolver = styleResolver ?? StyleResolver(ThemeResolver()),
        layoutResolver = layoutResolver ?? LayoutResolver(),
        dataResolver = dataResolver ?? DataBindingResolver(),
        conditionEvaluator = ConditionEvaluator(dataResolver ?? DataBindingResolver());

  Widget buildPage(String pageId, TemplateDocument template, DataContext context) {
    final page = template.pages[pageId];
    if (page == null) {
      throw StateError('[super_webflow] Page "$pageId" not found.');
    }
    return buildNode(page, context);
  }

  Widget buildNode(ComponentNode node, DataContext context) {
    if (node.condition != null &&
        !conditionEvaluator.evaluate(node.condition!, context)) {
      return const SizedBox.shrink();
    }

    if (node.data?.listField != null) {
      final binding = node.data!;
      final items = dataResolver.applyListModifiers(
        dataResolver.resolveList(binding, context),
        binding,
      );

      final rendered = <Widget>[];
      for (var i = 0; i < items.length; i++) {
        final childCtx = context.withAlias(
          binding.itemAlias,
          items[i],
          binding.indexAlias,
          i,
        );
        final children = node.children ?? const <ComponentNode>[];
        rendered.add(
          Column(
            children: children.map((c) => buildNode(c, childCtx)).toList(),
          ),
        );
      }
      return layoutResolver.apply(rendered, node.layout);
    }

    String? resolvedText;
    if (node.data?.field != null) {
      resolvedText = dataResolver.resolveField(node.data!, context)?.toString();
    }
    final resolvedProps = _mergeBindAttributes(node, context);

    final activeStyle = styleResolver.mergeResponsive(
      node.style,
      node.responsive,
      context.breakpoint,
    );

    Widget child;
    final children = node.children;
    if (children != null && children.isNotEmpty) {
      final childWidgets = children.map((c) => buildNode(c, context)).toList();
      child = layoutResolver.apply(childWidgets, node.layout);
    } else {
      final resolvedNode = _injectText(node, resolvedProps, resolvedText);
      child = registry.resolve(node.type)(resolvedNode, context, this);
    }

    final wrapped = styleResolver.wrap(child, activeStyle, context.theme);
    final interactive = _applyInteractions(wrapped, node.interactions, context);
    final animated = _applyEntranceAnimation(interactive, activeStyle.entranceAnimation, context);
    return animated;
  }

  Map<String, dynamic> _mergeBindAttributes(ComponentNode node, DataContext context) {
    final base = <String, dynamic>{...?(node.props)};
    final data = node.data;
    if (data == null) {
      return base;
    }
    final attrs = dataResolver.resolveAttributes(data, context);
    base.addAll(attrs);
    return base;
  }

  ComponentNode _injectText(
    ComponentNode node,
    Map<String, dynamic> props,
    String? resolvedText,
  ) {
    final isTextType = switch (node.type) {
      ComponentType.heading ||
      ComponentType.paragraph ||
      ComponentType.text ||
      ComponentType.label => true,
      _ => false,
    };

    if (isTextType && resolvedText != null) {
      props['text'] = resolvedText;
    }

    return node.copyWith(props: props);
  }

  Widget _applyInteractions(
    Widget child,
    List<Interaction>? interactions,
    DataContext context,
  ) {
    if (interactions == null || interactions.isEmpty) {
      return child;
    }

    GestureTapCallback? onTap;

    for (final i in interactions) {
      if (i.trigger == 'click') {
        onTap = () => _dispatch(i.action, context);
      }
    }

    if (onTap == null) {
      return child;
    }

    return GestureDetector(onTap: onTap, child: child);
  }

  void _dispatch(Action action, DataContext context) {
    switch (action) {
      case NavigateAction(:final url):
        debugPrint('[super_webflow] navigate -> $url');
      case ScrollToAction(:final nodeId):
        debugPrint('[super_webflow] scroll-to -> $nodeId');
      case OpenBookingAction():
        debugPrint('[super_webflow] open-booking');
      case SendAnalyticsAction(:final event):
        debugPrint('[super_webflow] analytics -> $event');
      default:
        break;
    }
  }

  Widget _applyEntranceAnimation(
    Widget child,
    EntranceAnimation? animation,
    DataContext context,
  ) {
    if (animation == null || animation.type == 'none' || context.reduceMotion) {
      return child;
    }

    if (animation.trigger == 'scroll-into-view') {
      return _VisibilityAnimated(
        animation: animation,
        child: child,
      );
    }

    return _BasicAnimated(animation: animation, child: child);
  }
}

class _BasicAnimated extends StatefulWidget {
  final EntranceAnimation animation;
  final Widget child;

  const _BasicAnimated({required this.animation, required this.child});

  @override
  State<_BasicAnimated> createState() => _BasicAnimatedState();
}

class _BasicAnimatedState extends State<_BasicAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animation.duration),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(_fade);
    _scale = Tween<double>(begin: 0.95, end: 1).animate(_fade);

    Future<void>.delayed(Duration(milliseconds: widget.animation.delay ?? 0), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

class _VisibilityAnimated extends StatefulWidget {
  final EntranceAnimation animation;
  final Widget child;

  const _VisibilityAnimated({required this.animation, required this.child});

  @override
  State<_VisibilityAnimated> createState() => _VisibilityAnimatedState();
}

class _VisibilityAnimatedState extends State<_VisibilityAnimated> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.01) {
          setState(() {
            _visible = true;
          });
        }
      },
      child: AnimatedOpacity(
        duration: Duration(milliseconds: widget.animation.duration),
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}




