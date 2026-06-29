// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey — corporate & back-office widgets (web `corporate.ts` parity):
// approval queue items, bulk-payment batch cards, audit-log rows, user-admin
// rows, permission toggles and compact workflow status. Theme-only (colour,
// shape, type read from the active theme), RTL-safe.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// A maker-checker queue item (web `<npt-approval-item>`): a title/subtitle, an
/// amount in tabular figures, and Approve (filled) + Reject (outlined) actions.
class NeptuneApprovalItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? amount;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const NeptuneApprovalItem({
    super.key,
    required this.title,
    this.subtitle,
    this.amount,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.titleMedium)
        .copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.bodyLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: shape.rMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsetsDirectional.all(16),
      child: LayoutBuilder(
        builder: (context, c) {
          // On narrow widths (mobile) the Approve/Reject buttons can't fit
          // beside the title — stack them full-width below it.
          final narrow = c.maxWidth < 440;
          final approve = FilledButton(
            onPressed: onApprove,
            child: const Text('Approve'),
          );
          final reject = OutlinedButton(
            onPressed: onReject,
            child: const Text('Reject'),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: info),
                    if (amount != null) ...[
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          amount!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: money,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: reject),
                    const SizedBox(width: 8),
                    Expanded(child: approve),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: info),
              if (amount != null) ...[
                const SizedBox(width: 16),
                Text(amount!, style: money),
              ],
              const SizedBox(width: 16),
              reject,
              const SizedBox(width: 8),
              approve,
            ],
          );
        },
      ),
    );
  }
}

/// A bulk-payment batch summary (web `<npt-batch-card>`): a title, a count of
/// items, a total amount in tabular figures, and a status chip.
class NeptuneBatchCard extends StatelessWidget {
  final String title;
  final String count;
  final String total;
  final String? status;

  const NeptuneBatchCard({
    super.key,
    required this.title,
    required this.count,
    required this.total,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.headlineSmall)
        .copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w700,
      letterSpacing: type.displayTracking * 28,
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: shape.rLg,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: shape.rSm,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count items',
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null) ...[
                const SizedBox(width: 12),
                _StatusChip(label: status!),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(total, style: money),
        ],
      ),
    );
  }
}

/// A small pill chip used for batch status. Reads colour + shape from the theme.
class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(shape.full),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: text.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A compact audit-log line (web `<npt-audit-row>`): a leading status dot (or
/// optional icon), the actor + action text, and a trailing timestamp.
class NeptuneAuditRow extends StatelessWidget {
  final String actor;
  final String action;
  final String time;
  final IconData? icon;

  const NeptuneAuditRow({
    super.key,
    required this.actor,
    required this.action,
    required this.time,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final timeStyle = NeptuneTheme.moneyStyle(context, base: text.labelSmall)
        .copyWith(color: scheme.onSurfaceVariant);

    final Widget leading = icon != null
        ? Icon(icon, size: 16, color: scheme.primary)
        : Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(shape.full),
            ),
          );

    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: actor,
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: action,
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(time, style: timeStyle),
        ],
      ),
    );
  }
}

/// A user-admin list row (web `<npt-user-row>`): an avatar, name + role, a
/// status chip and an optional tap target.
class NeptuneUserRow extends StatelessWidget {
  final String name;
  final String? role;
  final String? status;
  final Widget? avatar;
  final VoidCallback? onTap;

  const NeptuneUserRow({
    super.key,
    required this.name,
    this.role,
    this.status,
    this.avatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;

    final String initials = _initials(name);
    final Widget avatarWidget = ClipRRect(
      borderRadius: BorderRadius.circular(shape.full),
      child: Container(
        width: 40,
        height: 40,
        color: scheme.primaryContainer,
        alignment: Alignment.center,
        child: avatar ??
            Text(
              initials,
              style: text.labelLarge?.copyWith(
                fontFamily: type.display,
                fontWeight: FontWeight.w600,
                color: scheme.onPrimaryContainer,
              ),
            ),
      ),
    );

    final Widget row = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          avatarWidget,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (role != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    role!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status != null) ...[
            const SizedBox(width: 16),
            _UserStatusChip(label: status!),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: scheme.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.rSm,
        child: row,
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }
}

/// The user-row status chip: a secondary-container pill. Theme-only.
class _UserStatusChip extends StatelessWidget {
  final String label;

  const _UserStatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(shape.full),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: text.labelSmall?.copyWith(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A permission row (web `<npt-permission-toggle>`): a label, optional
/// description and a trailing [Switch]. Tap the whole row to toggle.
class NeptunePermissionToggle extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const NeptunePermissionToggle({
    super.key,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final enabled = onChanged != null;

    return Material(
      color: scheme.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: shape.rSm,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: text.bodyLarge?.copyWith(color: scheme.onSurface),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact multi-step status (web `<npt-workflow-status>`): a 'step k of n'
/// label with a mini linear progress indicator. [step] is 1-based.
class NeptuneWorkflowStatus extends StatelessWidget {
  final String label;
  final int step;
  final int total;

  const NeptuneWorkflowStatus({
    super.key,
    required this.label,
    required this.step,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final npt = Theme.of(context).extension<NptColors>()!;
    final text = Theme.of(context).textTheme;

    final safeTotal = total <= 0 ? 1 : total;
    final clampedStep = step < 0 ? 0 : (step > safeTotal ? safeTotal : step);
    final progress = clampedStep / safeTotal;
    final complete = clampedStep >= safeTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelLarge?.copyWith(color: scheme.onSurface),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Step $clampedStep of $safeTotal',
              style: NeptuneTheme.moneyStyle(context, base: text.labelSmall)
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(shape.full),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              complete ? npt.success : scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
