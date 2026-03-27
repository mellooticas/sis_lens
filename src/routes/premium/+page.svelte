<script lang="ts">
    /**
     * Premium Collection v3 — Filtros por Marca
     * Fonte: catalog_lenses.rpc_premium_filter_options + rpc_premium_search
     * Marca é o filtro principal. Linha, coating e fotossensível em cascata.
     */
    import { onMount }       from 'svelte';
    import { afterNavigate } from '$app/navigation';
    import { goto }          from '$app/navigation';
    import type { PageData } from './$types';
    import { LensOracleAPI } from '$lib/api/lens-oracle';
    import Container         from '$lib/components/layout/Container.svelte';
    import type { PremiumFilterOptions, CanonicalPremiumV3 } from '$lib/types/database-views';

    export let data: PageData;

    const LIMITE = 24;

    // ── Estado ──────────────────────────────────────────────────────────────────
    let items: CanonicalPremiumV3[] = [];
    let total         = 0;
    let total_paginas = 0;
    let loading       = true;
    let loadingFilters = true;
    let erro: string | null = null;

    // Opções dinâmicas (vêm da RPC em cascata)
    let filterOptions: PremiumFilterOptions | null = null;

    // Form (espelha URL)
    let brand        = data.brand        ?? '';
    let product_line = data.product_line ?? '';
    let lens_type    = data.lens_type    ?? '';
    let coating      = data.coating      ?? '';
    let photochromic = data.photochromic ?? '';
    let material_id  = data.material_id  ?? '';

    // ── Fetch filtros (cascata) ──────────────────────────────────────────────────
    async function fetchFilterOptions() {
        loadingFilters = true;
        const res = await LensOracleAPI.getPremiumFilterOptions({
            brand:        brand || undefined,
            product_line: product_line || undefined,
            lens_type:    lens_type || undefined,
            material_id:  material_id || undefined,
            coating:      coating || undefined,
            photochromic: photochromic || undefined,
        });
        if (res.data) filterOptions = res.data;
        loadingFilters = false;
    }

    // ── Fetch resultados ─────────────────────────────────────────────────────────
    async function fetchResults() {
        loading = true;
        erro = null;

        brand        = data.brand        ?? '';
        product_line = data.product_line ?? '';
        lens_type    = data.lens_type    ?? '';
        coating      = data.coating      ?? '';
        photochromic = data.photochromic ?? '';
        material_id  = data.material_id  ?? '';

        const offset = (data.pagina - 1) * LIMITE;

        const res = await LensOracleAPI.searchPremium({
            brand:        brand || undefined,
            product_line: product_line || undefined,
            lens_type:    lens_type || undefined,
            material_id:  material_id || undefined,
            coating:      coating || undefined,
            photochromic: photochromic || undefined,
            limit: LIMITE,
            offset,
        });

        if (res.error) {
            erro = res.error.message;
            items = [];
        } else if (res.data) {
            items         = res.data.items ?? [];
            total         = res.data.total ?? 0;
            total_paginas = Math.ceil(total / LIMITE);
        }
        loading = false;
    }

    // ── Navegação ────────────────────────────────────────────────────────────────
    function aplicarFiltros() {
        const p = new URLSearchParams();
        if (brand)        p.set('marca',    brand);
        if (product_line) p.set('linha',    product_line);
        if (lens_type)    p.set('tipo',     lens_type);
        if (coating)      p.set('coating',  coating);
        if (photochromic) p.set('foto',     photochromic);
        if (material_id)  p.set('material', material_id);
        goto(`/premium?${p.toString()}`);
    }

    function selecionarMarca(m: string) {
        brand = brand === m ? '' : m;
        product_line = '';
        coating = '';
        photochromic = '';
        aplicarFiltros();
    }

    function limparFiltros() {
        brand = ''; product_line = ''; lens_type = '';
        coating = ''; photochromic = ''; material_id = '';
        goto('/premium');
    }

    function irParaPagina(p: number) {
        const params = new URLSearchParams();
        if (brand)        params.set('marca',    brand);
        if (product_line) params.set('linha',    product_line);
        if (lens_type)    params.set('tipo',     lens_type);
        if (coating)      params.set('coating',  coating);
        if (photochromic) params.set('foto',     photochromic);
        if (material_id)  params.set('material', material_id);
        params.set('pagina', String(p));
        goto(`/premium?${params.toString()}`);
    }

    // ── Ciclo de vida ────────────────────────────────────────────────────────────
    afterNavigate(() => {
        fetchFilterOptions();
        fetchResults();
    });

    // ── Helpers ──────────────────────────────────────────────────────────────────
    const TIPO_LABELS: Record<string, string> = {
        single_vision: 'Visão Simples',
        multifocal:    'Multifocal',
        bifocal:       'Bifocal',
        occupational:  'Ocupacional',
    };

    const COATING_SHORT: Record<string, string> = {
        'Crizal Sapphire HR': 'Sapphire HR',
        'Crizal Easy Pro': 'Easy Pro',
        'Crizal Prevencia': 'Prevencia',
        'Crizal Rock': 'Rock',
    };

    function fmt(v: number | null): string {
        if (v == null) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v);
    }

    $: filtrosAtivos = [brand, product_line, lens_type, coating, photochromic, material_id].filter(Boolean).length;
</script>

<svelte:head>
    <title>Premium ({total.toLocaleString('pt-BR')}) | Clearix Lens</title>
</svelte:head>

<main class="min-h-screen bg-muted pb-24">

    <!-- ── Hero ─────────────────────────────────────────────────────────────── -->
    <div class="bg-background border-b border-border">
        <Container maxWidth="xl" padding="sm">
            <div class="py-6">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                    <div>
                        <div class="flex items-center gap-2 mb-1">
                            <span class="px-2 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 text-xs font-black rounded-full uppercase tracking-wide">Premium</span>
                        </div>
                        <h1 class="text-2xl font-black text-foreground">Premium Collection</h1>
                        <p class="text-sm text-muted-foreground mt-1">
                            {#if loading}Carregando...{:else}{total.toLocaleString('pt-BR')} conceitos · marcas consagradas do mercado{/if}
                        </p>
                    </div>
                    <div class="flex gap-2">
                        <a href="/lentes" class="px-3 py-1.5 bg-muted text-muted-foreground text-xs font-bold rounded-lg hover:bg-accent transition-colors">Catalogo</a>
                        <a href="/standard" class="px-3 py-1.5 bg-sky-50 dark:bg-sky-900/20 text-sky-600 dark:text-sky-400 text-xs font-bold rounded-lg hover:bg-sky-100 dark:hover:bg-sky-900/30 transition-colors">Standard</a>
                    </div>
                </div>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="md">

        <!-- ── Marcas (pills principais) ───────────────────────────────────── -->
        <div class="mt-6 bg-card border border-border rounded-2xl p-5">
            <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-3">Marca</label>
            <div class="flex flex-wrap gap-2">
                {#if filterOptions?.brands}
                    {#each filterOptions.brands as b}
                        <button type="button"
                            on:click={() => selecionarMarca(b.value)}
                            class="px-4 py-2 text-sm font-bold rounded-xl border-2 transition-all duration-150
                                {brand === b.value
                                    ? 'bg-amber-600 border-amber-600 text-white shadow-md'
                                    : 'bg-card border-border text-foreground hover:border-amber-300 hover:bg-amber-50 dark:hover:bg-amber-900/20'}">
                            {b.value}
                            <span class="ml-1.5 text-xs opacity-70">({b.count})</span>
                        </button>
                    {/each}
                {:else}
                    <div class="flex gap-2">
                        {#each Array(4) as _}
                            <div class="h-10 w-28 bg-muted rounded-xl animate-pulse"></div>
                        {/each}
                    </div>
                {/if}
            </div>

            <!-- ── Filtros secundários (cascata) ───────────────────────────── -->
            <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3 mt-5 pt-4 border-t border-border">
                <!-- Linha de produto -->
                <div>
                    <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1.5">Linha</label>
                    <select bind:value={product_line} on:change={aplicarFiltros}
                        class="w-full text-sm bg-muted border border-border rounded-lg px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-amber-400 cursor-pointer">
                        <option value="">Todas</option>
                        {#each (filterOptions?.product_lines ?? []) as pl}
                            <option value={pl.value}>{pl.value} ({pl.count})</option>
                        {/each}
                    </select>
                </div>

                <!-- Coating -->
                <div>
                    <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1.5">Coating</label>
                    <select bind:value={coating} on:change={aplicarFiltros}
                        class="w-full text-sm bg-muted border border-border rounded-lg px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-amber-400 cursor-pointer">
                        <option value="">Todos</option>
                        {#each (filterOptions?.coatings ?? []) as c}
                            <option value={c.value}>{c.value} ({c.count})</option>
                        {/each}
                    </select>
                </div>

                <!-- Fotossensível -->
                <div>
                    <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1.5">Fotossensível</label>
                    <select bind:value={photochromic} on:change={aplicarFiltros}
                        class="w-full text-sm bg-muted border border-border rounded-lg px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-amber-400 cursor-pointer">
                        <option value="">Todos</option>
                        {#each (filterOptions?.photochromics ?? []) as p}
                            <option value={p.value}>{p.value} ({p.count})</option>
                        {/each}
                    </select>
                </div>

                <!-- Tipo -->
                <div>
                    <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1.5">Tipo</label>
                    <select bind:value={lens_type} on:change={aplicarFiltros}
                        class="w-full text-sm bg-muted border border-border rounded-lg px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-amber-400 cursor-pointer">
                        <option value="">Todos</option>
                        {#each (filterOptions?.lens_types ?? []) as t}
                            <option value={t.value}>{TIPO_LABELS[t.value] ?? t.value} ({t.count})</option>
                        {/each}
                    </select>
                </div>

                <!-- Material -->
                <div>
                    <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-1.5">Material</label>
                    <select bind:value={material_id} on:change={aplicarFiltros}
                        class="w-full text-sm bg-muted border border-border rounded-lg px-3 py-2 text-foreground focus:outline-none focus:ring-2 focus:ring-amber-400 cursor-pointer">
                        <option value="">Todos</option>
                        {#each (filterOptions?.materials ?? []) as m}
                            <option value={m.id}>{m.name} ({m.count})</option>
                        {/each}
                    </select>
                </div>
            </div>

            <!-- ── Ações ──────────────────────────────────────────────────── -->
            <div class="flex items-center gap-3 mt-4 pt-3 border-t border-border">
                {#if filtrosAtivos > 0}
                    <button type="button" on:click={limparFiltros}
                        class="px-4 py-2 text-sm text-muted-foreground hover:text-foreground transition-colors">
                        Limpar filtros ({filtrosAtivos})
                    </button>
                {/if}
                <span class="text-xs text-muted-foreground ml-auto">
                    {#if !loading}{total.toLocaleString('pt-BR')} resultado{total !== 1 ? 's' : ''}{/if}
                </span>
            </div>
        </div>

        <!-- ── Grid de Cards ─────────────────────────────────────────────────── -->
        <div class="mt-6">
            {#if loading}
                <div class="flex flex-col items-center justify-center py-24 bg-card border border-border rounded-2xl">
                    <div class="w-8 h-8 border-4 border-amber-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p class="text-muted-foreground text-sm">Carregando premium...</p>
                </div>

            {:else if erro}
                <div class="py-16 text-center bg-card border border-red-200 dark:border-red-900 rounded-2xl">
                    <p class="text-red-500 font-semibold">{erro}</p>
                    <button type="button" on:click={fetchResults}
                        class="mt-4 px-4 py-2 bg-amber-600 text-white text-sm font-bold rounded-lg">
                        Tentar novamente
                    </button>
                </div>

            {:else if items.length === 0}
                <div class="py-24 text-center">
                    <p class="text-muted-foreground text-lg font-semibold">Nenhum conceito premium encontrado</p>
                    <p class="text-muted-foreground text-sm mt-1">Tente ajustar os filtros</p>
                    {#if filtrosAtivos > 0}
                        <button type="button" on:click={limparFiltros}
                            class="mt-5 px-4 py-2 text-sm text-amber-600 dark:text-amber-400 hover:text-amber-700 font-semibold transition-colors">
                            Limpar filtros
                        </button>
                    {/if}
                </div>

            {:else}
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {#each items as c (c.id)}
                        <a href="/premium/{c.id}"
                            class="bg-card border border-border rounded-2xl p-5 hover:shadow-md hover:border-amber-200 dark:hover:border-amber-800 transition-all duration-200 flex flex-col gap-3 no-underline">

                            <!-- Marca + Linha -->
                            <div class="flex items-start justify-between gap-2">
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span class="px-2 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 text-[10px] font-black rounded-full uppercase">{c.brand}</span>
                                        {#if c.product_line}
                                            <span class="text-[10px] font-bold text-muted-foreground">{c.product_line}</span>
                                        {/if}
                                    </div>
                                    <h3 class="font-bold text-foreground text-sm leading-snug line-clamp-2">
                                        {c.canonical_name ?? '—'}
                                    </h3>
                                    {#if c.sku}
                                        <p class="font-mono text-[11px] text-muted-foreground mt-0.5">{c.sku}</p>
                                    {/if}
                                </div>
                            </div>

                            <!-- Specs -->
                            <div class="space-y-1.5 flex-1">
                                <div class="flex items-center gap-2">
                                    <span class="text-[10px] font-black uppercase tracking-wide text-muted-foreground w-14 shrink-0">Tipo</span>
                                    <span class="text-xs text-muted-foreground">{TIPO_LABELS[c.lens_type] ?? c.lens_type}</span>
                                </div>
                                <div class="flex items-center gap-2">
                                    <span class="text-[10px] font-black uppercase tracking-wide text-muted-foreground w-14 shrink-0">Material</span>
                                    <span class="text-xs text-muted-foreground">{c.material_name} · n={c.refractive_index}</span>
                                </div>
                                {#if c.coating_name}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-muted-foreground w-14 shrink-0">Coating</span>
                                        <span class="text-xs text-muted-foreground">{c.coating_name}</span>
                                    </div>
                                {/if}
                                {#if c.photochromic_type}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-muted-foreground w-14 shrink-0">Foto</span>
                                        <span class="text-xs text-amber-600 dark:text-amber-400 font-semibold">{c.photochromic_type}</span>
                                    </div>
                                {/if}
                            </div>

                            <!-- Treatment chips -->
                            <div class="flex flex-wrap gap-1 min-h-[18px]">
                                {#each (c.treatment_codes ?? []) as t}
                                    <span class="px-1.5 py-0.5 bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-400 text-[9px] font-black rounded uppercase">{t}</span>
                                {/each}
                            </div>

                            <!-- Footer info -->
                            <div class="flex items-center justify-between pt-3 border-t border-border">
                                <span class="text-[10px] text-muted-foreground">
                                    {c.mapped_lens_count} lentes · {c.mapped_supplier_count} forn.
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
                                class="px-4 py-2 text-sm font-bold rounded-lg border border-border bg-card text-foreground hover:bg-accent disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
                                Anterior
                            </button>
                            <div class="flex items-center gap-1">
                                {#each Array.from({ length: total_paginas }, (_, i) => i + 1) as p}
                                    {#if p === 1 || p === total_paginas || (p >= data.pagina - 2 && p <= data.pagina + 2)}
                                        <button type="button" on:click={() => irParaPagina(p)}
                                            class="w-9 h-9 text-sm font-bold rounded-lg transition-colors {p === data.pagina ? 'bg-amber-600 text-white shadow-sm' : 'bg-card border border-border text-muted-foreground hover:bg-accent'}">
                                            {p}
                                        </button>
                                    {:else if p === data.pagina - 3 || p === data.pagina + 3}
                                        <span class="text-muted-foreground text-sm px-1">...</span>
                                    {/if}
                                {/each}
                            </div>
                            <button type="button" disabled={data.pagina >= total_paginas}
                                on:click={() => irParaPagina(data.pagina + 1)}
                                class="px-4 py-2 text-sm font-bold rounded-lg border border-border bg-card text-foreground hover:bg-accent disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
                                Proxima
                            </button>
                        </div>
                        <p class="text-xs text-muted-foreground">
                            Pagina {data.pagina} de {total_paginas} · {total.toLocaleString('pt-BR')} conceitos
                        </p>
                    </div>
                {/if}
            {/if}
        </div>

    </Container>
</main>
