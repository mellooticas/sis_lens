<script lang="ts">
  /**
   * Página de Busca de Lentes - Interface Principal com DADOS REAIS
   * Sistema de busca usando as views públicas do banco
   */

  import { onMount } from 'svelte';
  import { goto } from "$app/navigation";
  
  // === Hooks com dados reais ===
  import { useBuscarLentes, useStatsCatalogo } from '$lib/hooks';
  import type { BuscarLentesParams, VwBuscarLentes } from '$lib/types/views';

  // === Layout ===
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

  // === Componentes com dados reais ===
  import LenteCard from "$lib/components/catalogo/LenteCard.svelte";
  import FiltrosLentes from "$lib/components/catalogo/FiltrosLentes.svelte";
  import CompararFornecedores from "$lib/components/catalogo/CompararFornecedores.svelte";

  // === UI ===
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  
  // === Cards ===
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";

  // Hook de busca com dados reais
  const { state, buscar, aplicarFiltros, irParaPagina, proximaPagina, paginaAnterior, limparFiltros: limparFiltrosHook } = useBuscarLentes();
  
  // Hook de estatísticas
  const { state: statsState, carregarEstatisticas } = useStatsCatalogo();

  // Estado local
  let filtrosAtuais: BuscarLentesParams = {};
  let lenteParaComparar: VwBuscarLentes | null = null;

  // Carregar dados iniciais
  onMount(async () => {
    await Promise.all([
      buscar(),
      carregarEstatisticas()
    ]);
  });

  // Formatador de moeda
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(value);
  };

  // Handlers
  async function handleAplicarFiltros(filtros: BuscarLentesParams) {
    filtrosAtuais = filtros;
    await aplicarFiltros(filtros);
  }

  function handleLimparFiltros() {
    filtrosAtuais = {};
    limparFiltrosHook();
  }

  function handleSelecionarLente(lente: VwBuscarLentes) {
    goto(`/lentes/${lente.id}`);
  }

  function handleCompararFornecedores(lente: VwBuscarLentes) {
    lenteParaComparar = lente;
  }

  function fecharComparacao() {
    lenteParaComparar = null;
  }
</script>

<svelte:head>
  <title>Buscar Lentes - SIS Lens</title>
  <meta
    name="description"
    content="Busque lentes oftálmicas com filtros avançados e compare fornecedores"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero Section -->
    <PageHero
      badge="🔍 Sistema de Busca Inteligente"
      title="Buscar Lentes"
      subtitle="Encontre as melhores opções com filtros avançados e compare fornecedores em tempo real"
      alignment="center"
      maxWidth="lg"
    />

    <!-- Estatísticas da Busca -->
    {#if $statsState.stats}
      <section class="mt-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <StatsCard
            title="Lentes Disponíveis"
            value={$statsState.stats.total_lentes.toString()}
            icon="👓"
            color="blue"
          />

          <StatsCard
            title="Fornecedores Ativos"
            value={$statsState.stats.total_fornecedores.toString()}
            icon="🏢"
            color="green"
          />

          <StatsCard
            title="Preço Médio"
            value={formatCurrency($statsState.stats.preco_medio_catalogo)}
            icon="💰"
            color="orange"
          />
        </div>
      </section>
    {/if}

    <!-- Componente de Filtros Avançados -->
    <section class="mt-12">
      <FiltrosLentes
        {filtrosAtuais}
        onAplicar={handleAplicarFiltros}
        onLimpar={handleLimparFiltros}
      />
    </section>

    <!-- Resultados da Busca -->
    <section class="mt-12">
      <SectionHeader
        title="Resultados da Busca"
        subtitle={$state.lentes.length > 0 ? `${$state.total} lentes encontradas` : ""}
      />

      {#if $state.loading}
        <div class="flex justify-center py-12">
          <LoadingSpinner size="lg" />
        </div>
      {:else if $state.error}
        <EmptyState
          icon="⚠️"
          title="Erro ao carregar dados"
          description={$state.error}
          actionLabel="Tentar Novamente"
          on:action={() => buscar()}
        />
      {:else if $state.lentes.length > 0}
        <!-- Grid de Cards de Lentes -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {#each $state.lentes as lente (lente.id)}
            <LenteCard
              {lente}
              onSelecionar={handleSelecionarLente}
              onCompararFornecedores={handleCompararFornecedores}
            />
          {/each}
        </div>

        <!-- Paginação -->
        {#if $state.totalPaginas > 1}
          <div class="mt-8 flex justify-center items-center gap-4">
            <Button
              variant="ghost"
              size="sm"
              disabled={$state.pagina === 1}
              on:click={paginaAnterior}
            >
              ← Anterior
            </Button>

            <div class="flex items-center gap-2">
              {#each Array.from({ length: $state.totalPaginas }, (_, i) => i + 1) as pagina}
                {#if pagina === 1 || pagina === $state.totalPaginas || (pagina >= $state.pagina - 1 && pagina <= $state.pagina + 1)}
                  <Button
                    variant={pagina === $state.pagina ? "primary" : "ghost"}
                    size="sm"
                    on:click={() => irParaPagina(pagina)}
                  >
                    {pagina}
                  </Button>
                {:else if pagina === $state.pagina - 2 || pagina === $state.pagina + 2}
                  <span class="text-neutral-500">...</span>
                {/if}
              {/each}
            </div>

            <Button
              variant="ghost"
              size="sm"
              disabled={$state.pagina === $state.totalPaginas}
              on:click={proximaPagina}
            >
              Próxima →
            </Button>
          </div>
        {/if}
      {:else}
        <EmptyState
          icon="👓"
          title="Comece sua busca"
          description="Use os filtros acima para encontrar as lentes ideais"
          actionLabel="Ver Todas as Lentes"
          on:action={() => buscar()}
        />
      {/if}
    </section>

    <!-- Modal de Comparação de Fornecedores -->
    {#if lenteParaComparar}
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <div
        class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50"
        on:click={fecharComparacao}
      >
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <div
          class="bg-white dark:bg-neutral-800 rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto"
          on:click|stopPropagation
        >
          <div class="p-6 border-b border-neutral-200 dark:border-neutral-700">
            <div class="flex justify-between items-center">
              <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">
                Comparar Fornecedores
              </h2>
              <Button variant="ghost" size="sm" on:click={fecharComparacao}>
                ✕
              </Button>
            </div>
          </div>

          <div class="p-6">
            <CompararFornecedores
              grupoId={lenteParaComparar.canonica_id}
            />
          </div>
        </div>
      </div>
    {/if}

    <!-- Ações Rápidas -->
    <section class="mt-12 mb-8">
      <SectionHeader title="Ações Rápidas" />

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <ActionCard
          icon="📊"
          title="Ver Catálogo Completo"
          description="Explore todas as lentes disponíveis organizadas por grupo"
          actionLabel="Ver Catálogo"
          color="blue"
          on:click={() => goto("/catalogo")}
        />

        <ActionCard
          icon="🏆"
          title="Grupos Premium"
          description="Veja os melhores grupos de lentes premium"
          actionLabel="Ver Premium"
          color="green"
          on:click={() => goto("/grupos-premium")}
        />

        <ActionCard
          icon="🏢"
          title="Fornecedores"
          description="Veja todos os fornecedores ativos"
          actionLabel="Ver Fornecedores"
          color="orange"
          on:click={() => goto("/fornecedores")}
        />
      </div>
    </section>
  </Container>
</main>
