<script lang="ts">
    /**
     * Detalhe da Lente Real — client-side via browser supabase
     * Fonte: public.v_catalog_lenses
     */
    import { onMount } from 'svelte';
    import type { PageData } from './$types';
    import { supabase } from '$lib/supabase';
    import Container from '$lib/components/layout/Container.svelte';

    export let data: PageData;

    const TIPO_LABELS: Record<string, string> = {
        single_vision: 'Visão Simples',
        multifocal:    'Multifocal',
        bifocal:       'Bifocal',
        occupational:  'Ocupacional',
    };

    // Estado
    let lente: Record<string, any> | null = null;
    let loading = true;
    let erro: string | null = null;

    // Tratamentos calculados
    let tratamentos: string[] = [];

    // Edição de preços
    let editando      = false;
    let editCost      = 0;
    let editSugerido  = 0;
    let editSalvando  = false;
    let editErro: string | null = null;
    let editSucesso   = false;

    onMount(async () => {
        const { data: row, error: err } = await supabase
            .from('v_catalog_lenses')
            .select('*')
            .eq('id', data.id)
            .single();

        if (err || !row) {
            erro = err?.message ?? 'Lente não encontrada';
        } else {
            lente = row;
            editCost     = row.price_cost      ?? 0;
            editSugerido = row.price_suggested ?? 0;
            // Calcula tratamentos
            const nomes: string[] = row.treatment_names ?? [];
            if (nomes.length > 0) {
                tratamentos = nomes;
            } else {
                if (row.anti_reflective) tratamentos.push('Anti-Reflexo');
                if (row.anti_scratch)    tratamentos.push('Anti-Risco');
                if (row.uv_filter)       tratamentos.push('UV400');
                if (row.blue_light)      tratamentos.push('Blue Cut');
                if (row.photochromic)    tratamentos.push('Fotossensível');
                if (row.polarized)       tratamentos.push('Polarizado');
            }
        }
        loading = false;
    });

    function abrirEdicao() {
        editCost     = lente?.price_cost      ?? 0;
        editSugerido = lente?.price_suggested ?? 0;
        editErro     = null;
        editSucesso  = false;
        editando     = true;
    }

    async function salvarPrecos() {
        editSalvando = true;
        editErro     = null;
        editSucesso  = false;
        try {
            const { data: res, error: err } = await supabase
                .rpc('rpc_update_lens_price', {
                    p_id:              lente!.id,
                    p_price_cost:      editCost,
                    p_price_suggested: editSugerido,
                });
            if (err) throw new Error(err.message);
            if (res && !res.ok) throw new Error(res.error ?? 'Erro ao salvar');
            lente        = { ...lente!, price_cost: editCost, price_suggested: editSugerido };
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

    function fmtNum(v: number | null | undefined, suffix = ''): string {
        if (v == null) return '—';
        return `${v}${suffix}`;
    }
</script>

<svelte:head>
    <title>{lente?.lens_name ?? 'Lente'} | Clearix Lens</title>
</svelte:head>

<main class="min-h-screen bg-muted pb-24">

    <!-- Back bar -->
    <div class="bg-card border-b border-border">
        <Container maxWidth="xl" padding="sm">
            <div class="py-3">
                <a href="/lentes" class="inline-flex items-center gap-2 text-sm font-bold text-muted-foreground hover:text-foreground transition-colors">
                    <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/>
                    </svg>
                    Catálogo de Lentes
                </a>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="md">
        <div class="mt-6">

            {#if loading}
                <div class="flex flex-col items-center justify-center py-24 bg-card border border-border rounded-2xl">
                    <div class="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p class="text-muted-foreground text-sm">Carregando dados da lente...</p>
                </div>

            {:else if erro || !lente}
                <div class="py-16 text-center bg-card border border-red-200 dark:border-red-900 rounded-2xl">
                    <div class="text-5xl mb-4">😕</div>
                    <p class="text-red-500 font-semibold">{erro ?? 'Lente não encontrada'}</p>
                    <a href="/lentes" class="mt-4 inline-block px-4 py-2 bg-primary-600 text-white text-sm font-bold rounded-lg">
                        ← Voltar ao Catálogo
                    </a>
                </div>

            {:else}
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                    <!-- Coluna principal -->
                    <div class="lg:col-span-2 space-y-4">

                        <!-- Header card -->
                        <div class="bg-card border border-border rounded-2xl p-6">
                            <div class="flex items-start justify-between gap-4 mb-4">
                                <div>
                                    <h1 class="text-xl font-black text-foreground leading-tight">
                                        {lente.lens_name ?? '—'}
                                    </h1>
                                    <p class="text-sm text-muted-foreground mt-0.5">
                                        {lente.supplier_name ?? '—'}{#if lente.brand_name} · {lente.brand_name}{/if}
                                    </p>
                                </div>
                                <div class="flex gap-2 shrink-0">
                                    {#if lente.is_premium}
                                        <span class="px-2 py-1 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 text-xs font-black rounded-full uppercase">★ Premium</span>
                                    {:else}
                                        <span class="px-2 py-1 bg-sky-50 dark:bg-sky-900/20 text-sky-600 dark:text-sky-400 text-xs font-black rounded-full uppercase">Standard</span>
                                    {/if}
                                    {#if lente.status === 'active'}
                                        <span class="px-2 py-1 bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 dark:text-emerald-400 text-xs font-black rounded-full uppercase">Ativo</span>
                                    {/if}
                                </div>
                            </div>

                            <!-- Specs grid -->
                            <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
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
                                {#if lente.category}
                                    <div class="bg-muted rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-0.5">Categoria</div>
                                        <div class="text-sm font-semibold text-foreground capitalize">{lente.category}</div>
                                    </div>
                                {/if}
                                {#if lente.sku}
                                    <div class="bg-muted rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-0.5">SKU</div>
                                        <div class="font-mono text-sm font-semibold text-foreground">{lente.sku}</div>
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
                                        <div class="text-sm font-bold text-foreground">{fmtNum(lente.spherical_min)}</div>
                                        <div class="text-xs text-muted-foreground">a</div>
                                        <div class="text-sm font-bold text-foreground">{fmtNum(lente.spherical_max)}</div>
                                    </div>
                                    <div class="text-center bg-muted rounded-xl p-3">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1">Cilíndrico</div>
                                        <div class="text-sm font-bold text-foreground">{fmtNum(lente.cylindrical_min)}</div>
                                        <div class="text-xs text-muted-foreground">a</div>
                                        <div class="text-sm font-bold text-foreground">{fmtNum(lente.cylindrical_max)}</div>
                                    </div>
                                    {#if lente.addition_min != null}
                                        <div class="text-center bg-muted rounded-xl p-3">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1">Adição</div>
                                            <div class="text-sm font-bold text-foreground">{fmtNum(lente.addition_min)}</div>
                                            <div class="text-xs text-muted-foreground">a</div>
                                            <div class="text-sm font-bold text-foreground">{fmtNum(lente.addition_max)}</div>
                                        </div>
                                    {/if}
                                </div>
                            </div>
                        {/if}
                    </div>

                    <!-- Sidebar preço -->
                    <div class="space-y-4">
                        <div class="bg-card border border-border rounded-2xl p-5">
                            <div class="flex items-center justify-between mb-4">
                                <h2 class="text-sm font-black uppercase tracking-wide text-muted-foreground">Preços</h2>
                                {#if !editando}
                                    <button on:click={abrirEdicao}
                                        class="text-xs font-bold text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 transition-colors">
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
                                <!-- Modo edição -->
                                <div class="space-y-3">
                                    <div>
                                        <label class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1">Custo (R$)</label>
                                        <input type="number" step="0.01" min="0" bind:value={editCost}
                                            class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500" />
                                    </div>
                                    <div>
                                        <label class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1">Preço Sugerido (R$)</label>
                                        <input type="number" step="0.01" min="0" bind:value={editSugerido}
                                            class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500" />
                                    </div>
                                    {#if editCost > 0 && editSugerido > 0}
                                        <div class="text-xs text-muted-foreground text-right">
                                            Margem: <span class="font-bold text-emerald-600 dark:text-emerald-400">
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
                                <!-- Modo leitura -->
                                <div class="space-y-4">
                                    {#if lente.price_suggested}
                                        <div>
                                            <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground">Preço Sugerido</div>
                                            <div class="text-3xl font-black text-foreground mt-0.5">{fmt(lente.price_suggested)}</div>
                                        </div>
                                    {/if}
                                    {#if lente.price_cost}
                                        <div class="pt-3 border-t border-border">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-muted-foreground">Custo</div>
                                            <div class="text-xl font-bold text-muted-foreground dark:text-muted-foreground mt-0.5">{fmt(lente.price_cost)}</div>
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
                        </div>

                        {#if lente.lead_time_days || lente.stock_minimum}
                            <div class="bg-card border border-border rounded-2xl p-5">
                                <h2 class="text-sm font-black uppercase tracking-wide text-muted-foreground mb-3">Logística</h2>
                                <div class="space-y-2">
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
                            </div>
                        {/if}

                        <a href="/lentes"
                            class="block w-full text-center px-4 py-3 bg-muted hover:bg-accent text-foreground text-sm font-bold rounded-xl transition-colors">
                            ← Voltar ao Catálogo
                        </a>
                    </div>
                </div>
            {/if}
        </div>
    </Container>
</main>
