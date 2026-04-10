import 'package:freezed_annotation/freezed_annotation.dart';

import 'data_binding.dart';
import 'interaction.dart';
import 'layout_props.dart';
import 'style_props.dart';

part 'component_node.freezed.dart';
part 'component_node.g.dart';

enum ComponentType {
  container,
  section,
  row,
  column,
  grid,
  stack,
  @JsonValue('scroll-view')
  scrollView,
  @JsonValue('page-wrapper')
  pageWrapper,
  heading,
  paragraph,
  text,
  label,
  @JsonValue('rich-text')
  richText,
  code,
  image,
  video,
  icon,
  avatar,
  lottie,
  divider,
  spacer,
  badge,
  chip,
  tag,
  button,
  link,
  @JsonValue('social-link-item')
  socialLinkItem,
  navbar,
  footer,
  breadcrumb,
  tabs,
  pagination,
  form,
  input,
  textarea,
  select,
  checkbox,
  radio,
  toggle,
  @JsonValue('file-upload')
  fileUpload,
  @JsonValue('contact-form')
  contactForm,
  @JsonValue('booking-widget')
  bookingWidget,
  list,
  accordion,
  modal,
  tooltip,
  @JsonValue('progress-bar')
  progressBar,
  rating,
  hero,
  @JsonValue('service-card')
  serviceCard,
  @JsonValue('pricing-card')
  pricingCard,
  testimonial,
  @JsonValue('coach-stats')
  coachStats,
  @JsonValue('certification-badge')
  certificationBadge,
  @JsonValue('photo-gallery')
  photoGallery,
  @JsonValue('review-stars')
  reviewStars,
  @JsonValue('social-links')
  socialLinks,
  @JsonValue('calendar-widget')
  calendarWidget,
  @JsonValue('before-after')
  beforeAfter,
}

@freezed
class BuilderMeta with _$BuilderMeta {
  const factory BuilderMeta({
    bool? editable,
    bool? resizable,
    bool? movable,
    bool? deletable,
    String? group,
    String? icon,
    String? description,
    Map<String, dynamic>? previewData,
  }) = _BuilderMeta;

  factory BuilderMeta.fromJson(Map<String, dynamic> json) =>
      _$BuilderMetaFromJson(json);
}

@freezed
class ComponentNode with _$ComponentNode {
  const factory ComponentNode({
    required String id,
    required ComponentType type,
    String? name,
    @Default(false) bool locked,
    List<ComponentNode>? children,
    Map<String, dynamic>? props,
    StyleProps? style,
    LayoutProps? layout,
    Map<String, Map<String, dynamic>>? responsive,
    DataBinding? data,
    DataCondition? condition,
    List<Interaction>? interactions,
    String? role,
    String? ariaLabel,
    String? ariaLive,
    int? tabIndex,
    @JsonKey(name: '_builder') BuilderMeta? builder,
  }) = _ComponentNode;

  factory ComponentNode.fromJson(Map<String, dynamic> json) =>
      _$ComponentNodeFromJson(json);
}
