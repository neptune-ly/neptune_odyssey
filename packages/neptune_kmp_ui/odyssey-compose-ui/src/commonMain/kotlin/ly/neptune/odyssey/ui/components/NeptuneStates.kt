// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// State completeness (R4b): banks judge kits by the unhappy paths. Flutter
// counterpart: neptune_states.dart. This file makes loading / empty / error a
// first-class contract:
//   · NeptuneSkeletonCard / NeptuneSkeletonRow — ready-made placeholders that
//     mirror the real card/row anatomy (bones reuse NeptuneSkeleton, which
//     carries the brand shimmer + reduced-motion handling)
//   · NeptuneStateSwitcher — one wrapper that renders loading → skeleton,
//     error → branded retry, empty → NeptuneEmptyState, else the content —
//     with a soft cross-fade on the brand motion curve (instant swap under
//     reduced motion).
// Theme-only, RTL-safe, reduced-motion aware.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptShellGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** The four data states a surface can be in. Flutter: `NeptuneDataState`. */
public enum class NeptuneDataState { Loading, Error, Empty, Ready }

/**
 * Skeleton for card-shaped content (hero/stat cards) — shimmering bones in
 * the real card anatomy on a `surfaceContainerLow` brand-`lg` pane.
 * Flutter: `NeptuneSkeletonCard` (neptune_states.dart). Theme-only,
 * RTL-safe, reduced-motion aware (via [NeptuneSkeleton]).
 */
@Composable
public fun NeptuneSkeletonCard(
    modifier: Modifier = Modifier,
    height: Dp = 148.dp,
) {
    val scheme = MaterialTheme.colorScheme

    Column(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .clip(NeptuneTheme.shape.rLg)
            .background(scheme.surfaceContainerLow)
            .padding(20.dp),
    ) {
        NeptuneSkeleton(width = 120.dp, height = 12.dp)
        Spacer(Modifier.height(14.dp))
        NeptuneSkeleton(width = 200.dp, height = 26.dp)
        Spacer(Modifier.weight(1f))
        NeptuneSkeleton(width = 90.dp, height = 10.dp)
    }
}

/**
 * Skeleton for list rows (transactions/tiles) — [count] shimmering rows,
 * each a 40dp leading bone, a two-line body and a trailing amount bone.
 * Flutter: `NeptuneSkeletonRow` (neptune_states.dart). Theme-only, RTL-safe,
 * reduced-motion aware (via [NeptuneSkeleton]).
 */
@Composable
public fun NeptuneSkeletonRow(
    modifier: Modifier = Modifier,
    count: Int = 3,
) {
    Column(modifier.fillMaxWidth()) {
        repeat(count) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                NeptuneSkeleton(width = 40.dp, height = 40.dp)
                Spacer(Modifier.width(14.dp))
                Column(Modifier.weight(1f)) {
                    NeptuneSkeleton(width = 140.dp, height = 12.dp)
                    Spacer(Modifier.height(8.dp))
                    NeptuneSkeleton(width = 90.dp, height = 10.dp)
                }
                NeptuneSkeleton(width = 64.dp, height = 12.dp)
            }
        }
    }
}

/**
 * One wrapper for the whole data-state contract: give it the [state] and the
 * four faces; it cross-fades between them on the brand motion curve
 * (standard duration/easing). Under reduced motion the swap is instant.
 * Flutter: `NeptuneStateSwitcher` (neptune_states.dart).
 *
 * Defaults: loading → [NeptuneSkeletonRow] · empty → a themed
 * [NeptuneEmptyState] ([emptyIcon] falls back to the inbox glyph) · error →
 * a danger [NeptuneAlert] with a tonal retry [NeptuneButton] wired to
 * [onRetry]. Pass [loading]/[empty]/[error] to replace a face wholesale.
 * Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneStateSwitcher(
    state: NeptuneDataState,
    modifier: Modifier = Modifier,
    loading: (@Composable () -> Unit)? = null,
    empty: (@Composable () -> Unit)? = null,
    emptyTitle: String = "Nothing here yet",
    emptyMessage: String? = null,
    emptyIcon: (@Composable () -> Unit)? = null,
    error: (@Composable () -> Unit)? = null,
    errorTitle: String = "Something went wrong",
    retryLabel: String = "Try again",
    onRetry: (() -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion

    val face: @Composable (NeptuneDataState) -> Unit = { s ->
        when (s) {
            NeptuneDataState.Loading -> {
                if (loading != null) loading() else NeptuneSkeletonRow()
            }

            NeptuneDataState.Empty -> {
                if (empty != null) {
                    empty()
                } else {
                    NeptuneEmptyState(
                        title = emptyTitle,
                        message = emptyMessage,
                        icon = emptyIcon ?: {
                            Icon(
                                imageVector = NptShellGlyphs.inbox,
                                contentDescription = null,
                            )
                        },
                    )
                }
            }

            NeptuneDataState.Error -> {
                if (error != null) {
                    error()
                } else {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        NeptuneAlert(message = errorTitle, tone = NeptuneAlertTone.Danger)
                        Spacer(Modifier.height(12.dp))
                        NeptuneButton(
                            label = retryLabel,
                            onClick = onRetry,
                            variant = NeptuneButtonStyle.Tonal,
                            icon = {
                                Icon(
                                    imageVector = NptShellGlyphs.refresh,
                                    contentDescription = null,
                                    modifier = Modifier.size(20.dp),
                                )
                            },
                        )
                    }
                }
            }

            NeptuneDataState.Ready -> content()
        }
    }

    if (reduced) {
        // Instant swap — no cross-fade under reduced motion.
        Box(modifier) { face(state) }
    } else {
        Crossfade(
            targetState = state,
            modifier = modifier,
            animationSpec = tween(motion.standardMs, easing = motion.standard),
            label = "nptStateSwitcher",
        ) { s ->
            face(s)
        }
    }
}
