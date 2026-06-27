// {{PROJECT_TITLE}} — Neptune Odyssey starter (Vue 3).
import { createApp } from "vue";
import { registerIcons } from "@neptune.fintech/icons";
import "@neptune.fintech/web-ui/styles.css";

import App from "./App.vue";
import "./styles.css";

registerIcons(); // define <npt-icon> (NeptuneProvider registers the rest)

createApp(App).mount("#app");
