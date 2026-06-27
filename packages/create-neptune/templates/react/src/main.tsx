// {{PROJECT_TITLE}} — Neptune Odyssey starter (React).
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { registerIcons } from "@neptune.fintech/icons";
import "@neptune.fintech/web-ui/styles.css";

import { App } from "./App";
import "./styles.css";

registerIcons(); // define <npt-icon> (NeptuneProvider registers the rest)

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
