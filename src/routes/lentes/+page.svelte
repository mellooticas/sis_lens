<script lang="ts">
    /**
     * Catálogo de Lentes Reais — cards + filtros server-side
     * Fonte: public.v_catalog_lenses (tenant-filtered)
     * Filtros via goto() → URL params → server re-render
     */
    import { goto }         from '$app/navigation';
    import type { PageData } from './$types';
    import type { VCatalogLens } from '$lib/types/database-views';
    import type { FiltrosLentes, FornecedorOption, MaterialOption } from './+page.server';
    import Container from '$lib/components/layout/Container.svelte';

    export let data: PageData;

    $: lentes       = data.lentes       as VCatalogLens[];
    $: total        = data.total        as number;
    $: pagina       = data.pagina       as number;
    $: total_paginas = data.total_paginas as number;
    $: fornecedores = data.fornecedores as FornecedorOption[];
    $: materiais    = data.materiais    as MaterialOption[];
    $: filtros      = data.filtros      as FiltrosLentes;

    // Estado local dos filtros — sincronizado com server data
    let tipo       = filtros.lens_type   ?? '';
    let fornecedor = filtros.supplier_id ?? '';
    let material   = filtros.material_id ?? '';
    let premium    = filtros.is_premium === true ? 'true' : filtros.is_premium === false ? 'false' : '';
    let ar         = filtros.has_ar;
    let blue       = filtros.has_blue;
    let filtrosAbertos = false;

    // Sincroniza ao navegar entre páginas (server re-render)
    $: {
        tipo       = filtros.lens_type   ?? '';
        fornecedor = filtros.supplier_id ?? '';
        material   = filtros.material_id ?? '';
        premium    = filtros.is_premium === true ? 'true' : filtros.is_premium === false ? 'false' : '';
        ar         = filtros.has_ar;
        blue       = filtros.has_blue;
    }

    $: filtrosAtivos = [tipo, fornecedor, material, premium, ar ? '1' : '', blue ? '1' : '']
        .filter(Boolean).length;

    function buildParams(p?: number): string {
        const params = new URLSearchParams();
        if (tipo)       params.set('tipo', tipo);
        if (fornecedor) params.set('fornecedor', fornecedor);
        if (material)   params.set('material', material);
        if (premium)    params.set('premium', premium);
        if (ar)         params.set('ar', '1');
        if (blue)       params.set('blue', '1');
        if (p && p > 1) params.set('pagina', String(p));
        const q = params.toString();
        return q ? `?${q}` : '';
    }

    function aplicarFiltros() { goto(`/lentes${buildParams()}`); }
    function limparFiltros()  { tipo = ''; fornecedor = ''; material = ''; premium = ''; ar = false; blue = false; goto('/lentes'); }
    function irParaPagina(p: number) { goto(`/lentes${buildParams(p)}`); }

    // ── Helpers de display ───────────────────────────────────────────────────
    const TIPO_LABELS: Record<string, string> = {
        single_vision: 'Visão Simples',
        multifocal:    'Multifocal',
        bifocal:       'Bifocal',
        occupational:  'Ocupacional',
    };

    function formatarPreco(valor: number | null | undefined): string {
        if (!valor) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
    }

    // Converte treatment_names[] do banco em labels curtos para exibição
    function getTratamentos(lente: VCatalogLens): string[] {
        const nomes = lente.treatment_names ?? [];
        if (nomes.length > 0) {
            return nomes.map(n => {
                const u = n.toUpperCase();
                if (u.includes('REFLEX') || u.includes('ANTI-RE')) return 'AR';
                if (u.includes('RISCO'))                            return 'AS';
                if (u.includes('UV'))                               return 'UV';
                if (u.includes('BLUE') || u.includes('VIDEO'))      return 'Blue';
                if (u.includes('FOTOCR'))                           return 'Foto';
                if (u.includes('TRANSIT'))                          return 'Trans';
                if (u.includes('POLARIZ'))                          return 'Pol';
                if (u.includes('ACCLIM'))                           return 'Acc';
                return n.split(' ')[0];
            });
        }
        // Fallback flags booleanos
        const t: string[] = [];
        if (lente.anti_reflective) t.push('AR');
        if (lente.anti_scratch)    t.push('AS');
        if (lente.uv_filter)       t.push('UV');
        if (lente.blue_light)      t.push('Blue');
        if (lente.photochromic)    t.push('Foto');
        if (lente.polarized)       t.push('Pol');
        return t;
    }
</script>

<svelte:head>
    <title>Lentes ({total.toLocaleString('pt-BR')}) | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-950 pb-24">

    <!-- ── Hero ──────────────────────────────────────────────────────────── -->
    <div class="bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
        <Container maxWidth="xl" padding="sm">
            <div class="py-6">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                    <div>
                        <h1 class="text-2xl font-black text-neutral-900 dark:text-white">Catálogo de Lentes</h1>
                        <p class="text-sm text-neutral-500 mt-1">
                            {total.toLocaleString('pt-BR')} lentes ·
                            {materiais.length} materiais ·
                            {fornecedores.length} fornecedores
                        </p>
                    </div>
                    <div class="flex gap-2">
                        <a href="/standard"
                            class="px-3 py-1.5 bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400 text-xs font-bold rounded-lg hover:bg-primary-100 dark:hover:bg-primary-900/30 transition-colors">
                            ↗ Standard
                        </a>
                        <a href="/premium"
                            class="px-3 py-1.5 bg-amber-50 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 text-xs font-bold rounded-lg hover:bg-amber-100 dark:hover:bg-amber-900/30 transition-colors">
                            ↗ Premium
                        </a>
                    </div>
                </div>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="md">

        <!-- ── Filtros ────────────────────────────────────────────────────── -->
        <div class="mt-6 bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl overflow-hidden">

            <!-- Header clicável -->
            <button
                class="w-full flex items-center justify-between px-5 py-4 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors text-left"
                on:click={() => filtrosAbertos = !filtrosAbertos}
                type="button"
            >
                <div class="flex items-center gap-3">
                    <svg class="w-4 h-4 text-neutral-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"/>
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

            <!-- Conteúdo dos filtros -->
            {#if filtrosAbertos}
                <div class="border-t border-neutral-100 dark:border-neutral-800 px-5 py-5">
                    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">

                        <!-- Tipo -->
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Tipo</label>
                            <select bind:value={tipo}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400 cursor-pointer">
                                <option value="">Todos</option>
                                <option value="single_vision">Visão Simples</option>
                                <option value="multifocal">Multifocal</option>
                                <option value="bifocal">Bifocal</option>
                                <option value="occupational">Ocupacional</option>
                            </select>
                        </div>

                        <!-- Fornecedor -->
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Fornecedor</label>
                            <select bind:value={fornecedor}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400 cursor-pointer">
                                <option value="">Todos</option>
                                {#each fornecedores as f (f.id)}
                                    <option value={f.id}>{f.name}</option>
                                {/each}
                            </select>
                        </div>

                        <!-- Material -->
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Material</label>
                            <select bind:value={material}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400 cursor-pointer">
                                <option value="">Todos</option>
                                {#each materiais as m (m.id)}
                                    <option value={m.id}>{m.name}</option>
                                {/each}
                            </select>
                        </div>

                        <!-- Linha -->
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Linha</label>
                            <select bind:value={premium}
                                class="w-full text-sm bg-neutral-50 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg px-3 py-2 text-neutral-700 dark:text-neutral-300 focus:outline-none focus:ring-2 focus:ring-primary-400 cursor-pointer">
                                <option value="">Todas</option>
                                <option value="false">Standard</option>
                                <option value="true">Premium</option>
                            </select>
                        </div>

                        <!-- Tratamentos -->
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-wider text-neutral-400 mb-1.5">Tratamentos</label>
                            <div class="flex flex-col gap-2">
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" bind:checked={ar}
                                        class="w-3.5 h-3.5 rounded accent-primary-600 cursor-pointer"/>
                                    <span class="text-sm text-neutral-700 dark:text-neutral-300">Anti-Reflexo</span>
                                </label>
                                <label class="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" bind:checked={blue}
                                        class="w-3.5 h-3.5 rounded accent-primary-600 cursor-pointer"/>
                                    <span class="text-sm text-neutral-700 dark:text-neutral-300">Blue Cut</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Botões de ação -->
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
                            {total.toLocaleString('pt-BR')} resultado{total !== 1 ? 's' : ''}
                        </span>
                    </div>
                </div>
            {/if}
        </div>

        <!-- ── Grid de Cards ──────────────────────────────────────────────── -->
        <div class="mt-6">
            {#if lentes.length === 0}
                <div class="py-24 text-center">
                    <div class="text-5xl mb-4">🔍</div>
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
                        {@const tratamentos = getTratamentos(lente)}
                        <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-2xl p-5 hover:shadow-md hover:border-primary-200 dark:hover:border-primary-800 transition-all duration-200 flex flex-col gap-3">

                            <!-- Topo: nome + badge STD/PRE -->
                            <div class="flex items-start justify-between gap-2">
                                <div class="flex-1 min-w-0">
                                    <h3 class="font-bold text-neutral-900 dark:text-white text-sm leading-snug line-clamp-2">
                                        {lente.lens_name ?? '—'}
                                    </h3>
                                    <p class="text-[11px] text-neutral-400 dark:text-neutral-500 mt-0.5 truncate">
                                        {lente.supplier_name ?? '—'}
                                    </p>
                                </div>
                                {#if lente.is_premium}
                                    <span class="shrink-0 px-1.5 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 text-[9px] font-black rounded-full uppercase tracking-wide">★ PRE</span>
                                {:else}
                                    <span class="shrink-0 px-1.5 py-0.5 bg-sky-50 dark:bg-sky-900/20 text-sky-600 dark:text-sky-400 text-[9px] font-black rounded-full uppercase tracking-wide">STD</span>
                                {/if}
                            </div>

                            <!-- Especificações -->
                            <div class="space-y-1.5 flex-1">
                                {#if lente.brand_name}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-neutral-300 dark:text-neutral-600 w-14 shrink-0">Marca</span>
                                        <span class="text-xs text-neutral-600 dark:text-neutral-400 truncate">{lente.brand_name}</span>
                                    </div>
                                {/if}

                                {#if lente.lens_type}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-neutral-300 dark:text-neutral-600 w-14 shrink-0">Tipo</span>
                                        <span class="text-xs text-neutral-600 dark:text-neutral-400">{TIPO_LABELS[lente.lens_type] ?? lente.lens_type}</span>
                                    </div>
                                {/if}

                                {#if lente.material_name}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-neutral-300 dark:text-neutral-600 w-14 shrink-0">Material</span>
                                        <span class="text-xs text-neutral-600 dark:text-neutral-400 leading-tight">
                                            {lente.material_name}{#if lente.refractive_index} · <span class="text-neutral-400 dark:text-neutral-500">n={lente.refractive_index}</span>{/if}
                                        </span>
                                    </div>
                                {/if}

                                {#if lente.sku}
                                    <div class="flex items-center gap-2">
                                        <span class="text-[10px] font-black uppercase tracking-wide text-neutral-300 dark:text-neutral-600 w-14 shrink-0">SKU</span>
                                        <span class="font-mono text-[10px] bg-neutral-100 dark:bg-neutral-800 text-neutral-500 dark:text-neutral-400 px-1.5 py-0.5 rounded">{lente.sku}</span>
                                    </div>
                                {/if}
                            </div>

                            <!-- Tratamentos -->
                            <div class="flex flex-wrap gap-1 min-h-[18px]">
                                {#each tratamentos as trat}
                                    <span class="px-1.5 py-0.5 bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400 text-[9px] font-black rounded uppercase">{trat}</span>
                                {/each}
                            </div>

                            <!-- Rodapé: preço -->
                            <div class="flex items-center justify-between pt-3 border-t border-neutral-100 dark:border-neutral-800">
                                <span class="text-[10px] font-black uppercase tracking-wide text-neutral-400">Sugerido</span>
                                <span class="text-base font-black text-neutral-900 dark:text-white">
                                    {formatarPreco(lente.price_suggested)}
                                </span>
                            </div>
                        </div>
                    {/each}
                </div>

                <!-- ── Paginação ─────────────────────────────────────────── -->
                {#if total_paginas > 1}
                    <div class="flex flex-col items-center gap-3 mt-10">
                        <div class="flex items-center gap-2">
                            <button
                                type="button"
                                disabled={pagina <= 1}
                                on:click={() => irParaPagina(pagina - 1)}
                                class="px-4 py-2 text-sm font-bold rounded-lg border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-900 text-neutral-700 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
                                ← Anterior
                            </button>

                            <div class="flex items-center gap-1">
                                {#each Array.from({ length: total_paginas }, (_, i) => i + 1) as p}
                                    {#if p === 1 || p === total_paginas || (p >= pagina - 2 && p <= pagina + 2)}
                                        <button
                                            type="button"
                                            on:click={() => irParaPagina(p)}
                                            class="w-9 h-9 text-sm font-bold rounded-lg transition-colors
                                                {p === pagina
                                                    ? 'bg-primary-600 text-white shadow-sm'
                                                    : 'bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800'}">
                                            {p}
                                        </button>
                                    {:else if p === pagina - 3 || p === pagina + 3}
                                        <span class="text-neutral-400 text-sm px-1">…</span>
                                    {/if}
                                {/each}
                            </div>

                            <button
                                type="button"
                                disabled={pagina >= total_paginas}
                                on:click={() => irParaPagina(pagina + 1)}
                                class="px-4 py-2 text-sm font-bold rounded-lg border border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-900 text-neutral-700 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
                                Próxima →
                            </button>
                        </div>

                        <p class="text-xs text-neutral-400">
                            Página {pagina} de {total_paginas} · {total.toLocaleString('pt-BR')} lentes no total
                        </p>
                    </div>
                {/if}
            {/if}
        </div>
    </Container>
</main>
