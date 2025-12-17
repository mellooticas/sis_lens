<script lang="ts">
  /**
   * Layout Raiz
   * Inclui providers globais, layout sidebar e componentes persistentes
   */

  import "../app.css";
  import ToastContainer from "$lib/components/feedback/ToastContainer.svelte";
  import MainLayout from "$lib/components/layout/MainLayout.svelte";
  import { onMount } from "svelte";
  import { theme } from "$lib/stores/theme"; // Updated path
  import { contrastStore, colorThemeStore } from "$lib/stores/colorSystem";
  import { page } from "$app/stores";

  // Inicializar tema e sistema de cores
  onMount(() => {
    theme.init();
    contrastStore.init();
    colorThemeStore.init();
  });
</script>

<!-- Layout Principal (Sidebar + Header + Content) -->
{#if $page.url.pathname.startsWith("/login")}
  <slot />
{:else}
  <MainLayout currentPage={$page.url.pathname}>
    <slot />
  </MainLayout>
{/if}

<!-- Toast Container (global) -->
<ToastContainer />
