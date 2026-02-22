<!--
  ✨ Catálogo Premium - SIS Lens
  Lentes premium de alta tecnologia e marcas exclusivas
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
    Crown,
    SlidersHorizontal,
    Package,
    DollarSign,
    Layers,
    RotateCcw,
  } from "lucide-svelte";

  const {
    state: searchState,
    aplicarFiltros,
    limparFiltros,
    irParaPagina,
  } = useBuscarLentes({ is_premium: true });
  const { state: statsState } = useStatsCatalogo();

  onMount(() => {
    aplicarFiltros({ is_premium: true });
  });

  let viewMode: "grid" | "list" = "grid";
  let showMobileFilters = false;

  function formatarPreco(preco: number): string {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(preco);
  }
</script>

<svelte:head>
  <title>Premium Collection | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900">
  <PageHero
    badge="Elite Catalog"
    title="Premium Collection"
    subtitle="O auge da tecnologia óptica e marcas de luxo"
  />

  <Container maxWidth="full" padding="lg">
    <div class="space-y-6">
      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        {#if $statsState.stats}
          <StatsCard
            title="Lentes Premium"
            value={$statsState.stats.total_premium.toString()}
            color="orange"
          >
            <Crown slot="icon" class="w-6 h-6" />
          </StatsCard>
          <StatsCard
            title="Preço Médio Premium"
            value={formatarPreco($statsState.stats.price_avg || 0)}
            color="blue"
          >
            <DollarSign slot="icon" class="w-6 h-6" />
          </StatsCard>
          <StatsCard title="Sourcing Global" value="Ativo" color="orange">
            <Package slot="icon" class="w-6 h-6" />
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
                <SlidersHorizontal class="w-4 h-4 text-amber-500" />
                Refinar Elite
              </h3>
              <Button variant="ghost" size="sm" on:click={limparFiltros}>
                <RotateCcw class="w-4 h-4" />
              </Button>
            </div>
            <FilterPanel
              on:change={(e) =>
                aplicarFiltros({ ...e.detail, is_premium: true })}
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
              <Crown class="w-12 h-12 text-neutral-300 mx-auto mb-4" />
              <h3 class="text-xl font-bold dark:text-white">
                Nenhum tesouro encontrado
              </h3>
              <p class="text-neutral-500 mb-6">
                Tente ajustar seus filtros de elite.
              </p>
              <Button on:click={limparFiltros}>Ver Todas Premium</Button>
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
