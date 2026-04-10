"use strict";
/**
 * Returns a fresh deep-cloned minimal valid TemplateDocument.
 * Tests mutate this object to trigger specific violations.
 */
function baseDocument() {
  return JSON.parse(JSON.stringify(BASE));
}

module.exports = { baseDocument };

// â”€â”€â”€ Minimal valid document â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Keep in sync with spec/v1.0/examples/template.json.
// This is the smallest document that passes both schema and semantic validation.

const MINIMAL_THEME = {
  id: "test-theme",
  name: "Test",
  version: "1.0.0",
  colors: {
    primary: "#6C5CE7",
    primaryLight: "#A29BFE",
    primaryDark: "#4834D4",
    secondary: "#00B894",
    secondaryLight: "#55EFC4",
    secondaryDark: "#00876E",
    accent: "#FD79A8",
    accentLight: "#FDCFE2",
    background: "#0A0A0F",
    backgroundAlt: "#13131A",
    surface: "#1A1A26",
    surfaceAlt: "#252535",
    overlay: "rgba(0,0,0,0.65)",
    text: "#FFFFFF",
    textSecondary: "#A0A0B0",
    textMuted: "#6B6B80",
    textInverse: "#0A0A0F",
    textOnPrimary: "#FFFFFF",
    border: "#2A2A3A",
    borderStrong: "#3D3D55",
    borderFocus: "#6C5CE7",
    success: "#00B894",
    successLight: "#DCFFF6",
    warning: "#FDCB6E",
    warningLight: "#FFF8E7",
    danger: "#D63031",
    dangerLight: "#FFE8E8",
    info: "#0984E3",
    infoLight: "#E3F2FF",
  },
  typography: {
    fonts: { heading: "Poppins", body: "Inter" },
    scale: {
      xs: 12,
      sm: 14,
      base: 16,
      lg: 18,
      xl: 20,
      "2xl": 24,
      "3xl": 30,
      "4xl": 36,
      "5xl": 48,
      "6xl": 60,
      "7xl": 72,
    },
    lineHeights: {
      xs: 1.5,
      sm: 1.5,
      base: 1.6,
      lg: 1.5,
      xl: 1.4,
      "2xl": 1.3,
      "3xl": 1.2,
      "4xl": 1.1,
      "5xl": 1.05,
      "6xl": 1.0,
      "7xl": 1.0,
    },
  },
  spacing: { base: 4, scale: { 0: 0, 4: 16, 8: 32, 16: 64 } },
  radii: {
    none: 0,
    xs: 2,
    sm: 4,
    md: 8,
    lg: 12,
    xl: 16,
    "2xl": 24,
    "3xl": 32,
    full: 9999,
  },
  shadows: {
    none: null,
    sm: { offsetX: 0, offsetY: 1, blur: 3, color: "rgba(0,0,0,0.25)" },
    md: { offsetX: 0, offsetY: 4, blur: 12, color: "rgba(0,0,0,0.35)" },
    lg: { offsetX: 0, offsetY: 8, blur: 24, color: "rgba(0,0,0,0.4)" },
    xl: { offsetX: 0, offsetY: 16, blur: 48, color: "rgba(0,0,0,0.5)" },
    inner: {
      offsetX: 0,
      offsetY: 2,
      blur: 4,
      color: "rgba(0,0,0,0.3)",
      inset: true,
    },
  },
  transitions: {
    fast: 120,
    normal: 250,
    slow: 400,
    easing: {
      default: "ease",
      in: "ease-in",
      out: "ease-out",
      inOut: "ease-in-out",
      spring: "cubic-bezier(0.34,1.56,0.64,1)",
    },
  },
  zIndex: {
    base: 0,
    raised: 10,
    sticky: 50,
    overlay: 100,
    modal: 200,
    popup: 300,
    tooltip: 400,
    max: 9999,
  },
};

const BASE = {
  $schema: "https://aredegalli.it/super-webflow/v1.0/template.schema.json",
  version: "1.0",
  id: "test-document",
  name: "Test Document",
  theme: MINIMAL_THEME,
  meta: { title: "Test" },
  dataSchema: {},
  pages: {
    home: {
      id: "home-root",
      type: "container",
      children: [{ id: "child-a", type: "heading", props: { level: 1 } }],
    },
  },
};


