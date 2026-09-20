# Odyssey agent usage guide

Odyssey is the system. Its shared illustration character can become warmer or quieter by product context without becoming the default tone for every product.

Keep vivid colour, warmth and human character in every expression. Professional contexts need clear hierarchy and careful detail; they can still feel alive and distinctive.

## Choose expression by context

| Context | Use | Keep controlled |
| --- | --- | --- |
| Wallet, onboarding, discovery, Drive and Orbit | a fuller drawn scene, paper field and one or two bright accents | one message and one main action per surface |
| Bank home, account detail and ordinary service | a compact scene or no scene, institutional product colors and generous factual space | color intensity, decorative marks and expressive typography |
| Transfer review, OTP, KYC, fraud, limits, legal and operations | calm core components; optional small orientation artwork only | no loops, confetti, money-flight, premature ticks or playful status cues |

## Build sequence

1. Load `tokens/odyssey.core.<mode>.tokens.json`, then one matching public product file if the journey is Drive or Orbit.
2. Use the 48 px minimum touch target and the 56 px primary target. Preserve the spacing, radius, stroke and type tokens rather than inventing near-duplicates.
3. Put semantic UI copy beside the scene. A scene can support a state but cannot prove it. For any financial state show its label and the relevant amount, fee, timestamp, reference and recovery/support route.
4. Use an icon from `icons/` as an inline SVG with `currentColor`. Do not rasterize it or change its 24×24 viewBox.
5. For production art, use [`illustration-guidelines.md`](illustration-guidelines.md). `illustrations/` contains four raster illustration studies with their prompt and QA records. They are not user-approved final artwork or editable vector/Figma art; record explicit user signoff before final production use.
6. For Arabic, reserve its own measure and use Beiruti. Mirror only directional path marks after checking the full RTL screen; never mirror QR, account identifiers, maps, numbers or brand marks.

## Shared type mapping

Use Hanken Grotesk for English, Beiruti for Arabic, and zero tracking. Material slots below apply to Flutter and Compose; web uses the corresponding named style variables. Sizes and line heights are in logical pixels.

| Style | EN → AR size/leading | Weight | Material slots |
| --- | --- | ---: | --- |
| Display | 40/48 | 700 | displayLarge, displayMedium |
| Heading | 32/40 | 700 | headlineLarge, headlineMedium |
| Title | 24/32 | 700 | headlineSmall, titleLarge |
| Subtitle | 20/28 | 600 | titleMedium, titleSmall |
| Body | 16/24 → 20/28 | 400 | bodyLarge |
| Body small | 14/20 → 18/24 | 400 | bodyMedium |
| Label | 14/20 → 18/24 | 600 | labelLarge, labelMedium |
| Caption | 12/16 → 16/22 | 400 | bodySmall |
| Amount | 36/44 | 600 | displaySmall |

Material labelSmall uses Caption metrics at weight600. Amount is a financial value style, never a title substitute. Expressive and travel display faces are separate choices; do not apply them to every component.

## Odyssey drawing grammar

Use a dedicated image model or illustrator, never code-drawn SVG/Figma primitive stand-ins. The shared grammar is rounded navy contour, simplified expressive faces, or no facial features when the product brief requires it, warm human skin, believable gestures, flat colour planes and intentional quiet space. Make one action legible at 180 px. Keep institutional banking sparse, everyday banking warm and expressive discovery fuller without creating a separate visual identity. Avoid gradients, texture, photorealism, glass and decorative line noise.

The complete prompt, crop, accessibility, RTL, truthfulness and raster/vector handoff rules live in [`illustration-guidelines.md`](illustration-guidelines.md). Motion is semantic: feedback 120 ms, navigation 200 ms, reveal 320 ms; reduce or remove it when requested. No autonomous movement on transfer review, OTP, KYC, fraud or legal consent.

## Private identity boundary

Client bank expressions are distributed separately. Public documentation, demos, packages and GitHub Pages use generic Core, Drive or Orbit content; do not add private names, marks or values.
