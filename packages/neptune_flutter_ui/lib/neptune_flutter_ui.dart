// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey — Flutter UI. The vendor-neutral, white-label banking design
// system by Neptune.Fintech (neptune.ly). Public API barrel.
library;

// Brandprint codec + config model + registries.
export 'src/brandprint/codec.dart';

// Colour math (custom seeds).
export 'src/color/oklch.dart';
export 'src/color/palette.dart';
export 'src/color/seed_extractor.dart';

// Theming.
// 2.23.1 — the accessibility contract: host-localised screen-reader strings,
// spoken money, reduced-motion helpers.
export 'src/theme/accessibility.dart';
export 'src/theme/color_schemes.dart';
export 'src/theme/density.dart';
export 'src/theme/extensions.dart';
export 'src/theme/page_transitions.dart';
export 'src/theme/feedback.dart';
export 'src/theme/identity.dart';
export 'src/theme/neptune_theme.dart';
export 'src/theme/numerals.dart';
// 2.24.0 — the finished theme: the field border the filled-field seam needs,
// and the brightness-invariant pre-login canvas.
export 'src/theme/field_border.dart';
export 'src/theme/brand_canvas.dart';
// 2.26.0 — the wrist: the glance type scale and the round-face safe inset.
export 'src/theme/glance.dart';
export 'src/theme/brand_tables.dart'
    show kBrands, brandConfig, brandShape, brandType, brandSuccess, motionFor, hapticWeightFor;

// Widgets.
export 'src/widgets/neptune_numeral.dart';
export 'src/widgets/neptune_balance_card.dart';
export 'src/widgets/neptune_card_art.dart';
export 'src/widgets/neptune_transaction_row.dart';
export 'src/widgets/neptune_primary_button.dart';
export 'src/widgets/neptune_account_tile.dart';
export 'src/widgets/neptune_quick_actions.dart';
export 'src/widgets/neptune_onboarding.dart';
export 'src/widgets/neptune_buttons.dart';
export 'src/widgets/neptune_stat_card.dart';
export 'src/widgets/neptune_dock.dart';
export 'src/widgets/neptune_money_inputs.dart';
export 'src/widgets/neptune_secure_inputs.dart';
export 'src/widgets/neptune_money_movement.dart';
export 'src/widgets/neptune_receipt.dart';
export 'src/widgets/neptune_data_viz.dart';
export 'src/widgets/neptune_corporate.dart';
export 'src/widgets/neptune_wallet_pay.dart';
export 'src/widgets/neptune_shell_feedback.dart';
export 'src/widgets/neptune_data_table.dart';
export 'src/widgets/neptune_shell_nav.dart';
export 'src/widgets/neptune_card_controls.dart';
export 'src/widgets/neptune_toast.dart';
// 2.5.0 — the identity layer: brand motifs, real glass, branded card surface.
export 'src/widgets/neptune_identity_surfaces.dart';
// 2.6.0 — templates & motion: welcome screen, ambient backdrop, brand lockup,
// and the hourglass → check / rejected outcome motion.
export 'src/widgets/neptune_welcome.dart';
export 'src/widgets/neptune_status_motion.dart';
// R6 — loading indicator family + splash screen.
export 'src/widgets/neptune_loaders.dart';
export 'src/widgets/neptune_splash.dart';
// 2.14.0 — the swipe-up unlock ritual (returning-user lock screen).
export 'src/widgets/neptune_unlock_reveal.dart';
// 2.25.0 — the register composition (`statement-ledger`) and the paper
// pre-login shell (`paper-lockup`): what those lever names draw.
export 'src/widgets/neptune_register.dart';
export 'src/widgets/neptune_paper_welcome.dart';
// 2.7.0 — the composed screen templates (all nine from templates.html).
export 'src/templates/neptune_templates.dart';
export 'src/templates/neptune_onboarding_flow.dart';
export 'src/templates/neptune_demo_shell.dart';
// 2.8.0 — state contracts (skeleton/empty/error) + insights bar charts.
export 'src/widgets/neptune_states.dart';
export 'src/widgets/neptune_charts.dart';
// 2.4.0 — the "fully fledged" widget set (form fields, selection controls,
// overlays, navigation, display primitives, premium fintech).
export 'src/widgets/neptune_form_fields.dart';
export 'src/widgets/neptune_selection_controls.dart';
export 'src/widgets/neptune_overlays.dart';
export 'src/widgets/neptune_navigation.dart';
export 'src/widgets/neptune_display.dart';
export 'src/widgets/neptune_fintech.dart';
