<script lang="ts">
    import type { PageData } from "./$types";
    import { LensOracleAPI } from "$lib/api/lens-oracle";

    export let data: PageData;

    let isTuning = false;
    let tuneResult: any = null;

    async function handleAutotune() {
        isTuning = true;
        const res = await LensOracleAPI.autotunePricing();
        tuneResult = res.data;
        isTuning = false;
        // Recarregar a página ou os dados se necessário
    }

    const { systemHealth, pricingHealth, catalogSummary } = data;

    const getHealthColor = (status: string) => {
        if (status === "healthy") return "text-emerald-500";
        if (status === "warning") return "text-amber-500";
        if (status === "critical") return "text-rose-500";
        return "text-neutral-500";
    };

    const getZonaColor = (zona: string) => {
        if (zona.includes("Seguranca")) return "bg-emerald-500";
        if (zona.includes("Competitiva")) return "bg-blue-500";
        if (zona.includes("Performance")) return "bg-amber-500";
        return "bg-neutral-500";
    };
</script>

<svelte:head>
    <title>Saúde do Motor Óptico — SIS Lens</title>
</svelte:head>

<div class="p-6 space-y-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div
        class="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-neutral-200 dark:border-neutral-700 pb-6"
    >
        <div>
            <h1
                class="text-3xl font-bold text-neutral-900 dark:text-neutral-100 flex items-center gap-3"
            >
                <span
                    class="p-2 bg-primary-100 dark:bg-primary-900/40 rounded-lg text-primary-600 dark:text-primary-400"
                >
                    <svg
                        class="w-6 h-6"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                        />
                    </svg>
                </span>
                Diagnóstico Vital do Motor Óptico
            </h1>
            <p class="mt-2 text-neutral-500 dark:text-neutral-400 max-w-2xl">
                Monitoramento em tempo real do ecossistema SIS_DIGIAI. O
                "Cérebro" financeiro e clínico calibra o catálogo baseado em
                margens e integridade dos dados.
            </p>
        </div>

        <button
            on:click={handleAutotune}
            disabled={isTuning}
            class="flex items-center gap-2 px-6 py-3 bg-primary-600 hover:bg-primary-700 disabled:opacity-50 text-white rounded-xl font-semibold transition-all shadow-lg shadow-primary-500/20 active:scale-95"
        >
            {#if isTuning}
                <svg
                    class="animate-spin h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                >
                    <circle
                        class="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        stroke-width="4"
                    ></circle>
                    <path
                        class="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                </svg>
                Calibrando Organismo...
            {:else}
                <svg
                    class="w-5 h-5"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13 10V3L4 14h7v7l9-11h-7z"
                    />
                </svg>
                Auto-Calibrar Margens
            {/if}
        </button>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Coluna 1: Auditoria de Saúde -->
        <div class="lg:col-span-2 space-y-8">
            <!-- Seção: Saúde das Tabelas -->
            <section
                class="bg-white dark:bg-neutral-800 rounded-2xl border border-neutral-200 dark:border-neutral-700 overflow-hidden shadow-sm"
            >
                <div
                    class="px-6 py-4 bg-neutral-50 dark:bg-neutral-900/50 border-b border-neutral-200 dark:border-neutral-700"
                >
                    <h2
                        class="font-bold text-neutral-800 dark:text-neutral-200 uppercase tracking-wider text-xs"
                    >
                        Auditoria de Dados Vitais
                    </h2>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr
                                class="text-xs text-neutral-400 font-bold border-b border-neutral-100 dark:border-neutral-700"
                            >
                                <th class="px-6 py-3 uppercase"
                                    >Módulo / Tabela</th
                                >
                                <th class="px-6 py-3 uppercase"
                                    >Volume (Linhas)</th
                                >
                                <th class="px-6 py-3 uppercase"
                                    >Status de Saúde</th
                                >
                            </tr>
                        </thead>
                        <tbody
                            class="divide-y divide-neutral-100 dark:divide-neutral-700"
                        >
                            {#each systemHealth as item}
                                <tr
                                    class="hover:bg-neutral-50 dark:hover:bg-neutral-900/20 transition-colors"
                                >
                                    <td class="px-6 py-4">
                                        <span
                                            class="font-semibold text-neutral-700 dark:text-neutral-300"
                                            >{item.table_name}</span
                                        >
                                    </td>
                                    <td
                                        class="px-6 py-4 font-mono text-sm text-neutral-600 dark:text-neutral-400"
                                    >
                                        {item.row_count.toLocaleString()}
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-2">
                                            <span
                                                class="w-2 h-2 rounded-full {item.health_status ===
                                                'healthy'
                                                    ? 'bg-emerald-500'
                                                    : item.health_status ===
                                                        'warning'
                                                      ? 'bg-amber-500'
                                                      : 'bg-rose-500'}"
                                            ></span>
                                            <span
                                                class="text-xs font-bold uppercase tracking-tighter {getHealthColor(
                                                    item.health_status,
                                                )}"
                                            >
                                                {item.health_status}
                                            </span>
                                        </div>
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- Resumo Global -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {#each catalogSummary as type}
                    <div
                        class="bg-white dark:bg-neutral-800 p-6 rounded-2xl border border-neutral-200 dark:border-neutral-700 shadow-sm relative overflow-hidden group"
                    >
                        <div class="relative z-10">
                            <p
                                class="text-xs font-bold text-neutral-400 uppercase tracking-widest mb-1"
                            >
                                {type.tipo}
                            </p>
                            <div class="flex items-baseline gap-2">
                                <span
                                    class="text-4xl font-black text-neutral-900 dark:text-neutral-100 tracking-tight"
                                    >{type.total}</span
                                >
                                <span
                                    class="text-sm font-medium text-neutral-500 uppercase"
                                    >Itens</span
                                >
                            </div>
                            <div
                                class="mt-4 p-3 bg-neutral-50 dark:bg-neutral-900/40 rounded-xl inline-flex items-center gap-2"
                            >
                                <span
                                    class="text-xs text-neutral-500 dark:text-neutral-400"
                                    >Markup Médio:</span
                                >
                                <span
                                    class="text-sm font-bold text-primary-600 dark:text-primary-400"
                                    >{(type.markup_medio || 0).toFixed(
                                        2,
                                    )}x</span
                                >
                            </div>
                        </div>
                        <!-- Background decoration -->
                        <div
                            class="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity"
                        >
                            <svg
                                class="w-16 h-16 text-neutral-900 dark:text-white"
                                fill="currentColor"
                                viewBox="0 0 20 20"
                            >
                                {#if type.tipo === "Oftálmicas"}
                                    <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                                    <path
                                        fill-rule="evenodd"
                                        d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z"
                                        clip-rule="evenodd"
                                    />
                                {:else}
                                    <path
                                        fill-rule="evenodd"
                                        d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z"
                                        clip-rule="evenodd"
                                    />
                                {/if}
                            </svg>
                        </div>
                    </div>
                {/each}
            </div>
        </div>

        <!-- Coluna 2: Saúde da Precificação -->
        <div class="space-y-6">
            <section
                class="bg-neutral-900 text-white rounded-2xl p-6 shadow-xl border border-neutral-700 relative overflow-hidden"
            >
                <h2
                    class="text-sm font-bold text-neutral-400 uppercase tracking-widest mb-6 flex items-center gap-2"
                >
                    <svg
                        class="w-4 h-4 text-primary-400"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                        />
                    </svg>
                    Pulso da Precificação
                </h2>

                <div class="space-y-6">
                    {#each pricingHealth as zone}
                        <div class="space-y-2">
                            <div class="flex justify-between items-baseline">
                                <span
                                    class="text-sm font-medium text-neutral-300"
                                    >{zone.zona_comercial}</span
                                >
                                <span class="text-xs font-bold text-neutral-500"
                                    >{zone.qtd_lentes} lentes</span
                                >
                            </div>
                            <div
                                class="h-4 w-full bg-neutral-800 rounded-full overflow-hidden flex"
                            >
                                <div
                                    class="h-full {getZonaColor(
                                        zone.zona_comercial,
                                    )} transition-all duration-1000"
                                    style="width: {(
                                        (zone.qtd_lentes /
                                            (catalogSummary[0]?.total || 1)) *
                                        100
                                    ).toFixed(0)}%"
                                ></div>
                            </div>
                            <div class="flex justify-end">
                                <span
                                    class="text-xs font-black text-neutral-100"
                                    >Markup: {(zone.markup_medio || 0).toFixed(
                                        2,
                                    )}x</span
                                >
                            </div>
                        </div>
                    {/each}
                </div>

                <div
                    class="mt-8 pt-6 border-t border-neutral-800 flex flex-col gap-2"
                >
                    <p class="text-[10px] text-neutral-500 leading-tight">
                        * O sistema utiliza uma curva assintótica dinâmica.
                        Quando o markup médio desvia do alvo, use o botão
                        "Auto-Calibrar" para recalcular os parâmetros α e β.
                    </p>
                </div>
            </section>

            <!-- Alerta de Inteligência -->
            <div
                class="p-6 bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-800 rounded-2xl"
            >
                <h3
                    class="flex items-center gap-2 text-amber-800 dark:text-amber-400 font-bold text-sm mb-2"
                >
                    <svg
                        class="w-5 h-5"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                        />
                    </svg>
                    Brain Insights
                </h3>
                <p
                    class="text-xs text-amber-700 dark:text-amber-500 leading-relaxed"
                >
                    Identificamos que as lentes de contato estão com markup
                    fixado em 3.2x via Trigger Nativo. Já as oftálmicas seguem o
                    Living Organism. Recomendamos rodar o tuning se a zona de
                    Performance ultrapassar 30% do catálogo.
                </p>
            </div>
        </div>
    </div>
</div>

<style>
    :global(.dark) {
        color-scheme: dark;
    }
</style>
