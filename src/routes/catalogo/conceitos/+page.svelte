<script lang="ts">
    /**
     * 🧠 Motor de Conceitos — Canonical Engine v2
     * Visão consolidada por conceitos óticos com SKU, pricing e tratamentos.
     * Standard (CST) e Premium (CPR) — sem redundância comercial.
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
    import {
        Brain,
        Crown,
        Layers,
        Search,
        ChevronDown,
        ChevronUp,
        RotateCcw,
        DollarSign,
        Package,
    } from "lucide-svelte";

    const { state, carregarGruposPremium, carregarGruposGenericos } =
        useGruposCanonicos();
    const { state: statsState, carregarEstatisticas } = useStatsCatalogo();

    let activeTab: "premium" | "standard" = "premium";
    let showFilters = false;
    let searchQuery = "";
    let lensTypeFilter = "";

    onMount(() => {
        carregarEstatisticas();
        refreshData();
    });

    async function refreshData() {
        if (activeTab === "premium") {
            await carregarGruposPremium({ limit: 200, search: searchQuery || undefined, lens_type: lensTypeFilter || undefined });
        } else {
            await carregarGruposGenericos({ limit: 200, search: searchQuery || undefined, lens_type: lensTypeFilter || undefined });
        }
    }

    function handleTabChange(tab: "premium" | "standard") {
        activeTab = tab;
        refreshData();
    }

    function handleClearFilters() {
        searchQuery = "";
        lensTypeFilter = "";
        refreshData();
    }

    let searchTimeout: ReturnType<typeof setTimeout>;
    function handleSearchInput() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(refreshData, 400);
    }

    $: currentGrupos =
        activeTab === "premium" ? $state.gruposPremium : $state.gruposGenericos;
    $: totalCount =
        activeTab === "premium" ? $state.totalPremium : $state.totalGenericos;

    // KPIs dos conceitos atuais
    $: precoMedioAtual = (() => {
        const withPricing = currentGrupos.filter(g => g.price_avg != null);
        if (!withPricing.length) return null;
        return withPricing.reduce((acc, g) => acc + (g.price_avg ?? 0), 0) / withPricing.length;
    })();

    $: totalLentesAtual = currentGrupos.reduce((acc, g) => acc + (g.mapped_lens_count ?? 0), 0);

    function formatarPreco(valor: number | null): string {
        if (valor == null) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 0 }).format(valor);
    }

    const LENS_TYPES = [
        { value: '', label: 'Todos os tipos' },
        { value: 'single_vision', label: 'Visão Simples' },
        { value: 'multifocal', label: 'Multifocal' },
        { value: 'bifocal', label: 'Bifocal' },
        { value: 'reading', label: 'Leitura' },
        { value: 'occupational', label: 'Ocupacional' },
    ];
</script>

<svelte:head>
    <title>Motor de Conceitos | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
    <div class="bg-gradient-to-b from-primary-50/50 to-transparent dark:from-primary-950/20">
        <PageHero
            badge="🧠 Canonical Engine v2"
            title="Motor de Conceitos"
            subtitle="Catálogo consolidado por física ótica. SKU canônico único, sem redundância comercial — cada conceito é uma identidade ótica pura."
        />
    </div>

    <Container maxWidth="xl" padding="lg">
        <div class="space-y-8 -mt-8">
            <!-- KPIs Dashboard -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <StatsCard
                    title="Conceitos Standard"
                    value={$state.totalGenericos || "..."}
                    subtitle="SKU CST"
                    color="blue"
                    icon="📦"
                />
                <StatsCard
                    title="Conceitos Premium"
                    value={$state.totalPremium || "..."}
                    subtitle="SKU CPR"
                    color="gold"
                    icon="★"
                />
                <StatsCard
                    title="Lentes Mapeadas"
                    value={totalLentesAtual || "..."}
                    subtitle={`no segmento ${activeTab}`}
                    color="cyan"
                    icon="🔗"
                />
                <StatsCard
                    title="Preço Médio"
                    value={precoMedioAtual != null ? formatarPreco(precoMedioAtual) : '...'}
                    subtitle={`segmento ${activeTab}`}
                    color="green"
                    icon="💰"
                />
            </div>

            <!-- Barra de Ações -->
            <div
                class="flex flex-col md:flex-row items-center justify-between gap-4 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 p-3 rounded-2xl shadow-sm"
            >
                <!-- Segment Selector -->
                <div class="flex p-1 bg-neutral-100 dark:bg-neutral-800 rounded-xl w-full md:w-auto">
                    <button
                        on:click={() => handleTabChange("premium")}
                        class="flex-1 md:flex-none px-6 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center justify-center gap-2
                        {activeTab === 'premium'
                            ? 'bg-white dark:bg-neutral-700 shadow-sm text-amber-600 dark:text-amber-400'
                            : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
                    >
                        <Crown class="w-4 h-4" />
                        Premium
                        <span class="ml-1 text-[10px] px-1.5 py-0.5 rounded-full bg-amber-100 dark:bg-amber-900/50 text-amber-800 dark:text-amber-300 font-mono">
                            {$state.totalPremium}
                        </span>
                    </button>
                    <button
                        on:click={() => handleTabChange("standard")}
                        class="flex-1 md:flex-none px-6 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center justify-center gap-2
                        {activeTab === 'standard'
                            ? 'bg-white dark:bg-neutral-700 shadow-sm text-primary-600 dark:text-primary-400'
                            : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
                    >
                        <Layers class="w-4 h-4" />
                        Standard
                        <span class="ml-1 text-[10px] px-1.5 py-0.5 rounded-full bg-primary-100 dark:bg-primary-900/50 text-primary-800 dark:text-primary-300 font-mono">
                            {$state.totalGenericos}
                        </span>
                    </button>
                </div>

                <!-- Busca + Filtros -->
                <div class="flex items-center gap-2 w-full md:w-auto">
                    <div class="relative flex-1 md:w-72">
                        <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
                        <input
                            type="text"
                            placeholder="Buscar por nome, material..."
                            class="w-full pl-10 pr-4 py-2 text-sm bg-neutral-50 dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-lg outline-none focus:ring-2 focus:ring-primary-500/20"
                            bind:value={searchQuery}
                            on:input={handleSearchInput}
                        />
                    </div>
                    <!-- Filtro por tipo -->
                    <select
                        class="py-2 px-3 text-sm bg-neutral-50 dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-lg outline-none focus:ring-2 focus:ring-primary-500/20"
                        bind:value={lensTypeFilter}
                        on:change={refreshData}
                    >
                        {#each LENS_TYPES as lt}
                            <option value={lt.value}>{lt.label}</option>
                        {/each}
                    </select>
                    <Button variant="ghost" size="sm" on:click={handleClearFilters} class="!px-3" title="Limpar filtros">
                        <RotateCcw class="w-4 h-4" />
                    </Button>
                </div>
            </div>

            <!-- Grid de Resultados -->
            <div class="space-y-4">
                <SectionHeader
                    title="Conceitos {activeTab === 'premium' ? 'Premium ★' : 'Standard'}"
                    subtitle="{currentGrupos.length} conceitos óticos únicos • Cada card é uma identidade de física ótica"
                >
                    <div slot="actions" class="flex items-center gap-2">
                        <Button variant="ghost" size="sm" on:click={refreshData}>
                            <RotateCcw class="w-4 h-4 mr-2" />
                            Atualizar
                        </Button>
                    </div>
                </SectionHeader>

                {#if $state.loading}
                    <div class="flex flex-col items-center justify-center py-24 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl border-dashed text-center">
                        <LoadingSpinner size="lg" />
                        <p class="mt-4 text-neutral-500 animate-pulse font-medium">
                            Consultando Motor Oracle...
                        </p>
                    </div>
                {:else if $state.error}
                    <div class="p-12 text-center rounded-2xl border-2 border-red-100 bg-red-50/30 dark:border-red-900 dark:bg-red-950/20">
                        <p class="text-red-500 font-bold mb-4">{$state.error}</p>
                        <Button variant="primary" on:click={refreshData}>Tentar Novamente</Button>
                    </div>
                {:else if currentGrupos.length === 0}
                    <div class="bg-white dark:bg-neutral-900 p-24 text-center rounded-2xl border border-dashed border-neutral-300 dark:border-neutral-700">
                        <div class="text-6xl mb-6 opacity-20">🔍</div>
                        <h3 class="text-2xl font-bold dark:text-white mb-2">Nenhum conceito encontrado</h3>
                        <p class="text-neutral-500 mb-6">
                            {searchQuery ? `Nenhum resultado para "${searchQuery}"` : `Nenhum conceito ${activeTab} disponível`}
                        </p>
                        <Button variant="secondary" on:click={handleClearFilters}>Limpar Filtros</Button>
                    </div>
                {:else}
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
                        {#each currentGrupos as grupo (grupo.id)}
                            <div in:fade={{ duration: 200 }} class="h-full">
                                <GrupoCanonicoCard {grupo} variant={activeTab} />
                            </div>
                        {/each}
                    </div>
                {/if}
            </div>
        </div>
    </Container>
</main>
