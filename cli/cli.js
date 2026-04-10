#!/usr/bin/env node
"use strict";
/**
 * ui-validate â€” CLI for @aredegalli/super-webflow-cli
 *
 * Usage:
 *   node cli.js <file.json> [file2.json ...]
 *   npx ui-validate spec/v1.0/examples/minimal.json
 *
 * Exit codes:
 *   0 â€” all files valid
 *   1 â€” one or more files invalid or unreadable
 */

const fs = require("node:fs");
const path = require("node:path");
const { validateJson } = require("./validator");

const RESET = "\x1b[0m";
const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const DIM = "\x1b[2m";
const BOLD = "\x1b[1m";

const [, , ...files] = process.argv;

if (files.length === 0) {
  console.error("Usage: ui-validate <file.json> [file2.json ...]\n");
  console.error(
    "  Validates documents against the Super WebFlow Contract Language schema v1.0.",
  );
  console.error("  Exit code 0 = all valid, 1 = any errors found.\n");
  console.error("  Examples:");
  console.error("    node cli.js ../spec/v1.0/examples/template.json");
  console.error("    node cli.js ../spec/v1.0/examples/*.json");
  process.exit(1);
}

let exitCode = 0;

for (const file of files) {
  const label = path.relative(process.cwd(), path.resolve(file));

  let json;
  try {
    json = fs.readFileSync(file, "utf-8");
  } catch {
    console.error(`${RED}âœ—${RESET}  ${BOLD}${label}${RESET}`);
    console.error(`   ${DIM}cannot read file${RESET}\n`);
    exitCode = 1;
    continue;
  }

  const result = validateJson(json);

  if (result.valid) {
    console.log(`${GREEN}âœ“${RESET}  ${BOLD}${label}${RESET}`);
  } else {
    console.error(
      `${RED}âœ—${RESET}  ${BOLD}${label}${RESET}  ${DIM}(${result.errors.length} error${result.errors.length === 1 ? "" : "s"})${RESET}`,
    );

    for (const err of result.errors) {
      const rule =
        err.rule && err.rule !== "schema"
          ? `${YELLOW}[${err.rule}]${RESET} `
          : "";
      const loc = err.nodeId ? `${DIM}node "${err.nodeId}" Â· ${RESET}` : "";
      console.error(
        `   ${rule}${loc}${DIM}${err.path}${RESET}  ${err.message}`,
      );
    }
    console.error();
    exitCode = 1;
  }
}

process.exit(exitCode);



