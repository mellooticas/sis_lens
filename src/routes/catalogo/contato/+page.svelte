<script lang="ts">
    import { onMount } from "svelte";
    import { fade } from "svelte/transition";
    import { LensOracleAPI } from "$lib/api/lens-oracle";
    import type {
        RpcContactLensSearchResult,
        VBrand,
    } from "$lib/types/database-views";
    import type { FiltrosLentesContato } from "$lib/types/contact-lens";
    import { SlidersHorizontal, RotateCcw } from "lucide-svelte";

    // Layout Components
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

    // UI Components
    import ContactLensFilterPanel from "$lib/components/catalogo/ContactLensFilterPanel.svelte";
    import ContactLensCard from "$lib/components/catalogo/ContactLensCard.svelte";
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import Pagination from "$lib/components/ui/Pagination.svelte";

    export let data;

    // State
    let lentes: RpcContactLensSearchResult[] = data.initialLenses || [];
    let loading = false;
    let error = "";
    let total = 0; // Idealmente viria de uma RPC de contagem
    let paginaAtual = 1;
    const itensPorPagina = 12;

    let filters: FiltrosLentesContato = {};
    let showFilters = true;

    // Marcas e Fabricantes carregados no server
    const brands: VBrand[] = data.brands || [];
    const manufacturers: string[] = data.manufacturers || [];

    async function carregarLentesContatos() {
        try {
            loading = true;
            error = "";

            // Mapeamento de filtros do componente para a API
            const res = await LensOracleAPI.searchContactLenses({
                query: filters.busca,
                lens_type: filters.tipos?.[0], // Simplificando para o primeiro selecionado
                purpose: filters.finalidades?.[0],
                material: filters.materiais?.[0],
                // Nota: o componente filter panel envia nomes de marcas, a API espera IDs ou query
                // Por agora usaremos a busca textual da API para marcas se selecionado
                limit: itensPorPagina,
                offset: (paginaAtual - 1) * itensPorPagina,
            });

            if (res.data) {
                lentes = res.data;
                // Simulação de total (idealmente retorna do banco)
                if (total === 0 && res.data.length > 0) total = 225; // Baseado na migration 220
            } else {
                error =
                    res.error?.message || "Erro ao carregar lentes de contato";
            }
        } catch (err) {
            console.error("Erro ao buscar contatos:", err);
            error = "Falha na conexão com o Oráculo";
        } finally {
            loading = false;
        }
    }

    function handleFilterChange(event: CustomEvent<FiltrosLentesContato>) {
        filters = event.detail;
        paginaAtual = 1;
        carregarLentesContatos();
    }

    function handleClearFilters() {
        filters = {};
        paginaAtual = 1;
        carregarLentesContatos();
    }

    onMount(() => {
        // Se não houver dados iniciais, carrega
        if (lentes.length === 0) carregarLentesContatos();
    });
</script>

<svelte:head>
    <title>Catálogo de Lentes de Contato - SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
    <!-- Hero Section -->
    <div
        class="bg-white dark:bg-neutral-800 border-b border-neutral-200 dark:border-neutral-700 mb-8"
    >
        <Container>
            <PageHero
                badge="👁️ Contato & Estética"
                title="Catálogo de Lentes de Contato"
                subtitle="Encontre as melhores opções de descarte diário, mensal e lentes coloridas."
                alignment="left"
            />
        </Container>
    </div>

    <Container>
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
            <!-- Sidebar de Filtros -->
            <aside class="lg:col-span-1 space-y-6">
                <div class="sticky top-24">
                    <div class="flex items-center justify-between mb-4">
                        <SectionHeader title="Filtros" />
                        <button
                            class="lg:hidden p-2 bg-white dark:bg-neutral-800 rounded-lg shadow-sm"
                            on:click={() => (showFilters = !showFilters)}
                        >
                            <SlidersHorizontal class="w-5 h-5" />
                        </button>
                    </div>

                    {#if showFilters}
                        <div transition:fade>
                            <ContactLensFilterPanel
                                {filters}
                                {loading}
                                totalResults={lentes.length}
                                availableBrands={brands.map((b) => b.name)}
                                availableSuppliers={manufacturers}
                                on:change={handleFilterChange}
                                on:clear={handleClearFilters}
                            />
                        </div>
                    {/if}
                </div>
            </aside>

            <!-- Grid de Resultados -->
            <div class="lg:col-span-3 space-y-6">
                {#if loading && lentes.length === 0}
                    <div
                        class="flex flex-col items-center justify-center py-20 bg-white dark:bg-neutral-800 rounded-2xl border border-dashed border-neutral-300 dark:border-neutral-700"
                    >
                        <LoadingSpinner size="lg" />
                        <p class="mt-4 text-neutral-500">
                            Consultando estoque de lentes de contato...
                        </p>
                    </div>
                {:else if error}
                    <div
                        class="p-8 text-center bg-red-50 dark:bg-red-900/10 rounded-2xl border border-red-200 dark:border-red-800"
                    >
                        <p class="text-red-600 dark:text-red-400 font-medium">
                            {error}
                        </p>
                        <Button
                            variant="secondary"
                            class="mt-4"
                            on:click={carregarLentesContatos}
                            >Tentar Novamente</Button
                        >
                    </div>
                {:else if lentes.length === 0}
                    <div
                        class="py-20 text-center bg-white dark:bg-neutral-800 rounded-2xl border border-neutral-200 dark:border-neutral-700"
                    >
                        <div class="text-6xl mb-4">👁️‍🗨️</div>
                        <h3
                            class="text-xl font-bold text-neutral-900 dark:text-white"
                        >
                            Nenhum produto encontrado
                        </h3>
                        <p class="text-neutral-500 mt-2">
                            Tente ajustar seus filtros de marca ou descarte.
                        </p>
                        <Button
                            variant="ghost"
                            class="mt-6"
                            on:click={handleClearFilters}
                        >
                            <RotateCcw class="w-4 h-4 mr-2" /> Limpar Filtros
                        </Button>
                    </div>
                {:else}
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-2 gap-6"
                    >
                        {#each lentes as lente (lente.id)}
                            <!-- Mapeamento para o formato esperado pelo ContactLensCard se necessário -->
                            <!-- O RpcContactLensSearchResult é compatível com LenteContato do componente -->
                            <ContactLensCard {lente} />
                        {/each}
                    </div>

                    <!-- Paginação -->
                    {#if total > itensPorPagina}
                        <div class="mt-10 flex justify-center">
                            <Pagination
                                currentPage={paginaAtual}
                                totalPages={Math.ceil(total / itensPorPagina)}
                                on:change={(e) => {
                                    paginaAtual = e.detail;
                                    carregarLentesContatos();
                                    window.scrollTo({
                                        top: 0,
                                        behavior: "smooth",
                                    });
                                }}
                            />
                        </div>
                    {/if}
                {/if}
            </div>
        </div>
    </Container>
</main>
