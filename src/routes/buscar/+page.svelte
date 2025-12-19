<!--
  🔍 Buscar - Todas as Lentes (1,411 lentes)
  Dados reais da view vw_lentes_catalogo
  Busca completa com filtros avançados
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { LenteCatalogo } from '$lib/types/database-views';

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Input from "$lib/components/forms/Input.svelte";
  import Select from "$lib/components/forms/Select.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

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

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero -->
    <PageHero
      badge="🔍 Buscar"
      title="Catálogo Completo"
      subtitle="{total.toLocaleString('pt-BR')} lentes disponíveis de todos os laboratórios"
    />

    <!-- Filtros -->
    <section class="glass-panel p-6 rounded-xl shadow-lg mb-8 mt-8">
      <SectionHeader
        title="🔍 Filtros de Busca"
        subtitle="Refine sua pesquisa no catálogo"
      />

      <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6 mt-6">
        <!-- Busca -->
        <div class="md:col-span-2">
          <Input
            label="Buscar por nome"
            bind:value={filtroBusca}
            placeholder="Digite o nome da lente..."
            on:keypress={(e) => e.key === 'Enter' && aplicarFiltros()}
          />
        </div>

        <!-- Marca -->
        <Select
          label="Marca"
          bind:value={filtroMarca}
          options={[
            { value: "", label: "Todas" },
            ...(marcas || []).map((m) => ({
              value: m,
              label: m,
            })),
          ]}
        />

        <!-- Categoria -->
        <Select
          label="Categoria"
          bind:value={filtroCategoria}
          options={[
            { value: "", label: "Todas" },
            { value: "economica", label: "Econômica" },
            { value: "intermediaria", label: "Intermediária" },
            { value: "premium", label: "Premium" },
            { value: "super_premium", label: "Super Premium" },
          ]}
        />

        <!-- Tipo -->
        <Select
          label="Tipo"
          bind:value={filtroTipo}
          options={[
            { value: "", label: "Todos" },
            { value: "visao_simples", label: "Visão Simples" },
            { value: "multifocal", label: "Multifocal" },
            { value: "bifocal", label: "Bifocal" },
            { value: "leitura", label: "Leitura" },
            { value: "ocupacional", label: "Ocupacional" },
          ]}
        />

        <!-- Material -->
        <Select
          label="Material"
          bind:value={filtroMaterial}
          options={[
            { value: "", label: "Todos" },
            { value: "CR39", label: "CR39" },
            { value: "POLICARBONATO", label: "Policarbonato" },
            { value: "TRIVEX", label: "Trivex" },
            { value: "HIGH_INDEX", label: "High Index" },
            { value: "VIDRO", label: "Vidro" },
          ]}
        />

        <!-- Índice -->
        <Select
          label="Índice"
          bind:value={filtroIndice}
          options={[
            { value: "", label: "Todos" },
            { value: "1.50", label: "1.50" },
            { value: "1.56", label: "1.56" },
            { value: "1.59", label: "1.59" },
            { value: "1.61", label: "1.61" },
            { value: "1.67", label: "1.67" },
            { value: "1.74", label: "1.74" },
          ]}
        />
      </div>

      <!-- Botões -->
      <div class="flex justify-end gap-3 mt-6">
        <Button variant="ghost" on:click={limparFiltros}>Limpar</Button>
        <Button variant="primary" on:click={aplicarFiltros}>Buscar</Button>
      </div>
    </section>

    <!-- Loading -->
    {#if loading}
      <div class="flex justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>

    <!-- Error -->
    {:else if error}
      <section class="glass-panel p-6 rounded-xl shadow-lg text-center">
        <p class="text-red-600 dark:text-red-400 mb-4">⚠️ {error}</p>
        <Button variant="danger" on:click={carregarLentes}>
          Tentar novamente
        </Button>
      </section>

    <!-- Empty State -->
    {:else if lentes.length === 0}
      <section class="glass-panel p-12 rounded-xl shadow-lg text-center">
        <div class="text-6xl mb-4">🔍</div>
        <h3 class="text-2xl font-bold text-neutral-900 dark:text-neutral-100 mb-2">
          Nenhuma lente encontrada
        </h3>
        <p class="text-neutral-600 dark:text-neutral-400 mb-6">
          Tente ajustar os filtros de busca
        </p>
        <Button variant="primary" on:click={limparFiltros}>
          Limpar Filtros
        </Button>
      </section>
    
    <!-- Grid de Lentes -->
    {:else}
      <section>
        <SectionHeader
          title="📦 Resultados da Busca"
          subtitle="{lentes.length} lentes encontradas"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8 mt-6">
          {#each lentes as lente}
            <div class="glass-panel rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden">
            
            <!-- Header -->
            <div class="bg-gradient-to-r from-blue-500 to-indigo-600 p-4">
              <div class="flex items-start justify-between mb-2">
                <Badge variant="neutral" size="sm">
                  {lente.marca_nome}
                </Badge>
                <Badge variant="neutral" size="sm">
                  {lente.categoria.replace('_', ' ')}
                </Badge>
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

            <!-- Botão Ver Detalhes -->
            <div class="px-4 pb-4">
              <a
                href="/buscar/{lente.id}"
                class="block w-full text-center py-2 bg-gradient-to-r from-indigo-600 to-purple-600 text-white rounded-lg font-medium hover:from-indigo-700 hover:to-purple-700 transition-all"
              >
                Ver Detalhes →
              </a>
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

        <div class="mt-4 text-center text-sm text-neutral-600 dark:text-neutral-400">
          Página {paginaAtual} de {totalPaginas} • {total.toLocaleString('pt-BR')} lentes no total
        </div>
      {/if}
      </section>
    {/if}
  </Container>
</main>
