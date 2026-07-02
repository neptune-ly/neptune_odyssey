// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The full account-opening onboarding flow builds under LTR + RTL.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

void main() {
  NeptuneTheme.debugSkipFontLoading = true;

  Widget host(Widget child, TextDirection dir) => MaterialApp(
        theme: NeptuneTheme.light('proteus'),
        home: Directionality(
            textDirection: dir, child: Scaffold(body: child)),
      );

  final screens = <String, Widget>{
    'otp-step': const NeptuneOtpStepTemplate(phoneMasked: '+218 91 •••• 21'),
    'instruction': const NeptuneInstructionTemplate(
      title: 'Scan your passport',
      body: 'Make sure all four corners are visible.',
      tips: ['Good lighting', 'No glare', 'Flat surface'],
    ),
    'document-capture-aligning': const NeptuneDocumentCaptureTemplate(),
    'document-capture-ready': const NeptuneDocumentCaptureTemplate(
        readiness: NeptuneCaptureReadiness.ready, statusLabel: 'Hold steady'),
    'document-capture-processing': const NeptuneDocumentCaptureTemplate(
        readiness: NeptuneCaptureReadiness.processing),
    'selfie-capture-idle': const NeptuneSelfieCaptureTemplate(),
    'selfie-capture-countdown': const NeptuneSelfieCaptureTemplate(
      guideState: NeptuneSelfieGuideState.aligned,
      statusLabel: 'Hold still',
      countdown: 3,
    ),
    'ocr-review': const NeptuneOcrReviewTemplate(
      fields: [
        NeptuneOcrField('Name', 'LINA ATIYA'),
        NeptuneOcrField('Passport No.', 'P1234567'),
        NeptuneOcrField('Date of birth', '1994-03-12', editable: true),
      ],
      warning: 'Please confirm the expiry date.',
    ),
    'form-step': NeptuneOnboardingFormStep(
      step: 6,
      title: 'Personal details',
      fields: [
        const NeptuneFormFieldSpec(label: 'Email', icon: Icons.mail_outline),
        NeptuneFormFieldSpec(
            label: 'Housing municipality',
            value: 'Tripoli Centre',
            picker: true,
            onTap: () {}),
      ],
    ),
    'documents-step': NeptuneDocumentsStep(
      step: 5,
      attachments: [
        NeptuneAttachmentTile(
            label: 'Birth certificate',
            state: NeptuneAttachmentState.attached,
            fileName: 'certificate.pdf'),
        const NeptuneAttachmentTile(label: 'Signature image'),
      ],
    ),
    'terms': const NeptuneTermsTemplate(body: 'By continuing you agree...'),
    'status-processing': const NeptuneOnboardingStatusTemplate(
      outcome: NeptuneOnboardingOutcome.processing,
      title: 'Reviewing your application',
      message: 'This usually takes a minute.',
    ),
    'status-success': const NeptuneOnboardingStatusTemplate(
      outcome: NeptuneOnboardingOutcome.success,
      title: 'Account opened',
      message: 'Welcome aboard.',
      details: [
        NeptuneDetailRow('Account number', '01234567'),
        NeptuneDetailRow('Branch', 'Tripoli Centre'),
      ],
    ),
    'status-rejected': const NeptuneOnboardingStatusTemplate(
      outcome: NeptuneOnboardingOutcome.rejected,
      title: 'Application rejected',
      message: 'Please contact support.',
    ),
    'identity-correction': const NeptuneIdentityCorrectionTemplate(),
  };

  for (final entry in screens.entries) {
    testWidgets('onboarding ${entry.key} builds LTR + RTL', (tester) async {
      for (final dir in TextDirection.values) {
        await tester.pumpWidget(host(entry.value, dir));
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull, reason: '${entry.key} $dir');
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
