<!--
  📋 Detalhes da Lente
  Todas as informações completas do banco de dados
-->
<script lang="ts">
  import { page } from "$app/stores";
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";
  import { CatalogoAPI } from "$lib/api/catalogo-api";
  import type { LenteCatalogo } from "$lib/types/database-views";

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // State
  let lente: LenteCatalogo | null = null;
  let loading = true;
  let error = "";
  let isEditing = false;
  let saving = false;
  let editForm = {
    preco_venda: 0,
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

      const resultado = await CatalogoAPI.obterLente(lenteId);

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
        preco_venda: lente.preco_venda_sugerido || 0,
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
      const res = await CatalogoAPI.atualizarLente({
        id: lente.id,
        preco_custo: Number(editForm.preco_custo),
        preco_venda: Number(editForm.preco_venda),
        ativo: editForm.ativo,
      });

      if (res.success) {
        isEditing = false;
        await carregarDetalhes(); // Recarregar para confirmar
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
    if (!valor && valor !== 0) return "-";
    return `R$ ${valor.toFixed(2)}`;
  }

  function formatarBoolean(valor: boolean): string {
    return valor ? "✅ Sim" : "❌ Não";
  }
</script>

<svelte:head>
  <title>{lente?.nome_lente || "Detalhes da Lente"} - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
  {#if loading}
    <div class="flex flex-col justify-center items-center py-20">
      <LoadingSpinner size="lg" />
      <p class="mt-4 text-slate-600">Carregando detalhes...</p>
    </div>
  {:else if error || !lente}
    <div class="bg-red-50 border-2 border-red-200 rounded-2xl p-8 text-center">
      <div class="text-5xl mb-4">⚠️</div>
      <p class="text-red-800 text-lg font-medium mb-4">{error}</p>
      <Button variant="primary" on:click={() => goto("/catalogo")}>
        Voltar ao Catálogo
      </Button>
    </div>
  {:else}
    <!-- Botão Voltar e Editar -->
    <div class="mb-6 flex justify-between items-center">
      <Button variant="secondary" on:click={() => goto("/catalogo")}>
        ← Voltar ao Catálogo
      </Button>
      {#if !isEditing}
        <Button variant="outline" on:click={toggleEdit}>
          ✏️ Editar Valoes
        </Button>
      {:else}
        <div class="flex gap-2">
          <Button variant="ghost" on:click={toggleEdit} disabled={saving}>
            Cancelar
          </Button>
          <Button variant="primary" on:click={salvarEdicao} disabled={saving}>
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
            <Badge
              variant={lente.categoria.includes("premium") ? "gold" : "neutral"}
            >
              {lente.categoria.replace("_", " ")}
            </Badge>
            {#if lente.destaque}
              <Badge variant="gold">⭐ Destaque</Badge>
            {/if}
            {#if isEditing}
              <label
                class="flex items-center gap-2 cursor-pointer bg-white/50 px-3 py-1 rounded-full border border-slate-200"
              >
                <input
                  type="checkbox"
                  bind:checked={editForm.ativo}
                  class="form-checkbox text-indigo-600 rounded"
                />
                <span class="text-sm font-medium">Ativo no Catálogo</span>
              </label>
            {/if}
          </div>

          <h1 class="text-3xl md:text-4xl font-bold text-slate-900 mb-2">
            {lente.nome_lente}
          </h1>

          {#if lente.grupo_nome && lente.grupo_canonico_id}
            <p class="text-lg text-slate-600 mb-4">
              📦 Grupo Canônico:
              <a
                href="/catalogo/standard/{lente.grupo_canonico_id}"
                class="text-indigo-600 hover:text-indigo-800 hover:underline font-medium transition-colors"
              >
                {lente.grupo_nome}
              </a>
            </p>
          {/if}
          {#if lente.fornecedor_razao_social}
            <p class="text-sm text-slate-500">
              Fornecedor: {lente.fornecedor_razao_social} ({lente.fornecedor_cnpj ||
                "CNPJ não informado"})
            </p>
          {/if}
        </div>

        <div class="text-right">
          <div
            class="bg-gradient-to-br from-indigo-600 to-purple-600 text-white rounded-2xl p-6 min-w-[200px]"
          >
            {#if !isEditing}
              <div class="text-sm opacity-90 mb-1">Preço Sugerido</div>
              <div class="text-3xl font-bold">
                {formatarPreco(lente.preco_venda_sugerido)}
              </div>
              <div class="text-xs opacity-75 mt-2">
                Custo: {formatarPreco(lente.preco_custo)}
              </div>
              {#if lente.margem_lucro}
                <div class="text-xs opacity-75">
                  Margem: {lente.margem_lucro.toFixed(1)}%
                </div>
              {/if}
            {:else}
              <div class="text-sm opacity-90 mb-1">Preço Sugerido (R$)</div>
              <input
                type="number"
                step="0.01"
                bind:value={editForm.preco_venda}
                class="w-full bg-white/20 border border-white/30 rounded px-2 py-1 text-white placeholder-white/50 mb-2 font-bold text-xl focus:outline-none focus:ring-2 focus:ring-white/50"
              />

              <div class="text-xs opacity-90 mb-1 mt-2">Custo (R$)</div>
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

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8 mt-6">
      <!-- Tipo e Material -->
      <div class="glass-panel p-6 rounded-xl">
        <h3 class="font-semibold text-slate-900 mb-4 flex items-center gap-2">
          👓 Tipo e Material
        </h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-600">Tipo:</span>
            <span class="font-medium capitalize"
              >{lente.tipo_lente.replace("_", " ")}</span
            >
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Material:</span>
            <span class="font-medium">{lente.material}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Índice Refração:</span>
            <span class="font-medium">{lente.indice_refracao}</span>
          </div>
        </div>
      </div>

      <!-- Dimensões -->
      <div class="glass-panel p-6 rounded-xl">
        <h3 class="font-semibold text-slate-900 mb-4 flex items-center gap-2">
          📏 Dimensões
        </h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-600">Diâmetro:</span>
            <span class="font-medium"
              >{lente.diametro ? `${lente.diametro} mm` : "-"}</span
            >
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Espessura Central:</span>
            <span class="font-medium"
              >{lente.espessura_central
                ? `${lente.espessura_central} mm`
                : "-"}</span
            >
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Peso Aproximado:</span>
            <span class="font-medium"
              >{lente.peso ? `${lente.peso} g` : "-"}</span
            >
          </div>
        </div>
      </div>

      <!-- Faixas Ópticas -->
      <div class="glass-panel p-6 rounded-xl">
        <h3 class="font-semibold text-slate-900 mb-4 flex items-center gap-2">
          🎯 Faixas Ópticas
        </h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-600">Esférico:</span>
            <span class="font-medium">
              {lente.grau_esferico_min != null &&
              lente.grau_esferico_max != null
                ? `${lente.grau_esferico_min} a ${lente.grau_esferico_max}`
                : "-"}
            </span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Cilíndrico:</span>
            <span class="font-medium">
              {lente.grau_cilindrico_min != null &&
              lente.grau_cilindrico_max != null
                ? `${lente.grau_cilindrico_min} a ${lente.grau_cilindrico_max}`
                : "-"}
            </span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Adição:</span>
            <span class="font-medium">
              {lente.adicao_min != null && lente.adicao_max != null
                ? `${lente.adicao_min} a ${lente.adicao_max}`
                : "-"}
            </span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">DNP:</span>
            <span class="font-medium">
              {lente.dnp_min != null && lente.dnp_max != null
                ? `${lente.dnp_min} a ${lente.dnp_max} mm`
                : "-"}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Tratamentos -->
    <SectionHeader
      title="✨ Tratamentos e Proteções"
      subtitle="Tecnologias aplicadas"
    />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.tem_ar ? "✅" : "❌"}</span>
          <span class="text-sm">Anti-Reflexo</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.tem_antirrisco ? "✅" : "❌"}</span>
          <span class="text-sm">Anti-Risco</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.tem_hidrofobico ? "✅" : "❌"}</span>
          <span class="text-sm">Hidrofóbico</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">❌</span>
          <span class="text-sm">Anti-Embaçante</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.tem_blue ? "✅" : "❌"}</span>
          <span class="text-sm">Blue Light</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.tem_uv ? "✅" : "❌"}</span>
          <span class="text-sm">UV400</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl"
            >{lente.tratamento_foto !== "nenhum" ? "✅" : "❌"}</span
          >
          <span class="text-sm">Fotossensível ({lente.tratamento_foto})</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.tem_polarizado ? "✅" : "❌"}</span>
          <span class="text-sm">Polarizado</span>
        </div>
      </div>
    </div>

    <!-- Tecnologias -->
    <SectionHeader title="🚀 Tecnologias" subtitle="Recursos avançados" />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="flex items-center gap-2">
          <span class="text-2xl">❌</span>
          <span class="text-sm">Digital</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">❌</span>
          <span class="text-sm">Free-Form</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">❌</span>
          <span class="text-sm">Indoor</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">❌</span>
          <span class="text-sm">Drive</span>
        </div>
      </div>
    </div>

    <!-- Informações do Fornecedor -->
    {#if lente.fornecedor_nome}
      <SectionHeader title="🏢 Informações do Fornecedor" />
      <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <div class="text-sm text-slate-600 mb-1">Fornecedor</div>
            <div class="text-lg font-semibold">{lente.fornecedor_nome}</div>
          </div>
          {#if lente.fornecedor_razao_social}
            <div>
              <div class="text-sm text-slate-600 mb-1">Razão Social</div>
              <div class="text-lg font-semibold">
                {lente.fornecedor_razao_social}
              </div>
            </div>
          {/if}
          {#if lente.fornecedor_cnpj}
            <div>
              <div class="text-sm text-slate-600 mb-1">CNPJ</div>
              <div class="font-mono text-sm">{lente.fornecedor_cnpj}</div>
            </div>
          {/if}
        </div>
      </div>
    {/if}

    <!-- Logística e Entrega -->
    <SectionHeader title="📦 Logística e Entrega" />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div>
          <div class="text-sm text-slate-600 mb-1">Prazo de Entrega</div>
          <div class="text-lg font-semibold">
            {lente.prazo_dias ? `${lente.prazo_dias} dias` : "-"}
          </div>
        </div>
        <div>
          <div class="text-sm text-slate-600 mb-1">Peso Aproximado</div>
          <div class="text-lg font-semibold">
            {lente.peso ? `${lente.peso} g` : "-"}
          </div>
        </div>
        <div>
          <div class="text-sm text-slate-600 mb-1">Fornecedor</div>
          <div class="text-lg font-semibold">
            {lente.fornecedor_nome || "-"}
          </div>
        </div>
      </div>
    </div>

    <!-- Informações Comerciais -->
    <SectionHeader title="💰 Informações Comerciais" />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div>
          <div class="text-sm text-slate-600 mb-1">SKU Fornecedor</div>
          <div class="font-mono text-sm">{lente.sku_fornecedor || "-"}</div>
        </div>
        {#if lente.codigo_original}
          <div>
            <div class="text-sm text-slate-600 mb-1">Código Original</div>
            <div class="font-mono text-sm">{lente.codigo_original}</div>
          </div>
        {/if}
        <div>
          <div class="text-sm text-slate-600 mb-1">Custo</div>
          <div class="text-lg font-semibold">
            {formatarPreco(lente.preco_custo)}
          </div>
        </div>
        <div>
          <div class="text-sm text-slate-600 mb-1">Status</div>
          <div>
            <Badge variant={lente.ativo ? "success" : "neutral"}>
              {lente.ativo ? "Ativo" : "Inativo"}
            </Badge>
          </div>
        </div>
      </div>
    </div>

    <!-- Datas -->
    <div class="glass-panel p-4 rounded-xl mb-8 bg-slate-50">
      <div class="grid grid-cols-2 gap-4 text-xs text-slate-600">
        <div>
          <span class="font-medium">Cadastro:</span>
          {new Date(lente.created_at).toLocaleDateString("pt-BR")}
        </div>
        <div>
          <span class="font-medium">Atualização:</span>
          {new Date(lente.updated_at).toLocaleDateString("pt-BR")}
        </div>
      </div>
    </div>

    <!-- Ações -->
    <div class="flex gap-4 justify-center">
      <Button variant="secondary" on:click={() => goto("/catalogo")}>
        ← Voltar ao Catálogo
      </Button>
      <Button variant="primary">🛒 Adicionar ao Pedido</Button>
    </div>
  {/if}
</Container>
