// {{PROJECT_TITLE}} — Neptune Odyssey starter (web).
//
// 1. Register the Neptune custom elements (+ <npt-icon>).
// 2. Import the design-system stylesheet (reference themes + tokens).
// 3. applyTheme() paints the brandprint onto <html> as CSS variables.

import { applyTheme, registerAll } from "@neptune.fintech/web-ui";
import type { DirOption, ModeOption } from "@neptune.fintech/web-ui";
import { registerIcons } from "@neptune.fintech/icons";
import "@neptune.fintech/web-ui/styles.css";

import { dashboard } from "./dashboard";
import "./styles.css";

const BRAND = "{{BRAND}}";
const DIR: DirOption = "{{DIR}}";

registerAll();
registerIcons();

const app = document.querySelector<HTMLDivElement>("#app")!;
app.className = "app";
app.innerHTML = dashboard;

let mode: ModeOption = "{{MODE}}";
function paint(): void {
  applyTheme(document.documentElement, BRAND, { mode, dir: DIR });
}
paint();

const toggle = document.querySelector<HTMLButtonElement>("#modeToggle");
toggle?.addEventListener("click", () => {
  mode = mode === "dark" ? "light" : "dark";
  paint();
  toggle.textContent = mode === "dark" ? "☀ Light" : "☾ Dark";
});

document.querySelector<HTMLElement>("#cta")?.addEventListener("click", () => {
  window.alert("Wire this button to your transfer flow.");
});
