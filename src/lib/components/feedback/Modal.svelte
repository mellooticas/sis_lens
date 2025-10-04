<script lang="ts">
  /**
   * Modal - Dialog genérico
   */
  
  import { fade, scale } from 'svelte/transition';
  import { createEventDispatcher, onMount } from 'svelte';
  import Button from '$lib/components/ui/Button.svelte';
  
  export let open = false;
  export let title = '';
  export let size: 'sm' | 'md' | 'lg' | 'xl' = 'md';
  export let showClose = true;
  export let closeOnBackdrop = true;
  export let closeOnEscape = true;
  
  const dispatch = createEventDispatcher();
  
  const sizes = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl'
  };
  
  function handleClose() {
    open = false;
    dispatch('close');
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
  
  $: if (open) {
    // Prevenir scroll do body quando modal aberto
    document.body.style.overflow = 'hidden';
  } else {
    document.body.style.overflow = '';
  }
</script>

<svelte:window on:keydown={handleKeydown} />

{#if open}
  <!-- Backdrop -->
  <div
    class="modal-backdrop"
    transition:fade={{ duration: 200 }}
    on:click={handleBackdropClick}
    on:keydown={handleKeydown}
    role="presentation"
  >
    <!-- Modal -->
    <div
      class="modal {sizes[size]}"
      transition:scale={{ duration: 200, start: 0.95 }}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <!-- Header -->
      {#if title || showClose}
        <div class="modal-header">
          {#if title}
            <h3 id="modal-title" class="modal-title">
              {title}
            </h3>
          {/if}
          
          {#if showClose}
            <button
              on:click={handleClose}
              class="modal-close"
              aria-label="Fechar modal"
            >
              <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          {/if}
        </div>
      {/if}
      
      <!-- Content -->
      <div class="modal-content">
        <slot />
      </div>
      
      <!-- Footer (opcional) -->
      {#if $$slots.footer}
        <div class="modal-footer">
          <slot name="footer" />
        </div>
      {/if}
    </div>
  </div>
{/if}

<style>
  .modal-backdrop {
    @apply fixed inset-0 z-40;
    @apply bg-black/50 backdrop-blur-sm;
    @apply flex items-center justify-center;
    @apply p-4;
  }
  
  .modal {
    @apply relative w-full;
    @apply bg-white dark:bg-neutral-800;
    @apply rounded-xl shadow-elevated;
    @apply max-h-[90vh] overflow-hidden;
    @apply flex flex-col;
  }
  
  .modal-header {
    @apply flex items-center justify-between;
    @apply px-6 py-4;
    @apply border-b border-neutral-200 dark:border-neutral-700;
  }
  
  .modal-title {
    @apply text-xl font-bold;
    @apply text-neutral-900 dark:text-neutral-100;
  }
  
  .modal-close {
    @apply p-2 rounded-lg;
    @apply text-neutral-500 hover:text-neutral-700;
    @apply dark:text-neutral-400 dark:hover:text-neutral-200;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-700;
    @apply transition-colors;
  }
  
  .modal-content {
    @apply px-6 py-4;
    @apply overflow-y-auto;
    @apply text-neutral-700 dark:text-neutral-300;
  }
  
  .modal-footer {
    @apply px-6 py-4;
    @apply border-t border-neutral-200 dark:border-neutral-700;
    @apply flex items-center justify-end gap-3;
  }
</style>