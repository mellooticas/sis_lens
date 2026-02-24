 <script lang="ts">
  /**
   * SectionHeader - Cabeçalho de seção com título e ação opcional
   * Usado no topo de cada seção da página
   */
  
  import Button from '$lib/components/ui/Button.svelte';
  import { createEventDispatcher } from 'svelte';
  
  export let title = '';
  export let subtitle = '';
  export let actionLabel = '';
  export let actionVariant: 'primary' | 'secondary' | 'ghost' = 'secondary';
  export let actionSize: 'sm' | 'md' | 'lg' = 'sm';
  
  const dispatch = createEventDispatcher();
  
  function handleAction() {
    dispatch('action');
  }
</script>

<div class="flex items-center justify-between gap-4 mb-6">
  <div class="flex-1">
    <h2 class="text-2xl font-bold text-neutral-900 dark:text-neutral-100">
      {title}
    </h2>
    {#if subtitle}
      <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-1">
        {subtitle}
      </p>
    {/if}
  </div>
  
  <div class="flex items-center gap-2">
    <slot name="actions" />
    {#if actionLabel}
      <Button
        variant={actionVariant}
        size={actionSize}
        on:click={handleAction}
      >
        {actionLabel}
      </Button>
    {/if}
  </div>
</div>