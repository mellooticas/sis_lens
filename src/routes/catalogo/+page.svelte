<!--
  🔍 Catálogo de Lentes - SIS Lens
  Busca completa com filtros avançados e design premium
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { fade, fly } from 'svelte/transition';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { LenteCatalogo } from '$lib/types/database-views';
  
  // Ícones
  import { LayoutGrid, List, SlidersHorizontal, Search, ChevronDown, RotateCcw } from 'lucide-svelte';
  import { slide } from 'svelte/transition';

  // Layout Components
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  
  // UI Components
  import FilterPanel from "$lib/components/catalogo/FilterPanel.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import LenteCard from "$lib/components/catalogo/LenteCard.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import Pagination from "$lib/components/ui/Pagination.svelte";

  // State
  let lentes: LenteCatalogo[] = [];
  let loading = true;
  let error = '';
  let total = 0;
  let paginaAtual = 1;
  const itensPorPagina = 12;

  // Filtros (Estado Mestre)
  let filters: any = {
    busca: '',
    tipos: [],
    materiais: [],
    indices: [],
    marcas: [],
    tratamentos: {}
  };

  // View Mode
  let viewMode: 'grid' | 'list' = 'grid';
  let showMobileFilters = false;
  let showDesktopFilters = false;

  // Carregar dados inicial
  onMount(async () => {
    await carregarLentes();
  });

  async function carregarLentes() {
    try {
      loading = true;
      error = '';
      
      const resultado = await CatalogoAPI.buscarLentes(
        filters,
        { 
          pagina: paginaAtual, 
          limite: itensPorPagina,
          ordenar: 'preco_venda_sugerido', // Ordenação por preço (novo campo)
          direcao: 'asc'
        }
      );

      if (resultado.success && resultado.data) {
        lentes = resultado.data.dados;
        total = resultado.data.paginacao.total;
      } else {
        error = resultado.error || 'Erro ao buscar lentes';
        console.error('Erro ao buscar lentes:', error);
      }
    } catch (err) {
      console.error('Erro ao carregar lentes:', err);
      error = err instanceof Error ? err.message : 'Erro desconhecido';
    } finally {
      loading = false;
    }
  }

  // Event Handlers
  function handleFilterChange(event: CustomEvent) {
    filters = event.detail;
    paginaAtual = 1;
    carregarLentes();
  }

  function handleClearFilters() {
    filters = {
      busca: '',
      tipos: [],
      materiais: [],
      indices: [],
      marcas: [],
      tratamentos: {}
    };
    paginaAtual = 1;
    carregarLentes();
  }

  function toggleMobileFilters() {
    showMobileFilters = !showMobileFilters;
  }

</script>

<svelte:head>
  <title>Catálogo de Lentes - SIS Lens</title>
  <meta name="description" content="Explore nosso catálogo completo de lentes com filtros avançados" />
</svelte:head>

<main>
  <!-- Hero Section Premium -->
  <div class="bg-gradient-to-br from-brand-blue-50 via-white to-brand-orange-50 dark:from-neutral-900 dark:via-neutral-800 dark:to-neutral-900 border-b border-neutral-200 dark:border-neutral-700">
    <Container maxWidth="xl" padding="lg">
      <PageHero
        badge="🔍 Catálogo Completo"
        title="Explore Todas as Lentes"
        subtitle="{total.toLocaleString('pt-BR')} lentes disponíveis com filtros inteligentes"
        alignment="center"
        maxWidth="lg"
      />
      
      <!-- Stats Rápidos -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-8">
        <div class="glass-panel rounded-lg p-4 text-center">
          <div class="text-2xl font-bold text-brand-blue-600 dark:text-brand-blue-400">{total}</div>
          <div class="text-sm text-neutral-600 dark:text-neutral-400">Lentes Total</div>
        </div>
        <div class="glass-panel rounded-lg p-4 text-center">
          <div class="text-2xl font-bold text-brand-orange-600 dark:text-brand-orange-400">{lentes.length}</div>
          <div class="text-sm text-neutral-600 dark:text-neutral-400">Exibindo Agora</div>
        </div>
        <div class="glass-panel rounded-lg p-4 text-center">
          <div class="text-2xl font-bold text-brand-gold-600 dark:text-brand-gold-400">{Math.ceil(total / itensPorPagina)}</div>
          <div class="text-sm text-neutral-600 dark:text-neutral-400">Páginas</div>
        </div>
      </div>
    </Container>
  </div>

  <Container maxWidth="xl" padding="lg">
    <div class="space-y-6">
      
      <!-- Filtros Expansíveis (Desktop) -->
      <div class="hidden md:block">
        <div
          class="w-full glass-panel rounded-xl p-4 flex items-center justify-between hover:shadow-lg transition-all duration-300 cursor-pointer group"
        >
          <div 
            class="flex items-center gap-3 flex-1"
            on:click={() => showDesktopFilters = !showDesktopFilters}
            on:keydown={(e) => e.key === 'Enter' && (showDesktopFilters = !showDesktopFilters)}
            role="button"
            tabindex="0"
          >
            <div class="p-2 rounded-lg bg-brand-blue-50 dark:bg-brand-blue-800 text-brand-blue-600 dark:text-brand-blue-300 group-hover:scale-110 transition-transform">
              <SlidersHorizontal class="w-5 h-5" />
            </div>
            <div class="text-left">
              <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100">Filtros Avançados</h3>
              <p class="text-sm text-neutral-600 dark:text-neutral-400">
                {showDesktopFilters ? 'Clique para recolher' : 'Clique para expandir e refinar sua busca'}
              </p>
            </div>
          </div>
          <div class="flex items-center gap-4">
            <!-- Toggle de Visualização -->
            <div class="flex items-center gap-2 bg-neutral-100 dark:bg-neutral-800 rounded-lg p-1">
              <button 
                class="p-2 rounded-md transition-all {viewMode === 'grid' ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400' : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
                on:click={() => viewMode = 'grid'}
                title="Visualização em Grade"
              >
                <LayoutGrid class="w-4 h-4" />
              </button>
              <button 
                class="p-2 rounded-md transition-all {viewMode === 'list' ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400' : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
                on:click={() => viewMode = 'list'}
                title="Visualização em Lista"
              >
                <List class="w-4 h-4" />
              </button>
            </div>
            <!-- Chevron de Expansão -->
            <div 
              class="transform transition-transform duration-300 {showDesktopFilters ? 'rotate-180' : ''}"
              on:click={() => showDesktopFilters = !showDesktopFilters}
              on:keydown={(e) => e.key === 'Enter' && (showDesktopFilters = !showDesktopFilters)}
              role="button"
              tabindex="0"
            >
              <ChevronDown class="w-6 h-6 text-neutral-500 dark:text-neutral-400" />
            </div>
          </div>
        </div>
        
        {#if showDesktopFilters}
          <div transition:slide={{ duration: 300 }} class="mt-4">
            <FilterPanel 
              {filters} 
              {loading} 
              totalResults={total} 
              on:change={handleFilterChange}
              on:clear={handleClearFilters}
            />
            <div class="mt-4 flex justify-end">
              <Button variant="outline" size="sm" on:click={handleClearFilters}>
                <RotateCcw class="w-4 h-4 mr-2" />
                Limpar Todos os Filtros
              </Button>
            </div>
          </div>
        {/if}
      </div>

      <!-- Mobile Filters Overlay -->
      {#if showMobileFilters}
        <div class="fixed inset-0 z-40 bg-black/60 backdrop-blur-sm md:hidden" transition:fade on:click={toggleMobileFilters} role="button" tabindex="0" on:keydown={(e) => e.key === 'Enter' && toggleMobileFilters()}></div>
        <aside class="fixed inset-y-0 right-0 z-50 w-full max-w-md glass-panel shadow-2xl overflow-y-auto md:hidden" 
               transition:fly={{ x: 300, duration: 300 }}>
          <div class="sticky top-0 z-10 glass-panel border-b border-neutral-200 dark:border-neutral-700 p-6">
            <div class="flex items-center justify-between">
              <div>
                <h2 class="text-xl font-bold text-neutral-900 dark:text-neutral-100">Filtros & Visualização</h2>
                <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-1">{total} lentes disponíveis</p>
              </div>
              <button 
                on:click={toggleMobileFilters} 
                class="p-2 rounded-lg hover:bg-neutral-100 dark:hover:bg-neutral-800 text-neutral-500 dark:text-neutral-400 transition-colors"
                aria-label="Fechar filtros"
              >
                ✕
              </button>
            </div>
            <!-- Toggle de Visualização Mobile -->
            <div class="flex items-center gap-2 mt-4">
              <span class="text-sm text-neutral-600 dark:text-neutral-400">Visualizar como:</span>
              <div class="flex items-center gap-2 bg-neutral-100 dark:bg-neutral-800 rounded-lg p-1">
                <button 
                  class="p-2 rounded-md transition-all {viewMode === 'grid' ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400' : 'text-neutral-500'}"
                  on:click={() => viewMode = 'grid'}
                  title="Grade"
                >
                  <LayoutGrid class="w-4 h-4" />
                </button>
                <button 
                  class="p-2 rounded-md transition-all {viewMode === 'list' ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400' : 'text-neutral-500'}"
                  on:click={() => viewMode = 'list'}
                  title="Lista"
                >
                  <List class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
          <div class="p-6">
            <FilterPanel 
              {filters} 
              {loading} 
              totalResults={total} 
              on:change={handleFilterChange}
              on:clear={handleClearFilters}
            />
          </div>
        </aside>
      {/if}

      <!-- Grid de Resultados -->
      <div class="space-y-6">
        
        {#if loading && lentes.length === 0}
          <div class="glass-panel rounded-xl p-20 flex flex-col items-center justify-center">
            <LoadingSpinner size="lg" />
            <p class="mt-4 text-neutral-600 dark:text-neutral-400">Carregando lentes...</p>
          </div>
        {:else if error}
          <div class="glass-panel rounded-xl p-8 text-center border-2 border-error">
            <div class="text-5xl mb-4">⚠️</div>
            <h3 class="text-xl font-bold text-neutral-900 dark:text-neutral-100 mb-2">Erro ao Carregar</h3>
            <p class="text-error mb-6">{error}</p>
            <Button variant="primary" on:click={carregarLentes}>Tentar Novamente</Button>
          </div>
        {:else if lentes.length === 0}
          <div class="glass-panel rounded-xl p-12 text-center">
            <div class="text-6xl mb-4">🔍</div>
            <h3 class="text-2xl font-bold text-neutral-900 dark:text-neutral-100 mb-3">Nenhuma Lente Encontrada</h3>
            <p class="text-neutral-600 dark:text-neutral-400 mb-6 max-w-md mx-auto">Tente ajustar seus filtros para encontrar o que procura.</p>
            <Button variant="primary" on:click={handleClearFilters}>Limpar Todos os Filtros</Button>
          </div>
        {:else}
          <SectionHeader
            title="Resultados"
            subtitle="{lentes.length} lentes na página {paginaAtual} de {Math.ceil(total / itensPorPagina)}"
          />
          <div class={viewMode === 'grid' 
            ? "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 gap-6" 
            : "flex flex-col gap-4"
          }>
            {#each lentes as lente (lente.id)}
              <div class="h-full">
                <!-- Usando o card estilizado -->
                <LenteCard 
                  lente={{
                    ...lente,
                    preco: lente.preco_venda_sugerido // Normalização de preço
                  }}
                  compact={viewMode === 'list'}
                />
              </div>
            {/each}
          </div>

          <!-- Paginação -->
          <Pagination 
            currentPage={paginaAtual}
            totalPages={Math.ceil(total / itensPorPagina)}
            totalItems={total}
            itemsPerPage={itensPorPagina}
            on:change={(e) => { paginaAtual = e.detail; carregarLentes(); }}
          />
        {/if}
      </div>

    </div>
  </Container>
  
  <!-- Botão Flutuante Mobile (FAB) -->
  <button
    on:click={toggleMobileFilters}
    class="md:hidden fixed bottom-6 right-6 z-30 p-4 rounded-full bg-brand-blue-600 hover:bg-brand-blue-700 text-white shadow-2xl hover:shadow-3xl transition-all duration-300 hover:scale-110"
    aria-label="Abrir filtros"
  >
    <SlidersHorizontal class="w-6 h-6" />
  </button>
</main>
