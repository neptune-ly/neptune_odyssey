// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

/// The brand primary action. Wraps [FilledButton] so it inherits the brand's
/// pill shape and 48dp-min target from the theme. Optional leading icon and
/// busy state. Theme-only, RTL-safe.
class NeptunePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;
  final bool expand;

  const NeptunePrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.busy = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = busy
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
            ),
          )
        : Text(label);
    final onTap = busy ? null : onPressed;

    final button = icon != null && !busy
        ? FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 20),
            label: Text(label),
          )
        : FilledButton(onPressed: onTap, child: child);

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
