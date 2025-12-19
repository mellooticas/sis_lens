<!--
  📚 Catálogo - Lentes Canônicas Genéricas (187 grupos)
  Dados reais da view vw_canonicas_genericas
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { CanonicaGenerica } from '$lib/types/database-views';

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

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero -->
    <PageHero
      badge="📚 Catálogo"
      title="Lentes Canônicas"
      subtitle="{canonicas.length} grupos normalizados disponíveis"
    />

    <!-- Filtros -->
    <section class="glass-panel p-6 rounded-xl shadow-lg mb-8 mt-8">
      <SectionHeader
        title="🔍 Filtros"
        subtitle="Refine sua busca por grupos canônicos"
      />

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
        <!-- Busca -->
        <Input
          label="Buscar"
          bind:value={filtroBusca}
          placeholder="Nome da lente..."
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
          ]}
          on:change={carregarDados}
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
          ]}
          on:change={carregarDados}
        />
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
        <Button variant="danger" on:click={carregarDados}>
          Tentar novamente
        </Button>
      </section>

    <!-- Empty State -->
    {:else if filtradas.length === 0}
      <section class="glass-panel p-12 rounded-xl shadow-lg text-center">
        <div class="text-6xl mb-4">🔍</div>
        <h3 class="text-2xl font-bold text-neutral-900 dark:text-neutral-100 mb-2">
          Nenhuma lente encontrada
        </h3>
        <p class="text-neutral-600 dark:text-neutral-400">
          Tente ajustar os filtros
        </p>
      </section>

    <!-- Grid de Canônicas -->
    {:else}
      <section>
        <SectionHeader
          title="📦 Grupos Canônicos"
          subtitle="{filtradas.length} grupos encontrados"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6">
          {#each filtradas as canonica}
            <div class="glass-panel rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden">
            
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
                    <Badge variant="primary" size="sm">AR</Badge>
                  {/if}
                  {#if canonica.blue}
                    <Badge variant="info" size="sm">Blue</Badge>
                  {/if}
                  {#if canonica.fotossensivel}
                    <Badge variant="warning" size="sm">Foto</Badge>
                  {/if}
                  {#if canonica.polarizado}
                    <Badge variant="purple" size="sm">Polar</Badge>
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
              <Button
                variant="primary"
                fullWidth
                on:click={() => window.location.href = `/catalogo/${canonica.id}`}
              >
                Comparar Laboratórios →
              </Button>
            </div>
          </div>
        {/each}
        </div>

        <!-- Contador -->
        <div class="mt-8 text-center text-neutral-600 dark:text-neutral-400">
          Exibindo {filtradas.length} de {canonicas.length} grupos canônicos
        </div>
      </section>
    {/if}
  </Container>
</main>
