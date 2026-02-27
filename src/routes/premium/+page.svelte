<script lang="ts">
  /**
   * ✨ Catálogo Premium - SIS Lens
   * Lentes premium de alta tecnologia e marcas exclusivas
   */
  import { onMount } from "svelte";
  import { fade, slide } from "svelte/transition";
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
    ChevronDown,
  } from "lucide-svelte";

  const {
    state: searchState,
    aplicarFiltros,
    limparFiltros,
    irParaPagina,
  } = useBuscarLentes({ is_premium: true });
  const { state: statsState, carregarEstatisticas } = useStatsCatalogo();

  onMount(() => {
    aplicarFiltros({ is_premium: true });
    carregarEstatisticas();
  });

  let viewMode: "grid" | "list" = "grid";
  let showFilters = false;

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

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
  <PageHero
    badge="Elite"
    title="Premium Collection"
    subtitle="O auge da tecnologia óptica e marcas de luxo"
  />

  <Container maxWidth="xl" padding="lg">
    <div class="space-y-8">
      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        {#if $statsState.stats}
          <StatsCard
            title="Lentes Premium"
            value={$statsState.stats.premium.toString()}
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
          <StatsCard title="Curadoria" value="Exclusiva" color="orange">
            <Package slot="icon" class="w-6 h-6" />
          </StatsCard>
        {/if}
      </div>

      <!-- Filtro no Topo (Recolhível) -->
      <div class="w-full">
        <div
          class="w-full bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-xl p-4 flex items-center justify-between hover:shadow-lg transition-all duration-300 cursor-pointer group"
          on:click={() => (showFilters = !showFilters)}
          on:keydown={(e) => e.key === "Enter" && (showFilters = !showFilters)}
          role="button"
          tabindex="0"
        >
          <div class="flex items-center gap-3">
            <div
              class="p-2 rounded-lg bg-amber-50 dark:bg-amber-900/40 text-amber-600 dark:text-amber-400 group-hover:scale-110 transition-transform"
            >
              <SlidersHorizontal class="w-5 h-5" />
            </div>
            <div>
              <h3
                class="text-lg font-semibold text-neutral-900 dark:text-neutral-100"
              >
                Refinar Coleção Elite
              </h3>
              <p class="text-sm text-neutral-500">
                {showFilters
                  ? "Clique para recolher"
                  : "Clique para expandir e filtrar por luxo e tecnologia"}
              </p>
            </div>
          </div>
          <div class="flex items-center gap-4">
            <div
              class="transform transition-transform duration-300 {showFilters
                ? 'rotate-180'
                : ''}"
            >
              <ChevronDown class="w-6 h-6 text-neutral-400" />
            </div>
          </div>
        </div>

        {#if showFilters}
          <div
            transition:slide={{ duration: 300 }}
            class="mt-4 p-6 rounded-xl bg-white/50 dark:bg-neutral-800/50"
          >
            <FilterPanel
              on:change={(e) =>
                aplicarFiltros({ ...e.detail, is_premium: true })}
            />
            <div
              class="mt-6 flex justify-end border-t border-neutral-100 dark:border-neutral-700 pt-4"
            >
              <Button variant="ghost" size="sm" on:click={limparFiltros}>
                <RotateCcw class="w-4 h-4 mr-2" /> Limpar Filtros Premium
              </Button>
            </div>
          </div>
        {/if}
      </div>

      <!-- Resultados -->
      <div class="flex-1">
        {#if $searchState.loading}
          <div
            class="flex flex-col items-center justify-center py-20 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-xl"
          >
            <LoadingSpinner size="lg" />
            <p class="mt-4 text-neutral-500">Buscando coleção premium...</p>
          </div>
        {:else if $searchState.error}
          <div class="bg-white dark:bg-neutral-900 p-10 text-center rounded-xl border border-red-200">
            <p class="text-red-500 font-medium">{$searchState.error}</p>
            <Button
              class="mt-4"
              variant="secondary"
              on:click={() => aplicarFiltros({ is_premium: true })}
              >Tentar Novamente</Button
            >
          </div>
        {:else if $searchState.lentes.length === 0}
          <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 p-20 text-center rounded-xl">
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
              ? 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3'
              : 'grid-cols-1'}"
          >
            {#each $searchState.lentes as lente (lente.id)}
              <div in:fade>
                <LenteCard {lente} />
              </div>
            {/each}
          </div>

          <div class="mt-10">
            <Pagination
              currentPage={$searchState.pagina}
              totalPages={Math.ceil($searchState.total / 50)}
              on:change={(e) => {
                irParaPagina(e.detail);
                window.scrollTo({ top: 0, behavior: "smooth" });
              }}
            />
          </div>
        {/if}
      </div>
    </div>
  </Container>
</main>
