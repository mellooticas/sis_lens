<script lang="ts">
    import { onMount } from "svelte";
    import { fade, slide } from "svelte/transition";
    import { LensOracleAPI } from "$lib/api/lens-oracle";
    import type {
        RpcContactLensSearchResult,
        VBrand,
    } from "$lib/types/database-views";
    import type { FiltrosLentesContato } from "$lib/types/contact-lens";
    import { SlidersHorizontal, RotateCcw, ChevronDown } from "lucide-svelte";

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
    let total = 0;
    let paginaAtual = 1;
    const itensPorPagina = 12;

    let filters: FiltrosLentesContato = {};
    let showFilters = false; // Começa recolhido no novo padrão

    // Marcas e Fabricantes carregados no server
    const brands: VBrand[] = (data.brands || []).filter((b: VBrand | null): b is VBrand => b !== null);
    const manufacturers: string[] = ((data.manufacturers || []) as (string | null)[]).filter((m): m is string => m !== null);

    async function carregarLentesContatos() {
        try {
            loading = true;
            error = "";

            // Mapeia nome da marca para ID se selecionado
            let brandId: string | null = null;
            if (filters.marcas?.[0]) {
                const brand = brands.find(
                    (b) => b.name === filters.marcas?.[0],
                );
                if (brand) brandId = brand.brand_id;
            }

            const res = await LensOracleAPI.searchContactLenses({
                query: filters.busca,
                brand_id: brandId as any,
                lens_type: filters.tipos?.[0] as any,
                purpose: filters.finalidades?.[0] as any,
                material: filters.materiais?.[0] as any,
                limit: itensPorPagina,
                offset: (paginaAtual - 1) * itensPorPagina,
            });

            if (res.data) {
                lentes = res.data;
                // Simula total para paginação se não vier da API (RPC simples costuma não retornar count)
                if (total === 0 || paginaAtual === 1) {
                    total =
                        res.data.length < itensPorPagina
                            ? res.data.length
                            : 225;
                }
            } else {
                error =
                    res.error?.message || "Erro ao carregar lentes de contato";
                if (error.includes("permission denied")) {
                    error =
                        "Acesso negado: Verifique as permissões do RPC rpc_contact_lens_search no banco.";
                }
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
        <div class="space-y-8">
            <!-- Filtro no Topo (Recolhível) - PADRÃO SIS LENS -->
            <div class="w-full">
                <div
                    class="w-full glass-panel rounded-xl p-4 flex items-center justify-between hover:shadow-lg transition-all duration-300 cursor-pointer group"
                    on:click={() => (showFilters = !showFilters)}
                    on:keydown={(e) =>
                        e.key === "Enter" && (showFilters = !showFilters)}
                    role="button"
                    tabindex="0"
                >
                    <div class="flex items-center gap-3">
                        <div
                            class="p-2 rounded-lg bg-primary-50 dark:bg-primary-900/40 text-primary-600 dark:text-primary-400 group-hover:scale-110 transition-transform"
                        >
                            <SlidersHorizontal class="w-5 h-5" />
                        </div>
                        <div>
                            <h3
                                class="text-lg font-semibold text-neutral-900 dark:text-neutral-100"
                            >
                                Configurar Filtros
                            </h3>
                            <p class="text-sm text-neutral-500">
                                {showFilters
                                    ? "Clique para recolher"
                                    : "Clique para expandir e filtrar"}
                            </p>
                        </div>
                    </div>
                    <div class="flex items-center gap-4">
                        {#if Object.keys(filters).length > 0}
                            <span
                                class="px-2 py-1 rounded-full bg-primary-100 dark:bg-primary-900/60 text-primary-700 dark:text-primary-300 text-xs font-bold"
                            >
                                Ativos
                            </span>
                        {/if}
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
                        class="mt-4 p-6 glass-panel rounded-xl border-primary-200/50 dark:border-primary-800/50 bg-white/50 dark:bg-neutral-800/50"
                    >
                        <ContactLensFilterPanel
                            {filters}
                            {loading}
                            totalResults={lentes.length}
                            availableBrands={brands.map((b) => b.name)}
                            availableSuppliers={manufacturers}
                            on:change={handleFilterChange}
                            on:clear={handleClearFilters}
                        />
                        <div
                            class="mt-6 flex justify-end border-t border-neutral-100 dark:border-neutral-700 pt-4"
                        >
                            <Button
                                variant="ghost"
                                size="sm"
                                on:click={handleClearFilters}
                            >
                                <RotateCcw class="w-4 h-4 mr-2" /> Limpar Filtros
                            </Button>
                        </div>
                    </div>
                {/if}
            </div>

            <!-- Grid de Resultados -->
            <div class="space-y-6">
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
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 gap-6"
                    >
                        {#each lentes as lente (lente.id)}
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
