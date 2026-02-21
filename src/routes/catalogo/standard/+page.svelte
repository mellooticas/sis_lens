<!--
  ��� Catálogo Standard - SIS Lens
  Grupos canônicos de lentes standard (não premium)
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { fade } from 'svelte/transition';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { VGruposCanonico } from '$lib/types/database-views';
  
  // Ícones
  import { LayoutGrid, List, SlidersHorizontal, Package, DollarSign, Layers, ChevronDown, RotateCcw } from 'lucide-svelte';
  import { slide } from 'svelte/transition';

  // Layout Components
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  
  // UI Components
  import FilterPanel from "$lib/components/catalogo/FilterPanel.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import GrupoCanonicoCard from "$lib/components/catalogo/GrupoCanonicoCard.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import Pagination from "$lib/components/ui/Pagination.svelte";

  // State
  let grupos: VGruposCanonico[] = [];
  let loading = true;
  let error = '';
  let total = 0;
  let paginaAtual = 1;
  const itensPorPagina = 12;

  // Filtros
  let filters: any = {
    busca: '',
    tipos: [],
    materiais: [],
    indices: [],
    tratamentos: {}
  };

  // View Mode
  let viewMode: 'grid' | 'list' = 'grid';
  let showMobileFilters = false;
  let showDesktopFilters = false;

  // Stats
  let stats = {
    totalGrupos: 0,
    precoMedio: 0,
    totalLentes: 0
  };

  onMount(async () => {
    await carregarGrupos();
  });

  async function carregarGrupos() {
    try {
      loading = true;
      error = '';
      
      console.log('🔍 Carregando grupos standard...', { filters, pagina: paginaAtual, limite: itensPorPagina });
      
      const resultado = await CatalogoAPI.buscarGruposCanonicosStandard(
        filters,
        { 
          pagina: paginaAtual, 
          limite: itensPorPagina,
          ordenar: 'preco_medio',
          direcao: 'asc'
        }
      );

      console.log('📊 Resultado da API:', resultado);

      if (resultado.success && resultado.data) {
        grupos = resultado.data.dados;
        total = resultado.data.paginacao.total;
        
        console.log('✅ Grupos carregados:', grupos.length, 'Total:', total);
        
        stats.totalGrupos = total;
        stats.precoMedio = grupos.reduce((acc, g) => acc + (g.preco_medio || 0), 0) / (grupos.length || 1);
        stats.totalLentes = grupos.reduce((acc, g) => acc + g.total_lentes, 0);
      } else {
        error = resultado.error || 'Erro ao buscar grupos';
        console.error('❌ Erro da API:', error);
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'Erro desconhecido';
      console.error('❌ Erro ao carregar grupos:', err);
    } finally {
      loading = false;
    }
  }

  function handleFilterChange(event: CustomEvent) {
    filters = event.detail;
    paginaAtual = 1;
    carregarGrupos();
  }

  function handleClearFilters() {
    filters = { busca: '', tipos: [], materiais: [], indices: [], tratamentos: {} };
    paginaAtual = 1;
    carregarGrupos();
  }

  function formatarPreco(preco: number): string {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 0 }).format(preco);
  }

  $: totalPaginas = Math.ceil(total / itensPorPagina);
</script>

<svelte:head>
  <title>Catálogo Standard - SIS Lens</title>
</svelte:head>

<PageHero title="Catálogo Standard" subtitle="Grupos canônicos de lentes organizadas por especificações técnicas" />

<Container maxWidth="full" padding="lg">
  <div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <StatsCard title="Grupos Disponíveis" value={stats.totalGrupos.toString()} color="blue">
        <Package slot="icon" class="w-6 h-6" />
      </StatsCard>
      <StatsCard title="Preço Médio" value={formatarPreco(stats.precoMedio)} color="orange">
        <DollarSign slot="icon" class="w-6 h-6" />
      </StatsCard>
      <StatsCard title="Total de Lentes" value={stats.totalLentes.toString()} color="blue">
        <Layers slot="icon" class="w-6 h-6" />
      </StatsCard>
    </div>

    <div class="glass-panel rounded-xl">
      <div
        class="w-full p-4 flex items-center justify-between hover:shadow-lg transition-all duration-300 cursor-pointer group"
      >
        <div 
          class="flex items-center gap-3 flex-1"
          on:click={() => showDesktopFilters = !showDesktopFilters}
          on:keydown={(e) => e.key === 'Enter' && (showDesktopFilters = !showDesktopFilters)}
          role="button"
          tabindex="0"
        >
          <div class="p-2 rounded-lg bg-primary-50 dark:bg-primary-800 text-primary-600 dark:text-primary-300 group-hover:scale-110 transition-transform">
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
          <div class="hidden md:flex items-center gap-2 bg-neutral-100 dark:bg-neutral-800 rounded-lg p-1">
            <button 
              class="p-2 rounded-md transition-all {viewMode === 'grid' ? 'bg-white dark:bg-neutral-700 shadow-sm text-primary-600 dark:text-primary-400' : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
              on:click={() => viewMode = 'grid'}
              title="Visualização em Grade"
            >
              <LayoutGrid class="w-4 h-4" />
            </button>
            <button 
              class="p-2 rounded-md transition-all {viewMode === 'list' ? 'bg-white dark:bg-neutral-700 shadow-sm text-primary-600 dark:text-primary-400' : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
              on:click={() => viewMode = 'list'}
              title="Visualização em Lista"
            >
              <List class="w-4 h-4" />
            </button>
          </div>
          <!-- Chevron de Expansão -->
          <div 
            class="hidden md:block transform transition-transform duration-300 {showDesktopFilters ? 'rotate-180' : ''}"
            on:click={() => showDesktopFilters = !showDesktopFilters}
            on:keydown={(e) => e.key === 'Enter' && (showDesktopFilters = !showDesktopFilters)}
            role="button"
            tabindex="0"
          >
            <ChevronDown class="w-6 h-6 text-neutral-500 dark:text-neutral-400" />
          </div>
          <!-- Mobile Button -->
          <button class="md:hidden p-2 rounded-lg bg-primary-600 text-white" on:click={() => showMobileFilters = !showMobileFilters}>
            <SlidersHorizontal class="w-5 h-5" />
          </button>
        </div>
      </div>

      {#if showDesktopFilters}
        <div transition:slide={{ duration: 300 }} class="px-4 pb-4">
          <div class="hidden md:block">
            <FilterPanel {filters} {loading} totalResults={total} on:change={handleFilterChange} on:clear={handleClearFilters} />
          </div>
          <div class="mt-4 flex justify-end">
            <Button variant="primary" size="sm" on:click={handleClearFilters}>
              <RotateCcw class="w-4 h-4 mr-2" />
              Limpar Todos os Filtros
            </Button>
          </div>
        </div>
      {/if}

      {#if showMobileFilters}
        <div class="md:hidden px-4 pb-4" transition:slide={{ duration: 300 }}>
          <FilterPanel {filters} {loading} totalResults={total} on:change={handleFilterChange} on:clear={handleClearFilters} />
        </div>
      {/if}
    </div>

    <div class="glass-panel p-6 rounded-xl">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
          {loading ? 'Carregando...' : `${total} grupo${total !== 1 ? 's' : ''} encontrado${total !== 1 ? 's' : ''}`}
        </h3>
      </div>

      {#if loading}
        <div class="flex items-center justify-center py-20"><LoadingSpinner size="lg" /></div>
      {:else if error}
        <div class="text-center py-20">
          <div class="text-5xl mb-4">⚠️</div>
          <p class="text-red-600 dark:text-red-400 mb-4">{error}</p>
          <Button variant="primary" on:click={carregarGrupos}>Tentar Novamente</Button>
        </div>
      {:else if grupos.length === 0}
        <div class="text-center py-20">
          <div class="text-5xl mb-4">���</div>
          <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Nenhum grupo encontrado</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-6">Tente ajustar os filtros</p>
          <Button variant="secondary" on:click={handleClearFilters}>Limpar Filtros</Button>
        </div>
      {:else}
        <div class="grid gap-6 {viewMode === 'grid' ? 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4' : 'grid-cols-1'}" in:fade>
          {#each grupos as grupo (grupo.id)}
            <div in:fade><GrupoCanonicoCard {grupo} /></div>
          {/each}
        </div>
        
        <!-- Paginação -->
        <div class="mt-6">
          <Pagination 
            currentPage={paginaAtual}
            totalPages={totalPaginas}
            totalItems={total}
            itemsPerPage={itensPorPagina}
            on:change={(e) => { paginaAtual = e.detail; carregarGrupos(); }}
          />
        </div>
      {/if}
    </div>
  </div>
</Container>
