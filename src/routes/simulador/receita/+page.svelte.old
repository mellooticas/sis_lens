<!--
  🧪 Simulador de Busca por Receita
  Interface técnica para validar a função RPC `buscar_lentes_por_receita`
-->
<script lang="ts">
    import { CatalogoAPI } from "$lib/api/catalogo-api";
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
    import Badge from "$lib/components/ui/Badge.svelte";

    // Estado do formulário - Espelhando os parâmetros da função SQL
    let parametros = {
        esferico: -2.0,
        cilindrico: -0.5,
        eixo: 180,
        adicao: 0.0,
        tipo: "visao_simples" as "visao_simples" | "multifocal" | "bifocal",
    };

    // Estado da resposta
    let loading = false;
    let resultados: any[] = [];
    let tempoExecucao = 0;
    let erro = "";
    let sqlQuery = "";

    async function executarTeste() {
        loading = true;
        erro = "";
        resultados = [];
        const inicio = performance.now();

        // Simulação da query SQL que o backend executa
        sqlQuery = `SELECT * FROM public.buscar_lentes_por_receita(
  p_esferico => ${parametros.esferico},
  p_cilindrico => ${parametros.cilindrico},
  p_adicao => ${parametros.adicao},
  p_tipo_lente => '${parametros.tipo}'
);`;

        try {
            // Chamada real ao banco via API
            const resp = await CatalogoAPI.buscarLentesPorReceita({
                receita: {
                    esferico: parametros.esferico,
                    cilindrico: parametros.cilindrico,
                    eixo: parametros.eixo,
                    adicao: parametros.adicao,
                },
                tipo_lente: parametros.tipo,
                limite: 50, // Testando com limite alto
            });

            if (resp.success && resp.data) {
                resultados = resp.data.dados;
            } else {
                erro = "A função retornou sucesso=false ou dados vazios.";
            }
        } catch (e: any) {
            erro = e.message || "Erro desconhecido na execução da RPC";
        } finally {
            const fim = performance.now();
            tempoExecucao = fim - inicio;
            loading = false;
        }
    }

    function formatarMoeda(valor: number) {
        return new Intl.NumberFormat("pt-BR", {
            style: "currency",
            currency: "BRL",
        }).format(valor);
    }
</script>

<svelte:head>
    <title>Simulador SQL: Lentes por Receita - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
    <PageHero
        badge="🧪 Laboratório de Dados"
        title="Simulador de Compatibilidade"
        subtitle="Teste direto da função de banco de dados: buscar_lentes_por_receita()"
    />

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mt-8">
        <!-- Painel de Parâmetros (Input) -->
        <div class="glass-panel p-6 rounded-xl h-fit">
            <h3
                class="text-lg font-bold text-neutral-900 dark:text-white mb-4 flex items-center gap-2"
            >
                📥 Parâmetros de Entrada
            </h3>

            <div class="space-y-4">
                <div>
                    <label
                        class="block text-sm font-medium text-neutral-600 dark:text-neutral-400 mb-1"
                        >Tipo de Lente</label
                    >
                    <select bind:value={parametros.tipo} class="input w-full">
                        <option value="visao_simples">Visão Simples</option>
                        <option value="multifocal">Multifocal</option>
                        <option value="bifocal">Bifocal</option>
                    </select>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label
                            class="block text-sm font-medium text-neutral-600 dark:text-neutral-400 mb-1"
                            >Esférico</label
                        >
                        <input
                            type="number"
                            step="0.25"
                            bind:value={parametros.esferico}
                            class="input w-full"
                        />
                    </div>
                    <div>
                        <label
                            class="block text-sm font-medium text-neutral-600 dark:text-neutral-400 mb-1"
                            >Cilíndrico</label
                        >
                        <input
                            type="number"
                            step="0.25"
                            bind:value={parametros.cilindrico}
                            class="input w-full"
                        />
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label
                            class="block text-sm font-medium text-neutral-600 dark:text-neutral-400 mb-1"
                            >Eixo</label
                        >
                        <input
                            type="number"
                            step="1"
                            bind:value={parametros.eixo}
                            class="input w-full"
                        />
                    </div>
                    <div>
                        <label
                            class="block text-sm font-medium text-neutral-600 dark:text-neutral-400 mb-1"
                            >Adição</label
                        >
                        <input
                            type="number"
                            step="0.25"
                            bind:value={parametros.adicao}
                            class="input w-full"
                            disabled={parametros.tipo === "visao_simples"}
                        />
                    </div>
                </div>

                <div class="pt-4">
                    <Button
                        variant="primary"
                        fullWidth
                        on:click={executarTeste}
                        disabled={loading}
                    >
                        {#if loading}
                            <LoadingSpinner size="sm" /> Processando...
                        {:else}
                            🚀 Executar RPC
                        {/if}
                    </Button>
                </div>
            </div>

            <!-- SQL Preview -->
            <div class="mt-6 p-3 bg-neutral-900 rounded-lg overflow-x-auto">
                <code class="text-xs text-green-400 font-mono whitespace-pre"
                    >{sqlQuery || "-- Aguardando execução..."}</code
                >
            </div>
        </div>

        <!-- Painel de Resultados (Output) -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Métricas da Execução -->
            {#if resultados.length > 0 || erro}
                <div class="grid grid-cols-3 gap-4">
                    <div class="glass-panel p-4 rounded-xl text-center">
                        <div
                            class="text-xs text-neutral-500 uppercase font-bold"
                        >
                            Status
                        </div>
                        <div
                            class="text-lg font-bold {erro
                                ? 'text-red-500'
                                : 'text-green-500'}"
                        >
                            {erro ? "ERRO" : "SUCESSO"}
                        </div>
                    </div>
                    <div class="glass-panel p-4 rounded-xl text-center">
                        <div
                            class="text-xs text-neutral-500 uppercase font-bold"
                        >
                            Lentes Compatíveis
                        </div>
                        <div
                            class="text-lg font-bold text-neutral-900 dark:text-white"
                        >
                            {resultados.length}
                        </div>
                    </div>
                    <div class="glass-panel p-4 rounded-xl text-center">
                        <div
                            class="text-xs text-neutral-500 uppercase font-bold"
                        >
                            Tempo (Client)
                        </div>
                        <div class="text-lg font-bold text-blue-500">
                            {tempoExecucao.toFixed(0)} ms
                        </div>
                    </div>
                </div>
            {/if}

            {#if erro}
                <div
                    class="bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300 p-4 rounded-xl border border-red-200 dark:border-red-800"
                >
                    <strong>Erro na execução:</strong>
                    {erro}
                </div>
            {/if}

            <!-- Tabela de Dados Bruta (Para Validação Técnica) -->
            {#if resultados.length > 0}
                <div
                    class="glass-panel rounded-xl overflow-hidden shadow-xl border border-neutral-200 dark:border-neutral-700"
                >
                    <div class="overflow-x-auto max-h-[600px]">
                        <table
                            class="w-full text-left text-sm whitespace-nowrap"
                        >
                            <thead
                                class="bg-neutral-100 dark:bg-neutral-800 sticky top-0 z-10 font-bold text-neutral-700 dark:text-neutral-300"
                            >
                                <tr>
                                    <th
                                        class="p-3 border-b border-r dark:border-neutral-700"
                                        >Lente (Nome Comercial)</th
                                    >
                                    <th
                                        class="p-3 border-b border-r dark:border-neutral-700"
                                        >Marca</th
                                    >
                                    <th
                                        class="p-3 border-b border-r dark:border-neutral-700"
                                        >Material / Índice</th
                                    >
                                    <th
                                        class="p-3 border-b border-r dark:border-neutral-700 bg-blue-50 dark:bg-blue-900/20"
                                        >Preço Tabela</th
                                    >
                                    <th
                                        class="p-3 border-b border-r dark:border-neutral-700"
                                        >Tratamentos</th
                                    >
                                    <th
                                        class="p-3 border-b dark:border-neutral-700"
                                        >Range (Validação)</th
                                    >
                                </tr>
                            </thead>
                            <tbody
                                class="divide-y divide-neutral-200 dark:divide-neutral-700"
                            >
                                {#each resultados as row}
                                    <tr
                                        class="hover:bg-neutral-50 dark:hover:bg-neutral-800 transition-colors"
                                    >
                                        <td
                                            class="p-3 border-r dark:border-neutral-700 font-medium text-neutral-900 dark:text-white"
                                        >
                                            {row.nome_comercial}
                                            {#if row.categoria === "premium"}
                                                <Badge
                                                    variant="gold"
                                                    size="sm"
                                                    class="ml-2">Premium</Badge
                                                >
                                            {/if}
                                        </td>
                                        <td
                                            class="p-3 border-r dark:border-neutral-700"
                                            >{row.marca_nome}</td
                                        >
                                        <td
                                            class="p-3 border-r dark:border-neutral-700"
                                        >
                                            {row.material}
                                            <span class="text-neutral-400"
                                                >|</span
                                            >
                                            {row.indice_refracao}
                                        </td>
                                        <td
                                            class="p-3 border-r dark:border-neutral-700 bg-blue-50/50 dark:bg-blue-900/10 font-bold text-green-600"
                                        >
                                            {row.preco_tabela
                                                ? formatarMoeda(
                                                      row.preco_tabela,
                                                  )
                                                : "-"}
                                        </td>
                                        <td
                                            class="p-3 border-r dark:border-neutral-700 text-xs"
                                        >
                                            <div
                                                class="flex gap-1 flex-wrap max-w-[200px]"
                                            >
                                                {#if row.ar}
                                                    <span
                                                        class="px-1.5 py-0.5 rounded bg-blue-100 text-blue-700"
                                                        >AR</span
                                                    >
                                                {/if}
                                                {#if row.blue}
                                                    <span
                                                        class="px-1.5 py-0.5 rounded bg-cyan-100 text-cyan-700"
                                                        >Blue</span
                                                    >
                                                {/if}
                                                {#if row.fotossensivel}
                                                    <span
                                                        class="px-1.5 py-0.5 rounded bg-orange-100 text-orange-700"
                                                        >Foto</span
                                                    >
                                                {/if}
                                            </div>
                                        </td>
                                        <td
                                            class="p-3 text-xs text-neutral-500 font-mono"
                                        >
                                            Esf: [{row.esferico_min} a {row.esferico_max}]<br
                                            />
                                            Cil: [{row.cilindrico_min} a {row.cilindrico_max}]
                                        </td>
                                    </tr>
                                {/each}
                            </tbody>
                        </table>
                    </div>
                </div>
            {:else if !loading && !erro}
                <div class="text-center py-20 opacity-50">
                    <div class="text-6xl mb-4">🧪</div>
                    <p class="text-lg">Aguardando execução do teste...</p>
                </div>
            {/if}
        </div>
    </div>
</Container>
