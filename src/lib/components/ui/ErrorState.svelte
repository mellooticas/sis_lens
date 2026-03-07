<script lang="ts">
  /**
   * ErrorState — SIS Lens Component Contract
   * Error state with retry action
   */
  import Button from './Button.svelte';
  import type { Snippet } from 'svelte';

  interface Props {
    title?: string;
    message?: string;
    showRetry?: boolean;
    onretry?: () => void;
    children?: Snippet;
  }

  let {
    title = 'Algo deu errado',
    message = 'Nao foi possivel carregar os dados. Tente novamente.',
    showRetry = true,
    onretry,
    children
  }: Props = $props();
</script>

<div class="flex flex-col items-center justify-center text-center py-12 px-4">
  <!-- Icon -->
  <div class="text-destructive mb-4">
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
  <h3 class="text-xl font-semibold text-foreground mb-2">
    {title}
  </h3>

  <!-- Message -->
  <p class="text-sm text-muted-foreground max-w-md mb-6">
    {message}
  </p>

  <!-- Custom content -->
  {#if children}
    {@render children()}
  {/if}

  <!-- Retry Button -->
  {#if showRetry && onretry}
    <div class="mt-4">
      <Button variant="default" onclick={onretry}>
        Tentar Novamente
      </Button>
    </div>
  {/if}
</div>
