// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The full account-opening onboarding flow — modelled on the real production
// sequence (otp → passport → selfie → confirmation → personal/account info →
// documents → terms → processing → terminal outcome), not a generic wizard.
// Each screen mirrors the real app's actual anatomy: the passport capture
// frame uses four independent corner brackets (not a full box), the selfie
// guide is an oval with colour-coded readiness and an auto countdown, OCR
// review mixes read-only + editable fields, attachments are dashed-until-filled
// tiles, and every terminal state (success/manualReview/rejected/failed)
// shares ONE status screen built on NeptuneStatusMotion — exactly like the
// real app collapses those seven backend states onto one animated screen.
// Theme-only, RTL-safe, reduced-motion aware.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../widgets/neptune_buttons.dart';
import '../widgets/neptune_form_fields.dart';
import '../widgets/neptune_secure_inputs.dart';
import '../widgets/neptune_shell_feedback.dart';
import '../widgets/neptune_status_motion.dart';

// --- shared progress chrome -----------------------------------------------------

/// The "N/8" progress chip used on every wizard screen.
class NeptuneOnboardingProgress extends StatelessWidget {
  final int step;
  final int total;

  const NeptuneOnboardingProgress(
      {super.key, required this.step, this.total = 8});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    return Container(
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(shape.full),
      ),
      child: Text('$step/$total',
          style: text.labelMedium
              ?.copyWith(color: scheme.onSecondaryContainer)),
    );
  }
}

/// Frame shared by every wizard screen: progress chip, back action, content,
/// and the Continue/Cancel action pair pinned to the bottom.
class _WizardScaffold extends StatelessWidget {
  final int step;
  final int total;
  final Widget child;
  final String continueLabel;
  final VoidCallback? onContinue;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final bool continueEnabled;

  const _WizardScaffold({
    required this.step,
    this.total = 8,
    required this.child,
    this.continueLabel = 'Continue',
    this.onContinue,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.continueEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 4),
            child: Row(children: [
              // Plain "go back", never the destructive onCancel action below —
              // conflating the two meant a customer tapping what reads as a
              // normal back arrow could silently cancel their whole in-progress
              // application. onCancel is reserved for the explicit bottom
              // Cancel button.
              IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded)),
              const Spacer(),
              NeptuneOnboardingProgress(step: step, total: total),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
              child: child,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
            child: Column(children: [
              NeptuneCta(
                  label: continueLabel,
                  onPressed: continueEnabled ? onContinue : null),
              if (cancelLabel != null) ...[
                const SizedBox(height: 6),
                NeptuneButton(
                    label: cancelLabel!,
                    variant: NeptuneButtonStyle.text,
                    onPressed: onCancel),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

// --- 1. instruction screens (passport-instructions / selfie-instructions) ------

/// A static "how this works" screen: brand illustration slot, headline, body
/// and bulleted tips, then Continue/Cancel — the exact pattern the real app
/// reuses for both the passport and selfie instruction steps.
class NeptuneInstructionTemplate extends StatelessWidget {
  final int step;
  final int total;
  final IconData illustration;
  final String title;
  final String body;
  final List<String> tips;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;

  const NeptuneInstructionTemplate({
    super.key,
    this.step = 2,
    this.total = 8,
    this.illustration = Icons.badge_outlined,
    required this.title,
    required this.body,
    this.tips = const [],
    this.onContinue,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    return _WizardScaffold(
      step: step,
      total: total,
      onContinue: onContinue,
      onCancel: onCancel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: shape.rXl,
            ),
            child: Icon(illustration, size: 72, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(height: 24),
          Text(title,
              style: text.headlineSmall?.copyWith(
                  fontFamily: type.display,
                  fontWeight: type.displayFontWeight,
                  color: scheme.onSurface)),
          const SizedBox(height: 8),
          Text(body,
              style:
                  text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 20, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(tip,
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurface))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// --- 2. document capture (passport scan) — corner-bracket frame ----------------

/// The readiness state of a document/selfie capture surface.
enum NeptuneCaptureReadiness { aligning, ready, capturing, processing }

/// The passport/ID capture screen: a full-bleed themed surface, a document
/// frame drawn with four INDEPENDENT corner brackets (matching the real
/// capture UI — not a full rectangle), a status pill and a shutter button
/// that fills in and glows once the frame reports ready. [readiness] and
/// [autoCaptureIn] are driven by the caller — this widget is the faithful
/// visual shell; wire it to a real camera/quality pipeline in your app.
class NeptuneDocumentCaptureTemplate extends StatelessWidget {
  final NeptuneCaptureReadiness readiness;
  final String statusLabel;
  final VoidCallback? onCapture;
  final VoidCallback? onClose;
  final bool muted;
  final VoidCallback? onToggleMute;

  const NeptuneDocumentCaptureTemplate({
    super.key,
    this.readiness = NeptuneCaptureReadiness.aligning,
    this.statusLabel = 'Align the document within the frame',
    this.onCapture,
    this.onClose,
    this.muted = false,
    this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final ready = readiness == NeptuneCaptureReadiness.ready;
    final busy = readiness == NeptuneCaptureReadiness.capturing ||
        readiness == NeptuneCaptureReadiness.processing;

    return ColoredBox(
      color: scheme.inverseSurface,
      child: SafeArea(
        child: Stack(children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 60, 28, 140),
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  color: ready
                      ? scheme.inversePrimary
                      : scheme.onInverseSurface.withValues(alpha: 0.7),
                ),
                child: busy
                    ? Center(
                        child: CircularProgressIndicator(
                            color: scheme.onInverseSurface),
                      )
                    : null,
              ),
            ),
          ),
          PositionedDirectional(
            top: 8,
            start: 4,
            end: 4,
            child: Row(children: [
              IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close_rounded,
                      color: scheme.onInverseSurface)),
              const Spacer(),
              IconButton(
                onPressed: onToggleMute,
                icon: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: scheme.onInverseSurface),
              ),
            ]),
          ),
          PositionedDirectional(
            top: 70,
            start: 0,
            end: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (ready ? scheme.inversePrimary : scheme.onInverseSurface)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(shape.full),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: ready ? scheme.inversePrimary : scheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 36,
            start: 0,
            end: 0,
            child: Center(
              child: GestureDetector(
                onTap: onCapture,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.onInverseSurface, width: 3),
                    color: ready
                        ? scheme.inversePrimary
                        : scheme.onInverseSurface.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Draws four independent L-shaped corner brackets around a rounded document
/// frame (the real capture UI's actual overlay — not a solid rectangle).
class _CornerBracketPainter extends CustomPainter {
  final Color color;

  const _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final len = size.shortestSide * 0.14;
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    void corner(Offset a, Offset h, Offset v) {
      canvas.drawLine(a, a + h, paint);
      canvas.drawLine(a, a + v, paint);
    }

    corner(r.topLeft, Offset(len, 0), Offset(0, len));
    corner(r.topRight, Offset(-len, 0), Offset(0, len));
    corner(r.bottomLeft, Offset(len, 0), Offset(0, -len));
    corner(r.bottomRight, Offset(-len, 0), Offset(0, -len));
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) => old.color != color;
}

// --- 3. selfie capture — oval guide + countdown ---------------------------------

/// Selfie-guide colour phase.
enum NeptuneSelfieGuideState { idle, challenge, aligned }

/// The selfie/liveness capture screen: an oval face guide that changes colour
/// with [guideState] (white → blue during a challenge → green when aligned),
/// a pulsing ready-ring, and a large centred countdown numeral — fully
/// automatic, no shutter button, matching the real liveness capture screen.
class NeptuneSelfieCaptureTemplate extends StatelessWidget {
  final NeptuneSelfieGuideState guideState;
  final String statusLabel;
  final int? countdown;
  final VoidCallback? onClose;

  const NeptuneSelfieCaptureTemplate({
    super.key,
    this.guideState = NeptuneSelfieGuideState.idle,
    this.statusLabel = 'Center your face in the oval',
    this.countdown,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final npt = Theme.of(context).extension<NptColors>()!;
    final shape = Theme.of(context).extension<NptShape>()!;
    final guideColor = switch (guideState) {
      NeptuneSelfieGuideState.idle => scheme.onInverseSurface,
      NeptuneSelfieGuideState.challenge => scheme.inversePrimary,
      NeptuneSelfieGuideState.aligned => npt.success,
    };

    return ColoredBox(
      color: scheme.inverseSurface,
      child: SafeArea(
        child: Stack(children: [
          if (onClose != null)
            PositionedDirectional(
              top: 8,
              start: 4,
              child: IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close_rounded,
                      color: scheme.onInverseSurface)),
            ),
          Center(
            child: SizedBox(
              width: 240,
              height: 320,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(
                  size: const Size(240, 320),
                  painter: _OvalGuidePainter(color: guideColor),
                ),
                if (countdown != null)
                  Text(
                    '$countdown',
                    style: TextStyle(
                      color: scheme.onInverseSurface,
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ]),
            ),
          ),
          PositionedDirectional(
            bottom: 56,
            start: 0,
            end: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: guideColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(shape.full),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      color: guideColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _OvalGuidePainter extends CustomPainter {
  final Color color;

  const _OvalGuidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_OvalGuidePainter old) => old.color != color;
}

// --- 4. OCR review (passport confirmation) --------------------------------------

/// One field of a [NeptuneOcrReviewTemplate].
class NeptuneOcrField {
  final String label;
  final String value;

  /// Read-only fields (e.g. the OCR'd name) render as plain text rows;
  /// editable fields (e.g. dates) render as [NeptuneTextField]s.
  final bool editable;

  const NeptuneOcrField(this.label, this.value, {this.editable = false});
}

/// Reviews OCR-extracted document data: read-only fields as plain rows,
/// editable fields (dates) as text inputs, with an optional validation
/// banner — mirrors the real passport-confirmation screen.
class NeptuneOcrReviewTemplate extends StatelessWidget {
  final int step;
  final int total;
  final List<NeptuneOcrField> fields;
  final String? warning;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;
  final void Function(String label, String value)? onFieldChanged;

  const NeptuneOcrReviewTemplate({
    super.key,
    this.step = 3,
    this.total = 8,
    required this.fields,
    this.warning,
    this.onContinue,
    this.onCancel,
    this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return _WizardScaffold(
      step: step,
      total: total,
      onContinue: onContinue,
      onCancel: onCancel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm your details',
              style:
                  text.headlineSmall?.copyWith(color: scheme.onSurface)),
          const SizedBox(height: 6),
          Text('We read this from your document — check it\'s correct.',
              style:
                  text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          if (warning != null) ...[
            const SizedBox(height: 14),
            NeptuneAlert(message: warning!, tone: NeptuneAlertTone.warning),
          ],
          const SizedBox(height: 18),
          for (final f in fields) ...[
            if (f.editable)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 14),
                child: NeptuneTextField(
                  label: f.label,
                  controller: TextEditingController(text: f.value),
                  onChanged: (v) => onFieldChanged?.call(f.label, v),
                ),
              )
            else
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(f.label,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    Text(f.value,
                        style: text.bodyLarge
                            ?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// --- 5. generic form step (essential/personal details, account details) -------

/// One field slot in a [NeptuneOnboardingFormStep] — a text field or a
/// tappable picker (branch/job/municipality — the real app's bottom-sheet
/// selects).
class NeptuneFormFieldSpec {
  final String label;
  final String? value;
  final IconData? icon;

  /// When true, renders as a tappable picker row instead of a text field.
  final bool picker;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const NeptuneFormFieldSpec({
    required this.label,
    this.value,
    this.icon,
    this.picker = false,
    this.onTap,
    this.onChanged,
  });
}

/// A generic labelled-fields wizard step — used for essential details
/// (phone/national ID/passport), personal details (email/municipality/
/// address/mother's name) and account details (branch/job/salary pickers).
class NeptuneOnboardingFormStep extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String? subtitle;
  final List<NeptuneFormFieldSpec> fields;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;

  const NeptuneOnboardingFormStep({
    super.key,
    required this.step,
    this.total = 8,
    required this.title,
    this.subtitle,
    required this.fields,
    this.onContinue,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return _WizardScaffold(
      step: step,
      total: total,
      onContinue: onContinue,
      onCancel: onCancel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineSmall?.copyWith(color: scheme.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                style:
                    text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 18),
          for (final f in fields)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 14),
              child: f.picker
                  ? Material(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: shape.rSm,
                      child: InkWell(
                        onTap: f.onTap,
                        borderRadius: shape.rSm,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(children: [
                            if (f.icon != null) ...[
                              Icon(f.icon, size: 20, color: scheme.onSurfaceVariant),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(f.label,
                                      style: text.labelMedium
                                          ?.copyWith(color: scheme.onSurfaceVariant)),
                                  Text(f.value ?? 'Select',
                                      style: text.bodyLarge
                                          ?.copyWith(color: scheme.onSurface)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                          ]),
                        ),
                      ),
                    )
                  : NeptuneTextField(
                      label: f.label,
                      prefixIcon: f.icon,
                      controller: TextEditingController(text: f.value ?? ''),
                      onChanged: f.onChanged,
                    ),
            ),
        ],
      ),
    );
  }
}

// --- 6. attachments (documents / account details) --------------------------------

/// One attachment's state.
enum NeptuneAttachmentState { empty, attached }

/// One attachment slot: a dashed tile until [state] is attached, then a
/// filled tile with the filename and a checkmark — the real app's
/// AttachmentBox pattern (birth certificate, signature image).
class NeptuneAttachmentTile extends StatelessWidget {
  final String label;
  final NeptuneAttachmentState state;
  final String? fileName;
  final VoidCallback? onTap;

  const NeptuneAttachmentTile({
    super.key,
    required this.label,
    this.state = NeptuneAttachmentState.empty,
    this.fileName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final npt = Theme.of(context).extension<NptColors>()!;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final attached = state == NeptuneAttachmentState.attached;

    final content = Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(
          attached ? Icons.check_circle : Icons.upload_file_outlined,
          color: attached ? npt.success : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: text.bodyLarge?.copyWith(color: scheme.onSurface)),
              if (attached && fileName != null)
                Text(fileName!,
                    style: text.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        if (!attached)
          Text('Upload',
              style: text.labelLarge?.copyWith(color: scheme.primary)),
      ]),
    );

    if (attached) {
      return Material(
        color: npt.successContainer.withValues(alpha: 0.35),
        borderRadius: shape.rMd,
        child: InkWell(onTap: onTap, borderRadius: shape.rMd, child: content),
      );
    }
    return CustomPaint(
      painter: _DashedTilePainter(color: scheme.outline, radius: shape.md),
      child: InkWell(onTap: onTap, borderRadius: shape.rMd, child: content),
    );
  }
}

class _DashedTilePainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedTilePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(1), Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = math.min(d + 6, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedTilePainter old) =>
      old.color != color || old.radius != radius;
}

/// A documents/attachments step: a title, a list of [NeptuneAttachmentTile]s
/// and Continue/Cancel — the documents (step 5) and the attachment portion of
/// account details (step 7) both use this shape.
class NeptuneDocumentsStep extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String? subtitle;
  final List<NeptuneAttachmentTile> attachments;
  final bool continueEnabled;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;

  const NeptuneDocumentsStep({
    super.key,
    required this.step,
    this.total = 8,
    this.title = 'Upload your documents',
    this.subtitle,
    required this.attachments,
    this.continueEnabled = true,
    this.onContinue,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return _WizardScaffold(
      step: step,
      total: total,
      onContinue: onContinue,
      onCancel: onCancel,
      continueEnabled: continueEnabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineSmall?.copyWith(color: scheme.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                style:
                    text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 18),
          for (var i = 0; i < attachments.length; i++) ...[
            attachments[i],
            if (i < attachments.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// --- 7. terms & conditions --------------------------------------------------------

/// Scrollable terms text with Accept/Decline — the real ToS step.
class NeptuneTermsTemplate extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String body;
  final String acceptLabel;
  final String declineLabel;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const NeptuneTermsTemplate({
    super.key,
    this.step = 5,
    this.total = 8,
    this.title = 'Terms & conditions',
    required this.body,
    this.acceptLabel = 'I Accept',
    this.declineLabel = 'I Don\'t Accept',
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return _WizardScaffold(
      step: step,
      total: total,
      continueLabel: acceptLabel,
      onContinue: onAccept,
      cancelLabel: declineLabel,
      onCancel: onDecline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineSmall?.copyWith(color: scheme.onSurface)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsetsDirectional.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: shape.rMd,
            ),
            child: Text(body,
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

// --- 8. shared terminal status screen ---------------------------------------------

/// The seven backend outcomes the real app collapses onto ONE status screen.
enum NeptuneOnboardingOutcome {
  processing,
  success,
  manualReview,
  customerExists,
  submissionFailed,
  rejected,
}

/// A key/value row of the terminal detail card (account number, customer ID…).
class NeptuneDetailRow {
  final String label;
  final String value;

  const NeptuneDetailRow(this.label, this.value);
}

/// The shared processing/terminal-outcome screen — exactly like the real app,
/// every backend state (finalize, processing, success, manualReview,
/// customerExists, submissionFailed, rejected) renders through this ONE
/// widget. Drives [NeptuneStatusMotion] (hourglass while processing/
/// manualReview, drawn checkmark on success, drawn cross on failure/rejected)
/// plus an optional terminal detail card and the Check-now/Refresh + Leave
/// action pair.
class NeptuneOnboardingStatusTemplate extends StatelessWidget {
  final NeptuneOnboardingOutcome outcome;
  final String title;
  final String message;
  final List<NeptuneDetailRow> details;
  final bool checking;
  final String checkLabel;
  final String refreshLabel;
  final String leaveLabel;
  final VoidCallback? onCheck;
  final VoidCallback? onLeave;
  final void Function(String label, String value)? onCopyDetail;

  const NeptuneOnboardingStatusTemplate({
    super.key,
    required this.outcome,
    required this.title,
    required this.message,
    this.details = const [],
    this.checking = false,
    this.checkLabel = 'Check now',
    this.refreshLabel = 'Refresh status',
    this.leaveLabel = 'Leave and return later',
    this.onCheck,
    this.onLeave,
    this.onCopyDetail,
  });

  bool get _terminal => outcome != NeptuneOnboardingOutcome.processing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final motionStatus = switch (outcome) {
      NeptuneOnboardingOutcome.processing ||
      NeptuneOnboardingOutcome.manualReview =>
        NeptuneFlowStatus.loading,
      NeptuneOnboardingOutcome.success => NeptuneFlowStatus.success,
      _ => NeptuneFlowStatus.rejected,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeptuneStatusMotion(status: motionStatus, size: 120),
            const SizedBox(height: 24),
            Text(title,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(color: scheme.onSurface)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: shape.rMd,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < details.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(details[i].label,
                              style: text.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                          InkWell(
                            onTap: () => onCopyDetail
                                ?.call(details[i].label, details[i].value),
                            child: Row(children: [
                              Text(details[i].value,
                                  style: text.bodyLarge?.copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              Icon(Icons.copy_rounded,
                                  size: 16, color: scheme.onSurfaceVariant),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            NeptuneCta(
              label: _terminal ? refreshLabel : checkLabel,
              onPressed: checking ? null : onCheck,
              expand: false,
            ),
            const SizedBox(height: 6),
            NeptuneButton(
                label: leaveLabel,
                variant: NeptuneButtonStyle.text,
                onPressed: onLeave),
          ],
        ),
      ),
    );
  }
}

// --- 9. identity correction (recovery) --------------------------------------------

/// The 422/MATCH_FAILED recovery screen: edit the identifying fields and
/// restart the session, or cancel out.
class NeptuneIdentityCorrectionTemplate extends StatelessWidget {
  final String phone;
  final String nationalId;
  final String passportNumber;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;
  final void Function(String field, String value)? onFieldChanged;

  const NeptuneIdentityCorrectionTemplate({
    super.key,
    this.phone = '',
    this.nationalId = '',
    this.passportNumber = '',
    this.onContinue,
    this.onCancel,
    this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: scheme.error),
            const SizedBox(height: 16),
            Text('Identity verification failed',
                style:
                    text.headlineSmall?.copyWith(color: scheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t match your details. Please review and correct them below.',
              style:
                  text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            NeptuneTextField(
              label: 'Phone',
              controller: TextEditingController(text: phone),
              onChanged: (v) => onFieldChanged?.call('phone', v),
            ),
            const SizedBox(height: 14),
            NeptuneTextField(
              label: 'National ID',
              controller: TextEditingController(text: nationalId),
              onChanged: (v) => onFieldChanged?.call('nationalId', v),
            ),
            const SizedBox(height: 14),
            NeptuneTextField(
              label: 'Passport number',
              controller: TextEditingController(text: passportNumber),
              onChanged: (v) => onFieldChanged?.call('passportNumber', v),
            ),
            const Spacer(),
            NeptuneCta(label: 'Continue', onPressed: onContinue),
            const SizedBox(height: 6),
            NeptuneButton(
                label: 'Cancel',
                variant: NeptuneButtonStyle.text,
                onPressed: onCancel),
          ],
        ),
      ),
    );
  }
}

// --- 10. OTP step (thin wrapper matching the real screen's anatomy) --------------

/// The verification-code step: SMS icon, headline, [NeptuneOtpInput],
/// Continue/Cancel — mirrors the real otp screen (no visible resend timer).
class NeptuneOtpStepTemplate extends StatelessWidget {
  final int step;
  final int total;
  final String phoneMasked;
  final String? errorText;
  final ValueChanged<String>? onCompleted;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;

  /// Headline + supporting line + action labels — overridable so a tenant
  /// can localize (default English matches the original hardcoded copy, for
  /// existing callers that don't pass these).
  final String title;
  final String Function(String phoneMasked)? subtitleBuilder;
  final String continueLabel;
  final String cancelLabel;

  const NeptuneOtpStepTemplate({
    super.key,
    this.step = 1,
    this.total = 8,
    required this.phoneMasked,
    this.errorText,
    this.onCompleted,
    this.onContinue,
    this.onCancel,
    this.title = 'Enter verification code',
    this.subtitleBuilder,
    this.continueLabel = 'Continue',
    this.cancelLabel = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final subtitle =
        (subtitleBuilder ?? (p) => 'We sent a code to $p')(phoneMasked);

    return _WizardScaffold(
      step: step,
      total: total,
      onContinue: onContinue,
      onCancel: onCancel,
      continueLabel: continueLabel,
      cancelLabel: cancelLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sms_outlined, size: 40, color: scheme.primary),
          const SizedBox(height: 16),
          Text(title,
              style:
                  text.headlineSmall?.copyWith(color: scheme.onSurface)),
          const SizedBox(height: 6),
          Text(subtitle,
              style:
                  text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 22),
          NeptuneOtpInput(length: 6, onCompleted: onCompleted),
          if (errorText != null) ...[
            const SizedBox(height: 10),
            Text(errorText!, style: text.bodySmall?.copyWith(color: scheme.error)),
          ],
        ],
      ),
    );
  }
}
