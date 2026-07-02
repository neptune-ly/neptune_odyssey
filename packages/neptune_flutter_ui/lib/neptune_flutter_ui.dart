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

// Theming.
export 'src/theme/color_schemes.dart';
export 'src/theme/extensions.dart';
export 'src/theme/identity.dart';
export 'src/theme/neptune_theme.dart';
export 'src/theme/brand_tables.dart'
    show kBrands, brandConfig, brandShape, brandType, brandSuccess, motionFor;

// Widgets.
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
// 2.4.0 — the "fully fledged" widget set (form fields, selection controls,
// overlays, navigation, display primitives, premium fintech).
export 'src/widgets/neptune_form_fields.dart';
export 'src/widgets/neptune_selection_controls.dart';
export 'src/widgets/neptune_overlays.dart';
export 'src/widgets/neptune_navigation.dart';
export 'src/widgets/neptune_display.dart';
export 'src/widgets/neptune_fintech.dart';
