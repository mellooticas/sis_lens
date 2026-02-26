<script lang="ts">
    /**
     * Catálogo de Lentes Individuais — todas as ~1.400 lentes ativas do tenant.
     * Agrupadas por fornecedor. Sem filtros. Design System SIS_DIGIAI.
     */
    import type { PageData } from './$types';
    import type { VCatalogLens } from '$lib/types/database-views';
    import Container from '$lib/components/layout/Container.svelte';

    export let data: PageData;

    $: lentes = data.lentes as VCatalogLens[];
    $: total  = data.total as number;

    // Agrupar por fornecedor
    $: porFornecedor = (() => {
        const mapa = new Map<string, VCatalogLens[]>();
        for (const l of lentes) {
            const chave = l.supplier_name ?? 'Sem fornecedor';
            if (!mapa.has(chave)) mapa.set(chave, []);
            mapa.get(chave)!.push(l);
        }
        return [...mapa.entries()].sort(([a], [b]) => a.localeCompare(b));
    })();

    function formatarPreco(valor: number | null | undefined): string {
        if (valor == null) return '—';
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
    }

    function formatarTipo(lt: string | null): string {
        const mapa: Record<string, string> = {
            single_vision: 'VS', multifocal: 'Multi',
            bifocal: 'Bifocal', reading: 'Leitura', occupational: 'Ocup.',
        };
        return lt ? (mapa[lt] ?? lt) : '—';
    }

    function getTratamentos(l: VCatalogLens): string[] {
        const t: string[] = [];
        if (l.anti_reflective) t.push('AR');
        if (l.anti_scratch)    t.push('AS');
        if (l.uv_filter)       t.push('UV');
        if (l.blue_light)      t.push('Blue');
        if (l.photochromic)    t.push('Photo');
        if (l.polarized)       t.push('Pol');
        if (l.digital)         t.push('Dig');
        if (l.free_form)       t.push('FF');
        return t;
    }
</script>

<svelte:head>
    <title>Lentes ({total}) | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
    <!-- Cabeçalho -->
    <div class="bg-white dark:bg-neutral-800 border-b border-neutral-200 dark:border-neutral-700 sticky top-0 z-30">
        <Container maxWidth="xl" padding="sm">
            <div class="flex items-center justify-between py-4">
                <div>
                    <h1 class="text-xl font-black text-neutral-900 dark:text-white">Catálogo de Lentes</h1>
                    <p class="text-sm text-neutral-500 mt-0.5">{total} lentes ativas · {porFornecedor.length} fornecedores</p>
                </div>
                <div class="flex gap-2">
                    <a href="/catalogo/standard"
                        class="px-3 py-1.5 bg-primary-100 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 text-xs font-bold rounded-lg hover:bg-primary-200 transition-colors">
                        → Standard
                    </a>
                    <a href="/catalogo/premium"
                        class="px-3 py-1.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 text-xs font-bold rounded-lg hover:bg-amber-200 transition-colors">
                        → Premium
                    </a>
                </div>
            </div>
        </Container>
    </div>

    <Container maxWidth="xl" padding="md">
        {#if lentes.length === 0}
            <div class="mt-20 text-center">
                <p class="text-neutral-400 text-lg">Nenhuma lente ativa encontrada.</p>
            </div>
        {:else}
            {#each porFornecedor as [fornecedor, grupo]}
                <div class="mt-8">
                    <!-- Header do fornecedor -->
                    <div class="flex items-center gap-3 mb-3">
                        <span class="text-xs font-black uppercase tracking-widest text-neutral-400 dark:text-neutral-500">
                            🚚 {fornecedor}
                        </span>
                        <span class="px-2 py-0.5 bg-neutral-100 dark:bg-neutral-800 text-neutral-500 text-[10px] font-bold rounded-full">
                            {grupo.length}
                        </span>
                        <div class="flex-1 h-px bg-neutral-200 dark:bg-neutral-700"></div>
                    </div>

                    <!-- Tabela de lentes -->
                    <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-xl overflow-hidden">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="border-b border-neutral-100 dark:border-neutral-800 text-left">
                                    <th class="px-4 py-3 text-[10px] font-black uppercase tracking-wider text-neutral-400">Lente</th>
                                    <th class="px-4 py-3 text-[10px] font-black uppercase tracking-wider text-neutral-400 hidden md:table-cell">Marca</th>
                                    <th class="px-4 py-3 text-[10px] font-black uppercase tracking-wider text-neutral-400 hidden lg:table-cell">SKU</th>
                                    <th class="px-4 py-3 text-[10px] font-black uppercase tracking-wider text-neutral-400 hidden md:table-cell">Tipo</th>
                                    <th class="px-4 py-3 text-[10px] font-black uppercase tracking-wider text-neutral-400 hidden lg:table-cell">Material / Índice</th>
                                    <th class="px-4 py-3 text-[10px] font-black uppercase tracking-wider text-neutral-400 hidden xl:table-cell">Tratamentos</th>
                                    <th class="px-4 py-3 text-[10px] font-black uppercase tracking-wider text-neutral-400 text-right">Preço</th>
                                </tr>
                            </thead>
                            <tbody>
                                {#each grupo as lente, i (lente.id)}
                                    <tr class="border-b border-neutral-50 dark:border-neutral-800/50 last:border-0 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors">
                                        <!-- Nome -->
                                        <td class="px-4 py-3">
                                            <div class="font-medium text-neutral-900 dark:text-neutral-100 text-sm">{lente.lens_name}</div>
                                            <!-- Mobile: mostra extras inline -->
                                            <div class="md:hidden flex flex-wrap gap-1 mt-1 text-[10px] text-neutral-400">
                                                {#if lente.brand_name}<span>{lente.brand_name}</span>{/if}
                                                {#if lente.refractive_index}<span>n={lente.refractive_index}</span>{/if}
                                            </div>
                                            {#if lente.is_premium}
                                                <span class="text-[9px] font-bold text-amber-600 dark:text-amber-400 uppercase">★ Premium</span>
                                            {/if}
                                        </td>

                                        <!-- Marca -->
                                        <td class="px-4 py-3 hidden md:table-cell">
                                            <span class="text-neutral-600 dark:text-neutral-400">{lente.brand_name ?? '—'}</span>
                                        </td>

                                        <!-- SKU -->
                                        <td class="px-4 py-3 hidden lg:table-cell">
                                            {#if lente.sku}
                                                <span class="font-mono text-[11px] text-neutral-400 bg-neutral-100 dark:bg-neutral-800 px-1.5 py-0.5 rounded">{lente.sku}</span>
                                            {:else}
                                                <span class="text-neutral-300 dark:text-neutral-600">—</span>
                                            {/if}
                                        </td>

                                        <!-- Tipo -->
                                        <td class="px-4 py-3 hidden md:table-cell">
                                            <span class="text-xs text-neutral-500">{formatarTipo(lente.lens_type)}</span>
                                        </td>

                                        <!-- Material / Índice -->
                                        <td class="px-4 py-3 hidden lg:table-cell">
                                            <div class="text-xs text-neutral-500">
                                                {lente.material ?? '—'}
                                                {#if lente.refractive_index}
                                                    <span class="text-neutral-400 ml-1">n={lente.refractive_index}</span>
                                                {/if}
                                            </div>
                                        </td>

                                        <!-- Tratamentos -->
                                        <td class="px-4 py-3 hidden xl:table-cell">
                                            <div class="flex flex-wrap gap-1">
                                                {#each getTratamentos(lente) as trat}
                                                    <span class="px-1.5 py-0.5 bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 text-[9px] font-bold rounded uppercase">{trat}</span>
                                                {/each}
                                                {#if getTratamentos(lente).length === 0}
                                                    <span class="text-neutral-300 dark:text-neutral-600 text-[10px]">—</span>
                                                {/if}
                                            </div>
                                        </td>

                                        <!-- Preço -->
                                        <td class="px-4 py-3 text-right">
                                            <span class="font-bold text-neutral-900 dark:text-neutral-100">{formatarPreco(lente.price_suggested)}</span>
                                        </td>
                                    </tr>
                                {/each}
                            </tbody>
                        </table>
                    </div>
                </div>
            {/each}
        {/if}
    </Container>
</main>
