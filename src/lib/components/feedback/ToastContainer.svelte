<script lang="ts">
  /**
   * ToastContainer — Manages multiple toast notifications
   */
  import { toast } from '$lib/stores/toast';
  import Toast from './Toast.svelte';
</script>

<div class="fixed bottom-4 right-4 z-50 flex flex-col gap-3 pointer-events-none max-sm:left-4">
  {#each $toast as toastItem (toastItem.id)}
    <div class="pointer-events-auto">
      <Toast
        message={toastItem.message}
        type={toastItem.type}
        duration={toastItem.duration}
        show={true}
        onClose={() => toast.remove(toastItem.id)}
      />
    </div>
  {/each}
</div>
