# Instructions for designers and coding agents

Read PLAYBOOK.md before changing this kit. Use tokens/odyssey.tokens.json as the source; regenerate with `python3 generate.py`. Do not edit generated CSS or adapters by hand.

- Keep shared components brand-agnostic. Change identity data, not a bank-specific branch.
- Preserve the Vega drawing grammar: editable flat vectors, navy contour, warm paper, 3–5 fills, one human action, generous breathing room.
- Institutional screens give amounts, counterparties and status priority. Expressive scenes belong mainly to welcome, discovery, empty and support views.
- Preserve exact LYD arithmetic, fee disclosure, confirmation before submission and separate unknown/pending/failed/success states. Never resubmit while reconciling an unknown outcome.
- Use logical layout properties, LTR isolation for numerals, native labelled controls, keyboard focus and reduced motion.
- The Figma Arabic pages are localized home proofs. Do not claim the full journeys are translated.
- The platform adapters are opt-in Material 3 bridges, not drop-in replacements for Odyssey 2 extensions or production integrations.
- Bank names and client prototypes stay in this private deliverable. Public repository examples must use fictional Clarity/Reserve identities and no bank logos or screenshots.
- Run `python3 generate.py`, `node prototype/check.cjs`, relevant platform checks and a real browser visual pass after meaningful changes. Read QA.md for tested scope and remaining limits.
- No extra framework, icon package or animation runtime is needed for the portable prototype. Native HTML/CSS/JS and editable SVGs cover its scope.
