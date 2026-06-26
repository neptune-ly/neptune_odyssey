// Neptune Odyssey — brandprint codec (TypeScript port) · © 2026 Neptune.Fintech (neptune.ly)
// Faithful, byte-identical port of tools/brandprint.reference.js. 28-byte fixed layout ->
// base64url, version "NO1-", checksummed. Golden-tested against the JS reference.
// See docs/11-config-hash.md for the wire format.

import {
  FONTS,
  LOGIN,
  HERO,
  TONE,
  GLASS,
  MOTION,
  type Font,
  type LoginShell,
  type DashboardHero,
  type ContentTone,
  type GlassTint,
  type Motion,
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
  defaultDark: boolean;
  defaultRtl: boolean;
}

export interface DecodedBrandprint extends BrandprintConfig {
  version: number;
}

export const VERSION = 1;
const PREFIX = "NO1-";
const PAYLOAD_BYTES = 28;

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
  const buf = new Uint8Array(PAYLOAD_BYTES);
  const dv = new DataView(buf.buffer);
  let o = 0;
  buf[o++] = VERSION;
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
  buf[o++] = f;
  buf[o++] = 0; // reserved
  let sum = 0;
  for (let i = 0; i < o; i++) sum = (sum + buf[i]!) & 255;
  buf[o++] = sum; // checksum
  return PREFIX + toBase64Url(buf.subarray(0, PAYLOAD_BYTES));
}

/** Decode a `NO1-…` brandprint string. Throws on bad prefix/length/checksum/version. */
export function decode(str: string): DecodedBrandprint {
  if (!str.startsWith(PREFIX)) throw new Error("bad prefix");
  const buf = fromBase64Url(str.slice(4));
  if (buf.length !== PAYLOAD_BYTES) throw new Error("bad length");
  const dv = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
  let sum = 0;
  for (let i = 0; i < 27; i++) sum = (sum + buf[i]!) & 255;
  if (sum !== buf[27]) throw new Error("checksum mismatch");
  let o = 0;
  const version = buf[o++]!;
  if (version !== VERSION) throw new Error(`version ${version} unsupported`);
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
  };
}
