// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
import { defineConfig } from "vite";

// `base: "./"` makes the build relocatable as a plain static bundle.
export default defineConfig({
  base: "./",
  build: {
    target: "es2021",
    sourcemap: true,
  },
});
