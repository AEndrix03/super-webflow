# super_webflow

UI Contract Language validator and Flutter renderer for `ui-contract` v1.0.

## Quick Start

```dart
import 'dart:convert';

import 'package:super_webflow/super_webflow.dart';

final validator = Validator();
final result = validator.validateJson(jsonString);
if (!result.valid) {
  // handle errors
}

final doc = TemplateDocument.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

TemplateRenderer(
  document: doc,
  data: {
    'coach': {
      'fullName': 'Mario Rossi',
    }
  },
  pageId: 'home',
);
```
