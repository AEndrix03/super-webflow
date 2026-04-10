class ValidationError {
  final String? rule;
  final String severity;
  final String? nodeId;
  final String path;
  final String message;

  const ValidationError({
    this.rule,
    required this.severity,
    this.nodeId,
    required this.path,
    required this.message,
  });

  @override
  String toString() => '[${rule ?? 'schema'}] $path: $message';
}

class ValidationResult {
  final bool valid;
  final List<ValidationError> errors;

  const ValidationResult({required this.valid, required this.errors});

  factory ValidationResult.pass() =>
      const ValidationResult(valid: true, errors: []);

  factory ValidationResult.fail(List<ValidationError> errors) =>
      ValidationResult(valid: errors.isEmpty, errors: errors);
}
