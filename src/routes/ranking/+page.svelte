<script lang="ts">
  /**
   * 🎨 Página de Ranking de Lentes - Interface Premium
   * Versão: 2.1 - Com tratamento de erros
   */

  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import type { PageData } from "./$types";

  // === LAYOUT ===
  import Header from "$lib/components/layout/Header.svelte";

  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

  // === UI ===
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import Table from "$lib/components/ui/Table.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import Breadcrumbs from "$lib/components/ui/Breadcrumbs.svelte";

  // === CARDS ===
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";

  // === FEEDBACK ===
  import Modal from "$lib/components/feedback/Modal.svelte";
  import LoadingOverlay from "$lib/components/feedback/LoadingOverlay.svelte";

  export let data: PageData;

  // === ESTADO LOCAL ===
  let isLoading = false;
  let selectedOption: any = null;
  let showDecisionModal = false;
  let showFiltersModal = false;
  let showComparisonModal = false;
  let observacoes = "";
  let selectedForComparison: any[] = [];

  // === DADOS REATIVOS COM VALORES DEFAULT ===
  $: ranking = data?.ranking || [];
  $: top3 = data?.top3 || [];
  $: outros = data?.outros || [];
  $: criterio = data?.criterio || "NORMAL";
  $: lente_info = data?.lente_info;
  $: estatisticas = data?.estatisticas;
  $: filtros = data?.filtros || {};
  $: tem_filtros_ativos = data?.tem_filtros_ativos || false;

  // Criterio atual (sincronizado com data)
  let criterioAtual = criterio;

  // === CRITÉRIOS DISPONÍVEIS ===
  const criterios = [
    {
      id: "NORMAL",
      nome: "Custo-Benefício",
      descricao: "Prioriza melhor preço com qualidade",
      icon: "💰",
      pesos: "Preço: 60% | Prazo: 30% | Qualidade: 10%",
    },
    {
      id: "URGENCIA",
      nome: "Urgência",
      descricao: "Prioriza menor prazo de entrega",
      icon: "⚡",
      pesos: "Prazo: 60% | Preço: 25% | Qualidade: 15%",
    },
    {
      id: "ESPECIAL",
      nome: "Premium",
      descricao: "Prioriza máxima qualidade",
      icon: "⭐",
      pesos: "Qualidade: 60% | Prazo: 25% | Preço: 15%",
    },
  ];

  // === FORMATADORES ===
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(value || 0);
  };

  const formatPercentage = (value: number) => {
    return `${(value || 0).toFixed(1)}%`;
  };

  const formatDays = (days: number) => {
    const d = days || 0;
    return d === 1 ? "1 dia" : `${d} dias`;
  };

  // === NAVEGAÇÃO ===
  const breadcrumbItems = [
    { label: "Início", href: "/" },
    { label: "Buscar", href: "/buscar" },
    { label: "Ranking" },
  ];

  // === FUNÇÕES DE COR ===
  function getCriterioColor(crit: string) {
    switch (crit) {
      case "NORMAL":
        return "success";
      case "URGENCIA":
        return "danger";
      case "ESPECIAL":
        return "gold";
      default:
        return "info";
    }
  }

  function getPosicaoColor(posicao: number): "gold" | "orange" | "primary" {
    if (posicao === 1) return "gold";
    if (posicao === 2) return "orange";
    if (posicao === 3) return "primary";
    return "primary";
  }

  function getScoreColor(score: number): "success" | "warning" | "error" {
    if (score >= 90) return "success";
    if (score >= 70) return "warning";
    return "error";
  }

  function getBadgeVariant(
    badge: string,
  ): "primary" | "success" | "warning" | "orange" | "gold" {
    if (badge.includes("Preço")) return "success";
    if (badge.includes("Expressa")) return "warning";
    if (badge.includes("Qualidade")) return "gold";
    if (badge.includes("Grátis")) return "orange";
    return "primary";
  }

  // === MUDANÇA DE CRITÉRIO ===
  async function mudarCriterio(novoCriterio: string) {
    criterioAtual = novoCriterio;
    const newUrl = new URL($page.url);
    newUrl.searchParams.set("criterio", novoCriterio);
    goto(newUrl.toString());
  }

  // === COMPARAÇÃO ===
  function toggleComparacao(opcao: any) {
    const index = selectedForComparison.findIndex(
      (item) => item.id === opcao.id,
    );
    if (index === -1) {
      if (selectedForComparison.length < 3) {
        selectedForComparison = [...selectedForComparison, opcao];
      }
    } else {
      selectedForComparison = selectedForComparison.filter(
        (item) => item.id !== opcao.id,
      );
    }
  }

  function isSelectedForComparison(opcaoId: string) {
    return selectedForComparison.some((item) => item.id === opcaoId);
  }

  // === DECISÃO ===
  function confirmarDecisao(opcao: any) {
    selectedOption = opcao;
    showDecisionModal = true;
  }

  function fecharModal() {
    showDecisionModal = false;
    selectedOption = null;
  }

  async function processarDecisao() {
    if (!selectedOption) return;

    isLoading = true;
    try {
      await new Promise((resolve) => setTimeout(resolve, 1500));
      goto(`/decisao/${selectedOption.id}`);
    } catch (error) {
      console.error("Erro ao processar decisão:", error);
      alert("Erro ao processar decisão. Tente novamente.");
    } finally {
      isLoading = false;
      fecharModal();
    }
  }

  // === FILTROS COM VALORES DEFAULT ===
  let filtrosAtivos = {
    uf: filtros?.uf || "",
    cidade: filtros?.cidade || "",
    prazo_maximo: filtros?.prazo_maximo || "",
    preco_maximo: filtros?.preco_maximo || "",
  };

  function aplicarFiltros() {
    const newUrl = new URL($page.url);

    if (filtrosAtivos.uf) newUrl.searchParams.set("uf", filtrosAtivos.uf);
    else newUrl.searchParams.delete("uf");

    if (filtrosAtivos.cidade)
      newUrl.searchParams.set("cidade", filtrosAtivos.cidade);
    else newUrl.searchParams.delete("cidade");

    if (filtrosAtivos.prazo_maximo)
      newUrl.searchParams.set("prazo_maximo", filtrosAtivos.prazo_maximo);
    else newUrl.searchParams.delete("prazo_maximo");

    if (filtrosAtivos.preco_maximo)
      newUrl.searchParams.set("preco_maximo", filtrosAtivos.preco_maximo);
    else newUrl.searchParams.delete("preco_maximo");

    showFiltersModal = false;
    goto(newUrl.toString());
  }

  function limparFiltros() {
    filtrosAtivos = { uf: "", cidade: "", prazo_maximo: "", preco_maximo: "" };
    const newUrl = new URL($page.url);
    newUrl.searchParams.delete("uf");
    newUrl.searchParams.delete("cidade");
    newUrl.searchParams.delete("prazo_maximo");
    newUrl.searchParams.delete("preco_maximo");
    showFiltersModal = false;
    goto(newUrl.toString());
  }
</script>

<svelte:head>
  <title>Ranking de Lentes - BestLens</title>
  <meta
    name="description"
    content="Ranking inteligente de fornecedores baseado em critérios customizáveis"
  />
</svelte:head>

<div class="min-h-screen bg-neutral-50 dark:bg-neutral-900 transition-colors">
  <Header currentPage="ranking" />

  <main>
    <Container maxWidth="2xl" padding="lg">
      <!-- Breadcrumbs -->
      <Breadcrumbs items={breadcrumbItems} />

      <!-- Hero Section -->
      <PageHero
        badge="🏆 Sistema de Ranking Inteligente"
        title="Ranking de Fornecedores"
        subtitle="Comparação automática baseada em critérios customizáveis"
        alignment="center"
        maxWidth="xl"
      />

      <!-- Informações da Lente Buscada -->
      {#if lente_info}
        <section class="mt-8">
          <div
            class="bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20 rounded-2xl border border-blue-200 dark:border-blue-800 p-8 shadow-lg"
          >
            <div
              class="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6"
            >
              <div class="flex-1">
                <div class="flex items-center gap-3 mb-3">
                  <span class="text-4xl">🔍</span>
                  <h3
                    class="text-2xl font-bold text-neutral-900 dark:text-neutral-100"
                  >
                    {lente_info.familia || lente_info.sku_canonico}
                  </h3>
                </div>

                <div class="flex flex-wrap gap-2 mb-4">
                  <Badge variant="primary" size="md">
                    {lente_info.tipo_lente || "Lente"}
                  </Badge>
                  <Badge variant="primary" size="md">
                    {lente_info.material || "Material"}
                  </Badge>
                  {#if lente_info.indice_refracao}
                    <Badge variant="primary" size="md">
                      Índice {lente_info.indice_refracao}
                    </Badge>
                  {/if}
                  {#if lente_info.tratamentos && lente_info.tratamentos.length > 0}
                    {#each lente_info.tratamentos as tratamento}
                      <Badge variant="primary" size="sm">
                        {tratamento}
                      </Badge>
                    {/each}
                  {/if}
                </div>

                <div class="text-sm text-neutral-600 dark:text-neutral-400">
                  <strong>SKU:</strong>
                  {lente_info.sku_canonico} ·
                  <strong>Marca:</strong>
                  {lente_info.marca_nome || "N/A"}
                </div>
              </div>

              <div class="flex gap-3">
                <Button
                  variant="secondary"
                  size="md"
                  on:click={() => goto("/buscar")}
                >
                  🔄 Nova Busca
                </Button>
                <Button
                  variant="primary"
                  size="md"
                  on:click={() => (showFiltersModal = true)}
                >
                  🔧 Filtros {tem_filtros_ativos ? "●" : ""}
                </Button>
              </div>
            </div>
          </div>
        </section>
      {/if}

      <!-- Seletor de Critérios -->
      <section class="mt-12">
        <SectionHeader
          title="Critério de Decisão"
          subtitle="Escolha o que é mais importante para você"
        />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          {#each criterios as crit}
            <button
              class="text-left p-6 rounded-xl border-2 transition-all duration-200 {criterioAtual ===
              crit.id
                ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/30 shadow-lg scale-105'
                : 'border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-800 hover:border-blue-300 hover:shadow-md'}"
              on:click={() => mudarCriterio(crit.id)}
            >
              <div class="flex items-center gap-3 mb-3">
                <span class="text-3xl">{crit.icon}</span>
                <h4
                  class="text-lg font-semibold text-neutral-900 dark:text-neutral-100"
                >
                  {crit.nome}
                </h4>
              </div>

              <p class="text-sm text-neutral-600 dark:text-neutral-400 mb-3">
                {crit.descricao}
              </p>

              <div
                class="text-xs text-neutral-500 dark:text-neutral-500 font-mono"
              >
                {crit.pesos}
              </div>

              {#if criterioAtual === crit.id}
                <div class="mt-3">
                  <Badge variant="primary" size="sm">✓ Selecionado</Badge>
                </div>
              {/if}
            </button>
          {/each}
        </div>
      </section>

      <!-- Estatísticas do Ranking -->
      {#if estatisticas}
        <section class="mt-12">
          <SectionHeader title="Estatísticas da Comparação" />

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatsCard
              title="Fornecedores"
              value={estatisticas.total_fornecedores}
              icon="🏢"
              color="blue"
            />

            <StatsCard
              title="Melhor Preço"
              value={formatCurrency(estatisticas.melhor_preco)}
              icon="💰"
              color="green"
            />

            <StatsCard
              title="Menor Prazo"
              value={formatDays(estatisticas.menor_prazo)}
              icon="⚡"
              color="orange"
            />

            <StatsCard
              title="Economia Máxima"
              value={formatCurrency(estatisticas.economia_maxima)}
              icon="📈"
              color="gold"
            />
          </div>
        </section>
      {/if}

      <!-- TOP 3 - Cards Destacados -->
      {#if top3 && top3.length > 0}
        <section class="mt-12">
          <SectionHeader
            title="🏆 Top 3 Fornecedores"
            subtitle="Melhores opções baseadas no seu critério"
          />

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {#each top3 as opcao, index}
              <div class="relative">
                <!-- Badge de Posição -->
                <div class="absolute -top-4 -right-4 z-10">
                  <div
                    class="w-12 h-12 rounded-full bg-gradient-to-br {index === 0
                      ? 'from-yellow-400 to-yellow-600'
                      : index === 1
                        ? 'from-gray-400 to-gray-600'
                        : 'from-orange-400 to-orange-600'} flex items-center justify-center shadow-xl"
                  >
                    <span class="text-white font-bold text-lg"
                      >{opcao.posicao}º</span
                    >
                  </div>
                </div>

                <!-- Card -->
                <div
                  class="bg-white dark:bg-neutral-800 rounded-2xl border-2 {index ===
                  0
                    ? 'border-yellow-500 shadow-2xl'
                    : index === 1
                      ? 'border-gray-400 shadow-xl'
                      : 'border-orange-400 shadow-lg'} p-6 transition-all duration-200 hover:scale-105"
                >
                  <!-- Cabeçalho -->
                  <div class="mb-4">
                    <h4
                      class="text-xl font-bold text-neutral-900 dark:text-neutral-100 mb-2"
                    >
                      {opcao.laboratorio_nome}
                    </h4>
                    <div
                      class="flex items-center gap-2 text-sm text-neutral-600 dark:text-neutral-400"
                    >
                      <span
                        >📍 {opcao.laboratorio_cidade || "N/A"}, {opcao.laboratorio_uf ||
                          "N/A"}</span
                      >
                      {#if opcao.laboratorio_avaliacao}
                        <span>⭐ {opcao.laboratorio_avaliacao}</span>
                      {/if}
                    </div>
                  </div>

                  <!-- Badges -->
                  {#if opcao.badges && opcao.badges.length > 0}
                    <div class="flex flex-wrap gap-2 mb-4">
                      {#each opcao.badges as badge}
                        <Badge variant={getBadgeVariant(badge)} size="sm">
                          {badge}
                        </Badge>
                      {/each}
                    </div>
                  {/if}

                  <!-- Preço -->
                  <div class="mb-4">
                    <div class="flex items-baseline gap-2">
                      {#if opcao.desconto_percentual > 0}
                        <span class="text-sm text-neutral-500 line-through">
                          {formatCurrency(opcao.preco_base)}
                        </span>
                        <Badge variant="success" size="sm">
                          -{formatPercentage(opcao.desconto_percentual)}
                        </Badge>
                      {/if}
                    </div>
                    <div class="text-3xl font-bold text-success mt-1">
                      {formatCurrency(opcao.preco_final)}
                    </div>
                    {#if opcao.custo_frete > 0}
                      <div class="text-xs text-neutral-500 mt-1">
                        + {formatCurrency(opcao.custo_frete)} frete
                      </div>
                    {/if}
                  </div>

                  <!-- Scores -->
                  <div class="grid grid-cols-3 gap-2 mb-4">
                    <div
                      class="text-center p-2 bg-neutral-50 dark:bg-neutral-700 rounded-lg"
                    >
                      <div
                        class="text-xs text-neutral-600 dark:text-neutral-400"
                      >
                        Preço
                      </div>
                      <div
                        class="font-semibold text-neutral-900 dark:text-neutral-100"
                      >
                        {opcao.score_preco}
                      </div>
                    </div>
                    <div
                      class="text-center p-2 bg-neutral-50 dark:bg-neutral-700 rounded-lg"
                    >
                      <div
                        class="text-xs text-neutral-600 dark:text-neutral-400"
                      >
                        Prazo
                      </div>
                      <div
                        class="font-semibold text-neutral-900 dark:text-neutral-100"
                      >
                        {opcao.score_prazo}
                      </div>
                    </div>
                    <div
                      class="text-center p-2 bg-neutral-50 dark:bg-neutral-700 rounded-lg"
                    >
                      <div
                        class="text-xs text-neutral-600 dark:text-neutral-400"
                      >
                        Qualidade
                      </div>
                      <div
                        class="font-semibold text-neutral-900 dark:text-neutral-100"
                      >
                        {opcao.score_qualidade}
                      </div>
                    </div>
                  </div>

                  <!-- Score Total e Prazo -->
                  <div
                    class="flex items-center justify-between mb-4 p-3 bg-blue-50 dark:bg-blue-900/30 rounded-lg"
                  >
                    <div>
                      <div
                        class="text-xs text-neutral-600 dark:text-neutral-400"
                      >
                        Score Total
                      </div>
                      <div
                        class="text-2xl font-bold text-blue-600 dark:text-blue-400"
                      >
                        {opcao.score_total}
                      </div>
                    </div>
                    <div class="text-right">
                      <div
                        class="text-xs text-neutral-600 dark:text-neutral-400"
                      >
                        Prazo
                      </div>
                      <div
                        class="text-lg font-semibold text-neutral-900 dark:text-neutral-100"
                      >
                        {formatDays(opcao.prazo_entrega)}
                      </div>
                    </div>
                  </div>

                  <!-- Justificativa -->
                  <div
                    class="mb-4 p-3 bg-neutral-50 dark:bg-neutral-700 rounded-lg"
                  >
                    <p class="text-sm text-neutral-700 dark:text-neutral-300">
                      💡 {opcao.justificativa}
                    </p>
                  </div>

                  <!-- Ações -->
                  <div class="flex gap-2">
                    <Button
                      variant="primary"
                      size="md"
                      fullWidth
                      on:click={() => confirmarDecisao(opcao)}
                    >
                      ✅ Escolher
                    </Button>
                    <Button
                      variant="secondary"
                      size="md"
                      on:click={() => toggleComparacao(opcao)}
                    >
                      {isSelectedForComparison(opcao.id) ? "✓" : "⚖️"}
                    </Button>
                  </div>
                </div>
              </div>
            {/each}
          </div>
        </section>
      {/if}

      <!-- Comparação -->
      {#if selectedForComparison.length >= 2}
        <section class="mt-12">
          <div
            class="bg-blue-50 dark:bg-blue-900/20 border-2 border-blue-200 dark:border-blue-800 rounded-xl p-6"
          >
            <div class="flex items-center justify-between mb-4">
              <h3
                class="text-lg font-semibold text-neutral-900 dark:text-neutral-100"
              >
                ⚖️ Comparação Selecionada ({selectedForComparison.length} itens)
              </h3>
              <Button
                variant="secondary"
                size="sm"
                on:click={() => (selectedForComparison = [])}
              >
                Limpar
              </Button>
            </div>

            <div
              class="grid grid-cols-1 md:grid-cols-{selectedForComparison.length} gap-4"
            >
              {#each selectedForComparison as item}
                <div
                  class="bg-white dark:bg-neutral-800 rounded-lg p-4 border border-neutral-200 dark:border-neutral-700"
                >
                  <div
                    class="font-semibold text-neutral-900 dark:text-neutral-100 mb-2"
                  >
                    {item.laboratorio_nome}
                  </div>
                  <div class="text-sm space-y-1">
                    <div>💰 {formatCurrency(item.preco_final)}</div>
                    <div>⏱️ {formatDays(item.prazo_entrega)}</div>
                    <div>📊 Score: {item.score_total}</div>
                  </div>
                </div>
              {/each}
            </div>
          </div>
        </section>
      {/if}

      <!-- Outros Fornecedores -->
      {#if outros && outros.length > 0}
        <section class="mt-12">
          <SectionHeader
            title="Outras Opções"
            subtitle={`${outros.length} fornecedores adicionais`}
          />

          <div
            class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 overflow-hidden"
          >
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead class="bg-neutral-50 dark:bg-neutral-700">
                  <tr>
                    <th
                      class="px-6 py-3 text-left text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wider"
                      >#</th
                    >
                    <th
                      class="px-6 py-3 text-left text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wider"
                      >Laboratório</th
                    >
                    <th
                      class="px-6 py-3 text-right text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wider"
                      >Preço</th
                    >
                    <th
                      class="px-6 py-3 text-center text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wider"
                      >Prazo</th
                    >
                    <th
                      class="px-6 py-3 text-center text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wider"
                      >Score</th
                    >
                    <th
                      class="px-6 py-3 text-center text-xs font-medium text-neutral-500 dark:text-neutral-400 uppercase tracking-wider"
                      >Ações</th
                    >
                  </tr>
                </thead>
                <tbody
                  class="divide-y divide-neutral-200 dark:divide-neutral-700"
                >
                  {#each outros as opcao}
                    <tr
                      class="hover:bg-neutral-50 dark:hover:bg-neutral-700 transition-colors"
                    >
                      <td class="px-6 py-4 whitespace-nowrap">
                        <Badge
                          variant={getPosicaoColor(opcao.posicao)}
                          size="sm"
                        >
                          {opcao.posicao}º
                        </Badge>
                      </td>
                      <td class="px-6 py-4">
                        <div
                          class="font-medium text-neutral-900 dark:text-neutral-100"
                        >
                          {opcao.laboratorio_nome}
                        </div>
                        <div class="text-sm text-neutral-500">
                          {opcao.laboratorio_cidade || "N/A"}, {opcao.laboratorio_uf ||
                            "N/A"}
                        </div>
                      </td>
                      <td class="px-6 py-4 text-right">
                        <div
                          class="font-semibold text-neutral-900 dark:text-neutral-100"
                        >
                          {formatCurrency(opcao.preco_final)}
                        </div>
                        {#if opcao.desconto_percentual > 0}
                          <div class="text-xs text-success">
                            -{formatPercentage(opcao.desconto_percentual)}
                          </div>
                        {/if}
                      </td>
                      <td class="px-6 py-4 text-center">
                        <Badge variant="primary" size="sm">
                          {formatDays(opcao.prazo_entrega)}
                        </Badge>
                      </td>
                      <td class="px-6 py-4 text-center">
                        <div
                          class="font-semibold text-neutral-900 dark:text-neutral-100"
                        >
                          {opcao.score_total}
                        </div>
                      </td>
                      <td class="px-6 py-4 text-center">
                        <div class="flex gap-2 justify-center">
                          <Button
                            variant="primary"
                            size="sm"
                            on:click={() => confirmarDecisao(opcao)}
                          >
                            Escolher
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            on:click={() => toggleComparacao(opcao)}
                          >
                            {isSelectedForComparison(opcao.id) ? "✓" : "⚖️"}
                          </Button>
                        </div>
                      </td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          </div>
        </section>
      {/if}

      <!-- Empty State -->
      {#if !ranking || ranking.length === 0}
        <section class="mt-12">
          <EmptyState
            icon="🔍"
            title="Nenhum fornecedor encontrado"
            description={tem_filtros_ativos
              ? "Tente ajustar os filtros para encontrar mais opções"
              : "Não há fornecedores disponíveis para esta lente no momento"}
            actionLabel="Nova Busca"
            on:action={() => goto("/buscar")}
          />
        </section>
      {/if}

      <!-- Ações Rápidas -->
      <section class="mt-16">
        <SectionHeader title="Próximos Passos" />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <ActionCard
            icon="📋"
            title="Ver Histórico"
            description="Consulte decisões anteriores e compare resultados"
            actionLabel="Acessar Histórico"
            color="green"
            on:click={() => goto("/historico")}
          />

          <ActionCard
            icon="🏢"
            title="Gerenciar Fornecedores"
            description="Cadastre novos laboratórios ou atualize informações"
            actionLabel="Gerenciar"
            color="blue"
            on:click={() => goto("/fornecedores")}
          />

          <ActionCard
            icon="🎟️"
            title="Vouchers Disponíveis"
            description="Veja vouchers de desconto ativos para suas compras"
            actionLabel="Ver Vouchers"
            color="orange"
            on:click={() => goto("/vouchers")}
          />
        </div>
      </section>
    </Container>
  </main>
</div>

<!-- Modal de Confirmação -->
{#if showDecisionModal && selectedOption}
  <Modal
    open={showDecisionModal}
    title="✅ Confirmar Decisão"
    size="lg"
    on:close={fecharModal}
  >
    <div class="space-y-6">
      <div class="bg-blue-50 dark:bg-blue-900/30 rounded-xl p-6">
        <h4 class="font-semibold text-neutral-900 dark:text-neutral-100 mb-4">
          {selectedOption.laboratorio_nome}
        </h4>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <span class="text-sm text-neutral-600 dark:text-neutral-400"
              >Preço Final</span
            >
            <p class="text-2xl font-bold text-success">
              {formatCurrency(selectedOption.preco_final)}
            </p>
          </div>
          <div>
            <span class="text-sm text-neutral-600 dark:text-neutral-400"
              >Prazo</span
            >
            <p
              class="text-2xl font-bold text-neutral-900 dark:text-neutral-100"
            >
              {formatDays(selectedOption.prazo_entrega)}
            </p>
          </div>
        </div>

        <div
          class="mt-4 pt-4 border-t border-neutral-200 dark:border-neutral-700"
        >
          <div class="flex items-center justify-between">
            <span class="text-sm text-neutral-600 dark:text-neutral-400"
              >Score Total</span
            >
            <Badge
              variant={getScoreColor(selectedOption.score_total)}
              size="md"
            >
              {selectedOption.score_total}/100
            </Badge>
          </div>
        </div>
      </div>

      <div>
        <label
          for="observacoes"
          class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2"
        >
          Observações (opcional)
        </label>
        <textarea
          id="observacoes"
          bind:value={observacoes}
          rows="3"
          class="w-full px-4 py-2 border border-neutral-300 dark:border-neutral-600 rounded-lg bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100 focus:ring-2 focus:ring-blue-500"
          placeholder="Digite observações sobre esta decisão..."
        ></textarea>
      </div>

      <div class="bg-neutral-50 dark:bg-neutral-700 rounded-lg p-4">
        <p class="text-sm text-neutral-700 dark:text-neutral-300">
          <strong>💡 Justificativa:</strong>
          {selectedOption.justificativa}
        </p>
      </div>
    </div>

    <div slot="footer" class="flex gap-3">
      <Button
        variant="secondary"
        size="md"
        fullWidth
        on:click={fecharModal}
        disabled={isLoading}
      >
        Cancelar
      </Button>

      <Button
        variant="primary"
        size="md"
        fullWidth
        on:click={processarDecisao}
        disabled={isLoading}
      >
        {#if isLoading}
          <LoadingSpinner size="sm" color="white" />
          Processando...
        {:else}
          ✅ Confirmar Decisão
        {/if}
      </Button>
    </div>
  </Modal>
{/if}

<!-- Modal de Filtros -->
{#if showFiltersModal}
  <Modal
    open={showFiltersModal}
    title="🔧 Filtros Avançados"
    size="md"
    on:close={() => (showFiltersModal = false)}
  >
    <div class="space-y-4">
      <div>
        <label
          for="filtro-uf"
          class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2"
        >
          Estado (UF)
        </label>
        <select
          id="filtro-uf"
          bind:value={filtrosAtivos.uf}
          class="w-full px-4 py-2 border border-neutral-300 dark:border-neutral-600 rounded-lg bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
        >
          <option value="">Todos os estados</option>
          <option value="RS">Rio Grande do Sul</option>
          <option value="SP">São Paulo</option>
          <option value="GO">Goiás</option>
          <option value="PE">Pernambuco</option>
          <option value="AM">Amazonas</option>
        </select>
      </div>

      <div>
        <label
          for="filtro-cidade"
          class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2"
        >
          Cidade
        </label>
        <input
          id="filtro-cidade"
          type="text"
          bind:value={filtrosAtivos.cidade}
          placeholder="Ex: Porto Alegre"
          class="w-full px-4 py-2 border border-neutral-300 dark:border-neutral-600 rounded-lg bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
        />
      </div>

      <div>
        <label
          for="filtro-prazo"
          class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2"
        >
          Prazo Máximo (dias)
        </label>
        <input
          id="filtro-prazo"
          type="number"
          bind:value={filtrosAtivos.prazo_maximo}
          min="1"
          max="30"
          placeholder="Ex: 7"
          class="w-full px-4 py-2 border border-neutral-300 dark:border-neutral-600 rounded-lg bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
        />
      </div>

      <div>
        <label
          for="filtro-preco"
          class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2"
        >
          Preço Máximo (R$)
        </label>
        <input
          id="filtro-preco"
          type="number"
          bind:value={filtrosAtivos.preco_maximo}
          min="0"
          step="10"
          placeholder="Ex: 500"
          class="w-full px-4 py-2 border border-neutral-300 dark:border-neutral-600 rounded-lg bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
        />
      </div>
    </div>

    <div slot="footer" class="flex gap-3">
      <Button variant="secondary" size="md" on:click={limparFiltros}>
        Limpar Filtros
      </Button>

      <Button variant="primary" size="md" fullWidth on:click={aplicarFiltros}>
        Aplicar Filtros
      </Button>
    </div>
  </Modal>
{/if}

<!-- Loading Overlay -->
<LoadingOverlay show={isLoading} message="Processando sua decisão..." />

<style>
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  section {
    animation: fadeIn 0.4s ease-out;
  }
</style>
