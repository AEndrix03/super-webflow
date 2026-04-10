// ignore_for_file: prefer_const_constructors, prefer_const_declarations
import 'package:super_webflow/super_webflow.dart';

TemplateDocument baseDocument() {
  return TemplateDocument(
    schema: 'https://aredegalli.it/super-webflow/v1.0/template.schema.json',
    version: '1.0',
    id: 'test-document',
    name: 'Test Document',
    theme: ThemeSchema(
      id: 'test-theme',
      name: 'Test',
      version: '1.0.0',
      colors: const ThemeColors(
        primary: '#6C5CE7',
        primaryLight: '#A29BFE',
        primaryDark: '#4834D4',
        secondary: '#00B894',
        secondaryLight: '#55EFC4',
        secondaryDark: '#00876E',
        accent: '#FD79A8',
        accentLight: '#FDCFE2',
        background: '#0A0A0F',
        backgroundAlt: '#13131A',
        surface: '#1A1A26',
        surfaceAlt: '#252535',
        overlay: 'rgba(0,0,0,0.65)',
        text: '#FFFFFF',
        textSecondary: '#A0A0B0',
        textMuted: '#6B6B80',
        textInverse: '#0A0A0F',
        textOnPrimary: '#FFFFFF',
        border: '#2A2A3A',
        borderStrong: '#3D3D55',
        borderFocus: '#6C5CE7',
        success: '#00B894',
        successLight: '#DCFFF6',
        warning: '#FDCB6E',
        warningLight: '#FFF8E7',
        danger: '#D63031',
        dangerLight: '#FFE8E8',
        info: '#0984E3',
        infoLight: '#E3F2FF',
      ),
      typography: ThemeTypography(
        fonts: const ThemeFonts(heading: 'Poppins', body: 'Inter'),
        scale: const ThemeTypographyScale(
          xs: 12,
          sm: 14,
          base: 16,
          lg: 18,
          xl: 20,
          xl2: 24,
          xl3: 30,
          xl4: 36,
          xl5: 48,
          xl6: 60,
          xl7: 72,
        ),
        lineHeights: const ThemeTypographyScale(
          xs: 1.5,
          sm: 1.5,
          base: 1.6,
          lg: 1.5,
          xl: 1.4,
          xl2: 1.3,
          xl3: 1.2,
          xl4: 1.1,
          xl5: 1.05,
          xl6: 1.0,
          xl7: 1.0,
        ),
      ),
      spacing: const ThemeSpacing(base: 4, scale: {'0': 0, '4': 16}),
      radii: const ThemeRadii(
        xs: 2,
        sm: 4,
        md: 8,
        lg: 12,
        xl: 16,
        xl2: 24,
        xl3: 32,
      ),
      shadows: ThemeShadows(
        sm: SvSingle(
          const ShadowDef(
            offsetX: 0,
            offsetY: 1,
            blur: 3,
            color: 'rgba(0,0,0,0.25)',
          ),
        ),
        md: SvSingle(
          const ShadowDef(
            offsetX: 0,
            offsetY: 4,
            blur: 12,
            color: 'rgba(0,0,0,0.35)',
          ),
        ),
        lg: SvSingle(
          const ShadowDef(
            offsetX: 0,
            offsetY: 8,
            blur: 24,
            color: 'rgba(0,0,0,0.4)',
          ),
        ),
        xl: SvSingle(
          const ShadowDef(
            offsetX: 0,
            offsetY: 16,
            blur: 48,
            color: 'rgba(0,0,0,0.5)',
          ),
        ),
        inner: const ShadowDef(
          offsetX: 0,
          offsetY: 2,
          blur: 4,
          color: 'rgba(0,0,0,0.3)',
          inset: true,
        ),
      ),
      transitions: ThemeTransitions(
        fast: 120,
        normal: 250,
        slow: 400,
        easing: const ThemeEasing(
          defaultValue: 'ease',
          inValue: 'ease-in',
          out: 'ease-out',
          inOut: 'ease-in-out',
          spring: 'cubic-bezier(0.34,1.56,0.64,1)',
        ),
      ),
      zIndex: const ThemeZIndex(
        base: 0,
        raised: 10,
        sticky: 50,
        overlay: 100,
        modal: 200,
        popup: 300,
        tooltip: 400,
        max: 9999,
      ),
    ),
    meta: const TemplateMeta(title: 'Test'),
    dataSchema: const {},
    pages: {
      'home': const ComponentNode(
        id: 'home-root',
        type: ComponentType.container,
        children: [
          ComponentNode(id: 'child-a', type: ComponentType.heading, props: {'text': 'Hi'})
        ],
      )
    },
  );
}

