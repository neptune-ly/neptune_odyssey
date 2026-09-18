# Living Worlds: opt-in migration

The illustration-led Odyssey 3 preview is a deliberate alternative to Odyssey 2's glass/gradient identity surfaces. The existing rulebook continues to describe released v2 components. For the new preview subtree, [the Living Worlds playbook](../design/living-worlds/PLAYBOOK.md) defines the visual contract.

1. Start with a single host surface using native Material primitives. Select a reference identity and compare light/dark and LTR/RTL layouts.
2. Load `design/living-worlds/tokens/odyssey.css` on web; set `data-brand="Clarity|Reserve|Drive|Orbit"` and `data-mode="light|dark"` on the root. Existing `data-theme` v2 selectors are separate.
3. Flutter uses the new `neptune_living_worlds.dart` entry point. Register the documented fonts and provide localization/directionality. Do not wrap old custom widgets that require Neptune extensions without adapting those dependencies.
4. Compose uses `odyssey3Colors` and `odyssey3Shapes` in a native MaterialTheme subtree. Continue using NeptuneTheme for existing Neptune-specific components until their CompositionLocals are migrated.
5. Replace one product pattern at a time: field/button → summary/status → navigation → account/travel compositions. Preserve real service state machines and idempotency.
6. Verify target-platform semantics, scaling, fonts and keyboard behaviour. The browser is a design prototype; it cannot establish production service correctness.

Client logos, names, screenshots and demos remain outside the public repository. Clarity and Reserve are fictional reference identities. No existing production package has been automatically published or restyled by this preview.
