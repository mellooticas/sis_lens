<!--
  🔍 Buscar - Todas as Lentes (1,411 lentes)
  Dados reais da view vw_lentes_catalogo
  Busca completa com filtros avançados
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { LenteCatalogo } from '$lib/types/database-views';

  // State
  let lentes: LenteCatalogo[] = [];
  let loading = true;
  let error = '';
  let total = 0;
  let paginaAtual = 1;
  const itensPorPagina = 12;
  
  // Filtros
  let filtroBusca = '';
  let filtroTipo = '';
  let filtroMaterial = '';
  let filtroIndice = '';
  let filtroMarca = '';
  let filtroCategoria = '';
  
  // Filtros disponíveis
  let marcas: string[] = [];

  // Carregar dados
  onMount(async () => {
    await Promise.all([
      carregarMarcas(),
      carregarLentes()
    ]);
  });

  async function carregarMarcas() {
    const resultado = await CatalogoAPI.listarMarcas();
    if (resultado.success && resultado.data) {
      marcas = resultado.data;
    }
  }

  async function carregarLentes() {
    try {
      loading = true;
      error = '';
      
      const resultado = await CatalogoAPI.buscarLentes(
        {
          busca: filtroBusca || undefined,
          tipos: filtroTipo ? [filtroTipo as any] : undefined,
          materiais: filtroMaterial ? [filtroMaterial as any] : undefined,
          indices: filtroIndice ? [filtroIndice as any] : undefined,
          categorias: filtroCategoria ? [filtroCategoria as any] : undefined,
          marcas: filtroMarca ? [filtroMarca] : undefined
        },
        { 
          pagina: paginaAtual, 
          limite: itensPorPagina,
          ordenar: 'nome_comercial',
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

  // Resetar página ao filtrar
  async function aplicarFiltros() {
    paginaAtual = 1;
    await carregarLentes();
  }

  async function limparFiltros() {
    filtroBusca = '';
    filtroTipo = '';
    filtroMaterial = '';
    filtroIndice = '';
    filtroMarca = '';
    filtroCategoria = '';
    paginaAtual = 1;
    await carregarLentes();
  }

  async function mudarPagina(pagina: number) {
    paginaAtual = pagina;
    await carregarLentes();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  // Paginação
  $: totalPaginas = Math.ceil(total / itensPorPagina);
  $: paginasVisiveis = (() => {
    const paginas: number[] = [];
    const inicio = Math.max(1, paginaAtual - 2);
    const fim = Math.min(totalPaginas, paginaAtual + 2);
    for (let i = inicio; i <= fim; i++) {
      paginas.push(i);
    }
    return paginas;
  })();
</script>

<svelte:head>
  <title>Buscar Lentes - SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 py-12">
  <div class="container mx-auto px-4 max-w-7xl">
    
    <!-- Header -->
    <header class="text-center mb-12">
      <div class="inline-block px-4 py-2 bg-blue-100 text-blue-700 rounded-full text-sm font-medium mb-4">
        🔍 Buscar Lentes
      </div>
      <h1 class="text-4xl md:text-5xl font-bold text-slate-900 mb-4">
        Catálogo Completo
      </h1>
      <p class="text-lg text-slate-600 max-w-2xl mx-auto">
        {total.toLocaleString('pt-BR')} lentes disponíveis de todos os laboratórios
      </p>
    </header>

    <!-- Filtros -->
    <div class="bg-white/80 backdrop-blur-sm rounded-2xl shadow-lg p-6 mb-8">
      <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4 mb-4">
        <!-- Busca -->
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-slate-700 mb-2">
            🔍 Buscar por nome
          </label>
          <input
            type="text"
            bind:value={filtroBusca}
            placeholder="Digite o nome da lente..."
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            on:keypress={(e) => e.key === 'Enter' && aplicarFiltros()}
          />
        </div>

        <!-- Marca -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            🏭 Marca
          </label>
          <select
            bind:value={filtroMarca}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todas</option>
            {#each marcas as marca}
              <option value={marca}>{marca}</option>
            {/each}
          </select>
        </div>

        <!-- Categoria -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            ⭐ Categoria
          </label>
          <select
            bind:value={filtroCategoria}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todas</option>
            <option value="economica">Econômica</option>
            <option value="intermediaria">Intermediária</option>
            <option value="premium">Premium</option>
            <option value="super_premium">Super Premium</option>
          </select>
        </div>

        <!-- Tipo -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            👓 Tipo
          </label>
          <select
            bind:value={filtroTipo}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todos</option>
            <option value="visao_simples">Visão Simples</option>
            <option value="multifocal">Multifocal</option>
            <option value="bifocal">Bifocal</option>
            <option value="leitura">Leitura</option>
            <option value="ocupacional">Ocupacional</option>
          </select>
        </div>

        <!-- Material -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            🧪 Material
          </label>
          <select
            bind:value={filtroMaterial}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todos</option>
            <option value="CR39">CR39</option>
            <option value="POLICARBONATO">Policarbonato</option>
            <option value="TRIVEX">Trivex</option>
            <option value="HIGH_INDEX">High Index</option>
            <option value="VIDRO">Vidro</option>
          </select>
        </div>

        <!-- Índice -->
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-2">
            📐 Índice
          </label>
          <select
            bind:value={filtroIndice}
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Todos</option>
            <option value="1.50">1.50</option>
            <option value="1.56">1.56</option>
            <option value="1.59">1.59</option>
            <option value="1.61">1.61</option>
            <option value="1.67">1.67</option>
            <option value="1.74">1.74</option>
          </select>
        </div>
      </div>

      <!-- Botões -->
      <div class="flex gap-3">
        <button
          on:click={aplicarFiltros}
          class="px-6 py-2 bg-gradient-to-r from-blue-500 to-indigo-600 text-white rounded-lg font-medium hover:from-blue-600 hover:to-indigo-700 transition-all"
        >
          🔍 Buscar
        </button>
        <button
          on:click={limparFiltros}
          class="px-6 py-2 bg-slate-200 text-slate-700 rounded-lg font-medium hover:bg-slate-300 transition-all"
        >
          🔄 Limpar
        </button>
      </div>
    </div>

    <!-- Loading -->
    {#if loading}
      <div class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        <span class="ml-4 text-slate-600">Buscando lentes...</span>
      </div>
    
    <!-- Error -->
    {:else if error}
      <div class="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <p class="text-red-800">⚠️ {error}</p>
        <button
          on:click={carregarLentes}
          class="mt-4 px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Tentar novamente
        </button>
      </div>
    
    <!-- Empty State -->
    {:else if lentes.length === 0}
      <div class="text-center py-20">
        <div class="text-6xl mb-4">🔍</div>
        <h3 class="text-2xl font-bold text-slate-900 mb-2">Nenhuma lente encontrada</h3>
        <p class="text-slate-600 mb-6">Tente ajustar os filtros de busca</p>
        <button
          on:click={limparFiltros}
          class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Limpar Filtros
        </button>
      </div>
    
    <!-- Grid de Lentes -->
    {:else}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
        {#each lentes as lente}
          <div class="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 border border-slate-200 overflow-hidden">
            
            <!-- Header -->
            <div class="bg-gradient-to-r from-blue-500 to-indigo-600 p-4">
              <div class="flex items-start justify-between mb-2">
                <span class="px-2 py-1 bg-white/20 text-white text-xs rounded-full">
                  {lente.marca_nome}
                </span>
                <span class="px-2 py-1 bg-white/20 text-white text-xs rounded-full capitalize">
                  {lente.categoria.replace('_', ' ')}
                </span>
              </div>
              <h3 class="font-semibold text-white text-lg leading-tight">
                {lente.nome_comercial}
              </h3>
            </div>

            <!-- Corpo -->
            <div class="p-4 space-y-3">
              <!-- Specs -->
              <div class="grid grid-cols-3 gap-2 text-xs">
                <div class="bg-slate-50 px-2 py-1 rounded text-center">
                  <div class="text-slate-500">Tipo</div>
                  <div class="font-medium text-slate-900 capitalize text-[10px]">
                    {lente.tipo_lente.replace('_', ' ')}
                  </div>
                </div>
                <div class="bg-slate-50 px-2 py-1 rounded text-center">
                  <div class="text-slate-500">Material</div>
                  <div class="font-medium text-slate-900 text-[10px]">{lente.material}</div>
                </div>
                <div class="bg-slate-50 px-2 py-1 rounded text-center">
                  <div class="text-slate-500">Índice</div>
                  <div class="font-medium text-slate-900">{lente.indice_refracao}</div>
                </div>
              </div>

              <!-- Tratamentos -->
              {#if lente.ar || lente.blue || lente.fotossensivel || lente.polarizado}
                <div class="flex flex-wrap gap-1">
                  {#if lente.ar}<span class="px-2 py-0.5 bg-blue-100 text-blue-700 text-[10px] rounded-full">AR</span>{/if}
                  {#if lente.blue}<span class="px-2 py-0.5 bg-cyan-100 text-cyan-700 text-[10px] rounded-full">Blue</span>{/if}
                  {#if lente.fotossensivel}<span class="px-2 py-0.5 bg-amber-100 text-amber-700 text-[10px] rounded-full">Foto</span>{/if}
                  {#if lente.polarizado}<span class="px-2 py-0.5 bg-purple-100 text-purple-700 text-[10px] rounded-full">Polar</span>{/if}
                </div>
              {/if}

              <!-- Preço -->
              <div class="pt-3 border-t">
                <div class="text-center">
                  <div class="text-2xl font-bold text-emerald-600">
                    R$ {(lente.preco_tabela || 0).toFixed(0)}
                  </div>
                  {#if lente.desconto_promocional && lente.desconto_promocional > 0}
                    <div class="text-xs text-red-600 font-medium">
                      -{lente.desconto_promocional}% OFF
                    </div>
                  {/if}
                </div>
              </div>

              <!-- Info Adicional -->
              {#if lente.linha_produto}
                <div class="text-xs text-slate-600 text-center pt-2 border-t">
                  <strong>Linha:</strong> {lente.linha_produto}
                </div>
              {/if}
            </div>
          </div>
        {/each}
      </div>

      <!-- Paginação -->
      {#if totalPaginas > 1}
        <div class="flex items-center justify-center gap-2">
          <button
            on:click={() => mudarPagina(paginaAtual - 1)}
            disabled={paginaAtual === 1}
            class="px-4 py-2 bg-white border border-slate-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-slate-50"
          >
            ← Anterior
          </button>

          {#if paginasVisiveis[0] > 1}
            <button
              on:click={() => mudarPagina(1)}
              class="px-4 py-2 bg-white border border-slate-300 rounded-lg hover:bg-slate-50"
            >
              1
            </button>
            {#if paginasVisiveis[0] > 2}
              <span class="px-2 text-slate-500">...</span>
            {/if}
          {/if}

          {#each paginasVisiveis as pagina}
            <button
              on:click={() => mudarPagina(pagina)}
              class="px-4 py-2 rounded-lg {pagina === paginaAtual ? 'bg-blue-600 text-white' : 'bg-white border border-slate-300 hover:bg-slate-50'}"
            >
              {pagina}
            </button>
          {/each}

          {#if paginasVisiveis[paginasVisiveis.length - 1] < totalPaginas}
            {#if paginasVisiveis[paginasVisiveis.length - 1] < totalPaginas - 1}
              <span class="px-2 text-slate-500">...</span>
            {/if}
            <button
              on:click={() => mudarPagina(totalPaginas)}
              class="px-4 py-2 bg-white border border-slate-300 rounded-lg hover:bg-slate-50"
            >
              {totalPaginas}
            </button>
          {/if}

          <button
            on:click={() => mudarPagina(paginaAtual + 1)}
            disabled={paginaAtual === totalPaginas}
            class="px-4 py-2 bg-white border border-slate-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-slate-50"
          >
            Próxima →
          </button>
        </div>

        <div class="mt-4 text-center text-sm text-slate-600">
          Página {paginaAtual} de {totalPaginas} • {total.toLocaleString('pt-BR')} lentes no total
        </div>
      {/if}
    {/if}
  </div>
</main>
