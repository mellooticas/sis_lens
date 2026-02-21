<script lang="ts">
  /**
   * Header/Navbar SIS Lens (Modernized & Disruptive)
   * Floating Glass Design
   */
  import { createEventDispatcher } from "svelte";
  import ThemeToggle from "$lib/components/ui/ThemeToggle.svelte";
  import { fade } from "svelte/transition";

  import { onMount } from "svelte";

  export let collapsed = false;

  const dispatch = createEventDispatcher();

  // Time based greeting
  let currentTime = new Date();

  onMount(() => {
    const interval = setInterval(() => {
      currentTime = new Date();
    }, 1000); // Update every second for accurate clock

    return () => clearInterval(interval);
  });

  $: hour = currentTime.getHours();
  $: greeting =
    hour < 12 ? "🌅 Bom dia" : hour < 18 ? "☀️ Boa tarde" : "🌙 Boa noite";
</script>

<header
  class="
    sticky top-4 z-40 mx-6 mt-4 rounded-2xl
    glass-panel border-white/40 dark:border-white/10
    transition-all duration-300
    flex items-center justify-between px-6 py-3
  "
>
  <!-- Left: Title & Toggle -->
  <div class="flex items-center gap-4">
    <button
      class="
        p-2.5 rounded-xl text-neutral-500 hover:text-primary-600 dark:text-neutral-400 dark:hover:text-primary-400
        hover:bg-primary-50 dark:hover:bg-primary-900/30
        transition-all duration-200
      "
      on:click={() => dispatch("menuClick")}
      title={collapsed ? "Expandir menu" : "Recolher menu"}
    >
      <svg
        class="w-6 h-6"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        {#if collapsed}
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 5l7 7-7 7M5 5l7 7-7 7"
          />
        {:else}
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 6h16M4 12h16M4 18h7"
          />
        {/if}
      </svg>
    </button>

    <div class="hidden sm:flex flex-col" in:fade>
      <div class="flex items-baseline gap-2">
        <span
          class="text-2xl font-bold font-mono text-primary-600 dark:text-primary-400"
        >
          {currentTime.toLocaleTimeString("pt-BR", {
            hour: "2-digit",
            minute: "2-digit",
          })}
        </span>
        <h1
          class="text-lg font-bold text-neutral-800 dark:text-white leading-tight"
        >
          {greeting} 👋
        </h1>
      </div>
      <span class="text-xs font-medium text-neutral-500 dark:text-neutral-400">
        Bem-vindo ao SIS Lens Dashboard
      </span>
    </div>
  </div>

  <!-- Right: Actions -->
  <div class="flex items-center gap-3">
    <ThemeToggle size="md" />
  </div>
</header>

