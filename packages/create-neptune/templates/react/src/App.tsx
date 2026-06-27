import { useState } from "react";
import { NeptuneProvider } from "@neptune.fintech/react-ui";
import type { ModeOption } from "@neptune.fintech/react-ui";

import { Dashboard } from "./Dashboard";

export function App() {
  const [mode, setMode] = useState<ModeOption>("{{MODE}}");
  const toggleMode = () => setMode((m) => (m === "dark" ? "light" : "dark"));

  return (
    <NeptuneProvider theme="{{BRAND}}" mode={mode} dir="{{DIR}}">
      <Dashboard mode={mode} onToggleMode={toggleMode} />
    </NeptuneProvider>
  );
}
