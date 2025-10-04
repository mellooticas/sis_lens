<script lang="ts">
  /**
   * ErrorState Component
   * Estado de erro com opção de retry
   */
  
  import Button from './Button.svelte';
  
  export let title = 'Algo deu errado';
  export let message = 'Não foi possível carregar os dados. Tente novamente.';
  export let showRetry = true;
  export let onRetry: (() => void) | undefined = undefined;
</script>

<div class="error-state">
  <!-- Icon -->
  <div class="error-icon">
    <svg width="64" height="64" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path 
        stroke-linecap="round" 
        stroke-linejoin="round" 
        stroke-width="2" 
        d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" 
      />
    </svg>
  </div>
  
  <!-- Title -->
  <h3 class="error-title">
    {title}
  </h3>
  
  <!-- Message -->
  <p class="error-message">
    {message}
  </p>
  
  <!-- Slot para conteúdo adicional -->
  <slot />
  
  <!-- Retry Button -->
  {#if showRetry && onRetry}
    <div class="error-action">
      <Button variant="primary" on:click={onRetry}>
        🔄 Tentar Novamente
      </Button>
    </div>
  {/if}
</div>

<style>
  .error-state {
    @apply flex flex-col items-center justify-center;
    @apply text-center;
    @apply py-12 px-4;
  }
  
  .error-icon {
    @apply text-error mb-4;
  }
  
  .error-title {
    @apply text-xl font-semibold;
    @apply text-neutral-900 dark:text-neutral-100;
    @apply mb-2;
  }
  
  .error-message {
    @apply text-sm text-neutral-600 dark:text-neutral-400;
    @apply max-w-md mb-6;
  }
  
  .error-action {
    @apply mt-4;
  }
</style>