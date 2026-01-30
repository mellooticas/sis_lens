<script lang="ts">
    import { page } from "$app/stores";
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";
    import { ContactLensAPI } from "$lib/api/contact-lens-api";
    import type { LenteContato } from "$lib/types/contact-lens";

    // Componentes padronizados
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import Badge from "$lib/components/ui/Badge.svelte";
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

    // State
    let lente: LenteContato | null = null;
    let loading = true;
    let error = "";

    const lenteId = $page.params.id;

    onMount(async () => {
        await carregarDetalhes();
    });

    async function carregarDetalhes() {
        try {
            loading = true;
            error = "";

            const resultado = await ContactLensAPI.obterLente(lenteId);

            if (resultado.success && resultado.data) {
                lente = resultado.data;
            } else {
                error = resultado.error || "Lente não encontrada";
            }
        } catch (err) {
            error = "Erro ao carregar detalhes";
            console.error("Erro:", err);
        } finally {
            loading = false;
        }
    }

    function formatarPreco(valor: number | null): string {
        if (!valor) return "-";
        return new Intl.NumberFormat("pt-BR", {
            style: "currency",
            currency: "BRL",
        }).format(valor);
    }
</script>

<svelte:head>
    <title>{lente?.nome_produto || "Detalhes da Lente"} - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
    {#if loading}
        <div class="flex flex-col justify-center items-center py-20">
            <LoadingSpinner size="lg" />
            <p class="mt-4 text-slate-600">Carregando detalhes...</p>
        </div>
    {:else if error || !lente}
        <div
            class="bg-red-50 border-2 border-red-200 rounded-2xl p-8 text-center"
        >
            <div class="text-5xl mb-4">⚠️</div>
            <p class="text-red-800 text-lg font-medium mb-4">{error}</p>
            <Button
                variant="primary"
                on:click={() => goto("/catalogo/contato")}
            >
                Voltar ao Catálogo
            </Button>
        </div>
    {:else}
        <!-- Botão Voltar -->
        <div class="mb-6">
            <Button
                variant="secondary"
                on:click={() => goto("/catalogo/contato")}
            >
                ← Voltar ao Catálogo
            </Button>
        </div>

        <!-- Header -->
        <div class="glass-panel rounded-2xl p-8 mb-8">
            <div
                class="flex flex-col md:flex-row md:items-start md:justify-between gap-4"
            >
                <div class="flex-1">
                    <div class="flex flex-wrap gap-2 mb-4">
                        <Badge variant="primary">{lente.marca_nome}</Badge>
                        <Badge variant="neutral">
                            {lente.tipo_lente}
                        </Badge>
                        {#if lente.finalidade}
                            <Badge variant="gold"
                                >{lente.finalidade.replace("_", " ")}</Badge
                            >
                        {/if}
                    </div>

                    <h1
                        class="text-3xl md:text-4xl font-bold text-slate-900 mb-2"
                    >
                        {lente.nome_produto}
                    </h1>

                    {#if lente.fornecedor_nome}
                        <p class="text-sm text-slate-500">
                            Fornecedor: {lente.fornecedor_nome}
                        </p>
                    {/if}
                </div>

                <div class="text-right">
                    <div
                        class="bg-gradient-to-br from-indigo-600 to-purple-600 text-white rounded-2xl p-6 min-w-[200px]"
                    >
                        <div class="text-sm opacity-90 mb-1">
                            Preço Sugerido
                        </div>
                        <div class="text-3xl font-bold">
                            {formatarPreco(lente.preco_tabela)}
                        </div>
                        <div class="text-xs opacity-75 mt-2">
                            Custo: {formatarPreco(lente.preco_custo)}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Informações Técnicas -->
        <SectionHeader
            title="🔬 Especificações Técnicas"
            subtitle="Características ópticas e técnicas"
        />

        <div
            class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8 mt-6"
        >
            <!-- Material e Características -->
            <div class="glass-panel p-6 rounded-xl">
                <h3
                    class="font-semibold text-slate-900 mb-4 flex items-center gap-2"
                >
                    👓 Características
                </h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-slate-600">Material:</span>
                        <span class="font-medium">{lente.material}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-600">Hidratação:</span>
                        <span class="font-medium"
                            >{lente.conteudo_agua
                                ? lente.conteudo_agua + "%"
                                : "-"}</span
                        >
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-600">DK/t (Oxigenação):</span>
                        <span class="font-medium">{lente.dk_t || "-"}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-600">Descarte:</span>
                        <span class="font-medium capitalize"
                            >{lente.tipo_lente}</span
                        >
                    </div>
                </div>
            </div>

            <!-- Dimensões -->
            <div class="glass-panel p-6 rounded-xl">
                <h3
                    class="font-semibold text-slate-900 mb-4 flex items-center gap-2"
                >
                    📏 Dimensões
                </h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-slate-600">Curva Base:</span>
                        <span class="font-medium"
                            >{lente.curva_base || "-"}</span
                        >
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-600">Diâmetro:</span>
                        <span class="font-medium">{lente.diametro || "-"}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-600">Unid/Caixa:</span>
                        <span class="font-medium"
                            >{lente.unidades_por_caixa || "-"}</span
                        >
                    </div>
                </div>
            </div>

            <!-- Faixas Ópticas -->
            <div class="glass-panel p-6 rounded-xl">
                <h3
                    class="font-semibold text-slate-900 mb-4 flex items-center gap-2"
                >
                    🎯 Grade Disponível
                </h3>
                <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                        <span class="text-slate-600">Esférico:</span>
                        <span class="font-medium">
                            {lente.esferico_min > 0
                                ? "+"
                                : ""}{lente.esferico_min} a {lente.esferico_max >
                            0
                                ? "+"
                                : ""}{lente.esferico_max}
                        </span>
                    </div>
                    {#if lente.cilindrico_min != 0}
                        <div class="flex justify-between">
                            <span class="text-slate-600">Cilíndrico:</span>
                            <span class="font-medium">
                                {lente.cilindrico_min} a {lente.cilindrico_max}
                            </span>
                        </div>
                    {/if}
                    {#if lente.adicao_max}
                        <div class="flex justify-between">
                            <span class="text-slate-600">Adição:</span>
                            <span class="font-medium">
                                +{lente.adicao_min} a +{lente.adicao_max}
                            </span>
                        </div>
                    {/if}
                </div>
            </div>
        </div>

        <!-- Informações Extras -->
        {#if lente.descricao_curta || lente.metadata}
            <SectionHeader title="📝 Descrição" />
            <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
                <p class="text-slate-600 leading-relaxed">
                    {lente.descricao_curta || "Sem descrição disponível."}
                </p>
            </div>
        {/if}

        <!-- Datas -->
        <div class="glass-panel p-4 rounded-xl mb-8 bg-slate-50">
            <div class="grid grid-cols-2 gap-4 text-xs text-slate-600">
                <div>
                    <span class="font-medium">Cadastro:</span>
                    {new Date(lente.created_at).toLocaleDateString("pt-BR")}
                </div>
                <div>
                    <span class="font-medium">SKU:</span>
                    {lente.sku}
                </div>
            </div>
        </div>
    {/if}
</Container>
