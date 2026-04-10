import 'package:freezed_annotation/freezed_annotation.dart';

part 'interaction.freezed.dart';
part 'interaction.g.dart';

@freezed
class AnimationDef with _$AnimationDef {
  const factory AnimationDef({
    required String type,
    required int duration,
    String? easing,
    int? delay,
  }) = _AnimationDef;

  factory AnimationDef.fromJson(Map<String, dynamic> json) =>
      _$AnimationDefFromJson(json);
}

sealed class Action {
  const Action();

  factory Action.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'navigate' => NavigateAction.fromJson(json),
      'scroll-to' => ScrollToAction.fromJson(json),
      'toggle-visibility' => ToggleVisibilityAction.fromJson(json),
      'set-visibility' => SetVisibilityAction.fromJson(json),
      'toggle-class' => ToggleClassAction.fromJson(json),
      'add-class' => AddClassAction.fromJson(json),
      'remove-class' => RemoveClassAction.fromJson(json),
      'open-modal' => OpenModalAction.fromJson(json),
      'close-modal' => CloseModalAction.fromJson(json),
      'submit-form' => SubmitFormAction.fromJson(json),
      'reset-form' => ResetFormAction.fromJson(json),
      'open-booking' => const OpenBookingAction(),
      'copy-text' => CopyTextAction.fromJson(json),
      'play-video' => PlayVideoAction.fromJson(json),
      'pause-video' => PauseVideoAction.fromJson(json),
      'toggle-video' => ToggleVideoAction.fromJson(json),
      'open-link' => OpenLinkAction.fromJson(json),
      'send-analytics' => SendAnalyticsAction.fromJson(json),
      'set-var' => SetVarAction.fromJson(json),
      'toggle-var' => ToggleVarAction.fromJson(json),
      _ => throw FormatException('Unknown action type: ${json['type']}'),
    };
  }

  Map<String, dynamic> toJson();
}

class ActionConverter implements JsonConverter<Action, Map<String, dynamic>> {
  const ActionConverter();

  @override
  Action fromJson(Map<String, dynamic> json) => Action.fromJson(json);

  @override
  Map<String, dynamic> toJson(Action object) => object.toJson();
}

class NavigateAction extends Action {
  final String url;
  final String? target;

  const NavigateAction({required this.url, this.target});

  factory NavigateAction.fromJson(Map<String, dynamic> json) =>
      NavigateAction(url: json['url'] as String, target: json['target'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'navigate', 'url': url, if (target != null) 'target': target};
}

class ScrollToAction extends Action {
  final String nodeId;
  final String? behavior;
  final double? offset;

  const ScrollToAction({required this.nodeId, this.behavior, this.offset});

  factory ScrollToAction.fromJson(Map<String, dynamic> json) => ScrollToAction(
        nodeId: json['nodeId'] as String,
        behavior: json['behavior'] as String?,
        offset: (json['offset'] as num?)?.toDouble(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'scroll-to',
        'nodeId': nodeId,
        if (behavior != null) 'behavior': behavior,
        if (offset != null) 'offset': offset,
      };
}

class ToggleVisibilityAction extends Action {
  final String nodeId;

  const ToggleVisibilityAction({required this.nodeId});

  factory ToggleVisibilityAction.fromJson(Map<String, dynamic> json) =>
      ToggleVisibilityAction(nodeId: json['nodeId'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'toggle-visibility', 'nodeId': nodeId};
}

class SetVisibilityAction extends Action {
  final String nodeId;
  final bool visible;

  const SetVisibilityAction({required this.nodeId, required this.visible});

  factory SetVisibilityAction.fromJson(Map<String, dynamic> json) =>
      SetVisibilityAction(nodeId: json['nodeId'] as String, visible: json['visible'] as bool);

  @override
  Map<String, dynamic> toJson() => {'type': 'set-visibility', 'nodeId': nodeId, 'visible': visible};
}

class ToggleClassAction extends Action {
  final String className;
  final String? nodeId;

  const ToggleClassAction({required this.className, this.nodeId});

  factory ToggleClassAction.fromJson(Map<String, dynamic> json) => ToggleClassAction(
        className: json['className'] as String,
        nodeId: json['nodeId'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {'type': 'toggle-class', 'className': className, if (nodeId != null) 'nodeId': nodeId};
}

class AddClassAction extends Action {
  final String className;
  final String? nodeId;

  const AddClassAction({required this.className, this.nodeId});

  factory AddClassAction.fromJson(Map<String, dynamic> json) =>
      AddClassAction(className: json['className'] as String, nodeId: json['nodeId'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'add-class', 'className': className, if (nodeId != null) 'nodeId': nodeId};
}

class RemoveClassAction extends Action {
  final String className;
  final String? nodeId;

  const RemoveClassAction({required this.className, this.nodeId});

  factory RemoveClassAction.fromJson(Map<String, dynamic> json) =>
      RemoveClassAction(className: json['className'] as String, nodeId: json['nodeId'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'remove-class', 'className': className, if (nodeId != null) 'nodeId': nodeId};
}

class OpenModalAction extends Action {
  final String modalId;

  const OpenModalAction({required this.modalId});

  factory OpenModalAction.fromJson(Map<String, dynamic> json) =>
      OpenModalAction(modalId: json['modalId'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'open-modal', 'modalId': modalId};
}

class CloseModalAction extends Action {
  final String? modalId;

  const CloseModalAction({this.modalId});

  factory CloseModalAction.fromJson(Map<String, dynamic> json) =>
      CloseModalAction(modalId: json['modalId'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'close-modal', if (modalId != null) 'modalId': modalId};
}

class SubmitFormAction extends Action {
  final String? formId;

  const SubmitFormAction({this.formId});

  factory SubmitFormAction.fromJson(Map<String, dynamic> json) =>
      SubmitFormAction(formId: json['formId'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'submit-form', if (formId != null) 'formId': formId};
}

class ResetFormAction extends Action {
  final String? formId;

  const ResetFormAction({this.formId});

  factory ResetFormAction.fromJson(Map<String, dynamic> json) =>
      ResetFormAction(formId: json['formId'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'reset-form', if (formId != null) 'formId': formId};
}

class OpenBookingAction extends Action {
  const OpenBookingAction();

  @override
  Map<String, dynamic> toJson() => const {'type': 'open-booking'};
}

class CopyTextAction extends Action {
  final String text;

  const CopyTextAction({required this.text});

  factory CopyTextAction.fromJson(Map<String, dynamic> json) =>
      CopyTextAction(text: json['text'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'copy-text', 'text': text};
}

class PlayVideoAction extends Action {
  final String nodeId;

  const PlayVideoAction({required this.nodeId});

  factory PlayVideoAction.fromJson(Map<String, dynamic> json) =>
      PlayVideoAction(nodeId: json['nodeId'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'play-video', 'nodeId': nodeId};
}

class PauseVideoAction extends Action {
  final String nodeId;

  const PauseVideoAction({required this.nodeId});

  factory PauseVideoAction.fromJson(Map<String, dynamic> json) =>
      PauseVideoAction(nodeId: json['nodeId'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'pause-video', 'nodeId': nodeId};
}

class ToggleVideoAction extends Action {
  final String nodeId;

  const ToggleVideoAction({required this.nodeId});

  factory ToggleVideoAction.fromJson(Map<String, dynamic> json) =>
      ToggleVideoAction(nodeId: json['nodeId'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'toggle-video', 'nodeId': nodeId};
}

class OpenLinkAction extends Action {
  final String url;
  final String? target;

  const OpenLinkAction({required this.url, this.target});

  factory OpenLinkAction.fromJson(Map<String, dynamic> json) =>
      OpenLinkAction(url: json['url'] as String, target: json['target'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': 'open-link', 'url': url, if (target != null) 'target': target};
}

class SendAnalyticsAction extends Action {
  final String event;
  final Map<String, dynamic>? payload;

  const SendAnalyticsAction({required this.event, this.payload});

  factory SendAnalyticsAction.fromJson(Map<String, dynamic> json) => SendAnalyticsAction(
        event: json['event'] as String,
        payload: (json['payload'] as Map?)?.cast<String, dynamic>(),
      );

  @override
  Map<String, dynamic> toJson() => {'type': 'send-analytics', 'event': event, if (payload != null) 'payload': payload};
}

class SetVarAction extends Action {
  final String name;
  final Object? value;

  const SetVarAction({required this.name, this.value});

  factory SetVarAction.fromJson(Map<String, dynamic> json) =>
      SetVarAction(name: json['name'] as String, value: json['value']);

  @override
  Map<String, dynamic> toJson() => {'type': 'set-var', 'name': name, 'value': value};
}

class ToggleVarAction extends Action {
  final String name;

  const ToggleVarAction({required this.name});

  factory ToggleVarAction.fromJson(Map<String, dynamic> json) =>
      ToggleVarAction(name: json['name'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': 'toggle-var', 'name': name};
}

@freezed
class Interaction with _$Interaction {
  const factory Interaction({
    required String trigger,
    @ActionConverter() required Action action,
    AnimationDef? animation,
  }) = _Interaction;

  factory Interaction.fromJson(Map<String, dynamic> json) =>
      _$InteractionFromJson(json);
}
