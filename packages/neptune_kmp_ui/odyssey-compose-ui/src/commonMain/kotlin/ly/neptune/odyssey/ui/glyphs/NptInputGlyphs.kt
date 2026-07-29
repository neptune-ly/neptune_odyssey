// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Input-control glyphs used by the form-field components (select caret,
// stepper +/-, date-field calendar, keypad backspace), built through the
// shared nptGlyph() builder: 24×24 grid, 1.8 stroke, round caps,
// currentColor. `caretDown` ports 1:1 from packages/neptune_icons/src/
// icons.ts (`chevron-down`); the rest have no neptune_icons source yet
// (the Flutter widgets lean on Material's built-in icons there) and are
// drawn in the same house style.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.vector.ImageVector

/** Input/form glyphs (tinted via Icon's `tint` / currentColor). */
public object NptInputGlyphs {
    /** Dropdown caret — neptune_icons `chevron-down`
     * (the Flutter `Icons.arrow_drop_down` analog on the select field). */
    public val caretDown: ImageVector by lazy {
        nptGlyph("npt.caretDown") {
            // M5.5 9.5 12 16l6.5-6.5
            moveTo(5.5f, 9.5f)
            lineTo(12f, 16f)
            lineTo(18.5f, 9.5f)
        }
    }

    /** Increment plus (the Flutter `Icons.add` analog on the stepper). */
    public val plus: ImageVector by lazy {
        nptGlyph("npt.plus") {
            moveTo(12f, 5f)
            verticalLineTo(19f)
            moveTo(5f, 12f)
            horizontalLineTo(19f)
        }
    }

    /** Decrement minus (the Flutter `Icons.remove` analog on the stepper). */
    public val minus: ImageVector by lazy {
        nptGlyph("npt.minus") {
            moveTo(5f, 12f)
            horizontalLineTo(19f)
        }
    }

    /** Calendar (the Flutter `Icons.calendar_today` analog on the date
     * field): a rounded 16×15 frame, header rule and two binding ticks. */
    public val calendar: ImageVector by lazy {
        nptGlyph("npt.calendar") {
            // rect x=4 y=5 width=16 height=15 rx=2.5
            moveTo(6.5f, 5f)
            horizontalLineTo(17.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 20f, 7.5f)
            verticalLineTo(17.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 17.5f, 20f)
            horizontalLineTo(6.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 4f, 17.5f)
            verticalLineTo(7.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 6.5f, 5f)
            close()
            // M4 9.5 h16 (header rule)
            moveTo(4f, 9.5f)
            horizontalLineToRelative(16f)
            // M8 3.5 v3 · M16 3.5 v3 (binding ticks)
            moveTo(8f, 3.5f)
            verticalLineToRelative(3f)
            moveTo(16f, 3.5f)
            verticalLineToRelative(3f)
        }
    }

    /** Backspace (the Flutter `Icons.backspace_outlined` analog on the
     * amount keypad) — mirrors under RTL like deletion itself does. */
    public val backspace: ImageVector by lazy {
        nptGlyph("npt.backspace", autoMirror = true) {
            // Key body: rounded on the trailing side, pointed at 3.5,12.
            moveTo(9.2f, 5.5f)
            horizontalLineTo(18.5f)
            arcTo(1.5f, 1.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 20f, 7f)
            verticalLineTo(17f)
            arcTo(1.5f, 1.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 18.5f, 18.5f)
            horizontalLineTo(9.2f)
            lineTo(3.5f, 12f)
            close()
            // The delete cross.
            moveTo(11.5f, 9.5f)
            lineToRelative(5f, 5f)
            moveTo(16.5f, 9.5f)
            lineToRelative(-5f, 5f)
        }
    }
}
