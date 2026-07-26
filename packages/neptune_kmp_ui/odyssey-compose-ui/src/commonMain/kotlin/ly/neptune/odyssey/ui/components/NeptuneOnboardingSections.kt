// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Onboarding & content-structure blocks. Web counterparts: `<npt-onboarding>`
// and `<npt-section>` · Flutter: neptune_onboarding.dart (NeptuneChip /
// NeptuneStatusChip already live in NeptuneChips.kt). The onboarding hero
// fills bounded parents and falls back to a fixed hero height inside
// unbounded scroll columns — no unbounded-height traps. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ProvideTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.identity.NeptuneMotifLayer
import ly.neptune.odyssey.ui.identity.nptHeroGradient
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * A full-height get-started hero: a media region on top, then an eyebrow,
 * headline, supporting copy, page dots and a call to action.
 *
 * Web counterpart: `<npt-onboarding>` · Flutter: `NeptuneOnboarding`.
 *
 * [headline] is a fully styled slot (mix weights like the reference designs;
 * this composable only positions it and provides the base style). [media] is
 * an optional illustration slot — when null, a brand gradient
 * (primary → tertiary) with the login-shell motif etched over it fills the
 * space. [steps]/[activeStep] drive the page dots (0 steps = none); [cta]
 * sits at the bottom (e.g. a `NeptuneCta`).
 */
@Composable
public fun NeptuneOnboarding(
    headline: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    eyebrow: String? = null,
    supporting: String? = null,
    steps: Int = 0,
    activeStep: Int = 0,
    media: (@Composable () -> Unit)? = null,
    cta: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val direction = LocalLayoutDirection.current

    // Fill the screen when the parent bounds our height (a real onboarding
    // screen); fall back to a fixed hero height inside an unbounded scroll
    // column (e.g. a builder canvas) so the gradient hero still shows.
    BoxWithConstraints(modifier) {
        val bounded = constraints.hasBoundedHeight
        Column(
            Modifier
                .fillMaxWidth()
                .then(if (bounded) Modifier.fillMaxHeight() else Modifier),
        ) {
            // Media region: caller content, or the brand gradient with the
            // login-shell motif etched over it.
            Box(
                Modifier
                    .then(if (bounded) Modifier.weight(1f) else Modifier.height(300.dp))
                    .fillMaxWidth()
                    .padding(12.dp)
                    .clip(shape.rXl)
                    .then(
                        if (media == null) {
                            Modifier.drawBehind {
                                drawRect(nptHeroGradient(scheme, size, direction))
                            }
                        } else {
                            Modifier
                        },
                    ),
                contentAlignment = Alignment.Center,
            ) {
                if (media != null) {
                    media()
                } else {
                    NeptuneMotifLayer(
                        Modifier.matchParentSize(),
                        color = scheme.onPrimary,
                        strength = 1f,
                    )
                }
            }
            // Content block.
            Column(Modifier.fillMaxWidth().padding(24.dp)) {
                if (eyebrow != null) {
                    Text(
                        eyebrow.uppercase(),
                        style = typography.labelMedium.copy(
                            color = scheme.primary,
                            letterSpacing = 1.2.sp,
                        ),
                    )
                    Spacer(Modifier.height(12.dp))
                }
                // Hero headline in the display face; a lighter base weight
                // lets a bold emphasis run (mixed-weight) read the way the
                // web does.
                val base = typography.headlineSmall
                ProvideTextStyle(
                    base.copy(
                        fontWeight = FontWeight.W600,
                        lineHeight = base.fontSize * 1.12,
                        color = scheme.onSurface,
                    ),
                ) { headline() }
                if (supporting != null) {
                    Spacer(Modifier.height(12.dp))
                    Text(
                        supporting,
                        style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                    )
                }
                if (steps > 0) {
                    Spacer(Modifier.height(16.dp))
                    PageDots(steps = steps, activeStep = activeStep)
                }
                if (cta != null) {
                    Spacer(Modifier.height(16.dp))
                    cta()
                }
            }
        }
    }
}

/** A row of small rounded bars; the active one is wider (22×8dp) and
 * primary-coloured, the rest are 8dp `outlineVariant` dots. */
@Composable
private fun PageDots(steps: Int, activeStep: Int) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape.rFull
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        for (i in 0 until steps) {
            val active = i == activeStep
            Box(
                Modifier
                    .size(width = if (active) 22.dp else 8.dp, height = 8.dp)
                    .clip(shape)
                    .background(if (active) scheme.primary else scheme.outlineVariant),
            )
        }
    }
}

/**
 * A titled content section with an optional supporting description and a
 * body [content]. The title rides the brand display face.
 *
 * Web counterpart: `<npt-section>` · Flutter: `NeptuneSection`.
 */
@Composable
public fun NeptuneSection(
    title: String,
    modifier: Modifier = Modifier,
    description: String? = null,
    content: @Composable () -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val display = rememberNeptuneFontFamily(NeptuneTheme.type.display)

    Column(modifier) {
        Text(
            title,
            style = typography.titleMedium.copy(
                fontFamily = display ?: typography.titleMedium.fontFamily,
                color = scheme.onSurface,
            ),
        )
        if (description != null) {
            Spacer(Modifier.height(4.dp))
            Text(
                description,
                style = typography.bodySmall.copy(color = scheme.onSurfaceVariant),
            )
        }
        Spacer(Modifier.height(16.dp))
        content()
    }
}
