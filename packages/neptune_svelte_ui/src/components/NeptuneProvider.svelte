<!-- Neptune Odyssey — NeptuneProvider.svelte · © 2026 Neptune.Fintech (neptune.ly)
     Wraps a slot in a themed element using the `use:theme` action. Shipped as
     source and consumed via the package's `svelte` export condition. -->
<script lang="ts">
  import { theme } from "../theme.js";
  import type { ThemeInput, ModeOption, DirOption } from "../theme.js";

  // Svelte 5 runes
  let {
    input,
    mode = undefined,
    dir = undefined,
    children,
  }: {
    input: ThemeInput;
    mode?: ModeOption;
    dir?: DirOption;
    children?: import("svelte").Snippet;
  } = $props();
</script>

<div class="neptune-provider" use:theme={{ input, mode, dir }}>
  {@render children?.()}
</div>

<style>
  .neptune-provider {
    display: contents;
  }
</style>
