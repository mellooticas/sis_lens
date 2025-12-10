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
  import { page } from "$app/stores";

  // Inicializar tema
  onMount(() => {
    theme.init();
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
