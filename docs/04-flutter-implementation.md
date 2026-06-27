# 04 · Flutter implementation

Production mobile stack. This maps Neptune tokens → Flutter Material 3. **Reference, not a build script** — adapt to your architecture.

## Principles
- `MaterialApp(theme:…, darkTheme:…, themeMode:…)` with `useMaterial3: true`.
- A **bank = a pair of `ThemeData`** (light + dark). Swapping banks swaps the `ThemeData`; widgets never change.
- Read everything from `Theme.of(context)` — `colorScheme`, `textTheme`, component themes. **No literal colours, radii or fonts in widgets.**

## Colour
Author roles in OKLCH (`tokens/themes.css`) → convert to `Color` (ARGB) at build time (precompute, or use a small OKLCH→sRGB step in your token pipeline). Build the scheme explicitly so it matches the reference exactly:

```dart
const tritonLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0A7B55), onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFB8EBD6), onPrimaryContainer: Color(0xFF06291C),
  secondary: …, tertiary: Color(0xFF9A6B12), /* gold */ …
  surface: Color(0xFFFAFCFB), onSurface: Color(0xFF1A201D),
  // …all roles, mirrored for Brightness.dark…
);
```
Neptune's `success` role isn't in `ColorScheme` — carry it in a `ThemeExtension`:
```dart
@immutable class NptColors extends ThemeExtension<NptColors> {
  final Color success, onSuccess, successContainer, onSuccessContainer;
  // copyWith + lerp …
}
// usage: Theme.of(context).extension<NptColors>()!.success
```
> `ColorScheme.fromSeed(seedColor: …, brightness: …)` is fine for a fast/light-touch theme, but Neptune's tuned palettes (calm surfaces, specific containers) should be authored explicitly to match the reference.

## Shape
Map the corner family to a `ThemeExtension` and the M3 component shape themes:
```dart
class NptShape extends ThemeExtension<NptShape> {
  final double xs, sm, md, lg, xl, xxl; // 9999 → StadiumBorder
}
// Triton: xs12 sm18 md26 lg34 xl44 xxl56 ; Nereid: xs4 sm8 md12 lg18 xl26 xxl36
cardTheme: CardThemeData(shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(shape.md))),
filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
  shape: const StadiumBorder())), // pill
```

## Typography
Bundle the fonts (or `google_fonts`) and build a `TextTheme` per brand:
```dart
TextTheme nptText(String display, String text) => TextTheme(
  displayLarge: TextStyle(fontFamily: display, fontSize: 57, height: 64/57,
    fontWeight: FontWeight.w700, letterSpacing: -0.02 * 57),
  headlineMedium: TextStyle(fontFamily: display, fontSize: 28, fontWeight: FontWeight.w700),
  titleMedium:   TextStyle(fontFamily: text, fontSize: 18, fontWeight: FontWeight.w600),
  bodyLarge:     TextStyle(fontFamily: text, fontSize: 16),
  labelLarge:    TextStyle(fontFamily: text, fontSize: 14, fontWeight: FontWeight.w600),
);
```
Money: use `FontFeature.tabularFigures()` (`fontFeatures: [FontFeature.tabularFigures()]`).

## Assembling a bank theme
```dart
ThemeData bankTheme(ColorScheme scheme, NptShape shape, TextTheme text, NptColors extra) =>
  ThemeData(useMaterial3: true, colorScheme: scheme, textTheme: text,
    extensions: [shape, extra],
    cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(shape.md))),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer),
    /* button / input / chip / fab themes from tokens */);

// swap brand at launch / login:
MaterialApp(theme: tritonLight, darkTheme: tritonDark, themeMode: ThemeMode.system);
```
Drive the active brand from a provider (Riverpod/Bloc/InheritedWidget) so login or build flavour selects it.

## Motion
```dart
const emphasized = Cubic(.2,0,0,1), spring = Cubic(.34,1.56,.64,1);
// durations 300 / 500 / 450 ms ; honour MediaQuery.disableAnimations / reduce-motion
```

## RTL & a11y
- `MaterialApp(locale, supportedLocales, localizationsDelegates)`; layout with `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`. Test `Directionality(textDirection: TextDirection.rtl)`.
- Targets ≥ 48dp, respect `MediaQuery.textScaler`, label everything for screen readers, meet WCAG AA.

## Checklist before shipping a bank
- [ ] Light + dark `ColorScheme` authored & contrast-checked
- [ ] Shape extension fills xs…xxl
- [ ] Display + text fonts bundled; tabular figures on money
- [ ] `success` extension wired
- [ ] Component themes (nav bar, buttons, inputs, chips, fab, card) set from tokens
- [ ] RTL verified on every screen
- [ ] No literal colour / radius / font anywhere in widget code
