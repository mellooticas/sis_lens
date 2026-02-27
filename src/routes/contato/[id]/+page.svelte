<script lang="ts">
    /**
     * Detalhe da Lente de Contato — client-side via browser supabase
     * Fonte: public.v_contact_lenses
     */
    import { onMount } from 'svelte';
    import type { PageData } from './$types';
    import { supabase } from '$lib/supabase';
    import Container from '$lib/components/layout/Container.svelte';

    export let data: PageData;

    const DESCARTE_LABELS: Record<string, string> = {
        diaria:     'Descarte Diário',
        quinzenal:  'Descarte Quinzenal',
        mensal:     'Descarte Mensal',
        trimestral: 'Descarte Trimestral',
        anual:      'Uso Anual',
    };

    const PURPOSE_LABELS: Record<string, string> = {
        visao_simples: 'Visão Simples',
        torica:        'Tórica (Astigmatismo)',
        multifocal:    'Multifocal',
        cosmetica:     'Cosmético / Colorida',
        terapeutica:   'Terapêutico',
    };

    // Estado
    let lente: Record<string, any> | null = null;
    let loading = true;
    let erro: string | null = null;

    // Edição de preços
    let editando      = false;
    let editCost      = 0;
    let editSugerido  = 0;
    let editSalvando  = false;
    let editErro: string | null = null;
    let editSucesso   = false;

    onMount(async () => {
        const { data: row, error: err } = await supabase
            .from('v_contact_lenses')
            .select('*')
            .eq('id', data.id)
            .single();

        if (err || !row) {
            erro = err?.message ?? 'Lente não encontrada';
        } else {
            lente        = row;
            editCost     = row.price_cost      ?? 0;
            editSugerido = row.price_suggested ?? 0;
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
                .rpc('rpc_update_contact_lens_price', {
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
</script>

<svelte:head>
    <title>{lente?.product_name ?? 'Lente de Contato'} | SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-950 pb-24">

    <!-- Back bar -->
    <div class="bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
        <Container maxWidth="xl" padding="sm">
            <div class="py-3">
                <a href="/contato" class="inline-flex items-center gap-2 text-sm font-bold text-neutral-500 hover:text-neutral-900 dark:hover:text-white transition-colors">
                    <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/>
                    </svg>
                    Catálogo de Contato
                </a>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="md">
        <div class="mt-6">

            {#if loading}
                <div class="flex flex-col items-center justify-center py-24 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl">
                    <div class="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p class="text-neutral-500 text-sm">Carregando dados da lente de contato...</p>
                </div>

            {:else if erro || !lente}
                <div class="py-16 text-center bg-white dark:bg-neutral-900 border border-red-200 dark:border-red-900 rounded-2xl">
                    <div class="text-5xl mb-4">👁️</div>
                    <p class="text-red-500 font-semibold">{erro ?? 'Lente não encontrada'}</p>
                    <a href="/contato" class="mt-4 inline-block px-4 py-2 bg-primary-600 text-white text-sm font-bold rounded-lg">
                        ← Voltar ao Catálogo
                    </a>
                </div>

            {:else}
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                    <!-- Coluna principal -->
                    <div class="lg:col-span-2 space-y-4">

                        <!-- Header card -->
                        <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl p-6">
                            <div class="flex items-start justify-between gap-4 mb-4">
                                <div>
                                    <h1 class="text-xl font-black text-neutral-900 dark:text-white leading-tight">
                                        {lente.product_name ?? '—'}
                                    </h1>
                                    <p class="text-sm text-neutral-500 mt-0.5">
                                        {lente.brand_name ?? '—'}{#if lente.manufacturer_name} · {lente.manufacturer_name}{/if}
                                    </p>
                                </div>
                                <div class="flex gap-2 shrink-0">
                                    {#if lente.stock_available > 0}
                                        <span class="px-2 py-1 bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 dark:text-emerald-400 text-xs font-black rounded-full uppercase">Em Stock</span>
                                    {/if}
                                    {#if lente.is_colored}
                                        <span class="px-2 py-1 bg-purple-50 dark:bg-purple-900/20 text-purple-600 dark:text-purple-400 text-xs font-black rounded-full uppercase">Colorida</span>
                                    {/if}
                                </div>
                            </div>

                            <!-- Specs grid -->
                            <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
                                {#if lente.lens_type}
                                    <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Tipo</div>
                                        <div class="text-sm font-semibold text-neutral-900 dark:text-white">{DESCARTE_LABELS[lente.lens_type] ?? lente.lens_type}</div>
                                    </div>
                                {/if}
                                {#if lente.purpose}
                                    <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Finalidade</div>
                                        <div class="text-sm font-semibold text-neutral-900 dark:text-white">{PURPOSE_LABELS[lente.purpose] ?? lente.purpose.replace('_', ' ')}</div>
                                    </div>
                                {/if}
                                {#if lente.material}
                                    <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Material</div>
                                        <div class="text-sm font-semibold text-neutral-900 dark:text-white truncate">{lente.material}</div>
                                    </div>
                                {/if}
                                {#if lente.usage_days}
                                    <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Descarte</div>
                                        <div class="text-sm font-semibold text-neutral-900 dark:text-white">{lente.usage_days} dias</div>
                                    </div>
                                {/if}
                                {#if lente.units_per_box}
                                    <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Unid./Caixa</div>
                                        <div class="text-sm font-semibold text-neutral-900 dark:text-white">{lente.units_per_box} lentes</div>
                                    </div>
                                {/if}
                                {#if lente.stock_available != null}
                                    <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                        <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Estoque</div>
                                        <div class="text-sm font-semibold {lente.stock_available > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-500'}">{lente.stock_available} caixas</div>
                                    </div>
                                {/if}
                            </div>
                        </div>

                        <!-- Parâmetros técnicos -->
                        {#if lente.dk_t || lente.water_content || lente.diameter || lente.base_curve}
                            <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl p-5">
                                <h2 class="text-sm font-black uppercase tracking-wide text-neutral-400 mb-3">Parâmetros Técnicos</h2>
                                <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                                    {#if lente.dk_t}
                                        <div class="text-center bg-neutral-50 dark:bg-neutral-800 rounded-xl p-3">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1">Dk/t</div>
                                            <div class="text-lg font-black text-neutral-900 dark:text-white">{lente.dk_t}</div>
                                        </div>
                                    {/if}
                                    {#if lente.water_content}
                                        <div class="text-center bg-neutral-50 dark:bg-neutral-800 rounded-xl p-3">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1">H₂O</div>
                                            <div class="text-lg font-black text-neutral-900 dark:text-white">{lente.water_content}%</div>
                                        </div>
                                    {/if}
                                    {#if lente.diameter}
                                        <div class="text-center bg-neutral-50 dark:bg-neutral-800 rounded-xl p-3">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1">Diâmetro</div>
                                            <div class="text-lg font-black text-neutral-900 dark:text-white">{lente.diameter} mm</div>
                                        </div>
                                    {/if}
                                    {#if lente.base_curve}
                                        <div class="text-center bg-neutral-50 dark:bg-neutral-800 rounded-xl p-3">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1">Curva Base</div>
                                            <div class="text-lg font-black text-neutral-900 dark:text-white">{lente.base_curve}</div>
                                        </div>
                                    {/if}
                                </div>
                            </div>
                        {/if}

                        <!-- Prescrição + extras -->
                        {#if lente.spherical_min != null || lente.uv_protection || lente.is_colored}
                            <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl p-5">
                                <h2 class="text-sm font-black uppercase tracking-wide text-neutral-400 mb-3">Prescrição & Recursos</h2>
                                {#if lente.spherical_min != null}
                                    <div class="grid grid-cols-2 gap-3 mb-3">
                                        <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Esférico</div>
                                            <div class="text-sm font-semibold text-neutral-900 dark:text-white">{lente.spherical_min} a {lente.spherical_max}</div>
                                        </div>
                                        {#if lente.cylindrical_min != null}
                                            <div class="bg-neutral-50 dark:bg-neutral-800 rounded-xl px-3 py-2.5">
                                                <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-0.5">Cilíndrico</div>
                                                <div class="text-sm font-semibold text-neutral-900 dark:text-white">{lente.cylindrical_min} a {lente.cylindrical_max}</div>
                                            </div>
                                        {/if}
                                    </div>
                                {/if}
                                <div class="flex flex-wrap gap-2">
                                    {#if lente.uv_protection}
                                        <span class="px-3 py-1.5 bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300 text-xs font-bold rounded-lg">Proteção UV</span>
                                    {/if}
                                    {#if lente.is_colored}
                                        <span class="px-3 py-1.5 bg-purple-50 dark:bg-purple-900/20 text-purple-700 dark:text-purple-300 text-xs font-bold rounded-lg">Colorida</span>
                                    {/if}
                                    {#each (lente.available_colors ?? []) as cor}
                                        <span class="px-3 py-1.5 bg-neutral-100 dark:bg-neutral-800 text-neutral-600 dark:text-neutral-400 text-xs font-bold rounded-lg">{cor}</span>
                                    {/each}
                                </div>
                            </div>
                        {/if}
                    </div>

                    <!-- Sidebar preço -->
                    <div class="space-y-4">
                        <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl p-5">
                            <div class="flex items-center justify-between mb-4">
                                <h2 class="text-sm font-black uppercase tracking-wide text-neutral-400">Preço</h2>
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
                                        <label class="text-[10px] font-black uppercase tracking-wider text-neutral-400 block mb-1">Custo (R$)</label>
                                        <input type="number" step="0.01" min="0" bind:value={editCost}
                                            class="w-full px-3 py-2 border border-neutral-300 dark:border-neutral-600 rounded-lg text-sm bg-white dark:bg-neutral-800 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500" />
                                    </div>
                                    <div>
                                        <label class="text-[10px] font-black uppercase tracking-wider text-neutral-400 block mb-1">Preço por Caixa (R$)</label>
                                        <input type="number" step="0.01" min="0" bind:value={editSugerido}
                                            class="w-full px-3 py-2 border border-neutral-300 dark:border-neutral-600 rounded-lg text-sm bg-white dark:bg-neutral-800 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500" />
                                    </div>
                                    {#if editCost > 0 && editSugerido > 0}
                                        <div class="text-xs text-neutral-400 text-right">
                                            Markup: <span class="font-bold text-emerald-600 dark:text-emerald-400">
                                                {(editSugerido / editCost).toFixed(2)}x
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
                                            class="px-3 py-2 bg-neutral-100 dark:bg-neutral-800 hover:bg-neutral-200 dark:hover:bg-neutral-700 text-neutral-600 dark:text-neutral-400 text-xs font-bold rounded-lg transition-colors">
                                            Cancelar
                                        </button>
                                    </div>
                                </div>
                            {:else}
                                <!-- Modo leitura -->
                                <div class="space-y-4">
                                    {#if lente.price_suggested}
                                        <div>
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400">Por Caixa</div>
                                            <div class="text-3xl font-black text-neutral-900 dark:text-white mt-0.5">{fmt(lente.price_suggested)}</div>
                                            {#if lente.units_per_box}
                                                <div class="text-xs text-neutral-400 mt-0.5">{lente.units_per_box} lentes por caixa</div>
                                            {/if}
                                        </div>
                                    {/if}
                                    {#if lente.price_cost && lente.price_cost > 0}
                                        <div class="pt-3 border-t border-neutral-100 dark:border-neutral-800">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400">Custo</div>
                                            <div class="text-xl font-bold text-neutral-500 dark:text-neutral-400 mt-0.5">{fmt(lente.price_cost)}</div>
                                        </div>
                                    {/if}
                                    {#if lente.lead_time_days}
                                        <div class="pt-3 border-t border-neutral-100 dark:border-neutral-800">
                                            <div class="text-[10px] font-black uppercase tracking-wider text-neutral-400">Prazo de Entrega</div>
                                            <div class="text-sm font-bold text-neutral-700 dark:text-neutral-300 mt-0.5">{lente.lead_time_days} dias</div>
                                        </div>
                                    {/if}
                                </div>
                            {/if}
                        </div>

                        <a href="/contato"
                            class="block w-full text-center px-4 py-3 bg-neutral-100 dark:bg-neutral-800 hover:bg-neutral-200 dark:hover:bg-neutral-700 text-neutral-700 dark:text-neutral-300 text-sm font-bold rounded-xl transition-colors">
                            ← Voltar ao Catálogo
                        </a>
                    </div>
                </div>
            {/if}
        </div>
    </Container>
</main>
