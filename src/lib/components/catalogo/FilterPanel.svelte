<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { Search, RotateCcw, DollarSign } from 'lucide-svelte';
  import Button from "$lib/components/ui/Button.svelte";

  export let filters: any = {};
  export let loading = false;
  export let totalResults = 0;

  const dispatch = createEventDispatcher();

  // Opções para os selects
  const types = [
    { value: 'visao_simples', label: 'Visão Simples' },
    { value: 'bifocal', label: 'Bifocal' },
    { value: 'multifocal', label: 'Multifocal' },
  ];

  const materials = [
    { value: 'CR39', label: 'CR-39' },
    { value: 'POLICARBONATO', label: 'Policarbonato' },
    { value: 'TRIVEX', label: 'Trivex' },
  ];

  const indices = [
    { value: '1.50', label: '1.50' },
    { value: '1.56', label: '1.56' },
    { value: '1.59', label: '1.59' },
    { value: '1.61', label: '1.61' },
    { value: '1.67', label: '1.67' },
    { value: '1.74', label: '1.74' },
  ];

  const priceRanges = [
    { value: 'all', label: 'Todos os preços' },
    { value: '0-300', label: 'Até R$ 300' },
    { value: '300-600', label: 'R$ 300 - 600' },
    { value: '600-1000', label: 'R$ 600 - 1.000' },
    { value: '1000+', label: 'Acima de R$ 1.000' },
  ];

  // Valores selecionados
  let selectedType = '';
  let selectedMaterial = '';
  let selectedIndex = '';
  let selectedPriceRange = 'all';
  let searchText = filters.busca || '';
  let hasAR = false;
  let hasBlue = false;
  let hasFoto = false;
  let hasPolar = false;

  // Aplicar filtros quando mudar
  function applyFilters() {
    const newFilters: any = { busca: searchText };
    
    if (selectedType) newFilters.tipos = [selectedType];
    if (selectedMaterial) newFilters.materiais = [selectedMaterial];
    if (selectedIndex) newFilters.indices = [selectedIndex];
    
    if (selectedPriceRange !== 'all') {
      if (selectedPriceRange === '1000+') {
        newFilters.preco = { min: 1000 };
      } else {
        const [min, max] = selectedPriceRange.split('-').map(Number);
        newFilters.preco = { min, max };
      }
    }
    
    // Tratamentos como filtros booleanos diretos
    const tratamentos: any = {};
    if (hasAR) tratamentos.ar = true;
    if (hasBlue) tratamentos.blue = true;
    if (hasPolar) tratamentos.polarizado = true;
    
    // Fotossensivel é um enum/string, não boolean
    // Quando marcado, busca por qualquer valor diferente de 'nenhum'
    if (hasFoto) tratamentos.fotossensivel = true; // API vai interpretar isso
    
    if (Object.keys(tratamentos).length > 0) {
      newFilters.tratamentos = tratamentos;
    }
    
    dispatch('change', newFilters);
  }

  function clearFilters() {
    selectedType = '';
    selectedMaterial = '';
    selectedIndex = '';
    selectedPriceRange = 'all';
    searchText = '';
    hasAR = false;
    hasBlue = false;
    hasFoto = false;
    hasPolar = false;
    dispatch('clear');
  }

  $: hasActiveFilters = selectedType || selectedMaterial || selectedIndex || selectedPriceRange !== 'all' || searchText || hasAR || hasBlue || hasFoto || hasPolar;

</script>

<div class="glass-panel rounded-xl p-6">
  
  <!-- Grid de Filtros Compactos -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    
    <!-- Busca Textual (Full Width em mobile) -->
    <div class="md:col-span-2 lg:col-span-4">
      <div class="relative">
        <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
        <input 
          type="text" 
          placeholder="Buscar por nome, marca ou código..." 
          class="w-full pl-10 pr-4 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-blue-500/20 focus:border-brand-blue-500 outline-none transition-all"
          bind:value={searchText}
          on:input={applyFilters}
        />
      </div>
    </div>

    <!-- Tipo de Lente -->
    <div>
      <label class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5">Tipo</label>
      <select 
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-blue-500/20 focus:border-brand-blue-500 outline-none transition-all cursor-pointer"
        bind:value={selectedType}
        on:change={applyFilters}
      >
        <option value="">Todos os tipos</option>
        {#each types as type}
          <option value={type.value}>{type.label}</option>
        {/each}
      </select>
    </div>

    <!-- Material -->
    <div>
      <label class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5">Material</label>
      <select 
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-blue-500/20 focus:border-brand-blue-500 outline-none transition-all cursor-pointer"
        bind:value={selectedMaterial}
        on:change={applyFilters}
      >
        <option value="">Todos os materiais</option>
        {#each materials as mat}
          <option value={mat.value}>{mat.label}</option>
        {/each}
      </select>
    </div>

    <!-- Índice -->
    <div>
      <label class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5">Índice</label>
      <select 
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-blue-500/20 focus:border-brand-blue-500 outline-none transition-all cursor-pointer"
        bind:value={selectedIndex}
        on:change={applyFilters}
      >
        <option value="">Todos os índices</option>
        {#each indices as idx}
          <option value={idx.value}>{idx.label}</option>
        {/each}
      </select>
    </div>

    <!-- Faixa de Preço -->
    <div>
      <label class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5">Preço</label>
      <select 
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-blue-500/20 focus:border-brand-blue-500 outline-none transition-all cursor-pointer"
        bind:value={selectedPriceRange}
        on:change={applyFilters}
      >
        {#each priceRanges as range}
          <option value={range.value}>{range.label}</option>
        {/each}
      </select>
    </div>

  </div>

  <!-- Tratamentos (Checkboxes Horizontais com Indicador Premium) -->
  <div class="border-t border-neutral-200 dark:border-neutral-700 pt-4">
    <label class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-3">Tratamentos</label>
    <div class="flex flex-wrap gap-3">
      
      <!-- Antirreflexo (Standard + Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input 
          type="checkbox" 
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-brand-blue-600 focus:ring-2 focus:ring-brand-blue-500/20 transition-all cursor-pointer"
          bind:checked={hasAR}
          on:change={applyFilters}
        />
        <span class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-brand-blue-600 dark:group-hover:text-brand-blue-400 transition-colors">💨 Antirreflexo</span>
        <span class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400">620</span>
      </label>

      <!-- Blue Light (Standard + Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input 
          type="checkbox" 
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-brand-blue-600 focus:ring-2 focus:ring-brand-blue-500/20 transition-all cursor-pointer"
          bind:checked={hasBlue}
          on:change={applyFilters}
        />
        <span class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-brand-blue-600 dark:group-hover:text-brand-blue-400 transition-colors">🔵 Blue Light</span>
        <span class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400">466</span>
      </label>

      <!-- Fotossensível (Transitions + Acclimates = Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input 
          type="checkbox" 
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-brand-blue-600 focus:ring-2 focus:ring-brand-blue-500/20 transition-all cursor-pointer"
          bind:checked={hasFoto}
          on:change={applyFilters}
        />
        <span class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-brand-blue-600 dark:group-hover:text-brand-blue-400 transition-colors">📷 Fotossensível</span>
        <span class="text-xs px-1.5 py-0.5 rounded-full bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 font-semibold">🔒 PREMIUM</span>
        <span class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400">382</span>
      </label>

      <!-- Polarizado (Standard + Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input 
          type="checkbox" 
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-brand-blue-600 focus:ring-2 focus:ring-brand-blue-500/20 transition-all cursor-pointer"
          bind:checked={hasPolar}
          on:change={applyFilters}
        />
        <span class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-brand-blue-600 dark:group-hover:text-brand-blue-400 transition-colors">😎 Polarizado</span>
        <span class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400">60</span>
      </label>

    </div>

    <!-- Legenda de Tipos -->
    <div class="mt-3 flex items-center gap-4 text-xs text-neutral-600 dark:text-neutral-400">
      <span>💨 = Standard</span>
      <span>🔒 = Premium</span>
    </div>
  </div>

  <!-- Footer com info e botão limpar -->
  <div class="flex items-center justify-between mt-6 pt-4 border-t border-neutral-200 dark:border-neutral-700">
    <div class="text-sm text-neutral-600 dark:text-neutral-400">
      <span class="font-semibold text-brand-blue-600 dark:text-brand-blue-400">{loading ? '...' : totalResults}</span> lentes encontradas
    </div>
    {#if hasActiveFilters}
      <Button 
        variant="outline" 
        size="sm"
        on:click={clearFilters}
      >
        <RotateCcw class="w-3.5 h-3.5 mr-1.5" />
        Limpar Filtros
      </Button>
    {/if}
  </div>

</div>
