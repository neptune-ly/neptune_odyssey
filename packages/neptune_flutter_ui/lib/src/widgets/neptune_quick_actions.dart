// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import 'neptune_icon_slot.dart';

/// How a row of quick actions is composed — the `actionRow` lever (codec
/// `kActionRows`), rendered.
///
/// The pale tonal circle behind every glyph carries no information: it is the
/// same shape, the same size and the same role colour for "transfer" as for
/// "services", and it was identical on every white-label bank. These three
/// are compositions, not tints.
///
/// ALL THREE RANK THEIR ROW, AND NONE OF THEM RANKS IT BY DIMMING THE PEERS.
/// A quick-action row is one primary and three peers, every one of them
/// enabled; a peer drawn in the neutral ramp's tonal grey is wearing the
/// colour this app paints a control it has switched off, and the customer
/// reads it that way. So the peers keep the brand's own ink at full strength
/// and the lead is told apart by FORM — filled against tonal, filled against
/// outlined, ruled against bare — which is a difference each bank can express
/// in its own vocabulary without any of them borrowing an accent it does not
/// have.
enum NeptuneQuickActionShell {
  /// A tonal disc in the brand's own `primaryContainer` behind each glyph,
  /// and the lead action filled in `primary` with its own glow. The default,
  /// and what every host that names no shell keeps.
  filledCircles,

  /// No chip. One strip ruled top and bottom, the actions divided by
  /// hairlines — the column header of a register. The lead action is marked
  /// by a 2dp rule under its own cell and by weight, never by colour: this is
  /// the shell a bank with no accent at all wears.
  registerRows,

  /// Each action in its own hairline cell on the page's own paper, and the
  /// FIRST action — the one that moves the customer forward — marked in the
  /// brand's accent. The host orders its actions so the forward one leads.
  ruleGrid,
}

/// Carries the row's composition down to each [NeptuneQuickAction], so the
/// host keeps handing over a plain list of actions and no action has to be
/// told which bank it belongs to.
class _QuickActionShellScope extends InheritedWidget {
  final NeptuneQuickActionShell shell;
  final bool lead;

  const _QuickActionShellScope({
    required this.shell,
    required this.lead,
    required super.child,
  });

  static _QuickActionShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_QuickActionShellScope>();

  @override
  bool updateShouldNotify(_QuickActionShellScope old) =>
      old.shell != shell || old.lead != lead;
}

/// A single quick action: a circular tonal icon chip above a short label.
///
/// Mirrors the web `<npt-quick-action>` tonal treatment — a
/// [ColorScheme.secondaryContainer] chip with an
/// [ColorScheme.onSecondaryContainer] icon, captioned by a
/// [TextTheme.labelMedium] label in [ColorScheme.onSurfaceVariant].
/// Theme-only (no literal colours/radii/fonts), RTL-safe, 48dp-min target.
class NeptuneQuickAction extends StatelessWidget {
  /// The glyph shown inside the circular chip. Optional: supply this **or**
  /// [iconWidget].
  final IconData? icon;

  /// A host-supplied mark rendered inside the chip instead of [icon] — a
  /// per-brand SVG, an [ImageIcon], a lettermark. White-label apps ship their
  /// own icon sets, so quick actions never force Material glyphs on a brand.
  ///
  /// The widget is laid out in the same square the glyph would occupy and
  /// receives the [ColorScheme.onSecondaryContainer] tint through an
  /// [IconTheme] + [DefaultTextStyle] rather than a hard filter, so a
  /// multi-colour brand mark stays multi-colour. A monochrome SVG should
  /// inherit `currentColor` (i.e. read `IconTheme.of(context).color`) to stay
  /// on-brand across light/dark and every brandprint.
  final Widget? iconWidget;

  /// The caption shown beneath the chip.
  final String label;

  /// Invoked when the action is tapped. When null the action is inert.
  final VoidCallback? onTap;

  const NeptuneQuickAction({
    super.key,
    this.icon,
    this.iconWidget,
    required this.label,
    this.onTap,
  }) : assert(
          icon != null || iconWidget != null,
          'NeptuneQuickAction needs a glyph: pass `icon` (IconData) or `iconWidget`.',
        );

  @override
  Widget build(BuildContext context) {
    final scope = _QuickActionShellScope.maybeOf(context);
    return switch (scope?.shell ?? NeptuneQuickActionShell.filledCircles) {
      NeptuneQuickActionShell.filledCircles =>
        _buildChip(context, lead: scope?.lead ?? false),
      NeptuneQuickActionShell.registerRows =>
        _buildBare(context, lead: scope?.lead ?? false),
      NeptuneQuickActionShell.ruleGrid =>
        _buildCell(context, lead: scope?.lead ?? false),
    };
  }

  /// The quiet register: the mark and its label on the page itself, no chip
  /// to draw a shape that says nothing.
  ///
  /// ONE PRIMARY AND THREE PEERS, IN A BANK THAT HAS NO ACCENT TO SPEND. All
  /// four cells used to be byte-identical, so the row stated four verbs and
  /// ranked none of them — the opposite failure from a row whose peers look
  /// switched off, and the same underlying miss: a quick-action row is not a
  /// list, it is one action and three alternatives.
  ///
  /// This bank's emphasis is weight, ink and a drawn line, never colour and
  /// never a slab, so the [lead] is marked by the register's own device: a
  /// 2dp rule under its cell, its mark in the bank's ink and its caption at
  /// display weight. Nothing is added to the peers and nothing is taken away
  /// from them — they already sit on paper at full-strength ink, which is why
  /// this bank never had the grey-reads-as-disabled problem the other two did.
  Widget _buildBare(BuildContext context, {required bool lead}) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _tappable(
      context,
      DecoratedBox(
        decoration: BoxDecoration(
          border: lead
              ? Border(
                  bottom: BorderSide(color: scheme.primary, width: 2),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 26,
                child: Center(
                  child: NeptuneIconSlot(
                    icon: icon,
                    iconWidget: iconWidget,
                    size: 24,
                    color: lead ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _caption(
                textTheme,
                lead ? scheme.primary : scheme.onSurface,
                bold: lead,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Line structure: a hairline cell per action, and the accent spent once on
  /// the [lead] one — the action that moves the customer forward.
  Widget _buildCell(BuildContext context, {required bool lead}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final accent = theme.extension<NptColors>()!.accent;
    final textTheme = theme.textTheme;
    // The peer's edge is the BANK'S ink, not the list-hairline role. See
    // `_buildBare` and `NeptunePocketVerb`'s tile: a cell outlined in
    // `outlineVariant` is a row in a table, and a customer does not read a
    // table row as something they can press.
    final dark = theme.brightness == Brightness.dark;
    final peerInk = dark ? scheme.onSurface : scheme.primary;
    final mark = lead ? accent : peerInk;

    return _tappable(
      context,
      DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape.rSm,
          border: Border.all(
            // 0.65 is the measured floor for WCAG 1.4.11's 3:1 on a control
            // boundary — see `NeptunePocketVerb`'s tile for the arithmetic.
            color: lead ? accent : peerInk.withValues(alpha: 0.65),
            width: lead ? 1 : 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 26,
                child: Center(
                  child: NeptuneIconSlot(
                    icon: icon,
                    iconWidget: iconWidget,
                    size: 24,
                    color: mark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Full-strength ink on every caption, the lead told apart by
              // weight — see `_buildBare`. A muted caption under an enabled
              // control is the written half of the grey-reads-as-disabled bug.
              _caption(textTheme, scheme.onSurface, bold: lead),
            ],
          ),
        ),
      ),
    );
  }

  Widget _caption(TextTheme textTheme, Color color, {bool bold = false}) =>
      Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: textTheme.labelMedium
            ?.copyWith(color: color, fontWeight: bold ? FontWeight.w700 : null),
      );

  /// The chip and its caption are one button named by the caption — the same
  /// semantics wrapper every shell wears.
  Widget _tappable(BuildContext context, Widget child) {
    final shape = Theme.of(context).extension<NptShape>()!;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.rSm,
        child: child,
      ),
    );
  }

  /// The tonal disc. [lead] — the action that moves the customer forward — is
  /// the only FILLED one, and the only lit one.
  ///
  /// THE PEERS WEAR THE BRAND'S OWN CONTAINER, NOT THE NEUTRAL RAMP'S.
  /// `secondaryContainer` resolves to `#2C384D` on the dark theme — a slab
  /// four values of lightness off the page it sits on, with a muted caption
  /// under it. Next to it the app's genuinely disabled control is `#292B2F`.
  /// A customer cannot be asked to tell those apart, and the honest reading of
  /// the old row was three actions greyed out. `primaryContainer` is the same
  /// idea in the bank's own blue, at a tone that is unmistakably ON in both
  /// brightnesses; the fill and the glow are what say which one leads.
  Widget _buildChip(BuildContext context, {required bool lead}) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final textTheme = Theme.of(context).textTheme;

    final chipRadius = BorderRadius.circular(shape.full);

    // The chip and its caption are one button named by the caption. Without
    // the merge the chip is an unnamed tap target and the caption a stray
    // text node after it.
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // NO GLOW ON THE LEAD, IN EITHER SHELL. Both this row and the pocket
        // hero's carried one — the brand colour at ~30%, blur ~18, offset ~7 —
        // and in every frame this repo renders it comes out as a HARD-EDGED
        // OFFSET DUPLICATE of the disc in a washed tint, not as a blur: a pale
        // crescent hanging below the one control the row exists to point at.
        // It was reported on FGLB as looking broken, and Andalus has it too.
        //
        // Whatever the blur is doing in the rasteriser, the conclusion is the
        // same: a shadow that cannot be shown to render as a shadow does not
        // ship as one, and it is what every golden and every review shot of
        // this row will keep showing. The hierarchy does not need it — the
        // lead is the only FILLED disc on a row of tonal ones, which is the
        // whole point of `filledCircles` and survives the shadow's removal
        // untouched.
        Material(
            color: lead ? scheme.primary : scheme.primaryContainer,
            borderRadius: chipRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: RoundedRectangleBorder(borderRadius: chipRadius),
              child: SizedBox(
                width: 56,
                height: 56,
                // Center loosens the chip's tight box so the glyph — or a
                // host-supplied [iconWidget] — keeps its natural icon size.
                child: Center(
                  child: NeptuneIconSlot(
                    icon: icon,
                    iconWidget: iconWidget,
                    color: lead
                        ? scheme.onPrimary
                        : scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: lead ? FontWeight.w700 : null,
          ),
        ),
      ],
      ),
    );
  }
}

/// THE REGISTER'S RULES ARE THE BANK'S INK, NOT THE NEUTRAL RAMP'S.
///
/// `outlineVariant` is a grey — `#D1D5DC` on the bank this shell was designed
/// for — and a strip of four cells boxed in grey on white is the "grey slab"
/// its charter forbids outright: it read as an unstyled table floating between
/// the band above it and the register below. The same rule at 0.22 of the
/// page's own ink is the hairline a ruled document actually uses, and it is
/// the same family as every other rule this bank draws.
Color _registerRule(ColorScheme scheme) =>
    scheme.onSurface.withValues(alpha: 0.22);

/// A row of evenly-spaced [NeptuneQuickAction]s.
///
/// Mirrors the web `<npt-quick-actions>` — actions are laid out in equal,
/// top-aligned [Expanded] cells so they share the available width. When more
/// actions than [columns] are supplied they wrap onto further rows. Theme-only,
/// RTL-safe (logical layout mirrors automatically).
class NeptuneQuickActions extends StatelessWidget {
  /// The actions to display.
  final List<NeptuneQuickAction> actions;

  /// The number of actions per row before wrapping. Defaults to 4.
  final int columns;

  /// The composition — see [NeptuneQuickActionShell]. The host reads its
  /// brandprint's `actionRow` lever once and passes the result here.
  final NeptuneQuickActionShell shell;

  /// Whether the FIRST action is marked in the brand's reserved accent.
  ///
  /// True is right where this row is the screen's forward motion: on a home
  /// screen the lead verb is the thing the customer came to do, and a brand
  /// that reserves one colour per screen spends it there.
  ///
  /// It is wrong on a screen that has ALREADY spent it. A card page draws the
  /// card, and on a brand whose mark is a red arrow the card is the spend — so
  /// an accented lead action put a second red object on the same screen and
  /// broke the once-per-screen rule from inside the component that exists to
  /// honour it. The host knows which screen it is on; the component cannot.
  ///
  /// Defaults true, so every existing caller and every shipped brand is
  /// byte-identical.
  final bool accentLead;

  const NeptuneQuickActions({
    super.key,
    required this.actions,
    this.columns = 4,
    this.shell = NeptuneQuickActionShell.filledCircles,
    this.accentLead = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final perRow = columns < 1 ? 1 : columns;

    final rows = <Widget>[];
    for (var start = 0; start < actions.length; start += perRow) {
      final end =
          (start + perRow) < actions.length ? start + perRow : actions.length;
      final slice = actions.sublist(start, end);

      final gridded = shell == NeptuneQuickActionShell.ruleGrid;
      final ruled = shell == NeptuneQuickActionShell.registerRows;

      final cells = <Widget>[
        for (final (i, action) in slice.indexed) ...[
          // The hairline between two register cells belongs to neither of
          // them, so it is drawn here rather than as a border on both.
          if (ruled && i > 0)
            Container(width: 1, color: _registerRule(scheme)),
          if (gridded && i > 0) const SizedBox(width: 10),
          Expanded(
            child: _QuickActionShellScope(
              shell: shell,
              lead: accentLead && start + i == 0,
              child: action,
            ),
          ),
        ],
        // Pad the final row so trailing cells keep their natural width.
        for (var i = slice.length; i < perRow; i++) ...[
          if (gridded) const SizedBox(width: 10),
          const Expanded(child: SizedBox.shrink()),
        ],
      ];

      if (rows.isNotEmpty) rows.add(const SizedBox(height: 16));
      rows.add(
        // The register strip's dividers run the full height of the tallest
        // cell, which needs a bounded height — a stretched Row in an
        // unbounded box is the trap the rulebook names.
        ruled
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cells,
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cells,
              ),
      );
    }

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );

    if (shell != NeptuneQuickActionShell.registerRows) return body;

    // Ruled top and bottom: the strip is one entry in the register, not four
    // floating chips.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: _registerRule(scheme), width: 1),
        ),
      ),
      child: body,
    );
  }
}
