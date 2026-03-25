<script lang="ts">
  /**
   * EmptyState — Clearix Lens Component Contract
   * flex flex-col items-center text-center py-12
   */
  import Button from './Button.svelte';
  import type { Snippet } from 'svelte';

  interface Props {
    icon?: string;
    title?: string;
    description?: string;
    actionLabel?: string;
    onaction?: () => void;
    children?: Snippet;
  }

  let {
    icon = '',
    title = 'Nenhum resultado encontrado',
    description = '',
    actionLabel = '',
    onaction,
    children
  }: Props = $props();
</script>

<div class="flex flex-col items-center justify-center text-center py-12 px-4">
  <!-- Icon -->
  {#if icon}
    <div class="text-6xl mb-4 opacity-50">
      {icon}
    </div>
  {/if}

  <!-- Title -->
  <h3 class="text-xl font-semibold text-foreground mb-2">
    {title}
  </h3>

  <!-- Description -->
  {#if description}
    <p class="text-sm text-muted-foreground max-w-md mb-6">
      {description}
    </p>
  {/if}

  <!-- Custom content -->
  {#if children}
    {@render children()}
  {/if}

  <!-- Action Button -->
  {#if actionLabel && onaction}
    <div class="mt-4">
      <Button variant="default" onclick={onaction}>
        {actionLabel}
      </Button>
    </div>
  {/if}
</div>
