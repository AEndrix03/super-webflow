import '../models/component_node.dart';
import '../models/template_document.dart';
import 'validation_error.dart';

class SchemaValidator {
  static const _expectedSchema =
      'https://aredegalli.it/super-webflow/v1.0/template.schema.json';
  static final _idRegex = RegExp(r'^[a-z0-9][a-z0-9-]*[a-z0-9]$');

  List<ValidationError> validate(TemplateDocument doc) {
    final errors = <ValidationError>[];

    if (doc.schema != _expectedSchema) {
      errors.add(
        ValidationError(
          rule: 'schema',
          severity: 'error',
          path: '/\$schema',
          message: 'Invalid schema URL: ${doc.schema}',
        ),
      );
    }

    if (doc.version != '1.0') {
      errors.add(
        ValidationError(
          rule: 'schema',
          severity: 'error',
          path: '/version',
          message: 'Unsupported version: ${doc.version}',
        ),
      );
    }

    if (!_idRegex.hasMatch(doc.id)) {
      errors.add(
        const ValidationError(
          rule: 'R16',
          severity: 'error',
          path: '/id',
          message:
              'TemplateDocument.id must match ^[a-z0-9][a-z0-9-]*[a-z0-9]\$',
        ),
      );
    }

    if (!doc.pages.containsKey('home')) {
      errors.add(
        const ValidationError(
          rule: 'R07',
          severity: 'error',
          path: '/pages',
          message: 'pages.home is required.',
        ),
      );
    }

    final colorValues = doc.theme.colors.toJson().values;
    if (colorValues.any((e) => e == null || (e is String && e.isEmpty))) {
      errors.add(
        const ValidationError(
          rule: 'R06',
          severity: 'error',
          path: '/theme/colors',
          message: 'theme.colors must contain all required non-empty fields.',
        ),
      );
    }

    final scale = doc.theme.typography.scale.toJson();
    const requiredScaleKeys = [
      'xs',
      'sm',
      'base',
      'lg',
      'xl',
      '2xl',
      '3xl',
      '4xl',
      '5xl',
      '6xl',
      '7xl',
    ];
    for (final key in requiredScaleKeys) {
      if (!scale.containsKey(key)) {
        errors.add(
          ValidationError(
            rule: 'schema',
            severity: 'error',
            path: '/theme/typography/scale',
            message: 'Missing scale key: $key',
          ),
        );
      }
    }

    return errors;
  }

  void walkNodes(
    TemplateDocument doc,
    void Function(ComponentNode node, String path) visitor,
  ) {
    if (doc.globals?.navbar case final navbar?) {
      _walkNode(navbar, '/globals/navbar', visitor);
    }
    if (doc.globals?.footer case final footer?) {
      _walkNode(footer, '/globals/footer', visitor);
    }
    for (final entry in doc.pages.entries) {
      _walkNode(entry.value, '/pages/${entry.key}', visitor);
    }
  }

  void _walkNode(
    ComponentNode node,
    String path,
    void Function(ComponentNode node, String path) visitor,
  ) {
    visitor(node, path);
    final children = node.children;
    if (children == null) {
      return;
    }
    for (var i = 0; i < children.length; i++) {
      _walkNode(children[i], '$path/children/$i', visitor);
    }
  }
}
