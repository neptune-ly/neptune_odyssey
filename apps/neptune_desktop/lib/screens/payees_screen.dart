// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Payees — saved beneficiaries you can pay in one tap. A searchable left-hand
// list of NeptuneBeneficiaryTile rows beside a detail panel for the selected
// payee, with quick "Send money" / "Remove" actions. Two-column on wide desktop
// windows, stacked when narrow. Theme-only, RTL-safe — follows the Overview
// reference shape: AppScope for data, ContentScaffold + Block for the frame,
// money()/number() for figures, never a hard-coded colour.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

import '../app/app_scope.dart';
import '../app/nav.dart';
import '../data/models.dart';
import '../widgets/content_scaffold.dart';

class PayeesScreen extends StatefulWidget {
  const PayeesScreen({super.key});

  @override
  State<PayeesScreen> createState() => _PayeesScreenState();
}

class _PayeesScreenState extends State<PayeesScreen> {
  String _query = '';
  String? _selectedId;

  List<Beneficiary> _filtered(List<Beneficiary> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((b) =>
            b.name.toLowerCase().contains(q) ||
            b.bank.toLowerCase().contains(q) ||
            b.maskedAccount.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final filtered = _filtered(app.beneficiaries);

    // Resolve the active selection against the filtered set; fall back to the
    // first visible payee so the detail panel is never stranded on a hidden id.
    Beneficiary? selected;
    if (_selectedId != null) {
      for (final b in filtered) {
        if (b.id == _selectedId) {
          selected = b;
          break;
        }
      }
    }
    selected ??= filtered.isNotEmpty ? filtered.first : null;

    return ContentScaffold(
      title: 'Payees',
      subtitle: 'Saved beneficiaries you can pay in one tap.',
      actions: [
        NeptuneButton(
          label: 'Add payee',
          icon: Icons.person_add_alt,
          onPressed: () => showNeptuneToast(context, 'Add payee'),
        ),
      ],
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final list = _PayeeList(
              query: _query,
              filtered: filtered,
              selectedId: selected?.id,
              onSearch: (value) => setState(() => _query = value),
              onSelect: (b) => setState(() => _selectedId = b.id),
            );
            final detail = _PayeeDetail(
              payee: selected,
              onSend: () => app.go(NavDest.transfers),
              onRemove: selected == null
                  ? null
                  : () => showNeptuneToast(context, 'Remove ${selected!.name}'),
            );

            if (c.maxWidth < 820) {
              return Column(children: [list, detail]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: list),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: detail),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// The searchable list column: a rounded search field over the filtered
/// beneficiary tiles, or an empty state when nothing matches the query.
class _PayeeList extends StatelessWidget {
  final String query;
  final List<Beneficiary> filtered;
  final String? selectedId;
  final ValueChanged<String> onSearch;
  final ValueChanged<Beneficiary> onSelect;

  const _PayeeList({
    required this.query,
    required this.filtered,
    required this.selectedId,
    required this.onSearch,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Block(
      title: 'All payees',
      description: '${filtered.length} saved',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeptuneSearchField(
            hint: 'Search payees',
            onChanged: onSearch,
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            NeptuneEmptyState(
              icon: Icons.search_off,
              title: 'No payees found',
              message: query.trim().isEmpty
                  ? 'Add a beneficiary to get started.'
                  : 'No payee matches "${query.trim()}".',
            )
          else
            for (final b in filtered)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: NeptuneBeneficiaryTile(
                  name: b.name,
                  account: b.maskedAccount,
                  selected: b.id == selectedId,
                  onTap: () => onSelect(b),
                ),
              ),
        ],
      ),
    );
  }
}

/// The detail column for the selected payee: name, bank, masked account, and the
/// send / remove actions. Renders a gentle empty state when nothing is selected.
class _PayeeDetail extends StatelessWidget {
  final Beneficiary? payee;
  final VoidCallback onSend;
  final VoidCallback? onRemove;

  const _PayeeDetail({
    required this.payee,
    required this.onSend,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final text = Theme.of(context).textTheme;
    final p = payee;

    if (p == null) {
      return Block(
        title: 'Payee details',
        child: const NeptuneEmptyState(
          icon: Icons.people_outline,
          title: 'No payee selected',
          message: 'Pick a beneficiary from the list to see their details.',
        ),
      );
    }

    String initials(String value) {
      final parts = value
          .trim()
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isEmpty) return '•';
      final first = parts.first.characters.first;
      final last = parts.length > 1 ? parts.last.characters.first : '';
      final out = (first + last).toUpperCase();
      return out.isEmpty ? '•' : out;
    }

    Widget detailRow(String label, String value, {bool numeric = false}) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                  fontFamily: numeric ? type.num : null,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Block(
      title: 'Payee details',
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: shape.rLg,
        ),
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initials(p.name),
                    style: text.titleMedium?.copyWith(
                      fontFamily: type.display,
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.bank,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
            const SizedBox(height: 16),
            detailRow('Account', p.maskedAccount, numeric: true),
            detailRow('Bank', p.bank),
            detailRow('Reference', p.id.toUpperCase()),
            const SizedBox(height: 4),
            NeptuneButton(
              label: 'Send money',
              icon: Icons.north_east,
              expand: true,
              onPressed: onSend,
            ),
            const SizedBox(height: 8),
            NeptuneButton(
              label: 'Remove',
              variant: NeptuneButtonStyle.outlined,
              expand: true,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}