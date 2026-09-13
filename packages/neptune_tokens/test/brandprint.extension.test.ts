// The 29-byte extension byte (2.28.0), mirrored from the Dart codec.
//
// The three strings below are the brandprints of the three banks in
// production, as the 2.27.0 codec issued them. If the TS port ever decodes one
// of them differently from the Dart port, a web or Studio preview stops
// matching the app the customer is holding.

import { describe, it, expect } from "vitest";
import { encode, decode, VERSION, VERSION_EXTENDED, type BrandprintConfig } from "../src/brandprint/codec.js";

const ISSUED_BEFORE_2_28_0 = {
  andalus: "NO1-AY_RAQVwoAEdCg4SGCAsCOwEBAQAAAABAAAFKQ",
  nuran: "NO1-AVeEAP96VwDyBgoMEBQcBgoEBAQEBAMAAQABIw",
  fglb: "NO1-AVtjAQaNvgAbCAwQFBokB-IEBAQFBQMDAwQFsw",
} as const;

const bytes = (s: string): Uint8Array => {
  let t = s.slice(4).replace(/-/g, "+").replace(/_/g, "/");
  while (t.length % 4) t += "=";
  return new Uint8Array(Buffer.from(t, "base64"));
};

const NURAN: BrandprintConfig = {
  primary: { L: 0.34, C: 0.132, H: 255 },
  tertiary: { L: 0.48, C: 0.087, H: 242 },
  corners: { xs: 6, sm: 10, md: 12, lg: 16, xl: 20, xxl: 28 },
  displayWeight: 600,
  displayTracking: 0.01,
  fonts: {
    display: "IBM Plex Sans Arabic",
    text: "IBM Plex Sans Arabic",
    num: "IBM Plex Sans Arabic",
  },
  loginShell: "paper-lockup",
  dashboardHero: "statement-ledger",
  contentTone: "formal-authoritative",
  glassTint: "oceanic",
  motion: "calm-graceful",
  motif: "sonar-rings",
  defaultDark: false,
  defaultRtl: false,
};

describe("brandprint extension byte", () => {
  for (const [bank, issued] of Object.entries(ISSUED_BEFORE_2_28_0)) {
    it(`${bank}: the production string stays 28 bytes on version 1`, () => {
      const b = bytes(issued);
      expect(b.length).toBe(28);
      expect(b[0]).toBe(VERSION);
    });

    it(`${bank}: decodes to the 2.28.0 defaults and re-encodes identically`, () => {
      const d = decode(issued);
      expect(d.ruledRegister).toBe(false);
      expect(d.navShell).toBe("raised-dock");
      expect(d.actionRow).toBe("filled-circles");
      expect(encode(d)).toBe(issued);
    });
  }

  it("nuran's config encodes to exactly the string 2.27.0 issued", () => {
    expect(encode(NURAN)).toBe(ISSUED_BEFORE_2_28_0.nuran);
  });

  it("ruledRegister grows the payload to 29 bytes on version 2", () => {
    const s = encode({ ...NURAN, ruledRegister: true });
    const b = bytes(s);
    expect(b.length).toBe(29);
    expect(b[0]).toBe(VERSION_EXTENDED);
    expect(b[27]).toBe(1);
    expect(s).not.toBe(ISSUED_BEFORE_2_28_0.nuran);
    expect(decode(s).ruledRegister).toBe(true);
    expect(encode(decode(s))).toBe(s);
  });

  it("the extension byte does not disturb the flags byte the shells share", () => {
    const d = decode(
      encode({
        ...NURAN,
        defaultRtl: true,
        whiteGround: true,
        navShell: "rule-bar",
        actionRow: "register-rows",
        ruledRegister: true,
      }),
    );
    expect(d.navShell).toBe("rule-bar");
    expect(d.actionRow).toBe("register-rows");
    expect(d.whiteGround).toBe(true);
    expect(d.defaultRtl).toBe(true);
    expect(d.defaultDark).toBe(false);
    expect(d.ruledRegister).toBe(true);
  });

  it("the version byte and the length must agree", () => {
    const reissue = (b: Uint8Array): string => {
      let sum = 0;
      for (let i = 0; i < b.length - 1; i++) sum = (sum + b[i]!) & 255;
      b[b.length - 1] = sum;
      return "NO1-" + Buffer.from(b).toString("base64url").replace(/=+$/, "");
    };
    const short = bytes(ISSUED_BEFORE_2_28_0.nuran);
    short[0] = VERSION_EXTENDED;
    expect(() => decode(reissue(short))).toThrow();

    const long = new Uint8Array(29);
    long.set(bytes(ISSUED_BEFORE_2_28_0.nuran).subarray(0, 27));
    long[0] = VERSION;
    expect(() => decode(reissue(long))).toThrow();
  });
});
