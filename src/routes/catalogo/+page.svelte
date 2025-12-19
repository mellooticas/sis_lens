<!--
  📚 Página de Catálogo de Lentes - Grupos Canônicos
  Exibe grupos genéricos e premium com dados reais
-->
<script lang="ts">
  import { goto } from "$app/navigation";

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";

  // Hooks com dados reais
  import { useGruposCanonicos } from "$lib/hooks/useGruposCanonicos";
  import { useStatsCatalogo } from "$lib/hooks/useStatsCatalogo";
  
  // State dos hooks
  const { 
    state: gruposState, 
    carregarGruposGenericos, 
    carregarGruposPremium 
  } = useGruposCanonicos();
  
  const { state: statsState } = useStatsCatalogo();

  // Dados reativos
  $: gruposGenericos = $gruposState.gruposGenericos || [];
  $: gruposPremium = $gruposState.gruposPremium || [];
  $: loading = $gruposState.loading || $statsState.loading;
  $: error = $gruposState.error || $statsState.error;
  $: stats = $statsState.stats;

  // Estado de visualização
  let tabAtiva: 'genericos' | 'premium' = 'genericos';
  
  // Funções
  function verGrupo(id: number, tipo: 'genericos' | 'premium') {
    goto(`/catalogo/${tipo}/${id}`);
  }
</script>

<svelte:head>
  <title>Catálogo de Lentes - SIS Lens</title>
  <meta
    name="description"
    content="Catálogo completo de grupos canônicos - Genéricos e Premium"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero Section -->
    <PageHero
      badge="📚 Catálogo Completo"
      title="Grupos Canônicos de Lentes"
      subtitle="Explore nosso catálogo organizado por grupos genéricos e premium"
      alignment="center"
      maxWidth="lg"
    />

    <!-- Estatísticas do Catálogo -->
    {#if stats}
      <section class="mt-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <StatsCard
            title="Total de Lentes"
            value={stats.total_lentes?.toString() || "0"}
            icon="👓"
            color="blue"
          />

          <StatsCard
            title="Grupos Genéricos"
            value={stats.grupos_genericos?.toString() || "0"}
            icon="📦"
            color="green"
          />

          <StatsCard
            title="Grupos Premium"
            value={stats.grupos_premium?.toString() || "0"}
            icon="⭐"
            color="orange"
          />

          <StatsCard
            title="Marcas"
            value={stats.total_marcas?.toString() || "0"}
            icon="🏷️"
            color="orange"
          />
        </div>
      </section>
    {/if}

    <!-- Tabs Genéricos / Premium -->
    <section class="mt-12">
      <div class="flex gap-4 border-b border-neutral-200 dark:border-neutral-700">
        <button
          class="px-6 py-3 font-medium transition-colors {tabAtiva === 'genericos'
            ? 'text-blue-600 border-b-2 border-blue-600'
            : 'text-neutral-600 hover:text-neutral-900'}"
          on:click={() => tabAtiva = 'genericos'}
        >
          📦 Grupos Genéricos ({gruposGenericos.length})
        </button>
        <button
          class="px-6 py-3 font-medium transition-colors {tabAtiva === 'premium'
            ? 'text-purple-600 border-b-2 border-purple-600'
            : 'text-neutral-600 hover:text-neutral-900'}"
          on:click={() => tabAtiva = 'premium'}
        >
          ⭐ Grupos Premium ({gruposPremium.length})
        </button>
      </div>
    </section>

    <!-- Conteúdo das Tabs -->
    {#if loading}
      <div class="flex justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    {:else if error}
      <EmptyState
        icon="⚠️"
        title="Erro ao carregar dados"
        description={error}
      />
    {:else}
      <!-- Grupos Genéricos -->
      {#if tabAtiva === 'genericos'}
        <section class="mt-8">
          {#if gruposGenericos.length === 0}
            <EmptyState
              icon="📦"
              title="Nenhum grupo genérico encontrado"
              description="Os grupos canônicos genéricos aparecerão aqui"
            />
          {:else}
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {#each gruposGenericos as grupo}
                <ActionCard
                  title={grupo.nome_canonico}
                  description={`Tipo: ${grupo.tipo_lente} • Material: ${grupo.material} • Índice: ${grupo.indice_refracao}`}
                  actionLabel="Ver Detalhes"
                />
              {/each}
            </div>
          {/if}
        </section>
      {/if}

      <!-- Grupos Premium -->
      {#if tabAtiva === 'premium'}
        <section class="mt-8">
          {#if gruposPremium.length === 0}
            <EmptyState
              icon="⭐"
              title="Nenhum grupo premium encontrado"
              description="Os grupos canônicos premium aparecerão aqui"
            />
          {:else}
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {#each gruposPremium as grupo}
                <ActionCard
                  title={grupo.nome_canonico}
                  description={`Marca: ${grupo.marca} • Tipo: ${grupo.tipo_lente} • Material: ${grupo.material}`}
                  actionLabel="Ver Detalhes"
                />
              {/each}
            </div>
          {/if}
        </section>
      {/if}
    {/if}
  </Container>
</main>
