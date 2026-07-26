// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The toast stack. Web counterpart: `<npt-toast>` + `<npt-toast-host>`
// (feedback-status.ts) · Flutter: neptune_toast.dart (the `<npt-snackbar>`
// port — this component follows the richer npt-toast recipe: tones, timeout,
// close affordance, stacked host). A queue of timed, tone-tinted bars pinned
// inline-centre at the bottom, each rising in on the brand fast/spring
// motion (web `rise`: translateY(16px→0) + fade) and auto-hiding after its
// timeout (default 4000ms; 0 disables). Under reduced motion the slide is
// dropped and bars swap instantly (the web A11Y `animation: none`).
// Theme-only, RTL-safe.
//
// Compose idiom: overlay [NeptuneToastHost] once (e.g. as the last child of
// the app's root Box), keep the [NeptuneToastState] from
// [rememberNeptuneToastState], and call `state.show(message, tone)` — the
// analog of appending an `<npt-toast open>` to the web host.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredHeight
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay
import ly.neptune.odyssey.ui.glyphs.NptGlyphs
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/** Toast tones (web `<npt-toast tone=…>`). [Info] is the inverse-surface
 * default; the rest ride the matching container roles. */
public enum class NeptuneToastTone { Info, Success, Warning, Error }

/** One queued toast. */
internal class NeptuneToastEntry(
    val id: Long,
    val message: String,
    val tone: NeptuneToastTone,
    val timeoutMs: Int,
    val actionLabel: String?,
    val onAction: (() -> Unit)?,
) {
    /** Drives the rise-in / fade-out of this entry's bar. */
    val visible: MutableTransitionState<Boolean> = MutableTransitionState(false)
}

/**
 * The toast queue. Hand it to one [NeptuneToastHost] and [show] toasts from
 * anywhere that holds the state.
 */
@Stable
public class NeptuneToastState {
    internal val entries: SnapshotStateList<NeptuneToastEntry> = mutableStateListOf()
    private var nextId: Long = 0L

    /**
     * Queue a toast (newest stacks at the bottom, the web host order).
     * [timeoutMs] auto-hides after that many ms — 0 keeps it until closed
     * (web `timeout="0"`). An optional [actionLabel]/[onAction] renders an
     * accent-tinted trailing action. Returns an id for [dismiss].
     */
    public fun show(
        message: String,
        tone: NeptuneToastTone = NeptuneToastTone.Info,
        timeoutMs: Int = 4_000,
        actionLabel: String? = null,
        onAction: (() -> Unit)? = null,
    ): Long {
        val id = nextId++
        val entry = NeptuneToastEntry(id, message, tone, timeoutMs, actionLabel, onAction)
        entry.visible.targetState = true
        entries.add(entry)
        return id
    }

    /** Dismiss the toast with [id] (plays the exit motion, then removes). */
    public fun dismiss(id: Long) {
        entries.firstOrNull { it.id == id }?.visible?.targetState = false
    }

    internal fun remove(id: Long) {
        entries.removeAll { it.id == id }
    }
}

/** Remember a [NeptuneToastState] scoped to this composition. */
@Composable
public fun rememberNeptuneToastState(): NeptuneToastState = remember { NeptuneToastState() }

/**
 * The stacking toast container. Overlay it over the app content (it fills
 * the available box and pins its column of toasts inline-centre at the
 * bottom — web `inset-block-end: 24px`, 16dp inline padding, 12dp gaps).
 *
 * Web counterpart: `<npt-toast-host>` (+ `<npt-toast>`) · Flutter:
 * `showNeptuneToast` (the Overlay float).
 */
@Composable
public fun NeptuneToastHost(
    state: NeptuneToastState,
    modifier: Modifier = Modifier,
) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.BottomCenter) {
        Column(
            modifier = Modifier.padding(start = 16.dp, end = 16.dp, bottom = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            for (entry in state.entries) {
                key(entry.id) { ToastItem(state, entry) }
            }
        }
    }
}

/** One hosted toast: arms the auto-hide timer, animates in/out, removes
 * itself from the queue once the exit finishes. */
@Composable
private fun ToastItem(state: NeptuneToastState, entry: NeptuneToastEntry) {
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion
    val density = LocalDensity.current

    LaunchedEffect(entry) {
        if (entry.timeoutMs > 0) {
            delay(entry.timeoutMs.toLong())
            entry.visible.targetState = false
        }
    }
    val gone = entry.visible.isIdle && !entry.visible.currentState && !entry.visible.targetState
    LaunchedEffect(gone) {
        if (gone) state.remove(entry.id)
    }

    // Web `rise`: translateY(16px) → 0 + fade over dur-fast on ease-spring.
    val rise = with(density) { 16.dp.roundToPx() }
    AnimatedVisibility(
        visibleState = entry.visible,
        enter = if (reduced) {
            fadeIn(snap())
        } else {
            slideInVertically(tween(motion.fastMs, easing = motion.spring)) { rise } +
                fadeIn(tween(motion.fastMs, easing = motion.spring))
        },
        exit = if (reduced) {
            fadeOut(snap())
        } else {
            fadeOut(tween(motion.fastMs, easing = motion.standard))
        },
    ) {
        NeptuneToastBar(entry) { entry.visible.targetState = false }
    }
}

/** The toast bar itself: tone-tinted, elev-3, min 48dp, 16×12 padding,
 * capped at 560dp with message / optional action / close. */
@Composable
private fun NeptuneToastBar(entry: NeptuneToastEntry, onClose: () -> Unit) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val identity = NeptuneTheme.identity
    val shape = NeptuneTheme.shape.rSm
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    // Web tone table (feedback-status.ts `:host([tone=…])`).
    val bg: Color
    val fg: Color
    val accent: Color
    when (entry.tone) {
        NeptuneToastTone.Info -> {
            bg = scheme.inverseSurface
            fg = scheme.inverseOnSurface
            accent = scheme.inversePrimary
        }
        NeptuneToastTone.Success -> {
            bg = npt.successContainer
            fg = npt.onSuccessContainer
            accent = npt.success
        }
        NeptuneToastTone.Warning -> {
            bg = scheme.tertiaryContainer
            fg = scheme.onTertiaryContainer
            accent = scheme.tertiary
        }
        NeptuneToastTone.Error -> {
            bg = scheme.errorContainer
            fg = scheme.onErrorContainer
            accent = scheme.error
        }
    }

    Row(
        modifier = Modifier
            .widthIn(max = 560.dp)
            .nptShadow(identity.elevation3(scheme), shape)
            .clip(shape)
            .background(bg)
            .defaultMinSize(minHeight = 48.dp)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text(
            text = entry.message,
            style = typography.bodyMedium,
            color = fg,
            modifier = Modifier.weight(1f, fill = false),
        )
        if (entry.actionLabel != null) {
            // Accent action (web `::slotted(*)` tint) — visual stays a 24dp
            // strip, the tap target rides an overflowing 48dp band.
            Box(Modifier.height(24.dp), contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier
                        .requiredHeight(48.dp)
                        .defaultMinSize(minWidth = 48.dp)
                        .clip(NeptuneTheme.shape.rFull)
                        .clickable {
                            feedback.trigger(NptFeedbackCue.Tap, haptics)
                            entry.onAction?.invoke()
                            onClose()
                        }
                        .padding(horizontal = 8.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(text = entry.actionLabel, style = typography.labelLarge, color = accent)
                }
            }
        }
        // The web 44px close control, on an overflowing ≥48dp target.
        val interaction = remember { MutableInteractionSource() }
        Box(Modifier.size(24.dp), contentAlignment = Alignment.Center) {
            Box(
                modifier = Modifier
                    .requiredSize(48.dp)
                    .clip(NeptuneTheme.shape.rFull)
                    .clickable(interactionSource = interaction, indication = null) {
                        feedback.trigger(NptFeedbackCue.Tap, haptics)
                        onClose()
                    },
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    NptGlyphs.cross,
                    contentDescription = null,
                    tint = fg,
                    modifier = Modifier.size(18.dp),
                )
            }
        }
    }
}
