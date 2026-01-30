<script lang="ts">
    import { onMount } from "svelte";
    import { fade, fly, slide } from "svelte/transition";
    import { ContactLensAPI } from "$lib/api/contact-lens-api";
    import type {
        LenteContato,
        FiltrosLentesContato,
    } from "$lib/types/contact-lens";

    // Icons
    import {
        LayoutGrid,
        List,
        SlidersHorizontal,
        Search,
        ChevronDown,
        RotateCcw,
    } from "lucide-svelte";

    // Computes
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import ContactLensCard from "$lib/components/catalogo/ContactLensCard.svelte";
    import ContactLensFilterPanel from "$lib/components/catalogo/ContactLensFilterPanel.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
    import Pagination from "$lib/components/ui/Pagination.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

    // State
    let lenses: LenteContato[] = [];
    let loading = true;
    let error = "";
    let total = 0;
    let page = 1;
    const itemsPerPage = 12;

    // Filters State
    let filters: FiltrosLentesContato = {
        busca: "",
        tipos: [],
        materiais: [],
        finalidades: [],
        marcas: [],
    };

    // UI State
    let showMobileFilters = false;
    let showDesktopFilters = false; // Começa fechado para limpar o visual inicial e destacar os KPIs, igual ao original
    let viewMode: "grid" | "list" = "grid";
    let availableBrands: string[] = [];
    let availableSuppliers: string[] = [];

    onMount(async () => {
        await loadOptions();
        await loadLenses();
    });

    async function loadOptions() {
        const opts = await ContactLensAPI.buscarOpcoesFiltro();
        availableBrands = opts.marcas || [];
        availableSuppliers = opts.fornecedores || [];
    }

    async function loadLenses() {
        loading = true;
        try {
            const res = await ContactLensAPI.buscarLentes(
                filters,
                page,
                itemsPerPage,
            );
            if (res.success) {
                lenses = res.data || [];
                total = res.total || 0;
            } else {
                error = res.error || "Erro desconhecido";
            }
        } catch (e) {
            error = "Erro na requisição";
        } finally {
            loading = false;
        }
    }

    function handleFilterChange(event: CustomEvent) {
        filters = event.detail;
        page = 1;
        loadLenses();
    }

    function handleClearFilters() {
        filters = {
            busca: "",
            tipos: [],
            materiais: [],
            finalidades: [],
            marcas: [],
        };
        page = 1;
        loadLenses();
    }

    function toggleMobileFilters() {
        showMobileFilters = !showMobileFilters;
    }
</script>

<svelte:head>
    <title>Lentes de Contato - Catálogo SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
    <!-- Hero Section -->
    <div
        class="bg-gradient-to-br from-brand-blue-50 via-white to-brand-orange-50 dark:from-neutral-900 dark:via-neutral-800 dark:to-neutral-900 border-b border-neutral-200 dark:border-neutral-700"
    >
        <Container maxWidth="xl" padding="lg">
            <PageHero
                badge="Nova Coleção"
                title="Catálogo de Lentes de Contato"
                subtitle="Encontre a lente perfeita: diárias, mensais, tóricas e muito mais."
                alignment="center"
                maxWidth="lg"
            />

            <!-- Stats Rápidos (KPIs Header) -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-8">
                <div class="glass-panel rounded-lg p-4 text-center">
                    <div
                        class="text-2xl font-bold text-brand-blue-600 dark:text-brand-blue-400"
                    >
                        {total}
                    </div>
                    <div class="text-sm text-neutral-600 dark:text-neutral-400">
                        Lentes Cadastradas
                    </div>
                </div>
                <div class="glass-panel rounded-lg p-4 text-center">
                    <div
                        class="text-2xl font-bold text-brand-orange-600 dark:text-brand-orange-400"
                    >
                        {lenses.length}
                    </div>
                    <div class="text-sm text-neutral-600 dark:text-neutral-400">
                        Exibindo Agora
                    </div>
                </div>
                <div class="glass-panel rounded-lg p-4 text-center">
                    <div
                        class="text-2xl font-bold text-brand-gold-600 dark:text-brand-gold-400"
                    >
                        {Math.ceil(total / itemsPerPage)}
                    </div>
                    <div class="text-sm text-neutral-600 dark:text-neutral-400">
                        Páginas
                    </div>
                </div>
            </div>
        </Container>
    </div>

    <!-- Main Content Container -->
    <Container maxWidth="xl" padding="lg">
        <div class="space-y-8">
            <!-- 1. Filtros -->
            <div class="hidden md:block">
                <div
                    class="w-full glass-panel rounded-xl p-4 flex items-center justify-between hover:shadow-lg transition-all duration-300 cursor-pointer group"
                >
                    <div
                        class="flex items-center gap-3 flex-1"
                        on:click={() =>
                            (showDesktopFilters = !showDesktopFilters)}
                        on:keydown={(e) =>
                            e.key === "Enter" &&
                            (showDesktopFilters = !showDesktopFilters)}
                        role="button"
                        tabindex="0"
                    >
                        <div
                            class="p-2 rounded-lg bg-brand-blue-50 dark:bg-brand-blue-800 text-brand-blue-600 dark:text-brand-blue-300 group-hover:scale-110 transition-transform"
                        >
                            <SlidersHorizontal class="w-5 h-5" />
                        </div>
                        <div class="text-left">
                            <h3
                                class="text-lg font-semibold text-neutral-900 dark:text-neutral-100"
                            >
                                Filtros Avançados
                            </h3>
                            <p
                                class="text-sm text-neutral-600 dark:text-neutral-400"
                            >
                                {showDesktopFilters
                                    ? "Clique para recolher"
                                    : "Clique para expandir e refinar sua busca"}
                            </p>
                        </div>
                    </div>
                    <div class="flex items-center gap-4">
                        <!-- Toggle de Visualização -->
                        <div
                            class="flex items-center gap-2 bg-neutral-100 dark:bg-neutral-800 rounded-lg p-1"
                        >
                            <button
                                class="p-2 rounded-md transition-all {viewMode ===
                                'grid'
                                    ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400'
                                    : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
                                on:click={() => (viewMode = "grid")}
                                title="Visualização em Grade"
                            >
                                <LayoutGrid class="w-4 h-4" />
                            </button>
                            <button
                                class="p-2 rounded-md transition-all {viewMode ===
                                'list'
                                    ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400'
                                    : 'text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300'}"
                                on:click={() => (viewMode = "list")}
                                title="Visualização em Lista"
                            >
                                <List class="w-4 h-4" />
                            </button>
                        </div>
                        <!-- Chevron -->
                        <div
                            class="transform transition-transform duration-300 {showDesktopFilters
                                ? 'rotate-180'
                                : ''}"
                            on:click={() =>
                                (showDesktopFilters = !showDesktopFilters)}
                            on:keydown={(e) =>
                                e.key === "Enter" &&
                                (showDesktopFilters = !showDesktopFilters)}
                            role="button"
                            tabindex="0"
                        >
                            <ChevronDown
                                class="w-6 h-6 text-neutral-500 dark:text-neutral-400"
                            />
                        </div>
                    </div>
                </div>

                {#if showDesktopFilters}
                    <div transition:slide={{ duration: 300 }} class="mt-4">
                        <ContactLensFilterPanel
                            {filters}
                            {loading}
                            {availableBrands}
                            {availableSuppliers}
                            totalResults={total}
                            on:change={handleFilterChange}
                            on:clear={handleClearFilters}
                        />
                        <div class="mt-4 flex justify-end">
                            <Button
                                variant="outline"
                                size="sm"
                                on:click={handleClearFilters}
                            >
                                <RotateCcw class="w-4 h-4 mr-2" />
                                Limpar Todos os Filtros
                            </Button>
                        </div>
                    </div>
                {/if}
            </div>

            <!-- Mobile Filters -->
            {#if showMobileFilters}
                <div
                    class="fixed inset-0 z-40 bg-black/60 backdrop-blur-sm md:hidden"
                    transition:fade
                    on:click={toggleMobileFilters}
                    role="button"
                    tabindex="0"
                    on:keydown={(e) =>
                        e.key === "Enter" && toggleMobileFilters()}
                ></div>
                <aside
                    class="fixed inset-y-0 right-0 z-50 w-full max-w-md glass-panel shadow-2xl overflow-y-auto md:hidden"
                    transition:fly={{ x: 300, duration: 300 }}
                >
                    <div
                        class="sticky top-0 z-10 glass-panel border-b border-neutral-200 dark:border-neutral-700 p-6"
                    >
                        <div class="flex items-center justify-between">
                            <div>
                                <h2
                                    class="text-xl font-bold text-neutral-900 dark:text-neutral-100"
                                >
                                    Filtros & Visualização
                                </h2>
                                <p
                                    class="text-sm text-neutral-600 dark:text-neutral-400 mt-1"
                                >
                                    {total} lentes
                                </p>
                            </div>
                            <button
                                on:click={toggleMobileFilters}
                                class="p-2 rounded-lg hover:bg-neutral-100 dark:hover:bg-neutral-800 text-neutral-500 dark:text-neutral-400 transition-colors"
                            >
                                ✕
                            </button>
                        </div>
                        <!-- Toggle de Visualização Mobile -->
                        <div class="flex items-center gap-2 mt-4">
                            <span
                                class="text-sm text-neutral-600 dark:text-neutral-400"
                                >Visualizar:</span
                            >
                            <div
                                class="flex items-center gap-2 bg-neutral-100 dark:bg-neutral-800 rounded-lg p-1"
                            >
                                <button
                                    class="p-2 rounded-md transition-all {viewMode ===
                                    'grid'
                                        ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400'
                                        : 'text-neutral-500'}"
                                    on:click={() => (viewMode = "grid")}
                                >
                                    <LayoutGrid class="w-4 h-4" />
                                </button>
                                <button
                                    class="p-2 rounded-md transition-all {viewMode ===
                                    'list'
                                        ? 'bg-white dark:bg-neutral-700 shadow-sm text-brand-blue-600 dark:text-brand-blue-400'
                                        : 'text-neutral-500'}"
                                    on:click={() => (viewMode = "list")}
                                >
                                    <List class="w-4 h-4" />
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="p-6">
                        <ContactLensFilterPanel
                            {filters}
                            {loading}
                            {availableBrands}
                            {availableSuppliers}
                            totalResults={total}
                            on:change={handleFilterChange}
                            on:clear={handleClearFilters}
                        />
                    </div>
                </aside>
            {/if}

            <!-- 2. Resultados -->
            <div class="space-y-6">
                {#if loading && lenses.length === 0}
                    <div class="py-20 flex justify-center">
                        <LoadingSpinner size="lg" />
                    </div>
                {:else if error}
                    <div
                        class="glass-panel rounded-xl p-8 text-center border-2 border-error"
                    >
                        <div class="text-5xl mb-4">⚠️</div>
                        <h3
                            class="text-xl font-bold text-neutral-900 dark:text-neutral-100 mb-2"
                        >
                            Erro ao Carregar
                        </h3>
                        <p class="text-error mb-6">{error}</p>
                        <Button variant="primary" on:click={loadLenses}
                            >Tentar Novamente</Button
                        >
                    </div>
                {:else if lenses.length === 0}
                    <div
                        class="glass-panel rounded-xl p-12 text-center shadow-sm"
                    >
                        <div class="text-6xl mb-4">🔍</div>
                        <h3
                            class="text-2xl font-bold text-neutral-900 dark:text-neutral-100 mb-3"
                        >
                            Nenhuma Lente Encontrada
                        </h3>
                        <p
                            class="text-neutral-600 dark:text-neutral-400 mb-6 max-w-md mx-auto"
                        >
                            Tente ajustar seus filtros para encontrar o que
                            procura.
                        </p>
                        <Button variant="primary" on:click={handleClearFilters}
                            >Limpar Todos os Filtros</Button
                        >
                    </div>
                {:else}
                    <SectionHeader
                        title="Resultados"
                        subtitle="{lenses.length} lentes na página {page} de {Math.ceil(
                            total / itemsPerPage,
                        )}"
                    />

                    <div
                        class={viewMode === "grid"
                            ? "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 gap-6"
                            : "flex flex-col gap-4"}
                    >
                        {#each lenses as lente (lente.id)}
                            <div in:fade={{ duration: 300 }} class="h-full">
                                <ContactLensCard
                                    {lente}
                                    compact={viewMode === "list"}
                                />
                            </div>
                        {/each}
                    </div>

                    <div class="mt-8">
                        <Pagination
                            currentPage={page}
                            totalItems={total}
                            {itemsPerPage}
                            totalPages={Math.ceil(total / itemsPerPage)}
                            on:change={(e) => {
                                page = e.detail;
                                loadLenses();
                            }}
                        />
                    </div>
                {/if}
            </div>
        </div>
    </Container>

    <!-- Botão Flutuante Mobile (FAB) -->
    <button
        on:click={toggleMobileFilters}
        class="md:hidden fixed bottom-6 right-6 z-30 p-4 rounded-full bg-brand-blue-600 hover:bg-brand-blue-700 text-white shadow-2xl hover:shadow-3xl transition-all duration-300 hover:scale-110"
        aria-label="Abrir filtros"
    >
        <SlidersHorizontal class="w-6 h-6" />
    </button>
</main>
