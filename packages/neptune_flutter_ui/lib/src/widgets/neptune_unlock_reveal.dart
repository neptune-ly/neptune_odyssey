// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The "swipe up to open" unlock ritual for a returning-user lock screen: a
// full-bleed primary canvas with a vertical pill-shaped cutout near the bottom
// revealing the brand behind it (the 135° primary → tertiary gradient overlaid
// with the signature motif). Dragging the pill upward grows the cutout with
// the finger; releasing past the threshold completes the reveal and unlocks.
// Odyssey-original — beyond the web set, Flutter-first. Theme-only, RTL-safe,
// reduced-motion safe.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/identity.dart';
import 'neptune_identity_surfaces.dart';

// Geometry of the ritual (dp). The pill is a stadium — its radius derives from
// its own width, so it fits every brand corner family.
const double _pillWidth = 76;
const double _pillHeight = 150;
const double _chipSize = 60;
const double _chipInset = 10;
const double _hitWidth = 120;

/// Release past this reveal progress completes the unlock.
const double _threshold = 0.6;

/// An upward fling faster than this (px/s) completes regardless of progress.
const double _flingVelocity = 900;

/// The "swipe up to open" unlock ritual for a returning-user lock screen.
/// Odyssey-original — beyond the web set, Flutter-first.
///
/// A full-bleed canvas in the brand `primary` hides the brand's 135°
/// primary → tertiary gradient overlaid with the signature motif
/// ([NeptuneMotifLayer] in `onPrimary`). A vertical pill-shaped cutout near
/// the bottom reveals a sliver of it, with a circular arrow chip at its top.
/// Dragging the pill (or chip) upward grows the cutout, tracking the finger;
/// releasing past ~60% progress completes the reveal on the brand's
/// emphasized curve and fires [onUnlock]; releasing earlier settles back on
/// the brand spring. A tap on the chip also unlocks (and is the accessible
/// activation).
///
/// Under reduced motion ([MediaQueryData.disableAnimations]) there is no
/// growth animation — a tap or completed drag cross-fades straight to the
/// revealed state, then fires [onUnlock].
class NeptuneUnlockReveal extends StatefulWidget {
  /// Fired exactly once, after the reveal has fully completed.
  final VoidCallback onUnlock;

  /// Optional helper line under the pill, in `onPrimary`
  /// (e.g. "Swipe up to open"). Also used as the semantic button label.
  final String? label;

  /// Optional brand mark centered in the upper canvas area.
  final Widget? logo;

  const NeptuneUnlockReveal({
    super.key,
    required this.onUnlock,
    this.label,
    this.logo,
  });

  @override
  State<NeptuneUnlockReveal> createState() => _NeptuneUnlockRevealState();
}

class _NeptuneUnlockRevealState extends State<NeptuneUnlockReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  /// Finger travel (px) that maps drag distance onto reveal progress 0 → 1.
  /// Recomputed each layout so the pill's top edge tracks the finger ~1:1.
  double _dragRange = 320;

  /// Set the moment the unlock is committed; guards re-entry.
  bool _unlockStarted = false;

  /// Reduced-motion only: drives the cross-fade to the revealed state.
  bool _revealed = false;

  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  bool get _reduced => MediaQuery.of(context).disableAnimations;

  NptMotion get _motion => Theme.of(context).extension<NptMotion>()!;

  void _fire() {
    if (_fired || !mounted) return;
    _fired = true;
    widget.onUnlock();
  }

  void _complete() {
    if (_unlockStarted) return;
    _unlockStarted = true;
    if (_reduced) {
      setState(() => _revealed = true); // cross-fade; _fire on fade end
      return;
    }
    _progress
        .animateTo(1,
            duration: _motion.durationStandard, curve: _motion.emphasized)
        .whenComplete(() {
      if (mounted) _fire();
    });
  }

  void _settleBack() {
    if (_unlockStarted) return;
    if (_reduced) {
      _progress.value = 0;
      return;
    }
    _progress.animateTo(0,
        duration: _motion.durationStandard, curve: _motion.spring);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_unlockStarted) return;
    _progress.value =
        (_progress.value - details.delta.dy / _dragRange).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_unlockStarted) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_progress.value >= _threshold || velocity < -_flingVelocity) {
      _complete();
    } else {
      _settleBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final identity = theme.extension<NptIdentity>()!;
    final motion = theme.extension<NptMotion>()!;
    final text = theme.textTheme;
    final reduced = _reduced;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      const pillRadius = _pillWidth / 2;

      // Pill anchored above the bottom inset, leaving room for the label.
      final labelZone = widget.label != null ? 40.0 : 8.0;
      final labelBottom = bottomInset + 26;
      final pillBottom = size.height - labelBottom - labelZone;
      final pillTop = pillBottom - _pillHeight;
      final basePill = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            (size.width - _pillWidth) / 2, pillTop, _pillWidth, _pillHeight),
        const Radius.circular(pillRadius),
      );
      // At progress 1 the cutout swallows the canvas: the rect is inflated by
      // the pill radius so the rounded corners land offscreen.
      final fullPill = RRect.fromRectAndRadius(
        Rect.fromLTRB(-pillRadius, -pillRadius, size.width + pillRadius,
            size.height + pillRadius),
        const Radius.circular(pillRadius),
      );
      // The pill's top edge travels ~1:1 with the finger.
      _dragRange = math.max(pillTop + pillRadius, 160);

      final labelStyle = text.bodyMedium?.copyWith(
        color: scheme.onPrimary,
        fontWeight: FontWeight.w600,
      );

      // The cover: the primary canvas minus the pill cutout, plus everything
      // riding on it (logo, helper label, arrow chip). Built for a given
      // reveal progress so both the live drag and the reduced-motion static
      // frame share one layout.
      Widget cover(double p) {
        final rr = RRect.lerp(basePill, fullPill, p)!;
        // Chip rides the pill's top edge and bows out at the very end.
        final chipFade = ((1 - p) * 4).clamp(0.0, 1.0);
        // Label + logo belong to the covered state; they yield early.
        final trimFade = (1 - p * 2.4).clamp(0.0, 1.0);
        return Stack(fit: StackFit.expand, children: [
          CustomPaint(
            painter: _UnlockCoverPainter(color: scheme.primary, pill: rr),
          ),
          if (widget.logo != null)
            Align(
              alignment: const AlignmentDirectional(0, -0.55),
              child: Opacity(opacity: trimFade, child: widget.logo),
            ),
          if (widget.label != null)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: labelBottom,
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: trimFade,
                  child: Text(
                    widget.label!,
                    textAlign: TextAlign.center,
                    style: labelStyle,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            start: 0,
            end: 0,
            top: rr.top + _chipInset,
            child: Center(
              child: Opacity(
                opacity: chipFade,
                child: Container(
                  width: _chipSize,
                  height: _chipSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary,
                    border: Border.all(
                        color: scheme.onPrimary.withValues(alpha: 0.35)),
                    boxShadow: identity.elevation2(scheme),
                  ),
                  child: Icon(Icons.keyboard_arrow_up_rounded,
                      size: 30, color: scheme.onPrimary),
                ),
              ),
            ),
          ),
        ]);
      }

      final Widget coverLayer;
      if (reduced) {
        coverLayer = AnimatedOpacity(
          opacity: _revealed ? 0 : 1,
          duration: motion.fast,
          curve: motion.standard,
          onEnd: () {
            if (_revealed) _fire();
          },
          child: cover(0),
        );
      } else {
        coverLayer = AnimatedBuilder(
          animation: _progress,
          builder: (context, _) => cover(_progress.value),
        );
      }

      return Stack(fit: StackFit.expand, children: [
        // What lives behind the canvas: the brand gradient + motif.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[scheme.primary, scheme.tertiary],
            ),
          ),
        ),
        // Low-strength on-primary motif wash. The layer multiplies the
        // brand's base ink (per-motif ~0.07–0.13 alpha at strength 1), so
        // ~1.2 lands the wash at roughly 0.15 alpha — quiet but present;
        // a raw 0.15 here would paint at ~1.5% and vanish.
        Positioned.fill(
          child: NeptuneMotifLayer(color: scheme.onPrimary, strength: 1.2),
        ),
        IgnorePointer(child: coverLayer),
        // The interactive zone over the pill + chip + label (≥48dp target).
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: bottomInset + 8),
              child: Semantics(
                button: true,
                label: widget.label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _complete,
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  onVerticalDragCancel: _settleBack,
                  child: SizedBox(
                    width: _hitWidth,
                    height: _pillHeight + labelZone + labelBottom + 8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]);
    });
  }
}

/// Paints the primary canvas with the pill cutout punched out of it.
class _UnlockCoverPainter extends CustomPainter {
  final Color color;
  final RRect pill;

  const _UnlockCoverPainter({required this.color, required this.pill});

  @override
  void paint(Canvas canvas, Size size) {
    final cover = Path()..addRect(Offset.zero & size);
    final cutout = Path()..addRRect(pill);
    canvas.drawPath(
      Path.combine(PathOperation.difference, cover, cutout),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_UnlockCoverPainter old) =>
      old.color != color || old.pill != pill;
}
