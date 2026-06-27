// {{PROJECT_TITLE}} — Neptune Odyssey starter (React Native / Expo).
import { useState } from "react";
import { StatusBar } from "expo-status-bar";
import { NeptuneProvider } from "@neptune.fintech/react-native-ui";
import type { Mode } from "@neptune.fintech/react-native-ui";

import { Dashboard } from "./src/Dashboard";

export default function App() {
  const [mode, setMode] = useState<Mode>("{{MODE}}");
  const toggleMode = () => setMode((m) => (m === "dark" ? "light" : "dark"));

  return (
    <NeptuneProvider input="{{BRAND}}" mode={mode} dir="{{DIR}}">
      <Dashboard mode={mode} onToggleMode={toggleMode} />
      <StatusBar style={mode === "dark" ? "light" : "dark"} />
    </NeptuneProvider>
  );
}
