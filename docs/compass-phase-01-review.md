# Odyssey 2.0 — Phase 1 Compass review checkpoint

Status: **built in the existing Figma; owner review pending**.
Date: 17 September 2026.
Repository branch: `odyssey-2-product-worlds`. PR #2 remains a draft; do not merge or publish this design as an approved release.

This checkpoint follows the owner's rejection of the recent generic, incomplete domain extension. It records concrete Phase 1 work, not a completed component library or a production migration.

## Continue here, not from a blank file

Existing Figma: https://www.figma.com/design/JuC8o1hJzoGv8G6EHGXoro
New page inside that file: **28 · Compass / Constitution & quality proof**, node `292:33`.

| Board | Node | Evidence |
| --- | --- | --- |
| C01 — Compass | `292:34` | Shared foundation and independent visual-world, product-grammar and tenant-identity decisions; original art lineage; conflict examples. |
| C02 — Six-world grammar | `292:35` | Orbit, Current, Bloom, Atelier, Signal and Horizon recipes across composition, type/rhythm, shape/surface, navigation, icon/art, motion/voice, data/imagery and rejection rules. |
| C03 — Same task, three compositions | `292:36` | Full-size flight-selection specimens in Orbit, Atelier and Signal using identical fictional inventory and the same next action. |
| C04 — Shared trust | `292:37` | Review, offline-before-request and unknown-after-request specimens; touch target, focus, Arabic numeric isolation, motion and illustration boundaries. |
| C05 — Greyscale proof | `292:38` | Neutral copies of the three selectors for comparison without brand color; explicit visual-review questions. |
| C06 — Repair register | `292:39` | Retained visual evidence of the weak map/property-media examples, missing work, acceptance evidence and the next gate. |

Open an individual board with the file URL plus `?node-id=292-36`, substituting the appropriate node.

## Proposed correction to the model

**Distinct worlds. Shared trust.**

The shared foundation supplies mandatory behavior: accessibility, service-state truth, security, focus and form behavior, responsive rules, RTL, appearance modes, reduced motion and stable component APIs.

Within that boundary, three decisions are independent:

- **Visual world:** composition, hierarchy, typography, silhouette, rhythm, framing, icon/art language, motion and voice.
- **Product grammar:** the entities and tasks of banking, travel, rider, driver, dispatch, commerce, hospitality, SaaS and other domains.
- **Tenant identity:** authorized marks, palette, typography, content and governed identity overrides.

Travel is not automatically a visual world. The same travel grammar can be composed as Orbit, Atelier or Signal. The same world can support multiple domains. A driver product is not a relabeled rider product.

The original six worlds remain the lineage. The domain-named Voyage/Pulse/Market/Harbor/Grid/Canvas additions are provisional experiments, not the approved universal-world taxonomy.

**Important:** the branch's existing `AGENTS.md`, `docs/12-product-worlds.md` and `worlds.ts` still describe the previous proposal. This checkpoint does not silently migrate their runtime contract. Reconcile that model after design review; do not treat the previous branch implementation as visual approval.

## Concrete comparison fixture

All inventory and prices are fictional design fixtures, not live travel offers.

Task: choose a Tripoli-to-Istanbul flight for 18 December 2026, one adult, economy. Two nonstop flights are shown, sorted by departure.

| Fixture | Selected flight | Alternative |
| --- | --- | --- |
| Carrier / flight | Example Air · OD 214 | Example Air · OD 218 |
| Departure / arrival | 09:10 / 13:30 | 14:20 / 18:40 |
| Duration | 3h 20m | 3h 20m |
| Checked bag | 20 kg included | 20 kg included |
| Total including taxes | 1,240 LYD | 1,420 LYD |

The selected fare displays changes with a fee and non-refundable conditions. Times are identified as local. The persistent next action is **Review flight**. No fare condition or inconvenient fact is removed to make a world appear cleaner.

| World | Color specimen | Greyscale copy | Composition |
| --- | --- | --- | --- |
| Orbit | `293:40` | `302:443` | Dark route anchor, isolated ticket, capsule filters, time-led comparison. |
| Atelier | `295:38` | `302:506` | Serif editorial route, unboxed ruled fares, understated controls, sans-serif money. |
| Signal | `296:97` | `302:571` | Joined filter cells, price-led operational register, explicit selection band. |

Every specimen is **402 × 874**. These are static design-review specimens, not full applications or wired booking prototypes.

## Existing assets reused

The new page uses the existing `O2` variable collections and original text styles. Original source pages and masters were left unchanged.

- Original scene components: `21:30`, `23:27`, `26:42`, `26:68`, `26:96`, `26:122`.
- Existing action variants: `18:2`, `18:6`, `18:8`.
- Existing vector icons, including back arrow `29:60`.
- Original outlined wallet-hand art `95:54`, shown separately from functional icons and filled editorial scenes.

The three arrow instances in greyscale diagnostic copies were detached only to remove their inherited color binding. The production-source examples remain linked to their original arrow masters. Greyscale copies are not production sources.

## Boundaries made visible

C04 explicitly distinguishes:

1. **Review:** no payment has been submitted; the next step is clear.
2. **Offline before submission:** preserve the draft, do not invisibly queue a charge, and recheck fare/availability after reconnecting.
3. **Connection lost after submission:** the result is unknown; check the original request before another booking. A timer must not invent success or failure.

It also shows a 24 px vector within a 48 px target, a visible focus specimen, English/Arabic totals with isolated numeric order, and the existing 160/240/420 ms motion levels with reduced-motion constraints.

The art compass distinguishes functional UI icons, outlined object/gesture spots and flat editorial scenes. People require credible anatomy, connected joints, purposeful poses and inclusive roles. Recoloring one figure does not constitute an inclusive character library. Stickers/reactions remain a separate expression layer; they do not replace accessible labels or factual status.

C06 records two concrete rejected uses: the Pulse decorative car used as the main live-trip surface (`257:33`, `270:108`) and generic skyline blocks used as hotel media (`269:150`, `269:165`). Their originals are retained as WIP evidence.

## Scoped verification performed

- Six populated Compass boards exist on page `292:33`.
- Rendered comparison specimens, source-lineage presentation, world recipe, booking states, access examples, illustration examples, greyscale board and repair register were inspected.
- Native auto-layout bounds audit on the new page: **no remaining overflow findings** after fixes.
- All three color-to-greyscale pairs preserve identical text and type attributes.
- Each full-size comparison specimen is 402 × 874 with footer bottom at 874.
- Greyscale diagnostic copies: **137 solid paints checked, zero non-neutral solid paints**.
- Selected light-mode contrast pairs: Orbit onAccent/accent 6.38:1; Atelier 9.99:1; Signal 15.61:1. Muted text against their backgrounds: 5.46:1, 5.43:1 and 5.44:1 respectively.

These checks are not a full accessibility certification, large-text test, dark-mode/RTL screen sweep, runtime test or human art-direction approval. Those remain separate gates.

**New production component masters created in Phase 1: zero.** Documentation cards, review patterns, clones and labels are not counted as completed production components. The existing 304-requirement catalogue remains a scope register, not a claim of 304 finished widgets.

## Next step and stopping point

Wait for the owner's review or **go next**. Continue with **Phase 2 — Foundations** in the existing file: EN/AR type and numerics; semantic color/contrast; shape anatomy; spacing and density; responsive rules; focus/selection; illustration slots. Inspect existing foundation sources before extending them.

Do not restart Odyssey, create a second design system, automatically port the rejected domain proposal, or resume bulk screen generation. The later component library, character/illustration bible, stickers, complete travel product, rider/driver/dispatch ecosystem, other domain templates and production motion remain open work.

Phase 1 changes to the repository are limited to this review checkpoint. No application code, package version, registry release, deployment or merge was performed as part of this phase.
