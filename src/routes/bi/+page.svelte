<script lang="ts">
  import type { PageData } from './$types';
  import Container from '$lib/components/layout/Container.svelte';
  import PageHero from '$lib/components/layout/PageHero.svelte';
  import SectionHeader from '$lib/components/layout/SectionHeader.svelte';
  import DonutChart from '$lib/components/charts/DonutChart.svelte';
  import BarChart from '$lib/components/charts/BarChart.svelte';
  import MetricCard from '$lib/components/charts/MetricCard.svelte';
  import InsightCard from '$lib/components/charts/InsightCard.svelte';
  
  // Dados do servidor
  export let data: PageData;
  
  $: stats = data.stats;
  $: topCaros = data.topCaros || [];
  $: topPremium = data.topPremium || [];
  $: fornecedores = data.fornecedores || [];
  $: distribuicaoTipo = data.distribuicaoTipo || [];
  $: distribuicaoMaterial = data.distribuicaoMaterial || [];
  
  let activeTab: 'overview' | 'distribuicao' | 'comparativo' | 'insights' = 'overview';

  function formatarPreco(valor: number): string {
    if (!valor) return 'R$ 0,00';
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor);
  }

  function formatarTexto(texto: string): string {
    if (!texto) return '';
    return texto.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase());
  }

  function calcularPercentual(valor: number, total: number): number {
    if (!total || total === 0) return 0;
    return Math.round((valor / total) * 100);
  }

  // Gerar insights automáticos
  $: insights = generateInsights(stats, fornecedores, distribuicaoTipo, distribuicaoMaterial);

  function generateInsights(stats: any, fornecedores: any[], distribuicaoTipo: any[], distribuicaoMaterial: any[]) {
    if (!stats) return [];
    
    const results = [];
    
    // Insight sobre preço médio
    if (stats.preco_medio && stats.preco_medio > 300) {
      results.push({
        type: 'warning' as const,
        icon: '💰',
        title: 'Preço Médio Elevado',
        insight: `O preço médio do catálogo está em ${formatarPreco(stats.preco_medio)}, indicando foco em produtos premium.`
      });
    } else if (stats.preco_medio && stats.preco_medio < 150) {
      results.push({
        type: 'info' as const,
        icon: '💵',
        title: 'Posicionamento Econômico',
        insight: `Preço médio de ${formatarPreco(stats.preco_medio)} indica foco em acessibilidade.`
      });
    }
    
    // Insight sobre lentes premium
    const premiumPercentage = stats.total_premium && stats.total_lentes 
      ? (stats.total_premium / stats.total_lentes) * 100 
      : 0;
    
    if (premiumPercentage > 30) {
      results.push({
        type: 'success' as const,
        icon: '⭐',
        title: 'Alto Mix Premium',
        insight: `${premiumPercentage.toFixed(1)}% do catálogo é premium - excelente posicionamento de mercado.`
      });
    } else if (premiumPercentage < 15) {
      results.push({
        type: 'warning' as const,
        icon: '📊',
        title: 'Oportunidade Premium',
        insight: `Apenas ${premiumPercentage.toFixed(1)}% do catálogo é premium. Considere expandir esta categoria.`
      });
    }
    
    // Insight sobre fornecedores
    if (fornecedores.length > 0) {
      const fornecedorTop = fornecedores.reduce((prev, current) => 
        (current.total_lentes || 0) > (prev.total_lentes || 0) ? current : prev
      );
      const percentualTop = fornecedorTop.total_lentes 
        ? (fornecedorTop.total_lentes / stats.total_lentes) * 100 
        : 0;
      
      results.push({
        type: 'info' as const,
        icon: '🏭',
        title: 'Fornecedor Líder',
        insight: `${fornecedorTop.nome} lidera com ${fornecedorTop.total_lentes || 0} lentes (${percentualTop.toFixed(1)}% do catálogo).`
      });
    }
    
    // Insight sobre diversidade
    if (distribuicaoTipo.length >= 5) {
      results.push({
        type: 'success' as const,
        icon: '🎯',
        title: 'Catálogo Diversificado',
        insight: `${distribuicaoTipo.length} tipos diferentes garantem cobertura completa do mercado.`
      });
    } else if (distribuicaoTipo.length < 3) {
      results.push({
        type: 'danger' as const,
        icon: '⚠️',
        title: 'Diversidade Limitada',
        insight: `Apenas ${distribuicaoTipo.length} tipos disponíveis. Considere expandir a variedade.`
      });
    }
    
    // Insight sobre materiais
    if (distribuicaoMaterial.length > 0) {
      const materialTop = distribuicaoMaterial[0];
      const percentualMaterial = materialTop.quantidade 
        ? (materialTop.quantidade / stats.total_lentes) * 100 
        : 0;
      
      if (percentualMaterial > 50) {
        results.push({
          type: 'warning' as const,
          icon: '🔬',
          title: 'Concentração de Material',
          insight: `${formatarTexto(materialTop.material)} domina com ${percentualMaterial.toFixed(1)}%. Considere diversificar.`
        });
      }
    }
    
    // Insight sobre diferencial de preço Premium vs Standard
    if (stats.preco_medio_premium && stats.preco_medio_standard) {
      const diferencial = ((stats.preco_medio_premium - stats.preco_medio_standard) / stats.preco_medio_standard) * 100;
      
      if (diferencial > 100) {
        results.push({
          type: 'success' as const,
          icon: '💎',
          title: 'Forte Diferenciação Premium',
          insight: `Produtos premium custam ${diferencial.toFixed(0)}% a mais, gerando boa margem.`
        });
      }
    }
    
    return results;
  }

  // Preparar dados para gráficos
  $: chartDataTipo = distribuicaoTipo.map((item, index) => ({
    label: formatarTexto(item.tipo),
    value: item.quantidade,
    color: ['#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#ef4444', '#06b6d4', '#ec4899'][index % 7]
  }));

  $: chartDataMaterial = distribuicaoMaterial.map((item, index) => ({
    label: formatarTexto(item.material),
    value: item.quantidade,
    color: ['#06b6d4', '#14b8a6', '#84cc16', '#eab308', '#f97316', '#8b5cf6', '#ec4899'][index % 7]
  }));

  $: topFornecedoresChart = fornecedores
    .sort((a, b) => (b.total_lentes || 0) - (a.total_lentes || 0))
    .slice(0, 5)
    .map((f, index) => ({
      label: f.nome,
      value: f.total_lentes || 0,
      color: ['#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899'][index]
    }));

  $: topCarosChart = topCaros.slice(0, 5).map((item, index) => ({
    label: item.nome_exibicao || item.nome_lente || 'Sem nome',
    value: item.preco_venda_sugerido || 0,
    color: ['#f59e0b', '#eab308', '#facc15', '#fde047', '#fef08a'][index]
  }));
</script>

<svelte:head>
  <title>BI e Relatórios | SIS Lens</title>
  <meta name="description" content="Dashboard de Business Intelligence com análises completas" />
</svelte:head>

<main class="min-h-screen bg-gradient-to-br from-neutral-50 via-blue-50 to-neutral-100 dark:from-neutral-900 dark:via-neutral-800 dark:to-neutral-900">
  <Container>
    <PageHero
      title="📊 Business Intelligence"
      subtitle="Dashboard executivo com insights e análises em tempo real"
    />

    <!-- Tabs Navigation -->
    <div class="mt-8 bg-white dark:bg-neutral-800 rounded-xl shadow-lg border border-neutral-200 dark:border-neutral-700 overflow-hidden">
      <div class="flex flex-wrap border-b border-neutral-200 dark:border-neutral-700">
          <button
            on:click={() => activeTab = 'overview'}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-medium transition-colors {activeTab === 'overview' ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-400 border-b-2 border-blue-600' : 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-700/50'}"
          >
            📈 Overview
          </button>
          <button
            on:click={() => activeTab = 'distribuicao'}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-medium transition-colors {activeTab === 'distribuicao' ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-400 border-b-2 border-blue-600' : 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-700/50'}"
          >
            📊 Distribuição
          </button>
          <button
            on:click={() => activeTab = 'comparativo'}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-medium transition-colors {activeTab === 'comparativo' ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-400 border-b-2 border-blue-600' : 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-700/50'}"
          >
            🔄 Comparativo
          </button>
          <button
            on:click={() => activeTab = 'insights'}
            class="flex-1 min-w-[120px] px-6 py-4 text-sm font-medium transition-colors {activeTab === 'insights' ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-400 border-b-2 border-blue-600' : 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-700/50'}"
          >
            💡 Insights
          </button>
        </div>

        <div class="p-6 space-y-6">
          <!-- Overview Tab -->
          {#if activeTab === 'overview'}
            <!-- KPI Cards -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
              <MetricCard
                title="Total de Lentes"
                value={stats.total_lentes?.toLocaleString('pt-BR') || '0'}
                trend="neutral"
                icon="📦"
                color="blue"
              />
              <MetricCard
                title="Lentes Premium"
                value={stats.total_premium?.toLocaleString('pt-BR') || '0'}
                trend={((stats.total_premium || 0) / (stats.total_lentes || 1) * 100) > 25 ? 'up' : 'neutral'}
                trendValue={`${((stats.total_premium || 0) / (stats.total_lentes || 1) * 100).toFixed(1)}% do total`}
                icon="⭐"
                color="purple"
              />
              <MetricCard
                title="Preço Médio"
                value={formatarPreco(stats.preco_medio || 0)}
                trend="neutral"
                icon="💰"
                color="green"
              />
              <MetricCard
                title="Fornecedores"
                value={fornecedores.length.toLocaleString('pt-BR')}
                trend="neutral"
                icon="🏭"
                color="amber"
              />
            </div>

            <!-- Charts Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Container>
                <SectionHeader
                  title="📊 Distribuição por Tipo"
                  subtitle="Categorias de lentes no catálogo"
                />
                {#if chartDataTipo.length > 0}
                  <div class="flex justify-center py-4">
                    <DonutChart data={chartDataTipo} size={280} />
                  </div>
                {:else}
                  <p class="text-neutral-500 dark:text-neutral-400 text-center py-8">Nenhum dado disponível</p>
                {/if}
              </Container>

              <Container>
                <SectionHeader
                  title="🔬 Distribuição por Material"
                  subtitle="Materiais disponíveis"
                />
                {#if chartDataMaterial.length > 0}
                  <div class="flex justify-center py-4">
                    <DonutChart data={chartDataMaterial} size={280} />
                  </div>
                {:else}
                  <p class="text-neutral-500 dark:text-neutral-400 text-center py-8">Nenhum dado disponível</p>
                {/if}
              </Container>
            </div>

            <!-- Top Fornecedores Bar Chart -->
            <Container>
              <SectionHeader
                title="🏆 Top 5 Fornecedores"
                subtitle="Parceiros com maior volume de lentes cadastradas"
              />
              {#if topFornecedoresChart.length > 0}
                <div class="py-4">
                  <BarChart data={topFornecedoresChart} height={300} />
                </div>
              {:else}
                <p class="text-neutral-500 dark:text-neutral-400 text-center py-8">Nenhum dado disponível</p>
              {/if}
            </Container>
          {/if}

          <!-- Distribuição Tab -->
          {#if activeTab === 'distribuicao'}
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
              <Container>
                <SectionHeader
                  title="📊 Tipos de Lentes"
                  subtitle="Distribuição completa por categoria"
                />
                {#if chartDataTipo.length > 0}
                  <div class="flex justify-center py-4">
                    <DonutChart data={chartDataTipo} size={300} />
                  </div>
                  
                  <!-- Tabela de Detalhes -->
                  <div class="mt-6 overflow-x-auto">
                    <table class="w-full text-sm">
                      <thead class="bg-neutral-100 dark:bg-neutral-700">
                        <tr>
                          <th class="px-4 py-2 text-left">Tipo</th>
                          <th class="px-4 py-2 text-right">Quantidade</th>
                          <th class="px-4 py-2 text-right">Percentual</th>
                        </tr>
                      </thead>
                      <tbody>
                        {#each distribuicaoTipo as item}
                          <tr class="border-b border-neutral-200 dark:border-neutral-700">
                            <td class="px-4 py-2">{formatarTexto(item.tipo)}</td>
                            <td class="px-4 py-2 text-right font-medium">{item.quantidade}</td>
                            <td class="px-4 py-2 text-right text-neutral-600 dark:text-neutral-400">
                              {calcularPercentual(item.quantidade, stats.total_lentes)}%
                            </td>
                          </tr>
                        {/each}
                      </tbody>
                    </table>
                  </div>
                {:else}
                  <p class="text-neutral-500 dark:text-neutral-400 text-center py-8">Nenhum dado disponível</p>
                {/if}
              </Container>

              <Container>
                <SectionHeader
                  title="🔬 Materiais"
                  subtitle="Distribuição completa por material"
                />
                {#if chartDataMaterial.length > 0}
                  <div class="flex justify-center py-4">
                    <DonutChart data={chartDataMaterial} size={300} />
                  </div>
                  
                  <!-- Tabela de Detalhes -->
                  <div class="mt-6 overflow-x-auto">
                    <table class="w-full text-sm">
                      <thead class="bg-neutral-100 dark:bg-neutral-700">
                        <tr>
                          <th class="px-4 py-2 text-left">Material</th>
                          <th class="px-4 py-2 text-right">Quantidade</th>
                          <th class="px-4 py-2 text-right">Percentual</th>
                        </tr>
                      </thead>
                      <tbody>
                        {#each distribuicaoMaterial as item}
                          <tr class="border-b border-neutral-200 dark:border-neutral-700">
                            <td class="px-4 py-2">{formatarTexto(item.material)}</td>
                            <td class="px-4 py-2 text-right font-medium">{item.quantidade}</td>
                            <td class="px-4 py-2 text-right text-neutral-600 dark:text-neutral-400">
                              {calcularPercentual(item.quantidade, stats.total_lentes)}%
                            </td>
                          </tr>
                        {/each}
                      </tbody>
                    </table>
                  </div>
                {:else}
                  <p class="text-neutral-500 dark:text-neutral-400 text-center py-8">Nenhum dado disponível</p>
                {/if}
              </Container>
            </div>

            <!-- Rankings em Bar Charts -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Container>
                <SectionHeader
                  title="💎 Top 5 Mais Caros"
                  subtitle="Lentes com maior preço base"
                />
                {#if topCarosChart.length > 0}
                  <div class="py-4">
                    <BarChart data={topCarosChart} height={250} showValues={true} />
                  </div>
                {:else}
                  <p class="text-neutral-500 dark:text-neutral-400 text-center py-8">Nenhum dado disponível</p>
                {/if}
              </Container>

            </div>
          {/if}

          <!-- Comparativo Tab -->
          {#if activeTab === 'comparativo'}
            <!-- Comparação Premium vs Standard -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
              <MetricCard
                title="Lentes Premium"
                value={stats.total_premium?.toLocaleString('pt-BR') || '0'}
                trend={stats.total_premium > stats.total_standard ? 'up' : 'down'}
                trendValue={`${((stats.total_premium || 0) / (stats.total_lentes || 1) * 100).toFixed(1)}%`}
                icon="⭐"
                color="purple"
              />
              <MetricCard
                title="Lentes Standard"
                value={stats.total_standard?.toLocaleString('pt-BR') || '0'}
                trend={stats.total_standard > stats.total_premium ? 'up' : 'down'}
                trendValue={`${((stats.total_standard || 0) / (stats.total_lentes || 1) * 100).toFixed(1)}%`}
                icon="📦"
                color="blue"
              />
              <MetricCard
                title="Diferença"
                value={Math.abs((stats.total_premium || 0) - (stats.total_standard || 0)).toLocaleString('pt-BR')}
                trend="neutral"
                icon="📊"
                color="amber"
              />
            </div>

            <!-- Comparação de Preços -->
            <Container>
              <SectionHeader
                title="💰 Análise de Preços: Premium vs Standard"
                subtitle="Comparação de valores médios"
              />
              <div class="grid grid-cols-1 md:grid-cols-3 gap-6 py-6">
                <div class="text-center p-6 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
                  <p class="text-sm text-purple-600 dark:text-purple-400 font-medium mb-2">Premium</p>
                  <p class="text-3xl font-bold text-purple-700 dark:text-purple-300">
                    {formatarPreco(stats.preco_medio_premium || 0)}
                  </p>
                </div>
                <div class="text-center p-6 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                  <p class="text-sm text-blue-600 dark:text-blue-400 font-medium mb-2">Standard</p>
                  <p class="text-3xl font-bold text-blue-700 dark:text-blue-300">
                    {formatarPreco(stats.preco_medio_standard || 0)}
                  </p>
                </div>
                <div class="text-center p-6 bg-green-50 dark:bg-green-900/20 rounded-lg">
                  <p class="text-sm text-green-600 dark:text-green-400 font-medium mb-2">Diferencial</p>
                  <p class="text-3xl font-bold text-green-700 dark:text-green-300">
                    {stats.preco_medio_premium && stats.preco_medio_standard 
                      ? `+${(((stats.preco_medio_premium - stats.preco_medio_standard) / stats.preco_medio_standard) * 100).toFixed(0)}%`
                      : '0%'}
                  </p>
                </div>
              </div>
            </Container>

            <!-- Gráfico Comparativo de Fornecedores -->
            {#if fornecedores.length > 0}
              <Container>
                <SectionHeader
                  title="🏭 Volume por Fornecedor"
                  subtitle="Ranking completo de fornecedores"
                />
                <div class="py-4">
                  <BarChart 
                    data={fornecedores
                      .sort((a, b) => (b.total_lentes || 0) - (a.total_lentes || 0))
                      .map((f, index) => ({
                        label: f.nome,
                        value: f.total_lentes || 0,
                        color: ['#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899', '#06b6d4', '#f97316'][index % 7]
                      }))}
                    height={Math.min(400, fornecedores.length * 50)}
                  />
                </div>
              </Container>
            {/if}
          {/if}

          <!-- Insights Tab -->
          {#if activeTab === 'insights'}
            <div class="space-y-4">
              <div class="bg-gradient-to-r from-blue-500 to-purple-600 text-white p-6 rounded-xl shadow-lg">
                <h3 class="text-xl font-bold mb-2">💡 Insights Automáticos</h3>
                <p class="text-blue-100">
                  Análises inteligentes geradas automaticamente com base nos dados do catálogo.
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
              <Container>
                <SectionHeader
                  title="📈 Recomendações Estratégicas"
                  subtitle="Ações sugeridas para otimização do catálogo"
                />
                <div class="space-y-4 py-4">
                  {#if (stats.total_premium || 0) / (stats.total_lentes || 1) < 0.2}
                    <div class="p-4 bg-amber-50 dark:bg-amber-900/20 border-l-4 border-amber-500 rounded">
                      <h4 class="font-semibold text-amber-900 dark:text-amber-200 mb-2">
                        ⬆️ Expandir Segmento Premium
                      </h4>
                      <p class="text-sm text-amber-800 dark:text-amber-300">
                        O mix premium está abaixo de 20%. Considere adicionar mais lentes de alto valor para aumentar o ticket médio.
                      </p>
                    </div>
                  {/if}

                  {#if distribuicaoTipo.length < 4}
                    <div class="p-4 bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-500 rounded">
                      <h4 class="font-semibold text-blue-900 dark:text-blue-200 mb-2">
                        🎯 Diversificar Tipos
                      </h4>
                      <p class="text-sm text-blue-800 dark:text-blue-300">
                        Catálogo possui poucos tipos de lentes. Adicione visão simples, progressivas e outras categorias.
                      </p>
                    </div>
                  {/if}

                  {#if fornecedores.length < 3}
                    <div class="p-4 bg-purple-50 dark:bg-purple-900/20 border-l-4 border-purple-500 rounded">
                      <h4 class="font-semibold text-purple-900 dark:text-purple-200 mb-2">
                        🤝 Ampliar Rede de Fornecedores
                      </h4>
                      <p class="text-sm text-purple-800 dark:text-purple-300">
                        Apenas {fornecedores.length} fornecedores ativos. Busque novos parceiros para melhorar competitividade.
                      </p>
                    </div>
                  {/if}

                  <div class="p-4 bg-green-50 dark:bg-green-900/20 border-l-4 border-green-500 rounded">
                    <h4 class="font-semibold text-green-900 dark:text-green-200 mb-2">
                      ✅ Continue Monitorando
                    </h4>
                    <p class="text-sm text-green-800 dark:text-green-300">
                      Acompanhe regularmente este dashboard para identificar tendências e oportunidades de melhoria.
                    </p>
                  </div>
                </div>
              </Container>
            </div>
          {/if}
        </div>
      </div>
  </Container>
</main>
