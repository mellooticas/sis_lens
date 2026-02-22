<!--
  👓 Catálogo Standard - SIS Lens
  Lentes de catálogo essencial com excelente custo-benefício
-->
<script lang="ts">
  import { onMount } from "svelte";
  import { fade } from "svelte/transition";
  import { useBuscarLentes } from "$lib/hooks/useBuscarLentes";
  import { useStatsCatalogo } from "$lib/hooks/useStatsCatalogo";

  // Layout Components
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";

  // UI Components
  import FilterPanel from "$lib/components/catalogo/FilterPanel.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import LenteCard from "$lib/components/catalogo/LenteCard.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import Pagination from "$lib/components/ui/Pagination.svelte";
  import {
    Package,
    SlidersHorizontal,
    DollarSign,
    Layers,
    RotateCcw,
  } from "lucide-svelte";

  const {
    state: searchState,
    aplicarFiltros,
    limparFiltros,
    irParaPagina,
  } = useBuscarLentes({ is_premium: false });
  const { state: statsState } = useStatsCatalogo();

  onMount(() => {
    aplicarFiltros({ is_premium: false });
  });

  let viewMode: "grid" | "list" = "grid";

  function formatarPreco(preco: number): string {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(preco);
  }
</script>

<svelte:head>
  <title>Standard Collection | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900">
  <PageHero
    title="Standard Collection"
    subtitle="Qualidade essencial e as melhores opções de custo-benefício"
  />

  <Container maxWidth="full" padding="lg">
    <div class="space-y-6">
      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        {#if $statsState.stats}
          <StatsCard
            title="Lentes Disponíveis"
            value={$statsState.stats.total_lenses.toString()}
            color="blue"
          >
            <Package slot="icon" class="w-6 h-6" />
          </StatsCard>
          <StatsCard
            title="Preço Médio"
            value={formatarPreco($statsState.stats.price_avg || 0)}
            color="orange"
          >
            <DollarSign slot="icon" class="w-6 h-6" />
          </StatsCard>
          <StatsCard title="Categorias" value="5+" color="blue">
            <Layers slot="icon" class="w-6 h-6" />
          </StatsCard>
        {/if}
      </div>

      <div class="flex flex-col lg:flex-row gap-6">
        <!-- Sidebar Filtros -->
        <aside class="w-full lg:w-80 shrink-0">
          <div class="glass-panel p-6 rounded-xl sticky top-24">
            <div class="flex items-center justify-between mb-6">
              <h3
                class="font-bold text-neutral-900 dark:text-white flex items-center gap-2"
              >
                <SlidersHorizontal class="w-4 h-4 text-blue-500" />
                Filtros
              </h3>
              <Button variant="ghost" size="sm" on:click={limparFiltros}>
                <RotateCcw class="w-4 h-4" />
              </Button>
            </div>
            <FilterPanel
              on:change={(e) =>
                aplicarFiltros({ ...e.detail, is_premium: false })}
            />
          </div>
        </aside>

        <!-- Resultados -->
        <div class="flex-1">
          {#if $searchState.loading}
            <div class="flex justify-center py-20">
              <LoadingSpinner size="lg" />
            </div>
          {:else if $searchState.error}
            <div class="glass-panel p-10 text-center rounded-xl">
              <p class="text-red-500">{$searchState.error}</p>
            </div>
          {:else if $searchState.lentes.length === 0}
            <div class="glass-panel p-20 text-center rounded-xl">
              <Package class="w-12 h-12 text-neutral-300 mx-auto mb-4" />
              <h3 class="text-xl font-bold dark:text-white">
                Nenhuma lente encontrada
              </h3>
              <p class="text-neutral-500 mb-6">
                Tente ajustar seus filtros para encontrar a lente ideal.
              </p>
              <Button on:click={limparFiltros}>Ver Todas Standard</Button>
            </div>
          {:else}
            <div
              class="grid gap-6 {viewMode === 'grid'
                ? 'grid-cols-1 md:grid-cols-2 xl:grid-cols-3'
                : 'grid-cols-1'}"
            >
              {#each $searchState.lentes as lente (lente.id)}
                <div in:fade>
                  <LenteCard {lente} />
                </div>
              {/each}
            </div>

            <div class="mt-8">
              <Pagination
                currentPage={$searchState.pagina}
                totalPages={Math.ceil($searchState.total / 50)}
                on:change={(e) => irParaPagina(e.detail)}
              />
            </div>
          {/if}
        </div>
      </div>
    </div>
  </Container>
</main>
