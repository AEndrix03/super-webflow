import 'dart:convert';

import '../models/template_document.dart';
import 'schema_validator.dart';
import 'semantic_validator.dart';
import 'validation_error.dart';

class Validator {
  final SchemaValidator _schema;
  final SemanticValidator _semantic;

  Validator()
      : _schema = SchemaValidator(),
        _semantic = SemanticValidator();

  ValidationResult validateJson(String jsonString) {
    late TemplateDocument doc;
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      doc = TemplateDocument.fromJson(map);
    } catch (e) {
      return ValidationResult.fail([
        ValidationError(
          rule: null,
          severity: 'error',
          path: '/',
          message: 'Parse error: $e',
        ),
      ]);
    }
    return validateDocument(doc);
  }

  ValidationResult validateDocument(TemplateDocument doc) {
    final errors = [..._schema.validate(doc), ..._semantic.validate(doc)];
    return ValidationResult(valid: errors.isEmpty, errors: errors);
  }
}
