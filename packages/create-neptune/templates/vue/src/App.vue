<script setup lang="ts">
import { ref } from "vue";
import { NeptuneProvider } from "@neptune.fintech/vue-ui";
import type { ModeOption } from "@neptune.fintech/vue-ui";

import Dashboard from "./Dashboard.vue";

const mode = ref<ModeOption>("{{MODE}}");
function toggleMode() {
  mode.value = mode.value === "dark" ? "light" : "dark";
}
</script>

<template>
  <NeptuneProvider theme="{{BRAND}}" :mode="mode" dir="{{DIR}}">
    <Dashboard :mode="mode" @toggle-mode="toggleMode" />
  </NeptuneProvider>
</template>
