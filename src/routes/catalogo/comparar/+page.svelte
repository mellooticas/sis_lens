<!--
  🔄 Comparar - Detalhes de Lentes por Canônica
  Mostra todas as lentes reais de uma canônica, agrupadas por marca/laboratório
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { DetalhePremium } from '$lib/types/database-views';

  // State
  let detalhes: DetalhePremium[] = [];
  let loading = true;
  let error = '';
  let canonicaId = '';
  let canonicaNome = '';

  // Comparação por marca
  let comparacao: Record<string, DetalhePremium[]> = {};

  // Carregar dados
  onMount(async () => {
    // Pegar ID da query string
    canonicaId = $page.url.searchParams.get('id') || '';
    
    if (!canonicaId) {
      error = 'ID da lente canônica não informado';
      loading = false;
      return;
    }

    await carregarDetalhes();
  });

  async function carregarDetalhes() {
    loading = true;
    error = '';
    
    const resultado = await CatalogoAPI.listarDetalhesPremium(canonicaId);

    if (resultado.success && resultado.data) {
      detalhes = resultado.data;
      
      if (detalhes.length > 0) {
        canonicaNome = detalhes[0].nome_canonico;
        
        // Agrupar por marca
        comparacao = detalhes.reduce((acc, lente) => {
          const marca = lente.marca_nome;
          if (!acc[marca]) {
            acc[marca] = [];
          }
          acc[marca].push(lente);
          return acc;
        }, {} as Record<string, DetalhePremium[]>);
      }
    } else {
      error = resultado.error || 'Erro ao carregar detalhes';
    }
    
    loading = false;
  }

  // Marcas ordenadas
  $: marcas = Object.keys(comparacao).sort();
  
  // Estatísticas
  $: stats = {
    total: detalhes.length,
    marcas: marcas.length,
    precoMin: detalhes.reduce((min, l) => l.preco < min ? l.preco : min, Infinity),
    precoMax: detalhes.reduce((max, l) => l.preco > max ? l.preco : max, 0),
    precoMedio: detalhes.reduce((sum, l) => sum + l.preco, 0) / (detalhes.length || 1)
  };
</script>

<svelte:head>
  <title>Comparar Lentes - {canonicaNome || 'SIS Lens'}</title>
</svelte:head>

<main class="min-h-screen bg-gradient-to-br from-cyan-50 via-blue-50 to-indigo-50 py-12">
  <div class="container mx-auto px-4 max-w-7xl">
    
    <!-- Header -->
    <header class="text-center mb-12">
      <div class="inline-block px-4 py-2 bg-cyan-100 text-cyan-700 rounded-full text-sm font-medium mb-4">
        🔄 Comparar Laboratórios
      </div>
      <h1 class="text-3xl md:text-4xl font-bold text-slate-900 mb-2">
        {canonicaNome || 'Carregando...'}
      </h1>
      {#if !loading && detalhes.length > 0}
        <p class="text-lg text-slate-600">
          {stats.total} lentes disponíveis em {stats.marcas} marcas
        </p>
      {/if}
    </header>

    <!-- Loading -->
    {#if loading}
      <div class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-cyan-600"></div>
        <span class="ml-4 text-slate-600">Carregando comparação...</span>
      </div>
    
    <!-- Error -->
    {:else if error}
      <div class="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <p class="text-red-800">⚠️ {error}</p>
        <a
          href="/catalogo"
          class="inline-block mt-4 px-6 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700"
        >
          ← Voltar ao Catálogo
        </a>
      </div>
    
    <!-- Empty State -->
    {:else if detalhes.length === 0}
      <div class="text-center py-20">
        <div class="text-6xl mb-4">📦</div>
        <h3 class="text-2xl font-bold text-slate-900 mb-2">Nenhuma lente encontrada</h3>
        <p class="text-slate-600 mb-6">Não há lentes disponíveis para esta canônica</p>
        <a
          href="/catalogo"
          class="inline-block px-6 py-2 bg-cyan-600 text-white rounded-lg hover:bg-cyan-700"
        >
          ← Voltar ao Catálogo
        </a>
      </div>
    
    <!-- Estatísticas -->
    {:else}
      <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-lg p-6 mb-8">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div class="text-center p-4 bg-gradient-to-br from-cyan-50 to-blue-50 rounded-lg">
            <div class="text-3xl font-bold text-cyan-600">{stats.total}</div>
            <div class="text-sm text-slate-600 mt-1">Lentes Totais</div>
          </div>
          
          <div class="text-center p-4 bg-gradient-to-br from-purple-50 to-pink-50 rounded-lg">
            <div class="text-3xl font-bold text-purple-600">{stats.marcas}</div>
            <div class="text-sm text-slate-600 mt-1">Marcas</div>
          </div>
          
          <div class="text-center p-4 bg-gradient-to-br from-emerald-50 to-teal-50 rounded-lg">
            <div class="text-2xl font-bold text-emerald-600">R$ {stats.precoMin.toFixed(0)}</div>
            <div class="text-sm text-slate-600 mt-1">Preço Mínimo</div>
          </div>
          
          <div class="text-center p-4 bg-gradient-to-br from-amber-50 to-orange-50 rounded-lg">
            <div class="text-2xl font-bold text-amber-600">R$ {stats.precoMax.toFixed(0)}</div>
            <div class="text-sm text-slate-600 mt-1">Preço Máximo</div>
          </div>
        </div>
      </div>

      <!-- Comparação por Marca -->
      <div class="space-y-6">
        {#each marcas as marca}
          {@const lentes = comparacao[marca]}
          {@const precoMedio = lentes.reduce((sum, l) => sum + l.preco, 0) / lentes.length}
          
          <div class="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg border border-slate-200 overflow-hidden">
            
            <!-- Header da Marca -->
            <div class="bg-gradient-to-r from-cyan-500 to-blue-600 p-5">
              <div class="flex items-center justify-between">
                <div>
                  <h2 class="text-2xl font-bold text-white">{marca}</h2>
                  <p class="text-cyan-100 mt-1">
                    {lentes.length} {lentes.length === 1 ? 'lente' : 'lentes'} • Preço médio: R$ {precoMedio.toFixed(0)}
                  </p>
                </div>
                <div class="text-white text-4xl">🏭</div>
              </div>
            </div>

            <!-- Lista de Lentes -->
            <div class="divide-y divide-slate-200">
              {#each lentes as lente}
                <div class="p-5 hover:bg-slate-50 transition-colors">
                  <div class="flex items-start justify-between gap-4">
                    
                    <!-- Info da Lente -->
                    <div class="flex-1 space-y-2">
                      <h3 class="font-semibold text-lg text-slate-900">
                        {lente.nome_comercial}
                      </h3>
                      
                      {#if lente.linha_produto}
                        <div class="text-sm text-slate-600">
                          <span class="font-medium">Linha:</span> {lente.linha_produto}
                        </div>
                      {/if}

                      <!-- Specs -->
                      <div class="flex flex-wrap gap-2 text-sm">
                        <span class="px-2 py-1 bg-slate-100 text-slate-700 rounded">
                          {lente.material}
                        </span>
                        <span class="px-2 py-1 bg-slate-100 text-slate-700 rounded">
                          Índice {lente.indice_refracao}
                        </span>
                        <span class="px-2 py-1 bg-blue-100 text-blue-700 rounded capitalize">
                          {lente.categoria.replace('_', ' ')}
                        </span>
                      </div>

                      <!-- Tratamentos -->
                      <div class="flex flex-wrap gap-2 text-xs">
                        {#if lente.ar}
                          <span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full">✨ AR</span>
                        {/if}
                        {#if lente.blue}
                          <span class="px-2 py-1 bg-cyan-100 text-cyan-700 rounded-full">🔵 Blue Light</span>
                        {/if}
                        {#if lente.fotossensivel}
                          <span class="px-2 py-1 bg-amber-100 text-amber-700 rounded-full">☀️ Fotossensível</span>
                        {/if}
                        {#if lente.polarizado}
                          <span class="px-2 py-1 bg-purple-100 text-purple-700 rounded-full">🕶️ Polarizado</span>
                        {/if}
                      </div>

                      <!-- Características Adicionais -->
                      {#if lente.espessura_centro || lente.peso_gramas || lente.durabilidade}
                        <div class="flex gap-4 text-xs text-slate-600 pt-2 border-t">
                          {#if lente.espessura_centro}
                            <span>Espessura: {lente.espessura_centro}mm</span>
                          {/if}
                          {#if lente.peso_gramas}
                            <span>Peso: {lente.peso_gramas}g</span>
                          {/if}
                          {#if lente.durabilidade}
                            <span>Durabilidade: {lente.durabilidade}/10</span>
                          {/if}
                        </div>
                      {/if}
                    </div>

                    <!-- Preço -->
                    <div class="text-right">
                      <div class="text-3xl font-bold text-emerald-600">
                        R$ {lente.preco.toFixed(0)}
                      </div>
                      <div class="text-xs text-slate-500 mt-1">
                        {lente.status}
                      </div>
                      {#if lente.desconto_promocional && lente.desconto_promocional > 0}
                        <div class="mt-2 px-2 py-1 bg-red-100 text-red-700 text-xs rounded">
                          -{lente.desconto_promocional}% OFF
                        </div>
                      {/if}
                    </div>
                  </div>
                </div>
              {/each}
            </div>
          </div>
        {/each}
      </div>

      <!-- Voltar -->
      <div class="mt-8 text-center">
        <a
          href="/catalogo"
          class="inline-block px-8 py-3 bg-gradient-to-r from-cyan-500 to-blue-600 text-white rounded-lg font-medium hover:from-cyan-600 hover:to-blue-700 transition-all"
        >
          ← Voltar ao Catálogo
        </a>
      </div>
    {/if}
  </div>
</main>
