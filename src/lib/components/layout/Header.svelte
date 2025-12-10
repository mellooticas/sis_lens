<script lang="ts">
  /**
   * Header/Navbar BestLens (Modernized)
   * Top bar with actions and user menu
   */
  import { createEventDispatcher } from "svelte";
  import ThemeToggle from "$lib/components/ui/ThemeToggle.svelte";

  export let currentPage = "";
  export let collapsed = false;

  const dispatch = createEventDispatcher();

  function getPageTitle(path: string) {
    if (path === "/" || path === "/dashboard") return "Dashboard";
    if (path.startsWith("/buscar")) return "Buscar Lentes";
    if (path.startsWith("/ranking")) return "Ranking de Opções";
    if (path.startsWith("/historico")) return "Histórico de Decisões";
    if (path.startsWith("/config")) return "Configurações";
    if (path.startsWith("/analytics")) return "Analytics";
    return "SIS Lens";
  }

  $: pageTitle = getPageTitle(currentPage);
</script>

<header
  class="h-16 bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800 sticky top-0 z-30 transition-colors px-6 flex items-center justify-between"
>
  <!-- Left: Title & Toggle -->
  <div class="flex items-center gap-4">
    <button
      class="p-2 text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
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

    <!-- Discrete Welcome Message -->
    <div
      class="hidden sm:flex items-center gap-2 text-neutral-600 dark:text-neutral-400"
    >
      <span class="text-sm">Boas vindas, </span>
      <span class="text-sm font-semibold text-neutral-900 dark:text-neutral-200"
        >Junior Silva</span
      >
    </div>
  </div>

  <!-- Right: Actions -->
  <div class="flex items-center gap-3">
    <ThemeToggle size="md" />

    <div
      class="h-8 w-px bg-neutral-200 dark:bg-neutral-700 mx-2 hidden md:block"
    ></div>

    <button
      class="hidden md:flex items-center gap-2 px-3 py-2 text-sm font-medium text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
    >
      <span>🔔</span>
    </button>
  </div>
</header>
