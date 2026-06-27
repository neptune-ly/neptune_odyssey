import { defineConfig } from "vite";

// Neptune web components are standard custom elements — no plugin needed.
export default defineConfig({
  server: { port: 5173, open: true },
});
