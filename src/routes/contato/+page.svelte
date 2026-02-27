<script lang="ts">
    /**
     * Catálogo de Lentes de Contato — client-side via browser supabase
     * Fonte: public.v_contact_lenses (migration 281 — COALESCE fix)
     * Padrão visual unificado com /lentes, /standard e /premium
     */
    import { onMount }       from 'svelte';
    import { afterNavigate } from '$app/navigation';
    import { goto }          from '$app/navigation';
    import type { PageData } from './$types';
    import { supabase }      from '$lib/supabase';
    import Container         from '$lib/components/layout/Container.svelte';
    import ContactLensCard   from '$lib/components/catalogo/ContactLensCard.svelte';

    export let data: PageData;

    const LIMITE = 24;

    interface ContactLens {
        id: string;
        brand_name: string | null;
        manufacturer_name: string | null;
        product_name: string | null;
        lens_type: string | null;
        purpose: string | null;
        material: string | null;
        is_colored: boolean | null;
        usage_days: number | null;
        units_per_box: number | null;
        dk_t: number | null;
        price_suggested: number | null;
        stock_available: number | null;
        uv_protection: boolean | null;
    }

    // ── Estado ──────────────────────────────────────────────────────────────────
    let lentes: ContactLens[] = [];
    let total         = 0;
    let total_paginas = 0;
    let loading       = true;
    let erro: string | null = null;

    // Opções de filtro
    let tiposLente: string[]  = [];
    let finalidades: string[] = [];
    let materiais: string[]   = [];
    let opcoesCarregadas      = false;

    // Form (espelha URL)
    let busca     = '';
    let lens_type = '';
    let purpose   = '';
    let material  = '';
    let filtrosAbertos = false;

    // ── Labels ───────────────────────────────────────────────────────────────────
    const DESCARTE_LABELS: Record<string, string> = {
        diaria:     'Descarte Diário',
        quinzenal:  'Quinzenal',
        mensal:     'Mensal',
        trimestral: 'Trimestral',
        anual:      'Uso Anual',
    };
    const PURPOSE_LABELS: Record<string, string> = {
        vision_correction: 'Correção Visual',
        cosmetic:          'Cosmético',
        therapeutic:       'Terapêutico',
        orthokeratology:   'Ortoceratologia',
    };

    // ── Fetch principal ──────────────────────────────────────────────────────────
    async function fetchContato() {
        loading = true;
        erro    = null;

        busca     = data.busca     ?? '';
        lens_type = data.lens_type ?? '';
        purpose   = data.purpose   ?? '';
        material  = data.material  ?? '';

        const offset = (data.pagina - 1) * LIMITE;

        let query = supabase
            .from('v_contact_lenses')
            .select(
                'id,brand_name,manufacturer_name,product_name,lens_type,purpose,material,is_colored,usage_days,units_per_box,dk_t,price_suggested,stock_available,uv_protection',
                { count: 'exact' }
            )
            .eq('status', 'active');

        if (busca)     query = query.or(`product_name.ilike.%${busca}%,brand_name.ilike.%${busca}%`);
        if (lens_type) query = query.eq('lens_type', lens_type);
        if (purpose)   query = query.eq('purpose', purpose);
        if (material)  query = query.eq('material', material);

        const { data: rows, count, error: err } = await query
            .order('brand_name',   { ascending: true, nullsFirst: false })
            .order('product_name', { ascending: true })
            .range(offset, offset + LIMITE - 1);

        if (err) {
            erro   = err.message;
            lentes = [];
        } else {
            lentes        = (rows ?? []) as ContactLens[];
            total         = count ?? 0;
            total_paginas = Math.ceil(total / LIMITE);
        }
        loading = false;
    }

    // ── Fetch opções ─────────────────────────────────────────────────────────────
    async function fetchOpcoes() {
        if (opcoesCarregadas) return;
        const { data: rows } = await supabase
            .from('v_contact_lenses')
            .select('lens_type, purpose, material')
            .eq('status', 'active')
            .limit(500);
        const ts = new Set<string>();
        const ps = new Set<string>();
        const ms = new Set<string>();
        for (const r of rows ?? []) {
            if (r.lens_type) ts.add(r.lens_type);
            if (r.purpose)   ps.add(r.purpose);
            if (r.material)  ms.add(r.material);
        }
        tiposLente  = [...ts].sort();
        finalidades = [...ps].sort();
        materiais   = [...ms].sort();
        opcoesCarregadas = true;
    }

    // ── Navegação ────────────────────────────────────────────────────────────────
    function aplicarFiltros() {
        const p = new URLSearchParams();
        if (busca)     p.set('busca',    busca);
        if (lens_type) p.set('tipo',     lens_type);
        if (purpose)   p.set('uso',      purpose);
        if (material)  p.set('material', material);
        goto(`/contato?${p.toString()}`);
    }

    function limparFiltros() {
        busca = ''; lens_type = ''; purpose = ''; material = '';
        goto('/contato');
    }

    function irParaPagina(p: number) {
        const params = new URLSearchParams();
        if (busca)     params.set('busca',    busca);
        if (lens_type) params.set('tipo',     lens_type);
        if (purpose)   params.set('uso',      purpose);
        if (material)  params.set('material', material);
        params.set('pagina', String(p));
        goto(`/contato?${params.toString()}`);
    }

    // ── Ciclo de vida ────────────────────────────────────────────────────────────
    onMount(() => { fetchOpcoes(); });
    afterNavigate(() => { fetchContato(); });

    $: filtrosAtivos = [data.busca, data.lens_type, data.purpose, data.material].filter(Boolean).length;
</script>

<svelte:head>
    <title>Contato ({total.toLocaleString('pt-BR')}) | SIS Lens</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-950 pb-24">

    <!-- ── Hero ─────────────────────────────────────────────────────────────── -->
    <div class="bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
        <Container maxWidth="xl" padding="sm">
            <div class="py-6">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                    <div>
                        <div class="flex items-center gap-2 mb-1">
                            <span class="px-2 py-0.5 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-400 text-xs font-black rounded-full uppercase tracking-wide">👁️ Contato & Estética</span>
                        </div>
                        <h1 class="text-2xl font-black text-neutral-900 dark:text-white">Lentes de Contato</h1>
                        <p class="text-sm text-neutral-500 mt-1">
                            {#if loading}Carregando...{:else}{total.toLocaleString('pt-BR')} produtos · descarte diário, mensal e coloridas{/if}
                        </p>
                    </div>
                    <a href="/lentes" class="px-3 py-1.5 bg-neutral-100 dark:bg-neutral-800 text-neutral-600 dark:text-neutral-400 text-xs font-bold rounded-lg hover:bg-neutral-200 dark:hover:bg-neutral-700 transition-colors">← Catálogo Ótico</a>
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
                        <span class="px-2 py-0.5 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 text-xs font-black rounded-full">
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
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Buscar</label>
                            <input type="text" bind:value={busca}
                                placeholder="Marca ou nome..."
                                on:keydown={(e) => e.key === 'Enter' && aplicarFiltros()}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400"/>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Descarte</label>
                            <select bind:value={lens_type}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400 cursor-pointer">
                                <option value="">Todos</option>
                                {#each tiposLente as t}
                                    <option value={t}>{DESCARTE_LABELS[t] ?? t}</option>
                                {/each}
                            </select>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Finalidade</label>
                            <select bind:value={purpose}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400 cursor-pointer">
                                <option value="">Todas</option>
                                {#each finalidades as p}
                                    <option value={p}>{PURPOSE_LABELS[p] ?? p.replace('_', ' ')}</option>
                                {/each}
                            </select>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Material</label>
                            <select bind:value={material}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400 cursor-pointer">
                                <option value="">Todos</option>
                                {#each materiais as m}
                                    <option value={m}>{m}</option>
                                {/each}
                            </select>
                        </div>
                    </div>
                    <div class="flex items-center gap-3 mt-5 pt-4 border-t border-neutral-100 dark:border-neutral-800">
                        <button type="button" on:click={aplicarFiltros}
                            class="px-5 py-2 bg-primary-600 hover:bg-primary-700 text-white text-sm font-bold rounded-lg transition-colors">
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

        <!-- ── Grid ──────────────────────────────────────────────────────────── -->
        <div class="mt-6">
            {#if loading}
                <div class="flex flex-col items-center justify-center py-24 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl">
                    <div class="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p class="text-neutral-500 dark:text-neutral-400 text-sm">Buscando lentes de contato...</p>
                </div>

            {:else if erro}
                <div class="py-16 text-center bg-white dark:bg-neutral-900 border border-red-200 dark:border-red-900 rounded-2xl">
                    <p class="text-red-500 font-semibold">{erro}</p>
                    <button type="button" on:click={fetchContato}
                        class="mt-4 px-4 py-2 bg-primary-600 text-white text-sm font-bold rounded-lg">
                        Tentar novamente
                    </button>
                </div>

            {:else if lentes.length === 0}
                <div class="py-24 text-center">
                    <div class="text-5xl mb-4">👁️‍🗨️</div>
                    <p class="text-neutral-500 dark:text-neutral-400 text-lg font-semibold">Nenhuma lente encontrada</p>
                    <p class="text-neutral-400 dark:text-neutral-500 text-sm mt-1">Tente ajustar os filtros</p>
                    {#if filtrosAtivos > 0}
                        <button type="button" on:click={limparFiltros}
                            class="mt-5 px-4 py-2 text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 font-semibold transition-colors">
                            ← Limpar filtros
                        </button>
                    {/if}
                </div>

            {:else}
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {#each lentes as lente (lente.id)}
                        <ContactLensCard {lente} />
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
                                            class="w-9 h-9 text-sm font-bold rounded-lg transition-colors {p === data.pagina ? 'bg-primary-600 text-white shadow-sm' : 'bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800'}">
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
                            Página {data.pagina} de {total_paginas} · {total.toLocaleString('pt-BR')} produtos
                        </p>
                    </div>
                {/if}
            {/if}
        </div>

    </Container>
</main>
