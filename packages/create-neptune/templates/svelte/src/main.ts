// {{PROJECT_TITLE}} — Neptune Odyssey starter (Svelte 5).
import { mount } from "svelte";
import { registerIcons } from "@neptune.fintech/icons";
import "@neptune.fintech/web-ui/styles.css";

import App from "./App.svelte";
import "./styles.css";

registerIcons(); // define <npt-icon> (the theme action registers the rest)

const app = mount(App, { target: document.getElementById("app")! });

export default app;
