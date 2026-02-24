<!--
  ⚖️ Página de Grupos Canônicos - Comparação
  Pesquise grupos canônicos e navegue para ver lentes disponíveis
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import type { VCatalogLensGroup } from '$lib/types/database-views';

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";

  // Hook com dados reais
  import { useCompararFornecedores } from "$lib/hooks/useCompararFornecedores";

  // State do hook
  const { state, compararPorGrupo } = useCompararFornecedores();

  // Obter parâmetros da URL
  $: grupoParam = $page.url.searchParams.get('grupo') || '';

  // Dados reativos
  $: comparacoes = ($state.comparacoes || []) as unknown as VCatalogLensGroup[];
  $: loading = $state.loading;
  $: error = $state.error;

  // Buscar dados automaticamente se há grupo na URL
  $: if (grupoParam && !loading && comparacoes.length === 0) {
    compararPorGrupo(grupoParam);
  }

  // Estado local para busca
  let grupoInput = grupoParam;

  // Funções
  function buscarGrupo() {
    if (!grupoInput.trim()) return;
    goto(`/comparar?grupo=${encodeURIComponent(grupoInput)}`);
    compararPorGrupo(grupoInput);
  }

  function limpar() {
    grupoInput = '';
    goto('/comparar');
  }

  function verDetalhes(grupo: VCatalogLensGroup) {
    const rota = grupo.is_premium ? 'premium' : 'standard';
    goto(`/catalogo/${rota}/${grupo.id}`);
  }
</script>

<svelte:head>
  <title>Grupos Canônicos - SIS Lens</title>
  <meta
    name="description"
    content="Pesquise grupos canônicos por nome ou ID para ver lentes disponíveis"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero Section -->
    <PageHero
      badge="⚖️ Grupos Canônicos"
      title="Comparar Grupos"
      subtitle="Pesquise grupos canônicos por nome ou ID para ver todas as lentes disponíveis"
      alignment="center"
      maxWidth="lg"
    />

    <!-- Busca por Grupo -->
    <section class="mt-8">
      <div class="glass-panel rounded-xl p-6 shadow-xl max-w-2xl mx-auto">
        <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-4">
          Buscar Grupo Canônico
        </h3>

        <form on:submit|preventDefault={buscarGrupo} class="flex gap-4">
          <input
            type="text"
            bind:value={grupoInput}
            placeholder="Nome ou ID do grupo..."
            class="flex-1 px-4 py-2 rounded-lg border border-neutral-300 dark:border-neutral-600
                   bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100
                   focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />

          <Button variant="primary" type="submit" disabled={!grupoInput.trim()}>
            🔍 Buscar
          </Button>

          {#if grupoInput}
            <Button variant="ghost" type="button" on:click={limpar}>
              Limpar
            </Button>
          {/if}
        </form>

        <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-2">
          Digite o nome ou ID do grupo canônico para ver as lentes e fornecedores disponíveis
        </p>
      </div>
    </section>

    <!-- Resultados -->
    <section class="mt-12">
      {#if loading}
        <div class="flex justify-center py-12">
          <LoadingSpinner size="lg" />
        </div>
      {:else if error}
        <EmptyState
          icon="⚠️"
          title="Erro ao carregar grupos"
          description={error}
        />
      {:else if comparacoes.length === 0 && grupoParam}
        <EmptyState
          icon="🔍"
          title="Nenhum grupo encontrado"
          description="Não encontramos grupos para este identificador"
        />
      {:else if comparacoes.length > 0}
        <SectionHeader
          title="Grupos Encontrados"
          subtitle={`${comparacoes.length} grupo${comparacoes.length !== 1 ? 's' : ''} encontrado${comparacoes.length !== 1 ? 's' : ''} para "${grupoParam}"`}
        />

        <div class="mt-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {#each comparacoes as grupo}
            <div class="glass-panel rounded-xl p-6 shadow-xl hover:shadow-2xl transition-all duration-300">
              <div class="flex flex-wrap gap-2 mb-3">
                {#if grupo.is_premium}
                  <Badge variant="gold" size="sm">⭐ Premium</Badge>
                {:else}
                  <Badge variant="primary" size="sm">Standard</Badge>
                {/if}
                {#if grupo.lens_type}
                  <Badge variant="neutral" size="sm">{grupo.lens_type.replace('_', ' ')}</Badge>
                {/if}
                <Badge variant="success" size="sm">
                  Ativo
                </Badge>
              </div>

              <h3 class="text-lg font-bold text-neutral-900 dark:text-neutral-100 mb-3">
                {grupo.name}
              </h3>

              <div class="space-y-2 text-sm mb-4">
                <div class="flex justify-between">
                  <span class="text-neutral-600 dark:text-neutral-400">Material:</span>
                  <span class="font-medium">{grupo.material}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-neutral-600 dark:text-neutral-400">Índice:</span>
                  <span class="font-medium">{grupo.refractive_index}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-neutral-600 dark:text-neutral-400">Tipo:</span>
                  <span class="font-medium capitalize">{(grupo.lens_type || '').replace('_', ' ')}</span>
                </div>
              </div>

              <Button
                variant="primary"
                size="sm"
                fullWidth
                on:click={() => verDetalhes(grupo)}
              >
                Ver Lentes Disponíveis →
              </Button>
            </div>
          {/each}
        </div>
      {:else}
        <EmptyState
          icon="⚖️"
          title="Pesquise um grupo"
          description="Digite o nome ou ID de um grupo canônico acima para ver as lentes disponíveis"
        />
      {/if}
    </section>

    <!-- Atalhos para Catálogos -->
    {#if !grupoParam}
      <section class="mt-12">
        <SectionHeader
          title="Navegar por Catálogos"
          subtitle="Ou explore diretamente pelos catálogos completos"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          <button
            class="glass-panel rounded-lg p-6 hover:shadow-lg transition-shadow text-left"
            on:click={() => goto('/catalogo/standard')}
          >
            <p class="text-xl font-bold text-blue-600 dark:text-blue-400 mb-2">📦 Catálogo Standard</p>
            <p class="text-sm text-neutral-600 dark:text-neutral-400">
              Explore grupos canônicos standard com lentes acessíveis
            </p>
          </button>

          <button
            class="glass-panel rounded-lg p-6 hover:shadow-lg transition-shadow text-left"
            on:click={() => goto('/catalogo/premium')}
          >
            <p class="text-xl font-bold text-yellow-600 dark:text-yellow-400 mb-2">⭐ Catálogo Premium</p>
            <p class="text-sm text-neutral-600 dark:text-neutral-400">
              Explore grupos canônicos premium de alta performance
            </p>
          </button>
        </div>
      </section>
    {/if}
  </Container>
</main>
