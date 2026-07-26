// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Gallery sections for the component groups beyond the identity/pattern set.

package ly.neptune.odyssey.gallery

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneAccountTile
import ly.neptune.odyssey.ui.components.NeptuneAlert
import ly.neptune.odyssey.ui.components.NeptuneAlertTone
import ly.neptune.odyssey.ui.components.NeptuneAmountInput
import ly.neptune.odyssey.ui.components.NeptuneAppBar
import ly.neptune.odyssey.ui.components.NeptuneAppBarVariant
import ly.neptune.odyssey.ui.components.NeptuneBadge
import ly.neptune.odyssey.ui.components.NeptuneBalanceCard
import ly.neptune.odyssey.ui.components.NeptuneBanner
import ly.neptune.odyssey.ui.components.NeptuneCardArt
import ly.neptune.odyssey.ui.components.NeptuneChip
import ly.neptune.odyssey.ui.components.NeptuneCta
import ly.neptune.odyssey.ui.components.NeptuneDock
import ly.neptune.odyssey.ui.components.NeptuneDockItem
import ly.neptune.odyssey.ui.components.NeptuneFlowStatus
import ly.neptune.odyssey.ui.components.NeptuneHourglassLoader
import ly.neptune.odyssey.ui.components.NeptuneDotsLoader
import ly.neptune.odyssey.ui.components.NeptuneListTile
import ly.neptune.odyssey.ui.components.NeptuneOtpInput
import ly.neptune.odyssey.ui.components.NeptunePulseLoader
import ly.neptune.odyssey.ui.components.NeptuneSegmented
import ly.neptune.odyssey.ui.components.NeptuneSkeleton
import ly.neptune.odyssey.ui.components.NeptuneSpinner
import ly.neptune.odyssey.ui.components.NeptuneStatusChip
import ly.neptune.odyssey.ui.components.NeptuneStatusMotion
import ly.neptune.odyssey.ui.components.NeptuneStatusTone
import ly.neptune.odyssey.ui.components.NeptuneTabs
import ly.neptune.odyssey.ui.components.NeptuneTag
import ly.neptune.odyssey.ui.components.NeptuneTextField
import ly.neptune.odyssey.ui.components.NeptuneTransactionRow
import ly.neptune.odyssey.ui.components.NeptuneWelcome
import ly.neptune.odyssey.ui.glyphs.NptFinanceGlyphs
import ly.neptune.odyssey.ui.glyphs.NptGlyphs

internal fun componentSections(): List<GallerySection> = listOf(
    financeSection,
    inputsSection,
    navSection,
    statusSection,
    motionSection,
    welcomeSection,
)

private val financeSection = GallerySection("finance", "Finance surfaces") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneBalanceCard(
            label = "Main account",
            amount = "24,850.75 LYD",
            caption = "Available balance",
            hero = true,
        )
        NeptuneCardArt(
            holder = "Amira K. Benghazi",
            last4 = "4021",
            expiry = "09/29",
            scheme = "Odyssey",
        )
        NeptuneTransactionRow(
            title = "Grocery Market",
            subtitle = "Card · Today 09:41",
            amount = "-86.20",
        )
        NeptuneTransactionRow(
            title = "Salary",
            subtitle = "Transfer · Yesterday",
            amount = "+3,200.00",
            isCredit = true,
        )
        NeptuneAccountTile(
            name = "Everyday checking",
            maskedNumber = "•••• 5512",
            balance = "8,410.00",
        )
    }
}

private val inputsSection = GallerySection("inputs", "Inputs") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        var name by remember { mutableStateOf("") }
        NeptuneTextField(
            value = name,
            onValueChange = { name = it },
            label = "Beneficiary name",
            placeholder = "Full name",
            helper = "As written on the account",
        )
        var bad by remember { mutableStateOf("NPT-1") }
        NeptuneTextField(
            value = bad,
            onValueChange = { bad = it },
            label = "IBAN",
            error = "That IBAN doesn't look right",
        )
        var amount by remember { mutableStateOf("120.50") }
        NeptuneAmountInput(value = amount, onValueChange = { amount = it }, currency = "LYD")
        var otp by remember { mutableStateOf("42") }
        NeptuneOtpInput(value = otp, onValueChange = { otp = it }, length = 6)
    }
}

private val navSection = GallerySection("nav", "Navigation & shell") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneAppBar(title = "Payments", variant = NeptuneAppBarVariant.Small)
        NeptuneAppBar(title = "Accounts", variant = NeptuneAppBarVariant.Large)
        NeptuneTabs(tabs = listOf("Accounts", "Cards", "Insights"), selectedIndex = 1, onSelect = {})
        NeptuneSegmented(
            options = listOf("Daily", "Weekly", "Monthly"),
            selectedIndex = 0,
            onSelect = {},
            modifier = Modifier.fillMaxWidth(),
        )
        NeptuneDock(
            items = listOf(
                NeptuneDockItem("Home") { Icon(NptFinanceGlyphs.wallet, contentDescription = null) },
                NeptuneDockItem("Move") { Icon(NptFinanceGlyphs.swapExchange, contentDescription = null) },
                NeptuneDockItem("More") { Icon(NptGlyphs.arrowForward, contentDescription = null) },
            ),
            selectedIndex = 0,
            onSelect = {},
        )
    }
}

private val statusSection = GallerySection("status", "Status & feedback") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneAlert(
            message = "Transfers above 10,000 LYD need a second approval.",
            tone = NeptuneAlertTone.Warning,
            title = "Approval required",
        )
        NeptuneBanner(message = "A new statement is ready for March.")
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            NeptuneChip("All", selected = true, onClick = {})
            NeptuneChip("Cards", onClick = {})
            NeptuneStatusChip("Cleared", tone = NeptuneStatusTone.Success)
            NeptuneStatusChip("Held", tone = NeptuneStatusTone.Danger)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            NeptuneBadge(count = 3)
            NeptuneTag("Utilities", onRemove = {})
        }
        NeptuneListTile(
            title = "Standing order",
            subtitle = "Rent · monthly on the 1st",
            trailing = { Icon(NptGlyphs.arrowForward, contentDescription = null, modifier = Modifier.size(20.dp)) },
            onClick = {},
        )
        NeptuneSkeleton(height = 16.dp)
        NeptuneSkeleton(width = 220.dp, height = 16.dp)
    }
}

private val motionSection = GallerySection("motion", "Status motion & loaders") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
            NeptuneStatusMotion(NeptuneFlowStatus.Success, size = 84.dp)
            NeptuneStatusMotion(NeptuneFlowStatus.Rejected, size = 84.dp)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
            NeptuneHourglassLoader(size = 56.dp)
            NeptuneSpinner()
            NeptuneDotsLoader()
            NeptunePulseLoader(size = 48.dp)
        }
    }
}

private val welcomeSection = GallerySection("welcome", "Welcome") {
    Box(Modifier.fillMaxWidth().height(560.dp)) {
        NeptuneWelcome(
            brandInitial = "N",
            brandName = "Neptune",
            title = "Banking that feels",
            emphasis = "made for you",
            supporting = "One account for every day — cards, transfers and insights in one place.",
            primaryAction = { NeptuneCta("Get started", onClick = {}, arrow = true) },
        )
    }
}
