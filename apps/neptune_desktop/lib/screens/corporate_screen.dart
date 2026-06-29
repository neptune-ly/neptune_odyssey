// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Corporate / back-office — the maker-checker hub. Pending approvals (filled
// Approve / outlined Reject) sit beside the audit trail on wide screens; below
// them, bulk-payment batches with a workflow status, and the team roster with
// per-member approval permissions. Pure neptune_flutter_ui widgets, themed from
// the active brandprint. Reads/mutates shared state via AppScope.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../data/fmt.dart';
import '../widgets/content_scaffold.dart';

class CorporateScreen extends StatelessWidget {
  const CorporateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    // ---- Pending approvals ---------------------------------------------------
    final Widget approvals = Block(
      title: 'Pending approvals',
      description: 'Maker-checker queue — approve or reject outgoing money.',
      child: app.approvals.isEmpty
          ? const NeptuneEmptyState(
              icon: Icons.inbox_outlined,
              title: 'All clear',
              message: 'No approvals pending.',
            )
          : Column(
              children: [
                for (final a in app.approvals)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 12),
                    child: NeptuneApprovalItem(
                      title: a.title,
                      subtitle: a.subtitle,
                      amount: money(a.amount),
                      onApprove: () {
                        app.resolveApproval(a);
                        showNeptuneToast(context, 'Approved ${a.title}');
                      },
                      onReject: () {
                        app.resolveApproval(a);
                        showNeptuneToast(context, 'Rejected');
                      },
                    ),
                  ),
              ],
            ),
    );

    // ---- Audit trail ---------------------------------------------------------
    final Widget audit = Block(
      title: 'Audit trail',
      description: 'Every action, logged.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in app.audit)
            NeptuneAuditRow(actor: e.actor, action: e.action, time: e.time),
        ],
      ),
    );

    return ContentScaffold(
      title: 'Corporate',
      subtitle: 'Approvals, batches, team and audit trail.',
      children: [
        // ---- approvals + audit -------------------------------------------
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 860) {
              return Column(children: [approvals, audit]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: approvals),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: audit),
              ],
            );
          },
        ),

        // ---- batches ------------------------------------------------------
        Block(
          title: 'Batches',
          description: 'Bulk payments awaiting release.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  const cards = [
                    NeptuneBatchCard(
                      title: 'June payroll',
                      count: '42',
                      total: 'LYD 18,200',
                      status: 'Pending',
                    ),
                    NeptuneBatchCard(
                      title: 'Q2 supplier run',
                      count: '11',
                      total: 'LYD 8,550',
                      status: 'Draft',
                    ),
                  ];
                  if (c.maxWidth < 560) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        cards[0],
                        const SizedBox(height: 16),
                        cards[1],
                      ],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: cards[1]),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const NeptuneWorkflowStatus(label: 'Review', step: 2, total: 3),
            ],
          ),
        ),

        // ---- team & permissions ------------------------------------------
        Block(
          title: 'Team & permissions',
          description: 'Who can approve, and up to how much.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final m in app.team) ...[
                NeptuneUserRow(
                  name: m.name,
                  role: m.role,
                  status: m.status,
                  onTap: () {},
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: NeptunePermissionToggle(
                    label: '${m.name} can approve',
                    description: 'Up to LYD 50k',
                    value: m.canApprove,
                    onChanged: (v) => app.setCanApprove(m, v),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
