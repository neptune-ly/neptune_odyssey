// Neptune Odyssey — @neptune.fintech/tokens · © 2026 Neptune.Fintech (neptune.ly)
// The determinism backbone: OKLCH→sRGB color math, the seed→palette ramp, the
// brandprint codec, pinned reference palettes, and the unified theme builder.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).

export * from "./types.js";
export * from "./color/oklch.js";
export * from "./color/palette.js";
export * from "./brandprint/registries.js";
export * from "./brandprint/codec.js";
export * from "./resolve.js";
export * from "./theme.js";
export * from "./generate/css.js";
export * from "./generate/dart.js";

export { RESOLVED } from "./data/resolved.generated.js";
export { BRAND_CONFIG, BRAND_BRANDPRINT } from "./data/brands.generated.js";
export { MOTION_PRESETS, BRAND_SHAPE, BRAND_TYPE, REFERENCE_SCALE } from "./data/levers.generated.js";

export const TOKENS_VERSION = "2.0.0";
