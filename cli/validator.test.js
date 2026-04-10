"use strict";
/**
 * Validator test suite â€” @aredegalli/super-webflow-cli
 * Run: node --test tests/validator.test.js
 *
 * Coverage:
 *   - Phase 1 (JSON Schema): required fields, enums, types, patterns, oneOf
 *   - Phase 2 (Semantic):    R01 unique ids, R03 listField+children
 *   - Valid examples:        template.json, website.json
 */

const { test, describe } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const { validateDocument, validateJson } = require("../src/validator");
const { baseDocument } = require("./helpers/base-document");

const EXAMPLES = path.join(__dirname, "../spec/v1.0/examples");

// â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/** Assert that validation fails and at least one error matches the predicate. */
function assertFails(doc, predicate, hint) {
  const result = validateDocument(doc);
  assert.equal(
    result.valid,
    false,
    `Expected validation to fail but it passed. Hint: ${hint}`,
  );
  const matched = result.errors.some(predicate);
  if (!matched) {
    const messages = result.errors
      .map((e) => `  [${e.rule ?? "schema"}] ${e.path}: ${e.message}`)
      .join("\n");
    assert.fail(
      `No error matched predicate for: ${hint}\nActual errors:\n${messages}`,
    );
  }
}

/** Assert that validation passes. */
function assertPasses(doc, hint) {
  const result = validateDocument(doc);
  if (!result.valid) {
    const messages = result.errors
      .map((e) => `  [${e.rule ?? "schema"}] ${e.path}: ${e.message}`)
      .join("\n");
    assert.fail(
      `Expected validation to pass but got ${result.errors.length} error(s). Hint: ${hint}\n${messages}`,
    );
  }
}

// â”€â”€â”€ Suite: valid examples â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("Valid examples", () => {
  test("template.json passes", () => {
    const json = fs.readFileSync(path.join(EXAMPLES, "template.json"), "utf-8");
    const result = validateJson(json);
    if (!result.valid) {
      const msgs = result.errors
        .map((e) => `  ${e.path}: ${e.message}`)
        .join("\n");
      assert.fail(`template.json failed:\n${msgs}`);
    }
    assert.equal(result.valid, true);
  });

  test("website.json passes", () => {
    const json = fs.readFileSync(
      path.join(EXAMPLES, "website.json"),
      "utf-8",
    );
    const result = validateJson(json);
    if (!result.valid) {
      const msgs = result.errors
        .map((e) => `  ${e.path}: ${e.message}`)
        .join("\n");
      assert.fail(`website.json failed:\n${msgs}`);
    }
    assert.equal(result.valid, true);
  });

  test("base-document helper itself is valid", () => {
    assertPasses(baseDocument(), "base helper");
  });
});

// â”€â”€â”€ Suite: JSON parse errors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("JSON parse errors", () => {
  test("malformed JSON returns parse error", () => {
    const result = validateJson("{not json}");
    assert.equal(result.valid, false);
    assert.ok(result.errors[0].message.includes("JSON parse error"));
  });

  test("non-object JSON returns error", () => {
    const result = validateJson('"a string"');
    assert.equal(result.valid, false);
  });
});

// â”€â”€â”€ Suite: TemplateDocument structure â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("TemplateDocument â€” required fields", () => {
  test("missing $schema fails", () => {
    const doc = baseDocument();
    delete doc.$schema;
    // AJV maps root-level required errors to path '/' (mapped from empty instancePath)
    assertFails(doc, (e) => e.message?.includes("$schema"), "missing $schema");
  });

  test("wrong $schema value fails", () => {
    const doc = baseDocument();
    doc.$schema = "https://example.com/wrong.json";
    assertFails(doc, (e) => e.path.includes("$schema"), "wrong $schema");
  });

  test("wrong version fails", () => {
    const doc = baseDocument();
    doc.version = "2.0";
    assertFails(doc, (e) => e.path.includes("version"), "wrong version");
  });

  test("missing id fails", () => {
    const doc = baseDocument();
    delete doc.id;
    assertFails(
      doc,
      (e) => e.message?.includes("'id'") || e.path.includes("id"),
      "missing id",
    );
  });

  test("id with uppercase letters fails", () => {
    const doc = baseDocument();
    doc.id = "MyTemplate";
    assertFails(doc, (e) => e.path.includes("/id"), "uppercase id");
  });

  test("id with trailing hyphen fails", () => {
    const doc = baseDocument();
    doc.id = "my-template-";
    assertFails(doc, (e) => e.path.includes("/id"), "trailing hyphen");
  });

  test("missing name fails", () => {
    const doc = baseDocument();
    delete doc.name;
    assertFails(doc, (e) => e.message?.includes("'name'"), "missing name");
  });

  test("missing theme fails", () => {
    const doc = baseDocument();
    delete doc.theme;
    assertFails(doc, (e) => e.message?.includes("'theme'"), "missing theme");
  });

  test("missing meta fails", () => {
    const doc = baseDocument();
    delete doc.meta;
    assertFails(doc, (e) => e.message?.includes("'meta'"), "missing meta");
  });

  test("missing dataSchema fails", () => {
    const doc = baseDocument();
    delete doc.dataSchema;
    assertFails(
      doc,
      (e) => e.message?.includes("'dataSchema'"),
      "missing dataSchema",
    );
  });

  test("missing pages fails", () => {
    const doc = baseDocument();
    delete doc.pages;
    assertFails(doc, (e) => e.message?.includes("'pages'"), "missing pages");
  });

  test("pages without home fails", () => {
    const doc = baseDocument();
    doc.pages = { about: { id: "about-root", type: "container" } };
    assertFails(
      doc,
      (e) => e.message?.includes("'home'"),
      "pages without home",
    );
  });

  test("unknown top-level field fails", () => {
    const doc = baseDocument();
    doc.unknownField = "surprise";
    assertFails(
      doc,
      (e) => e.message?.includes("additional"),
      "unknown top-level field",
    );
  });
});

// â”€â”€â”€ Suite: ThemeSchema â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("ThemeSchema â€” colors", () => {
  test("missing required color token fails", () => {
    const doc = baseDocument();
    delete doc.theme.colors.primaryLight;
    assertFails(
      doc,
      (e) => e.message?.includes("'primaryLight'"),
      "missing primaryLight",
    );
  });

  test("extra color not in schema fails", () => {
    const doc = baseDocument();
    doc.theme.colors.rainbow = "#ff0000";
    assertFails(
      doc,
      (e) => e.message?.includes("additional"),
      "extra color field",
    );
  });

  test("theme version not matching semver pattern fails", () => {
    const doc = baseDocument();
    doc.theme.version = "v1"; // must be X.Y.Z
    assertFails(
      doc,
      (e) => e.path.includes("version"),
      "invalid theme version",
    );
  });
});

// â”€â”€â”€ Suite: ComponentNode â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("ComponentNode", () => {
  test("unknown component type fails", () => {
    const doc = baseDocument();
    doc.pages.home.children[0].type = "super-widget";
    assertFails(doc, (e) => e.path?.includes("type"), "unknown component type");
  });

  test("missing node id fails", () => {
    const doc = baseDocument();
    delete doc.pages.home.id;
    assertFails(
      doc,
      (e) => e.message?.includes("'id'") || e.path.includes("/id"),
      "missing node id",
    );
  });

  test("missing node type fails", () => {
    const doc = baseDocument();
    delete doc.pages.home.type;
    assertFails(doc, (e) => e.message?.includes("'type'"), "missing node type");
  });

  test("extra field on ComponentNode fails", () => {
    const doc = baseDocument();
    doc.pages.home.weirdProp = true;
    assertFails(
      doc,
      (e) => e.message?.includes("additional"),
      "extra node field",
    );
  });
});

// â”€â”€â”€ Suite: StyleProps â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("StyleProps", () => {
  test("invalid textAlign fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = { textAlign: "justify-all" };
    assertFails(doc, (e) => e.path?.includes("textAlign"), "invalid textAlign");
  });

  test("negative width fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = { width: -10 };
    assertFails(doc, (e) => e.path?.includes("width"), "negative width");
  });

  test("opacity above 1 fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = { opacity: 1.5 };
    assertFails(doc, (e) => e.path?.includes("opacity"), "opacity > 1");
  });

  test("borderRadius with 5 elements fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = { borderRadius: [1, 2, 3, 4, 5] };
    assertFails(
      doc,
      (e) => e.path?.includes("borderRadius"),
      "borderRadius too many items",
    );
  });

  test("aspectRatio invalid format fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = { aspectRatio: "16:9" }; // must be "16/9"
    assertFails(
      doc,
      (e) => e.path?.includes("aspectRatio"),
      "aspectRatio bad format",
    );
  });

  test("SizeValue percentage string passes", () => {
    const doc = baseDocument();
    doc.pages.home.style = { width: "80%" };
    assertPasses(doc, "SizeValue percent");
  });

  test("SizeValue semantic keyword passes", () => {
    const doc = baseDocument();
    doc.pages.home.style = { width: "fill" };
    assertPasses(doc, "SizeValue fill");
  });

  test("SizeValue unsupported keyword fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = { width: "max-content" };
    assertFails(
      doc,
      (e) => e.path?.includes("width"),
      "unsupported SizeValue keyword",
    );
  });
});

// â”€â”€â”€ Suite: GradientDef â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("GradientDef", () => {
  test("gradient with 2 stops passes", () => {
    const doc = baseDocument();
    doc.pages.home.style = {
      backgroundGradient: {
        type: "linear",
        angle: 135,
        stops: [
          { color: "primary", position: 0 },
          { color: "#000000", position: 100 },
        ],
      },
    };
    assertPasses(doc, "valid gradient");
  });

  test("gradient with 1 stop fails (R09)", () => {
    const doc = baseDocument();
    doc.pages.home.style = {
      backgroundGradient: {
        type: "linear",
        stops: [{ color: "primary", position: 0 }],
      },
    };
    assertFails(doc, (e) => e.path?.includes("stops"), "gradient 1 stop");
  });

  test("gradient stop position > 100 fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = {
      backgroundGradient: {
        type: "linear",
        stops: [
          { color: "#fff", position: 0 },
          { color: "#000", position: 150 }, // > 100
        ],
      },
    };
    assertFails(
      doc,
      (e) => e.path?.includes("position"),
      "stop position > 100",
    );
  });
});

// â”€â”€â”€ Suite: DataBinding â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("DataBinding", () => {
  test("valid field path passes", () => {
    const doc = baseDocument();
    doc.pages.home.data = { field: "coach.fullName" };
    assertPasses(doc, "valid field path");
  });

  test("field path with array notation passes", () => {
    const doc = baseDocument();
    doc.pages.home.data = { field: "coach.services[0].price" };
    assertPasses(doc, "array bracket path");
  });

  test("field path starting with digit fails", () => {
    const doc = baseDocument();
    doc.pages.home.data = { field: "0invalid" };
    assertFails(
      doc,
      (e) => e.path?.includes("field"),
      "field path starts with digit",
    );
  });

  test("valid transform pipeline passes", () => {
    const doc = baseDocument();
    doc.pages.home.data = {
      field: "coach.name",
      transform: ["uppercase", "truncate:40"],
    };
    assertPasses(doc, "valid transform pipeline");
  });

  test("invalid transform string fails", () => {
    const doc = baseDocument();
    doc.pages.home.data = { field: "coach.name", transform: "SHOUT" };
    assertFails(doc, (e) => e.path?.includes("transform"), "invalid transform");
  });

  test("sort on binding passes", () => {
    const doc = baseDocument();
    doc.pages.home.data = {
      listField: "coach.services",
      sort: { field: "service.price", direction: "asc" },
    };
    doc.pages.home.children = [{ id: "svc-tpl", type: "service-card" }];
    assertPasses(doc, "binding with sort");
  });
});

// â”€â”€â”€ Suite: Action discriminated union â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("Action â€” oneOf discriminated union", () => {
  test("navigate action passes", () => {
    const doc = baseDocument();
    doc.pages.home.interactions = [
      {
        trigger: "click",
        action: {
          type: "navigate",
          url: "https://example.com",
          target: "_blank",
        },
      },
    ];
    assertPasses(doc, "navigate action");
  });

  test("scroll-to action passes", () => {
    const doc = baseDocument();
    doc.pages.home.interactions = [
      {
        trigger: "click",
        action: {
          type: "scroll-to",
          nodeId: "contact-section",
          behavior: "smooth",
        },
      },
    ];
    assertPasses(doc, "scroll-to action");
  });

  test("unknown action type fails", () => {
    const doc = baseDocument();
    doc.pages.home.interactions = [
      {
        trigger: "click",
        action: { type: "fly-away", destination: "moon" },
      },
    ];
    assertFails(doc, (e) => e.path?.includes("action"), "unknown action type");
  });

  test("navigate missing url fails", () => {
    const doc = baseDocument();
    doc.pages.home.interactions = [
      {
        trigger: "click",
        action: { type: "navigate" }, // url required
      },
    ];
    assertFails(doc, (e) => e.path?.includes("action"), "navigate without url");
  });

  test("extra field in action fails", () => {
    const doc = baseDocument();
    doc.pages.home.interactions = [
      {
        trigger: "click",
        action: { type: "open-booking", extraProp: true },
      },
    ];
    assertFails(
      doc,
      (e) => e.path?.includes("action"),
      "extra field in action",
    );
  });

  test("unknown trigger fails", () => {
    const doc = baseDocument();
    doc.pages.home.interactions = [
      {
        trigger: "triple-click",
        action: { type: "open-booking" },
      },
    ];
    assertFails(doc, (e) => e.path?.includes("trigger"), "unknown trigger");
  });
});

// â”€â”€â”€ Suite: EasingFn â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("EasingFn", () => {
  test("named easing passes", () => {
    const doc = baseDocument();
    doc.pages.home.style = {
      entranceAnimation: { type: "fade-in", duration: 300, easing: "ease-out" },
    };
    assertPasses(doc, "named easing");
  });

  test("cubic-bezier easing passes", () => {
    const doc = baseDocument();
    doc.pages.home.style = {
      entranceAnimation: {
        type: "slide-up",
        duration: 400,
        easing: "cubic-bezier(0.34,1.56,0.64,1)",
      },
    };
    assertPasses(doc, "cubic-bezier easing");
  });

  test("invalid easing string fails", () => {
    const doc = baseDocument();
    doc.pages.home.style = {
      entranceAnimation: { type: "fade-in", duration: 300, easing: "bounce" },
    };
    assertFails(doc, (e) => e.path?.includes("easing"), "invalid easing");
  });
});

// â”€â”€â”€ Suite: DataFieldDef â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("DataFieldDef (dataSchema)", () => {
  test("valid field definition passes", () => {
    const doc = baseDocument();
    doc.dataSchema = {
      "coach.fullName": {
        type: "string",
        required: true,
        label: "Nome completo",
      },
      "coach.services": {
        type: "list",
        label: "Servizi",
        validation: {
          itemSchema: {
            name: { type: "string", required: true, label: "Nome" },
            price: { type: "number", required: true, label: "Prezzo" },
          },
        },
      },
    };
    assertPasses(doc, "valid dataSchema");
  });

  test("field with unknown type fails", () => {
    const doc = baseDocument();
    doc.dataSchema = { "coach.x": { type: "blob", label: "Test" } };
    assertFails(doc, (e) => e.path?.includes("type"), "unknown field type");
  });

  test("field missing label fails", () => {
    const doc = baseDocument();
    doc.dataSchema = { "coach.x": { type: "string" } };
    assertFails(
      doc,
      (e) => e.message?.includes("'label'"),
      "field missing label",
    );
  });
});

// â”€â”€â”€ Suite: Semantic rule R01 â€” unique IDs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("R01 â€” unique node IDs", () => {
  test("unique IDs pass", () => {
    assertPasses(baseDocument(), "unique ids");
  });

  test("duplicate ID in same page fails", () => {
    const doc = baseDocument();
    // home-root already has id 'child-a'; add another with the same id
    doc.pages.home.children.push({ id: "child-a", type: "paragraph" });
    assertFails(
      doc,
      (e) => e.rule === "R01" && e.nodeId === "child-a",
      "duplicate id in page",
    );
  });

  test("duplicate ID between page root and child fails", () => {
    const doc = baseDocument();
    doc.pages.home.children[0].id = "home-root"; // same as page root
    assertFails(
      doc,
      (e) => e.rule === "R01" && e.nodeId === "home-root",
      "id collision with root",
    );
  });

  test("duplicate ID across pages fails", () => {
    const doc = baseDocument();
    doc.pages.about = { id: "home-root", type: "container" }; // reuse home-root id
    assertFails(
      doc,
      (e) => e.rule === "R01" && e.nodeId === "home-root",
      "id collision across pages",
    );
  });

  test("duplicate ID between page and global fails", () => {
    const doc = baseDocument();
    doc.globals = {
      navbar: { id: "home-root", type: "navbar" }, // collision
      footer: { id: "global-footer", type: "footer" },
    };
    assertFails(doc, (e) => e.rule === "R01", "id collision with global");
  });
});

// â”€â”€â”€ Suite: Semantic rule R03 â€” listField + children â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("R03 â€” listField requires children", () => {
  test("listField with children passes", () => {
    const doc = baseDocument();
    doc.pages.home.data = { listField: "coach.services", itemAlias: "service" };
    doc.pages.home.children = [{ id: "svc-tpl", type: "service-card" }];
    assertPasses(doc, "listField with children");
  });

  test("listField without children fails", () => {
    const doc = baseDocument();
    doc.pages.home.data = { listField: "coach.services" };
    doc.pages.home.children = [];
    assertFails(doc, (e) => e.rule === "R03", "listField without children");
  });

  test("listField with no children key fails", () => {
    const doc = baseDocument();
    doc.pages.home.data = { listField: "coach.services" };
    delete doc.pages.home.children;
    assertFails(doc, (e) => e.rule === "R03", "listField missing children key");
  });

  test("nested listField without children fails", () => {
    const doc = baseDocument();
    doc.pages.home.children[0].data = { listField: "coach.testimonials" };
    doc.pages.home.children[0].children = []; // empty
    assertFails(
      doc,
      (e) => e.rule === "R03",
      "nested listField without children",
    );
  });
});

// â”€â”€â”€ Suite: PrototypeSchema â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("PrototypeSchema", () => {
  test("valid prototype passes", () => {
    const doc = baseDocument();
    doc.prototype = {
      version: "1.0",
      id: "test-proto",
      startPageId: "home",
      connections: [
        {
          id: "conn-1",
          source: { nodeId: "home-root", trigger: "click" },
          destination: { type: "section", nodeId: "child-a" },
          transition: { type: "dissolve", duration: 300 },
        },
      ],
    };
    assertPasses(doc, "valid prototype");
  });

  test("unknown transition type fails", () => {
    const doc = baseDocument();
    doc.prototype = {
      version: "1.0",
      id: "test-proto",
      startPageId: "home",
      connections: [
        {
          id: "conn-1",
          source: { nodeId: "home-root", trigger: "click" },
          destination: { type: "back" },
          transition: { type: "teleport" }, // not in enum
        },
      ],
    };
    assertFails(
      doc,
      (e) => e.path?.includes("transition"),
      "unknown transition type",
    );
  });
});

// â”€â”€â”€ Suite: AssetsSchema â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

describe("AssetsSchema", () => {
  test("valid assets block passes", () => {
    const doc = baseDocument();
    doc.assets = {
      fonts: [
        {
          family: "Poppins",
          url: "https://fonts.example.com/poppins.woff2",
          weight: [400, 700],
        },
      ],
      icons: { provider: "lucide", subset: ["star", "arrow-right"] },
      images: { "hero-bg": "https://cdn.example.com/bg.jpg" },
    };
    assertPasses(doc, "valid assets");
  });

  test("unknown icon provider fails", () => {
    const doc = baseDocument();
    doc.assets = { icons: { provider: "fontawesome" } }; // not in enum
    assertFails(
      doc,
      (e) => e.path?.includes("provider"),
      "unknown icon provider",
    );
  });
});


