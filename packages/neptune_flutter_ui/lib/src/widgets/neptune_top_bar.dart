// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// How tall a [NeptuneSliverTopBar] stands while the page is at rest - the
/// `size` lever of the flat Material 3 Expressive top bar. All of them collapse
/// to the 64dp small bar as the page scrolls.
enum NeptuneTopBarSize {
  /// 112dp at rest, the title at headline small.
  medium,

  /// 128dp at rest, the title at headline medium.
  large,
}

/// The numbers of the flat top bar, in one place so [NeptuneTopBar] and
/// [NeptuneSliverTopBar] cannot drift apart and the title sits where the
/// customer expects it on every page.
abstract final class NeptuneTopBarMetrics {
  /// The small bar, and what a sliver bar collapses to.
  static const double small = 64;
  static const double medium = 112;
  static const double large = 128;

  /// The inset of the leading mark and the title from the edge.
  static const double gutter = 24;

  /// A leading mark is a 48dp target, [gutter] in from the edge, with 12dp
  /// before the title.
  static const double leadingWidth = gutter + 48 + 12;

  static double expanded(NeptuneTopBarSize size) =>
      size == NeptuneTopBarSize.large ? large : medium;
}

TextStyle? _smallTitle(BuildContext context, Color ink) => Theme.of(context)
    .textTheme
    .titleLarge
    ?.copyWith(color: ink, fontWeight: FontWeight.w600);

TextStyle? _expandedTitle(
        BuildContext context, NeptuneTopBarSize size, Color ink) =>
    (size == NeptuneTopBarSize.large
            ? Theme.of(context).textTheme.headlineMedium
            : Theme.of(context).textTheme.headlineSmall)
        ?.copyWith(color: ink, fontWeight: FontWeight.w700);

List<Widget> _trailing(List<Widget> actions) => [
      for (final a in actions) ...[a, const SizedBox(width: 8)],
      const SizedBox(width: 16),
    ];

Widget? _leading(Widget? leading) => leading == null
    ? const SizedBox.shrink()
    : Padding(
        padding: const EdgeInsetsDirectional.only(
            start: NeptuneTopBarMetrics.gutter),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(width: 48, height: 48, child: leading),
        ),
      );

/// A flat Material 3 Expressive top bar for a screen that is not a scroll view
/// (`Scaffold.appBar`): 64dp, the title at title large in the emphasised
/// weight, an optional leading mark and trailing actions, all mirrored under
/// RTL. For a scrolling page use [NeptuneSliverTopBar], which is the same bar
/// with a large title that collapses into this one.
///
/// FLAT MEANS FLAT. The page's surface (or [background]), no gradient, no
/// shadow, no surface tint, no elevation on scroll. Colours come from the theme;
/// a bar on a coloured band passes the band's colour and its on-colour.
///
/// Unlike [NeptuneAppBar] - a lightweight themed row, not a Material [AppBar] -
/// this is a real [AppBar]: it plugs into `Scaffold.appBar` and
/// `CustomScrollView`, publishes the system overlay style and drives the
/// scroll-under state. The brand never appears in it; a bank changes the theme,
/// not this widget.
class NeptuneTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// The screen's title.
  final String title;

  /// A leading mark - the back button, usually - hosted in a 48dp target. The
  /// host supplies it: the library knows nothing of a bank's icon set.
  final Widget? leading;

  /// Trailing buttons, each a 48dp target.
  final List<Widget> actions;

  /// The bar's fill. Null is the page's `surface`.
  final Color? background;

  /// The ink of the title, the leading mark and the actions. Null is the page's
  /// `onSurface`.
  final Color? foreground;

  /// The status-bar icon style. Null lets the framework derive it from
  /// [background]; a bar on a dark band over a light theme passes it.
  final SystemUiOverlayStyle? systemOverlayStyle;

  const NeptuneTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.background,
    this.foreground,
    this.systemOverlayStyle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(NeptuneTopBarMetrics.small);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = foreground ?? scheme.onSurface;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: NeptuneTopBarMetrics.small,
      backgroundColor: background ?? scheme.surface,
      foregroundColor: ink,
      surfaceTintColor: scheme.surface.withValues(alpha: 0),
      scrolledUnderElevation: 0,
      systemOverlayStyle: systemOverlayStyle,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: leading == null
          ? NeptuneTopBarMetrics.gutter
          : NeptuneTopBarMetrics.leadingWidth,
      leading: _leading(leading),
      title: Semantics(
        header: true,
        child: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _smallTitle(context, ink)),
      ),
      actions: _trailing(actions),
    );
  }
}

/// The large (or medium), collapsing form of [NeptuneTopBar] for a scrolling
/// page: the title stands at headline size at the foot of the bar while the page
/// is at rest and collapses into the small title as it scrolls. The two titles
/// cross-fade on the scroll offset, so the motion is the finger's own and there
/// is nothing to switch off under reduced motion.
///
/// Pinned. Put it first in a `CustomScrollView`.
class NeptuneSliverTopBar extends StatelessWidget {
  /// The screen's title.
  final String title;

  /// The `size` lever: how tall the bar stands at rest.
  final NeptuneTopBarSize size;

  /// A leading mark hosted in a 48dp target - see [NeptuneTopBar.leading].
  final Widget? leading;

  /// Trailing buttons, each a 48dp target.
  final List<Widget> actions;

  /// The bar's fill once content scrolls under it. Null is the page's
  /// `surface`.
  final Color? background;

  /// The ink of the titles, the leading mark and the actions. Null is the
  /// page's `onSurface`.
  final Color? foreground;

  /// True when the bar sits on a coloured band that runs behind it: the bar is
  /// clear at rest and takes [background] only once content scrolls under it,
  /// so the band shows through until then.
  final bool clearAtRest;

  /// See [NeptuneTopBar.systemOverlayStyle].
  final SystemUiOverlayStyle? systemOverlayStyle;

  const NeptuneSliverTopBar({
    super.key,
    required this.title,
    this.size = NeptuneTopBarSize.large,
    this.leading,
    this.actions = const [],
    this.background,
    this.foreground,
    this.clearAtRest = false,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = foreground ?? scheme.onSurface;
    final ground = background ?? scheme.surface;
    final top = MediaQuery.paddingOf(context).top;
    final start = leading == null
        ? NeptuneTopBarMetrics.gutter
        : NeptuneTopBarMetrics.leadingWidth;
    final expanded = NeptuneTopBarMetrics.expanded(size);

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: clearAtRest
          ? WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.scrolledUnder)
                  ? ground
                  : ground.withValues(alpha: 0))
          : ground,
      foregroundColor: ink,
      surfaceTintColor: scheme.surface.withValues(alpha: 0),
      scrolledUnderElevation: 0,
      systemOverlayStyle: systemOverlayStyle,
      toolbarHeight: NeptuneTopBarMetrics.small,
      expandedHeight: expanded,
      leadingWidth: start,
      leading: _leading(leading),
      titleSpacing: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, box) {
          final min = NeptuneTopBarMetrics.small + top;
          final max = expanded + top;
          final t = ((box.maxHeight - min) / (max - min)).clamp(0.0, 1.0);
          return Stack(
            children: [
              PositionedDirectional(
                start: NeptuneTopBarMetrics.gutter,
                end: NeptuneTopBarMetrics.gutter,
                bottom: 16,
                child: Opacity(
                  opacity: t,
                  child: Semantics(
                    header: true,
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _expandedTitle(context, size, ink)),
                  ),
                ),
              ),
              PositionedDirectional(
                start: start,
                end: NeptuneTopBarMetrics.gutter + actions.length * 56,
                top: top,
                height: NeptuneTopBarMetrics.small,
                child: ExcludeSemantics(
                  child: Opacity(
                    opacity: 1 - t,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _smallTitle(context, ink)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: _trailing(actions),
    );
  }
}
