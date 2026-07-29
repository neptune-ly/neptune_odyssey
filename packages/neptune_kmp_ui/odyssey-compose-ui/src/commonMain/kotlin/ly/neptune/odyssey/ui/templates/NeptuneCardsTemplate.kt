// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed card-management screen template. Ported 1:1 from
// neptune_templates.dart (NeptuneCardsTemplate) / site/templates.html §cards
// — composition only. The Flutter PageView (viewportFraction 0.92, height
// 210, 6dp page gutters) maps to a HorizontalPager with 4%-width content
// padding, which yields the same 92% page viewport.

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.Column
import ly.neptune.odyssey.ui.components.NeptuneAddCard
import ly.neptune.odyssey.ui.components.NeptuneCardArt
import ly.neptune.odyssey.ui.components.NeptuneCardControls
import ly.neptune.odyssey.ui.components.NeptuneLimitMeter
import ly.neptune.odyssey.ui.components.NeptuneSection
import ly.neptune.odyssey.ui.components.NeptuneTierBadge
import ly.neptune.odyssey.ui.components.NeptuneTransactionRow

/** One card in the cards-template carousel.
 * Flutter counterpart: `NeptuneCardData` (neptune_templates.dart). */
public class NeptuneCardData(
    public val holder: String,
    public val last4: String,
    public val expiry: String,
    public val scheme: String,
    public val virtual: Boolean = false,
)

/**
 * The card-management screen: title + tier, swipeable card carousel, the
 * freeze/limits/details/PIN controls, spend meter and per-card activity.
 * The 110dp bottom inset leaves room for a dock hosted by the surrounding
 * shell (see [NeptuneDashboardTemplate] for the glass wiring note).
 *
 * Web counterpart: site/templates.html §cards · Flutter:
 * `NeptuneCardsTemplate`.
 */
@Composable
public fun NeptuneCardsTemplate(
    modifier: Modifier = Modifier,
    title: String = "My cards",
    tier: String = "Gold",
    cards: List<NeptuneCardData> = emptyList(),
    frozen: Boolean = false,
    onControl: ((String) -> Unit)? = null,
    limitValue: Float = 0.62f,
    limitLabel: String = "Monthly spend",
    limitAmount: String = "620 / 1,000 LYD",
    activityTitle: String = "This card",
    transactions: List<NeptuneTxData> = emptyList(),
    addLabel: String = "Add card",
    onAddCard: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .windowInsetsPadding(
                WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal),
            ),
        contentPadding = PaddingValues(start = 16.dp, top = 12.dp, end = 16.dp, bottom = 110.dp),
    ) {
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                // headlineSmall rides the brand display face (Typography.kt).
                Text(
                    title,
                    style = typography.headlineSmall.copy(color = scheme.onSurface),
                    modifier = Modifier.weight(1f),
                )
                NeptuneTierBadge(tier = tier)
            }
        }
        item {
            Spacer(Modifier.height(14.dp))
            val pagerState = rememberPagerState(pageCount = { cards.size })
            BoxWithConstraints(Modifier.fillMaxWidth()) {
                // viewportFraction 0.92 → 4% of the width on each side.
                val sidePad = maxWidth * 0.04f
                HorizontalPager(
                    state = pagerState,
                    contentPadding = PaddingValues(horizontal = sidePad),
                    modifier = Modifier.fillMaxWidth().height(210.dp),
                ) { page ->
                    val c = cards[page]
                    Box(
                        Modifier.fillMaxSize().padding(horizontal = 6.dp),
                        contentAlignment = Alignment.Center,
                    ) {
                        NeptuneCardArt(
                            holder = c.holder,
                            last4 = c.last4,
                            expiry = c.expiry,
                            scheme = c.scheme,
                            virtual = c.virtual,
                            selected = page == pagerState.currentPage,
                        )
                    }
                }
            }
        }
        item {
            Spacer(Modifier.height(14.dp))
            NeptuneCardControls(onControl = onControl ?: {}, frozen = frozen)
            Spacer(Modifier.height(14.dp))
            NeptuneLimitMeter(value = limitValue, label = limitLabel, amount = limitAmount)
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
            Spacer(Modifier.height(8.dp))
            NeptuneAddCard(label = addLabel, onTap = onAddCard)
        }
    }
}
