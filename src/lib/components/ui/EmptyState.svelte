<script lang="ts">
  /**
   * EmptyState Component
   * Estado vazio com ícone e mensagem
   */
  
  import Button from './Button.svelte';
  
  export let icon = '📭';
  export let title = 'Nenhum resultado encontrado';
  export let description = '';
  export let actionLabel = '';
  export let onAction: (() => void) | undefined = undefined;
</script>

<div class="empty-state">
  <!-- Icon -->
  <div class="empty-icon">
    {icon}
  </div>
  
  <!-- Title -->
  <h3 class="empty-title">
    {title}
  </h3>
  
  <!-- Description -->
  {#if description}
    <p class="empty-description">
      {description}
    </p>
  {/if}
  
  <!-- Slot para conteúdo customizado -->
  <slot />
  
  <!-- Action Button -->
  {#if actionLabel && onAction}
    <div class="empty-action">
      <Button variant="primary" on:click={onAction}>
        {actionLabel}
      </Button>
    </div>
  {/if}
</div>

<style>
  .empty-state {
    @apply flex flex-col items-center justify-center;
    @apply text-center;
    @apply py-12 px-4;
  }
  
  .empty-icon {
    @apply text-6xl mb-4;
    @apply opacity-50;
  }
  
  .empty-title {
    @apply text-xl font-semibold;
    @apply text-neutral-900 dark:text-neutral-100;
    @apply mb-2;
  }
  
  .empty-description {
    @apply text-sm text-neutral-600 dark:text-neutral-400;
    @apply max-w-md mb-6;
  }
  
  .empty-action {
    @apply mt-4;
  }
</style>