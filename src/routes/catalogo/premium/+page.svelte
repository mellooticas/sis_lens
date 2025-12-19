<!--
  🏆 Premium - Lentes Canônicas Premium (250 grupos)
  Dados reais da view vw_canonicas_premium
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { CanonicaPremium } from '$lib/types/database-views';

  // State
  let canonicas: CanonicaPremium[] = [];
  let loading = true;
  let error = '';
  
  // Filtros
  let filtroMarca = '';
  let filtroTipo = '';
  let filtroBusca = '';

  // Carregar dados
  onMount(async () => {
    await carregarDados();
  });

  async function carregarDados() {
    loading = true;
    error = '';
    
    const resultado = await CatalogoAPI.listarCanonicasPremium(
      {
        tipos: filtroTipo ? [filtroTipo as any] : undefined
      },
      { limite: 300, ordenar: 'nome_canonico', direcao: 'asc' }
    );

    if (resultado.success && resultado.data) {
      canonicas = resultado.data.dados;
    } else {
      error = resultado.error || 'Erro ao carregar premium';
    }
    
    loading = false;
  }

  // Filtros locais
  $: filtradas = canonicas.filter(c => {
    const busca = filtroBusca.toLowerCase();
    const buscaOk = !busca || 
      c.nome_canonico.toLowerCase().includes(busca) ||
      c.marca_nome.toLowerCase().includes(busca) ||
      c.linha_produto?.toLowerCase().includes(busca);
    
    const marcaOk = !filtroMarca || c.marca_nome === filtroMarca;
    
    return buscaOk && marcaOk;
  });

  // Marcas únicas para filtro
  $: marcasUnicas = [...new Set(canonicas.map(c => c.marca_nome))].sort();
</script>

<svelte:head>
  <title>Lentes Premium - SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-yellow-50 py-12">
  <div class="container mx-auto px-4 max-w-7xl">
    
    <!-- Header -->
    <header class="text-center mb-12">
      <div class="inline-block px-4 py-2 bg-amber-100 text-amber-700 rounded-full text-sm font-medium mb-4">
        🏆 Premium
      </div>
      <h1 class="text-4xl md:text-5xl font-bold text-slate-900 mb-4">
        Lentes Premium
      </h1>
      <p class="text-lg text-slate-600 max-w-2xl mx-auto">
        {canonicas.length} produtos premium disponíveis
      </p>
    </header>

    <!-- Filtros -->
    <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-lg p-6 mb-8">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <!-- Busca -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            🔍 Buscar
          </label>
          <input
            type="text"
            bind:value={filtroBusca}
            placeholder="Nome, marca ou linha..."
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
          />
        </div>

        <!-- Marca -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            🏭 Marca
          </label>
          <select
            bind:value={filtroMarca}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
          >
            <option value="">Todas</option>
            {#each marcasUnicas as marca}
              <option value={marca}>{marca}</option>
            {/each}
          </select>
        </div>

        <!-- Tipo -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            👓 Tipo
          </label>
          <select
            bind:value={filtroTipo}
            on:change={carregarDados}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-transparent"
          >
            <option value="">Todos</option>
            <option value="visao_simples">Visão Simples</option>
            <option value="multifocal">Multifocal</option>
            <option value="bifocal">Bifocal</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading -->
    {#if loading}
      <div class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600"></div>
        <span class="ml-4 text-slate-600">Carregando produtos premium...</span>
      </div>
    
    <!-- Error -->
    {:else if error}
      <div class="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <p class="text-red-800">⚠️ {error}</p>
        <button
          on:click={carregarDados}
          class="mt-4 px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Tentar novamente
        </button>
      </div>
    
    <!-- Empty State -->
    {:else if filtradas.length === 0}
      <div class="text-center py-20">
        <div class="text-6xl mb-4">🔍</div>
        <h3 class="text-2xl font-bold text-slate-900 mb-2">Nenhum produto encontrado</h3>
        <p class="text-slate-600">Tente ajustar os filtros</p>
      </div>
    
    <!-- Grid de Premium -->
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {#each filtradas as canonica}
          <div class="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 border-2 border-amber-200 overflow-hidden">
            
            <!-- Header com Marca -->
            <div class="bg-gradient-to-r from-amber-500 to-orange-600 p-4">
              <div class="flex items-center justify-between mb-2">
                <span class="px-3 py-1 bg-white/20 backdrop-blur-sm text-white text-xs rounded-full font-medium">
                  {canonica.marca_nome}
                </span>
                {#if canonica.categoria === 'super_premium'}
                  <span class="text-white text-xl">⭐</span>
                {/if}
              </div>
              <h3 class="font-semibold text-white text-lg leading-tight">
                {canonica.nome_canonico}
              </h3>
              {#if canonica.linha_produto}
                <p class="text-amber-100 text-sm mt-1">
                  {canonica.linha_produto}
                </p>
              {/if}
            </div>

            <!-- Corpo -->
            <div class="p-5 space-y-3">
              <!-- Specs -->
              <div class="grid grid-cols-2 gap-2 text-sm">
                <div class="bg-slate-50 px-3 py-2 rounded-lg">
                  <div class="text-slate-500 text-xs">Tipo</div>
                  <div class="font-medium text-slate-900 capitalize">
                    {canonica.tipo_lente.replace('_', ' ')}
                  </div>
                </div>
                
                <div class="bg-slate-50 px-3 py-2 rounded-lg">
                  <div class="text-slate-500 text-xs">Material</div>
                  <div class="font-medium text-slate-900">{canonica.material}</div>
                </div>

                <div class="bg-slate-50 px-3 py-2 rounded-lg">
                  <div class="text-slate-500 text-xs">Índice</div>
                  <div class="font-medium text-slate-900">{canonica.indice_refracao}</div>
                </div>

                <div class="bg-slate-50 px-3 py-2 rounded-lg">
                  <div class="text-slate-500 text-xs">Categoria</div>
                  <div class="font-medium text-amber-700 capitalize text-xs">
                    {canonica.categoria.replace('_', ' ')}
                  </div>
                </div>
              </div>

              <!-- Tratamentos Premium -->
              {#if canonica.ar || canonica.blue || canonica.fotossensivel || canonica.polarizado}
                <div class="flex flex-wrap gap-2">
                  {#if canonica.ar}
                    <span class="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full font-medium">✨ AR</span>
                  {/if}
                  {#if canonica.blue}
                    <span class="px-2 py-1 bg-cyan-100 text-cyan-700 text-xs rounded-full font-medium">🔵 Blue</span>
                  {/if}
                  {#if canonica.fotossensivel}
                    <span class="px-2 py-1 bg-amber-100 text-amber-700 text-xs rounded-full font-medium">☀️ Foto</span>
                  {/if}
                  {#if canonica.polarizado}
                    <span class="px-2 py-1 bg-purple-100 text-purple-700 text-xs rounded-full font-medium">🕶️ Polar</span>
                  {/if}
                </div>
              {/if}

              <!-- Stats -->
              <div class="pt-3 border-t border-slate-200">
                <div class="grid grid-cols-2 gap-2 text-center">
                  <div>
                    <div class="text-xs text-slate-500">Lentes Ativas</div>
                    <div class="text-lg font-bold text-amber-600">{canonica.lentes_ativas || 0}</div>
                  </div>
                  <div>
                    <div class="text-xs text-slate-500">Preço Médio</div>
                    <div class="text-sm font-bold text-emerald-600">
                      {canonica.preco_medio ? `R$ ${canonica.preco_medio.toFixed(0)}` : '-'}
                    </div>
                  </div>
                </div>
              </div>

              <!-- Faixa de Preço -->
              {#if canonica.preco_minimo && canonica.preco_maximo}
                <div class="text-xs text-slate-600 pt-2 border-t">
                  <strong>Faixa:</strong> R$ {canonica.preco_minimo.toFixed(0)} - R$ {canonica.preco_maximo.toFixed(0)}
                </div>
              {/if}
            </div>

            <!-- Footer -->
            <div class="px-5 pb-4">
              <a
                href="/catalogo/comparar?id={canonica.id}"
                class="block w-full text-center py-2 bg-gradient-to-r from-amber-500 to-orange-600 text-white rounded-lg font-medium hover:from-amber-600 hover:to-orange-700 transition-all"
              >
                Ver Detalhes →
              </a>
            </div>
          </div>
        {/each}
      </div>

      <!-- Contador -->
      <div class="mt-8 text-center text-slate-600">
        Exibindo {filtradas.length} de {canonicas.length} produtos premium
      </div>
    {/if}
  </div>
</main>
