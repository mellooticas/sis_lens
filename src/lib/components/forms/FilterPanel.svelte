<script lang="ts">
  /**
   * FilterPanel Component
   * Painel de filtros avançados
   */
  
  import { createEventDispatcher } from 'svelte';
  import Select from './Select.svelte';
  import Checkbox from './Checkbox.svelte';
  import Button from '$lib/components/ui/Button.svelte';
  import Badge from '$lib/components/ui/Badge.svelte';
  
  export let filters = {
    regiao: '',
    prazoMaximo: '',
    precoMaximo: '',
    scoreMinimo: '',
    marcas: [] as string[],
    tratamentos: [] as string[]
  };
  
  export let collapsed = false;
  
  const dispatch = createEventDispatcher();
  
  const regioes = [
    { value: '', label: 'Todas as regiões' },
    { value: 'sul', label: 'Sul' },
    { value: 'sudeste', label: 'Sudeste' },
    { value: 'centro-oeste', label: 'Centro-Oeste' },
    { value: 'nordeste', label: 'Nordeste' },
    { value: 'norte', label: 'Norte' }
  ];
  
  const prazosMaximos = [
    { value: '', label: 'Qualquer prazo' },
    { value: '3', label: 'Até 3 dias' },
    { value: '5', label: 'Até 5 dias' },
    { value: '7', label: 'Até 7 dias' },
    { value: '10', label: 'Até 10 dias' },
    { value: '15', label: 'Até 15 dias' }
  ];
  
  const precosMaximos = [
    { value: '', label: 'Qualquer preço' },
    { value: '200', label: 'Até R$ 200' },
    { value: '300', label: 'Até R$ 300' },
    { value: '400', label: 'Até R$ 400' },
    { value: '500', label: 'Até R$ 500' }
  ];
  
  const scoresMinimos = [
    { value: '', label: 'Qualquer qualidade' },
    { value: '7', label: 'Mínimo 7.0' },
    { value: '8', label: 'Mínimo 8.0' },
    { value: '9', label: 'Mínimo 9.0' }
  ];
  
  const marcasDisponiveis = [
    'Essilor', 'Hoya', 'Zeiss', 'Rodenstock', 'Kodak'
  ];
  
  const tratamentosDisponiveis = [
    'HC (Anti-risco)',
    'AR (Anti-reflexo)',
    'Blue Light',
    'Transitions',
    'Polarizado'
  ];
  
  $: activeFiltersCount = Object.values(filters).filter(v => 
    Array.isArray(v) ? v.length > 0 : v !== ''
  ).length;
  
  function handleApply() {
    dispatch('apply', filters);
  }
  
  function handleClear() {
    filters = {
      regiao: '',
      prazoMaximo: '',
      precoMaximo: '',
      scoreMinimo: '',
      marcas: [],
      tratamentos: []
    };
    dispatch('clear');
  }
  
  function toggleMarca(marca: string) {
    if (filters.marcas.includes(marca)) {
      filters.marcas = filters.marcas.filter(m => m !== marca);
    } else {
      filters.marcas = [...filters.marcas, marca];
    }
  }
  
  function toggleTratamento(tratamento: string) {
    if (filters.tratamentos.includes(tratamento)) {
      filters.tratamentos = filters.tratamentos.filter(t => t !== tratamento);
    } else {
      filters.tratamentos = [...filters.tratamentos, tratamento];
    }
  }
</script>

<div class="filter-panel" class:collapsed>
  <!-- Header -->
  <div class="filter-header">
    <div class="flex items-center gap-2">
      <h3 class="filter-title">Filtros Avançados</h3>
      {#if activeFiltersCount > 0}
        <Badge variant="primary">{activeFiltersCount}</Badge>
      {/if}
    </div>
    
    <button
      class="toggle-btn"
      on:click={() => collapsed = !collapsed}
      aria-label={collapsed ? 'Expandir filtros' : 'Recolher filtros'}
    >
      <svg 
        width="20" 
        height="20" 
        fill="none" 
        stroke="currentColor" 
        viewBox="0 0 24 24"
        class:rotate-180={!collapsed}
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>
  </div>
  
  <!-- Content -->
  {#if !collapsed}
    <div class="filter-content">
      <!-- Row 1: Selects -->
      <div class="filter-row">
        <div class="filter-field">
          <label class="field-label">Região de Entrega</label>
          <Select
            bind:value={filters.regiao}
            options={regioes}
            placeholder="Selecione..."
          />
        </div>
        
        <div class="filter-field">
          <label class="field-label">Prazo Máximo</label>
          <Select
            bind:value={filters.prazoMaximo}
            options={prazosMaximos}
            placeholder="Selecione..."
          />
        </div>
        
        <div class="filter-field">
          <label class="field-label">Preço Máximo</label>
          <Select
            bind:value={filters.precoMaximo}
            options={precosMaximos}
            placeholder="Selecione..."
          />
        </div>
        
        <div class="filter-field">
          <label class="field-label">Score Mínimo</label>
          <Select
            bind:value={filters.scoreMinimo}
            options={scoresMinimos}
            placeholder="Selecione..."
          />
        </div>
      </div>
      
      <!-- Row 2: Marcas -->
      <div class="filter-group">
        <label class="field-label">Marcas</label>
        <div class="checkbox-grid">
          {#each marcasDisponiveis as marca}
            <Checkbox
              checked={filters.marcas?.includes(marca) || false}
              label={marca}
              on:change={() => toggleMarca(marca)}
            />
          {/each}
        </div>
      </div>
      
      <!-- Row 3: Tratamentos -->
      <div class="filter-group">
        <label class="field-label">Tratamentos</label>
        <div class="checkbox-grid">
          {#each tratamentosDisponiveis as tratamento}
            <Checkbox
              checked={filters.tratamentos?.includes(tratamento) || false}
              label={tratamento}
              on:change={() => toggleTratamento(tratamento)}
            />
          {/each}
        </div>
      </div>
      
      <!-- Actions -->
      <div class="filter-actions">
        <Button variant="secondary" on:click={handleClear}>
          Limpar Filtros
        </Button>
        <Button variant="primary" on:click={handleApply}>
          Aplicar Filtros
        </Button>
      </div>
    </div>
  {/if}
</div>

<style>
  .filter-panel {
    @apply bg-white dark:bg-neutral-800;
    @apply border border-neutral-200 dark:border-neutral-700;
    @apply rounded-xl;
    @apply transition-all duration-200;
  }
  
  .filter-header {
    @apply flex items-center justify-between;
    @apply px-6 py-4;
    @apply border-b border-neutral-200 dark:border-neutral-700;
  }
  
  .filter-title {
    @apply text-lg font-semibold;
    @apply text-neutral-900 dark:text-neutral-100;
  }
  
  .toggle-btn {
    @apply p-2 rounded-lg;
    @apply text-neutral-600 dark:text-neutral-400;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-700;
    @apply transition-all duration-200;
  }
  
  .toggle-btn svg {
    @apply transition-transform duration-200;
  }
  
  .filter-content {
    @apply px-6 py-4 space-y-6;
  }
  
  .filter-row {
    @apply grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4;
  }
  
  .filter-field {
    @apply space-y-2;
  }
  
  .filter-group {
    @apply space-y-3;
  }
  
  .field-label {
    @apply block text-sm font-medium;
    @apply text-neutral-700 dark:text-neutral-300;
  }
  
  .checkbox-grid {
    @apply grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3;
  }
  
  .filter-actions {
    @apply flex items-center justify-end gap-3;
    @apply pt-4 border-t border-neutral-200 dark:border-neutral-700;
  }
  
  .filter-panel.collapsed .filter-header {
    @apply border-b-0;
  }
</style>