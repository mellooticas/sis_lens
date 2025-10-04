<script lang="ts">
  /**
   * ToastContainer - Gerenciador de múltiplos toasts
   */
  
  import { toast } from '$lib/stores/toast';
  import Toast from './Toast.svelte';
</script>

<div class="toast-container-wrapper">
  {#each $toast as toastItem (toastItem.id)}
    <Toast
      message={toastItem.message}
      type={toastItem.type}
      duration={toastItem.duration}
      show={true}
      onClose={() => toast.remove(toastItem.id)}
    />
  {/each}
</div>

<style>
  .toast-container-wrapper {
    @apply fixed bottom-4 right-4 z-50;
    @apply flex flex-col gap-3;
    @apply pointer-events-none;
  }
  
  .toast-container-wrapper :global(.toast-container) {
    @apply pointer-events-auto;
  }
  
  @media (max-width: 640px) {
    .toast-container-wrapper {
      @apply left-4 right-4;
    }
  }
</style>