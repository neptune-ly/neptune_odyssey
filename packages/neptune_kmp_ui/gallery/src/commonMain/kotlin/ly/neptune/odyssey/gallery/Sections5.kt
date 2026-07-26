// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Gallery sections for the wave-3 screen templates. Each template is a
// full-screen composition, rendered here inside a phone-height frame so the
// sweep captures it end to end.

package ly.neptune.odyssey.gallery

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneFlowStatus
import ly.neptune.odyssey.ui.components.NeptuneQuickActionItem
import ly.neptune.odyssey.ui.glyphs.NptIcons
import ly.neptune.odyssey.ui.templates.NeptuneAuthTemplate
import ly.neptune.odyssey.ui.templates.NeptuneCardData
import ly.neptune.odyssey.ui.templates.NeptuneCardsTemplate
import ly.neptune.odyssey.ui.templates.NeptuneDashboardTemplate
import ly.neptune.odyssey.ui.templates.NeptuneDetailRow
import ly.neptune.odyssey.ui.templates.NeptuneKycTemplate
import ly.neptune.odyssey.ui.templates.NeptuneOnboardingOutcome
import ly.neptune.odyssey.ui.templates.NeptuneOnboardingStatusTemplate
import ly.neptune.odyssey.ui.templates.NeptuneOtpStepTemplate
import ly.neptune.odyssey.ui.templates.NeptunePayeeData
import ly.neptune.odyssey.ui.templates.NeptuneTransferTemplate
import ly.neptune.odyssey.ui.templates.NeptuneTxData
import ly.neptune.odyssey.ui.templates.NeptuneWalletTemplate

internal fun wave3Sections(): List<GallerySection> = listOf(
    templateAuthSection,
    templateDashboardSection,
    templateCardsSection,
    templateTransferSection,
    templateWalletSection,
    templateKycSection,
    templateOnboardingSection,
    demoShellSection,
)

private val demoShellSection = GallerySection("tpl_demoshell", "Template · Demo shell (welcome)") {
    Phone(760.dp) {
        ly.neptune.odyssey.ui.templates.NeptuneDemoShellApp(
            brand = "neptune",
            bankNameEn = "Neptune",
            bankNameAr = "نبتون",
            // The logo slot is the MARK only — the shell renders the bank
            // name beside it itself.
            logo = { ly.neptune.odyssey.ui.components.NeptuneAvatar(initials = "N", size = 34.dp) },
        )
    }
}

@Composable
private fun Phone(height: Dp = 700.dp, content: @Composable () -> Unit) {
    Box(Modifier.fillMaxWidth().height(height)) { content() }
}

private val sampleTx = listOf(
    NeptuneTxData("Grocery Market", "Card · Today 09:41", "-86.20"),
    NeptuneTxData("Salary", "Transfer · Yesterday", "+3,200.00", credit = true),
    NeptuneTxData("Utilities", "Bill · Jul 3", "-142.75"),
)

private val sampleActions = listOf(
    NeptuneQuickActionItem("Send", icon = { Icon(NptIcons.send, null) }),
    NeptuneQuickActionItem("Receive", icon = { Icon(NptIcons.receive, null) }),
    NeptuneQuickActionItem("Top up", icon = { Icon(NptIcons.wallet, null) }),
    NeptuneQuickActionItem("Bills", icon = { Icon(NptIcons.bill, null) }),
)

private val templateAuthSection = GallerySection("tpl_auth", "Template · Auth") {
    Phone(620.dp) { NeptuneAuthTemplate(brandInitial = "N", brandName = "Neptune") }
}

private val templateDashboardSection = GallerySection("tpl_dashboard", "Template · Dashboard") {
    Phone(760.dp) {
        NeptuneDashboardTemplate(
            actions = sampleActions,
            transactions = sampleTx,
        )
    }
}

private val templateCardsSection = GallerySection("tpl_cards", "Template · Cards") {
    Phone(760.dp) {
        NeptuneCardsTemplate(
            cards = listOf(
                NeptuneCardData("Amira K. Benghazi", "4021", "09/29", "Odyssey"),
                NeptuneCardData("Amira K. Benghazi", "8830", "01/28", "Odyssey", virtual = true),
            ),
            transactions = sampleTx,
        )
    }
}

private val templateTransferSection = GallerySection("tpl_transfer", "Template · Transfer") {
    Phone(680.dp) {
        NeptuneTransferTemplate(
            payees = listOf(
                NeptunePayeeData("Amira Khaled", "LY83 002 •••• 5512"),
                NeptunePayeeData("Omar Trabelsi", "LY51 007 •••• 9034"),
            ),
        )
    }
}

private val templateWalletSection = GallerySection("tpl_wallet", "Template · Wallet") {
    Phone(760.dp) {
        NeptuneWalletTemplate(
            actions = sampleActions.take(3),
            merchants = listOf(
                ly.neptune.odyssey.ui.templates.NeptuneMerchantData("Corner Café", "Dining", "-14.50", "12:40"),
                ly.neptune.odyssey.ui.templates.NeptuneMerchantData("City Pharmacy", "Health", "-32.00", "10:05"),
            ),
            voucher = ly.neptune.odyssey.ui.templates.NeptuneVoucherData(
                "Welcome bonus", "25 LYD", "NPT-25", "Ends Aug 30",
            ),
        )
    }
}

private val templateKycSection = GallerySection("tpl_kyc", "Template · KYC") {
    Phone(700.dp) { NeptuneKycTemplate() }
}

private val templateOnboardingSection = GallerySection("tpl_onboarding", "Template · Onboarding") {
    Phone(1100.dp) {
        androidx.compose.foundation.layout.Column {
            Box(Modifier.fillMaxWidth().height(520.dp)) {
                NeptuneOtpStepTemplate(phoneMasked = "+218 •• ••• 8042")
            }
            Box(Modifier.fillMaxWidth().height(560.dp)) {
                NeptuneOnboardingStatusTemplate(
                    outcome = NeptuneOnboardingOutcome.Success,
                    title = "You're all set",
                    message = "Your account is open and ready.",
                    details = listOf(
                        NeptuneDetailRow("Account", "LY83 002 •••• 5512"),
                        NeptuneDetailRow("Opened", "2026-07-09"),
                    ),
                )
            }
        }
    }
}
