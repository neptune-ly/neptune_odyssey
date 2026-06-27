<script lang="ts">
  import { theme } from "@neptune.fintech/svelte-ui";
  import type { ModeOption } from "@neptune.fintech/svelte-ui";
  import Dashboard from "./Dashboard.svelte";

  let mode: ModeOption = $state("{{MODE}}");
  function toggleMode() {
    mode = mode === "dark" ? "light" : "dark";
  }
</script>

<div class="neptune-provider" use:theme={{ input: "{{BRAND}}", mode, dir: "{{DIR}}" }}>
  <Dashboard {mode} {toggleMode} />
</div>
