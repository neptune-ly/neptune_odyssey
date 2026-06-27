import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [
    vue({
      // Tell Vue that npt-* tags are custom elements, not Vue components.
      template: { compilerOptions: { isCustomElement: (tag) => tag.startsWith("npt-") } },
    }),
  ],
  server: { port: 5173, open: true },
});
