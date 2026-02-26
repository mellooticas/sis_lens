<script lang="ts">
    /**
     * ★ Detalhes do Conceito Canônico Premium — Canonical Engine v2
     * Exibe SKU CPR, pricing agregado, tratamentos e lentes premium mapeadas.
     */
    import { goto } from "$app/navigation";
    import { fade, fly } from "svelte/transition";
    import type { PageData } from "./$types";
    import type { CanonicalDetailEnriched } from "$lib/types/database-views";

    // Componentes
    import Container from "$lib/components/layout/Container.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import Badge from "$lib/components/ui/Badge.svelte";
    import {
        ChevronLeft, Crown, Zap, ShieldCheck, Brain,
        TrendingUp, CheckCircle2, Package, Star,
    } from "lucide-svelte";

    export let data: PageData;

    $: conceito = data.conceito;
    $: lentes = (data.lentes || []) as CanonicalDetailEnriched[];

    function formatarPreco(valor: number | null | undefined): string {
        if (valor == null) return "—";
        return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(valor);
    }

    function formatarMarkup(valor: number | null | undefined): string {
        if (valor == null) return "—";
        return `${valor.toFixed(2)}x`;
    }

    function formatarLensType(lt: string | null): string {
        const mapa: Record<string, string> = {
            single_vision: "Visão Simples", multifocal: "Multifocal",
            bifocal: "Bifocal", reading: "Leitura", occupational: "Ocupacional",
        };
        return lt ? (mapa[lt] ?? lt.replace(/_/g, " ")) : "—";
    }

    function formatarTratamento(code: string): string {
        const mapa: Record<string, string> = {
            ar: "Anti-Reflexo", scratch: "Anti-Risco",
            blue: "Blue Cut", uv: "UV", photo: "Fotossensível",
        };
        return mapa[code] ?? code.toUpperCase();
    }

    function getTratamentosLente(l: CanonicalDetailEnriched): string[] {
        const t: string[] = [];
        if (l.anti_reflective) t.push('Anti-Reflexo');
        if (l.anti_scratch)    t.push('Anti-Risco');
        if (l.uv_filter)       t.push('UV');
        if (l.blue_light)      t.push('Blue Cut');
        if (l.photochromic)    t.push('Fotossensível');
        if (l.polarized)       t.push('Polarizado');
        if (l.digital)         t.push('Digital');
        if (l.free_form)       t.push('Free Form');
        return t;
    }

    $: lentePreferida = lentes.find((l) => l.is_preferred);
    $: outrasLentes   = lentes.filter((l) => !l.is_preferred);
</script>

<svelte:head>
    <title>{conceito?.canonical_name || "Conceito Premium"} ★ | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
    <!-- Top Bar -->
    <div class="bg-white dark:bg-neutral-800 border-b border-neutral-200 dark:border-neutral-700 sticky top-0 z-30">
        <Container maxWidth="xl" padding="sm">
            <div class="flex items-center justify-between py-3">
                <button on:click={() => history.back()} class="flex items-center gap-2 text-neutral-500 hover:text-amber-600 transition-colors text-sm font-medium">
                    <ChevronLeft class="w-4 h-4" /> Voltar
                </button>
                <div class="flex items-center gap-3">
                    {#if conceito?.sku}
                        <span class="px-3 py-1 bg-amber-100 dark:bg-amber-900/40 text-amber-800 dark:text-amber-300 text-xs font-black rounded-full font-mono tracking-wider">
                            {conceito.sku}
                        </span>
                    {/if}
                    <Badge variant="warning" class="flex items-center gap-1">
                        <Crown class="w-3 h-3" /> Oracle Premium
                    </Badge>
                </div>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="lg">
        <!-- Hero -->
        <div class="mt-8 mb-12">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="lg:col-span-2 space-y-6">
                    <div in:fly={{ y: 20, duration: 500 }}>
                        {#if conceito?.treatment_codes?.length}
                            <div class="flex flex-wrap gap-2 mb-4">
                                {#each conceito.treatment_codes as code}
                                    <span class="px-2.5 py-1 bg-amber-100 dark:bg-amber-900/40 text-amber-800 dark:text-amber-300 text-xs font-bold rounded-full uppercase tracking-wide">
                                        {formatarTratamento(code)}
                                    </span>
                                {/each}
                            </div>
                        {/if}

                        <h1 class="text-3xl md:text-5xl font-black text-neutral-900 dark:text-white leading-tight mb-4">
                            {conceito?.canonical_name}
                        </h1>

                        <div class="flex flex-wrap gap-3">
                            <div class="flex items-center gap-2 bg-white dark:bg-neutral-800 px-4 py-2 rounded-xl shadow-sm border border-amber-100 dark:border-amber-900/30">
                                <Zap class="w-4 h-4 text-amber-500" />
                                <span class="font-bold text-neutral-900 dark:text-white capitalize">{formatarLensType(conceito?.lens_type)}</span>
                            </div>
                            <div class="flex items-center gap-2 bg-white dark:bg-neutral-800 px-4 py-2 rounded-xl shadow-sm border border-amber-100 dark:border-amber-900/30">
                                <ShieldCheck class="w-4 h-4 text-amber-500" />
                                <span class="font-bold text-neutral-900 dark:text-white">{conceito?.material_display}</span>
                            </div>
                            <div class="flex items-center gap-2 bg-white dark:bg-neutral-800 px-4 py-2 rounded-xl shadow-sm border border-amber-100 dark:border-amber-900/30">
                                <TrendingUp class="w-4 h-4 text-amber-500" />
                                <span class="font-bold text-neutral-900 dark:text-white">n = {conceito?.refractive_index}</span>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-neutral-900 p-6 rounded-2xl border-l-4 border-amber-500" in:fade={{ delay: 200 }}>
                        <div class="flex gap-4">
                            <div class="p-3 bg-amber-50 dark:bg-amber-900/20 rounded-xl h-fit">
                                <Brain class="w-6 h-6 text-amber-600 dark:text-amber-400" />
                            </div>
                            <div>
                                <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-1">★ Conceito Premium</h3>
                                <p class="text-neutral-600 dark:text-neutral-400 text-sm leading-relaxed">
                                    Agrupa <strong>{conceito?.mapped_lens_count ?? 0} lente(s)</strong> de
                                    <strong>{conceito?.mapped_brand_count ?? 0} marca(s)</strong> premium com a mesma física ótica.
                                </p>
                                <div class="flex gap-4 mt-3 text-xs font-semibold text-neutral-500">
                                    <span>📦 {conceito?.mapped_lens_count ?? 0} lentes</span>
                                    <span>🏷️ {conceito?.mapped_brand_count ?? 0} marcas</span>
                                    <span>🚚 {conceito?.mapped_supplier_count ?? 0} fornecedores</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Price Card Premium -->
                <div in:fly={{ x: 20, duration: 500 }}>
                    <div class="bg-gradient-to-br from-amber-900 to-orange-900 text-white rounded-3xl p-8 shadow-2xl relative overflow-hidden h-full">
                        <div class="absolute -right-10 -bottom-10 opacity-10"><Crown size={200} /></div>
                        <div class="relative z-10 space-y-5">
                            {#if conceito?.price_avg}
                                <div>
                                    <p class="text-amber-300 text-xs font-bold uppercase tracking-widest mb-2">Ticket Médio Premium</p>
                                    <h2 class="text-5xl font-black">{formatarPreco(conceito.price_avg)}</h2>
                                </div>
                            {:else}
                                <div>
                                    <p class="text-amber-300 text-xs font-bold uppercase tracking-widest mb-2">Pricing</p>
                                    <h2 class="text-2xl font-bold opacity-50">Sem dados</h2>
                                </div>
                            {/if}

                            <div class="space-y-2.5">
                                <div class="flex justify-between text-sm border-b border-white/10 pb-2">
                                    <span class="opacity-60">Piso de Venda</span>
                                    <span class="font-bold text-amber-200">{formatarPreco(conceito?.price_min)}</span>
                                </div>
                                <div class="flex justify-between text-sm border-b border-white/10 pb-2">
                                    <span class="opacity-60">Teto de Venda</span>
                                    <span class="font-bold text-amber-200">{formatarPreco(conceito?.price_max)}</span>
                                </div>
                                <div class="flex justify-between text-sm border-b border-white/10 pb-2">
                                    <span class="opacity-60">Piso de Custo</span>
                                    <span class="font-bold text-green-300">{formatarPreco(conceito?.cost_min)}</span>
                                </div>
                                <div class="flex justify-between text-sm">
                                    <span class="opacity-60">Markup</span>
                                    <span class="font-bold">{formatarMarkup(conceito?.markup_min)} — {formatarMarkup(conceito?.markup_max)}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Specs -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16">
            <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 p-8 rounded-2xl">
                <SectionHeader title="🧬 Especificações" subtitle="Range de fabricação" />
                <div class="grid grid-cols-2 gap-5 mt-6">
                    <div>
                        <p class="text-[10px] text-neutral-400 uppercase font-black tracking-widest">Esférico</p>
                        <p class="text-lg font-bold dark:text-white mt-1">
                            {conceito?.spherical_min != null ? (conceito.spherical_min > 0 ? '+' : '') + conceito.spherical_min : '—'} a
                            {conceito?.spherical_max != null ? (conceito.spherical_max > 0 ? '+' : '') + conceito.spherical_max : '—'}
                        </p>
                    </div>
                    <div>
                        <p class="text-[10px] text-neutral-400 uppercase font-black tracking-widest">Cilíndrico</p>
                        <p class="text-lg font-bold dark:text-white mt-1">{conceito?.cylindrical_min ?? '—'} a {conceito?.cylindrical_max ?? '—'}</p>
                    </div>
                    {#if conceito?.addition_max}
                        <div>
                            <p class="text-[10px] text-neutral-400 uppercase font-black tracking-widest">Adição</p>
                            <p class="text-lg font-bold dark:text-white mt-1">+{conceito.addition_min ?? 0} a +{conceito.addition_max}</p>
                        </div>
                    {/if}
                </div>
            </div>
            <div class="bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950/20 dark:to-orange-950/20 border border-amber-200 dark:border-amber-800 p-8 rounded-2xl flex flex-col justify-center">
                <div class="text-center">
                    <div class="inline-flex items-center justify-center p-4 bg-amber-100 dark:bg-amber-900/40 rounded-full mb-4">
                        <CheckCircle2 class="w-8 h-8 text-amber-600 dark:text-amber-400" />
                    </div>
                    <h3 class="text-xl font-black text-neutral-900 dark:text-white">Paridade Premium</h3>
                    <p class="text-neutral-500 text-sm mt-2 max-w-xs mx-auto">
                        Lentes premium intercambiáveis — mesma física ótica, diferentes marcas de alto padrão.
                    </p>
                    {#if conceito?.sku}
                        <div class="mt-4 text-xs text-neutral-400">
                            ID Premium: <span class="font-mono font-bold text-amber-600 dark:text-amber-400">{conceito.sku}</span>
                        </div>
                    {/if}
                </div>
            </div>
        </div>

        <!-- Lentes Mapeadas -->
        <div class="space-y-6">
            <SectionHeader
                title="★ Opções Premium do Catálogo"
                subtitle="{lentes.length} lente(s) premium vinculada(s) com pricing do seu contrato."
            />

            {#if lentes.length === 0}
                <div class="bg-white dark:bg-neutral-900 border border-dashed border-amber-200 dark:border-amber-800 p-16 text-center rounded-2xl">
                    <Package class="w-12 h-12 text-amber-300 mx-auto mb-4" />
                    <h3 class="text-xl font-bold dark:text-white mb-2">Nenhuma lente premium vinculada</h3>
                    <p class="text-neutral-500 text-sm">Sem lentes premium com pricing_book neste conceito.</p>
                </div>
            {:else}
                {#if lentePreferida}
                    <div in:fly={{ y: 20, duration: 400 }}>
                        <div class="flex items-center gap-2 mb-2">
                            <Star class="w-4 h-4 text-amber-500 fill-amber-500" />
                            <span class="text-sm font-bold text-amber-700 dark:text-amber-400">Opção Preferida</span>
                        </div>
                        <div class="bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-950/20 dark:to-orange-950/20 border-2 border-amber-300 dark:border-amber-700 rounded-2xl p-6">
                            <div class="flex flex-col md:flex-row md:items-start justify-between gap-4">
                                <div class="flex-1">
                                    <div class="font-bold text-neutral-900 dark:text-white text-lg">{lentePreferida.lens_name}</div>
                                    <div class="text-sm text-neutral-500">{lentePreferida.brand_name ?? '—'} · {lentePreferida.supplier_name ?? '—'}</div>
                                    {#if lentePreferida.lens_sku}
                                        <div class="font-mono text-[11px] text-neutral-400 mt-0.5">{lentePreferida.lens_sku}</div>
                                    {/if}
                                    {#if lentePreferida.material || lentePreferida.refractive_index}
                                        <div class="text-xs text-neutral-500 mt-1">
                                            {lentePreferida.material ?? ''}{lentePreferida.material && lentePreferida.refractive_index ? ' · ' : ''}{lentePreferida.refractive_index ? `n = ${lentePreferida.refractive_index}` : ''}
                                        </div>
                                    {/if}
                                    {#if getTratamentosLente(lentePreferida).length > 0}
                                        <div class="flex flex-wrap gap-1 mt-2">
                                            {#each getTratamentosLente(lentePreferida) as trat}
                                                <span class="px-1.5 py-0.5 bg-amber-100 dark:bg-amber-900/40 text-amber-700 dark:text-amber-300 text-[10px] font-bold rounded uppercase">{trat}</span>
                                            {/each}
                                        </div>
                                    {/if}
                                </div>
                                <div class="flex items-center gap-6">
                                    <div class="text-center">
                                        <div class="text-[10px] text-neutral-400 uppercase font-bold">Custo</div>
                                        <div class="font-bold text-neutral-700 dark:text-neutral-300">{formatarPreco(lentePreferida.cost_price)}</div>
                                    </div>
                                    <div class="text-center">
                                        <div class="text-[10px] text-neutral-400 uppercase font-bold">Venda</div>
                                        <div class="font-black text-amber-700 dark:text-amber-400 text-2xl">{formatarPreco(lentePreferida.sell_price)}</div>
                                    </div>
                                    <div class="text-center">
                                        <div class="text-[10px] text-neutral-400 uppercase font-bold">Markup</div>
                                        <div class="font-bold text-green-600 dark:text-green-400">{formatarMarkup(lentePreferida.effective_markup)}</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                {/if}

                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
                    {#each outrasLentes as lente, i (lente.lens_id)}
                        <div in:fly={{ y: 30, delay: i * 40, duration: 400 }}>
                            <div class="bg-white dark:bg-neutral-900 border border-amber-100 dark:border-amber-900/30 rounded-xl p-5 hover:shadow-lg transition-all duration-200 hover:border-amber-300 dark:hover:border-amber-700 relative group">
                                <div class="mb-3">
                                    <div class="font-semibold text-neutral-900 dark:text-white text-sm line-clamp-2">{lente.lens_name}</div>
                                    <div class="text-xs text-neutral-500 mt-0.5">{lente.brand_name ?? '—'}</div>
                                    {#if lente.supplier_name}
                                        <div class="text-xs text-neutral-400 mt-0.5">🚚 {lente.supplier_name}</div>
                                    {/if}
                                    {#if lente.lens_sku}
                                        <div class="font-mono text-[10px] text-neutral-400 mt-0.5">{lente.lens_sku}</div>
                                    {/if}
                                    {#if lente.material || lente.refractive_index}
                                        <div class="text-[11px] text-neutral-400 mt-1">
                                            {lente.material ?? ''}{lente.material && lente.refractive_index ? ' · ' : ''}{lente.refractive_index ? `n = ${lente.refractive_index}` : ''}
                                        </div>
                                    {/if}
                                    {#if getTratamentosLente(lente).length > 0}
                                        <div class="flex flex-wrap gap-1 mt-2">
                                            {#each getTratamentosLente(lente) as trat}
                                                <span class="px-1 py-0.5 bg-amber-50 dark:bg-amber-900/30 text-amber-600 dark:text-amber-400 text-[9px] font-bold rounded uppercase leading-none">{trat}</span>
                                            {/each}
                                        </div>
                                    {/if}
                                </div>
                                <div class="space-y-1.5 border-t border-neutral-100 dark:border-neutral-800 pt-3">
                                    <div class="flex justify-between text-xs">
                                        <span class="text-neutral-500">Custo</span>
                                        <span class="font-medium">{formatarPreco(lente.cost_price)}</span>
                                    </div>
                                    <div class="flex justify-between text-sm">
                                        <span class="font-medium text-neutral-600 dark:text-neutral-400">Venda</span>
                                        <span class="font-bold text-amber-700 dark:text-amber-400">{formatarPreco(lente.sell_price)}</span>
                                    </div>
                                    {#if lente.effective_markup}
                                        <div class="flex justify-between text-xs">
                                            <span class="text-neutral-500">Markup</span>
                                            <span class="font-semibold text-green-600 dark:text-green-400">{formatarMarkup(lente.effective_markup)}</span>
                                        </div>
                                    {/if}
                                </div>
                                <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <span class="text-[9px] text-neutral-400 font-mono bg-neutral-100 dark:bg-neutral-800 px-1.5 py-0.5 rounded">
                                        {lente.match_method}
                                    </span>
                                </div>
                            </div>
                        </div>
                    {/each}
                </div>
            {/if}
        </div>

        <!-- Ações -->
        <div class="flex gap-4 justify-center mt-16">
            <Button variant="secondary" on:click={() => history.back()}>← Voltar</Button>
            <Button variant="primary" on:click={() => goto('/simulador/receita')}>👓 Simular com Receita</Button>
        </div>
    </Container>
</main>
