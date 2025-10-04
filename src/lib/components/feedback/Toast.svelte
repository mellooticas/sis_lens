<script lang="ts">
  /**
   * Toast - Notificações flutuantes
   */
  
  import { fade, fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  
  export let message = '';
  export let type: 'success' | 'error' | 'warning' | 'info' = 'success';
  export let duration = 3000; // ms
  export let show = false;
  export let onClose: (() => void) | undefined = undefined;
  
  let timeoutId: ReturnType<typeof setTimeout>;
  
  $: if (show && duration > 0) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      handleClose();
    }, duration);
  }
  
  function handleClose() {
    show = false;
    if (onClose) onClose();
  }
  
  const variants = {
    success: {
      bg: 'bg-success',
      icon: '✓',
      text: 'text-white'
    },
    error: {
      bg: 'bg-error',
      icon: '✕',
      text: 'text-white'
    },
    warning: {
      bg: 'bg-warning',
      icon: '⚠',
      text: 'text-white'
    },
    info: {
      bg: 'bg-info',
      icon: 'ℹ',
      text: 'text-white'
    }
  };
  
  $: variant = variants[type];
</script>

{#if show}
  <div
    class="toast-container"
    transition:fly={{ y: 50, duration: 300 }}
  >
    <div class="toast {variant.bg} {variant.text}">
      <div class="flex items-center gap-3">
        <!-- Ícone -->
        <div class="flex-shrink-0 w-6 h-6 flex items-center justify-center rounded-full bg-white/20">
          <span class="text-lg font-bold">{variant.icon}</span>
        </div>
        
        <!-- Mensagem -->
        <div class="flex-1">
          <p class="font-medium">{message}</p>
        </div>
        
        <!-- Botão Fechar -->
        <button
          on:click={handleClose}
          class="flex-shrink-0 p-1 hover:bg-white/20 rounded transition-colors"
          aria-label="Fechar notificação"
        >
          <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  .toast-container {
    @apply fixed bottom-4 right-4 z-50;
    @apply max-w-md;
  }
  
  .toast {
    @apply px-6 py-4 rounded-lg shadow-lg;
    @apply backdrop-blur-sm;
  }
  
  @media (max-width: 640px) {
    .toast-container {
      @apply left-4 right-4 bottom-4;
      @apply max-w-none;
    }
  }
</style>