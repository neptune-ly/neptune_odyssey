// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/identity.dart';

/// Visual style for [NeptuneButton], mirroring the web `<npt-button>` variants.
enum NeptuneButtonStyle { filled, tonal, outlined, text }

/// The brand action button. Maps onto the Material button family so it inherits
/// the active theme's pill shape and ≥48dp target — theme-only, RTL-safe.
class NeptuneButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final NeptuneButtonStyle variant;
  final bool expand;
  final bool busy;

  const NeptuneButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = NeptuneButtonStyle.filled,
    this.expand = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onTap = busy ? null : onPressed;
    final hasIcon = icon != null && !busy;

    Widget spinner(Color c) => SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(c),
          ),
        );

    final Widget button;
    switch (variant) {
      case NeptuneButtonStyle.filled:
        button = hasIcon
            ? FilledButton.icon(onPressed: onTap, icon: Icon(icon, size: 20), label: Text(label))
            : FilledButton(onPressed: onTap, child: busy ? spinner(scheme.onPrimary) : Text(label));
      case NeptuneButtonStyle.tonal:
        button = hasIcon
            ? FilledButton.tonalIcon(onPressed: onTap, icon: Icon(icon, size: 20), label: Text(label))
            : FilledButton.tonal(
                onPressed: onTap,
                child: busy ? spinner(scheme.onSecondaryContainer) : Text(label),
              );
      case NeptuneButtonStyle.outlined:
        button = hasIcon
            ? OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 20), label: Text(label))
            : OutlinedButton(onPressed: onTap, child: busy ? spinner(scheme.primary) : Text(label));
      case NeptuneButtonStyle.text:
        button = hasIcon
            ? TextButton.icon(onPressed: onTap, icon: Icon(icon, size: 20), label: Text(label))
            : TextButton(onPressed: onTap, child: busy ? spinner(scheme.primary) : Text(label));
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// The premium animated call-to-action (web `<npt-cta>`): a display-font pill
/// riding the primary key-light, with a slow SPECULAR SHEEN sweeping across
/// (4.8s cycle, on-colour tinted), a gently NUDGING arrow (±4dp, 2.4s) and a
/// 0.98 press-scale on the brand's emphasized curve. [tonal] renders the
/// secondary tone (no glow). All motion pauses under reduced-motion. RTL-safe
/// (the arrow mirrors and the sheen sweeps the reading direction).
class NeptuneCta extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool arrow;
  final bool expand;

  /// Secondary tone: secondary-container fill, no glow (web `variant="tonal"`).
  final bool tonal;

  const NeptuneCta({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.arrow = false,
    this.expand = true,
    this.tonal = false,
  });

  @override
  State<NeptuneCta> createState() => _NeptuneCtaState();
}

class _NeptuneCtaState extends State<NeptuneCta> with TickerProviderStateMixin {
  late final AnimationController _sheen;
  late final AnimationController _nudge;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _sheen = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4800));
    _nudge = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      _sheen.stop();
      _nudge.stop();
    } else {
      if (!_sheen.isAnimating) _sheen.repeat();
      if (!_nudge.isAnimating) _nudge.repeat();
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    _nudge.dispose();
    super.dispose();
  }

  /// Web keyframes: hold at -130% until 62%, sweep to +130% by 82%, hold.
  double _sheenX(double t) {
    if (t < 0.62) return -1.3;
    if (t > 0.82) return 1.3;
    return -1.3 + 2.6 * Curves.easeInOut.transform((t - 0.62) / 0.20);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final type = theme.extension<NptType>()!;
    final motion = theme.extension<NptMotion>()!;
    final identity = theme.extension<NptIdentity>()!;
    final text = theme.textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reduced = MediaQuery.of(context).disableAnimations;

    final bg = widget.tonal ? scheme.secondaryContainer : scheme.primary;
    final fg =
        widget.tonal ? scheme.onSecondaryContainer : scheme.onPrimary;
    final radius = shape.rXxl;
    final enabled = widget.onPressed != null;

    final labelStyle = (text.titleMedium ?? const TextStyle()).copyWith(
      fontFamily: type.display,
      fontWeight: FontWeight.w700,
      letterSpacing: type.displayTracking * 16,
      color: fg,
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(widget.label,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: labelStyle),
        ),
        if (widget.arrow) ...[
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _nudge,
            builder: (context, child) {
              // 0 → 4dp → 0 along the reading direction (web `nudge`).
              final dx = reduced
                  ? 0.0
                  : 4 * math.sin(math.pi * _nudge.value) * (isRtl ? -1 : 1);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: Icon(
                isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                size: 20,
                color: fg),
          ),
        ],
      ],
    );

    final btn = AnimatedScale(
      // Web `.cta:active { transform: scale(.98) }` on the emphasized curve.
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 220),
      curve: motion.emphasized,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          // The primary key-light glow (web `--npt-glow-primary`).
          boxShadow: widget.tonal || !enabled
              ? null
              : [
                  ...identity.elevation3(scheme),
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.24),
                    blurRadius: 22,
                    spreadRadius: -8,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Material(
          color: enabled ? bg : bg.withValues(alpha: 0.5),
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Specular sheen — an on-colour tinted highlight sweeping
                  // across on the 4.8s cycle (web `.sheen`).
                  if (!reduced)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _sheen,
                          builder: (context, _) => FractionalTranslation(
                            translation: Offset(
                                _sheenX(_sheen.value) * (isRtl ? -1 : 1), 0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: AlignmentDirectional.centerStart,
                                  end: AlignmentDirectional.centerEnd,
                                  transform:
                                      const GradientRotation(0.349), // ~110°−90°
                                  colors: [
                                    fg.withValues(alpha: 0),
                                    fg.withValues(alpha: 0.38),
                                    fg.withValues(alpha: 0),
                                  ],
                                  stops: const [0.32, 0.5, 0.68],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 24, vertical: 8),
                    child: row,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return widget.expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
