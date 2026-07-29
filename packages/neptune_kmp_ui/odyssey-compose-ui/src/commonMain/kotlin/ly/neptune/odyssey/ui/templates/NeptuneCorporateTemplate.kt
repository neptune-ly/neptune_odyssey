// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed corporate-approvals workspace template. Ported 1:1 from
// neptune_templates.dart (NeptuneCorporateTemplate) / site/templates.html
// §corporate — composition only. NeptuneAppShell provides the glass scope
// and marks the content region, so glass surfaces composed inside find
// their backdrop automatically.

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneAppShell
import ly.neptune.odyssey.ui.components.NeptuneApprovalItem
import ly.neptune.odyssey.ui.components.NeptuneAuditRow
import ly.neptune.odyssey.ui.components.NeptuneBatchCard
import ly.neptune.odyssey.ui.components.NeptunePageHeader
import ly.neptune.odyssey.ui.components.NeptuneSection
import ly.neptune.odyssey.ui.components.NeptuneSideNav
import ly.neptune.odyssey.ui.components.NeptuneSideNavItem
import ly.neptune.odyssey.ui.glyphs.NptCardControlGlyphs
import ly.neptune.odyssey.ui.glyphs.NptStatusGlyphs

/** A pending approval for the corporate template.
 * Flutter counterpart: `NeptuneApprovalData` (neptune_templates.dart). */
public class NeptuneApprovalData(
    public val title: String,
    public val subtitle: String,
    public val amount: String,
)

/** A batch summary for the corporate template — title, count, total, status.
 * Flutter counterpart: the `batch` record. */
public class NeptuneBatchData(
    public val title: String,
    public val count: String,
    public val total: String,
    public val status: String,
)

/** An audit-trail entry for the corporate template — actor, action, time.
 * Flutter counterpart: the `audit` record entries. */
public class NeptuneAuditData(
    public val actor: String,
    public val action: String,
    public val time: String,
)

/** One side-nav destination for the corporate template.
 * Flutter counterpart: the `(IconData, String)` nav entries. */
public class NeptuneCorporateNavItem(
    public val label: String,
    public val icon: (@Composable () -> Unit)? = null,
)

/** The Dart template's default nav — Approvals / Batches / Audit. */
private val defaultNavItems: List<NeptuneCorporateNavItem> = listOf(
    NeptuneCorporateNavItem(
        label = "Approvals",
        icon = { Icon(NptStatusGlyphs.successCheck, contentDescription = null) },
    ),
    NeptuneCorporateNavItem(
        label = "Batches",
        icon = { Icon(NptTemplateGlyphs.users, contentDescription = null) },
    ),
    NeptuneCorporateNavItem(
        label = "Audit",
        icon = { Icon(NptCardControlGlyphs.receipt, contentDescription = null) },
    ),
)

/**
 * The corporate approvals workspace: side nav, page header and the approval
 * queue with batches + audit trail. Collapses below [NeptuneAppShell]'s
 * breakpoint like the web. [navTitle] is carried for API parity with the
 * Flutter template (unused there too).
 *
 * Web counterpart: site/templates.html §corporate · Flutter:
 * `NeptuneCorporateTemplate`.
 */
@Composable
public fun NeptuneCorporateTemplate(
    modifier: Modifier = Modifier,
    navTitle: String = "Corporate",
    navIndex: Int = 0,
    navItems: List<NeptuneCorporateNavItem> = defaultNavItems,
    onNav: ((Int) -> Unit)? = null,
    title: String = "Approvals",
    subtitle: String? = null,
    approvals: List<NeptuneApprovalData> = emptyList(),
    onDecide: ((index: Int, approved: Boolean) -> Unit)? = null,
    batch: NeptuneBatchData? = null,
    audit: List<NeptuneAuditData> = emptyList(),
    auditTitle: String = "Audit trail",
) {
    NeptuneAppShell(
        modifier = modifier,
        nav = {
            NeptuneSideNav {
                navItems.forEachIndexed { i, item ->
                    NeptuneSideNavItem(
                        label = item.label,
                        icon = item.icon,
                        active = i == navIndex,
                        onTap = if (onNav == null) null else fun() { onNav(i) },
                    )
                }
            }
        },
    ) {
        LazyColumn {
            item { NeptunePageHeader(title = title, subtitle = subtitle) }
            approvals.forEachIndexed { i, a ->
                item {
                    NeptuneApprovalItem(
                        title = a.title,
                        subtitle = a.subtitle,
                        amount = a.amount,
                        onApprove = if (onDecide == null) null else fun() { onDecide(i, true) },
                        onReject = if (onDecide == null) null else fun() { onDecide(i, false) },
                    )
                    Spacer(Modifier.height(10.dp))
                }
            }
            if (batch != null) {
                item {
                    Spacer(Modifier.height(4.dp))
                    NeptuneBatchCard(
                        title = batch.title,
                        count = batch.count,
                        total = batch.total,
                        status = batch.status,
                    )
                }
            }
            if (audit.isNotEmpty()) {
                item {
                    Spacer(Modifier.height(12.dp))
                    NeptuneSection(title = auditTitle) {
                        Column {
                            for (a in audit) {
                                NeptuneAuditRow(actor = a.actor, action = a.action, time = a.time)
                            }
                        }
                    }
                }
            }
        }
    }
}
