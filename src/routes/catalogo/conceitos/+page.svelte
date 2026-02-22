<script lang="ts">
    /**
     * 🧠 Catálogo de Conceitos (Canônicas) - SIS Lens
     * Visão consolidada por conceitos óticos, separando Premium de Standard.
     */
    import { onMount } from "svelte";
    import { fade } from "svelte/transition";
    import { useGruposCanonicos } from "$lib/hooks/useGruposCanonicos";

    // Layout Components
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

    // UI Components
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
    import GrupoCanonicoCard from "$lib/components/catalogo/GrupoCanonicoCard.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import { Brain, Crown, Layers, Filter, ChevronRight } from "lucide-svelte";

    const { state, carregarTodosGrupos } = useGruposCanonicos();

    let activeTab: "premium" | "standard" = "premium";

    onMount(() => {
        carregarTodosGrupos({ limit: 100 });
    });

    $: currentGrupos =
        activeTab === "premium" ? $state.gruposPremium : $state.gruposGenericos;
    $: totalCount =
        activeTab === "premium" ? $state.totalPremium : $state.totalGenericos;
</script>

<svelte:head>
    <title>Conceitos Óticos | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
    <PageHero
        badge="Cérebro Clínico"
        title="Motor de Conceitos"
        subtitle="Visão consolidada do catálogo por especificações óticas, eliminando duplicidade comercial."
    />

    <Container maxWidth="xl" padding="lg">
        <div class="space-y-8">
            <!-- Navegação de Segmentos -->
            <div
                class="flex flex-col md:flex-row items-center justify-between gap-4 glass-panel p-2 rounded-2xl"
            >
                <div
                    class="flex p-1 bg-neutral-100 dark:bg-neutral-800 rounded-xl w-full md:w-auto"
                >
                    <button
                        on:click={() => (activeTab = "premium")}
                        class="flex-1 md:flex-none px-6 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center justify-center gap-2
              {activeTab === 'premium'
                            ? 'bg-white dark:bg-neutral-700 shadow-sm text-amber-600 dark:text-amber-400'
                            : 'text-neutral-500 hover:text-neutral-700'}"
                    >
                        <Crown class="w-4 h-4" />
                        Segmento Premium
                        <span
                            class="ml-1 text-[10px] px-1.5 py-0.5 rounded-full bg-amber-100 dark:bg-amber-900/50"
                            >{$state.totalPremium}</span
                        >
                    </button>
                    <button
                        on:click={() => (activeTab = "standard")}
                        class="flex-1 md:flex-none px-6 py-2.5 rounded-lg text-sm font-bold transition-all flex items-center justify-center gap-2
              {activeTab === 'standard'
                            ? 'bg-white dark:bg-neutral-700 shadow-sm text-primary-600 dark:text-primary-400'
                            : 'text-neutral-500 hover:text-neutral-700'}"
                    >
                        <Layers class="w-4 h-4" />
                        Segmento Standard
                        <span
                            class="ml-1 text-[10px] px-1.5 py-0.5 rounded-full bg-primary-100 dark:bg-primary-900/50"
                            >{$state.totalGenericos}</span
                        >
                    </button>
                </div>

                <div
                    class="hidden md:flex items-center gap-2 text-sm text-neutral-500"
                >
                    <Brain class="w-4 h-4 text-primary-500" />
                    <span
                        >As canônicas agora são <strong
                            >isoladas por nível</strong
                        > de mercado.</span
                    >
                </div>
            </div>

            <!-- Grid de Resultados -->
            <div class="space-y-6">
                {#if $state.loading}
                    <div
                        class="flex flex-col items-center justify-center py-24 glass-panel rounded-2xl"
                    >
                        <LoadingSpinner size="lg" />
                        <p class="mt-4 text-neutral-500 animate-pulse">
                            Consultando motor de canônicas...
                        </p>
                    </div>
                {:else if $state.error}
                    <div
                        class="glass-panel p-12 text-center rounded-2xl border-2 border-red-100"
                    >
                        <p class="text-red-500 font-bold mb-4">
                            {$state.error}
                        </p>
                        <Button
                            variant="secondary"
                            on:click={() => carregarTodosGrupos()}
                            >Tentar Recarregar</Button
                        >
                    </div>
                {:else if currentGrupos.length === 0}
                    <div class="glass-panel p-24 text-center rounded-2xl">
                        <div class="text-6xl mb-6 opacity-20">🧊</div>
                        <h3 class="text-2xl font-bold dark:text-white mb-2">
                            Nenhum conceito neste segmento
                        </h3>
                        <p class="text-neutral-500">
                            O motor de canônicas não encontrou grupos ativos
                            para {activeTab}.
                        </p>
                    </div>
                {:else}
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
                    >
                        {#each currentGrupos as grupo (grupo.id)}
                            <div in:fade>
                                <!-- Adaptando VCanonicalLens para GrupoCanonicoCard -->
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
