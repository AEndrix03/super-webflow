import 'package:freezed_annotation/freezed_annotation.dart';

import 'component_node.dart';
import 'data_binding.dart';
import 'interaction.dart';
import 'theme.dart';

part 'template_document.freezed.dart';
part 'template_document.g.dart';

class PrototypeDestinationConverter
    implements JsonConverter<PrototypeDestination, Map<String, dynamic>> {
  const PrototypeDestinationConverter();

  @override
  PrototypeDestination fromJson(Map<String, dynamic> json) =>
      PrototypeDestination.fromJson(json);

  @override
  Map<String, dynamic> toJson(PrototypeDestination object) => object.toJson();
}

sealed class PrototypeDestination {
  const PrototypeDestination();

  factory PrototypeDestination.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'page' => PageDestination.fromJson(json),
        'section' => SectionDestination.fromJson(json),
        'overlay' => OverlayDestination.fromJson(json),
        'url' => UrlDestination.fromJson(json),
        'back' => const BackDestination(),
        _ => throw FormatException('Unknown destination type: ${json['type']}'),
      };

  Map<String, dynamic> toJson();
}

class PageDestination extends PrototypeDestination {
  final String pageId;

  const PageDestination({required this.pageId});

  factory PageDestination.fromJson(Map<String, dynamic> json) =>
      PageDestination(pageId: json['pageId'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'page', 'pageId': pageId};
}

class SectionDestination extends PrototypeDestination {
  final String nodeId;
  final String? templateId;

  const SectionDestination({required this.nodeId, this.templateId});

  factory SectionDestination.fromJson(Map<String, dynamic> json) =>
      SectionDestination(
        nodeId: json['nodeId'] as String,
        templateId: json['templateId'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'section',
        'nodeId': nodeId,
        if (templateId != null) 'templateId': templateId,
      };
}

class OverlayDestination extends PrototypeDestination {
  final String overlayId;
  final String? position;

  const OverlayDestination({required this.overlayId, this.position});

  factory OverlayDestination.fromJson(Map<String, dynamic> json) =>
      OverlayDestination(
        overlayId: json['overlayId'] as String,
        position: json['position'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'overlay',
        'overlayId': overlayId,
        if (position != null) 'position': position,
      };
}

class UrlDestination extends PrototypeDestination {
  final String url;
  final String? target;

  const UrlDestination({required this.url, this.target});

  factory UrlDestination.fromJson(Map<String, dynamic> json) =>
      UrlDestination(url: json['url'] as String, target: json['target'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'url', 'url': url, if (target != null) 'target': target};
}

class BackDestination extends PrototypeDestination {
  const BackDestination();

  @override
  Map<String, dynamic> toJson() => const {'type': 'back'};
}

@freezed
class PrototypeTransition with _$PrototypeTransition {
  const factory PrototypeTransition({
    required String type,
    int? duration,
    String? easing,
  }) = _PrototypeTransition;

  factory PrototypeTransition.fromJson(Map<String, dynamic> json) =>
      _$PrototypeTransitionFromJson(json);
}

@freezed
class PrototypeSource with _$PrototypeSource {
  const factory PrototypeSource({required String nodeId, required String trigger}) =
      _PrototypeSource;

  factory PrototypeSource.fromJson(Map<String, dynamic> json) =>
      _$PrototypeSourceFromJson(json);
}

@freezed
class PrototypeConnection with _$PrototypeConnection {
  const factory PrototypeConnection({
    required String id,
    required PrototypeSource source,
    @PrototypeDestinationConverter() required PrototypeDestination destination,
    PrototypeTransition? transition,
  }) = _PrototypeConnection;

  factory PrototypeConnection.fromJson(Map<String, dynamic> json) =>
      _$PrototypeConnectionFromJson(json);
}

@freezed
class PrototypeOverlay with _$PrototypeOverlay {
  const factory PrototypeOverlay({
    required String id,
    required String nodeId,
    required String position,
    bool? backdrop,
    String? backdropColor,
    bool? closeOnBackdropClick,
    bool? closeOnEsc,
    AnimationDef? animation,
  }) = _PrototypeOverlay;

  factory PrototypeOverlay.fromJson(Map<String, dynamic> json) =>
      _$PrototypeOverlayFromJson(json);
}

@freezed
class PrototypeFlow with _$PrototypeFlow {
  const factory PrototypeFlow({
    required String id,
    required String name,
    required String startNodeId,
    String? description,
  }) = _PrototypeFlow;

  factory PrototypeFlow.fromJson(Map<String, dynamic> json) =>
      _$PrototypeFlowFromJson(json);
}

@freezed
class PrototypeSchema with _$PrototypeSchema {
  const factory PrototypeSchema({
    required String version,
    required String id,
    String? name,
    required String startPageId,
    required List<PrototypeConnection> connections,
    List<PrototypeOverlay>? overlays,
    List<PrototypeFlow>? flows,
  }) = _PrototypeSchema;

  factory PrototypeSchema.fromJson(Map<String, dynamic> json) =>
      _$PrototypeSchemaFromJson(json);
}

@freezed
class FontAsset with _$FontAsset {
  const factory FontAsset({
    required String family,
    required String url,
    Object? weight,
    String? style,
    String? display,
  }) = _FontAsset;

  factory FontAsset.fromJson(Map<String, dynamic> json) =>
      _$FontAssetFromJson(json);
}

@freezed
class IconSetDef with _$IconSetDef {
  const factory IconSetDef({
    required String provider,
    List<String>? subset,
    String? customUrl,
  }) = _IconSetDef;

  factory IconSetDef.fromJson(Map<String, dynamic> json) =>
      _$IconSetDefFromJson(json);
}

@freezed
class ScriptDef with _$ScriptDef {
  const factory ScriptDef({
    required String src,
    bool? async,
    bool? defer,
    required String position,
    String? condition,
  }) = _ScriptDef;

  factory ScriptDef.fromJson(Map<String, dynamic> json) =>
      _$ScriptDefFromJson(json);
}

@freezed
class AssetsSchema with _$AssetsSchema {
  const factory AssetsSchema({
    List<FontAsset>? fonts,
    IconSetDef? icons,
    Map<String, String>? images,
    List<ScriptDef>? scripts,
  }) = _AssetsSchema;

  factory AssetsSchema.fromJson(Map<String, dynamic> json) =>
      _$AssetsSchemaFromJson(json);
}

@freezed
class TemplateMeta with _$TemplateMeta {
  const factory TemplateMeta({
    required String title,
    String? description,
    List<String>? keywords,
    String? favicon,
    String? ogImage,
    String? canonicalUrl,
    bool? noIndex,
    Map<String, dynamic>? structuredData,
  }) = _TemplateMeta;

  factory TemplateMeta.fromJson(Map<String, dynamic> json) =>
      _$TemplateMetaFromJson(json);
}

@freezed
class TemplateGlobals with _$TemplateGlobals {
  const factory TemplateGlobals({
    required ComponentNode navbar,
    required ComponentNode footer,
    List<String>? styles,
  }) = _TemplateGlobals;

  factory TemplateGlobals.fromJson(Map<String, dynamic> json) =>
      _$TemplateGlobalsFromJson(json);
}

@freezed
class EngineHints with _$EngineHints {
  const factory EngineHints({
    bool? preferSSR,
    bool? lazyLoadImages,
    bool? enableAnimations,
    bool? reduceMotion,
    bool? rtl,
    String? locale,
    double? baseFontSize,
  }) = _EngineHints;

  factory EngineHints.fromJson(Map<String, dynamic> json) =>
      _$EngineHintsFromJson(json);
}

@freezed
class TemplateDocument with _$TemplateDocument {
  const factory TemplateDocument({
    @JsonKey(name: r'$schema') required String schema,
    required String version,
    required String id,
    required String name,
    String? category,
    List<String>? tags,
    String? author,
    String? thumbnail,
    String? createdAt,
    String? updatedAt,
    required ThemeSchema theme,
    required TemplateMeta meta,
    required Map<String, DataFieldDef> dataSchema,
    TemplateGlobals? globals,
    required Map<String, ComponentNode> pages,
    AssetsSchema? assets,
    PrototypeSchema? prototype,
    EngineHints? engineHints,
  }) = _TemplateDocument;

  factory TemplateDocument.fromJson(Map<String, dynamic> json) =>
      _$TemplateDocumentFromJson(json);
}
