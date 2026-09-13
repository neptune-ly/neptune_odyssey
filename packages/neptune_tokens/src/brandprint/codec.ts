// Neptune Odyssey — brandprint codec (TypeScript port) · © 2026 Neptune.Fintech (neptune.ly)
// Faithful, byte-identical port of the Dart codec (neptune_flutter_ui). 28-byte layout
// (version byte 1) or, from 2.28.0, 29 bytes (version byte 2) when the extension byte
// carries something -> base64url, prefix "NO1-", checksummed. Golden-tested.
// See docs/11-config-hash.md for the wire format.

import {
  FONTS,
  LOGIN,
  HERO,
  TONE,
  GLASS,
  MOTION,
  MOTIF,
  type Font,
  type LoginShell,
  type DashboardHero,
  type ContentTone,
  type GlassTint,
  type Motion,
  type Motif,
  NAV_SHELL,
  type NavShell,
  ACTION_ROW,
  type ActionRow,
} from "./registries.js";

export interface Seed {
  L: number;
  C: number;
  H: number;
}

export interface Corners {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
  xxl: number;
}

export interface BrandprintConfig {
  primary: Seed;
  tertiary: Seed;
  corners: Corners;
  displayWeight: number;
  /** em, e.g. -0.02 */
  displayTracking: number;
  fonts: { display: Font; text: Font; num: Font };
  loginShell: LoginShell;
  dashboardHero: DashboardHero;
  contentTone: ContentTone;
  glassTint: GlassTint;
  motion: Motion;
  /** Byte 26 (reserved until 2.24.0). Omitted = "auto": derive from glassTint. */
  motif?: Motif;
  defaultDark: boolean;
  defaultRtl: boolean;
  /**
   * Flags bit 2 (2.24.0). True: the tertiary seed is the brand's ACCENT, spent on
   * direction and confirmation only, and feeds no Material role (tertiary* and the
   * card gradient come from primary). Omitted/false: tertiary is a second chrome
   * colour as before and the accent equals primary.
   */
  accentOnTertiary?: boolean;
  /**
   * Flags bit 3 (2.25.0). True: the white, structural register - the page ground
   * and app bar are surface-container-lowest (pure white in light), and a text
   * field is white inside its ring instead of filled. Omitted/false keeps the
   * tinted ground and the filled fields; dark mode is untouched either way.
   */
  whiteGround?: boolean;
  /**
   * Flags bits 4-5 (2.28.0). The bar the signed-in app stands on. Omitted =
   * "raised-dock", the floating glass dock every brandprint had before the
   * nibble was claimed.
   */
  navShell?: NavShell;
  /**
   * Flags bits 6-7 (2.28.0). The home quick-action treatment. Omitted =
   * "filled-circles", the tonal circle behind every glyph.
   */
  actionRow?: ActionRow;
  /**
   * Byte 27 (the extension byte), bit 0 (2.28.0). THE RULED REGISTER: this brand
   * draws structure in LINES - ruled rectangular buttons at the brand's own `md`
   * corner instead of stadium pills, and hairline-ruled groups instead of
   * tone-filled cards. It does NOT ride the flags byte: bits 4-7 are the two
   * composition registries and byte 26 is the motif, so the 28-byte layout was
   * full. Setting it grows the payload to 29 bytes and the version byte to 2;
   * omitted/false encodes to exactly the 28 bytes it always did.
   */
  ruledRegister?: boolean;
}

export interface DecodedBrandprint extends BrandprintConfig {
  version: number;
  motif: Motif;
  accentOnTertiary: boolean;
  whiteGround: boolean;
  navShell: NavShell;
  actionRow: ActionRow;
  ruledRegister: boolean;
}

/** The version byte of the original 28-byte layout. */
export const VERSION = 1;
/** The version byte of the 29-byte layout, which carries the extension byte. */
export const VERSION_EXTENDED = 2;
const PREFIX = "NO1-";
const PAYLOAD_BYTES = 28;
const PAYLOAD_BYTES_EXTENDED = 29;

const ix = <T>(arr: readonly T[], v: T): number => {
  const i = arr.indexOf(v);
  return i < 0 ? 0 : i;
};

function toBase64Url(bytes: Uint8Array): string {
  let bin = "";
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]!);
  const b64 =
    typeof btoa !== "undefined"
      ? btoa(bin)
      : Buffer.from(bytes).toString("base64");
  return b64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function fromBase64Url(s: string): Uint8Array {
  let t = s.replace(/-/g, "+").replace(/_/g, "/");
  while (t.length % 4) t += "=";
  if (typeof atob !== "undefined") {
    const bin = atob(t);
    const out = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
    return out;
  }
  return new Uint8Array(Buffer.from(t, "base64"));
}

/** Encode a config to its `NO1-…` brandprint string. */
export function encode(cfg: BrandprintConfig): string {
  // The extension byte is written only when it would carry something, so a config
  // that predates it produces exactly the 28 bytes it always did.
  let ext = 0;
  if (cfg.ruledRegister) ext |= 1;
  const extended = ext !== 0;
  const buf = new Uint8Array(extended ? PAYLOAD_BYTES_EXTENDED : PAYLOAD_BYTES);
  const dv = new DataView(buf.buffer);
  let o = 0;
  buf[o++] = extended ? VERSION_EXTENDED : VERSION;
  buf[o++] = Math.round(cfg.primary.L * 255);
  buf[o++] = Math.min(255, Math.round(cfg.primary.C * 1000));
  dv.setUint16(o, cfg.primary.H);
  o += 2;
  buf[o++] = Math.round(cfg.tertiary.L * 255);
  buf[o++] = Math.min(255, Math.round(cfg.tertiary.C * 1000));
  dv.setUint16(o, cfg.tertiary.H);
  o += 2;
  for (const k of ["xs", "sm", "md", "lg", "xl", "xxl"] as const) {
    buf[o++] = Math.min(255, cfg.corners[k]);
  }
  buf[o++] = Math.round(cfg.displayWeight / 100);
  dv.setInt8(o, Math.round(cfg.displayTracking * 1000));
  o += 1;
  buf[o++] = ix(FONTS, cfg.fonts.display);
  buf[o++] = ix(FONTS, cfg.fonts.text);
  buf[o++] = ix(FONTS, cfg.fonts.num);
  buf[o++] = ix(LOGIN, cfg.loginShell);
  buf[o++] = ix(HERO, cfg.dashboardHero);
  buf[o++] = ix(TONE, cfg.contentTone);
  buf[o++] = ix(GLASS, cfg.glassTint);
  buf[o++] = ix(MOTION, cfg.motion);
  let f = 0;
  if (cfg.defaultDark) f |= 1;
  if (cfg.defaultRtl) f |= 2;
  if (cfg.accentOnTertiary) f |= 4;
  if (cfg.whiteGround) f |= 8;
  // The high nibble carries the two composition shells, two bits each: the
  // 28-byte layout has no spare byte, and index 0 on both keeps every string
  // issued before 2.28.0 byte-identical.
  f |= (ix(NAV_SHELL, cfg.navShell ?? "raised-dock") & 3) << 4;
  f |= (ix(ACTION_ROW, cfg.actionRow ?? "filled-circles") & 3) << 6;
  buf[o++] = f;
  buf[o++] = ix(MOTIF, cfg.motif ?? "auto"); // motif (byte 26)
  if (extended) buf[o++] = ext; // byte 27, the extension byte
  let sum = 0;
  for (let i = 0; i < o; i++) sum = (sum + buf[i]!) & 255;
  buf[o++] = sum; // checksum
  return PREFIX + toBase64Url(buf);
}

/** Decode a `NO1-…` brandprint string. Throws on bad prefix/length/checksum/version. */
export function decode(str: string): DecodedBrandprint {
  if (!str.startsWith(PREFIX)) throw new Error("bad prefix");
  const buf = fromBase64Url(str.slice(4));
  if (buf.length !== PAYLOAD_BYTES && buf.length !== PAYLOAD_BYTES_EXTENDED) {
    throw new Error("bad length");
  }
  const dv = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
  const last = buf.length - 1; // the checksum is always the final byte
  let sum = 0;
  for (let i = 0; i < last; i++) sum = (sum + buf[i]!) & 255;
  if (sum !== buf[last]) throw new Error("checksum mismatch");
  let o = 0;
  const version = buf[o++]!;
  // The version byte NAMES the length. Accepting a mismatch would let a truncated
  // or padded payload decode as a plausible neighbour.
  const expected =
    version === VERSION ? PAYLOAD_BYTES : version === VERSION_EXTENDED ? PAYLOAD_BYTES_EXTENDED : -1;
  if (expected !== buf.length) {
    throw new Error(`version ${version} unsupported at ${buf.length} bytes`);
  }
  const primary: Seed = { L: buf[o++]! / 255, C: buf[o++]! / 1000, H: dv.getUint16((o += 2, o - 2)) };
  const tertiary: Seed = { L: buf[o++]! / 255, C: buf[o++]! / 1000, H: dv.getUint16((o += 2, o - 2)) };
  const corners = {} as Corners;
  for (const k of ["xs", "sm", "md", "lg", "xl", "xxl"] as const) corners[k] = buf[o++]!;
  const displayWeight = buf[o++]! * 100;
  const displayTracking = dv.getInt8(o) / 1000;
  o += 1;
  const fonts = {
    display: FONTS[buf[o++]!] as Font,
    text: FONTS[buf[o++]!] as Font,
    num: FONTS[buf[o++]!] as Font,
  };
  const loginShell = LOGIN[buf[o++]!] as LoginShell;
  const dashboardHero = HERO[buf[o++]!] as DashboardHero;
  const contentTone = TONE[buf[o++]!] as ContentTone;
  const glassTint = GLASS[buf[o++]!] as GlassTint;
  const motion = MOTION[buf[o++]!] as Motion;
  const f = buf[o++]!;
  const motif = MOTIF[buf[o++]!] as Motif;
  // Absent on a 28-byte payload, which is exactly how every pre-2.28.0 string
  // decodes to the defaults it always had.
  const ext = buf.length === PAYLOAD_BYTES_EXTENDED ? buf[o++]! : 0;
  return {
    version,
    primary,
    tertiary,
    corners,
    displayWeight,
    displayTracking,
    fonts,
    loginShell,
    dashboardHero,
    contentTone,
    glassTint,
    motion,
    defaultDark: !!(f & 1),
    defaultRtl: !!(f & 2),
    motif,
    accentOnTertiary: !!(f & 4),
    whiteGround: !!(f & 8),
    navShell: (NAV_SHELL[(f >> 4) & 3] ?? NAV_SHELL[0]) as NavShell,
    actionRow: (ACTION_ROW[(f >> 6) & 3] ?? ACTION_ROW[0]) as ActionRow,
    ruledRegister: !!(ext & 1),
  };
}
