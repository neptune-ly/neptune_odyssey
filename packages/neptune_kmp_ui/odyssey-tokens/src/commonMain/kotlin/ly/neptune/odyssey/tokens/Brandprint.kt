// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Brandprint codec (Kotlin port). Faithful, byte-identical port of the
// TypeScript reference (packages/neptune_tokens/src/brandprint/codec.ts) and
// the Dart port (neptune_flutter_ui/lib/src/brandprint/codec.dart). 28-byte
// fixed layout -> base64url, version "NO1-", checksummed. Golden-tested
// against the four reference brands. See docs/11-config-hash.md for the wire
// format.

package ly.neptune.odyssey.tokens

import kotlin.io.encoding.Base64
import kotlin.math.roundToInt

/** Append-only font registry. Indices ARE the wire format — never reorder. */
public val kFonts: List<String> = listOf(
    "Hanken Grotesk",
    "Bricolage Grotesque",
    "Space Grotesk",
    "Sora",
    "IBM Plex Sans Arabic",
    "Reem Kufi",
    "Tajawal",
    "Readex Pro",
    "Noto Kufi Arabic",
)

/** Append-only login-shell registry. */
public val kLoginShells: List<String> = listOf(
    "depth-emblem",
    "arcade-arches",
    "light-grid-spark",
    "shield-guilloche",
)

/** Append-only dashboard-hero registry. */
public val kDashboardHeroes: List<String> = listOf(
    "balance-cards",
    "warm-balance-cards",
    "wallet-hero",
    "restrained-balance",
)

/** Append-only content-tone registry. */
public val kContentTones: List<String> = listOf(
    "clear-calm",
    "warm-hospitable",
    "light-instant",
    "formal-authoritative",
)

/** Append-only glass-tint registry. */
public val kGlassTints: List<String> = listOf(
    "oceanic",
    "warm-amber",
    "violet-luminous",
    "navy-steel",
)

/** Append-only motion registry. */
public val kMotions: List<String> = listOf(
    "smooth-fluid",
    "calm-graceful",
    "light-quick-crisp",
    "stable-minimal-authoritative",
)

/** An OKLCH seed colour (perceptual lightness, chroma, hue degrees). */
public data class Seed(public val l: Double, public val c: Double, public val h: Int)

/** The six corner radii (px), xs..xxl. */
public data class Corners(
    public val xs: Int,
    public val sm: Int,
    public val md: Int,
    public val lg: Int,
    public val xl: Int,
    public val xxl: Int,
)

/**
 * A complete brandprint input config — the inputs a theme is generated from.
 * Mirrors `BrandprintConfig` in codec.ts field-for-field.
 */
public data class BrandprintConfig(
    public val version: Int = 1,
    public val primary: Seed,
    public val tertiary: Seed,
    public val corners: Corners,
    public val displayWeight: Int,
    /** Tracking in em, e.g. -0.02. */
    public val displayTracking: Double,
    public val fontDisplay: String,
    public val fontText: String,
    public val fontNum: String,
    public val loginShell: String,
    public val dashboardHero: String,
    public val contentTone: String,
    public val glassTint: String,
    public val motion: String,
    public val defaultDark: Boolean = false,
    public val defaultRtl: Boolean = false,
)

/** Thrown by [Brandprint.decode] on bad prefix/length/checksum/version. */
public class BrandprintFormatException(message: String) : IllegalArgumentException(message)

/** Encode/decode the portable `NO1-…` brandprint string. */
public object Brandprint {
    public const val version: Int = 1
    private const val PREFIX = "NO1-"
    private const val PAYLOAD_BYTES = 28

    private fun ix(arr: List<String>, v: String): Int {
        val i = arr.indexOf(v)
        return if (i < 0) 0 else i
    }

    private fun toBase64Url(bytes: ByteArray): String =
        Base64.UrlSafe.encode(bytes).replace("=", "")

    private fun fromBase64Url(s: String): ByteArray {
        var t = s
        while (t.length % 4 != 0) t += "="
        return Base64.UrlSafe.decode(t)
    }

    /** Encode a config to its `NO1-…` brandprint string. */
    public fun encode(cfg: BrandprintConfig): String {
        val buf = ByteArray(PAYLOAD_BYTES)
        var o = 0
        fun put(v: Int) {
            buf[o++] = v.toByte()
        }
        fun putU16(v: Int) {
            buf[o++] = ((v shr 8) and 0xFF).toByte()
            buf[o++] = (v and 0xFF).toByte()
        }
        put(version)
        put((cfg.primary.l * 255).roundToInt())
        put((cfg.primary.c * 1000).roundToInt().coerceIn(0, 255))
        putU16(cfg.primary.h)
        put((cfg.tertiary.l * 255).roundToInt())
        put((cfg.tertiary.c * 1000).roundToInt().coerceIn(0, 255))
        putU16(cfg.tertiary.h)
        val c = cfg.corners
        for (v in intArrayOf(c.xs, c.sm, c.md, c.lg, c.xl, c.xxl)) {
            put(v.coerceIn(0, 255))
        }
        put((cfg.displayWeight / 100.0).roundToInt())
        put((cfg.displayTracking * 1000).roundToInt()) // int8, two's complement
        put(ix(kFonts, cfg.fontDisplay))
        put(ix(kFonts, cfg.fontText))
        put(ix(kFonts, cfg.fontNum))
        put(ix(kLoginShells, cfg.loginShell))
        put(ix(kDashboardHeroes, cfg.dashboardHero))
        put(ix(kContentTones, cfg.contentTone))
        put(ix(kGlassTints, cfg.glassTint))
        put(ix(kMotions, cfg.motion))
        var f = 0
        if (cfg.defaultDark) f = f or 1
        if (cfg.defaultRtl) f = f or 2
        put(f)
        put(0) // reserved
        var sum = 0
        for (i in 0 until o) {
            sum = (sum + (buf[i].toInt() and 0xFF)) and 255
        }
        put(sum) // checksum
        return PREFIX + toBase64Url(buf)
    }

    /**
     * Decode a `NO1-…` brandprint string.
     * Throws [BrandprintFormatException] on bad prefix/length/checksum/version.
     */
    public fun decode(str: String): BrandprintConfig {
        if (!str.startsWith(PREFIX)) {
            throw BrandprintFormatException("bad prefix")
        }
        val buf = try {
            fromBase64Url(str.substring(4))
        } catch (e: IllegalArgumentException) {
            throw BrandprintFormatException("bad base64url payload")
        }
        if (buf.size != PAYLOAD_BYTES) {
            throw BrandprintFormatException("bad length")
        }
        var sum = 0
        for (i in 0 until 27) {
            sum = (sum + (buf[i].toInt() and 0xFF)) and 255
        }
        if (sum != (buf[27].toInt() and 0xFF)) {
            throw BrandprintFormatException("checksum mismatch")
        }
        var o = 0
        fun u8(): Int = buf[o++].toInt() and 0xFF
        fun i8(): Int = buf[o++].toInt() // signed
        fun u16(): Int = (u8() shl 8) or u8()
        val ver = u8()
        if (ver != version) {
            throw BrandprintFormatException("version $ver unsupported")
        }
        val primary = Seed(l = u8() / 255.0, c = u8() / 1000.0, h = u16())
        val tertiary = Seed(l = u8() / 255.0, c = u8() / 1000.0, h = u16())
        val corners = Corners(xs = u8(), sm = u8(), md = u8(), lg = u8(), xl = u8(), xxl = u8())
        val displayWeight = u8() * 100
        val displayTracking = i8() / 1000.0
        val fontDisplay = kFonts[u8()]
        val fontText = kFonts[u8()]
        val fontNum = kFonts[u8()]
        val loginShell = kLoginShells[u8()]
        val dashboardHero = kDashboardHeroes[u8()]
        val contentTone = kContentTones[u8()]
        val glassTint = kGlassTints[u8()]
        val motion = kMotions[u8()]
        val f = u8()
        return BrandprintConfig(
            version = ver,
            primary = primary,
            tertiary = tertiary,
            corners = corners,
            displayWeight = displayWeight,
            displayTracking = displayTracking,
            fontDisplay = fontDisplay,
            fontText = fontText,
            fontNum = fontNum,
            loginShell = loginShell,
            dashboardHero = dashboardHero,
            contentTone = contentTone,
            glassTint = glassTint,
            motion = motion,
            defaultDark = (f and 1) != 0,
            defaultRtl = (f and 2) != 0,
        )
    }
}
