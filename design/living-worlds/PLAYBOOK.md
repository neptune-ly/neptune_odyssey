# Odyssey 3 — Living Worlds

**Design release 3.0.0-design.1 · 18 September 2026 · Neptune**

A little more life. A lot more clarity. Odyssey is the shared product language; each brand is an identity configuration. Vega supplies the visual grammar: warm paper, confident navy outlines, simple human gestures, bright flat accents and generous space. Banks use this language with restraint. Mobility and travel give it more room.

## 1. What the system believes

1. **The task leads.** Amounts, counterparties, prices, status and next steps outrank decoration. A transfer confirmation is evidence; an illustration is atmosphere.
2. **One expressive moment per view.** Choose an illustration, a large colour field or a strong headline. Do not turn all three up together on a transaction screen.
3. **Warmth comes from drawing and language.** Use human gestures and concrete copy. Avoid gradients, glass, glow, fake three-dimensional objects, arbitrary mascots and decorative icon confetti.
4. **Shared structure, distinct expression.** Components never inspect a bank name. Identity data chooses palette, shapes, type and illustration intensity.
5. **Uncertainty is a real state.** Pending, unknown, failed and completed must have different words and different next actions. Rechecking a submitted request must not resubmit it.

This is a deliberate new direction from Odyssey 2's glass/gradient doctrine. It is versioned separately; the current production release is not silently restyled.

## 2. Two expression ranges

| Decision | Institutional: Clarity / Reserve | Everyday: Drive / Orbit |
|---|---|---|
| Main purpose | Trust and precision | Movement and discovery |
| Surface | Warm paper, white panels | Warm paper, larger coloured panels |
| Display typography | Hanken Grotesk, confident and quiet | Baloo 2, rounded and expressive |
| Body typography | Hanken Grotesk | Hanken Grotesk |
| Arabic | Beiruti | Beiruti |
| Illustration target | 8–12% of task views; more at welcome/empty/help | Up to 36–40% at discovery/welcome; reduce during decisions |
| Control radius | Clarity 12; Reserve 8 | Drive 24; Orbit 20 |
| Panel radius | Clarity 16; Reserve 12 | Drive 28; Orbit 24 |
| Accent | Clarity sky; Reserve sand | Drive coral; Orbit sky/lemon |
| Motion | Brief state feedback | Brief feedback plus a purposeful scene transition |

Coverage percentages are composition guidance, not a forced layout constraint. Clarity and Reserve are fictional institutional reference identities. No client identities or logos are included in this public release.

Vibrancy does not require saturated text everywhere. Use bright colour in a contained illustration or surface, then place dark navy text on it. Use semantic role pairs for controls and messages. The normal bank transaction page should remain calm even when the welcome view feels lively.

## 3. Illustration grammar

### Construction

- Author SVG first. Keep objects and body parts as editable closed paths. Use a 360 × 240 scene or 240 × 180 spot; larger scenes may use 640 × 400.
- Anchor contours in navy `#07315F`, typically 3–4 px on a 360 px master. Keep round joins and caps. Interior marks use 2–3 px. Scale the whole artwork uniformly, including strokes.
- Build from broad silhouettes: soft quadrilaterals, arcs, ellipses and simple tapered limbs. Slight asymmetry gives life; random distortion does not.
- Use 3–5 main flat fills plus navy. The palette includes sky, coral, teal, sand, mint, lemon, lavender and peach. Use white/paper as breathing room.
- One recognisable action per scene: receiving a card, greeting a driver, holding luggage, checking a document. Faces are minimal; hands and posture communicate the action.
- A low-contrast ground ellipse or cloud may support the subject. Leave 12–16% clear perimeter and at least 20% internal negative space.
- Add at most three small directional marks. A star can be an occasional visual accent; never use it as a success or security indicator.
- Maintain a believable everyday setting without cultural caricature. Reflect local people and places through ordinary situations, not stereotyped clothing or symbols.

### Use and adaptation

| Context | Good | Avoid |
|---|---|---|
| Bank welcome | Small local institution or people scene | Cartoon cash piles or celebration of wealth |
| Transfer review | No illustration; clear summary | Art competing with amount or recipient |
| Pending | Quiet hourglass + explicit status copy | Confetti or a checkmark implying completion |
| Unknown result | Text-led warning and recheck action | Retry-payment CTA before reconciliation |
| Drive | Person, vehicle and simple streetscape | Unverified live-location markers |
| Orbit | Traveller, bag and departure gesture | Fake airline logos or real ticket barcodes |
| Dark mode | Retain bright flat artwork on a deliberate plate | Automatically invert or recolour skin/hair |
| Arabic | Mirror directional controls when needed | Mirroring people, text, currency, vehicles or geography indiscriminately |

`route-preview.svg` is a **schematic diagram**, not geographic or live map data. Production maps need a real provider and a parallel text itinerary.

### Master asset inventory and provenance

Seven editable source drawings were recovered from the user-supplied Vega file: everyday-people, local-bank, security-shield, waiting-hourglass, wallet-beginning, wallet-hand and payment-receipt. Drive-street, orbit-departure and route-preview were authored for this release using the same flat contour grammar. These assets contain no external stock photography. Source ownership remains with the source owners; this package does not relicense third-party fonts or bank identities.

### Brief for a designer or agent

> Create an editable flat SVG scene for [product/context], depicting [one action]. Use the Odyssey palette and a consistent navy outline. Compose on [size] with 12–16% clear perimeter. Use 3–5 flat fills, rounded contours, simple human gestures and one quiet ground shape. For institutional work, reduce visual coverage and decorative marks. Preserve amounts, status and task actions as the visual priority. Deliver named vector groups and an SVG with viewBox. Check at 120 px and at the intended display size. Do not include logos, text baked into paths, gradients, blur, glow, photorealistic shading or emoji.

Do not ask an image generator to reproduce a raster screenshot and call it a reusable illustration master. A raster draft can inform a designer, but the delivered system assets must remain editable.

## 4. Foundations and token contract

The canonical source is `tokens/odyssey.tokens.json`. It defines 127 tokens in six collections: Palette, Identity, Theme, Dimensions, Typography and Motion. Figma adds two private session variables for demo balances; those are not design tokens.

| Layer | Responsibility | Edit rule |
|---|---|---|
| Palette | Reusable raw colours | Never bind meaning directly to a palette colour in a product component |
| Identity | Brand choices | Add an identity mode instead of forking a component |
| Theme | Light/dark semantic roles | Pair foreground and background roles |
| Dimensions | Space, targets, radii | 4 px base; 48 px minimum interactive targets; 56 px default control |
| Typography | English/Arabic families and sizes | Keep content separate from font choice |
| Motion | Feedback/enter/exit/scene/stagger | All durations become zero in reduced-motion mode |

The palette may be bound directly in artwork. Product text and controls use semantic roles. Tokens are the API: a rename or meaning change requires migration, not a silent replacement.

Type scale (English size/line-height): hero 64/72, display 40/48, heading 28/36, title 20/28, body and label 16/24, caption 14/20, micro 12/16, amount 36/44. Arabic small text gains 2 px; line-height gains 4 px. Use tabular numerals and isolate account numbers, amounts, route codes and dates as LTR runs inside RTL text. Never letter-space Arabic.

Spacing: 0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80. Border radii: 0–32 plus pill. Money always uses three decimal places in these LYD prototypes. Store money as integer milli-dinars; format only at the edge.

## 5. Components, states and Material 3

Odyssey is a product layer over Material 3, not a replacement for its accessibility and interaction primitives. Use native Material controls for date entry, menus, dialogs, selection and keyboard behaviour. The Figma kit supplies the shared visual/product patterns used by these journeys; it does not claim to reproduce every component in the entire Material library.

Core families: Button, Field, Choice, Switch, Checkbox, Status, App bar, Heading, List row, Balance, Summary, Payment card, Flight option, Ride option, Journey, Navigation item/bar, Sheet and Illustrated panel. Text properties are exposed on masters. Illustration instances can be swapped. Button states cover default, hover, pressed, focus, disabled and loading across three styles. Field, choice, switch, checkbox, status, card and selectable options have state variants.

| Figma pattern | Flutter | Compose | Web |
|---|---|---|---|
| Button | FilledButton / OutlinedButton / TextButton | Button / OutlinedButton / TextButton | button |
| Field | TextFormField | OutlinedTextField | labelled input |
| Choice | RadioListTile / CheckboxListTile | RadioButton / Checkbox | radio / checkbox |
| Navigation | NavigationBar / NavigationRail | NavigationBar / NavigationRail | nav with aria-current |
| Sheet | showModalBottomSheet / Dialog | ModalBottomSheet / AlertDialog | dialog with focus return |
| Status | Semantics live region + text | liveRegion semantics | role=status / role=alert |
| Balance, Journey, Summary | Composition of themed primitives | Composition of themed primitives | semantic section + text |

Error recovery lives beside the failed task. Error text names the problem and the next action. Disabled controls explain prerequisites. Loading locks the submitted action but leaves support and recovery available. A selected tab identifies a destination; a CTA initiates an action.

## 6. Flow contracts

**Clarity / Reserve:** sign-in → accounts → recipient → amount + fee → review → code → submitted → receipt; unknown result rechecks the original request; declined result returns to editing. Additional flows cover adding a recipient, bills, card freeze/unfreeze, account opening, support and preferences. Native Figma uses deterministic sample amounts and one transfer/bill per reset; the browser allows edited amounts and uses idempotent in-memory settlement.

**Drive:** pickup → destination → vehicle estimate → review → matching → driver assigned → trip → receipt/rating. Cancellation shows its fee before confirmation. Driver journey: online → offer → pickup PIN → trip → cash collection → earnings. The in-trip rider view advances after eight seconds to simulate arrival. Nothing tracks a real location or contacts a real driver.

**Orbit:** search → results → fare rules → passenger → baggage → review → payment received → ticket issued. A checked-bag branch carries its 710 LYD total through payment and ticket. Unknown payment rechecks; a declined payment returns to editing; a fare change requires renewed review. Cancellation separates requested, cancelled and refund processing. Example Air and all fares, schedules, references and refund times are fixtures, not commercial offers or policy guidance.

The browser's recovery-state controls live in the surrounding review studio. They are not proposed production UI. Support submission confirms a **simulated** request; no message is sent.

## 7. Responsive, Arabic and accessibility

Mobile: 402 px reference, 24 px content margins, vertical task order. Below 380 px use 20 px margins and allow wrapping. Desktop: 1440 px reference, 12 columns, 24 px gutters and a persistent navigation rail. At 840 px collapse navigation; at 600 px stack task panels. Do not stretch a phone card until it fills a desktop.

All browser journeys share light/dark semantic roles. Figma contains explicit Arabic and dark home proofs for every identity, plus four desktop compositions. **Arabic is a home-layout proof, not a complete translated journey.** Production Arabic copy, legal wording, screen-reader announcements and full platform navigation require local review before release.

Keep heading order, labelled controls, keyboard focus, 48 px targets, non-colour status text and reduced-motion handling. Validate text scaling and RTL on real Flutter/KMP targets before rollout. Automated contrast checks cover 80 foreground/background pairs; they are not a full accessibility certification.

## 8. Motion language

Feedback 120 ms; entry 240 ms; exit 160 ms; scene 480 ms; stagger 40 ms. Use ease-out for arrivals and ease-in for departures. Restrict playful object motion to discovery and welcome. Do not move amounts during review. Never pulse security status or animate a balance to imply a change that has not been confirmed. Native Figma navigation is instantaneous for deterministic review; motion tokens define the implementation contract. Reduced motion removes spatial travel and duration while retaining state feedback.

## 9. Reuse in other tools

- Figma: duplicate or publish the local component/variable library from the new file. The file is not automatically published as a team library.
- Claude or another agent: provide this playbook, `AGENTS.md`, source tokens, a chosen screen specification and the relevant SVGs. Ask for a native layout composed from these patterns.
- Other design tools: import SVGs as editable vectors. Use `odyssey.dtcg.json` where supported, or `resolved.json` when a tool cannot resolve modes. Cross-tool import does not preserve every Figma interaction/property automatically.
- Web: load `odyssey.css`; set `data-brand` and `data-mode` on the root. Use semantic variables, not palette literals in components.
- Flutter: opt into `odyssey3Theme`; register the three font families, supply directionality/localization and use Material widgets. Existing Neptune 2 widgets that require custom theme extensions are not automatically compatible with this adapter.
- KMP: opt into `odyssey3Colors` and `odyssey3Shapes` inside MaterialTheme; provide fonts and typography in the host. This colour/shape adapter does not replace Neptune 2 CompositionLocals.

## 10. Governance and shipping

Change tokens first, then component behaviour, then composed screens. Keep a screenshot of the changed state in light/dark and LTR/RTL. Verify a banking and an everyday identity so an improvement does not silently favour one. Record changes by token and observable behaviour. Do not merge client logos, bank demos or client screenshots into the public repository. Public examples use fictional Clarity/Reserve identities.

Before production: integrate real authentication and idempotent services, review banking/airline conditions with owners, replace schematic maps, add complete localization, verify assistive technology, and run target-platform tests. This deliverable is a design system and working prototype, not deployed financial or travel infrastructure.

References: [DTCG 2025.10 format](https://www.designtokens.org/tr/2025.10/format/), [DTCG colour](https://www.designtokens.org/tr/2025.10/color/), [Material 3 theming](https://developer.android.com/codelabs/m3-design-theming). Source designs: user-supplied Odyssey 2 and Vega Figma files.
