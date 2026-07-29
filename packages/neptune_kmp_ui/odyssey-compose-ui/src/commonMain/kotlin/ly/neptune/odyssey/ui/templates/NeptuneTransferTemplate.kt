// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed three-step transfer-flow screen template. Ported 1:1 from
// neptune_templates.dart (NeptuneTransferTemplate) / site/templates.html
// §transfer — composition only. The outcome step renders the linked
// hourglass → success/rejected motion via NeptuneStatusMotion (which is
// reduced-motion safe by itself).

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneAmountInput
import ly.neptune.odyssey.ui.components.NeptuneBeneficiaryTile
import ly.neptune.odyssey.ui.components.NeptuneCta
import ly.neptune.odyssey.ui.components.NeptuneFlowStatus
import ly.neptune.odyssey.ui.components.NeptuneSection
import ly.neptune.odyssey.ui.components.NeptuneStatusMotion
import ly.neptune.odyssey.ui.components.NeptuneStepper
import ly.neptune.odyssey.ui.components.NeptuneTransferReview
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** A payee for the transfer template.
 * Flutter counterpart: `NeptunePayeeData` (neptune_templates.dart). */
public class NeptunePayeeData(
    public val name: String,
    public val account: String,
)

/**
 * The three-step transfer flow: amount + beneficiary → review → outcome.
 * Fully driven: [step] 0..2; the outcome step renders the linked
 * hourglass → success/rejected motion via [outcome]. The 110dp bottom inset
 * leaves room for a dock hosted by the surrounding shell (see
 * [NeptuneDashboardTemplate] for the glass wiring note).
 *
 * Web counterpart: site/templates.html §transfer · Flutter:
 * `NeptuneTransferTemplate`.
 */
@Composable
public fun NeptuneTransferTemplate(
    modifier: Modifier = Modifier,
    step: Int = 0,
    steps: List<String> = listOf("Amount", "Review", "Done"),
    amount: String = "250.00",
    currency: String = "LYD",
    payees: List<NeptunePayeeData> = emptyList(),
    selectedPayee: Int = 0,
    onPayee: ((Int) -> Unit)? = null,
    onAmountChange: ((String) -> Unit)? = null,
    reviewFrom: String = "Everyday •••• 4821",
    fee: String = "0.00",
    beneficiariesTitle: String = "Beneficiaries",
    continueLabel: String = "Continue",
    confirmLabel: String = "Confirm & send",
    onContinue: (() -> Unit)? = null,
    onConfirm: (() -> Unit)? = null,
    outcome: NeptuneFlowStatus = NeptuneFlowStatus.Loading,
    sendingTitle: String = "Sending…",
    successTitle: String = "Transfer sent",
    rejectedTitle: String = "Transfer failed",
    doneLabel: String = "Done",
    onDone: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val payee = if (payees.isEmpty()) {
        NeptunePayeeData("—", "")
    } else {
        payees[selectedPayee.coerceIn(0, payees.lastIndex)]
    }

    if (step >= 2) {
        val sending = outcome == NeptuneFlowStatus.Loading
        val failed = outcome == NeptuneFlowStatus.Rejected
        Box(modifier.fillMaxSize().padding(32.dp), contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                NeptuneStatusMotion(status = outcome, size = 116.dp)
                Spacer(Modifier.height(22.dp))
                Text(
                    if (sending) sendingTitle else if (failed) rejectedTitle else successTitle,
                    style = typography.headlineSmall.copy(color = scheme.onSurface),
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    NeptuneTheme.formatDigits("$currency $amount → ${payee.name}"),
                    style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                )
                Spacer(Modifier.height(26.dp))
                if (!sending) {
                    NeptuneCta(doneLabel, onClick = onDone, expand = false)
                }
            }
        }
        return
    }

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .windowInsetsPadding(
                WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal),
            ),
        contentPadding = PaddingValues(start = 16.dp, top = 12.dp, end = 16.dp, bottom = 110.dp),
    ) {
        item {
            NeptuneStepper(steps = steps, active = step)
            Spacer(Modifier.height(18.dp))
        }
        if (step == 0) {
            item {
                NeptuneAmountInput(
                    value = amount,
                    onValueChange = onAmountChange ?: {},
                    currency = currency,
                )
                Spacer(Modifier.height(14.dp))
                NeptuneSection(title = beneficiariesTitle) {
                    Column {
                        payees.forEachIndexed { i, p ->
                            NeptuneBeneficiaryTile(
                                name = p.name,
                                account = p.account,
                                selected = i == selectedPayee,
                                onTap = if (onPayee == null) null else fun() { onPayee(i) },
                            )
                        }
                    }
                }
                Spacer(Modifier.height(16.dp))
                NeptuneCta(continueLabel, onClick = onContinue, arrow = true)
            }
        } else {
            item {
                NeptuneTransferReview(
                    fromLabel = reviewFrom,
                    toLabel = payee.name,
                    amount = amount,
                    fee = fee,
                    total = amount,
                    currency = currency,
                )
                Spacer(Modifier.height(16.dp))
                NeptuneCta(confirmLabel, onClick = onConfirm, arrow = true)
            }
        }
    }
}
