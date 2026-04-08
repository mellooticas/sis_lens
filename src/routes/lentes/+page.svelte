<script lang="ts">
    /**
     * Catálogo de Lentes Reais
     *
     * Mostra TODAS as 3.698 lentes reais (v_catalog_lenses), divididas em
     * tabs Premium / Standard via flag is_premium. Conceitos canônicos NÃO
     * aparecem aqui — só no detalhe individual da lente.
     */
    import { goto } from '$app/navigation';
    import { page } from '$app/stores';
    import { Crown, Sparkles, Search, X } from 'lucide-svelte';
    import Container from '$lib/components/layout/Container.svelte';
    import type { PageData } from './$types';

    export let data: PageData;

    $: lentes         = data.lentes;
    $: total          = data.total;
    $: premiumTotal   = data.premiumTotal;
    $: standardTotal  = data.standardTotal;
    $: pagina         = data.pagina;
    $: pageSize       = data.pageSize;
    $: totalPages     = Math.max(1, Math.ceil(total / pageSize));
    $: filtros        = data.filtros;
    $: filterOptions  = data.filterOptions;
    $: hasActiveFilters = !!(
        filtros.busca || filtros.tipo || filtros.fornecedor || filtros.marca ||
        filtros.material || filtros.indice != null || filtros.isPremium !== null
    );

    // Tab ativo derivado do filtro is_premium
    $: activeTab = filtros.isPremium === true  ? 'premium'
                 : filtros.isPremium === false ? 'standard'
                 : 'todos';

    // Busca local (input)
    let buscaInput = '';
    $: buscaInput  = filtros.busca ?? '';

    function navegar(params: Record<string, string | number | null>) {
        const url = new URL($page.url);
        for (const [k, v] of Object.entries(params)) {
            if (v === null || v === '') url.searchParams.delete(k);
            else url.searchParams.set(k, String(v));
        }
        // Reset paginação ao mudar filtros
        if (!('pagina' in params)) url.searchParams.delete('pagina');
        goto(url.pathname + url.search, { keepFocus: true, noScroll: false });
    }

    function setTab(tab: 'todos' | 'premium' | 'standard') {
        const premium = tab === 'premium' ? 'true' : tab === 'standard' ? 'false' : null;
        navegar({ premium });
    }

    function aplicarBusca() {
        navegar({ busca: buscaInput || null });
    }

    function setFiltro(key: 'tipo' | 'fornecedor' | 'material' | 'indice', value: string | null) {
        navegar({ [key]: value });
    }

    function limparFiltros() {
        goto('/lentes');
    }

    function fmtBRL(v: number | null | undefined): string {
        if (v == null) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v);
    }

    const TIPO_LABELS: Record<string, string> = {
        single_vision: 'Visão Simples',
        multifocal:    'Multifocal',
        bifocal:       'Bifocal',
        occupational:  'Ocupacional',
    };
</script>

<svelte:head>
    <title>Catálogo de Lentes | Clearix Lens</title>
</svelte:head>

<main class="min-h-screen bg-muted pb-20">
    <!-- Hero -->
    <div class="bg-background border-b border-border">
        <Container>
            <div class="py-10">
                <h1 class="text-4xl font-bold bg-gradient-to-r from-blue-600 via-cyan-600 to-teal-600 bg-clip-text text-transparent">
                    Catálogo de Lentes
                </h1>
                <p class="mt-2 text-muted-foreground">
                    {total.toLocaleString('pt-BR')} lentes reais — Premium e Standard
                </p>
            </div>
        </Container>
    </div>

    <Container>
        <div class="py-8 space-y-6">

            <!-- KPIs -->
            <div class="grid grid-cols-2 gap-4 md:grid-cols-3">
                <div class="rounded-xl bg-card border border-border p-4">
                    <p class="text-xs font-bold uppercase tracking-wide text-muted-foreground mb-1">Total</p>
                    <p class="text-3xl font-black text-foreground">{(premiumTotal + standardTotal).toLocaleString('pt-BR')}</p>
                </div>
                <div class="rounded-xl bg-amber-50 dark:bg-amber-950/30 p-4">
                    <div class="flex items-center gap-2 mb-1">
                        <Crown class="h-4 w-4 text-amber-600 dark:text-amber-400" />
                        <p class="text-xs font-bold uppercase tracking-wide text-amber-700 dark:text-amber-300">Premium</p>
                    </div>
                    <p class="text-3xl font-black text-amber-900 dark:text-amber-100">{premiumTotal.toLocaleString('pt-BR')}</p>
                </div>
                <div class="rounded-xl bg-cyan-50 dark:bg-cyan-950/30 p-4">
                    <div class="flex items-center gap-2 mb-1">
                        <Sparkles class="h-4 w-4 text-cyan-600 dark:text-cyan-400" />
                        <p class="text-xs font-bold uppercase tracking-wide text-cyan-700 dark:text-cyan-300">Standard</p>
                    </div>
                    <p class="text-3xl font-black text-cyan-900 dark:text-cyan-100">{standardTotal.toLocaleString('pt-BR')}</p>
                </div>
            </div>

            <!-- Tabs -->
            <div class="flex gap-2 border-b border-border">
                <button
                    class="px-4 py-2 text-sm font-semibold border-b-2 transition-colors {activeTab === 'todos' ? 'border-foreground text-foreground' : 'border-transparent text-muted-foreground hover:text-foreground'}"
                    on:click={() => setTab('todos')}
                >
                    Todas ({(premiumTotal + standardTotal).toLocaleString('pt-BR')})
                </button>
                <button
                    class="px-4 py-2 text-sm font-semibold border-b-2 transition-colors flex items-center gap-1.5 {activeTab === 'premium' ? 'border-amber-600 text-amber-700 dark:text-amber-300' : 'border-transparent text-muted-foreground hover:text-foreground'}"
                    on:click={() => setTab('premium')}
                >
                    <Crown class="h-3.5 w-3.5" />
                    Premium ({premiumTotal.toLocaleString('pt-BR')})
                </button>
                <button
                    class="px-4 py-2 text-sm font-semibold border-b-2 transition-colors flex items-center gap-1.5 {activeTab === 'standard' ? 'border-cyan-600 text-cyan-700 dark:text-cyan-300' : 'border-transparent text-muted-foreground hover:text-foreground'}"
                    on:click={() => setTab('standard')}
                >
                    <Sparkles class="h-3.5 w-3.5" />
                    Standard ({standardTotal.toLocaleString('pt-BR')})
                </button>
            </div>

            <!-- Search bar -->
            <div class="flex gap-2">
                <div class="relative flex-1">
                    <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <input
                        type="text"
                        placeholder="Buscar por nome, marca, fornecedor ou SKU…"
                        bind:value={buscaInput}
                        on:keydown={(e) => e.key === 'Enter' && aplicarBusca()}
                        class="w-full pl-10 pr-4 py-2 bg-card border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                    />
                </div>
                <button
                    on:click={aplicarBusca}
                    class="px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white text-sm font-semibold rounded-lg transition-colors"
                >
                    Buscar
                </button>
                {#if hasActiveFilters}
                    <button
                        on:click={limparFiltros}
                        class="px-3 py-2 bg-muted hover:bg-accent text-muted-foreground text-sm font-semibold rounded-lg transition-colors flex items-center gap-1.5"
                    >
                        <X class="h-4 w-4" /> Limpar
                    </button>
                {/if}
            </div>

            <!-- Sidebar + Lista -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">

                <!-- Sidebar de filtros -->
                <aside class="lg:col-span-1 space-y-4">
                    <div class="bg-card border border-border rounded-2xl p-5 sticky top-4">
                        <h2 class="text-sm font-black uppercase tracking-wider text-foreground mb-4">Filtros</h2>

                        <!-- Laboratório -->
                        <div class="mb-4">
                            <label for="filtro-fornecedor" class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1.5">
                                Laboratório
                            </label>
                            <select
                                id="filtro-fornecedor"
                                value={filtros.fornecedor ?? ''}
                                on:change={(e) => setFiltro('fornecedor', e.currentTarget.value || null)}
                                class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500"
                            >
                                <option value="">Todos ({filterOptions.laboratorios.length})</option>
                                {#each filterOptions.laboratorios as opt}
                                    <option value={opt.value}>{opt.label} ({opt.count})</option>
                                {/each}
                            </select>
                        </div>

                        <!-- Tipo -->
                        <div class="mb-4">
                            <label for="filtro-tipo" class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1.5">
                                Tipo
                            </label>
                            <select
                                id="filtro-tipo"
                                value={filtros.tipo ?? ''}
                                on:change={(e) => setFiltro('tipo', e.currentTarget.value || null)}
                                class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500"
                            >
                                <option value="">Todos</option>
                                {#each filterOptions.tipos as opt}
                                    <option value={opt.value}>{opt.label} ({opt.count})</option>
                                {/each}
                            </select>
                        </div>

                        <!-- Material -->
                        <div class="mb-4">
                            <label for="filtro-material" class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1.5">
                                Material
                            </label>
                            <select
                                id="filtro-material"
                                value={filtros.material ?? ''}
                                on:change={(e) => setFiltro('material', e.currentTarget.value || null)}
                                class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500"
                            >
                                <option value="">Todos ({filterOptions.materiais.length})</option>
                                {#each filterOptions.materiais as opt}
                                    <option value={opt.value}>{opt.label} ({opt.count})</option>
                                {/each}
                            </select>
                        </div>

                        <!-- Índice -->
                        <div class="mb-4">
                            <label for="filtro-indice" class="text-[10px] font-black uppercase tracking-wider text-muted-foreground block mb-1.5">
                                Índice de refração
                            </label>
                            <select
                                id="filtro-indice"
                                value={filtros.indice != null ? String(filtros.indice) : ''}
                                on:change={(e) => setFiltro('indice', e.currentTarget.value || null)}
                                class="w-full px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary-500"
                            >
                                <option value="">Todos</option>
                                {#each filterOptions.indices as opt}
                                    <option value={opt.value}>{opt.label} ({opt.count})</option>
                                {/each}
                            </select>
                        </div>

                        {#if hasActiveFilters}
                            <button
                                on:click={limparFiltros}
                                class="w-full mt-2 px-3 py-2 bg-muted hover:bg-accent text-muted-foreground text-xs font-bold rounded-lg transition-colors flex items-center justify-center gap-1.5"
                            >
                                <X class="h-3.5 w-3.5" /> Limpar todos os filtros
                            </button>
                        {/if}
                    </div>
                </aside>

                <!-- Conteúdo principal -->
                <div class="lg:col-span-3 space-y-4">
                    {#if lentes.length === 0}
                        <div class="bg-card border border-border rounded-2xl p-12 text-center">
                            <p class="text-muted-foreground">Nenhuma lente encontrada com os filtros atuais.</p>
                        </div>
                    {:else}
                        <p class="text-sm text-muted-foreground">
                            Mostrando <span class="font-bold text-foreground">{lentes.length}</span> de
                            <span class="font-bold text-foreground">{total.toLocaleString('pt-BR')}</span>
                            {total === 1 ? 'lente' : 'lentes'}
                        </p>

                        <div class="bg-card border border-border rounded-2xl overflow-hidden">
                            <div class="divide-y divide-border">
                                {#each lentes as lente (lente.id)}
                                    <a
                                        href="/lentes/{lente.id}"
                                        class="flex items-center gap-4 px-5 py-4 hover:bg-accent transition-colors"
                                    >
                                        <!-- Badge premium/standard -->
                                        <div class="shrink-0">
                                            {#if lente.is_premium}
                                                <div class="w-10 h-10 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
                                                    <Crown class="h-5 w-5 text-amber-600 dark:text-amber-400" />
                                                </div>
                                            {:else}
                                                <div class="w-10 h-10 rounded-lg bg-cyan-100 dark:bg-cyan-900/30 flex items-center justify-center">
                                                    <Sparkles class="h-5 w-5 text-cyan-600 dark:text-cyan-400" />
                                                </div>
                                            {/if}
                                        </div>

                                        <!-- Info principal -->
                                        <div class="flex-1 min-w-0">
                                            <p class="font-semibold text-foreground truncate">{lente.lens_name ?? '—'}</p>
                                            <p class="text-xs text-muted-foreground truncate mt-0.5">
                                                {lente.brand_name ?? '—'}
                                                {#if lente.supplier_name} · {lente.supplier_name}{/if}
                                                {#if lente.material_name} · {lente.material_name}{/if}
                                                {#if lente.refractive_index} · n={lente.refractive_index}{/if}
                                                {#if lente.sku} · <span class="font-mono">{lente.sku}</span>{/if}
                                            </p>
                                        </div>

                                        <!-- Tipo -->
                                        <div class="hidden md:block shrink-0 text-right">
                                            <p class="text-xs text-muted-foreground">Tipo</p>
                                            <p class="text-sm font-semibold text-foreground">{TIPO_LABELS[lente.lens_type ?? ''] ?? lente.lens_type ?? '—'}</p>
                                        </div>

                                        <!-- Preço -->
                                        <div class="shrink-0 text-right min-w-[100px]">
                                            <p class="text-xs text-muted-foreground">Sugerido</p>
                                            <p class="text-base font-bold text-primary-600 dark:text-primary-400">{fmtBRL(lente.price_suggested)}</p>
                                        </div>
                                    </a>
                                {/each}
                            </div>
                        </div>

                        <!-- Paginação -->
                        {#if totalPages > 1}
                            <div class="flex items-center justify-center gap-2 flex-wrap pt-4">
                                <button
                                    disabled={pagina === 1}
                                    on:click={() => navegar({ pagina: pagina - 1 })}
                                    class="px-3 py-2 rounded-lg border border-border hover:bg-muted disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
                                >
                                    ← Anterior
                                </button>
                                <span class="text-sm text-muted-foreground">
                                    Página <span class="font-bold text-foreground">{pagina}</span> de <span class="font-bold text-foreground">{totalPages}</span>
                                </span>
                                <button
                                    disabled={pagina === totalPages}
                                    on:click={() => navegar({ pagina: pagina + 1 })}
                                    class="px-3 py-2 rounded-lg border border-border hover:bg-muted disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
                                >
                                    Próxima →
                                </button>
                            </div>
                        {/if}
                    {/if}
                </div>
            </div>
        </div>
    </Container>
</main>
