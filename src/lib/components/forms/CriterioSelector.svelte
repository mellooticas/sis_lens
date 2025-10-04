<script lang="ts">
  /**
   * Seletor de Critério de Decisão
   * Urgência | Normal | Especial
   */
  
  import type { Criterio } from '$lib/types';
  
  export let selected: Criterio = 'NORMAL';
  
  const criterios: Array<{ value: Criterio; label: string; description: string; icon: string }> = [
    { 
      value: 'URGENCIA', 
      label: 'Urgência', 
      description: 'Prioriza prazo de entrega',
      icon: '⚡'
    },
    { 
      value: 'NORMAL', 
      label: 'Normal', 
      description: 'Equilíbrio preço/prazo',
      icon: '⚖️'
    },
    { 
      value: 'ESPECIAL', 
      label: 'Especial', 
      description: 'Prioriza qualidade',
      icon: '⭐'
    }
  ];
  
  function handleSelect(criterio: Criterio) {
    selected = criterio;
  }
</script>

<div class="criterio-selector">
  <label class="block text-sm font-medium text-neutral-700 mb-3">
    Critério de Decisão
  </label>
  
  <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
    {#each criterios as criterio}
      <button
        type="button"
        class="criterio-option"
        class:selected={selected === criterio.value}
        on:click={() => handleSelect(criterio.value)}
      >
        <div class="flex items-center gap-3 mb-2">
          <span class="text-2xl">{criterio.icon}</span>
          <div class="text-left">
            <div class="font-semibold">{criterio.label}</div>
            <div class="text-xs text-neutral-600">{criterio.description}</div>
          </div>
        </div>
        
        <div class="radio-indicator">
          {#if selected === criterio.value}
            <div class="radio-dot"></div>
          {/if}
        </div>
      </button>
    {/each}
  </div>
</div>

<style>
  .criterio-option {
    @apply relative p-4 rounded-lg border-2 transition-all duration-200;
    @apply bg-white border-neutral-200;
    @apply hover:border-brand-blue-300 hover:shadow-sm;
    @apply text-left;
  }
  
  .criterio-option.selected {
    @apply border-brand-blue-500 bg-brand-blue-50;
    @apply shadow-md;
  }
  
  .radio-indicator {
    @apply absolute top-3 right-3;
    @apply w-5 h-5 rounded-full border-2;
    @apply border-neutral-300;
    @apply flex items-center justify-center;
  }
  
  .criterio-option.selected .radio-indicator {
    @apply border-brand-blue-500;
  }
  
  .radio-dot {
    @apply w-3 h-3 rounded-full;
    @apply bg-brand-blue-500;
  }
</style>