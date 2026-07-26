// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed payment-led wallet-home screen template. Ported 1:1 from
// neptune_templates.dart (NeptuneWalletTemplate) / site/templates.html
// §wallet — composition only.

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneBalanceCard
import ly.neptune.odyssey.ui.components.NeptuneMerchantRow
import ly.neptune.odyssey.ui.components.NeptuneQrPay
import ly.neptune.odyssey.ui.components.NeptuneQuickActionItem
import ly.neptune.odyssey.ui.components.NeptuneQuickActions
import ly.neptune.odyssey.ui.components.NeptuneSection
import ly.neptune.odyssey.ui.components.NeptuneTierBadge
import ly.neptune.odyssey.ui.components.NeptuneVoucherCard

/** A merchant row for the wallet template — name, category, amount, time.
 * Flutter counterpart: the `merchants` record entries. */
public class NeptuneMerchantData(
    public val name: String,
    public val category: String,
    public val amount: String,
    public val time: String,
)

/** A voucher for the wallet template — title, value, code, expiry.
 * Flutter counterpart: the `voucher` record. */
public class NeptuneVoucherData(
    public val title: String,
    public val value: String,
    public val code: String,
    public val expiry: String,
)

/**
 * The payment-led wallet home: tiered header, wallet hero, pay actions,
 * merchants, QR pay and a voucher. The 110dp bottom inset leaves room for a
 * dock hosted by the surrounding shell (see [NeptuneDashboardTemplate] for
 * the glass wiring note).
 *
 * Web counterpart: site/templates.html §wallet · Flutter:
 * `NeptuneWalletTemplate`.
 */
@Composable
public fun NeptuneWalletTemplate(
    modifier: Modifier = Modifier,
    title: String = "Wallet",
    tier: String = "Gold",
    balanceLabel: String = "Wallet balance",
    balance: String = "LYD 842.00",
    actions: List<NeptuneQuickActionItem> = emptyList(),
    merchantsTitle: String = "Recent merchants",
    merchants: List<NeptuneMerchantData> = emptyList(),
    qrAmount: String = "LYD 45.00",
    qrMerchant: String? = null,
    voucher: NeptuneVoucherData? = null,
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
            Spacer(Modifier.height(14.dp))
            NeptuneBalanceCard(label = balanceLabel, amount = balance, hero = true)
            Spacer(Modifier.height(14.dp))
            if (actions.isNotEmpty()) NeptuneQuickActions(actions = actions)
        }
        item {
            Spacer(Modifier.height(8.dp))
            NeptuneSection(title = merchantsTitle) {
                Column {
                    for (m in merchants) {
                        NeptuneMerchantRow(
                            name = m.name,
                            category = m.category,
                            amount = m.amount,
                            time = m.time,
                        )
                    }
                }
            }
        }
        item {
            Spacer(Modifier.height(8.dp))
            NeptuneQrPay(amount = qrAmount, merchant = qrMerchant)
        }
        if (voucher != null) {
            item {
                Spacer(Modifier.height(14.dp))
                NeptuneVoucherCard(
                    title = voucher.title,
                    value = voucher.value,
                    code = voucher.code,
                    expiry = voucher.expiry,
                )
            }
        }
    }
}
