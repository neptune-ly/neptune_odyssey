// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The border every Odyssey text field wears. It exists because the theme
// ships a FILLED field, and a filled field with an outline border puts the
// floating label on the fill's top edge. This class is what moves it inside.

import 'package:flutter/material.dart';

/// The container of an Odyssey text field: rounded, filled, and — the whole
/// point of this class — one whose floating label rises **inside** the fill
/// instead of straddling its top edge.
///
/// ## The defect this exists to fix
///
/// The theme's fields are `filled: true` with an [OutlineInputBorder]. That
/// pairing is not a Material configuration; it is two of them mixed.
/// Material's *outlined* field is transparent and notches its label through
/// the stroke; Material's *filled* field is opaque and floats its label down
/// inside the fill. Combining them puts the label on a seam:
///
/// * `input_decorator.dart` positions an outline-border label at
///   `outlinedFloatingY = (-labelHeight * 0.75) / 2 - strokeOffset / 2` — the
///   label's vertical CENTRE lands exactly on the container's top edge, so
///   half of every glyph is drawn above the field and half inside it.
/// * `_InputBorderPainter.paint` fills the ENTIRE rounded rect before it
///   strokes. The `gapStart`/`gapExtent` notch is punched only through the
///   stroke — never through the fill, and the fill painter is not even given
///   the gap. There is nothing a border subclass can do about that: neither
///   `getOuterPath` nor `paintInterior` receives the gap.
///
/// So the floated label is bisected by the fill boundary and needs to be
/// legible against two different colours at once. On a pre-login brand canvas
/// those two colours are the bank's primary and a near-white card, and the one
/// colour available was tuned for the primary — which made the lower half of
/// every floated label white-on-white and invisible. Under the ambient theme
/// it is the quieter version of the same fault: the label sits across the
/// step from `surface` to `surfaceContainerHighest`, most visibly in dark
/// mode where that step is largest.
///
/// ## The fix
///
/// [isOutline] is `false`. That single override is what moves the label:
/// `InputDecorator` then reserves `4 + 0.75 × labelFontSize` of room at the
/// top of the content box and floats the label to `contentPadding.top`, fully
/// inside the fill, on one surface, in one colour — the geometry Material
/// already defines for a filled field. Everything else about the field is
/// unchanged, including the rounded shape, because this still IS an
/// [OutlineInputBorder] for painting purposes.
///
/// Heights are unchanged for a labelled field: outline gave `20 + 24 + 12 =
/// 56`, this gives `8 + 16 + 24 + 8 = 56`. A label-less field settles at
/// `kMinInteractiveDimension` (48), which `_RenderDecoration` clamps to for
/// anything not marked `isDense`.
///
/// [paint] deliberately ignores `gapStart`/`gapExtent`: with the label inside
/// the field there is nothing for a notch to make room for, and a notch drawn
/// where no label sits is just a bite out of the stroke.
///
/// There is no default radius on purpose: the theme always passes
/// `NptShape.rSm`, and a host that reaches for this border passes its own
/// token rather than inheriting a number.
class NeptuneFieldBorder extends OutlineInputBorder {
  const NeptuneFieldBorder({
    super.borderSide,
    required super.borderRadius,
    super.gapPadding,
  });

  /// FALSE ON PURPOSE. See the class docs — flipping this back re-bisects the
  /// floating label on every field the theme draws.
  @override
  bool get isOutline => false;

  @override
  NeptuneFieldBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
  }) {
    return NeptuneFieldBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      gapPadding: gapPadding ?? this.gapPadding,
    );
  }

  @override
  NeptuneFieldBorder scale(double t) {
    return NeptuneFieldBorder(
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
      gapPadding: gapPadding * t,
    );
  }

  // Without these the focus/error transition falls through to ShapeBorder's
  // compound blend, which `_InputBorderTween` then casts to InputBorder and
  // crashes on.
  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is NeptuneFieldBorder) {
      return NeptuneFieldBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
        gapPadding: a.gapPadding,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is NeptuneFieldBorder) {
      return NeptuneFieldBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        gapPadding: b.gapPadding,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none) return;
    final outer = borderRadius.resolve(textDirection).toRRect(rect);
    canvas.drawRRect(
      outer.deflate(borderSide.strokeInset),
      borderSide.toPaint(),
    );
  }
}
