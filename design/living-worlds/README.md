# Odyssey 3 — Living Worlds preview

An opt-in design direction: warm paper, editable flat illustration, semantic colour and clear task hierarchy. Institutional examples use fictional **Clarity** and **Reserve** identities; Drive and Orbit explore more expressive consumer experiences.

Open `prototype/index.html`, or visit the repository's `site/living-worlds/` preview. Read [PLAYBOOK.md](PLAYBOOK.md) for the drawing philosophy, component/state contract and implementation limits.

- `tokens/odyssey.tokens.json`: canonical source; regenerate with `python3 generate.py`.
- `tokens/odyssey.dtcg.json`: resolved DTCG 2025.10 groups.
- `assets/`: ten editable SVG masters.
- `prototype/`: dependency-free interactive design review; `node prototype/check.cjs` verifies arithmetic and route targets.
- `platforms/`: generated opt-in Material 3 bridges.

Flutter: `import 'package:neptune_flutter_ui/neptune_living_worlds.dart';` then `MaterialApp(theme: odyssey3Theme(brand: 'Clarity'))`. Register Hanken Grotesk, Baloo 2 and Beiruti in the host. These themes are for native Material widgets; Odyssey 2 widgets requiring Neptune theme extensions need a deliberate migration.

Compose: `MaterialTheme(colorScheme = odyssey3Colors("Drive", dark), shapes = odyssey3Shapes("Drive")) { … }`. Import `ly.neptune.odyssey.livingworlds.*` and supply the host typography. This does not replace NeptuneTheme's CompositionLocals.

The existing Odyssey 2 public API, defaults and package version remain intact. This preview is not a production payment, ride, booking or authentication integration. The browser has English journeys, theme switching and Arabic home-layout proofs. Exact validation scope is recorded in the PR.
