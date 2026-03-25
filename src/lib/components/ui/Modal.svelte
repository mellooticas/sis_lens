<script lang="ts">
  /**
   * Modal — Clearix Lens Component Contract
   * Overlay: bg-black/50 fixed inset-0 z-50
   * Content: bg-background rounded-lg shadow-lg p-6
   * Transitions: fade + scale
   */
  import { fade, scale } from 'svelte/transition';
  import type { Snippet } from 'svelte';

  interface Props {
    open?: boolean;
    title?: string;
    size?: 'sm' | 'md' | 'lg' | 'xl';
    showClose?: boolean;
    closeOnBackdrop?: boolean;
    closeOnEscape?: boolean;
    onclose?: () => void;
    children?: Snippet;
    footer?: Snippet;
  }

  let {
    open = $bindable(false),
    title = '',
    size = 'md',
    showClose = true,
    closeOnBackdrop = true,
    closeOnEscape = true,
    onclose,
    children,
    footer
  }: Props = $props();

  const sizes: Record<string, string> = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl'
  };

  function handleClose() {
    open = false;
    onclose?.();
  }

  function handleBackdropClick(e: MouseEvent) {
    if (closeOnBackdrop && e.target === e.currentTarget) {
      handleClose();
    }
  }

  function handleKeydown(e: KeyboardEvent) {
    if (closeOnEscape && e.key === 'Escape' && open) {
      handleClose();
    }
  }

  $effect(() => {
    if (open) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }

    return () => {
      document.body.style.overflow = '';
    };
  });
</script>

<svelte:window onkeydown={handleKeydown} />

{#if open}
  <!-- Overlay -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div
    class="bg-black/50 fixed inset-0 z-50 flex items-center justify-center p-4"
    transition:fade={{ duration: 200 }}
    onclick={handleBackdropClick}
    onkeydown={handleKeydown}
    role="presentation"
  >
    <!-- Content -->
    <div
      class="relative w-full {sizes[size]} bg-background rounded-lg shadow-lg max-h-[90vh] overflow-hidden flex flex-col"
      transition:scale={{ duration: 200, start: 0.95 }}
      role="dialog"
      aria-modal="true"
      aria-labelledby={title ? 'modal-title' : undefined}
    >
      <!-- Header -->
      {#if title || showClose}
        <div class="flex items-center justify-between px-6 py-4 border-b border-border">
          {#if title}
            <h3 id="modal-title" class="text-xl font-bold text-foreground">
              {title}
            </h3>
          {/if}

          {#if showClose}
            <button
              onclick={handleClose}
              class="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
              aria-label="Fechar modal"
            >
              <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          {/if}
        </div>
      {/if}

      <!-- Body -->
      <div class="p-6 overflow-y-auto text-foreground">
        {#if children}
          {@render children()}
        {/if}
      </div>

      <!-- Footer -->
      {#if footer}
        <div class="px-6 py-4 border-t border-border flex items-center justify-end gap-3">
          {@render footer()}
        </div>
      {/if}
    </div>
  </div>
{/if}
