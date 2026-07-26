// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Gallery sections for the wave-2 parity groups (data/charts, fintech,
// money movement, wallet/pay, corporate, navigation extras, splash).

package ly.neptune.odyssey.gallery

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneAccordion
import ly.neptune.odyssey.ui.components.NeptuneAccordionPanel
import ly.neptune.odyssey.ui.components.NeptuneAddCard
import ly.neptune.odyssey.ui.components.NeptuneApprovalItem
import ly.neptune.odyssey.ui.components.NeptuneAuditRow
import ly.neptune.odyssey.ui.components.NeptuneBarChart
import ly.neptune.odyssey.ui.components.NeptuneBarData
import ly.neptune.odyssey.ui.components.NeptuneBatchCard
import ly.neptune.odyssey.ui.components.NeptuneBeneficiaryTile
import ly.neptune.odyssey.ui.components.NeptuneBreadcrumbs
import ly.neptune.odyssey.ui.components.NeptuneBudgetRing
import ly.neptune.odyssey.ui.components.NeptuneCardControls
import ly.neptune.odyssey.ui.components.NeptuneColumn
import ly.neptune.odyssey.ui.components.NeptuneCompareBars
import ly.neptune.odyssey.ui.components.NeptuneCompareData
import ly.neptune.odyssey.ui.components.NeptuneCreditScoreGauge
import ly.neptune.odyssey.ui.components.NeptuneCrumb
import ly.neptune.odyssey.ui.components.NeptuneDataTable
import ly.neptune.odyssey.ui.components.NeptuneDonut
import ly.neptune.odyssey.ui.components.NeptuneFxCard
import ly.neptune.odyssey.ui.components.NeptuneInsightCard
import ly.neptune.odyssey.ui.components.NeptuneLimitMeter
import ly.neptune.odyssey.ui.components.NeptuneMerchantRow
import ly.neptune.odyssey.ui.components.NeptuneMethodRow
import ly.neptune.odyssey.ui.components.NeptunePagination
import ly.neptune.odyssey.ui.components.NeptunePermissionToggle
import ly.neptune.odyssey.ui.components.NeptuneQrPay
import ly.neptune.odyssey.ui.components.NeptuneReceipt
import ly.neptune.odyssey.ui.components.NeptuneReceiptRow
import ly.neptune.odyssey.ui.components.NeptuneSection
import ly.neptune.odyssey.ui.components.NeptuneSparkline
import ly.neptune.odyssey.ui.components.NeptuneStatCard
import ly.neptune.odyssey.ui.components.NeptuneSpendBreakdown
import ly.neptune.odyssey.ui.components.NeptuneSpendSlice
import ly.neptune.odyssey.ui.components.NeptuneSplashScreen
import ly.neptune.odyssey.ui.components.NeptuneStatusTone
import ly.neptune.odyssey.ui.components.NeptuneStepper
import ly.neptune.odyssey.ui.components.NeptuneSuccess
import ly.neptune.odyssey.ui.components.NeptuneTierBadge
import ly.neptune.odyssey.ui.components.NeptuneTierTone
import ly.neptune.odyssey.ui.components.NeptuneTopupRow
import ly.neptune.odyssey.ui.components.NeptuneTransferReview
import ly.neptune.odyssey.ui.components.NeptuneTrend
import ly.neptune.odyssey.ui.components.NeptuneUserRow
import ly.neptune.odyssey.ui.components.NeptuneVoucherCard
import ly.neptune.odyssey.ui.components.NeptuneWorkflowStatus
import ly.neptune.odyssey.ui.glyphs.NptFintechGlyphs

internal fun wave2Sections(): List<GallerySection> = listOf(
    dataVizSection,
    fintechSection,
    moneyMovementSection,
    walletSection,
    corporateSection,
    navExtrasSection,
    splashSection,
)

private val dataVizSection = GallerySection("dataviz", "Data & charts") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NeptuneStatCard(
                label = "This month",
                value = "1,240.00",
                unit = "LYD",
                delta = "+8.2%",
                modifier = Modifier.weight(1f),
                chart = {
                    NeptuneSparkline(points = listOf(3f, 5f, 4f, 7f, 6f, 9f), height = 36.dp)
                },
            )
            NeptuneStatCard(
                label = "Card spend",
                value = "486.50",
                delta = "-12%",
                modifier = Modifier.weight(1f),
            )
        }
        NeptuneDataTable(
            columns = listOf(
                NeptuneColumn("Payee"),
                NeptuneColumn("Date"),
                NeptuneColumn("Amount", numeric = true),
            ),
            rows = listOf(
                listOf("Grocery Market", "Jul 6", "-86.20"),
                listOf("Salary", "Jul 5", "+3,200.00"),
                listOf("Utilities", "Jul 3", "-142.75"),
            ),
            caption = "Recent activity",
        )
        Row(
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            NeptuneSparkline(
                points = listOf(4f, 7f, 5f, 9f, 6f, 11f, 10f),
                modifier = Modifier.weight(1f),
            )
            NeptuneDonut(segments = listOf(42f, 26f, 18f, 14f))
            NeptuneTrend(value = 4.2f)
        }
        NeptuneLimitMeter(value = 0.72f, label = "Card limit", amount = "7,200 / 10,000")
        NeptuneBarChart(
            bars = listOf(
                NeptuneBarData("Mar", 420f),
                NeptuneBarData("Apr", 380f),
                NeptuneBarData("May", 510f),
                NeptuneBarData("Jun", 460f),
            ),
            highlightIndex = 2,
            caption = { "${it.toInt()} LYD" },
        )
        NeptuneCompareBars(
            data = listOf(
                NeptuneCompareData("Food", 320f, 280f),
                NeptuneCompareData("Transport", 140f, 190f),
                NeptuneCompareData("Bills", 260f, 245f),
            ),
        )
    }
}

private val fintechSection = GallerySection("fintech", "Fintech premium") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneInsightCard(
            icon = { Icon(NptFintechGlyphs.trendingUp, null) },
            title = "Spending is down 12%",
            message = "You spent less on dining out than in June.",
            actionLabel = "See details",
            onAction = {},
            tone = NeptuneStatusTone.Success,
        )
        NeptuneFxCard(fromCurrency = "USD", toCurrency = "LYD", rate = "4.8210", change = "+0.6%", up = true)
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            NeptuneBudgetRing(spent = 640.0, limit = 900.0, label = "Groceries")
            NeptuneCreditScoreGauge(score = 712, band = "Good", size = 150.dp)
        }
        NeptuneSpendBreakdown(
            slices = listOf(
                NeptuneSpendSlice("Housing", 620.0),
                NeptuneSpendSlice("Food", 340.0),
                NeptuneSpendSlice("Transport", 180.0),
                NeptuneSpendSlice("Other", 120.0),
            ),
        )
    }
}

private val moneyMovementSection = GallerySection("moneymove", "Money movement") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneStepper(steps = listOf("Recipient", "Amount", "Review"), active = 1)
        NeptuneBeneficiaryTile(name = "Amira Khaled", account = "LY83 002 •••• 5512", selected = true, onTap = {})
        NeptuneMethodRow(
            icon = { Icon(ly.neptune.odyssey.ui.glyphs.NptFinanceGlyphs.wallet, null) },
            title = "Instant transfer",
            subtitle = "Arrives in seconds · 1.50 fee",
            selected = true,
            onTap = {},
        )
        NeptuneTransferReview(
            fromLabel = "Everyday checking",
            toLabel = "Amira Khaled",
            amount = "250.00",
            fee = "1.50",
            total = "251.50",
            currency = "LYD",
        )
        NeptuneSuccess(title = "Transfer sent", amount = "250.00 LYD", subtitle = "To Amira Khaled · today 14:02")
        NeptuneReceipt(
            title = "Receipt",
            rows = listOf(
                NeptuneReceiptRow("Reference", "TRX-88014"),
                NeptuneReceiptRow("Amount", "250.00 LYD"),
                NeptuneReceiptRow("Fee", "1.50 LYD"),
            ),
            onShare = {},
        )
    }
}

private val walletSection = GallerySection("wallet", "Wallet & pay") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            NeptuneTierBadge(tier = "Gold", tone = NeptuneTierTone.Gold)
            NeptuneTierBadge(tier = "Standard")
        }
        NeptuneMerchantRow(name = "Corner Café", amount = "-14.50", category = "Dining", time = "12:40", pending = true)
        NeptuneVoucherCard(title = "Welcome bonus", value = "25 LYD", code = "NPT-25", expiry = "Ends Aug 30")
        NeptuneTopupRow(label = "Mobile top-up", amount = "10.00", sublabel = "Libyana ••41", onTap = {})
        NeptuneQrPay(amount = "36.75 LYD", merchant = "Corner Café", size = 150.dp)
        NeptuneCardControls(onControl = {}, frozen = false)
        NeptuneAddCard(onTap = {})
    }
}

private val corporateSection = GallerySection("corporate", "Corporate") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneApprovalItem(
            title = "Payroll batch #42",
            subtitle = "Requested by Finance · 18 payments",
            amount = "64,200.00",
            onApprove = {},
            onReject = {},
        )
        NeptuneBatchCard(title = "July payroll", count = "18", total = "64,200.00", status = "Awaiting approval")
        NeptuneAuditRow(actor = "S. Benali", action = "approved payment TRX-88014", time = "14:02")
        NeptuneUserRow(name = "Amira Khaled", role = "Approver", status = "Active", onClick = {})
        NeptunePermissionToggle(
            label = "Can approve transfers",
            description = "Up to 10,000 LYD per day",
            value = true,
            onChanged = {},
        )
        NeptuneWorkflowStatus(label = "Payment approval", step = 2, total = 3)
    }
}

private val navExtrasSection = GallerySection("navx", "Navigation extras & sections") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneBreadcrumbs(
            crumbs = listOf(
                NeptuneCrumb("Payments") {},
                NeptuneCrumb("Batches") {},
                NeptuneCrumb("July payroll"),
            ),
        )
        NeptunePagination(page = 2, pageCount = 8, onChanged = {})
        NeptuneAccordion(
            panels = listOf(
                NeptuneAccordionPanel("What are limits?", initiallyExpanded = true) {
                    Text("Limits cap how much can leave the account per day.")
                },
                NeptuneAccordionPanel("How do I raise them?") {
                    Text("Ask an approver, or visit a branch.")
                },
            ),
        )
        NeptuneSection(title = "Security", description = "Who can touch this account") {
            NeptunePermissionToggle(label = "Biometric sign-in", value = true, onChanged = {})
        }
    }
}

private val splashSection = GallerySection("splash", "Splash") {
    Box(Modifier.fillMaxWidth().height(420.dp)) {
        NeptuneSplashScreen(brandInitial = "N", brandName = "Neptune", caption = "Securing your session…")
    }
}
