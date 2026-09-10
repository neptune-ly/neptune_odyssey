// Brandprint golden test — TS codec must be byte-identical to tools/brandprint.reference.js
// for the 4 reference brands, idempotent, and tamper-rejecting.
import { describe, it, expect } from "vitest";
import { createRequire } from "node:module";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { encode, decode, VERSION } from "../src/brandprint/codec.js";
import { BRAND_BRANDPRINT, BRAND_CONFIG } from "../src/data/brands.generated.js";

const require = createRequire(import.meta.url);
const ref = require("../assets/brandprint.reference.cjs");
const golden = JSON.parse(
  readFileSync(fileURLToPath(new URL("../assets/brandprints.golden.json", import.meta.url)), "utf8"),
);

const BRANDS = ["neptune", "triton", "nereid", "proteus"] as const;

describe("brandprint codec — golden parity with the JS reference", () => {
  it("VERSION matches the reference", () => {
    expect(VERSION).toBe(ref.VERSION);
  });

  for (const brand of BRANDS) {
    const cfg = golden.brands[brand].config;
    const expected = golden.brands[brand].brandprint as string;

    it(`${brand}: TS encode == golden string`, () => {
      expect(encode(cfg)).toBe(expected);
    });

    it(`${brand}: TS encode == JS reference encode`, () => {
      expect(encode(cfg)).toBe(ref.encode(cfg));
    });

    it(`${brand}: decode is idempotent (encode(decode(x)) === x)`, () => {
      expect(encode(decode(expected))).toBe(expected);
    });

    it(`${brand}: TS decode matches JS reference decode`, () => {
      expect(decode(expected)).toEqual({ version: VERSION, ...ref.decode(expected) });
    });

    it(`${brand}: BRAND_CONFIG/BRAND_BRANDPRINT data is self-consistent`, () => {
      expect(BRAND_BRANDPRINT[brand]).toBe(expected);
      expect(encode(BRAND_CONFIG[brand]!)).toBe(expected);
    });
  }
});

describe("brandprint codec — the motif byte (2.24.0)", () => {
  // Byte 26 was reserved (always 0) and now carries the MOTIF index. The four
  // reference strings must not move; the synthetic entry is what proves the
  // byte round-trips.
  for (const brand of BRANDS) {
    it(`${brand}: decodes motif "auto" and leaves byte 26 at 0`, () => {
      expect(decode(golden.brands[brand].brandprint).motif).toBe("auto");
    });
  }

  const custom = golden.brands["custom-none"];

  it("custom-none: TS encode == golden string", () => {
    expect(encode(custom.config)).toBe(custom.brandprint);
  });

  it("custom-none: TS encode == JS reference encode", () => {
    expect(encode(custom.config)).toBe(ref.encode(custom.config));
  });

  it("custom-none: motif survives the wire in TS and in the reference", () => {
    expect(decode(custom.brandprint).motif).toBe("none");
    expect(ref.decode(custom.brandprint).motif).toBe("none");
    expect(encode(decode(custom.brandprint))).toBe(custom.brandprint);
  });

  it("a config without motif encodes identically to motif: auto", () => {
    const cfg = golden.brands.triton.config;
    expect(encode({ ...cfg, motif: "auto" })).toBe(encode(cfg));
  });
});

describe("brandprint codec — 2.24.0 registry appends + flags bit 2", () => {
  const custom = golden.brands["custom-accent"];

  for (const brand of BRANDS) {
    it(`${brand}: accentOnTertiary decodes false (bit 2 clear)`, () => {
      expect(decode(golden.brands[brand].brandprint).accentOnTertiary).toBe(false);
    });
  }

  it("custom-accent: TS encode == golden string == JS reference encode", () => {
    expect(encode(custom.config)).toBe(custom.brandprint);
    expect(ref.encode(custom.config)).toBe(custom.brandprint);
  });

  it("custom-accent: the appended lever names and the flag survive the wire", () => {
    const d = decode(custom.brandprint);
    expect(d.loginShell).toBe("lockup-rule");
    expect(d.dashboardHero).toBe("chevron-summary");
    expect(d.accentOnTertiary).toBe(true);
    expect(d.defaultRtl).toBe(true); // bit 2 must not clobber bits 0-1
    expect(d.defaultDark).toBe(false);
    expect(ref.decode(custom.brandprint).accentOnTertiary).toBe(true);
    expect(encode(decode(custom.brandprint))).toBe(custom.brandprint);
  });

  it("a config without accentOnTertiary encodes identically to false", () => {
    const cfg = golden.brands.proteus.config;
    expect(encode({ ...cfg, accentOnTertiary: false })).toBe(encode(cfg));
  });
});

describe("brandprint codec — integrity", () => {
  const sample = golden.brands.neptune.brandprint as string;

  it("rejects a bad prefix", () => {
    expect(() => decode("NO2-" + sample.slice(4))).toThrow();
  });

  it("rejects a tampered checksum (flip one base64 char)", () => {
    const i = sample.length - 2;
    const ch = sample[i] === "A" ? "B" : "A";
    const tampered = sample.slice(0, i) + ch + sample.slice(i + 1);
    expect(() => decode(tampered)).toThrow();
  });

  it("rejects truncated payloads", () => {
    expect(() => decode("NO1-AAAA")).toThrow();
  });

  it("the 4 brands produce 4 distinct strings", () => {
    const set = new Set(BRANDS.map((b) => BRAND_BRANDPRINT[b]));
    expect(set.size).toBe(4);
  });
});
