// Neptune Odyssey — framework registry for create-neptune.
// © 2026 Neptune.Fintech (neptune.ly)
//
// Each framework maps to a template directory under ../templates and describes
// what the resulting starter supports (so prompts can offer only valid choices)
// plus the commands a developer runs next.

/** The four reference brand skins (demo themes — not real institutions). */
export const BRANDS = ["neptune", "triton", "nereid", "proteus"] as const;
export type Brand = (typeof BRANDS)[number];

export type FrameworkId =
  | "web"
  | "react"
  | "vue"
  | "svelte"
  | "react-native"
  | "flutter";

export type ModeOption = "light" | "dark" | "system";
export type DirOption = "ltr" | "rtl" | "auto";

export interface Framework {
  id: FrameworkId;
  /** Display label shown in the picker. */
  label: string;
  /** One-line description of the stack the starter ships. */
  blurb: string;
  /** Template directory name under packages/create-neptune/templates. */
  template: FrameworkId;
  /** The @neptune.fintech package the app is built around. */
  neptunePackage: string;
  /** Does the runtime support `mode: "system"` (web-class) vs explicit only. */
  supportsSystemMode: boolean;
  /** Does the runtime support `dir: "auto"` vs explicit ltr/rtl only. */
  supportsAutoDir: boolean;
  /** Install command shown in "next steps". */
  install: string;
  /** Dev command shown in "next steps". */
  dev: string;
}

export const FRAMEWORKS: Framework[] = [
  {
    id: "web",
    label: "Web (vanilla + Vite)",
    blurb: "TypeScript + Vite, Neptune web components, applyTheme().",
    template: "web",
    neptunePackage: "@neptune.fintech/web-ui",
    supportsSystemMode: true,
    supportsAutoDir: true,
    install: "npm install",
    dev: "npm run dev",
  },
  {
    id: "react",
    label: "React (Vite)",
    blurb: "React 18 + Vite, <NeptuneProvider> + typed Npt* components.",
    template: "react",
    neptunePackage: "@neptune.fintech/react-ui",
    supportsSystemMode: true,
    supportsAutoDir: true,
    install: "npm install",
    dev: "npm run dev",
  },
  {
    id: "vue",
    label: "Vue 3 (Vite)",
    blurb: "Vue 3 + Vite, <NeptuneProvider>, npt-* custom elements configured.",
    template: "vue",
    neptunePackage: "@neptune.fintech/vue-ui",
    supportsSystemMode: true,
    supportsAutoDir: true,
    install: "npm install",
    dev: "npm run dev",
  },
  {
    id: "svelte",
    label: "Svelte 5 (Vite)",
    blurb: "Svelte 5 + Vite, use:theme action, Neptune web components.",
    template: "svelte",
    neptunePackage: "@neptune.fintech/svelte-ui",
    supportsSystemMode: true,
    supportsAutoDir: true,
    install: "npm install",
    dev: "npm run dev",
  },
  {
    id: "react-native",
    label: "React Native (Expo)",
    blurb: "Expo + React Native, <NeptuneProvider> + Neptune* components.",
    template: "react-native",
    neptunePackage: "@neptune.fintech/react-native-ui",
    supportsSystemMode: false,
    supportsAutoDir: false,
    install: "npm install",
    dev: "npm run start",
  },
  {
    id: "flutter",
    label: "Flutter",
    blurb: "Flutter + Material 3, NeptuneTheme.light/dark, themed dashboard.",
    template: "flutter",
    neptunePackage: "neptune_flutter_ui",
    supportsSystemMode: true,
    supportsAutoDir: false,
    install: "flutter pub get",
    dev: "flutter run",
  },
];

export function frameworkById(id: string): Framework | undefined {
  return FRAMEWORKS.find((f) => f.id === id);
}

export function isBrand(v: string): v is Brand {
  return (BRANDS as readonly string[]).includes(v);
}
