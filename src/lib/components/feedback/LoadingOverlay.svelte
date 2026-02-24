<script lang="ts">
  /**
   * LoadingOverlay - Loading fullscreen
   */
  
  import { fade } from 'svelte/transition';
  import Logo from '$lib/components/layout/Logo.svelte';
  
  export let show = false;
  export let message = 'Carregando...';
  export let showLogo = true;
</script>

{#if show}
  <div
    class="loading-overlay"
    transition:fade={{ duration: 200 }}
  >
    <div class="loading-content">
      {#if showLogo}
        <div class="mb-6 animate-pulse">
          <Logo size="lg" />
        </div>
      {/if}
      
      <!-- Spinner -->
      <div class="flex justify-center mb-4">
        <div class="spinner"></div>
      </div>
      
      <!-- Mensagem -->
      {#if message}
        <p class="text-neutral-700 dark:text-neutral-300 text-lg">
          {message}
        </p>
      {/if}
    </div>
  </div>
{/if}

<style>
  .loading-overlay {
    @apply fixed inset-0 z-50;
    @apply bg-white/80 dark:bg-neutral-900/80;
    @apply backdrop-blur-sm;
    @apply flex items-center justify-center;
  }
  
  .loading-content {
    @apply text-center;
  }
  
  .spinner {
    @apply w-12 h-12;
    @apply border-4 border-neutral-200 dark:border-neutral-700;
    @apply border-t-primary-500;
    @apply rounded-full;
    @apply animate-spin;
  }
</style>