# Super-WebFlow UI Contract Language

A platform-agnostic JSON schema for declarative UI templates.  
Write once, render anywhere — Angular web app, Flutter mobile, or any future engine.

---

## What it is

The UI Contract Language (UI-CL) is a versioned specification for describing complete UI pages as structured JSON documents. A document contains:

- a **Theme** (design tokens: colors, typography, spacing, radii, shadows)
- a **DataSchema** (what data fields the template expects at runtime)
- one or more **Pages** (recursive component trees)
- optional **Globals** (shared navbar/footer)
- optional **Prototype** (navigation links between pages)

Any engine that implements the specification can render the same document without modification.

---

## Repository structure

```
spec/
└── v1.0/
    ├── template.schema.json   ← JSON Schema Draft 2020-12 (formal validation)
    ├── functional-spec.md     ← Behavioural rules not expressible in JSON Schema
    └── examples/
        ├── minimal.json       ← Minimal valid document (hero + contact form)
        └── coach-landing.json ← Full coach website template
CHANGELOG.md
README.md
```

---

## Quick start

### 1. Validate a document

```bash
# Using ajv-cli
npx ajv validate \
  -s spec/v1.0/template.schema.json \
  -d spec/v1.0/examples/minimal.json \
  --spec=draft2020
```

### 2. Reference the schema in your document

```json
{
  "$schema": "https://ui-schema.Super-WebFlow.io/v1.0/template.schema.json",
  "version": "1.0",
  "id": "my-template",
  ...
}
```

### 3. Use in TypeScript

```bash
npm install  # (once the package is published)
```

```typescript
import type { TemplateDocument } from "@Super-WebFlow/ui-schema";

function loadTemplate(json: unknown): TemplateDocument {
  // validate against schema, then cast
  return json as TemplateDocument;
}
```

The TypeScript type definitions are in `Super-WebFlow-template.schema.d.ts`.

---

## Compliance tiers

Engines MUST implement Tier 1 and Tier 2 to be considered compliant.

| Tier  | Components                                                                                                                                                   | Requirement                                                              |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| **1** | `container`, `section`, `row`, `column`, `grid`, `stack`, `heading`, `paragraph`, `text`, `image`, `button`, `link`, `divider`, `spacer`, `navbar`, `footer` | Required                                                                 |
| **2** | `hero`, `service-card`, `pricing-card`, `testimonial`, `contact-form`, `booking-widget`, `photo-gallery`, `coach-stats`, `social-links`, `modal`             | Required                                                                 |
| **3** | All remaining types                                                                                                                                          | Optional; renders empty container with dev-mode warning if unimplemented |

---

## Versioning

Follows `MAJOR.MINOR` semantic versioning.

- **MAJOR** — breaking changes; old documents fail validation against new schema
- **MINOR** — backward-compatible additions (new optional fields, new enum values, new component types)

Every document declares its schema version in `"version"`. Engines MUST refuse to render documents with unsupported versions.

See [CHANGELOG.md](CHANGELOG.md) for the full history.

---

## Spec quick reference

| Topic                                      | Where defined                             |
| ------------------------------------------ | ----------------------------------------- |
| All JSON types and validation rules        | `spec/v1.0/template.schema.json`          |
| Value resolution (colors, sizes, spacing…) | `functional-spec.md §3`                   |
| Component rendering order                  | `functional-spec.md §4`                   |
| Data binding & transforms                  | `functional-spec.md §5`                   |
| Interaction dispatch                       | `functional-spec.md §6`                   |
| Responsive merge algorithm                 | `functional-spec.md §7`                   |
| Validation rules R01–R17                   | `functional-spec.md §8`                   |
| Error handling contract                    | `functional-spec.md §9`                   |
| Per-type component props                   | `Super-WebFlow-template.schema.d.ts` Appendix A |

---

## License

MIT — free to use for any project.


