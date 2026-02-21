<script lang="ts">
    import {
        Building2,
        TrendingDown,
        Clock,
        CheckCircle,
        AlertTriangle,
    } from "lucide-svelte";

    // Dados mockados que viriam da view vw_opcoes_marca_propria
    export let lenteVirtual = {
        nome: "SIS Lens Gold Digital 1.67",
        sku: "SIS-GOLD-167-DIG",
    };

    export let sourcingOptions = [
        {
            lab_id: "lab-a",
            lab_nome: "Laboratório Alpha",
            produto_real: "Alpha Digital X",
            custo: 250.0,
            prazo: 3,
            quality_score: 9.8,
            status: "ATIVO_PREFERIDO",
        },
        {
            lab_id: "lab-b",
            lab_nome: "Laboratório Beta",
            produto_real: "Beta Freeform HD",
            custo: 245.0, // Mais barato agora!
            prazo: 4,
            quality_score: 9.5,
            status: "ATIVO",
        },
        {
            lab_id: "lab-c",
            lab_nome: "Gamma Optical",
            produto_real: "Gamma Vision Pro",
            custo: 280.0,
            prazo: 5,
            quality_score: 9.2,
            status: "BACKUP",
        },
        {
            lab_id: "lab-d",
            lab_nome: "Delta Labs",
            produto_real: "Delta Sharp",
            custo: 230.0,
            prazo: 12, // Muito demorado
            quality_score: 8.5,
            status: "SUSPENSO", // Prazo estourado
        },
    ];

    // Ordenar por melhor opção (Regra de negócio simples: Menor Custo + Score Aceitável)
    $: sortedOptions = [...sourcingOptions].sort((a, b) => {
        if (a.status === "SUSPENSO") return 1;
        if (b.status === "SUSPENSO") return -1;
        // Em produção, usaríamos uma fórmula ponderada aqui
        return a.custo - b.custo;
    });

    $: currentBestOption = sortedOptions[0];
</script>

<div
    class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden font-sans"
>
    <div
        class="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50"
    >
        <div>
            <h3
                class="text-lg font-bold text-gray-800 flex items-center gap-2 font-headline"
            >
                <Building2 size={20} class="text-primary-500" />
                SIS Lens Sourcing
            </h3>
            <p class="text-sm text-gray-500">
                Gestão de fornecedores para: <span
                    class="font-medium text-gray-900">{lenteVirtual.nome}</span
                >
            </p>
        </div>
        <div class="text-right">
            <div
                class="text-xs text-primary-600 font-bold uppercase tracking-wider"
            >
                Custo Atual Otimizado
            </div>
            <div class="text-2xl font-bold text-green-600 font-mono">
                {new Intl.NumberFormat("pt-BR", {
                    style: "currency",
                    currency: "BRL",
                }).format(currentBestOption.custo)}
            </div>
        </div>
    </div>

    <div class="p-0 overflow-x-auto">
        <table class="w-full text-left text-sm">
            <thead class="bg-gray-50 text-gray-500 border-b border-gray-100">
                <tr>
                    <th
                        class="px-6 py-3 font-medium uppercase text-xs tracking-wider"
                        >Laboratório Homologado</th
                    >
                    <th
                        class="px-6 py-3 font-medium uppercase text-xs tracking-wider"
                        >Produto Real (Lab)</th
                    >
                    <th
                        class="px-6 py-3 font-medium text-right uppercase text-xs tracking-wider"
                        >Custo</th
                    >
                    <th
                        class="px-6 py-3 font-medium text-center uppercase text-xs tracking-wider"
                        >Prazo</th
                    >
                    <th
                        class="px-6 py-3 font-medium text-center uppercase text-xs tracking-wider"
                        >Qualidade</th
                    >
                    <th
                        class="px-6 py-3 font-medium text-right uppercase text-xs tracking-wider"
                        >Status</th
                    >
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                {#each sortedOptions as opt, i}
                    <tr
                        class="hover:bg-gray-50 transition-colors {i === 0
                            ? 'bg-green-50/30'
                            : ''}"
                    >
                        <td
                            class="px-6 py-4 font-medium text-gray-900 flex items-center gap-2"
                        >
                            {#if i === 0}
                                <span
                                    class="text-[10px] bg-green-100 text-green-700 px-2 py-0.5 rounded-full font-bold uppercase tracking-wide border border-green-200"
                                >
                                    Atual
                                </span>
                            {/if}
                            {opt.lab_nome}
                        </td>
                        <td class="px-6 py-4 text-gray-600"
                            >{opt.produto_real}</td
                        >
                        <td
                            class="px-6 py-4 text-right font-mono font-medium {i ===
                            0
                                ? 'text-green-700'
                                : 'text-gray-600'}"
                        >
                            {new Intl.NumberFormat("pt-BR", {
                                style: "currency",
                                currency: "BRL",
                            }).format(opt.custo)}
                        </td>
                        <td class="px-6 py-4 text-center">
                            <span
                                class="inline-flex items-center gap-1 px-2 py-1 rounded-md {opt.prazo >
                                7
                                    ? 'bg-red-50 text-red-700'
                                    : 'bg-gray-100 text-gray-700'}"
                            >
                                <Clock size={14} />
                                {opt.prazo}d
                            </span>
                        </td>
                        <td class="px-6 py-4 text-center">
                            <div class="flex items-center justify-center gap-1">
                                <span
                                    class="font-bold {opt.quality_score >= 9
                                        ? 'text-green-600'
                                        : 'text-yellow-600'}"
                                    >{opt.quality_score}</span
                                >
                                <span class="text-gray-400 text-xs">/10</span>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-right">
                            {#if opt.status === "SUSPENSO"}
                                <span
                                    class="inline-flex items-center gap-1 text-red-600 font-medium text-xs bg-red-50 px-2 py-1 rounded-full border border-red-100"
                                >
                                    <AlertTriangle size={12} /> Suspenso
                                </span>
                            {:else if i === 0}
                                <span
                                    class="inline-flex items-center gap-1 text-green-600 font-bold text-xs bg-green-50 px-2 py-1 rounded-full border border-green-200"
                                >
                                    <TrendingDown size={12} /> Menor Custo
                                </span>
                            {:else}
                                <span
                                    class="inline-flex items-center gap-1 text-gray-500 font-medium text-xs bg-gray-100 px-2 py-1 rounded-full border border-gray-200"
                                >
                                    <CheckCircle size={12} /> Homologado
                                </span>
                            {/if}
                        </td>
                    </tr>
                {/each}
            </tbody>
        </table>
    </div>

    <div
        class="bg-gray-50 p-4 border-t border-gray-200 text-xs text-center text-gray-500"
    >
        <p>
            O <strong>SIS Lens</strong> redireciona automaticamente os pedidos
            para o <strong>{currentBestOption.lab_nome}</strong> para maximizar a
            margem.
        </p>
    </div>
</div>
