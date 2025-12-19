<!--
  📚 Catálogo - Lentes Canônicas Genéricas (187 grupos)
  Dados reais da view vw_canonicas_genericas
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { CanonicaGenerica } from '$lib/types/database-views';

  // State
  let canonicas: CanonicaGenerica[] = [];
  let loading = true;
  let error = '';
  
  // Filtros
  let filtroTipo = '';
  let filtroMaterial = '';
  let filtroBusca = '';

  // Carregar dados
  onMount(async () => {
    await carregarDados();
  });

  async function carregarDados() {
    loading = true;
    error = '';
    
    const resultado = await CatalogoAPI.listarCanonicasGenericas(
      {
        tipos: filtroTipo ? [filtroTipo as any] : undefined,
        materiais: filtroMaterial ? [filtroMaterial as any] : undefined
      },
      { limite: 200, ordenar: 'nome_canonico', direcao: 'asc' }
    );

    if (resultado.success && resultado.data) {
      canonicas = resultado.data.dados;
    } else {
      error = resultado.error || 'Erro ao carregar catálogo';
    }
    
    loading = false;
  }

  // Filtro de busca local
  $: filtradas = canonicas.filter(c => {
    const busca = filtroBusca.toLowerCase();
    if (!busca) return true;
    return c.nome_canonico.toLowerCase().includes(busca);
  });
</script>

<svelte:head>
  <title>Catálogo de Lentes - SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-purple-50 py-12">
  <div class="container mx-auto px-4 max-w-7xl">
    
    <!-- Header -->
    <header class="text-center mb-12">
      <div class="inline-block px-4 py-2 bg-violet-100 text-violet-700 rounded-full text-sm font-medium mb-4">
        📚 Catálogo
      </div>
      <h1 class="text-4xl md:text-5xl font-bold text-slate-900 mb-4">
        Lentes Canônicas
      </h1>
      <p class="text-lg text-slate-600 max-w-2xl mx-auto">
        {canonicas.length} grupos normalizados disponíveis
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
            placeholder="Nome da lente..."
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-transparent"
          />
        </div>

        <!-- Tipo -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            👓 Tipo
          </label>
          <select
            bind:value={filtroTipo}
            on:change={carregarDados}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-transparent"
          >
            <option value="">Todos</option>
            <option value="visao_simples">Visão Simples</option>
            <option value="multifocal">Multifocal</option>
            <option value="bifocal">Bifocal</option>
          </select>
        </div>

        <!-- Material -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            🧪 Material
          </label>
          <select
            bind:value={filtroMaterial}
            on:change={carregarDados}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-violet-500 focus:border-transparent"
          >
            <option value="">Todos</option>
            <option value="CR39">CR39</option>
            <option value="POLICARBONATO">Policarbonato</option>
            <option value="TRIVEX">Trivex</option>
            <option value="HIGH_INDEX">High Index</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading -->
    {#if loading}
      <div class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-violet-600"></div>
        <span class="ml-4 text-slate-600">Carregando catálogo...</span>
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
        <h3 class="text-2xl font-bold text-slate-900 mb-2">Nenhuma lente encontrada</h3>
        <p class="text-slate-600">Tente ajustar os filtros</p>
      </div>
    
    <!-- Grid de Canônicas -->
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {#each filtradas as canonica}
          <div class="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 border border-slate-200 overflow-hidden">
            
            <!-- Header -->
            <div class="bg-gradient-to-r from-violet-500 to-purple-600 p-4">
              <h3 class="font-semibold text-white text-lg leading-tight">
                {canonica.nome_canonico}
              </h3>
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
                  <div class="font-medium text-slate-900 capitalize text-xs">
                    {canonica.categoria.replace('_', ' ')}
                  </div>
                </div>
              </div>

              <!-- Tratamentos -->
              {#if canonica.ar || canonica.blue || canonica.fotossensivel || canonica.polarizado}
                <div class="flex flex-wrap gap-2">
                  {#if canonica.ar}
                    <span class="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full">AR</span>
                  {/if}
                  {#if canonica.blue}
                    <span class="px-2 py-1 bg-cyan-100 text-cyan-700 text-xs rounded-full">Blue</span>
                  {/if}
                  {#if canonica.fotossensivel}
                    <span class="px-2 py-1 bg-amber-100 text-amber-700 text-xs rounded-full">Foto</span>
                  {/if}
                  {#if canonica.polarizado}
                    <span class="px-2 py-1 bg-purple-100 text-purple-700 text-xs rounded-full">Polar</span>
                  {/if}
                </div>
              {/if}

              <!-- Stats -->
              <div class="pt-3 border-t border-slate-200">
                <div class="grid grid-cols-3 gap-2 text-center">
                  <div>
                    <div class="text-xs text-slate-500">Lentes</div>
                    <div class="text-lg font-bold text-violet-600">{canonica.lentes_ativas || 0}</div>
                  </div>
                  <div>
                    <div class="text-xs text-slate-500">Marcas</div>
                    <div class="text-lg font-bold text-violet-600">{canonica.total_marcas || 0}</div>
                  </div>
                  <div>
                    <div class="text-xs text-slate-500">Preço</div>
                    <div class="text-sm font-bold text-emerald-600">
                      {canonica.preco_medio ? `R$ ${canonica.preco_medio.toFixed(0)}` : '-'}
                    </div>
                  </div>
                </div>
              </div>

              <!-- Marcas -->
              {#if canonica.marcas_disponiveis && canonica.marcas_disponiveis.length > 0}
                <div class="text-xs text-slate-600 pt-2 border-t">
                  <strong>Marcas:</strong> {canonica.marcas_disponiveis.join(', ')}
                </div>
              {/if}
            </div>

            <!-- Footer -->
            <div class="px-5 pb-4">
              <a
                href="/catalogo/comparar?id={canonica.id}"
                class="block w-full text-center py-2 bg-gradient-to-r from-violet-500 to-purple-600 text-white rounded-lg font-medium hover:from-violet-600 hover:to-purple-700 transition-all"
              >
                Ver Detalhes →
              </a>
            </div>
          </div>
        {/each}
      </div>

      <!-- Contador -->
      <div class="mt-8 text-center text-slate-600">
        Exibindo {filtradas.length} de {canonicas.length} grupos canônicos
      </div>
    {/if}
  </div>
</main>
