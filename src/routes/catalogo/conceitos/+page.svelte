<script lang="ts">
    /**
     * 🧠 Catálogo de Conceitos (Canônicas) - SIS Lens
     * Visão consolidada por conceitos óticos, separando Premium de Standard.
     * KPIs interativos e filtros integrados.
     */
    import { onMount } from "svelte";
    import { fade, slide } from "svelte/transition";
    import { useGruposCanonicos } from "$lib/hooks/useGruposCanonicos";
    import { useStatsCatalogo } from "$lib/hooks/useStatsCatalogo";

    // Layout Components
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

    // UI Components
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
    import GrupoCanonicoCard from "$lib/components/catalogo/GrupoCanonicoCard.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import StatsCard from "$lib/components/cards/StatsCard.svelte";
    import FilterPanel from "$lib/components/catalogo/FilterPanel.svelte";
    import {
        Brain,
        Crown,
        Layers,
        Search,
        ChevronDown,
        ChevronUp,
        RotateCcw,
    } from "lucide-svelte";

    const { state, carregarGruposPremium, carregarGruposGenericos } =
        useGruposCanonicos();
    const { state: statsState, carregarEstatisticas } = useStatsCatalogo();

    let activeTab: "premium" | "standard" = "premium";
    let showFilters = false;
    let filters: any = { busca: "" };

    onMount(() => {
        carregarEstatisticas();
        refreshData();
    });

    async function refreshData() {
        if (activeTab === "premium") {
            await carregarGruposPremium({ limit: 100 });
        } else {
            await carregarGruposGenericos({ limit: 100 });
        }
    }

    function handleTabChange(tab: "premium" | "standard") {
        activeTab = tab;
        refreshData();
    }

    function handleFilterChange(event: CustomEvent) {
        filters = event.detail;
        refreshData();
    }

    function handleClearFilters() {
        filters = { busca: "" };
        refreshData();
    }

    $: currentGrupos =
        activeTab === "premium" ? $state.gruposPremium : $state.gruposGenericos;
    $: totalCount =
        activeTab === "premium" ? $state.totalPremium : $state.totalGenericos;
    $: stats = $statsState.stats;
</script>

<svelte:head>
    <title>Motor de Conceitos | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
    <div
        class="bg-gradient-to-b from-primary-50/50 to-transparent dark:from-primary-950/20"
    >
        <PageHero
            badge="Inteligência de Catálogo"
            title="Motor de Conceitos"
            subtitle="Onde a física ótica encontra o mercado. Visualize o catálogo consolidado por modelos órfãos de redundância comercial."
        />
    </div>

    <Container maxWidth="xl" padding="lg">
        <div class="space-y-8 -mt-8">
            <!-- KPIs Dashboard -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <StatsCard
                    title="Total de Conceitos"
                    value={$state.totalPremium + $state.totalGenericos || "..."}
                    color="blue"
                    icon="🧠"
                />
                <StatsCard
                    title="Lentes Mapeadas"
                    value={stats?.total_lenses || "..."}
                    color="cyan"
                    icon="📦"
                />
                <StatsCard
                    title="Marcas Ativas"
                    value={stats?.total_brands || "..."}
                    color="gold"
                    icon="🏷️"
                />
                <StatsCard
                    title="Fidelidade Ótica"
                    value="100%"
                    subtitle="Zero colisões cross-pool"
                    color="green"
                    icon="✨"
                />
            </div>

            <!-- Barra de Ações e Filtros -->
            <div class="flex flex-col gap-4">
                <div
                    class="flex flex-col md:flex-row items-center justify-between gap-4 glass-panel p-3 rounded-2xl shadow-sm"
                >
                    <!-- Segment Selector -->
                    <div
                        class="flex p-1 bg-neutral-100 dark:bg-neutral-800 rounded-xl w-full md:w-auto"
                    >
                        <button
                            on:click={() => handleTabChange("premium")}
                            class="flex-1 md:flex-none px-6 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center justify-center gap-2
                {activeTab === 'premium'
                                ? 'bg-white dark:bg-neutral-700 shadow-sm text-amber-600 dark:text-amber-400'
                                : 'text-neutral-500 hover:text-neutral-700'}"
                        >
                            <Crown class="w-4 h-4" />
                            Premium
                            <span
                                class="ml-1 text-[10px] px-1.5 py-0.5 rounded-full bg-amber-100 dark:bg-amber-900/50"
                                >{$state.totalPremium}</span
                            >
                        </button>
                        <button
                            on:click={() => handleTabChange("standard")}
                            class="flex-1 md:flex-none px-6 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center justify-center gap-2
                {activeTab === 'standard'
                                ? 'bg-white dark:bg-neutral-700 shadow-sm text-primary-600 dark:text-primary-400'
                                : 'text-neutral-500 hover:text-neutral-700'}"
                        >
                            <Layers class="w-4 h-4" />
                            Standard
                            <span
                                class="ml-1 text-[10px] px-1.5 py-0.5 rounded-full bg-primary-100 dark:bg-primary-900/50"
                                >{$state.totalGenericos}</span
                            >
                        </button>
                    </div>

                    <!-- Quick Actions -->
                    <div class="flex items-center gap-2 w-full md:w-auto">
                        <div class="relative flex-1 md:w-64">
                            <Search
                                class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400"
                            />
                            <input
                                type="text"
                                placeholder="Filtrar conceitos..."
                                class="w-full pl-10 pr-4 py-2 text-sm bg-neutral-50 dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-lg outline-none focus:ring-2 focus:ring-primary-500/20"
                                bind:value={filters.busca}
                                on:input={refreshData}
                            />
                        </div>
                        <Button
                            variant="secondary"
                            size="sm"
                            on:click={() => (showFilters = !showFilters)}
                            class="!px-3"
                        >
                            {#if showFilters}<ChevronUp
                                    class="w-4 h-4"
                                />{:else}<ChevronDown class="w-4 h-4" />{/if}
                        </Button>
                    </div>
                </div>

                {#if showFilters}
                    <div transition:slide={{ duration: 300 }}>
                        <FilterPanel
                            {filters}
                            loading={$state.loading}
                            totalResults={totalCount}
                            on:change={handleFilterChange}
                            on:clear={handleClearFilters}
                        />
                    </div>
                {/if}
            </div>

            <!-- Grid de Resultados -->
            <div class="space-y-6">
                <SectionHeader
                    title="Grupos de Mercado: {activeTab === 'premium'
                        ? 'Premium'
                        : 'Standard'}"
                    subtitle="Listando {currentGrupos.length} conceitos órfãos de redundância comercial."
                >
                    <div slot="actions" class="flex items-center gap-2">
                        <Button
                            variant="ghost"
                            size="sm"
                            on:click={refreshData}
                        >
                            <RotateCcw class="w-4 h-4 mr-2" />
                            Atualizar
                        </Button>
                    </div>
                </SectionHeader>

                {#if $state.loading}
                    <div
                        class="flex flex-col items-center justify-center py-24 glass-panel rounded-2xl border border-dashed text-center"
                    >
                        <LoadingSpinner size="lg" />
                        <p
                            class="mt-4 text-neutral-500 animate-pulse font-medium"
                        >
                            Consultando Motor Oracle...
                        </p>
                    </div>
                {:else if $state.error}
                    <div
                        class="glass-panel p-12 text-center rounded-2xl border-2 border-red-100 bg-red-50/30"
                    >
                        <p class="text-red-500 font-bold mb-4">
                            {$state.error}
                        </p>
                        <Button variant="primary" on:click={refreshData}
                            >Tentar Novamente</Button
                        >
                    </div>
                {:else if currentGrupos.length === 0}
                    <div
                        class="glass-panel p-24 text-center rounded-2xl border border-dashed"
                    >
                        <div class="text-6xl mb-6 opacity-20">🔍</div>
                        <h3 class="text-2xl font-bold dark:text-white mb-2">
                            Nenhum conceito encontrado
                        </h3>
                        <p class="text-neutral-500 mb-6">
                            Ajuste os filtros ou a busca para visualizar os
                            grupos do segmento {activeTab}.
                        </p>
                        <Button
                            variant="secondary"
                            on:click={handleClearFilters}>Limpar Filtros</Button
                        >
                    </div>
                {:else}
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
                    >
                        {#each currentGrupos as grupo (grupo.id)}
                            <div in:fade={{ duration: 200 }} class="h-full">
                                <GrupoCanonicoCard
                                    grupo={{
                                        id: grupo.id,
                                        name: grupo.canonical_name,
                                        lens_type: grupo.lens_type,
                                        material: grupo.material,
                                        refractive_index:
                                            grupo.refractive_index,
                                        is_premium: grupo.has_premium_mapping,
                                        is_active: true,
                                        tenant_id: "",
                                        created_at: "",
                                        updated_at: "",
                                    }}
                                    variant={activeTab}
                                />
                            </div>
                        {/each}
                    </div>
                {/if}
            </div>
        </div>
    </Container>
</main>

<style>
    :global(.glass-panel) {
        @apply bg-white/70 dark:bg-neutral-800/70 backdrop-blur-md border border-white/20 dark:border-neutral-700/30;
    }
</style>
