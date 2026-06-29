// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

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

/// A large, premium primary call-to-action (web `<npt-cta>`): a pill in the
/// display font with an optional trailing arrow that mirrors under RTL.
class NeptuneCta extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool arrow;
  final bool expand;

  const NeptuneCta({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.arrow = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final style = FilledButton.styleFrom(
      minimumSize: const Size(0, 54),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: shape.rXxl),
      textStyle: (text.titleMedium ?? const TextStyle()).copyWith(
        fontFamily: type.display,
        fontWeight: type.displayFontWeight,
      ),
    );

    final children = <Widget>[
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
      if (arrow) ...[
        const SizedBox(width: 8),
        Icon(isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded, size: 20),
      ],
    ];

    final btn = FilledButton(
      onPressed: onPressed,
      style: style,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
