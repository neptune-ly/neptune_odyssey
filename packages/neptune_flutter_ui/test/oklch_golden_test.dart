// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Single-source chain verification: the pinned ColorSchemes (generated from
// themes.css by tools/codegen.mjs) must match tokens.resolved.json byte-exact
// for EVERY role, and the runtime OKLCH converter must reproduce the same
// bytes for custom seeds. No hardcoded hexes — the resolved tokens are canon.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

int _argbToInt(String s) => int.parse(s.substring(2), radix: 16);

Map<String, dynamic> _loadResolved() {
  final f = File('../neptune_tokens/assets/tokens.resolved.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

List<dynamic> _loadRoles() {
  final f = File('test/fixtures/oklch_roles.json');
  return jsonDecode(f.readAsStringSync()) as List<dynamic>;
}

/// ColorScheme accessors for every resolved `md-sys-color-*` role we pin.
final Map<String, Color Function(ColorScheme)> _roleOf = {
  'md-sys-color-primary': (s) => s.primary,
  'md-sys-color-on-primary': (s) => s.onPrimary,
  'md-sys-color-primary-container': (s) => s.primaryContainer,
  'md-sys-color-on-primary-container': (s) => s.onPrimaryContainer,
  'md-sys-color-secondary': (s) => s.secondary,
  'md-sys-color-on-secondary': (s) => s.onSecondary,
  'md-sys-color-secondary-container': (s) => s.secondaryContainer,
  'md-sys-color-on-secondary-container': (s) => s.onSecondaryContainer,
  'md-sys-color-tertiary': (s) => s.tertiary,
  'md-sys-color-on-tertiary': (s) => s.onTertiary,
  'md-sys-color-tertiary-container': (s) => s.tertiaryContainer,
  'md-sys-color-on-tertiary-container': (s) => s.onTertiaryContainer,
  'md-sys-color-error': (s) => s.error,
  'md-sys-color-on-error': (s) => s.onError,
  'md-sys-color-error-container': (s) => s.errorContainer,
  'md-sys-color-on-error-container': (s) => s.onErrorContainer,
  'md-sys-color-surface': (s) => s.surface,
  'md-sys-color-on-surface': (s) => s.onSurface,
  'md-sys-color-surface-container-lowest': (s) => s.surfaceContainerLowest,
  'md-sys-color-surface-container-low': (s) => s.surfaceContainerLow,
  'md-sys-color-surface-container': (s) => s.surfaceContainer,
  'md-sys-color-surface-container-high': (s) => s.surfaceContainerHigh,
  'md-sys-color-surface-container-highest': (s) => s.surfaceContainerHighest,
  'md-sys-color-on-surface-variant': (s) => s.onSurfaceVariant,
  'md-sys-color-outline': (s) => s.outline,
  'md-sys-color-outline-variant': (s) => s.outlineVariant,
  'md-sys-color-inverse-surface': (s) => s.inverseSurface,
  'md-sys-color-inverse-on-surface': (s) => s.onInverseSurface,
  'md-sys-color-inverse-primary': (s) => s.inversePrimary,
  'md-sys-color-scrim': (s) => s.scrim,
};

void main() {
  group('pinned ColorSchemes match tokens.resolved.json byte-exact', () {
    final resolved = _loadResolved()['themes'] as Map<String, dynamic>;

    for (final brand in kBrands) {
      test('$brand — every role, light + dark', () {
        final schemes = neptuneSchemes[brand]!;
        for (final (mode, scheme) in [('light', schemes.$1), ('dark', schemes.$2)]) {
          final roles = resolved[brand]![mode] as Map<String, dynamic>;
          _roleOf.forEach((role, get) {
            final expected = _argbToInt(roles[role]!['argb'] as String);
            expect(get(scheme).toARGB32(), expected,
                reason: '$brand/$mode/$role');
          });
        }
      });

      test('$brand — success roles, light + dark', () {
        final s = brandSuccess[brand]!;
        for (final (mode, colors) in [('light', s.$1), ('dark', s.$2)]) {
          final roles = resolved[brand]![mode] as Map<String, dynamic>;
          int want(String r) => _argbToInt(roles['md-sys-color-$r']!['argb'] as String);
          expect(colors.success.toARGB32(), want('success'),
              reason: '$brand/$mode/success');
          expect(colors.onSuccess.toARGB32(), want('on-success'));
          expect(colors.successContainer.toARGB32(), want('success-container'));
          expect(colors.onSuccessContainer.toARGB32(),
              want('on-success-container'));
        }
      });
    }
  });

  group('OKLCH converter reproduces resolved.json', () {
    final roles = _loadRoles();
    test('every fixture role converts byte-exact (${292} samples)', () {
      for (final row in roles) {
        final got = oklchToArgb(Oklch(
          (row['L'] as num).toDouble(),
          (row['C'] as num).toDouble(),
          (row['H'] as num).toDouble(),
        ));
        expect(got, _argbToInt(row['argb'] as String),
            reason: '${row['brand']}/${row['mode']}/${row['role']}');
      }
    });
  });
}
