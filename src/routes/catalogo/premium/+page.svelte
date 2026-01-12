<!--
  ✨ Catálogo Premium - SIS Lens
  Grupos canônicos de lentes premium (marcas e tecnologias avançadas)
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { fade } from 'svelte/transition';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { VGruposCanonico } from '$lib/types/database-views';
  
  // Ícones
  import { LayoutGrid, List, SlidersHorizontal, Crown } from 'lucide-svelte';

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
      
      console.log('🔍 Carregando grupos premium...', { filters, pagina: paginaAtual, limite: itensPorPagina });
      
      const resultado = await CatalogoAPI.buscarGruposCanonicosPremium(
        filters,
        { 
          pagina: paginaAtual, 
          limite: itensPorPagina,
          ordenar: 'preco_medio',
          direcao: 'desc' // Premium ordena do maior para o menor preço
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
  <title>Catálogo Premium - SIS Lens</title>
</svelte:head>

<PageHero title="Catálogo Premium" subtitle="Lentes de marcas renomadas com tecnologias avançadas e design exclusivo">
  <div slot="badge" class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold text-sm">
    <Crown class="w-4 h-4" />
    Premium Collection
  </div>
</PageHero>

<Container maxWidth="full" padding="lg">
  <div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <StatsCard title="Grupos Premium" value={stats.totalGrupos.toString()} icon="👑" color="orange" />
      <StatsCard title="Preço Médio" value={formatarPreco(stats.precoMedio)} icon="💎" color="blue" />
      <StatsCard title="Total de Lentes" value={stats.totalLentes.toString()} icon="✨" color="orange" />
    </div>

    <div class="glass-panel p-6 rounded-xl">
      <div class="flex items-center justify-between mb-4">
        <SectionHeader title="Filtros" subtitle="Refine sua busca" />
        <div class="flex items-center gap-2">
          <div class="hidden md:flex items-center gap-1 bg-gray-100 dark:bg-gray-800 rounded-lg p-1">
            <button class="p-2 rounded transition-colors {viewMode === 'grid' ? 'bg-white dark:bg-gray-700 shadow' : 'hover:bg-gray-200 dark:hover:bg-gray-700'}" on:click={() => viewMode = 'grid'}>
              <LayoutGrid class="w-4 h-4" />
            </button>
            <button class="p-2 rounded transition-colors {viewMode === 'list' ? 'bg-white dark:bg-gray-700 shadow' : 'hover:bg-gray-200 dark:hover:bg-gray-700'}" on:click={() => viewMode = 'list'}>
              <List class="w-4 h-4" />
            </button>
          </div>
          <button class="md:hidden p-2 rounded-lg bg-amber-600 text-white" on:click={() => showMobileFilters = !showMobileFilters}>
            <SlidersHorizontal class="w-5 h-5" />
          </button>
        </div>
      </div>

      <div class="hidden md:block">
        <FilterPanel {filters} {loading} totalResults={total} on:change={handleFilterChange} on:clear={handleClearFilters} />
      </div>

      {#if showMobileFilters}
        <div class="md:hidden" transition:fade>
          <FilterPanel {filters} {loading} totalResults={total} on:change={handleFilterChange} on:clear={handleClearFilters} />
        </div>
      {/if}
    </div>

    <div class="glass-panel p-6 rounded-xl">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
          {loading ? 'Carregando...' : `${total} grupo${total !== 1 ? 's' : ''} premium encontrado${total !== 1 ? 's' : ''}`}
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
          <div class="text-5xl mb-4">👑</div>
          <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Nenhum grupo premium encontrado</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-6">Tente ajustar os filtros</p>
          <Button variant="secondary" on:click={handleClearFilters}>Limpar Filtros</Button>
        </div>
      {:else}
        <div class="grid gap-6 {viewMode === 'grid' ? 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4' : 'grid-cols-1'}" in:fade>
          {#each grupos as grupo (grupo.id)}
            <div in:fade><GrupoCanonicoCard {grupo} variant="premium" /></div>
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
