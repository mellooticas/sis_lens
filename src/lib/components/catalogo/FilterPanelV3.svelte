<script lang="ts">
  /**
   * FilterPanelV3 — Advanced filter panel para Premium/Standard
   */
  import { ChevronDown, ChevronUp, RotateCcw, Search } from 'lucide-svelte'
  import { slide } from 'svelte/transition'
  import type {
    PremiumFilterParamsV3,
    StandardFilterParamsV3,
    PremiumFilterOptions,
    StandardFilterOptions,
  } from '$lib/types/lentes'

  export let isPremium: boolean = false
  export let filters: PremiumFilterParamsV3 | StandardFilterParamsV3 = {}
  export let filterOptions: PremiumFilterOptions | StandardFilterOptions | null = null
  export let loading: boolean = false
  export let onApplyFilters: (filters: any) => void = () => {}
  export let onClearFilters: () => void = () => {}

  let expanded = false
  let searchText = ''

  $: premiumFilters = filters as PremiumFilterParamsV3
  $: standardFilters = filters as StandardFilterParamsV3
  $: premiumOpts = isPremium ? (filterOptions as PremiumFilterOptions) : null
  $: standardOpts = !isPremium ? (filterOptions as StandardFilterOptions) : null

  function countActiveFilters(): number {
    return Object.values(filters)
      .filter(v => v !== undefined && v !== null && (typeof v !== 'string' || v !== ''))
      .length
  }

  $: activeFilters = countActiveFilters()

  function handleApply() {
    onApplyFilters({ ...filters, ...(searchText ? { search: searchText } : {}) })
  }

  function handleClear() {
    filters = {}
    searchText = ''
    onClearFilters()
  }
</script>

<div class="bg-card border border-border rounded-2xl overflow-hidden">
  <!-- Header -->
  <button
    on:click={() => (expanded = !expanded)}
    class="w-full px-6 py-4 flex items-center justify-between hover:bg-muted/50 transition-colors"
  >
    <div class="flex items-center gap-3">
      <Search class="h-5 w-5 text-muted-foreground" />
      <h3 class="font-semibold font-heading text-foreground">Filtros Avançados</h3>
      {#if activeFilters > 0}
        <span class="px-2.5 py-0.5 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 text-xs font-bold rounded-full">
          {activeFilters}
        </span>
      {/if}
    </div>
    {#if expanded}
      <ChevronUp class="h-5 w-5 text-muted-foreground" />
    {:else}
      <ChevronDown class="h-5 w-5 text-muted-foreground" />
    {/if}
  </button>

  <!-- Content -->
  {#if expanded}
    <div class="border-t border-border px-6 py-4 space-y-4" transition:slide>
      <!-- Search -->
      <div>
        <label for="search-input" class="text-xs font-bold uppercase tracking-wide text-muted-foreground block mb-2">
          Buscar
        </label>
        <input
          id="search-input"
          type="text"
          bind:value={searchText}
          placeholder="Digite para buscar..."
          class="w-full px-3 py-2 bg-muted border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
      </div>

      {#if isPremium && premiumOpts}
        <!-- Premium Filters -->
        
        <!-- Brands -->
        {#if premiumOpts.brands?.length}
          <div>
            <label for="brand-select" class="text-xs font-bold uppercase tracking-wide text-muted-foreground block mb-2">
              Marcas ({premiumOpts.brands.length})
            </label>
            <select
              id="brand-select"
              bind:value={premiumFilters.brand}
              disabled={!premiumFilters}
              class="w-full px-3 py-2 bg-muted border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">— Todas —</option>
              {#each premiumOpts.brands as opt}
                <option value={opt.value}>{opt.value} ({opt.count})</option>
              {/each}
            </select>
          </div>
        {/if}

        <!-- Lens Types -->
        {#if premiumOpts.lens_types?.length}
          <div>
            <label for="lens-type-premium" class="text-xs font-bold uppercase tracking-wide text-muted-foreground block mb-2">
              Tipo de Lente ({premiumOpts.lens_types.length})
            </label>
            <select
              id="lens-type-premium"
              bind:value={premiumFilters.lens_type}
              disabled={!premiumFilters}
              class="w-full px-3 py-2 bg-muted border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">— Todos —</option>
              {#each premiumOpts.lens_types as opt}
                <option value={opt.value}>{opt.value} ({opt.count})</option>
              {/each}
            </select>
          </div>
        {/if}

        <!-- Materials -->
        {#if premiumOpts.materials?.length}
          <div>
            <label for="material-premium" class="text-xs font-bold uppercase tracking-wide text-muted-foreground block mb-2">
              Material ({premiumOpts.materials.length})
            </label>
            <select
              id="material-premium"
              bind:value={premiumFilters.material_id}
              disabled={!premiumFilters}
              class="w-full px-3 py-2 bg-muted border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">— Todos —</option>
              {#each premiumOpts.materials as opt}
                <option value={opt.id}>{opt.name} (n={opt.index}) {opt.count}</option>
              {/each}
            </select>
          </div>
        {/if}
      {:else if !isPremium && standardOpts}
        <!-- Standard Filters -->

        <!-- Lens Types -->
        {#if standardOpts.lens_types?.length}
          <div>
            <label for="lens-type-standard" class="text-xs font-bold uppercase tracking-wide text-muted-foreground block mb-2">
              Tipo de Lente ({standardOpts.lens_types.length})
            </label>
            <select
              id="lens-type-standard"
              bind:value={standardFilters.lens_type}
              disabled={!standardFilters}
              class="w-full px-3 py-2 bg-muted border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">— Todos —</option>
              {#each standardOpts.lens_types as opt}
                <option value={opt.value}>{opt.value} ({opt.count})</option>
              {/each}
            </select>
          </div>
        {/if}

        <!-- Materials -->
        {#if standardOpts.materials?.length}
          <div>
            <label for="material-standard" class="text-xs font-bold uppercase tracking-wide text-muted-foreground block mb-2">
              Material ({standardOpts.materials.length})
            </label>
            <select
              id="material-standard"
              bind:value={standardFilters.material_id}
              disabled={!standardFilters}
              class="w-full px-3 py-2 bg-muted border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">— Todos —</option>
              {#each standardOpts.materials as opt}
                <option value={opt.id}>{opt.name} (n={opt.index})</option>
              {/each}
            </select>
          </div>
        {/if}
      {/if}

      <!-- Action Buttons -->
      <div class="flex gap-3 pt-4 border-t border-border">
        <button
          on:click={handleApply}
          disabled={loading}
          class="flex-1 px-4 py-2 bg-primary-600 hover:bg-primary-700 disabled:opacity-50 text-white font-semibold rounded-lg transition-colors"
        >
          {loading ? 'Carregando...' : 'Aplicar Filtros'}
        </button>
        <button
          on:click={handleClear}
          class="px-4 py-2 border border-border hover:bg-muted rounded-lg text-foreground font-semibold transition-colors flex items-center gap-2"
        >
          <RotateCcw class="h-4 w-4" />
          Limpar
        </button>
      </div>
    </div>
  {/if}
</div>
