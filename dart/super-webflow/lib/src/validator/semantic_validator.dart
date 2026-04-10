import '../models/component_node.dart';
import '../models/template_document.dart';
import 'schema_validator.dart';
import 'validation_error.dart';

class SemanticValidator {
  List<ValidationError> validate(TemplateDocument doc) {
    final errors = <ValidationError>[];
    final walker = SchemaValidator();

    final seenIds = <String, String>{};
    walker.walkNodes(doc, (node, path) {
      final first = seenIds[node.id];
      if (first != null) {
        errors.add(
          ValidationError(
            rule: 'R01',
            severity: 'error',
            nodeId: node.id,
            path: path,
            message: 'Duplicate node id "${node.id}". First occurrence: $first',
          ),
        );
      } else {
        seenIds[node.id] = path;
      }

      if (node.data?.listField != null) {
        final hasChildren = (node.children?.isNotEmpty ?? false);
        if (!hasChildren) {
          errors.add(
            ValidationError(
              rule: 'R03',
              severity: 'error',
              nodeId: node.id,
              path: path,
              message:
                  'Node "${node.id}" has data.listField but no children. At least one child is required.',
            ),
          );
        }
      }

      final gradient = node.style?.backgroundGradient;
      if (gradient != null && gradient.stops.length < 2) {
        errors.add(
          ValidationError(
            rule: 'R09',
            severity: 'error',
            nodeId: node.id,
            path: '$path/style/backgroundGradient/stops',
            message: 'GradientDef.stops must contain at least 2 items.',
          ),
        );
      }
    });

    for (final entry in doc.pages.entries) {
      final root = entry.value;
      if (root.type != ComponentType.pageWrapper) {
        continue;
      }
      _walkChildrenForPageWrapper(root, '/pages/${entry.key}', errors);
    }

    return errors;
  }

  void _walkChildrenForPageWrapper(
    ComponentNode node,
    String path,
    List<ValidationError> errors,
  ) {
    final children = node.children;
    if (children == null) {
      return;
    }
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final childPath = '$path/children/$i';
      if (child.type == ComponentType.pageWrapper) {
        errors.add(
          ValidationError(
            rule: 'R08',
            severity: 'error',
            nodeId: child.id,
            path: childPath,
            message: 'page-wrapper can only be used as page root.',
          ),
        );
      }
      _walkChildrenForPageWrapper(child, childPath, errors);
    }
  }
}
