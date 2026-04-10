"use strict";
/**
 * @aredegalli/super-webflow-cli â€” Validator
 *
 * Two-phase validation:
 *   Phase 1 â€” JSON Schema (structural, via AJV 2020-12)
 *   Phase 2 â€” Semantic rules (functional-spec.md Â§8) that cannot be
 *             expressed in JSON Schema alone.
 *
 * @example
 *   const { validateJson } = require('./validator')
 *   const result = validateJson(fs.readFileSync('my-template.json', 'utf8'))
 *   if (!result.valid) console.error(result.errors)
 */

const Ajv2020 = require("ajv/dist/2020");
const addFormats = require("ajv-formats");
const fs = require("node:fs");
const path = require("node:path");

// â”€â”€â”€ Schema setup (compile once at module load) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const SCHEMA_PATH = path.join(__dirname, "../spec/v1.0/template.schema.json");
const schema = JSON.parse(fs.readFileSync(SCHEMA_PATH, "utf-8"));

const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);
const schemaValidate = ajv.compile(schema);

// â”€â”€â”€ Public API â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/**
 * Validate a pre-parsed document object.
 * @param {unknown} document
 * @returns {{ valid: boolean, errors: ValidationError[] }}
 */
function validateDocument(document) {
  const errors = [
    ...runSchemaValidation(document),
    ...runSemanticValidation(document),
  ];
  return { valid: errors.length === 0, errors };
}

/**
 * Parse a JSON string and validate it.
 * @param {string} jsonString
 * @returns {{ valid: boolean, errors: ValidationError[] }}
 */
function validateJson(jsonString) {
  let doc;
  try {
    doc = JSON.parse(jsonString);
  } catch (e) {
    return {
      valid: false,
      errors: [
        {
          rule: null,
          severity: "error",
          nodeId: undefined,
          path: "/",
          message: `JSON parse error: ${e.message}`,
        },
      ],
    };
  }
  return validateDocument(doc);
}

module.exports = { validateDocument, validateJson };

// â”€â”€â”€ Phase 1 â€” JSON Schema â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function runSchemaValidation(doc) {
  const ok = schemaValidate(doc);
  if (ok) return [];
  return (schemaValidate.errors ?? []).map((e) => ({
    rule: "schema",
    severity: "error",
    nodeId: undefined,
    path: e.instancePath || "/",
    message: e.message ?? "validation failed",
    schemaPath: e.schemaPath,
    params: e.params,
  }));
}

// â”€â”€â”€ Phase 2 â€” Semantic rules â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function runSemanticValidation(doc) {
  if (typeof doc !== "object" || doc === null) return [];
  return [...checkUniqueIds(doc), ...checkListFieldChildren(doc)];
}

/**
 * R01 â€” Every ComponentNode.id MUST be unique in the entire document.
 */
function checkUniqueIds(doc) {
  const errors = [];
  const seen = new Map(); // id â†’ first JSON Pointer

  function walk(node, pointer) {
    if (!node || typeof node !== "object") return;

    if (typeof node.id === "string") {
      if (seen.has(node.id)) {
        errors.push({
          rule: "R01",
          severity: "error",
          nodeId: node.id,
          path: pointer,
          message: `Duplicate node id "${node.id}". First occurrence: ${seen.get(node.id)}`,
        });
      } else {
        seen.set(node.id, pointer);
      }
    }

    if (Array.isArray(node.children)) {
      node.children.forEach((child, i) =>
        walk(child, `${pointer}/children/${i}`),
      );
    }
  }

  walkDocument(doc, walk);
  return errors;
}

/**
 * R03 â€” If data.listField is present, children MUST exist with â‰¥ 1 element.
 */
function checkListFieldChildren(doc) {
  const errors = [];

  function walk(node, pointer) {
    if (!node || typeof node !== "object") return;

    if (typeof node.data?.listField === "string") {
      const hasChildren =
        Array.isArray(node.children) && node.children.length > 0;
      if (!hasChildren) {
        errors.push({
          rule: "R03",
          severity: "error",
          nodeId: node.id,
          path: pointer,
          message: `Node "${node.id ?? "?"}" has data.listField="${node.data.listField}" but no children. At least one child template is required.`,
        });
      }
    }

    if (Array.isArray(node.children)) {
      node.children.forEach((child, i) =>
        walk(child, `${pointer}/children/${i}`),
      );
    }
  }

  walkDocument(doc, walk);
  return errors;
}

// â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/**
 * Walk all ComponentNode trees in a document (globals + all pages).
 * @param {object}   doc
 * @param {Function} visitor  (node: object, pointer: string) => void
 */
function walkDocument(doc, visitor) {
  if (doc.globals?.navbar) visitor(doc.globals.navbar, "/globals/navbar");
  if (doc.globals?.footer) visitor(doc.globals.footer, "/globals/footer");

  const pages = doc.pages ?? {};
  for (const [key, node] of Object.entries(pages)) {
    if (node) visitor(node, `/pages/${key}`);
  }
}

/**
 * @typedef {Object} ValidationError
 * @property {string|null}    rule       - Rule identifier (e.g. 'R01') or 'schema' for JSON Schema errors
 * @property {'error'|'warning'} severity
 * @property {string|undefined} nodeId   - Affected ComponentNode id, if applicable
 * @property {string}         path       - JSON Pointer (RFC 6901) to the offending value
 * @property {string}         message    - Human-readable description
 * @property {string}         [schemaPath] - AJV schemaPath (schema errors only)
 * @property {object}         [params]   - AJV params (schema errors only)
 */


