<script lang="ts">
    /**
     * Standard Collection v3 — Filtros Técnicos
     * Fonte: catalog_lenses.rpc_standard_filter_options + rpc_standard_search
     * Sem marca! Material e tratamento são os filtros principais.
     */
    import { afterNavigate } from '$app/navigation';
    import { goto }          from '$app/navigation';
    import type { PageData } from './$types';
    import { LensOracleAPI } from '$lib/api/lens-oracle';
    import Container         from '$lib/components/layout/Container.svelte';
    import type { StandardFilterOptions, CanonicalStandardV3 } from '$lib/types/database-views';

    export let data: PageData;

    const LIMITE = 24;

    // ── Estado ──────────────────────────────────────────────────────────────────
    let items: CanonicalStandardV3[] = [];
    let total         = 0;
    let total_paginas = 0;
    let loading       = true;
    let loadingFilters = true;
    let erro: string | null = null;

    // Opções dinâmicas
    let filterOptions: StandardFilterOptions | null = null;

    // Form (espelha URL)
    let lens_type   = data.lens_type   ?? '';
    let material_id = data.material_id ?? '';
    let treatments: string[] = data.treatments ?? [];

    // ── Fetch filtros ────────────────────────────────────────────────────────────
    async function fetchFilterOptions() {
        loadingFilters = true;
        const res = await LensOracleAPI.getStandardFilterOptions({
            lens_type:   lens_type || undefined,
            material_id: material_id || undefined,
            treatments:  treatments.length > 0 ? treatments : undefined,
        });
        if (res.data) filterOptions = res.data;
        loadingFilters = false;
    }

    // ── Fetch resultados ─────────────────────────────────────────────────────────
    async function fetchResults() {
        loading = true;
        erro = null;

        lens_type   = data.lens_type   ?? '';
        material_id = data.material_id ?? '';
        treatments  = data.treatments  ?? [];

        const offset = (data.pagina - 1) * LIMITE;

        const res = await LensOracleAPI.searchStandard({
            lens_type:   lens_type || undefined,
            material_id: material_id || undefined,
            treatments:  treatments.length > 0 ? treatments : undefined,
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
        if (lens_type)         p.set('tipo',     lens_type);
        if (material_id)       p.set('material', material_id);
        if (treatments.length) p.set('trat',     treatments.join(','));
        goto(`/standard?${p.toString()}`);
    }

    function selecionarMaterial(id: string) {
        material_id = material_id === id ? '' : id;
        aplicarFiltros();
    }

    function toggleTratamento(code: string) {
        if (treatments.includes(code)) {
            treatments = treatments.filter(t => t !== code);
        } else {
            treatments = [...treatments, code];
        }
        aplicarFiltros();
    }

    function limparFiltros() {
        lens_type = ''; material_id = ''; treatments = [];
        goto('/standard');
    }

    function irParaPagina(p: number) {
        const params = new URLSearchParams();
        if (lens_type)         params.set('tipo',     lens_type);
        if (material_id)       params.set('material', material_id);
        if (treatments.length) params.set('trat',     treatments.join(','));
        params.set('pagina', String(p));
        goto(`/standard?${params.toString()}`);
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

    const TRAT_LABELS: Record<string, string> = {
        ar:      'Anti-Reflexo',
        blue:    'Blue Light',
        uv:      'UV',
        scratch: 'Anti-Risco',
        photo:   'Fotossensível',
    };

    function fmt(v: number | null): string {
        if (v == null) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v);
    }

    $: filtrosAtivos = [lens_type, material_id, ...treatments].filter(Boolean).length;
</script>

<svelte:head>
    <title>Standard ({total.toLocaleString('pt-BR')}) | Clearix Lens</title>
</svelte:head>

<main class="min-h-screen bg-muted pb-24">

    <!-- ── Hero ─────────────────────────────────────────────────────────────── -->
    <div class="bg-background border-b border-border">
        <Container maxWidth="xl" padding="sm">
            <div class="py-6">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                    <div>
                        <div class="flex items-center gap-2 mb-1">
                            <span class="px-2 py-0.5 bg-sky-100 dark:bg-sky-900/30 text-sky-700 dark:text-sky-400 text-xs font-black rounded-full uppercase tracking-wide">Essencial</span>
                        </div>
                        <h1 class="text-2xl font-black text-foreground">Standard Collection</h1>
                        <p class="text-sm text-muted-foreground mt-1">
                            {#if loading}Carregando...{:else}{total.toLocaleString('pt-BR')} conceitos · custo-beneficio sem marca{/if}
                        </p>
                    </div>
                    <div class="flex gap-2">
                        <a href="/lentes" class="px-3 py-1.5 bg-muted text-muted-foreground text-xs font-bold rounded-lg hover:bg-accent transition-colors">Catalogo</a>
                        <a href="/premium" class="px-3 py-1.5 bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 text-xs font-bold rounded-lg hover:bg-amber-100 dark:hover:bg-amber-900/30 transition-colors">Premium</a>
                    </div>
                </div>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="md">

        <!-- ── Filtros ─────────────────────────────────────────────────────── -->
        <div class="mt-6 bg-card border border-border rounded-2xl p-5">

            <!-- Tipo de lente -->
            <div class="flex items-center gap-4 mb-5">
                <label class="text-[10px] font-black uppercase tracking-wider text-muted-foreground shrink-0">Tipo</label>
                <div class="flex flex-wrap gap-2">
                    <button type="button"
                        on:click={() => { lens_type = ''; aplicarFiltros(); }}
                        class="px-3 py-1.5 text-sm font-bold rounded-lg transition-all
                            {!lens_type ? 'bg-sky-600 text-white' : 'bg-muted text-muted-foreground hover:bg-accent'}">
                        Todos
                    </button>
                    {#each (filterOptions?.lens_types ?? []) as t}
                        <button type="button"
                            on:click={() => { lens_type = lens_type === t.value ? '' : t.value; aplicarFiltros(); }}
                            class="px-3 py-1.5 text-sm font-bold rounded-lg transition-all
                                {lens_type === t.value ? 'bg-sky-600 text-white' : 'bg-muted text-muted-foreground hover:bg-accent'}">
                            {TIPO_LABELS[t.value] ?? t.value}
                            <span class="ml-1 text-xs opacity-70">({t.count})</span>
                        </button>
                    {/each}
                </div>
            </div>

            <!-- Material (pills — o diferencial do standard) -->
            <div class="mb-5 pt-4 border-t border-border">
                <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-3">Material / Indice</label>
                <div class="flex flex-wrap gap-2">
                    {#if filterOptions?.materials}
                        {#each filterOptions.materials as m}
                            <button type="button"
                                on:click={() => selecionarMaterial(m.id)}
                                class="px-4 py-2 text-sm font-bold rounded-xl border-2 transition-all duration-150
                                    {material_id === m.id
                                        ? 'bg-sky-600 border-sky-600 text-white shadow-md'
                                        : 'bg-card border-border text-foreground hover:border-sky-300 hover:bg-sky-50 dark:hover:bg-sky-900/20'}">
                                {m.name}
                                <span class="ml-1.5 text-xs opacity-70">({m.count})</span>
                            </button>
                        {/each}
                    {:else}
                        {#each Array(6) as _}
                            <div class="h-10 w-32 bg-muted rounded-xl animate-pulse"></div>
                        {/each}
                    {/if}
                </div>
            </div>

            <!-- Tratamentos (checkboxes) -->
            <div class="pt-4 border-t border-border">
                <label class="block text-[10px] font-black uppercase tracking-wider text-muted-foreground mb-3">Tratamentos</label>
                <div class="flex flex-wrap gap-3">
                    {#each (filterOptions?.treatments ?? []) as t}
                        <button type="button"
                            on:click={() => toggleTratamento(t.value)}
                            class="flex items-center gap-2 px-3 py-2 text-sm rounded-lg border transition-all
                                {treatments.includes(t.value)
                                    ? 'bg-sky-100 dark:bg-sky-900/30 border-sky-300 dark:border-sky-700 text-sky-700 dark:text-sky-300 font-bold'
                                    : 'bg-card border-border text-muted-foreground hover:bg-accent'}">
                            <span class="w-4 h-4 rounded border-2 flex items-center justify-center text-[10px]
                                {treatments.includes(t.value) ? 'border-sky-500 bg-sky-500 text-white' : 'border-muted-foreground/30'}">
                                {#if treatments.includes(t.value)}✓{/if}
                            </span>
                            {TRAT_LABELS[t.value] ?? t.value}
                            <span class="text-xs opacity-60">({t.count})</span>
                        </button>
                    {/each}
                </div>
            </div>

            <!-- Ações -->
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
                    <div class="w-8 h-8 border-4 border-sky-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p class="text-muted-foreground text-sm">Carregando standard...</p>
                </div>

            {:else if erro}
                <div class="py-16 text-center bg-card border border-red-200 dark:border-red-900 rounded-2xl">
                    <p class="text-red-500 font-semibold">{erro}</p>
                    <button type="button" on:click={fetchResults}
                        class="mt-4 px-4 py-2 bg-sky-600 text-white text-sm font-bold rounded-lg">
                        Tentar novamente
                    </button>
                </div>

            {:else if items.length === 0}
                <div class="py-24 text-center">
                    <p class="text-muted-foreground text-lg font-semibold">Nenhum conceito encontrado</p>
                    <p class="text-muted-foreground text-sm mt-1">Tente ajustar os filtros</p>
                    {#if filtrosAtivos > 0}
                        <button type="button" on:click={limparFiltros}
                            class="mt-5 px-4 py-2 text-sm text-sky-600 dark:text-sky-400 hover:text-sky-700 font-semibold transition-colors">
                            Limpar filtros
                        </button>
                    {/if}
                </div>

            {:else}
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {#each items as c (c.id)}
                        <a href="/standard/{c.id}"
                            class="bg-card border border-border rounded-2xl p-5 hover:shadow-md hover:border-sky-200 dark:hover:border-sky-800 transition-all duration-200 flex flex-col gap-3 no-underline">

                            <!-- Nome + badge STD -->
                            <div class="flex items-start justify-between gap-2">
                                <div class="flex-1 min-w-0">
                                    <h3 class="font-bold text-foreground text-sm leading-snug line-clamp-2">
                                        {c.canonical_name ?? '—'}
                                    </h3>
                                    {#if c.sku}
                                        <p class="font-mono text-[11px] text-muted-foreground mt-0.5">{c.sku}</p>
                                    {/if}
                                </div>
                                <span class="shrink-0 px-1.5 py-0.5 bg-sky-50 dark:bg-sky-900/20 text-sky-600 dark:text-sky-400 text-[9px] font-black rounded-full uppercase tracking-wide">STD</span>
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
                                <div class="flex items-center gap-2">
                                    <span class="text-[10px] font-black uppercase tracking-wide text-muted-foreground w-14 shrink-0">Opcoes</span>
                                    <span class="text-xs text-muted-foreground">{c.mapped_lens_count} lentes · {c.mapped_supplier_count} forn.</span>
                                </div>
                            </div>

                            <!-- Treatment chips -->
                            <div class="flex flex-wrap gap-1 min-h-[18px]">
                                {#each (c.treatment_codes ?? []) as t}
                                    <span class="px-1.5 py-0.5 bg-sky-50 dark:bg-sky-900/20 text-sky-600 dark:text-sky-400 text-[9px] font-black rounded uppercase">{t}</span>
                                {/each}
                            </div>

                            <!-- Footer -->
                            <div class="flex items-center justify-between pt-3 border-t border-border">
                                <span class="text-[10px] text-muted-foreground">
                                    {c.mapped_supplier_count} fornecedor{c.mapped_supplier_count !== 1 ? 'es' : ''}
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
                                            class="w-9 h-9 text-sm font-bold rounded-lg transition-colors {p === data.pagina ? 'bg-sky-600 text-white shadow-sm' : 'bg-card border border-border text-muted-foreground hover:bg-accent'}">
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
