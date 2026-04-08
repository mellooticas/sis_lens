<script lang="ts">
    /**
     * Detalhe da Lente Real
     * Server load: lente (v_catalog_lenses) + conceitos canônicos
     */
    import { Crown, Sparkles, ChevronLeft, Layers } from 'lucide-svelte';
    import Container from '$lib/components/layout/Container.svelte';
    import { supabase } from '$lib/supabase';
    import type { PageData } from './$types';
    import type { VCatalogLens } from '$lib/types/database-views';

    export let data: PageData;

    $: lente = data.lente as unknown as VCatalogLens;
    $: conceito = data.conceito;
    $: isPremium = data.isPremium;

    const TIPO_LABELS: Record<string, string> = {
        single_vision: 'Visão Simples',
        multifocal:    'Multifocal',
        bifocal:       'Bifocal',
        occupational:  'Ocupacional',
    };

    // Tratamentos derivados
    $: tratamentos = (() => {
        const nomes = lente.treatment_names ?? [];
        if (nomes.length > 0) return nomes;
        const r: string[] = [];
        if (lente.anti_reflective) r.push('Anti-Reflexo');
        if (lente.anti_scratch)    r.push('Anti-Risco');
        if (lente.uv_filter)       r.push('UV400');
        if (lente.blue_light)      r.push('Blue Cut');
        if (lente.photochromic)    r.push('Fotossensível');
        if (lente.polarized)       r.push('Polarizado');
        return r;
    })();

    // Edição de preços
    let editando      = false;
    let editCost      = 0;
    let editSugerido  = 0;
    let editSalvando  = false;
    let editErro: string | null = null;
    let editSucesso   = false;

    function abrirEdicao() {
        editCost     = lente.price_cost      ?? 0;
        editSugerido = lente.price_suggested ?? 0;
        editErro     = null;
        editSucesso  = false;
        editando     = true;
    }

    async function salvarPrecos() {
        editSalvando = true;
        editErro     = null;
        editSucesso  = false;
        try {
            const { data: res, error: err } = await supabase.rpc('rpc_update_lens_price', {
                p_id:              lente.id,
                p_price_cost:      editCost,
                p_price_suggested: editSugerido,
            });
            if (err) throw new Error(err.message);
            if (res && !res.ok) throw new Error(res.error ?? 'Erro ao salvar');
            lente = { ...lente, price_cost: editCost, price_suggested: editSugerido } as VCatalogLens;
            editando     = false;
            editSucesso  = true;
            setTimeout(() => editSucesso = false, 3000);
        } catch (e: any) {
            editErro = e.message;
        } finally {
            editSalvando = false;
        }
    }

    function fmt(v: number | null | undefined): string {
        if (v == null) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v);
    }

    function fmtDiopter(v: number | null | undefined): string {
        if (v == null) return '—';
        const sign = v > 0 ? '+' : '';
        return `${sign}${v.toFixed(2)}`;
    }
</script>

<svelte:head>
    <title>{lente.lens_name ?? 'Lente'} | Clearix Lens</title>
</svelte:head>

<main class="min-h-screen bg-muted pb-24">
    <!-- Top bar -->
    <div class="bg-card border-b border-border sticky top-0 z-30">
        <Container>
            <div class="flex items-center justify-between py-4">
                <a href="/lentes" class="flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors text-sm font-medium">
                    <ChevronLeft class="h-4 w-4" /> Catálogo de Lentes
                </a>
                {#if isPremium}
                    <span class="px-3 py-1 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 text-xs font-bold rounded-full uppercase flex items-center gap-1">
                        <Crown class="h-3 w-3" /> Premium
                    </span>
                {:else}
                    <span class="px-3 py-1 bg-cyan-100 dark:bg-cyan-900/30 text-cyan-700 dark:text-cyan-300 text-xs font-bold rounded-full uppercase flex items-center gap-1">
                        <Sparkles class="h-3 w-3" /> Standard
                    </span>
                {/if}
            </div>
        </Container>
    </div>

    <Container>
        <div class="py-8 grid grid-cols-1 lg:grid-cols-3 gap-6">

            <!-- Coluna principal -->
            <div class="lg:col-span-2 space-y-6">

                <!-- Header -->
                <div class="bg-card border border-border rounded-2xl p-6">
                    <h1 class="text-2xl font-black text-foreground leading-tight">
                        {lente.lens_name ?? '—'}
                    </h1>
                    <p class="text-sm text-muted-foreground mt-1">
                        {lente.brand_name ?? '—'}
                        {#if lente.supplier_name} · {lente.supplier_name}{/if}
                    </p>
                    {#if lente.sku}
                        <p class="font-mono text-xs text-muted-foreground mt-2">SKU: {lente.sku}</p>
                    {/if}

                    <!-- Specs grid -->
                    <div class="grid grid-cols-2 sm:grid-cols-3 gap-3 mt-5">
                        {#if lente.lens_type}
                            <div class="bg-muted rounded-xl px-3 py-2.5">
                                <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-0.5">Tipo</div>
                                <div class="text-sm font-semibold text-foreground">{TIPO_LABELS[lente.lens_type] ?? lente.lens_type}</div>
                            </div>
                        {/if}
                        {#if lente.material_name}
                            <div class="bg-muted rounded-xl px-3 py-2.5">
                                <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-0.5">Material</div>
                                <div class="text-sm font-semibold text-foreground">{lente.material_name}</div>
                            </div>
                        {/if}
                        {#if lente.refractive_index}
                            <div class="bg-muted rounded-xl px-3 py-2.5">
                                <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-0.5">Índice</div>
                                <div class="text-sm font-semibold text-foreground">n = {lente.refractive_index}</div>
                            </div>
                        {/if}
                        {#if lente.stock_available != null}
                            <div class="bg-muted rounded-xl px-3 py-2.5">
                                <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-0.5">Estoque</div>
                                <div class="text-sm font-semibold {lente.stock_available > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-500'}">{lente.stock_available} unid.</div>
                            </div>
                        {/if}
                    </div>
                </div>

                <!-- Tratamentos -->
                {#if tratamentos.length > 0}
                    <div class="bg-card border border-border rounded-2xl p-5">
                        <h2 class="text-sm font-black uppercase tracking-wide text-muted-foreground mb-3">Tratamentos</h2>
                        <div class="flex flex-wrap gap-2">
                            {#each tratamentos as t}
                                <span class="px-3 py-1.5 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300 text-xs font-bold rounded-lg border border-primary-100 dark:border-primary-800">{t}</span>
                            {/each}
                        </div>
                    </div>
                {/if}

                <!-- Faixa de prescrição -->
                {#if lente.spherical_min != null || lente.cylindrical_min != null}
                    <div class="bg-card border border-border rounded-2xl p-5">
                        <h2 class="text-sm font-black uppercase tracking-wide text-muted-foreground mb-3">Faixa de Prescrição</h2>
                        <div class="grid grid-cols-3 gap-3">
                            <div class="text-center bg-muted rounded-xl p-3">
                                <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1">Esférico</div>
                                <div class="font-mono text-sm text-foreground">
                                    {fmtDiopter(lente.spherical_min)} a {fmtDiopter(lente.spherical_max)}
                                </div>
                            </div>
                            <div class="text-center bg-muted rounded-xl p-3">
                                <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1">Cilíndrico</div>
                                <div class="font-mono text-sm text-foreground">
                                    {fmtDiopter(lente.cylindrical_min)} a {fmtDiopter(lente.cylindrical_max)}
                                </div>
                            </div>
                            {#if lente.addition_min != null}
                                <div class="text-center bg-muted rounded-xl p-3">
                                    <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1">Adição</div>
                                    <div class="font-mono text-sm text-foreground">
                                        {fmtDiopter(lente.addition_min)} a {fmtDiopter(lente.addition_max)}
                                    </div>
                                </div>
                            {/if}
                        </div>
                    </div>
                {/if}

                <!-- Conceito canônico ao qual a lente pertence (1:1 — N:1 reverso) -->
                <div class="bg-card border border-border rounded-2xl overflow-hidden">
                    <div class="px-5 py-4 border-b border-border flex items-center gap-2">
                        <Layers class="h-4 w-4 text-muted-foreground" />
                        <h2 class="text-sm font-black uppercase tracking-wide text-muted-foreground">
                            Conceito Canônico
                        </h2>
                    </div>
                    {#if !conceito}
                        <p class="px-5 py-8 text-sm text-center text-muted-foreground">
                            Esta lente ainda não foi mapeada para um conceito canônico.
                        </p>
                    {:else}
                        <a
                            href="{conceito.kind === 'premium' ? '/premium' : '/standard'}/{conceito.id}"
                            class="block px-5 py-4 hover:bg-accent transition-colors"
                        >
                            <div class="flex items-start justify-between gap-4">
                                <div class="flex-1 min-w-0">
                                    <p class="font-semibold text-foreground truncate">{conceito.canonical_name}</p>
                                    <p class="text-xs text-muted-foreground mt-1 truncate">
                                        {conceito.material_name ?? conceito.material_class}
                                        {#if conceito.refractive_index} · n={conceito.refractive_index}{/if}
                                        {#if conceito.treatment_codes && conceito.treatment_codes.length > 0} · {conceito.treatment_codes.join(', ')}{/if}
                                    </p>
                                    {#if conceito.sku}
                                        <p class="font-mono text-[10px] text-muted-foreground mt-1">{conceito.sku}</p>
                                    {/if}
                                </div>
                                <div class="text-right shrink-0">
                                    <p class="text-xs text-muted-foreground">{conceito.mapped_lens_count} lentes</p>
                                    {#if conceito.price_avg != null}
                                        <p class="text-sm font-bold text-primary-600 dark:text-primary-400 mt-0.5">~{fmt(conceito.price_avg)}</p>
                                    {/if}
                                </div>
                            </div>
                        </a>
                    {/if}
                </div>
            </div>

            <!-- Sidebar preço -->
            <div class="space-y-4">
                <div class="bg-card border border-border rounded-2xl p-5 sticky top-20">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="text-sm font-black uppercase tracking-wide text-muted-foreground">Preços</h2>
                        {#if !editando}
                            <button on:click={abrirEdicao} class="text-xs font-bold text-primary-600 hover:text-primary-700 dark:text-primary-400 transition-colors">
                                Editar
                            </button>
                        {/if}
                    </div>

                    {#if editSucesso}
                        <div class="mb-3 px-3 py-2 bg-emerald-50 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 text-xs font-bold rounded-lg">
                            ✓ Preços atualizados com sucesso
                        </div>
                    {/if}

                    {#if editando}
                        <div class="space-y-3">
                            <div>
                                <label for="edit-cost" class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1">Custo (R$)</label>
                                <input id="edit-cost" type="number" step="0.01" min="0" bind:value={editCost}
                                    class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500" />
                            </div>
                            <div>
                                <label for="edit-suggested" class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1">Sugerido (R$)</label>
                                <input id="edit-suggested" type="number" step="0.01" min="0" bind:value={editSugerido}
                                    class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500" />
                            </div>
                            {#if editCost > 0 && editSugerido > 0}
                                <div class="text-xs text-muted-foreground text-right">
                                    Margem:
                                    <span class="font-bold text-emerald-600 dark:text-emerald-400">
                                        {(((editSugerido - editCost) / editSugerido) * 100).toFixed(1)}%
                                    </span>
                                </div>
                            {/if}
                            {#if editErro}
                                <p class="text-xs text-red-500 font-medium">{editErro}</p>
                            {/if}
                            <div class="flex gap-2 pt-1">
                                <button on:click={salvarPrecos} disabled={editSalvando}
                                    class="flex-1 px-3 py-2 bg-primary-600 hover:bg-primary-700 disabled:opacity-50 text-white text-xs font-bold rounded-lg transition-colors">
                                    {editSalvando ? 'Salvando…' : 'Salvar'}
                                </button>
                                <button on:click={() => { editando = false; editErro = null; }}
                                    class="px-3 py-2 bg-muted hover:bg-accent text-muted-foreground text-xs font-bold rounded-lg transition-colors">
                                    Cancelar
                                </button>
                            </div>
                        </div>
                    {:else}
                        <div class="space-y-4">
                            {#if lente.price_suggested}
                                <div>
                                    <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground">Sugerido</div>
                                    <div class="text-3xl font-black text-foreground mt-0.5">{fmt(lente.price_suggested)}</div>
                                </div>
                            {/if}
                            {#if lente.price_cost}
                                <div class="pt-3 border-t border-border">
                                    <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground">Custo</div>
                                    <div class="text-xl font-bold text-muted-foreground mt-0.5">{fmt(lente.price_cost)}</div>
                                </div>
                            {/if}
                            {#if lente.price_cost && lente.price_suggested}
                                <div class="pt-3 border-t border-border">
                                    <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground">Margem</div>
                                    <div class="text-lg font-bold text-emerald-600 dark:text-emerald-400 mt-0.5">
                                        {(((lente.price_suggested - lente.price_cost) / lente.price_suggested) * 100).toFixed(1)}%
                                    </div>
                                </div>
                            {/if}
                        </div>
                    {/if}

                    {#if lente.lead_time_days || lente.stock_minimum}
                        <div class="mt-6 pt-6 border-t border-border space-y-2">
                            {#if lente.lead_time_days}
                                <div class="flex items-center justify-between">
                                    <span class="text-xs text-muted-foreground">Prazo entrega</span>
                                    <span class="text-xs font-bold text-foreground">{lente.lead_time_days} dias</span>
                                </div>
                            {/if}
                            {#if lente.stock_minimum}
                                <div class="flex items-center justify-between">
                                    <span class="text-xs text-muted-foreground">Estoque mínimo</span>
                                    <span class="text-xs font-bold text-foreground">{lente.stock_minimum} unid.</span>
                                </div>
                            {/if}
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </Container>
</main>
