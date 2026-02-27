<script lang="ts">
    /**
     * Premium Collection — client-side via browser supabase
     * Fonte: public.v_canonical_lenses_premium_pricing (migration 277)
     * Padrão visual unificado com /lentes e /standard
     */
    import { onMount }       from 'svelte';
    import { afterNavigate } from '$app/navigation';
    import { goto }          from '$app/navigation';
    import type { PageData } from './$types';
    import { supabase }      from '$lib/supabase';
    import Container         from '$lib/components/layout/Container.svelte';

    export let data: PageData;

    const LIMITE = 24;

    interface CanonicalLens {
        id: string;
        sku: string | null;
        canonical_name: string | null;
        lens_type: string | null;
        material_class: string | null;
        refractive_index: number | null;
        material_display: string | null;
        treatment_codes: string[] | null;
        mapped_lens_count: number | null;
        mapped_supplier_count: number | null;
        mapped_brand_count: number | null;
        price_min: number | null;
        price_max: number | null;
        price_avg: number | null;
    }

    // ── Estado ──────────────────────────────────────────────────────────────────
    let canonicais: CanonicalLens[] = [];
    let total         = 0;
    let total_paginas = 0;
    let loading       = true;
    let erro: string | null = null;

    // Opções de filtro
    let tiposLente: string[] = [];
    let classes: string[]    = [];
    let opcoesCarregadas     = false;

    // Form (espelha URL)
    let busca          = '';
    let lens_type      = '';
    let material_class = '';
    let has_ar    = data.has_ar    ?? false;
    let has_uv    = data.has_uv    ?? false;
    let has_blue  = data.has_blue  ?? false;
    let has_photo = data.has_photo ?? false;
    let filtrosAbertos = false;

    // ── Fetch principal ──────────────────────────────────────────────────────────
    async function fetchCanonicais() {
        loading = true;
        erro    = null;

        busca          = data.busca          ?? '';
        lens_type      = data.lens_type      ?? '';
        material_class = data.material_class ?? '';
        has_ar    = data.has_ar    ?? false;
        has_uv    = data.has_uv    ?? false;
        has_blue  = data.has_blue  ?? false;
        has_photo = data.has_photo ?? false;

        const offset = (data.pagina - 1) * LIMITE;

        let query = supabase
            .from('v_canonical_lenses_premium_pricing')
            .select(
                'id,sku,canonical_name,lens_type,material_class,refractive_index,material_display,treatment_codes,mapped_lens_count,mapped_supplier_count,mapped_brand_count,price_min,price_max,price_avg',
                { count: 'exact' }
            );

        if (busca)          query = query.ilike('canonical_name', `%${busca}%`);
        if (lens_type)      query = query.eq('lens_type', lens_type);
        if (material_class) query = query.eq('material_class', material_class);
        if (data.has_ar)    query = query.contains('treatment_codes', ['ar']);
        if (data.has_uv)    query = query.contains('treatment_codes', ['uv']);
        if (data.has_blue)  query = query.contains('treatment_codes', ['blue']);
        if (data.has_photo) query = query.contains('treatment_codes', ['photo']);

        const { data: rows, count, error: err } = await query
            .order('canonical_name', { ascending: true })
            .range(offset, offset + LIMITE - 1);

        if (err) {
            erro       = err.message;
            canonicais = [];
        } else {
            canonicais    = (rows ?? []) as CanonicalLens[];
            total         = count ?? 0;
            total_paginas = Math.ceil(total / LIMITE);
        }
        loading = false;
    }

    // ── Fetch opções de filtro ───────────────────────────────────────────────────
    async function fetchOpcoes() {
        if (opcoesCarregadas) return;
        const { data: rows } = await supabase
            .from('v_canonical_lenses_premium_pricing')
            .select('lens_type, material_class')
            .limit(500);
        const ts = new Set<string>();
        const cs = new Set<string>();
        for (const r of rows ?? []) {
            if (r.lens_type)      ts.add(r.lens_type);
            if (r.material_class) cs.add(r.material_class);
        }
        tiposLente = [...ts].sort();
        classes    = [...cs].sort();
        opcoesCarregadas = true;
    }

    // ── Navegação ────────────────────────────────────────────────────────────────
    function aplicarFiltros() {
        const p = new URLSearchParams();
        if (busca)          p.set('busca',    busca);
        if (lens_type)      p.set('tipo',     lens_type);
        if (material_class) p.set('material', material_class);
        if (has_ar)         p.set('ar',   '1');
        if (has_uv)         p.set('uv',   '1');
        if (has_blue)       p.set('blue', '1');
        if (has_photo)      p.set('foto', '1');
        goto(`/premium?${p.toString()}`);
    }

    function limparFiltros() {
        busca = '';
        lens_type = '';
        material_class = '';
        has_ar = false; has_uv = false; has_blue = false; has_photo = false;
        goto('/premium');
    }

    function irParaPagina(p: number) {
        const params = new URLSearchParams();
        if (busca)          params.set('busca',    busca);
        if (lens_type)      params.set('tipo',     lens_type);
        if (material_class) params.set('material', material_class);
        if (has_ar)         params.set('ar',   '1');
        if (has_uv)         params.set('uv',   '1');
        if (has_blue)       params.set('blue', '1');
        if (has_photo)      params.set('foto', '1');
        params.set('pagina', String(p));
        goto(`/premium?${params.toString()}`);
    }

    // ── Ciclo de vida ────────────────────────────────────────────────────────────
    onMount(() => { fetchOpcoes(); });
    afterNavigate(() => { fetchCanonicais(); });

    // ── Helpers ──────────────────────────────────────────────────────────────────
    const TIPO_LABELS: Record<string, string> = {
        single_vision: 'Visão Simples',
        multifocal:    'Multifocal',
        bifocal:       'Bifocal',
        occupational:  'Ocupacional',
    };

    function fmt(v: number | null): string {
        if (v == null) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v);
    }

    $: filtrosAtivos = [data.busca, data.lens_type, data.material_class,
        data.has_ar ? '1' : '', data.has_uv ? '1' : '',
        data.has_blue ? '1' : '', data.has_photo ? '1' : '']
        .filter(Boolean).length;
</script>

<svelte:head>
    <title>Premium ({total.toLocaleString('pt-BR')}) | SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-950 pb-24">

    <!-- ── Hero ─────────────────────────────────────────────────────────────── -->
    <div class="bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
        <Container maxWidth="xl" padding="sm">
            <div class="py-6">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                    <div>
                        <div class="flex items-center gap-2 mb-1">
                            <span class="px-2 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 text-xs font-black rounded-full uppercase tracking-wide">★ Elite</span>
                        </div>
                        <h1 class="text-2xl font-black text-neutral-900 dark:text-white">Premium Collection</h1>
                        <p class="text-sm text-neutral-500 mt-1">
                            {#if loading}Carregando...{:else}{total.toLocaleString('pt-BR')} conceitos · alta tecnologia e marcas exclusivas{/if}
                        </p>
                    </div>
                    <div class="flex gap-2">
                        <a href="/lentes" class="px-3 py-1.5 bg-neutral-100 dark:bg-neutral-800 text-neutral-600 dark:text-neutral-400 text-xs font-bold rounded-lg hover:bg-neutral-200 dark:hover:bg-neutral-700 transition-colors">← Catálogo</a>
                        <a href="/standard" class="px-3 py-1.5 bg-sky-50 dark:bg-sky-900/20 text-sky-600 dark:text-sky-400 text-xs font-bold rounded-lg hover:bg-sky-100 dark:hover:bg-sky-900/30 transition-colors">↗ Standard</a>
                    </div>
                </div>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="md">

        <!-- ── Filtros ───────────────────────────────────────────────────────── -->
        <div class="mt-6 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl overflow-hidden">
            <button
                class="w-full flex items-center justify-between px-5 py-4 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors text-left"
                on:click={() => (filtrosAbertos = !filtrosAbertos)}
                type="button"
            >
                <div class="flex items-center gap-3">
                    <svg class="w-4 h-4 text-neutral-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"/>
                    </svg>
                    <span class="text-sm font-bold text-neutral-700 dark:text-neutral-300">Filtros</span>
                    {#if filtrosAtivos > 0}
                        <span class="px-2 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 text-xs font-black rounded-full">
                            {filtrosAtivos} {filtrosAtivos === 1 ? 'ativo' : 'ativos'}
                        </span>
                    {/if}
                </div>
                <svg class="w-4 h-4 text-neutral-400 transition-transform duration-200 {filtrosAbertos ? 'rotate-180' : ''}"
                    fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
                </svg>
            </button>

            {#if filtrosAbertos}
                <div class="border-t border-neutral-100 dark:border-neutral-800 px-5 py-5">
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Buscar por nome</label>
                            <input type="text" bind:value={busca}
                                placeholder="Ex: progressiva alta tecnologia..."
                                on:keydown={(e) => e.key === 'Enter' && aplicarFiltros()}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-amber-400"/>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Tipo</label>
                            <select bind:value={lens_type}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-amber-400 cursor-pointer">
                                <option value="">Todos os tipos</option>
                                {#each tiposLente as t}
                                    <option value={t}>{TIPO_LABELS[t] ?? t}</option>
                                {/each}
                            </select>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Material</label>
                            <select bind:value={material_class}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-amber-400 cursor-pointer">
                                <option value="">Todos os materiais</option>
                                {#each classes as c}
                                    <option value={c}>{c}</option>
                                {/each}
                            </select>
                        </div>
                    </div>
                    <div class="mt-4 flex flex-wrap items-center gap-6">
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-2">Tratamentos</label>
                            <div class="flex flex-wrap gap-x-5 gap-y-2">
                                <label class="flex items-center gap-1.5 cursor-pointer">
                                    <input type="checkbox" bind:checked={has_ar}    class="w-3.5 h-3.5 rounded accent-primary-600"/>
                                    <span class="text-sm text-neutral-700 dark:text-neutral-300">Anti-Reflexo</span>
                                </label>
                                <label class="flex items-center gap-1.5 cursor-pointer">
                                    <input type="checkbox" bind:checked={has_uv}    class="w-3.5 h-3.5 rounded accent-primary-600"/>
                                    <span class="text-sm text-neutral-700 dark:text-neutral-300">UV</span>
                                </label>
                                <label class="flex items-center gap-1.5 cursor-pointer">
                                    <input type="checkbox" bind:checked={has_blue}  class="w-3.5 h-3.5 rounded accent-primary-600"/>
                                    <span class="text-sm text-neutral-700 dark:text-neutral-300">Blue Cut</span>
                                </label>
                                <label class="flex items-center gap-1.5 cursor-pointer">
                                    <input type="checkbox" bind:checked={has_photo} class="w-3.5 h-3.5 rounded accent-primary-600"/>
                                    <span class="text-sm text-neutral-700 dark:text-neutral-300">Fotossensível</span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="flex items-center gap-3 mt-5 pt-4 border-t border-neutral-100 dark:border-neutral-800">
                        <button type="button" on:click={aplicarFiltros}
                            class="px-5 py-2 bg-amber-600 hover:bg-amber-700 text-white text-sm font-bold rounded-lg transition-colors">
                            Aplicar Filtros
                        </button>
                        {#if filtrosAtivos > 0}
                            <button type="button" on:click={limparFiltros}
                                class="px-4 py-2 text-sm text-neutral-500 hover:text-neutral-700 dark:hover:text-neutral-300 transition-colors">
                                Limpar tudo
                            </button>
                        {/if}
                        <span class="text-xs text-neutral-400 ml-auto">
                            {#if !loading}{total.toLocaleString('pt-BR')} resultado{total !== 1 ? 's' : ''}{/if}
                        </span>
                    </div>
                </div>
            {/if}
        </div>

        <!-- ── Grid de Cards ─────────────────────────────────────────────────── -->
        <div class="mt-6">
            {#if loading}
                <div class="flex flex-col items-center justify-center py-24 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl">
                    <div class="w-8 h-8 border-4 border-amber-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p class="text-neutral-500 dark:text-neutral-400 text-sm">Carregando coleção premium...</p>
                </div>

            {:else if erro}
                <div class="py-16 text-center bg-white dark:bg-neutral-900 border border-red-200 dark:border-red-900 rounded-2xl">
                    <p class="text-red-500 font-semibold">{erro}</p>
                    <button type="button" on:click={fetchCanonicais}
                        class="mt-4 px-4 py-2 bg-amber-600 text-white text-sm font-bold rounded-lg">
                        Tentar novamente
                    </button>
                </div>

            {:else if canonicais.length === 0}
                <div class="py-24 text-center">
                    <div class="text-5xl mb-4">👑</div>
                    <p class="text-neutral-500 dark:text-neutral-400 text-lg font-semibold">Nenhum conceito premium encontrado</p>
                    <p class="text-neutral-400 dark:text-neutral-500 text-sm mt-1">Tente ajustar os filtros</p>
                    {#if filtrosAtivos > 0}
                        <button type="button" on:click={limparFiltros}
                            class="mt-5 px-4 py-2 text-sm text-amber-600 dark:text-amber-400 hover:text-amber-700 font-semibold transition-colors">
                            ← Limpar filtros
                        </button>
                    {/if}
                </div>

            {:else}
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {#each canonicais as c (c.id)}
                        <a href="/premium/{c.id}"
                            class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl p-5 hover:shadow-md hover:border-amber-200 dark:hover:border-amber-800 transition-all duration-200 flex flex-col gap-3 no-underline">

                            <!-- Nome + badge PRE -->
                            <div class="flex items-start justify-between gap-2">
                                <div class="flex-1 min-w-0">
                                    <h3 class="font-bold text-neutral-900 dark:text-white text-sm leading-snug line-clamp-2">
                                        {c.canonical_name ?? '—'}
                                    </h3>
                                    {#if c.sku}
                                        <p class="font-mono text-[11px] text-neutral-400 dark:text-neutral-500 mt-0.5">{c.sku}</p>
                                    {/if}
                                </div>
                                <span class="shrink-0 px-1.5 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 text-[9px] font-black rounded-full uppercase tracking-wide">★ PRE</span>
                            </div>

                            <!-- Specs (label-value rows) -->
                            <div class="space-y-1.5 flex-1">
                                {#if c.lens_type}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-neutral-300 dark:text-neutral-600 w-14 shrink-0">Tipo</span>
                                        <span class="text-xs text-neutral-600 dark:text-neutral-400">{TIPO_LABELS[c.lens_type] ?? c.lens_type}</span>
                                    </div>
                                {/if}
                                {#if c.material_display || c.material_class}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-neutral-300 dark:text-neutral-600 w-14 shrink-0">Material</span>
                                        <span class="text-xs text-neutral-600 dark:text-neutral-400 leading-tight">
                                            {c.material_display ?? c.material_class}{#if c.refractive_index} · <span class="text-neutral-400 dark:text-neutral-500">n={c.refractive_index}</span>{/if}
                                        </span>
                                    </div>
                                {/if}
                                {#if c.mapped_lens_count}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-neutral-300 dark:text-neutral-600 w-14 shrink-0">Opções</span>
                                        <span class="text-xs text-neutral-600 dark:text-neutral-400">{c.mapped_lens_count} lentes · {c.mapped_supplier_count ?? 0} forn.</span>
                                    </div>
                                {/if}
                            </div>

                            <!-- Treatment chips -->
                            <div class="flex flex-wrap gap-1 min-h-[18px]">
                                {#each (c.treatment_codes ?? []) as t}
                                    <span class="px-1.5 py-0.5 bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-400 text-[9px] font-black rounded uppercase">{t}</span>
                                {/each}
                            </div>

                            <!-- Footer preço -->
                            <div class="flex items-center justify-between pt-3 border-t border-neutral-100 dark:border-neutral-800">
                                <span class="text-[10px] font-black uppercase tracking-wide text-neutral-400">
                                    {c.price_avg != null ? 'Média' : 'Preço'}
                                </span>
                                <span class="text-base font-black text-neutral-900 dark:text-white">
                                    {#if c.price_avg != null}
                                        {fmt(c.price_avg)}
                                    {:else}
                                        Sob Consulta
                                    {/if}
                                </span>
                            </div>
                        </a>
                    {/each}
                </div>

                <!-- ── Paginação ──────────────────────────────────────────────── -->
                {#if total_paginas > 1}
                    <div class="flex flex-col items-center gap-3 mt-10">
                        <div class="flex items-center gap-2">
                            <button type="button" disabled={data.pagina <= 1}
                                on:click={() => irParaPagina(data.pagina - 1)}
                                class="px-4 py-2 text-sm font-bold rounded-lg border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-900 text-neutral-700 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
                                ← Anterior
                            </button>
                            <div class="flex items-center gap-1">
                                {#each Array.from({ length: total_paginas }, (_, i) => i + 1) as p}
                                    {#if p === 1 || p === total_paginas || (p >= data.pagina - 2 && p <= data.pagina + 2)}
                                        <button type="button" on:click={() => irParaPagina(p)}
                                            class="w-9 h-9 text-sm font-bold rounded-lg transition-colors {p === data.pagina ? 'bg-amber-600 text-white shadow-sm' : 'bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800'}">
                                            {p}
                                        </button>
                                    {:else if p === data.pagina - 3 || p === data.pagina + 3}
                                        <span class="text-neutral-400 text-sm px-1">…</span>
                                    {/if}
                                {/each}
                            </div>
                            <button type="button" disabled={data.pagina >= total_paginas}
                                on:click={() => irParaPagina(data.pagina + 1)}
                                class="px-4 py-2 text-sm font-bold rounded-lg border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-900 text-neutral-700 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
                                Próxima →
                            </button>
                        </div>
                        <p class="text-xs text-neutral-400">
                            Página {data.pagina} de {total_paginas} · {total.toLocaleString('pt-BR')} conceitos
                        </p>
                    </div>
                {/if}
            {/if}
        </div>

    </Container>
</main>
