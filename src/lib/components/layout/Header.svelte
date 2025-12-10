<script lang="ts">
  /**
   * Header/Navbar BestLens (Modernized & Disruptive)
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
        p-2.5 rounded-xl text-neutral-500 hover:text-brand-blue-600 dark:text-neutral-400 dark:hover:text-brand-blue-400
        hover:bg-brand-blue-50 dark:hover:bg-brand-blue-900/30
        transition-all duration-300 hover:scale-105 active:scale-95
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
          class="text-2xl font-bold font-mono text-brand-blue-600 dark:text-brand-blue-400"
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
        Bem-vindo ao BestLens Dashboard
      </span>
    </div>
  </div>

  <!-- Right: Actions -->
  <div class="flex items-center gap-4">
    <!-- Search Bar (Optional Visual) -->
    <div
      class="hidden md:flex items-center bg-neutral-100/50 dark:bg-neutral-800/50 rounded-full px-4 py-1.5 border border-transparent focus-within:border-brand-blue-300 dark:focus-within:border-brand-blue-700 transition-all"
    >
      <svg
        class="w-4 h-4 text-neutral-400"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        ><path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
        /></svg
      >
      <input
        type="text"
        placeholder="Busca rápida..."
        class="bg-transparent border-none text-sm w-32 focus:ring-0 text-neutral-600 dark:text-neutral-300 placeholder-neutral-400"
      />
    </div>

    <div
      class="h-6 w-px bg-neutral-200 dark:bg-neutral-700 hidden md:block"
    ></div>

    <ThemeToggle size="md" />

    <button
      aria-label="Notificações"
      class="
        relative p-2.5 rounded-xl text-neutral-500 hover:text-brand-orange-500 dark:text-neutral-400 dark:hover:text-brand-orange-400
        hover:bg-brand-orange-50 dark:hover:bg-brand-orange-900/30
        transition-all duration-300
      "
    >
      <span
        class="absolute top-2 right-2.5 w-2 h-2 bg-red-500 rounded-full ring-2 ring-white dark:ring-neutral-900 animate-pulse"
      ></span>
      <svg
        class="w-5 h-5"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
        />
      </svg>
    </button>
  </div>
</header>
