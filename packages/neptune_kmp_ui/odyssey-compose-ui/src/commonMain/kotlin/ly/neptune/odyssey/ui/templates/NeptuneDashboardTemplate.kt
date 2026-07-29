// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed retail-home screen template. Ported 1:1 from
// neptune_templates.dart (NeptuneDashboardTemplate) / site/templates.html
// §dashboard. Composition only — the stat pair renders through the public
// [NeptuneStatCard].

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneAvatar
import ly.neptune.odyssey.ui.components.NeptuneBadge
import ly.neptune.odyssey.ui.components.NeptuneBalanceCard
import ly.neptune.odyssey.ui.components.NeptuneQuickActionItem
import ly.neptune.odyssey.ui.components.NeptuneQuickActions
import ly.neptune.odyssey.ui.components.NeptuneSection
import ly.neptune.odyssey.ui.components.NeptuneSparkline
import ly.neptune.odyssey.ui.components.NeptuneStatCard
import ly.neptune.odyssey.ui.components.NeptuneTransactionRow

/** A transaction entry for the dashboard/cards/wallet templates.
 * Flutter counterpart: `NeptuneTxData` (neptune_templates.dart). */
public class NeptuneTxData(
    public val title: String,
    public val subtitle: String,
    public val amount: String,
    public val credit: Boolean = false,
)

/** The stat tile fed to [NeptuneDashboardTemplate] — label, big value, unit
 * and signed delta. Flutter counterpart: the `statPair` record. */
public class NeptuneStatData(
    public val label: String,
    public val value: String,
    public val unit: String,
    public val delta: String,
)

/**
 * The retail home: greeting bar, hero balance, quick actions, stat pair and
 * the latest activity — the exact §dashboard composition. The 110dp bottom
 * inset leaves room for a dock hosted by the surrounding shell; mark the
 * template with `Modifier.nptGlassBackground(scope)` (or host it inside
 * `NeptuneAppShell`) so a glass dock finds its backdrop.
 *
 * Web counterpart: site/templates.html §dashboard · Flutter:
 * `NeptuneDashboardTemplate`.
 */
@Composable
public fun NeptuneDashboardTemplate(
    modifier: Modifier = Modifier,
    greeting: String = "Good morning",
    customer: String = "Lina Atiya",
    balanceLabel: String = "Available balance",
    balance: String = "LYD 12,480.50",
    balanceCaption: String? = null,
    actions: List<NeptuneQuickActionItem> = emptyList(),
    statPair: NeptuneStatData? = null,
    sparkline: List<Float> = listOf(3f, 4f, 4f, 6f, 5f, 7f, 8f),
    activityTitle: String = "Latest activity",
    transactions: List<NeptuneTxData> = emptyList(),
    notificationCount: Int = 2,
    avatarInitials: String = "L",
    leading: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    Column(
        modifier
            .fillMaxSize()
            .windowInsetsPadding(
                WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal),
            ),
    ) {
        Row(
            modifier = Modifier.padding(start = 16.dp, top = 10.dp, end = 16.dp, bottom = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (leading != null) leading() else NeptuneAvatar(initials = avatarInitials)
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(greeting, style = typography.labelMedium.copy(color = scheme.onSurfaceVariant))
                Text(
                    customer,
                    style = typography.titleLarge.copy(
                        color = scheme.onSurface,
                        fontWeight = FontWeight.W700,
                    ),
                )
            }
            NeptuneBadge(count = notificationCount) {
                Icon(NptTemplateGlyphs.bell, contentDescription = null, tint = scheme.onSurfaceVariant)
            }
        }
        LazyColumn(
            modifier = Modifier.weight(1f),
            contentPadding = PaddingValues(start = 16.dp, top = 8.dp, end = 16.dp, bottom = 110.dp),
        ) {
            item {
                NeptuneBalanceCard(
                    label = balanceLabel,
                    amount = balance,
                    caption = balanceCaption,
                    hero = true,
                )
                Spacer(Modifier.height(14.dp))
                if (actions.isNotEmpty()) NeptuneQuickActions(actions = actions)
            }
            if (statPair != null) {
                item {
                    Spacer(Modifier.height(14.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        NeptuneStatCard(
                            label = statPair.label,
                            value = statPair.value,
                            unit = statPair.unit,
                            delta = statPair.delta,
                            modifier = Modifier.weight(1f),
                        )
                        Spacer(Modifier.width(12.dp))
                        Box(Modifier.weight(1f)) {
                            NeptuneSparkline(points = sparkline, height = 92.dp)
                        }
                    }
                }
            }
            item {
                Spacer(Modifier.height(8.dp))
                NeptuneSection(title = activityTitle) {
                    Column {
                        for (t in transactions) {
                            NeptuneTransactionRow(
                                title = t.title,
                                subtitle = t.subtitle,
                                amount = t.amount,
                                isCredit = t.credit,
                            )
                        }
                    }
                }
            }
        }
    }
}
