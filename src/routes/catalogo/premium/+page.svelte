<!--
  🏆 Premium - Lentes Canônicas Premium (250 grupos)
  Dados reais da view vw_canonicas_premium
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { CanonicaPremium } from '$lib/types/database-views';

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

<Container maxWidth="xl" padding="lg">
    
    <!-- Header -->
    <PageHero
      badge="🏆 Premium"
      title="Lentes Premium"
      subtitle={`${canonicas.length} produtos premium de alta qualidade`}
      alignment="center"
      maxWidth="lg"
    />

    <!-- Filtros -->
    <section class="glass-panel p-6 rounded-xl shadow-lg mb-8 mt-8">
      <SectionHeader
        title="🔍 Filtros de Busca"
        subtitle="Refine sua pesquisa"
      />
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
        <!-- Busca -->
        <Input
          label="🔍 Buscar"
          bind:value={filtroBusca}
          placeholder="Nome, marca ou linha..."
          type="text"
        />

        <!-- Marca -->
        <Select
          label="🏭 Marca"
          bind:value={filtroMarca}
          options={[
            { value: '', label: 'Todas as marcas' },
            ...marcasUnicas.map(m => ({ value: m, label: m }))
          ]}
        />

        <!-- Tipo -->
        <Select
          label="👓 Tipo de Lente"
          bind:value={filtroTipo}
          on:change={carregarDados}
          options={[
            { value: '', label: 'Todos os tipos' },
            { value: 'visao_simples', label: 'Visão Simples' },
            { value: 'multifocal', label: 'Multifocal' },
            { value: 'bifocal', label: 'Bifocal' }
          ]}
        />
      </div>
    </section>

    <!-- Loading -->
    {#if loading}
      <div class="flex flex-col justify-center items-center py-20">
        <LoadingSpinner size="lg" />
        <p class="mt-4 text-slate-600">Carregando produtos premium...</p>
      </div>
    
    <!-- Error -->
    {:else if error}
      <div class="bg-red-50 border-2 border-red-200 rounded-2xl p-8 text-center">
        <div class="text-5xl mb-4">⚠️</div>
        <p class="text-red-800 text-lg font-medium mb-4">{error}</p>
        <Button
          variant="danger"
          on:click={carregarDados}
        >
          Tentar Novamente
        </Button>
      </div>
    
    <!-- Empty State -->
    {:else if filtradas.length === 0}
      <div class="text-center py-20 bg-white/60 rounded-2xl backdrop-blur-sm">
        <div class="text-6xl mb-4">🔍</div>
        <h3 class="text-2xl font-bold text-slate-900 mb-2">Nenhum produto encontrado</h3>
        <p class="text-slate-600 mb-4">Tente ajustar os filtros de busca</p>
        <Button
          variant="secondary"
          on:click={() => {
            filtroBusca = '';
            filtroMarca = '';
            filtroTipo = '';
          }}
        >
          Limpar Filtros
        </Button>
      </div>
    
    <!-- Grid de Premium -->
    {:else}
      <SectionHeader
        title="✨ Produtos Premium"
        subtitle={`Exibindo ${filtradas.length} de ${canonicas.length} produtos`}
      />
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6">
        {#each filtradas as canonica}
          <div class="bg-white/95 backdrop-blur-sm rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 border border-indigo-100 overflow-hidden group hover:-translate-y-1">
            
            <!-- Header com Marca -->
            <div class="bg-gradient-to-r from-indigo-600 to-purple-600 p-5">
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
                href="/catalogo/premium/{canonica.id}"
                class="block w-full text-center py-2 bg-gradient-to-r from-indigo-600 to-purple-600 text-white rounded-lg font-medium hover:from-indigo-700 hover:to-purple-700 transition-all"
              >
                Comparar Laboratórios →
              </a>
            </div>
          </div>
        {/each}
      </div>

    {/if}
  </Container>
