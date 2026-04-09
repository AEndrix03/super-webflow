# Super-WebFlow UI Contract Language — Functional Specification

**Version:** 1.0  
**Status:** Stable  
**Schema:** `https://ui-schema.Super-WebFlow.io/v1.0/template.schema.json`  
**Changelog:** See `CHANGELOG.md`

---

## 1. Overview

This document specifies the behavioural rules governing the Super-WebFlow UI Contract Language (UI-CL).
The JSON Schema (`template.schema.json`) defines structural validity.
This document defines **semantic correctness**: rules that cannot be expressed in JSON Schema alone.

Every engine (Angular, Flutter, or any future renderer) MUST implement this specification in full.
An engine is considered **compliant** only when it passes the reference test suite located at `spec/v1.0/tests/`.

### 1.1 Terminology

| Term             | Meaning                                                                                 |
| ---------------- | --------------------------------------------------------------------------------------- |
| **engine**       | Any renderer that consumes a TemplateDocument and produces a UI                         |
| **MUST**         | Mandatory. Non-compliance is a spec violation.                                          |
| **SHOULD**       | Strongly recommended. Deviation requires justification.                                 |
| **MAY**          | Optional. Engines may implement or omit.                                                |
| **DataContext**  | The runtime object holding all resolved data for a template                             |
| **token**        | A named key in `ThemeColors`, `ThemeTypography.scale`, `ThemeShadows`, or `ThemeZIndex` |
| **@webOnly**     | Property ignored silently by non-web engines                                            |
| **@flutterOnly** | Property ignored silently by non-Flutter engines                                        |

---

## 2. Document Lifecycle

Before rendering, an engine MUST execute the following pipeline in order:

```
1. Parse       → JSON parse the document string
2. Validate    → Validate against template.schema.json (structural)
3. Lint        → Apply semantic validation rules (§8)
4. Hydrate     → Inject DataContext into the document
5. Render      → Execute the rendering pipeline (§4)
```

**Parse failure** → surface to caller as a fatal error with the parse error message.  
**Validation failure** → surface all JSON Schema errors; abort rendering.  
**Lint failure** → surface all rule violations as structured errors (§8.2); abort rendering by default; WARN-only mode available for development.  
**Hydrate/Render failure** → per-node error handling per §9.

---

## 3. Value Resolution

### 3.1 Color Resolution

When a `Color` value is encountered, the engine resolves it in this order:

1. If the string matches a key in `theme.colors`, use `theme.colors[key]`.
2. Otherwise treat the value as a raw CSS color string.

Resolution is case-sensitive. `"Primary"` is NOT the same as `"primary"`.

```
"primary"             → theme.colors.primary  (e.g. "#6C5CE7")
"#6C5CE7"             → "#6C5CE7"  (raw)
"rgba(108,92,231,0.8)"→ "rgba(108,92,231,0.8)"  (raw)
"surface"             → theme.colors.surface
"SURFACE"             → treated as raw; no match; WARN in dev mode
```

### 3.2 SizeValue Resolution

| Input                | Web output                                  | Flutter output                           |
| -------------------- | ------------------------------------------- | ---------------------------------------- |
| `number` (e.g. `24`) | `24px`                                      | `24.0` logical pixels                    |
| `"50%"`              | `50%`                                       | `FractionallySizedBox(widthFactor: 0.5)` |
| `"auto"`             | `auto`                                      | `null` (Flutter default)                 |
| `"fill"`             | `flex: 1` / `width: 100%` context-dependent | `Expanded`                               |
| `"wrap"`             | `fit-content`                               | `IntrinsicWidth` / `IntrinsicHeight`     |
| `"screen"`           | `100vw` or `100vh` context-dependent        | `MediaQuery.of(context).size`            |
| `"50vw"` @webOnly    | `50vw`                                      | warn + MediaQuery equivalent             |
| `"50vh"` @webOnly    | `50vh`                                      | warn + MediaQuery equivalent             |

### 3.3 Spacing Resolution

Shorthand follows CSS conventions:

- `16` → all sides `16`
- `[16, 24]` → top/bottom `16`, right/left `24`
- `[8, 16, 24, 32]` → top `8`, right `16`, bottom `24`, left `32`
- Object form → each key sets its side; unset sides default to `0`

**Precedence:** individual props (`paddingTop`, `marginLeft`, …) override shorthand (`padding`, `margin`) when both appear on the same node.  
`paddingX` sets left and right; `paddingY` sets top and bottom. If both `paddingX` and `paddingLeft` are set on the same node, `paddingLeft` wins.

### 3.4 FontSize Resolution

- `number` → used as-is in px / logical pixels
- `FontSizeKey` → `theme.typography.scale[key]`

If the key is absent from the theme scale, fall back to `theme.typography.scale.base` and warn.

### 3.5 Shadow Resolution

- String key `"sm" | "md" | "lg" | "xl" | "inner"` → `theme.shadows[key]`
- `"none"` → no shadow (removes any inherited shadow)
- Inline `ShadowDef` → used directly
- `ShadowDef[]` → multiple shadows @webOnly; Flutter engines use the first element

`theme.shadows.none` MUST be `null`. Engines MUST treat `null` as "no shadow applied".

### 3.6 FontFamily Resolution

- `"heading"` → `theme.typography.fonts.heading`
- `"body"` → `theme.typography.fonts.body`
- `"mono"` → `theme.typography.fonts.mono`; if undefined in theme, fall back to system monospace
- Any other string → used as-is

### 3.7 ZIndex Resolution

- Integer → used directly
- String key → `theme.zIndex[key]`

### 3.8 Transition Resolution

- `"fast"` → `{ property:"all", duration:theme.transitions.fast, easing:theme.transitions.easing.default }`
- `"normal"` → `{ property:"all", duration:theme.transitions.normal, easing:theme.transitions.easing.default }`
- `"slow"` → `{ property:"all", duration:theme.transitions.slow, easing:theme.transitions.easing.default }`
- `TransitionDef` or `TransitionDef[]` → used directly

Transitions are @webOnly. Flutter engines MUST silently ignore the `transition` property.

---

## 4. ComponentNode Rendering Pipeline

For every `ComponentNode`, an engine MUST execute the following steps in order. Deviating from this order is a spec violation.

```
Step 1 — Condition check
  If node.condition is present:
    Evaluate condition against DataContext (§5.3)
    If FALSE → render nothing; children are NOT evaluated. STOP.
              (web: display:none  |  Flutter: Visibility(visible:false))

Step 2 — List expansion
  If node.data.listField is present:
    Resolve array at listField from DataContext
    Apply data.sort if present (stable sort)
    Apply data.limit if present (take first N elements)
    For each item at index i:
      Clone child DataContext:
        parent context fields
        + [data.itemAlias  ?? "item"]  = item
        + [data.indexAlias ?? "index"] = i
      Render each child of node in the cloned context
    STOP — do not proceed to step 3 for the list container itself.

Step 3 — Field binding
  If node.data.field is present:
    Resolve value from DataContext (§5.1)
    Apply transform pipeline (§5.2)
    Inject into node content:
      text-type nodes (heading/paragraph/text/label): set text content
      other nodes: engine-defined per component (see Appendix A)
  If node.data.bindAttributes is present:
    For each [propName, fieldPath]:
      Resolve fieldPath from DataContext
      Set as node.props[propName] — overrides any static value

Step 4 — Responsive merge
  Determine active breakpoint:
    viewport < 640px  → base only
    viewport ≥ 640px  → merge sm
    viewport ≥ 768px  → merge md
    viewport ≥ 1024px → merge lg
    viewport ≥ 1280px → merge xl
  Merging is ADDITIVE (deep property-level merge). See §7.

Step 5 — Style resolution
  Resolve all StyleProps token values using §3.
  Produce a platform-native style representation.

Step 6 — Layout resolution
  Determine mode:
    columns present  → Grid mode
    direction present → Flex mode
    else              → Block/Column (default)

Step 7 — Render
  Dispatch to ComponentRegistry with resolved node.
  ComponentRegistry returns a platform-native widget/element.

Step 8 — Children
  If node.children is present and non-empty (and step 2 did not apply):
    Render each child in order, passing current DataContext.

Step 9 — Interactions
  Attach event listeners per §6.

Step 10 — Entrance animation
  If node.style.entranceAnimation is present:
    'page-load'        → fire immediately after first render
    'scroll-into-view' → fire when node enters viewport
                         (IntersectionObserver on web | VisibilityDetector on Flutter)
```

---

## 5. Data Binding

### 5.1 Path Resolution

Paths use dot-notation with bracket notation for arrays:

```
"coach.name"               → context["coach"]["name"]
"coach.services[0].price"  → context["coach"]["services"][0]["price"]
"service.name"             → context["service"]["name"]   (item alias)
"index"                    → context["index"]             (index alias)
```

Rules:

- Non-existent intermediate key → treat as `undefined`; apply fallback; never throw.
- `null` or `undefined` resolved value → apply `data.fallback` if present; else empty string for text nodes, `null` for bindings.

### 5.2 Transform Pipeline

Applied left-to-right. Each transform receives the output of the previous. On type mismatch: return input unchanged, warn (§9.1 R10).

**String transforms:**

| Transform     | Input → Output                     |
| ------------- | ---------------------------------- |
| `uppercase`   | `"hello"` → `"HELLO"`              |
| `lowercase`   | `"HELLO"` → `"hello"`              |
| `capitalize`  | `"hello world"` → `"Hello World"`  |
| `trim`        | `"  hi  "` → `"hi"`                |
| `truncate:N`  | First N chars + `"…"` if longer    |
| `prefix:X`    | `"100"` → `"X100"`                 |
| `suffix:X`    | `"100"` → `"100X"`                 |
| `replace:A:B` | All occurrences of A replaced by B |
| `default:V`   | Uses V if value is falsy           |

**Numeric transforms** (locale from `engineHints.locale`, default `"it-IT"`):

| Transform                 | `1500` →         |
| ------------------------- | ---------------- |
| `format:currency`         | `"€1.500,00"`    |
| `format:currency-compact` | `"€1,5k"`        |
| `format:percent`          | `0.85` → `"85%"` |
| `format:number`           | `"1.500"`        |

**Date transforms** (expects ISO 8601 string):

| Transform           | Output                         |
| ------------------- | ------------------------------ |
| `format:date`       | `"15 gennaio 2025"`            |
| `format:date-short` | `"15/01/2025"`                 |
| `format:time`       | `"14:30"`                      |
| `format:datetime`   | `"15 gen 2025, 14:30"`         |
| `format:duration`   | number of minutes → `"1h 30m"` |

**Array transforms:**

| Transform   | `["a","b","c"]` → |
| ----------- | ----------------- |
| `join:SEP`  | `"aSEPbSEPc"`     |
| `count`     | `"3"` (string)    |
| `first`     | `"a"`             |
| `last`      | `"c"`             |
| `slice:1:2` | `["b"]`           |

**Cast transforms:** `boolean`, `string`, `number` — standard coercion; `number` on NaN → `0` + warn.

### 5.3 Condition Evaluation

`DataCondition` is evaluated against the current DataContext:

| Operator                    | Semantics                                                    |
| --------------------------- | ------------------------------------------------------------ |
| `==` / `!=`                 | Loose equality / inequality after type coercion              |
| `>`, `<`, `>=`, `<=`        | Numeric comparison; coerce to number first                   |
| `exists`                    | Not `null` and not `undefined`                               |
| `not-exists`                | `null` or `undefined`                                        |
| `contains`                  | String: `includes()`; Array: `some(i => i == value)`         |
| `not-contains`              | Negation of `contains`                                       |
| `empty`                     | String: blank or `""`; Array: `length === 0`; null/undefined |
| `not-empty`                 | Negation of `empty`                                          |
| `starts-with` / `ends-with` | String prefix/suffix check                                   |

`or` array: true if ANY sub-condition is true.  
`and` array: true if ALL sub-conditions are true.  
Both present on the same node: `(root) AND (or result) AND (and result)`.

---

## 6. Interaction System

When the trigger fires, the engine dispatches the action to the ActionDispatcher. The optional `animation` runs concurrently.

### 6.1 Action Dispatch Contract

| Action `type`            | Web                                      | Flutter                            |
| ------------------------ | ---------------------------------------- | ---------------------------------- |
| `navigate`               | `router.navigate` / `location.href`      | `Navigator.pushNamed`              |
| `scroll-to`              | `scrollIntoView()` + offset              | `Scrollable.ensureVisible()`       |
| `toggle-visibility`      | Toggle `display:none`                    | Toggle `Visibility`                |
| `set-visibility`         | Set/remove `display:none`                | `Visibility(visible:)`             |
| `toggle-class`           | `classList.toggle()`                     | State variable → widget appearance |
| `add-class`              | `classList.add()`                        | As above                           |
| `remove-class`           | `classList.remove()`                     | As above                           |
| `open-modal`             | Overlay at `z-index: theme.zIndex.modal` | Modal route / dialog               |
| `close-modal`            | Remove overlay                           | `Navigator.pop()`                  |
| `submit-form`            | `form.submit()`                          | Form submit callback               |
| `reset-form`             | `form.reset()`                           | Reset form state                   |
| `open-booking`           | Super-WebFlow booking widget                   | Super-WebFlow booking screen             |
| `copy-text`              | `navigator.clipboard.writeText()`        | `Clipboard.setData()`              |
| `play-video`             | `video.play()`                           | `VideoPlayerController.play()`     |
| `pause-video`            | `video.pause()`                          | `VideoPlayerController.pause()`    |
| `toggle-video`           | Toggle play/pause                        | Toggle play/pause                  |
| `open-link`              | `window.open()`                          | `url_launcher.launchUrl()`         |
| `send-analytics`         | Analytics event                          | Analytics event                    |
| `set-var` / `toggle-var` | Runtime variable map                     | Engine state                       |

Unresolvable `nodeId` → no-op + development warning (not an error at runtime).

### 6.2 Trigger Mapping

| Trigger            | Web event                       | Flutter gesture               |
| ------------------ | ------------------------------- | ----------------------------- |
| `click`            | `click`                         | `GestureDetector.onTap`       |
| `double-click`     | `dblclick`                      | `GestureDetector.onDoubleTap` |
| `hover`            | `mouseenter`                    | `MouseRegion.onEnter`         |
| `hover-end`        | `mouseleave`                    | `MouseRegion.onExit`          |
| `focus` / `blur`   | `focus` / `blur`                | `FocusNode` listener          |
| `scroll-into-view` | `IntersectionObserver`          | `VisibilityDetector` package  |
| `page-load`        | `DOMContentLoaded` / `ngOnInit` | `initState`                   |
| `form-submit`      | `form submit` event             | `onSaved` callback            |
| `form-change`      | `input` / `change`              | `onChanged` callback          |

---

## 7. Responsive Merge Algorithm

The merge is **left-biased** and **additive** at property level:

```
merged = Object.assign(
  {},
  node.style,
  viewport >= 640  ? node.responsive?.sm : {},
  viewport >= 768  ? node.responsive?.md : {},
  viewport >= 1024 ? node.responsive?.lg : {},
  viewport >= 1280 ? node.responsive?.xl : {}
)
```

Rules:

1. Start with `node.style` (or `node.layout`).
2. Merge each applicable breakpoint override in ascending order.
3. Each merge is **shallow** (property level). A breakpoint setting `{ padding: 32 }` replaces the entire `padding` value; it does not merge sub-keys of a single property.
4. `style` and `layout` are merged independently.
5. Responsive overrides in `StyleLayoutOverride` can contain properties from both `StyleProps` and `LayoutProps`; the engine distributes them to the appropriate target.

---

## 8. Validation Rules

### 8.1 Rule Definitions

Enforced during the lint phase (document lifecycle step 3).

| Rule    | Severity | Description                                                                                                                                  |
| ------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **R01** | error    | Every `ComponentNode.id` MUST be unique in the entire document (all pages + globals).                                                        |
| **R02** | error    | Every `node.type` MUST be a value from the `ComponentType` enum. Unknown types render as empty containers with a dev-mode error placeholder. |
| **R03** | error    | If `data.listField` is present, `children` MUST exist and contain ≥ 1 element.                                                               |
| **R04** | warning  | `data.field` and `props.text` both present on the same node. `data.field` wins; static prop ignored.                                         |
| **R05** | warning  | Action `nodeId` references a non-existent node. No-op at runtime.                                                                            |
| **R06** | error    | `theme.colors` MUST contain all 30 required fields. No silent fallbacks.                                                                     |
| **R07** | error    | `pages.home` MUST be present.                                                                                                                |
| **R08** | error    | `type: "page-wrapper"` MUST be the root of a page; cannot be a child node.                                                                   |
| **R09** | error    | `GradientDef.stops` MUST have ≥ 2 elements.                                                                                                  |
| **R10** | warning  | Transform type mismatch at runtime. Return input unchanged; continue pipeline.                                                               |
| **R11** | —        | `_builder` fields MUST be stripped before rendering. Never used by rendering engines.                                                        |
| **R12** | —        | `@webOnly` properties silently ignored by non-web engines. No warning, no error.                                                             |
| **R13** | error    | Responsive merge MUST be additive (deep merge), not replacement of the entire `style`/`layout` object.                                       |
| **R14** | error    | `listField` child DataContexts are isolated. Mutations MUST NOT propagate to siblings or parent.                                             |
| **R15** | warning  | Prototype `nodeId`/`pageId` references should exist. Missing references are no-ops at runtime.                                               |
| **R16** | error    | `TemplateDocument.id` MUST match `^[a-z0-9][a-z0-9-]*[a-z0-9]$`.                                                                             |
| **R17** | error    | When `condition` evaluates to false, no descendants are rendered or mounted. No side effects fire.                                           |

### 8.2 Violation Reporting Format

```typescript
interface ValidationViolation {
  rule: string; // "R01"
  severity: "error" | "warning";
  nodeId?: string; // affected node
  path: string; // JSON Pointer: "/pages/home/children/0/id"
  message: string; // human-readable
}
```

Engines MUST collect and return ALL violations; do not stop at the first.

---

## 9. Error Handling

### 9.1 Rendering Errors

If rendering a node throws:

- **Dev mode**: error boundary placeholder with node ID and error message.
- **Production**: empty container, silent. Log to engine error reporter.

An error in one node MUST NOT abort siblings or ancestors.

### 9.2 Unresolvable Data

`data.field` or `data.listField` path missing from DataContext:

- Apply `data.fallback` if present.
- Else: text nodes → empty string; other nodes → rendered without data injection.
- Dev mode: warn with node ID, attempted path, available DataContext keys.

### 9.3 Unknown Component Types

Dev mode: visible placeholder `[Unknown: {type}]`.  
Production: `<div />` (web) or `SizedBox.shrink()` (Flutter). Log error in both modes.

---

## 10. Extension Points

- Fields starting with `x-` on any object: reserved for vendor extensions; ignored by spec-compliant engines.
- `_builder` on `ComponentNode`: builder-UI metadata only; stripped before rendering.
- `engineHints` keys unknown to the engine: silently ignored.

---

## 11. Versioning Policy

Follows **Semantic Versioning** (`MAJOR.MINOR`):

- **MAJOR** bump: breaking changes. Old documents fail validation against new schema.
- **MINOR** bump: backward-compatible additions (new optional fields, new enum values, new component types).

### 11.1 Version Declaration

```json
{
  "$schema": "https://ui-schema.Super-WebFlow.io/v1.0/template.schema.json",
  "version": "1.0"
}
```

Engines MUST check `version` before processing. Unsupported version → error, refuse to render.

### 11.2 Engine Capabilities Declaration

```typescript
interface EngineCapabilities {
  supportedSchemaVersions: string[]; // ["1.0"]
  engineName: string;
  engineVersion: string;
}
```

### 11.3 Deprecation

Deprecated fields: marked `@deprecated` in JSON Schema descriptions.  
Removal: first MAJOR version after deprecation.  
Engines MUST support deprecated fields for at least one full MAJOR version post-deprecation.

---

## Appendix A — Component Compliance Tiers

Engines MUST implement Tier 1 and Tier 2 to be considered compliant.

**Tier 1 — Required:**  
`container`, `section`, `row`, `column`, `grid`, `stack`,
`heading`, `paragraph`, `text`, `image`, `button`, `link`,
`divider`, `spacer`, `navbar`, `footer`

**Tier 2 — Required for full feature parity:**  
`hero`, `service-card`, `pricing-card`, `testimonial`,
`contact-form`, `booking-widget`, `photo-gallery`,
`coach-stats`, `social-links`, `modal`

**Tier 3 — Optional:**  
All remaining `ComponentType` values. Omitted Tier 3 components render as empty containers with a dev-mode warning.

Per-type props: see `Super-WebFlow-template.schema.d.ts` (authoritative TypeScript definition).

---

## Appendix B — DataContext Shape

The DataContext is a plain JSON object populated by the Super-WebFlow backend at runtime, conforming to the template's `dataSchema`. Example:

```json
{
  "coach": {
    "fullName": "Mario Rossi",
    "tagline": "Forza e risultati, senza compromessi.",
    "avatar": "https://cdn.Super-WebFlow.io/avatars/mario.jpg",
    "bio": "Personal trainer con 10 anni di esperienza…",
    "isPro": true,
    "services": [
      { "name": "Personal Training", "price": 80, "duration": 60 },
      { "name": "Online Coaching", "price": 149, "duration": null }
    ],
    "socialLinks": [
      { "network": "instagram", "url": "https://instagram.com/mario" }
    ],
    "stats": [
      { "label": "Clienti", "value": 120, "suffix": "+" },
      { "label": "Anni exp.", "value": 10 }
    ]
  }
}
```

---

_End of Functional Specification v1.0_


