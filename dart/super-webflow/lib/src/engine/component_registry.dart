import 'package:flutter/widgets.dart';

import '../models/component_node.dart';
import 'components/avatar_component.dart';
import 'components/button_component.dart';
import 'components/container_component.dart';
import 'components/divider_component.dart';
import 'components/footer_component.dart';
import 'components/heading_component.dart';
import 'components/icon_component.dart';
import 'components/image_component.dart';
import 'components/link_component.dart';
import 'components/navbar_component.dart';
import 'components/paragraph_component.dart';
import 'components/spacer_component.dart';
import 'components/text_component.dart';
import 'data_context.dart';
import 'template_engine.dart';

typedef ComponentBuilder = Widget Function(
  ComponentNode node,
  DataContext context,
  TemplateEngine engine,
);

class ComponentRegistry {
  final Map<ComponentType, ComponentBuilder> _builders;

  ComponentRegistry(this._builders);

  factory ComponentRegistry.defaults() {
    return ComponentRegistry({
      ComponentType.container: ContainerComponent.build,
      ComponentType.section: ContainerComponent.build,
      ComponentType.heading: HeadingComponent.build,
      ComponentType.paragraph: ParagraphComponent.build,
      ComponentType.text: TextComponent.build,
      ComponentType.label: TextComponent.build,
      ComponentType.image: ImageComponent.build,
      ComponentType.button: ButtonComponent.build,
      ComponentType.link: LinkComponent.build,
      ComponentType.icon: IconComponent.build,
      ComponentType.avatar: AvatarComponent.build,
      ComponentType.divider: DividerComponent.build,
      ComponentType.spacer: SpacerComponent.build,
      ComponentType.navbar: NavbarComponent.build,
      ComponentType.footer: FooterComponent.build,
    });
  }

  void register(ComponentType type, ComponentBuilder builder) {
    _builders[type] = builder;
  }

  ComponentBuilder resolve(ComponentType type) {
    return _builders[type] ?? _unknownComponent;
  }

  static Widget _unknownComponent(
    ComponentNode node,
    DataContext context,
    TemplateEngine engine,
  ) {
    assert(() {
      debugPrint(
        '[super_webflow] Unknown component type: ${node.type.name} (id: ${node.id})',
      );
      return true;
    }());
    return const SizedBox.shrink();
  }
}
