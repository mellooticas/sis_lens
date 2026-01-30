<script lang="ts">
  import type { PageData } from "./$types";
  import { fade } from "svelte/transition";
  import { goto } from "$app/navigation";
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import DashboardMetricCard from "$lib/components/cards/DashboardMetricCard.svelte";
  import DonutChart from "$lib/components/charts/DonutChart.svelte";
  import BarChart from "$lib/components/charts/BarChart.svelte";
  import InsightCard from "$lib/components/charts/InsightCard.svelte";
  import {
    BarChart3,
    PieChart,
    TrendingUp,
    Lightbulb,
    Search,
    Award,
    Factory,
    Zap,
  } from "lucide-svelte";

  // Dados do servidor
  export let data: PageData;

  $: stats = data.stats;
  $: topCaros = data.topCaros || [];
  $: topPremium = data.topPremium || [];
  $: fornecedores = data.fornecedores || [];
  $: distribuicaoTipo = data.distribuicaoTipo || [];
  $: distribuicaoMaterial = data.distribuicaoMaterial || [];

  let activeTab: "overview" | "distribuicao" | "comparativo" | "insights" =
    "overview";

  function formatarPreco(valor: number): string {
    if (!valor) return "R$ 0,00";
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(valor);
  }

  function formatarTexto(texto: string): string {
    if (!texto) return "";
    return texto.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
  }

  function calcularPercentual(valor: number, total: number): number {
    if (!total || total === 0) return 0;
    return Math.round((valor / total) * 100);
  }

  // Gerar insights automáticos
  $: insights = generateInsights(
    stats,
    fornecedores,
    distribuicaoTipo,
    distribuicaoMaterial,
  );

  function generateInsights(
    stats: any,
    fornecedores: any[],
    distribuicaoTipo: any[],
    distribuicaoMaterial: any[],
  ) {
    if (!stats) return [];

    const results = [];

    const premiumPercentage =
      stats.total_premium && stats.total_lentes
        ? (stats.total_premium / stats.total_lentes) * 100
        : 0;

    if (premiumPercentage > 30) {
      results.push({
        type: "success" as const,
        icon: "⭐",
        title: "Alto Mix Premium",
        insight: `${premiumPercentage.toFixed(1)}% do catálogo é premium - excelente posicionamento de mercado.`,
      });
    } else if (premiumPercentage < 15) {
      results.push({
        type: "warning" as const,
        icon: "📊",
        title: "Oportunidade Premium",
        insight: `Apenas ${premiumPercentage.toFixed(1)}% do catálogo é premium. Considere expandir esta categoria.`,
      });
    }

    if (fornecedores.length > 0) {
      const fornecedorTop = fornecedores.reduce((prev, current) =>
        (current.total_lentes || 0) > (prev.total_lentes || 0) ? current : prev,
      );
      const percentualTop = fornecedorTop.total_lentes
        ? (fornecedorTop.total_lentes / stats.total_lentes) * 100
        : 0;

      results.push({
        type: "info" as const,
        icon: "🏭",
        title: "Fornecedor Líder",
        insight: `${fornecedorTop.nome} lidera com ${fornecedorTop.total_lentes || 0} lentes (${percentualTop.toFixed(1)}% do catálogo).`,
      });
    }

    if (stats.preco_medio_premium && stats.preco_medio_standard) {
      const diferencial =
        ((stats.preco_medio_premium - stats.preco_medio_standard) /
          stats.preco_medio_standard) *
        100;

      if (diferencial > 100) {
        results.push({
          type: "success" as const,
          icon: "💎",
          title: "Forte Diferenciação Premium",
          insight: `Produtos premium custam ${diferencial.toFixed(0)}% a mais, gerando boa margem.`,
        });
      }
    }

    return results;
  }

  // Preparar dados para gráficos
  $: chartDataTipo = distribuicaoTipo.map((item, index) => ({
    label: formatarTexto(item.tipo),
    value: item.quantidade,
    color: [
      "#3b82f6",
      "#10b981",
      "#f59e0b",
      "#8b5cf6",
      "#ef4444",
      "#06b6d4",
      "#ec4899",
    ][index % 7],
  }));

  $: chartDataMaterial = distribuicaoMaterial.map((item, index) => ({
    label: formatarTexto(item.material),
    value: item.quantidade,
    color: [
      "#06b6d4",
      "#14b8a6",
      "#84cc16",
      "#eab308",
      "#f97316",
      "#8b5cf6",
      "#ec4899",
    ][index % 7],
  }));

  $: topFornecedoresChart = fornecedores
    .sort((a, b) => (b.total_lentes || 0) - (a.total_lentes || 0))
    .slice(0, 5)
    .map((f, index) => ({
      label: f.nome,
      value: f.total_lentes || 0,
      color: ["#3b82f6", "#10b981", "#f59e0b", "#8b5cf6", "#ec4899"][index],
    }));

  $: topCarosChart = topCaros.slice(0, 5).map((item, index) => ({
    label: item.nome_exibicao || item.nome_lente || "Sem nome",
    value: item.preco_venda_sugerido || 0,
    color: ["#f59e0b", "#eab308", "#facc15", "#fde047", "#fef08a"][index],
  }));
</script>

<svelte:head>
  <title>BI e Relatórios | SIS Lens</title>
  <meta
    name="description"
    content="Dashboard de Business Intelligence com análises completas"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero Section -->
    <PageHero
      badge="📊 Business Intelligence"
      title="Dashboard Executivo"
      subtitle="Análises em tempo real com insights automáticos para tomada de decisão estratégica"
      alignment="center"
      maxWidth="lg"
    />

    <!-- Tabs Navigation -->
    <section class="mt-8">
      <div
        class="bg-neutral-900/50 dark:bg-neutral-900/80 backdrop-blur-sm rounded-xl overflow-hidden border border-neutral-700/50"
      >
        <div class="flex flex-wrap border-b border-neutral-700/50">
          <button
            on:click={() => (activeTab = "overview")}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-semibold transition-all duration-300 flex items-center justify-center gap-2
              {activeTab === 'overview'
              ? 'bg-blue-900/50 text-white border-b-2 border-blue-500'
              : 'text-neutral-400 hover:bg-neutral-800/50 hover:text-white'}"
          >
            <BarChart3 class="w-4 h-4" />
            Overview
          </button>
          <button
            on:click={() => (activeTab = "distribuicao")}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-semibold transition-all duration-300 flex items-center justify-center gap-2
              {activeTab === 'distribuicao'
              ? 'bg-blue-900/50 text-white border-b-2 border-blue-500'
              : 'text-neutral-400 hover:bg-neutral-800/50 hover:text-white'}"
          >
            <PieChart class="w-4 h-4" />
            Distribuição
          </button>
          <button
            on:click={() => (activeTab = "comparativo")}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-semibold transition-all duration-300 flex items-center justify-center gap-2
              {activeTab === 'comparativo'
              ? 'bg-blue-900/50 text-white border-b-2 border-blue-500'
              : 'text-neutral-400 hover:bg-neutral-800/50 hover:text-white'}"
          >
            <TrendingUp class="w-4 h-4" />
            Comparativo
          </button>
          <button
            on:click={() => (activeTab = "insights")}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-semibold transition-all duration-300 flex items-center justify-center gap-2
              {activeTab === 'insights'
              ? 'bg-blue-900/50 text-white border-b-2 border-blue-500'
              : 'text-neutral-400 hover:bg-neutral-800/50 hover:text-white'}"
          >
            <Lightbulb class="w-4 h-4" />
            Insights
          </button>
        </div>

        <div class="p-6">
          <!-- Overview Tab -->
          {#if activeTab === "overview"}
            <div in:fade={{ duration: 300 }} class="space-y-8">
              <!-- KPI Cards -->
              <section>
                <SectionHeader
                  title="📊 Visão Geral do Catálogo"
                  subtitle="Estatísticas atualizadas em tempo real"
                />
                <div
                  class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mt-6"
                >
                  <DashboardMetricCard
                    title="Total de Lentes"
                    value={stats.total_lentes?.toLocaleString("pt-BR") || "0"}
                    icon="📦"
                    color="blue"
                  />
                  <DashboardMetricCard
                    title="Lentes Premium"
                    value={stats.total_premium?.toLocaleString("pt-BR") || "0"}
                    icon="⭐"
                    color="purple"
                    trend={`${(((stats.total_premium || 0) / (stats.total_lentes || 1)) * 100).toFixed(1)}% do total`}
                  />
                  <DashboardMetricCard
                    title="Preço Médio"
                    value={formatarPreco(stats.preco_medio || 0)}
                    icon="💰"
                    color="green"
                  />
                  <DashboardMetricCard
                    title="Fornecedores"
                    value={fornecedores.length.toLocaleString("pt-BR")}
                    icon="🏭"
                    color="orange"
                  />
                </div>
              </section>

              <!-- Charts Grid -->
              <section>
                <SectionHeader
                  title="📈 Distribuição do Catálogo"
                  subtitle="Análise por tipo e material"
                />
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
                  <div
                    class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50"
                  >
                    <h3
                      class="text-lg font-bold text-white mb-4 flex items-center gap-2"
                    >
                      <span class="text-2xl">📊</span>
                      Por Tipo
                    </h3>
                    {#if chartDataTipo.length > 0}
                      <DonutChart data={chartDataTipo} size={280} />
                    {:else}
                      <p class="text-neutral-400 text-center py-8">
                        Nenhum dado disponível
                      </p>
                    {/if}
                  </div>

                  <div
                    class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50"
                  >
                    <h3
                      class="text-lg font-bold text-white mb-4 flex items-center gap-2"
                    >
                      <span class="text-2xl">🔬</span>
                      Por Material
                    </h3>
                    {#if chartDataMaterial.length > 0}
                      <DonutChart data={chartDataMaterial} size={280} />
                    {:else}
                      <p class="text-neutral-400 text-center py-8">
                        Nenhum dado disponível
                      </p>
                    {/if}
                  </div>
                </div>
              </section>

              <!-- Top Fornecedores -->
              <section>
                <SectionHeader
                  title="🏆 Top 5 Fornecedores"
                  subtitle="Parceiros com maior volume de lentes cadastradas"
                />
                <div
                  class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 mt-6"
                >
                  {#if topFornecedoresChart.length > 0}
                    <BarChart data={topFornecedoresChart} height={300} />
                  {:else}
                    <p class="text-neutral-400 text-center py-8">
                      Nenhum dado disponível
                    </p>
                  {/if}
                </div>
              </section>
            </div>
          {/if}

          <!-- Distribuição Tab -->
          {#if activeTab === "distribuicao"}
            <div in:fade={{ duration: 300 }} class="space-y-8">
              <section>
                <SectionHeader
                  title="📊 Análise Detalhada"
                  subtitle="Distribuição completa por categoria e material"
                />
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
                  <div
                    class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50"
                  >
                    <h3 class="text-lg font-bold text-white mb-4">
                      📊 Tipos de Lentes
                    </h3>
                    {#if chartDataTipo.length > 0}
                      <DonutChart data={chartDataTipo} size={300} />

                      <!-- Tabela de Detalhes -->
                      <div class="mt-6 overflow-x-auto">
                        <table class="w-full text-sm">
                          <thead class="bg-neutral-800/50">
                            <tr>
                              <th
                                class="px-4 py-3 text-left font-semibold text-neutral-300"
                                >Tipo</th
                              >
                              <th
                                class="px-4 py-3 text-right font-semibold text-neutral-300"
                                >Qtd</th
                              >
                              <th
                                class="px-4 py-3 text-right font-semibold text-neutral-300"
                                >%</th
                              >
                            </tr>
                          </thead>
                          <tbody>
                            {#each distribuicaoTipo as item}
                              <tr
                                class="border-b border-neutral-800 hover:bg-neutral-800/30 transition-colors"
                              >
                                <td class="px-4 py-3 text-white"
                                  >{formatarTexto(item.tipo)}</td
                                >
                                <td
                                  class="px-4 py-3 text-right font-medium text-white"
                                  >{item.quantidade}</td
                                >
                                <td
                                  class="px-4 py-3 text-right text-neutral-400"
                                >
                                  {calcularPercentual(
                                    item.quantidade,
                                    stats.total_lentes,
                                  )}%
                                </td>
                              </tr>
                            {/each}
                          </tbody>
                        </table>
                      </div>
                    {:else}
                      <p class="text-neutral-400 text-center py-8">
                        Nenhum dado disponível
                      </p>
                    {/if}
                  </div>

                  <div
                    class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50"
                  >
                    <h3 class="text-lg font-bold text-white mb-4">
                      🔬 Materiais
                    </h3>
                    {#if chartDataMaterial.length > 0}
                      <DonutChart data={chartDataMaterial} size={300} />

                      <!-- Tabela de Detalhes -->
                      <div class="mt-6 overflow-x-auto">
                        <table class="w-full text-sm">
                          <thead class="bg-neutral-800/50">
                            <tr>
                              <th
                                class="px-4 py-3 text-left font-semibold text-neutral-300"
                                >Material</th
                              >
                              <th
                                class="px-4 py-3 text-right font-semibold text-neutral-300"
                                >Qtd</th
                              >
                              <th
                                class="px-4 py-3 text-right font-semibold text-neutral-300"
                                >%</th
                              >
                            </tr>
                          </thead>
                          <tbody>
                            {#each distribuicaoMaterial as item}
                              <tr
                                class="border-b border-neutral-800 hover:bg-neutral-800/30 transition-colors"
                              >
                                <td class="px-4 py-3 text-white"
                                  >{formatarTexto(item.material)}</td
                                >
                                <td
                                  class="px-4 py-3 text-right font-medium text-white"
                                  >{item.quantidade}</td
                                >
                                <td
                                  class="px-4 py-3 text-right text-neutral-400"
                                >
                                  {calcularPercentual(
                                    item.quantidade,
                                    stats.total_lentes,
                                  )}%
                                </td>
                              </tr>
                            {/each}
                          </tbody>
                        </table>
                      </div>
                    {:else}
                      <p class="text-neutral-400 text-center py-8">
                        Nenhum dado disponível
                      </p>
                    {/if}
                  </div>
                </div>
              </section>

              <!-- Top Mais Caros -->
              <section>
                <SectionHeader
                  title="💎 Top 5 Mais Caros"
                  subtitle="Lentes com maior preço base"
                />
                <div
                  class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 mt-6"
                >
                  {#if topCarosChart.length > 0}
                    <BarChart
                      data={topCarosChart}
                      height={250}
                      showValues={true}
                    />
                  {:else}
                    <p class="text-neutral-400 text-center py-8">
                      Nenhum dado disponível
                    </p>
                  {/if}
                </div>
              </section>
            </div>
          {/if}

          <!-- Comparativo Tab -->
          {#if activeTab === "comparativo"}
            <div in:fade={{ duration: 300 }} class="space-y-8">
              <!-- Comparação Premium vs Standard -->
              <section>
                <SectionHeader
                  title="⚖️ Premium vs Standard"
                  subtitle="Análise comparativa do catálogo"
                />
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-6">
                  <DashboardMetricCard
                    title="Lentes Premium"
                    value={stats.total_premium?.toLocaleString("pt-BR") || "0"}
                    icon="⭐"
                    color="purple"
                    trend={`${(((stats.total_premium || 0) / (stats.total_lentes || 1)) * 100).toFixed(1)}%`}
                  />
                  <DashboardMetricCard
                    title="Lentes Standard"
                    value={stats.total_standard?.toLocaleString("pt-BR") || "0"}
                    icon="📦"
                    color="blue"
                    trend={`${(((stats.total_standard || 0) / (stats.total_lentes || 1)) * 100).toFixed(1)}%`}
                  />
                  <DashboardMetricCard
                    title="Diferença"
                    value={Math.abs(
                      (stats.total_premium || 0) - (stats.total_standard || 0),
                    ).toLocaleString("pt-BR")}
                    icon="📊"
                    color="orange"
                  />
                </div>
              </section>

              <!-- Comparação de Preços -->
              <section>
                <SectionHeader
                  title="💰 Análise de Preços"
                  subtitle="Comparação de valores médios"
                />
                <div
                  class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 mt-6"
                >
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div
                      class="text-center p-6 bg-purple-900/30 rounded-xl border-2 border-purple-600/50"
                    >
                      <p
                        class="text-sm text-purple-400 font-semibold mb-2 uppercase tracking-wider"
                      >
                        Premium
                      </p>
                      <p class="text-3xl font-bold text-white">
                        {formatarPreco(stats.preco_medio_premium || 0)}
                      </p>
                    </div>
                    <div
                      class="text-center p-6 bg-blue-900/30 rounded-xl border-2 border-blue-600/50"
                    >
                      <p
                        class="text-sm text-blue-400 font-semibold mb-2 uppercase tracking-wider"
                      >
                        Standard
                      </p>
                      <p class="text-3xl font-bold text-white">
                        {formatarPreco(stats.preco_medio_standard || 0)}
                      </p>
                    </div>
                    <div
                      class="text-center p-6 bg-green-900/30 rounded-xl border-2 border-green-600/50"
                    >
                      <p
                        class="text-sm text-green-400 font-semibold mb-2 uppercase tracking-wider"
                      >
                        Diferencial
                      </p>
                      <p class="text-3xl font-bold text-white">
                        {stats.preco_medio_premium && stats.preco_medio_standard
                          ? `+${(((stats.preco_medio_premium - stats.preco_medio_standard) / stats.preco_medio_standard) * 100).toFixed(0)}%`
                          : "0%"}
                      </p>
                    </div>
                  </div>
                </div>
              </section>

              <!-- Gráfico Comparativo de Fornecedores -->
              {#if fornecedores.length > 0}
                <section>
                  <SectionHeader
                    title="🏭 Volume por Fornecedor"
                    subtitle="Ranking completo de fornecedores"
                  />
                  <div
                    class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 mt-6"
                  >
                    <BarChart
                      data={fornecedores
                        .sort(
                          (a, b) =>
                            (b.total_lentes || 0) - (a.total_lentes || 0),
                        )
                        .map((f, index) => ({
                          label: f.nome,
                          value: f.total_lentes || 0,
                          color: [
                            "#3b82f6",
                            "#10b981",
                            "#f59e0b",
                            "#8b5cf6",
                            "#ec4899",
                            "#06b6d4",
                            "#f97316",
                          ][index % 7],
                        }))}
                      height={Math.min(400, fornecedores.length * 50)}
                    />
                  </div>
                </section>
              {/if}
            </div>
          {/if}

          <!-- Insights Tab -->
          {#if activeTab === "insights"}
            <div in:fade={{ duration: 300 }} class="space-y-6">
              <div
                class="bg-gradient-to-r from-blue-600 via-blue-700 to-blue-800 text-white p-8 rounded-2xl shadow-2xl"
              >
                <div class="flex items-center gap-3 mb-3">
                  <Lightbulb class="w-8 h-8" />
                  <h3 class="text-2xl font-bold">Insights Automáticos</h3>
                </div>
                <p class="text-blue-100 text-lg">
                  Análises inteligentes geradas automaticamente com base nos
                  dados do catálogo.
                </p>
              </div>

              {#if insights.length === 0}
                <InsightCard
                  type="info"
                  icon="ℹ️"
                  title="Carregando Insights"
                  insight="Aguardando dados para gerar insights inteligentes..."
                />
              {:else}
                {#each insights as insight}
                  <InsightCard
                    type={insight.type}
                    icon={insight.icon}
                    title={insight.title}
                    insight={insight.insight}
                  />
                {/each}
              {/if}

              <!-- Recomendações Estratégicas -->
              <section>
                <SectionHeader
                  title="📈 Recomendações Estratégicas"
                  subtitle="Ações sugeridas para otimização do catálogo"
                />
                <div class="space-y-4 mt-6">
                  {#if (stats.total_premium || 0) / (stats.total_lentes || 1) < 0.2}
                    <div
                      class="p-4 bg-amber-900/30 border-l-4 border-amber-500 rounded-lg"
                    >
                      <h4
                        class="font-semibold text-amber-200 mb-2 flex items-center gap-2"
                      >
                        <TrendingUp class="w-4 h-4" />
                        Expandir Segmento Premium
                      </h4>
                      <p class="text-sm text-amber-300">
                        O mix premium está abaixo de 20%. Considere adicionar
                        mais lentes de alto valor para aumentar o ticket médio.
                      </p>
                    </div>
                  {/if}

                  <div
                    class="p-4 bg-green-900/30 border-l-4 border-green-500 rounded-lg"
                  >
                    <h4 class="font-semibold text-green-200 mb-2">
                      ✅ Continue Monitorando
                    </h4>
                    <p class="text-sm text-green-300">
                      Acompanhe regularmente este dashboard para identificar
                      tendências e oportunidades de melhoria.
                    </p>
                  </div>
                </div>
              </section>
            </div>
          {/if}
        </div>
      </div>
    </section>

    <!-- Ações Rápidas -->
    <section class="mt-12">
      <SectionHeader
        title="⚡ Ações Rápidas"
        subtitle="Acesse rapidamente as funcionalidades principais"
      />

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
        <button
          on:click={() => goto("/catalogo")}
          class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 hover:border-blue-500/50 hover:shadow-xl transition-all hover:scale-105 group"
        >
          <div class="flex flex-col items-center text-center">
            <Search
              class="w-12 h-12 text-blue-400 mb-3 group-hover:scale-110 transition-transform"
            />
            <h3 class="text-lg font-bold text-white mb-2">Buscar Lentes</h3>
            <p class="text-sm text-neutral-400">
              Pesquise no catálogo completo de {stats.total_lentes?.toLocaleString(
                "pt-BR",
              ) || "0"} lentes
            </p>
          </div>
        </button>

        <button
          on:click={() => goto("/ranking")}
          class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 hover:border-orange-500/50 hover:shadow-xl transition-all hover:scale-105 group"
        >
          <div class="flex flex-col items-center text-center">
            <Award
              class="w-12 h-12 text-orange-400 mb-3 group-hover:scale-110 transition-transform"
            />
            <h3 class="text-lg font-bold text-white mb-2">Ver Rankings</h3>
            <p class="text-sm text-neutral-400">
              Consulte os grupos mais caros e populares
            </p>
          </div>
        </button>

        <button
          on:click={() => goto("/fornecedores")}
          class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 hover:border-green-500/50 hover:shadow-xl transition-all hover:scale-105 group"
        >
          <div class="flex flex-col items-center text-center">
            <Factory
              class="w-12 h-12 text-green-400 mb-3 group-hover:scale-110 transition-transform"
            />
            <h3 class="text-lg font-bold text-white mb-2">Fornecedores</h3>
            <p class="text-sm text-neutral-400">
              Gerencie {fornecedores.length} fornecedores ativos
            </p>
          </div>
        </button>

        <button
          on:click={() => goto("/dashboard")}
          class="bg-neutral-900/80 backdrop-blur-sm rounded-xl p-6 border border-neutral-700/50 hover:border-purple-500/50 hover:shadow-xl transition-all hover:scale-105 group"
        >
          <div class="flex flex-col items-center text-center">
            <Zap
              class="w-12 h-12 text-purple-400 mb-3 group-hover:scale-110 transition-transform"
            />
            <h3 class="text-lg font-bold text-white mb-2">Dashboard</h3>
            <p class="text-sm text-neutral-400">Voltar ao painel principal</p>
          </div>
        </button>
      </div>
    </section>
  </Container>
</main>
