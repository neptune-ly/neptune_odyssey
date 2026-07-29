// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Gallery sections for the wave-1 parity groups (selection/forms/secure,
// display, shell, states, quick actions). Popup-based overlays (dialog/
// sheet/menu/tooltip) are interactive-only and excluded from the static
// sweep; the toast host is inline and included.

package ly.neptune.odyssey.gallery

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Icon
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneAvatar
import ly.neptune.odyssey.ui.components.NeptuneAvatarGroup
import ly.neptune.odyssey.ui.components.NeptuneAvatarGroupItem
import ly.neptune.odyssey.ui.components.NeptuneAmountKeypad
import ly.neptune.odyssey.ui.components.NeptuneCheckbox
import ly.neptune.odyssey.ui.components.NeptuneCheckboxTile
import ly.neptune.odyssey.ui.components.NeptuneDateField
import ly.neptune.odyssey.ui.components.NeptuneEmptyState
import ly.neptune.odyssey.ui.components.NeptunePageHeader
import ly.neptune.odyssey.ui.components.NeptunePinInput
import ly.neptune.odyssey.ui.components.NeptuneProgressBar
import ly.neptune.odyssey.ui.components.NeptuneProgressRing
import ly.neptune.odyssey.ui.components.NeptuneQuickActionItem
import ly.neptune.odyssey.ui.components.NeptuneQuickActions
import ly.neptune.odyssey.ui.components.NeptuneRadioGroup
import ly.neptune.odyssey.ui.components.NeptuneRadioOption
import ly.neptune.odyssey.ui.components.NeptuneRating
import ly.neptune.odyssey.ui.components.NeptuneSearchField
import ly.neptune.odyssey.ui.components.NeptuneSelect
import ly.neptune.odyssey.ui.components.NeptuneSelectOption
import ly.neptune.odyssey.ui.components.NeptuneSkeletonCard
import ly.neptune.odyssey.ui.components.NeptuneSkeletonRow
import ly.neptune.odyssey.ui.components.NeptuneSlider
import ly.neptune.odyssey.ui.components.NeptuneStepperInput
import ly.neptune.odyssey.ui.components.NeptuneSwitch
import ly.neptune.odyssey.ui.components.NeptuneTimeline
import ly.neptune.odyssey.ui.components.NeptuneTimelineEntry
import ly.neptune.odyssey.ui.glyphs.NptFinanceGlyphs
import ly.neptune.odyssey.ui.glyphs.NptShellGlyphs

internal fun wave1Sections(): List<GallerySection> = listOf(
    selectionSection,
    formsSection,
    displaySection,
    shellSection,
    statesSection,
)

private val selectionSection = GallerySection("selection", "Selection controls") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        var checked by remember { mutableStateOf(true) }
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            NeptuneCheckbox(value = checked, onChanged = { checked = it })
            NeptuneCheckbox(value = false, onChanged = {})
            NeptuneSwitch(value = true, onChanged = {})
            NeptuneSwitch(value = false, onChanged = {})
        }
        NeptuneCheckboxTile(
            label = "Notify me about card payments",
            description = "Instant push for every transaction",
            value = true,
            onChanged = {},
        )
        NeptuneRadioGroup(
            options = listOf(
                NeptuneRadioOption("now", "Send now"),
                NeptuneRadioOption("later", "Schedule", description = "Pick a date"),
            ),
            value = "now",
            onChanged = {},
        )
        var amount by remember { mutableFloatStateOf(0.6f) }
        NeptuneSlider(value = amount, onValueChange = { amount = it }, label = "Monthly limit")
    }
}

private val formsSection = GallerySection("forms", "Form fields & secure entry") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneSelect(
            options = listOf(
                NeptuneSelectOption("chk", "Everyday checking"),
                NeptuneSelectOption("sav", "Rainy-day savings"),
            ),
            value = "chk",
            onChanged = {},
            label = "From account",
        )
        var qty by remember { mutableIntStateOf(2) }
        NeptuneStepperInput(value = qty, onChanged = { qty = it }, label = "Cards", min = 1, max = 5)
        var date by remember { mutableStateOf("2026-07-08") }
        NeptuneDateField(value = date, onValueChange = { date = it }, label = "Transfer date")
        var pin by remember { mutableStateOf("12") }
        NeptunePinInput(value = pin, onValueChange = { pin = it })
        NeptuneAmountKeypad(onKey = {}, onBackspace = {})
    }
}

private val displaySection = GallerySection("display", "Display primitives") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            NeptuneAvatar(initials = "AK")
            NeptuneAvatarGroup(
                avatars = listOf(
                    NeptuneAvatarGroupItem(initials = "AK"),
                    NeptuneAvatarGroupItem(initials = "MT"),
                    NeptuneAvatarGroupItem(initials = "SB"),
                    NeptuneAvatarGroupItem(initials = "LN"),
                    NeptuneAvatarGroupItem(initials = "ZR"),
                ),
            )
            NeptuneRating(value = 3.5f)
        }
        NeptuneProgressBar(value = 0.64f, label = "Budget used")
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            NeptuneProgressRing(value = 0.72f, centerLabel = "72%")
        }
        NeptuneTimeline(
            entries = listOf(
                NeptuneTimelineEntry("Transfer created", time = "09:12", done = true),
                NeptuneTimelineEntry("Compliance check", time = "09:14", done = true),
                NeptuneTimelineEntry("Funds released", subtitle = "Expected today"),
            ),
        )
    }
}

private val shellSection = GallerySection("shell", "Shell & quick actions") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptunePageHeader(
            title = "Insights",
            eyebrow = "March",
            subtitle = "Where your money went",
        )
        var q by remember { mutableStateOf("") }
        NeptuneSearchField(value = q, onValueChange = { q = it }, placeholder = "Search transactions")
        NeptuneQuickActions(
            actions = listOf(
                NeptuneQuickActionItem("Send", icon = { Icon(NptFinanceGlyphs.swapExchange, null) }),
                NeptuneQuickActionItem("Top up", icon = { Icon(NptFinanceGlyphs.wallet, null) }),
                NeptuneQuickActionItem("Search", icon = { Icon(NptShellGlyphs.search, null) }),
                NeptuneQuickActionItem("Refresh", icon = { Icon(NptShellGlyphs.refresh, null) }),
            ),
        )
    }
}

private val statesSection = GallerySection("states", "Loading & empty states") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneSkeletonCard()
        NeptuneSkeletonRow(count = 2)
        NeptuneEmptyState(
            title = "No saved beneficiaries",
            message = "People you pay often will show up here.",
            icon = { Icon(NptShellGlyphs.inbox, null) },
        )
    }
}
