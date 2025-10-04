<script lang="ts">
  /**
   * Layout Raiz
   * Inclui providers globais e componentes persistentes
   */
  
  import '../app.css';
  import ToastContainer from '$lib/components/feedback/ToastContainer.svelte';
  import { onMount } from 'svelte';
  import { theme } from '$lib/contexts/theme';
  
  // Inicializar tema
  onMount(() => {
    theme.init();
  });
</script>

<!-- Conteúdo das páginas -->
<slot />

<!-- Toast Container (global) -->
<ToastContainer /> 