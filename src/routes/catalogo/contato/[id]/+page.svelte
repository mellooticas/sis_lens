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
    let isEditing = false;
    let saving = false;
    let editForm = {
        preco_tabela: 0,
        preco_custo: 0,
        ativo: true,
    };

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
                resetForm();
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

    function resetForm() {
        if (lente) {
            editForm = {
                preco_tabela: lente.preco_tabela || 0,
                preco_custo: lente.preco_custo || 0,
                ativo: lente.ativo,
            };
        }
    }

    function toggleEdit() {
        isEditing = !isEditing;
        if (!isEditing) resetForm();
    }

    async function salvarEdicao() {
        if (!lente) return;

        try {
            saving = true;
            const res = await ContactLensAPI.atualizarLente({
                id: lente.id,
                preco_custo: Number(editForm.preco_custo),
                preco_tabela: Number(editForm.preco_tabela),
                ativo: editForm.ativo,
            });

            if (res.success) {
                isEditing = false;
                await carregarDetalhes();
            } else {
                alert("Erro ao salvar: " + res.error);
            }
        } catch (e) {
            console.error(e);
            alert("Erro ao salvar alterações");
        } finally {
            saving = false;
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
        <!-- Botão Voltar e Editar -->
        <div class="mb-6 flex justify-between items-center">
            <Button
                variant="secondary"
                on:click={() => goto("/catalogo/contato")}
            >
                ← Voltar ao Catálogo
            </Button>
            {#if !isEditing}
                <Button variant="outline" on:click={toggleEdit}>
                    ✏️ Editar Valores
                </Button>
            {:else}
                <div class="flex gap-2">
                    <Button
                        variant="ghost"
                        on:click={toggleEdit}
                        disabled={saving}
                    >
                        Cancelar
                    </Button>
                    <Button
                        variant="primary"
                        on:click={salvarEdicao}
                        disabled={saving}
                    >
                        {saving ? "Salvando..." : "Salvar Alterações"}
                    </Button>
                </div>
            {/if}
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
                        {#if isEditing}
                            <label
                                class="flex items-center gap-2 cursor-pointer bg-white/50 px-3 py-1 rounded-full border border-slate-200 ml-2"
                            >
                                <input
                                    type="checkbox"
                                    bind:checked={editForm.ativo}
                                    class="form-checkbox text-indigo-600 rounded"
                                />
                                <span class="text-sm font-medium"
                                    >Ativo no Catálogo</span
                                >
                            </label>
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
                        {#if !isEditing}
                            <div class="text-sm opacity-90 mb-1">
                                Preço Sugerido
                            </div>
                            <div class="text-3xl font-bold">
                                {formatarPreco(lente.preco_tabela)}
                            </div>
                            <div class="text-xs opacity-75 mt-2">
                                Custo: {formatarPreco(lente.preco_custo)}
                            </div>
                        {:else}
                            <div class="text-sm opacity-90 mb-1">
                                Preço Sugerido (R$)
                            </div>
                            <input
                                type="number"
                                step="0.01"
                                bind:value={editForm.preco_tabela}
                                class="w-full bg-white/20 border border-white/30 rounded px-2 py-1 text-white placeholder-white/50 mb-2 font-bold text-xl focus:outline-none focus:ring-2 focus:ring-white/50"
                            />

                            <div class="text-xs opacity-90 mb-1 mt-2">
                                Custo (R$)
                            </div>
                            <input
                                type="number"
                                step="0.01"
                                bind:value={editForm.preco_custo}
                                class="w-full bg-white/20 border border-white/30 rounded px-2 py-1 text-sm text-white focus:outline-none focus:ring-2 focus:ring-white/50"
                            />
                        {/if}
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
