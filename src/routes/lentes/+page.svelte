<script lang="ts">
  /**
   * +page.svelte — Catálogo de Lentes Canônicas
   * Premium | Standard com filtros avançados (v3)
   */
  import { onMount } from 'svelte'
  import { Crown, Sparkles } from 'lucide-svelte'
  import Container from '$lib/components/layout/Container.svelte'
  import TabSelector from '$lib/components/catalogo/TabSelector.svelte'
  import FilterPanelV3 from '$lib/components/catalogo/FilterPanelV3.svelte'
  import LensGrid from '$lib/components/catalogo/LensGrid.svelte'
  import {
    usePremiumFilterOptionsV3,
    usePremiumSearchV3,
    useStandardFilterOptionsV3,
    useStandardSearchV3,
  } from '$lib/hooks/useLentesCatalogo'
  import type {
    PremiumFilterParamsV3,
    PremiumSearchParamsV3,
    StandardFilterParamsV3,
    StandardSearchParamsV3,
  } from '$lib/types/lentes'

  let activeTab: 'premium' | 'standard' = 'premium'
  let premiumFilters: PremiumFilterParamsV3 = {}
  let standardFilters: StandardFilterParamsV3 = {}
  let currentPage = 1
  let itemsPerPage = 24

  // Premium hooks
  $: premiumSearchParams: PremiumSearchParamsV3 = {
    ...premiumFilters,
    limit: itemsPerPage,
    offset: (currentPage - 1) * itemsPerPage,
  }

  const premiumFilterOpts = usePremiumFilterOptionsV3(premiumFilters)
  const premiumResults = usePremiumSearchV3(premiumSearchParams)

  // Standard hooks
  $: standardSearchParams: StandardSearchParamsV3 = {
    ...standardFilters,
    limit: itemsPerPage,
    offset: (currentPage - 1) * itemsPerPage,
  }

  const standardFilterOpts = useStandardFilterOptionsV3(standardFilters)
  const standardResults = useStandardSearchV3(standardSearchParams)

  // KPIs
  const premiumOptsForKpi = usePremiumFilterOptionsV3({})
  const standardOptsForKpi = useStandardFilterOptionsV3({})

  // État computed
  $: isLoading = activeTab === 'premium' ? $premiumResults.loading : $standardResults.loading
  $: totalItems = activeTab === 'premium' ? ($premiumResults.data?.total ?? 0) : ($standardResults.data?.total ?? 0)
  $: totalPages = Math.ceil(totalItems / itemsPerPage)
  $: premiumTotal = $premiumFilterOpts.data?.total_count ?? $premiumOptsForKpi.data?.total_count ?? 0
  $: standardTotal = $standardFilterOpts.data?.total_count ?? $standardOptsForKpi.data?.total_count ?? 0
  $: hasActiveFilters = activeTab === 'premium'
    ? Object.values(premiumFilters).some(v => v !== undefined)
    : Object.values(standardFilters).some(v => v !== undefined)

  onMount(async () => {
    await premiumOptsForKpi.fetch()
    await standardOptsForKpi.fetch()
    await premiumFilterOpts.fetch()
    await premiumResults.fetch()
  })

  const resetFilters = async () => {
    if (activeTab === 'premium') {
      premiumFilters = {}
    } else {
      standardFilters = {}
    }
    currentPage = 1
    await refetch()
  }

  const applyFilters = async (filters: any) => {
    if (activeTab === 'premium') {
      premiumFilters = filters
    } else {
      standardFilters = filters
    }
    currentPage = 1
    await refetch()
  }

  const refetch = async () => {
    if (activeTab === 'premium') {
      await premiumFilterOpts.fetch()
      await premiumResults.fetch()
    } else {
      await standardFilterOpts.fetch()
      await standardResults.fetch()
    }
  }

  const handleTabChange = async () => {
    currentPage = 1
    await refetch()
  }
</script>

<svelte:head>
  <title>Lentes Canônicas | Clearix Lens</title>
</svelte:head>

<main class="min-h-screen bg-muted pb-20">
  <!-- Hero -->
  <div class="bg-background border-b border-border">
    <Container>
      <div class="py-12">
        <div class="flex items-start justify-between gap-6">
          <div>
            <h1 class="text-4xl font-bold bg-gradient-to-r from-blue-600 via-cyan-600 to-teal-600 bg-clip-text text-transparent">
              Catálogo de Lentes v3
            </h1>
            <p class="mt-2 text-muted-foreground">
              Conceitos canônicos com filtros estruturados — dados do Canonical Engine v3
            </p>
          </div>
        </div>
      </div>
    </Container>
  </div>

  <Container>
    <div class="py-8 space-y-6">
      <!-- KPIs -->
      <div class="grid grid-cols-2 gap-4 md:grid-cols-4">
        <div class="rounded-xl bg-amber-50 dark:bg-amber-950/30 p-4">
          <div class="flex items-center gap-2 mb-2">
            <Crown class="h-4 w-4 text-amber-600 dark:text-amber-400" />
            <p class="text-xs font-bold uppercase tracking-wide text-amber-700 dark:text-amber-300">Premium</p>
          </div>
          <p class="text-3xl font-black text-amber-900 dark:text-amber-100">{premiumTotal.toLocaleString('pt-BR')}</p>
        </div>

        <div class="rounded-xl bg-cyan-50 dark:bg-cyan-950/30 p-4">
          <div class="flex items-center gap-2 mb-2">
            <Sparkles class="h-4 w-4 text-cyan-600 dark:text-cyan-400" />
            <p class="text-xs font-bold uppercase tracking-wide text-cyan-700 dark:text-cyan-300">Standard</p>
          </div>
          <p class="text-3xl font-black text-cyan-900 dark:text-cyan-100">{standardTotal.toLocaleString('pt-BR')}</p>
        </div>

        {#if activeTab === 'premium' && $premiumFilterOpts.data?.brands}
          <div class="rounded-xl bg-violet-50 dark:bg-violet-950/30 p-4">
            <p class="text-xs font-bold uppercase tracking-wide text-violet-700 dark:text-violet-300 mb-2">Marcas</p>
            <p class="text-3xl font-black text-violet-900 dark:text-violet-100">{$premiumFilterOpts.data.brands.length}</p>
          </div>
        {/if}

        <div class="rounded-xl bg-green-50 dark:bg-green-950/30 p-4">
          <p class="text-xs font-bold uppercase tracking-wide text-green-700 dark:text-green-300 mb-2">Resultados</p>
          <p class="text-3xl font-black text-green-900 dark:text-green-100">{totalItems.toLocaleString('pt-BR')}</p>
        </div>
      </div>

      <!-- Tabs -->
      <TabSelector
        bind:activeTab
        {premiumTotal}
        {standardTotal}
      />

      <!-- Content -->
      <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <!-- Sidebar Filters -->
        <div class="lg:col-span-1">
          <FilterPanelV3
            isPremium={activeTab === 'premium'}
            filters={activeTab === 'premium' ? premiumFilters : standardFilters}
            filterOptions={activeTab === 'premium' ? $premiumFilterOpts.data : $standardFilterOpts.data}
            loading={isLoading}
            onApplyFilters={applyFilters}
            onClearFilters={resetFilters}
          />
        </div>

        <!-- Main Content -->
        <div class="lg:col-span-3 space-y-6">
          {#if hasActiveFilters}
            <div class="flex items-center justify-between bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-900/50 rounded-lg p-4">
              <p class="text-sm text-blue-700 dark:text-blue-300">
                <span class="font-semibold">{totalItems} resultado(s)</span> com os filtros aplicados
              </p>
              <button
                on:click={resetFilters}
                class="text-sm font-semibold text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-200 transition-colors"
              >
                Limpar filtros
              </button>
            </div>
          {/if}

          <!-- Grid -->
          <LensGrid
            lentes={activeTab === 'premium' ? ($premiumResults.data?.items ?? []) : ($standardResults.data?.items ?? [])}
            loading={isLoading}
            erro={activeTab === 'premium' ? $premiumResults.error : $standardResults.error}
            isPremium={activeTab === 'premium'}
            itemCount={totalItems}
          />

          <!-- Pagination -->
          {#if totalPages > 1 && !isLoading}
            <div class="flex items-center justify-center gap-2 flex-wrap">
              <button
                disabled={currentPage === 1}
                on:click={() => (currentPage = Math.max(1, currentPage - 1))}
                class="px-3 py-2 rounded-lg border border-border hover:bg-muted disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
              >
                ← Anterior
              </button>

              <div class="flex gap-1">
                {#each Array.from({ length: Math.min(5, totalPages) }) as _, i}
                  {@const page = i + 1}
                  <button
                    on:click={() => (currentPage = page)}
                    class={`px-3 py-2 rounded-lg text-sm font-medium ${
                      currentPage === page
                        ? 'bg-primary-600 text-white'
                        : 'border border-border hover:bg-muted'
                    }`}
                  >
                    {page}
                  </button>
                {/each}
                {#if totalPages > 5}
                  <span class="px-3 py-2 text-muted-foreground">...</span>
                  <button
                    on:click={() => (currentPage = totalPages)}
                    class="px-3 py-2 rounded-lg border border-border hover:bg-muted text-sm font-medium"
                  >
                    {totalPages}
                  </button>
                {/if}
              </div>

              <button
                disabled={currentPage === totalPages}
                on:click={() => (currentPage = Math.min(totalPages, currentPage + 1))}
                class="px-3 py-2 rounded-lg border border-border hover:bg-muted disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
              >
                Próxima →
              </button>
            </div>
          {/if}
        </div>
      </div>
    </div>
  </Container>
</main>
