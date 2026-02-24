<script lang="ts">
    import { goto } from "$app/navigation";
    import { fade, fly, slide } from "svelte/transition";
    import type { PageData } from "./$types";

    // Componentes
    import Container from "$lib/components/layout/Container.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import Badge from "$lib/components/ui/Badge.svelte";
    import {
        ChevronLeft,
        Zap,
        ShieldCheck,
        Package,
        Truck,
        Clock,
        DollarSign,
        BarChart3,
        ArrowRight,
        Search,
        Brain,
        Info,
        CheckCircle2,
    } from "lucide-svelte";

    export let data: PageData;

    $: lente = data.lente;
    $: alternativas = data.alternativas || [];
    $: mapping = data.mapping;

    function formatarPreco(valor: number | null): string {
        if (valor === null) return "-";
        return new Intl.NumberFormat("pt-BR", {
            style: "currency",
            currency: "BRL",
        }).format(valor);
    }

    function formatarData(dataStr: string): string {
        return new Date(dataStr).toLocaleDateString("pt-BR");
    }
</script>

<svelte:head>
    <title>{lente.lens_name} | SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-24">
    <!-- Nav header -->
    <div
        class="bg-white dark:bg-neutral-800 border-b border-neutral-200 dark:border-neutral-700 sticky top-0 z-30"
    >
        <Container maxWidth="xl" padding="sm">
            <div class="flex items-center justify-between py-3">
                <button
                    on:click={() => history.back()}
                    class="flex items-center gap-2 text-neutral-500 hover:text-primary-600 transition-colors text-sm font-medium"
                >
                    <ChevronLeft class="w-4 h-4" />
                    Voltar
                </button>
                <div class="flex items-center gap-3">
                    <Badge
                        variant={lente.status === "active"
                            ? "success"
                            : "error"}
                        size="sm"
                    >
                        {lente.status === "active" ? "Item Ativo" : "Inativo"}
                    </Badge>
                    {#if lente.is_premium}
                        <Badge variant="gold" size="sm">Premium</Badge>
                    {/if}
                </div>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="lg">
        <!-- Main Product Header -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 mt-8 mb-16">
            <!-- Left: Basic Info & Stats -->
            <div class="lg:col-span-8 space-y-8">
                <div in:fly={{ y: 20, duration: 500 }}>
                    <div class="inline-flex items-center gap-2 mb-2">
                        <span
                            class="text-primary-600 dark:text-primary-400 font-bold tracking-widest text-xs uppercase"
                        >
                            {lente.brand_name || "Marca Desconhecida"}
                        </span>
                        <span class="text-neutral-300">•</span>
                        <span
                            class="text-neutral-500 text-xs uppercase tracking-widest"
                            >SKU: {lente.sku || "N/A"}</span
                        >
                    </div>

                    <h1
                        class="text-4xl md:text-6xl font-black text-neutral-900 dark:text-white leading-tight mb-6"
                    >
                        {lente.lens_name}
                    </h1>

                    <div class="flex flex-wrap gap-3">
                        <Badge
                            variant="neutral"
                            size="md"
                            class="px-5 py-2 !rounded-2xl shadow-sm"
                        >
                            {(lente.lens_type || "Visão Simples").replace(
                                "_",
                                " ",
                            )}
                        </Badge>
                        <Badge
                            variant="neutral"
                            size="md"
                            class="px-5 py-2 !rounded-2xl shadow-sm"
                        >
                            {lente.material}
                        </Badge>
                        <Badge
                            variant="neutral"
                            size="md"
                            class="px-5 py-2 !rounded-2xl shadow-sm"
                        >
                            n = {lente.refractive_index}
                        </Badge>
                    </div>
                </div>

                <!-- Technical Details Grid -->
                <div
                    class="grid grid-cols-1 md:grid-cols-2 gap-6"
                    in:fade={{ delay: 200 }}
                >
                    <div class="glass-panel p-8 rounded-3xl space-y-6">
                        <h3
                            class="text-lg font-bold flex items-center gap-3 text-neutral-900 dark:text-white"
                        >
                            <BarChart3 class="w-5 h-5 text-primary-500" />
                            Características Técnicas
                        </h3>

                        <div class="space-y-4">
                            <div
                                class="flex justify-between items-center py-2 border-b border-neutral-100 dark:border-neutral-700"
                            >
                                <span class="text-neutral-500 text-sm"
                                    >Design</span
                                >
                                <span
                                    class="font-bold text-neutral-900 dark:text-white"
                                    >{lente.free_form
                                        ? "Freeform Digital"
                                        : "Convencional"}</span
                                >
                            </div>
                            <div
                                class="flex justify-between items-center py-2 border-b border-neutral-100 dark:border-neutral-700"
                            >
                                <span class="text-neutral-500 text-sm"
                                    >Tratamento Base</span
                                >
                                <span
                                    class="font-bold text-neutral-900 dark:text-white"
                                    >{lente.anti_reflective
                                        ? "Antirreflexo"
                                        : "Sem AR"}</span
                                >
                            </div>
                            <div
                                class="flex justify-between items-center py-2 border-b border-neutral-100 dark:border-neutral-700"
                            >
                                <span class="text-neutral-500 text-sm">
                                    Blue Light</span
                                >
                                <span
                                    class="font-bold text-neutral-900 dark:text-white"
                                    >{lente.blue_light ? "Sim" : "Não"}</span
                                >
                            </div>
                            <div class="flex justify-between items-center py-2">
                                <span class="text-neutral-500 text-sm"
                                    >Fotossensível</span
                                >
                                <span
                                    class="font-bold text-neutral-900 dark:text-white"
                                    >{lente.photochromic &&
                                    lente.photochromic !== "nenhum"
                                        ? lente.photochromic
                                        : "Simples"}</span
                                >
                            </div>
                        </div>
                    </div>

                    <div class="glass-panel p-8 rounded-3xl space-y-6">
                        <h3
                            class="text-lg font-bold flex items-center gap-3 text-neutral-900 dark:text-white"
                        >
                            <ShieldCheck class="w-5 h-5 text-green-500" />
                            Ranges Ópticos
                        </h3>

                        <div class="grid grid-cols-2 gap-4">
                            <div
                                class="bg-neutral-50 dark:bg-neutral-900/50 p-4 rounded-xl border border-neutral-100 dark:border-neutral-700"
                            >
                                <p
                                    class="text-[10px] text-neutral-400 uppercase font-black mb-1"
                                >
                                    Esférico Máx
                                </p>
                                <p
                                    class="text-xl font-black text-neutral-900 dark:text-white"
                                >
                                    {lente.spherical_max ?? "—"}
                                </p>
                            </div>
                            <div
                                class="bg-neutral-50 dark:bg-neutral-900/50 p-4 rounded-xl border border-neutral-100 dark:border-neutral-700"
                            >
                                <p
                                    class="text-[10px] text-neutral-400 uppercase font-black mb-1"
                                >
                                    Cilíndrico Máx
                                </p>
                                <p
                                    class="text-xl font-black text-neutral-900 dark:text-white"
                                >
                                    {lente.cylindrical_max ?? "—"}
                                </p>
                            </div>
                            <div
                                class="bg-neutral-50 dark:bg-neutral-900/50 p-4 rounded-xl border border-neutral-100 dark:border-neutral-700"
                            >
                                <p
                                    class="text-[10px] text-neutral-400 uppercase font-black mb-1"
                                >
                                    Adição Máx
                                </p>
                                <p
                                    class="text-xl font-black text-neutral-900 dark:text-white"
                                >
                                    {lente.addition_max ?? "—"}
                                </p>
                            </div>
                            <div
                                class="bg-neutral-50 dark:bg-neutral-900/50 p-4 rounded-xl border border-neutral-100 dark:border-neutral-700"
                            >
                                <p
                                    class="text-[10px] text-neutral-400 uppercase font-black mb-1"
                                >
                                    Lead Time
                                </p>
                                <p
                                    class="text-xl font-black text-neutral-900 dark:text-white"
                                >
                                    {lente.lead_time_days} dias
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Mapping Intel (SIS Oracle) -->
                {#if mapping}
                    <div
                        class="bg-primary-600 text-white rounded-3xl p-8 relative overflow-hidden shadow-xl"
                        in:fly={{ y: 20, delay: 400 }}
                    >
                        <div class="absolute -right-10 -top-10 opacity-10">
                            <Brain size={200} />
                        </div>

                        <div
                            class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6"
                        >
                            <div class="space-y-2">
                                <Badge
                                    variant="info"
                                    class="!bg-white/20 border-white/30 text-white"
                                    >Mapeamento Inteligente</Badge
                                >
                                <h3 class="text-2xl font-black leading-tight">
                                    Esta lente pertence ao conceito:<br
                                    />{mapping.canonical_name}
                                </h3>
                            </div>
                            <div class="flex items-center gap-4">
                                <div class="text-right">
                                    <p
                                        class="text-[10px] opacity-60 uppercase font-bold"
                                    >
                                        Confiança
                                    </p>
                                    <p class="text-3xl font-black">
                                        {Math.round(
                                            mapping.confidence_score * 100,
                                        )}%
                                    </p>
                                </div>
                                <Button
                                    variant="ghost"
                                    class="!bg-white !text-primary-600 hover:!bg-primary-50"
                                    on:click={() =>
                                        goto(
                                            `/catalogo/${lente.is_premium ? "premium" : "standard"}/${mapping.canonical_lens_id}`,
                                        )}
                                >
                                    Ver Conceito completo
                                </Button>
                            </div>
                        </div>
                    </div>
                {/if}
            </div>

            <!-- Right: Pricing & Service -->
            <div class="lg:col-span-4 space-y-6">
                <div
                    class="bg-white dark:bg-neutral-800 rounded-3xl p-8 shadow-xl border border-neutral-200 dark:border-neutral-700 sticky top-24"
                >
                    <div class="space-y-8">
                        <div>
                            <p
                                class="text-neutral-500 text-xs font-bold uppercase tracking-widest mb-1"
                            >
                                Sugerido p/ Venda
                            </p>
                            <div class="flex items-baseline gap-1">
                                <span
                                    class="text-5xl font-black text-neutral-900 dark:text-white"
                                    >{formatarPreco(
                                        lente.price_suggested,
                                    )}</span
                                >
                            </div>
                        </div>

                        <div class="space-y-4">
                            <div
                                class="p-4 bg-neutral-50 dark:bg-neutral-900/50 rounded-2xl flex items-center justify-between"
                            >
                                <div class="flex items-center gap-3">
                                    <div
                                        class="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg"
                                    >
                                        <Truck
                                            class="w-4 h-4 text-blue-600 dark:text-blue-400"
                                        />
                                    </div>
                                    <div class="text-left">
                                        <p
                                            class="text-xs text-neutral-500 font-bold uppercase"
                                        >
                                            Logística
                                        </p>
                                        <p
                                            class="text-sm font-black dark:text-white"
                                        >
                                            Laboratório Próprio
                                        </p>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <p
                                        class="text-xs text-neutral-500 font-bold uppercase"
                                    >
                                        Prazo
                                    </p>
                                    <p class="text-sm font-black text-blue-600">
                                        {lente.lead_time_days}d
                                    </p>
                                </div>
                            </div>

                            <div
                                class="p-4 bg-neutral-50 dark:bg-neutral-900/50 rounded-2xl flex items-center justify-between"
                            >
                                <div class="flex items-center gap-3">
                                    <div
                                        class="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg"
                                    >
                                        <Package
                                            class="w-4 h-4 text-green-600 dark:text-green-400"
                                        />
                                    </div>
                                    <div class="text-left">
                                        <p
                                            class="text-xs text-neutral-500 font-bold uppercase"
                                        >
                                            Disponibilidade
                                        </p>
                                        <p
                                            class="text-sm font-black dark:text-white"
                                        >
                                            Estoque Local
                                        </p>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <p
                                        class="text-xs text-neutral-500 font-bold uppercase"
                                    >
                                        Unid.
                                    </p>
                                    <p
                                        class="text-sm font-black text-green-600"
                                    >
                                        {lente.stock_available}
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="pt-4 space-y-3">
                            <Button
                                variant="primary"
                                fullWidth
                                size="md"
                                class="!py-6 text-lg font-black rounded-2xl shadow-lg shadow-primary-500/20"
                            >
                                Selecionar para Venda
                            </Button>
                            <Button variant="ghost" fullWidth size="md">
                                Adicionar ao Laboratório
                            </Button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Alternatives Section -->
        {#if alternativas.length > 0}
            <div class="space-y-8" in:fade={{ delay: 600 }}>
                <SectionHeader
                    title="🔄 Lentes Alternativas"
                    subtitle="Produtos similares com especificações técnicas equivalentes e variação de preço."
                />

                <div
                    class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6"
                >
                    {#each alternativas as alt (alt.id)}
                        <div
                            class="bg-white dark:bg-neutral-800 rounded-2xl p-6 border border-neutral-100 dark:border-neutral-700 shadow-sm hover:shadow-md transition-all group"
                        >
                            <div class="flex flex-col h-full">
                                <div class="flex-1 space-y-4">
                                    <div>
                                        <p
                                            class="text-[10px] text-neutral-400 uppercase font-black mb-1"
                                        >
                                            {alt.supplier_name}
                                        </p>
                                        <h4
                                            class="font-bold text-neutral-900 dark:text-white line-clamp-2 leading-tight group-hover:text-primary-600 transition-colors"
                                        >
                                            {alt.lens_name}
                                        </h4>
                                    </div>

                                    <div class="flex items-baseline gap-2">
                                        <span
                                            class="text-2xl font-black text-neutral-900 dark:text-white"
                                            >{formatarPreco(
                                                alt.price_suggested,
                                            )}</span
                                        >
                                        {#if alt.price_diff !== 0}
                                            <span
                                                class="text-[10px] font-bold px-1.5 py-0.5 rounded {alt.price_diff <
                                                0
                                                    ? 'bg-green-100 text-green-700'
                                                    : 'bg-red-100 text-red-700'}"
                                            >
                                                {alt.price_diff > 0
                                                    ? "+"
                                                    : ""}{formatarPreco(
                                                    alt.price_diff,
                                                )}
                                            </span>
                                        {/if}
                                    </div>

                                    <div
                                        class="flex items-center gap-4 text-[10px] text-neutral-500 font-medium"
                                    >
                                        <span class="flex items-center gap-1"
                                            ><Truck class="w-3 h-3" />
                                            {alt.lead_time_days} dias</span
                                        >
                                        <span
                                            class="flex items-center gap-1 font-bold text-green-600"
                                            ><CheckCircle2 class="w-3 h-3" /> Compatível</span
                                        >
                                    </div>
                                </div>

                                <button
                                    on:click={() =>
                                        goto(`/catalogo/lente/${alt.id}`)}
                                    class="mt-6 w-full flex items-center justify-between text-xs font-bold text-primary-600 hover:text-primary-700 pt-4 border-t border-neutral-50 dark:border-neutral-700"
                                >
                                    Ver Detalhes
                                    <ArrowRight class="w-4 h-4" />
                                </button>
                            </div>
                        </div>
                    {/each}
                </div>
            </div>
        {/if}
    </Container>
</main>

<style>
    :global(.glass-panel) {
        background-color: rgba(255, 255, 255, 0.7);
        backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.2);
    }

    :global(.dark .glass-panel) {
        background-color: rgba(38, 38, 38, 0.7);
        border-color: rgba(64, 64, 64, 0.3);
    }
</style>
