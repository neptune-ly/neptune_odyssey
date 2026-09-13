// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/accessibility.dart';
import '../theme/brand_canvas.dart';
import '../theme/extensions.dart';
import '../theme/identity.dart';
import 'neptune_icon_slot.dart';
import 'neptune_identity_surfaces.dart';

/// One item in a [NeptuneDock]. The parent owns selection — set [active] on the
/// current item and handle [onTap].
class NeptuneDockItem {
  /// The Material glyph. Optional: supply this **or** [iconWidget].
  final IconData? icon;

  /// A host-supplied mark rendered instead of [icon] — a per-brand SVG, an
  /// [ImageIcon], a lettermark. White-label apps ship their own icon sets, so
  /// the dock never forces Material glyphs on a brand.
  ///
  /// The widget is laid out in the same 22dp square the glyph would occupy and
  /// receives the item's active/inactive tint through an [IconTheme] +
  /// [DefaultTextStyle] rather than a hard filter, so a multi-colour brand mark
  /// stays multi-colour. A monochrome SVG should inherit `currentColor` (i.e.
  /// read `IconTheme.of(context).color`) to follow the raised-active treatment.
  final Widget? iconWidget;

  final String label;
  final bool active;
  final VoidCallback? onTap;

  const NeptuneDockItem({
    this.icon,
    this.iconWidget,
    required this.label,
    this.active = false,
    this.onTap,
  }) : assert(
          icon != null || iconWidget != null,
          'NeptuneDockItem needs a glyph: pass `icon` (IconData) or `iconWidget`.',
        );
}

/// Which bar a brand's signed-in app stands on — the `navShell` lever
/// (codec `kNavShells`), rendered.
///
/// THE BAR IS IDENTITY, NOT CHROME. Until 2.28.0 the dock had exactly one
/// composition, so every white-label bank wore Andalus's floating pill with
/// its raised circle and differed only in hue — the same "hue is not
/// identity" mistake the login shell and dashboard hero levers already fixed
/// one layer up. A greyscale screenshot of two brands' bars must not look
/// the same; these three do not.
enum NeptuneDockShell {
  /// The floating glass pill, the active item lifted into a filled circle on
  /// the brand spring. The loud register; the default, and what every host
  /// that names no shell keeps.
  raised,

  /// A flat, full-width bar sitting on one `outlineVariant` hairline. No
  /// pill, no float, no fill, no lift: the active item is marked by weight
  /// and the brand colour and nothing else. The quiet, documentary register.
  register,

  /// A full-width bar under a rule, where the active item claims its segment
  /// of that rule in the brand's ACCENT. Structure drawn in lines, not slabs,
  /// and the accent used as direction — which is the one job it has.
  rule,

  /// A SOLID stadium of the brand's own ink, floating clear of every edge,
  /// with the content scrolling visibly underneath it. The active item is a
  /// lozenge of the on-canvas tone inside that stadium.
  ///
  /// It is not [raised] in another colour, and the difference is the whole
  /// point of it being its own shell. `raised` is GLASS: it borrows the page's
  /// colour, so it recedes, and it marks the active item by lifting a circle
  /// out of the bar — an object rising toward the customer. This one is
  /// OPAQUE: it is the single darkest object on a pale page, so it advances,
  /// and it marks the active item by moving a lozenge INSIDE itself — nothing
  /// leaves the bar's outline. A greyscale screenshot of the two is not the
  /// same picture, which is the test this enum exists to pass.
  ///
  /// It takes its fill from [NptBrandCanvas.canvas] rather than from
  /// `colorScheme.primary`, so it is the bank's real colour at both
  /// brightnesses instead of a light tone at night. A page under it must be
  /// laid out with `extendBody: true` and enough trailing padding for the bar
  /// to overlap rather than cover: the overlap IS the signal that the list
  /// continues, and a bar that hides the last row is a bug, not a composition.
  inkPill,
}

/// The bottom navigation bar (web `<npt-dock>`) in one of three
/// compositions — see [NeptuneDockShell]; [NeptuneDockShell.raised] is the
/// original floating glass dock and the default.
///
/// Set [centerGap] to reserve a hole in the middle of the item row so a host
/// app can float its own centre FAB over the dock (the dock itself never owns
/// that button — the host stacks it above and keeps its own hit target).
class NeptuneDock extends StatelessWidget {
  final List<NeptuneDockItem> items;

  /// The composition. The host reads its brandprint's `navShell` lever once
  /// and passes the result here; the widget never reads the theme string
  /// itself, so a lever no template exists for fails at the host's parse
  /// rather than silently drawing the default.
  final NeptuneDockShell shell;

  /// Reserve [centerGapWidth] of empty, inert space in the middle of the item
  /// row for a host-owned floating action button. The glass pane, hairline and
  /// raised-active spring are untouched; taps in the gap hit whatever the host
  /// stacked above it. No-op when false (the default), and no-op on the flat
  /// shells — a bar a FAB hovers over is the raised composition by definition.
  ///
  /// With an even number of [items] — the layout a centre FAB wants — the gap
  /// lands exactly on the dock's centre line. With an odd count the extra item
  /// sits after the gap, so the gap is off-centre by half a cell.
  final bool centerGap;

  /// Width of the reserved [centerGap]. Defaults to 72 — a 56dp FAB plus 8dp
  /// of breathing room each side.
  final double centerGapWidth;

  const NeptuneDock({
    super.key,
    required this.items,
    this.shell = NeptuneDockShell.raised,
    this.centerGap = false,
    this.centerGapWidth = 72,
  });

  @override
  Widget build(BuildContext context) {
    return switch (shell) {
      NeptuneDockShell.raised => _buildRaised(context),
      NeptuneDockShell.register => _buildFlat(context, ruled: false),
      NeptuneDockShell.rule => _buildFlat(context, ruled: true),
      NeptuneDockShell.inkPill => _buildInkPill(context),
    };
  }

  /// The solid brand stadium. See [NeptuneDockShell.inkPill].
  Widget _buildInkPill(BuildContext context) {
    final theme = Theme.of(context);
    final canvas = theme.extension<NptBrandCanvas>()!;

    return Padding(
      // The bar floats, so it is inset from all three edges. The bottom inset
      // is measured from the gesture area rather than added to it: a stadium
      // that clears the home indicator by a fixed 16 sits too low on a device
      // with no indicator and too high on one with a tall one.
      padding: EdgeInsetsDirectional.fromSTEB(
          20, 0, 20, 10 + MediaQuery.paddingOf(context).bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: canvas.canvas,
          borderRadius: BorderRadius.circular(999),
          // The one shadow in this composition, and it earns its place: the
          // bar has to read as being IN FRONT of the content passing under it,
          // and on a pale page an opaque dark stadium with no shadow reads as
          // a hole cut in the page instead.
          //
          // It is NOT `identity.elevation3`, which is tuned for the glass dock
          // — a tight, fairly opaque neutral drop that sits correctly under a
          // translucent pane and, under a solid dark stadium, rendered as a
          // hard GREY BAND reading as a second bar below the first. This is
          // the bar's own colour at low alpha, spread wide and soft: a dark
          // object's shadow is its own colour darkened, never neutral grey,
          // and a wide blur is what reads as height rather than as an outline.
          boxShadow: [
            BoxShadow(
              color: canvas.canvas.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              for (final item in items)
                Expanded(child: _InkPillItem(item: item, canvas: canvas)),
            ],
          ),
        ),
      ),
    );
  }

  /// The flat bars. [ruled] picks the marker: false marks the active item by
  /// weight and the brand colour alone (`register`), true adds the accent
  /// segment on the rule above it (`rule`).
  ///
  /// Both are full-width and flush — a bar is not a floating object, so the
  /// host insets it by nothing and the BAR ITSELF eats the bottom safe area.
  /// That inset has to live inside the fill: a host that pads the widget from
  /// outside leaves a transparent strip under a bar the page scrolls behind
  /// (`extendBody: true`), and the first thing to slide into it is a divider
  /// from the content — a stray hairline floating beside the gesture pill.
  Widget _buildFlat(BuildContext context, {required bool ruled}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = theme.extension<NptColors>()!.accent;

    final cells = [
      for (final item in items)
        Expanded(
          child: _FlatDockItem(
            item: item,
            // A bar cannot lift, so the state has to read without the colour
            // too: _FlatDockItem carries the weight as well.
            color: item.active
                ? (ruled ? accent : scheme.primary)
                : scheme.onSurfaceVariant,
          ),
        ),
    ];

    return Container(
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ruled)
            // One rule across the whole width, thickened into the accent over
            // the active item: the bank's arrow pointing at where you are.
            SizedBox(
              height: 3,
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Container(
                          height: item.active ? 3 : 1,
                          width: double.infinity,
                          color:
                              item.active ? accent : scheme.outlineVariant,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(height: 1, color: scheme.outlineVariant),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                4, 8, 4, 6 + MediaQuery.paddingOf(context).bottom),
            child: Row(children: cells),
          ),
        ],
      ),
    );
  }

  Widget _buildRaised(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final identity = theme.extension<NptIdentity>()!;

    // The glass pane sits 12px below the top of the hit area so the active
    // item's raised circle can pop ABOVE the bar (web `overflow: visible`).
    // Shadow lives OUTSIDE the glass clip so the blur pane stays clean.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          top: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: shape.rXxl,
              boxShadow: identity.elevation3(scheme),
            ),
            child: NeptuneGlass(
              dock: true,
              borderRadius: shape.rXxl,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 8, 10),
          child: Row(children: _cells()),
        ),
      ],
    );
  }

  /// The item row. Every item is an equal-width [Expanded] cell exactly as
  /// before; [centerGap] only splices one fixed-width inert box into the middle
  /// of that list, so the untouched-path layout is byte-for-byte identical.
  List<Widget> _cells() {
    if (!centerGap) {
      return [for (final it in items) Expanded(child: _DockItem(item: it))];
    }
    final split = items.length ~/ 2;
    return [
      for (var i = 0; i < split; i++) Expanded(child: _DockItem(item: items[i])),
      SizedBox(width: centerGapWidth),
      for (var i = split; i < items.length; i++) Expanded(child: _DockItem(item: items[i])),
    ];
  }
}

/// One cell of the [NeptuneDockShell.inkPill] stadium: mark and label side by
/// side, the active one inside a lozenge.
///
/// The label is drawn for the ACTIVE item only. A stadium that fits on one
/// line with four labels in it has labels too small to read, and an icon row
/// with no words at all is the thing every customer complains about; showing
/// the word for where you ARE resolves both, because the other three are the
/// places you are not and their marks only have to be recognisable, not
/// self-explaining. Assistive technology still hears every label — see the
/// [Semantics] below, which does not depend on what is painted.
class _InkPillItem extends StatelessWidget {
  final NeptuneDockItem item;
  final NptBrandCanvas canvas;

  const _InkPillItem({required this.item, required this.canvas});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = theme.extension<NptMotion>()!;
    final text = theme.textTheme;
    final fast = NeptuneAccessibility.duration(context, motion.fast);
    // Inactive ink is the muted on-canvas tone the brand already checked
    // against this exact ground, not an alpha guess: `onCanvasMuted` is the
    // one value in the theme that is guaranteed to read on `canvas`.
    final ink = item.active ? canvas.onCanvas : canvas.onCanvasMuted;

    return Semantics(
      button: true,
      selected: item.active,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.onTap,
        child: AnimatedContainer(
          duration: fast,
          curve: motion.standard,
          height: 46,
          decoration: BoxDecoration(
            color: item.active
                ? canvas.onCanvas.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeptuneIconSlot(
                icon: item.icon,
                iconWidget: item.iconWidget,
                size: 21,
                color: ink,
              ),
              // The label reveals by WIDTH FACTOR, so the marks slide rather
              // than jumping between two layouts.
              //
              // NOT `AnimatedSize`. That measures its child, then restarts its
              // own animation from inside `performLayout`, and when reduced
              // motion collapses the duration to zero it re-dirties itself
              // mid-layout and throws - "a RenderObject must not re-dirty
              // itself while still being laid out". It is not a test artefact:
              // it is every customer who has switched animations off. A
              // clipped `Align` lays the label out once at its full size and
              // reveals a fraction of it, so there is no layout feedback loop
              // to close.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: item.active ? 1 : 0, end: item.active ? 1 : 0),
                duration: fast,
                curve: motion.standard,
                builder: (context, t, child) => ClipRect(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: t,
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 7, end: 3),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: (text.labelMedium ?? const TextStyle())
                        .copyWith(color: ink, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One cell of a flat bar ([NeptuneDockShell.register] / `.rule`): the mark
/// over its label, both in [color], no chip and no lift. The active state is
/// the colour AND the weight, so it survives a greyscale screenshot.
class _FlatDockItem extends StatelessWidget {
  final NeptuneDockItem item;
  final Color color;

  const _FlatDockItem({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = theme.extension<NptShape>()!;
    final motion = theme.extension<NptMotion>()!;
    final text = theme.textTheme;
    final fast = NeptuneAccessibility.duration(context, motion.fast);

    return Semantics(
      button: true,
      selected: item.active,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: shape.rSm,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 28,
                child: Center(
                  child: NeptuneIconSlot(
                    icon: item.icon,
                    iconWidget: item.iconWidget,
                    size: 22,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: fast,
                curve: motion.standard,
                style: (text.labelSmall ?? const TextStyle()).copyWith(
                  color: color,
                  fontWeight:
                      item.active ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final NeptuneDockItem item;

  const _DockItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final motion = theme.extension<NptMotion>()!;
    final text = theme.textTheme;
    final active = item.active;
    // Under reduced motion the selection jumps to its end state - the raised
    // circle is a STATE, so it is shown, not skipped.
    final standard =
        NeptuneAccessibility.duration(context, motion.durationStandard);
    final fast = NeptuneAccessibility.duration(context, motion.fast);

    // The raised-active circle springs up on the brand's motion curve and
    // carries the primary key-light while lifted.
    final circle = AnimatedContainer(
      duration: standard,
      curve: motion.spring,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? scheme.primary : scheme.primary.withValues(alpha: 0),
        shape: BoxShape.circle,
        // The key-light fades in on alpha ONLY: both states must emit the same
        // number of shadows with identical geometry. A null (or shorter) list
        // makes BoxDecoration.lerp fall back to BoxShadow.scale(1 - t), and the
        // brand spring overshoots outside 0..1 — a negative factor there means
        // a negative blurRadius, which asserts in dart:ui the first time the
        // selection actually changes. lerpDouble over equal radii can't.
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: active ? 0.32 : 0),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // A host-supplied mark ([NeptuneDockItem.iconWidget]) takes the glyph's
      // place and inherits the very same active/inactive tint.
      child: Center(
        child: NeptuneIconSlot(
          icon: item.icon,
          iconWidget: item.iconWidget,
          size: 22,
          color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
        ),
      ),
    );

    // A tab: named by its label, flagged selected when active, so TalkBack
    // and VoiceOver say "Home, selected, tab" rather than "Home" twice.
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
      onTap: item.onTap,
      borderRadius: shape.rLg,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              duration: standard,
              curve: motion.spring,
              offset: Offset(0, active ? -0.30 : 0),
              child: circle,
            ),
            AnimatedDefaultTextStyle(
              duration: fast,
              curve: motion.standard,
              style: (text.labelSmall ?? const TextStyle()).copyWith(
                color: active ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: active ? 0 : 2),
                child: Text(item.label),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Which M3 top-app-bar layout [NeptuneAppBar] renders (web `<npt-top-app-bar
/// variant="small|center|medium|large">`). `medium`/`large` stack a larger
/// headline below the action row instead of showing the title inline.
enum NeptuneAppBarVariant { small, center, medium, large }

/// A lightweight themed top bar (web `<npt-app-bar>` / `<npt-top-app-bar>`):
/// an optional leading widget, a display-font title, and trailing actions.
/// [variant] picks the M3 layout — `small` (default) and `center` keep the
/// title inline in the 56dp row; `medium`/`large` reserve the row for
/// leading/actions only and drop a bigger headline below it. A plain themed
/// widget — not a Material [AppBar]. RTL-safe.
class NeptuneAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final NeptuneAppBarVariant variant;

  const NeptuneAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.variant = NeptuneAppBarVariant.small,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final stacked = variant == NeptuneAppBarVariant.medium || variant == NeptuneAppBarVariant.large;

    final rowTitleStyle = text.titleLarge?.copyWith(
      fontFamily: type.display,
      fontWeight: type.displayFontWeight,
      color: scheme.onSurface,
    );

    final row = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            // In medium/large the inline title is replaced by the stacked
            // headline below — an empty Expanded still reserves the same
            // space for leading/actions as the web's `visibility:hidden` row
            // title does, without needing an invisible Text underneath.
            child: stacked
                ? const SizedBox.shrink()
                : Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: variant == NeptuneAppBarVariant.center ? TextAlign.center : TextAlign.start,
                      style: rowTitleStyle,
                    ),
                  ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );

    if (!stacked) {
      // Keep the title reachable to screen readers even though it's the only
      // visible copy — the web version's row title is the sole rendering.
      return Container(color: scheme.surface, child: row);
    }

    final headlineStyle = (variant == NeptuneAppBarVariant.large ? text.displayMedium : text.headlineMedium)
        ?.copyWith(
      fontFamily: type.display,
      fontWeight: type.displayFontWeight,
      letterSpacing: type.displayTracking * (variant == NeptuneAppBarVariant.large ? 45 : 28),
      color: scheme.onSurface,
    );

    return Container(
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row,
          // A Semantics wrapper carries the title to assistive tech once —
          // the row above intentionally has no visible/exposed title copy.
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 24),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: headlineStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
