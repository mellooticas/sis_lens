<!--
  📊 BI e Relatórios - SIS Lens
  Central de Business Intelligence unificando Histórico e Analytics
-->
<script lang="ts">
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import { CatalogoAPI } from "$lib/api/catalogo-api";
  import { FornecedoresAPI } from "$lib/api/fornecedores-api";
  import { useStatsCatalogo } from "$lib/hooks/useStatsCatalogo";

  // State dos hooks
  const { state: statsState, carregarEstatisticas } = useStatsCatalogo();

  // Dados reativos
  $: stats = $statsState.stats;
  $: loading = $statsState.loading;

  // Dados de rankings e análises
  let topCaros: any[] = [];
  let topPopulares: any[] = [];
  let topPremium: any[] = [];
  let fornecedores: any[] = [];
  let distribuicaoTipo: any[] = [];
  let distribuicaoMaterial: any[] = [];
  let loadingExtras = true;

  onMount(() => {
    carregarEstatisticas();
    carregarDadosCompletos();
  });

  async function carregarDadosCompletos() {
    loadingExtras = true;
    try {
      const [resCaros, resPopulares, resPremium, resFornecedores, resTipo, resMaterial] = await Promise.all([
        CatalogoAPI.buscarTopCaros(10),
        CatalogoAPI.buscarTopPopulares(10),
        CatalogoAPI.buscarTopPremium(10),
        FornecedoresAPI.buscarFornecedores(),
        CatalogoAPI.obterDistribuicaoPorTipo(),
        CatalogoAPI.obterDistribuicaoPorMaterial()
      ]);

      if (resCaros.success && resCaros.data) topCaros = resCaros.data;
      if (resPopulares.success && resPopulares.data) topPopulares = resPopulares.data;
      if (resPremium.success && resPremium.data) topPremium = resPremium.data;
      if (resFornecedores.success && resFornecedores.data) fornecedores = resFornecedores.data;
      if (resTipo.success && resTipo.data) distribuicaoTipo = resTipo.data;
      if (resMaterial.success && resMaterial.data) distribuicaoMaterial = resMaterial.data;
    } catch (err) {
      console.error('Erro ao carregar dados de BI:', err);
    } finally {
      loadingExtras = false;
    }
  }

  function formatNumber(value: number): string {
    if (!value) return "0";
    return value.toLocaleString("pt-BR");
  }

  function formatarPreco(valor: number): string {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor);
  }

  function formatarTexto(texto: string): string {
    if (!texto) return '';
    return texto
      .split('_')
      .map(palavra => palavra.charAt(0).toUpperCase() + palavra.slice(1).toLowerCase())
      .join(' ');
  }

  function calcularPercentual(valor: number, total: number): number {
    if (!total || total === 0) return 0;
    return Math.round((valor / total) * 100);
  }
</script>

<svelte:head>
  <title>BI e Relatórios | SIS Lens</title>
  <meta name="description" content="Central de Business Intelligence e Relatórios do Sistema SIS Lens" />
</svelte:head>

<main class="min-h-screen bg-gradient-to-br from-neutral-50 via-blue-50 to-neutral-100 dark:from-neutral-900 dark:via-neutral-800 dark:to-neutral-900">
  <Container>
    <PageHero
      title="📊 BI e Relatórios"
      description="Central de Business Intelligence com dados reais do catálogo de lentes"
    />

    {#if loading || loadingExtras}
      <div class="flex justify-center items-center py-20">
        <LoadingSpinner size="lg" />
      </div>
    {:else}
      <!-- Visão Geral Executiva -->
      <section class="mt-8">
        <SectionHeader
          title="📈 Visão Geral Executiva"
          subtitle="Principais indicadores do sistema"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
          <StatsCard
            title="Total de Lentes"
            value={formatNumber(stats?.total_lentes || 0)}
            icon="👓"
            color="blue"
          />
          <StatsCard
            title="Grupos Canônicos"
            value={formatNumber(topPopulares.length > 0 ? topPopulares.reduce((sum, g) => sum + (g.total_lentes || 0), 0) : 0)}
            icon="📦"
            color="green"
          />
          <StatsCard
            title="Fornecedores Ativos"
            value={formatNumber(fornecedores.length)}
            icon="🏭"
            color="orange"
          />
          <StatsCard
            title="Marcas Disponíveis"
            value={formatNumber(stats?.total_marcas || 0)}
            icon="🏷️"
            color="purple"
          />
        </div>
      </section>

      <!-- Análise de Precificação -->
      <section class="mt-12">
        <SectionHeader
          title="💰 Análise de Precificação"
          subtitle="Faixas de preço e distribuição no catálogo"
        />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <div class="flex items-center justify-between mb-4">
              <span class="text-sm font-medium text-neutral-600 dark:text-neutral-400">Preço Mínimo</span>
              <span class="text-2xl">💵</span>
            </div>
            <p class="text-3xl font-bold text-green-600 dark:text-green-400">
              {stats?.preco_minimo ? formatarPreco(stats.preco_minimo) : '-'}
            </p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400 mt-2">Entrada mais acessível</p>
          </div>

          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <div class="flex items-center justify-between mb-4">
              <span class="text-sm font-medium text-neutral-600 dark:text-neutral-400">Preço Médio</span>
              <span class="text-2xl">📊</span>
            </div>
            <p class="text-3xl font-bold text-blue-600 dark:text-blue-400">
              {stats?.preco_medio ? formatarPreco(stats.preco_medio) : '-'}
            </p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400 mt-2">Média do catálogo</p>
          </div>

          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <div class="flex items-center justify-between mb-4">
              <span class="text-sm font-medium text-neutral-600 dark:text-neutral-400">Preço Máximo</span>
              <span class="text-2xl">💎</span>
            </div>
            <p class="text-3xl font-bold text-amber-600 dark:text-amber-400">
              {stats?.preco_maximo ? formatarPreco(stats.preco_maximo) : '-'}
            </p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400 mt-2">Premium mais caro</p>
          </div>
        </div>
      </section>

      <!-- Top 10 Rankings -->
      <section class="mt-12">
        <SectionHeader
          title="🏆 Rankings do Catálogo"
          subtitle="Top 10 grupos em diferentes categorias"
        />

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-6">
          <!-- Top 10 Mais Caros -->
          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-neutral-900 dark:text-white">💰 Mais Caros</h3>
              <button
                on:click={() => goto('/ranking')}
                class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400"
              >
                Ver mais →
              </button>
            </div>
            <div class="space-y-2">
              {#each topCaros.slice(0, 10) as grupo, index}
                <div class="flex items-center gap-2 p-2 rounded-lg bg-neutral-50 dark:bg-neutral-700/50 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors">
                  <span class="flex-shrink-0 w-6 h-6 flex items-center justify-center rounded-full bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 font-bold text-xs">
                    {index + 1}
                  </span>
                  <div class="flex-1 min-w-0">
                    <p class="text-xs font-semibold text-neutral-900 dark:text-white truncate">{grupo.nome_grupo}</p>
                    <p class="text-xs text-neutral-500 dark:text-neutral-400">{grupo.total_lentes} lentes</p>
                  </div>
                  <span class="flex-shrink-0 text-xs font-bold text-amber-600 dark:text-amber-400">
                    {formatarPreco(grupo.preco_medio)}
                  </span>
                </div>
              {/each}
            </div>
          </div>

          <!-- Top 10 Mais Populares -->
          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-neutral-900 dark:text-white">🔥 Mais Populares</h3>
              <button
                on:click={() => goto('/ranking')}
                class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400"
              >
                Ver mais →
              </button>
            </div>
            <div class="space-y-2">
              {#each topPopulares.slice(0, 10) as grupo, index}
                <div class="flex items-center gap-2 p-2 rounded-lg bg-neutral-50 dark:bg-neutral-700/50 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors">
                  <span class="flex-shrink-0 w-6 h-6 flex items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 font-bold text-xs">
                    {index + 1}
                  </span>
                  <div class="flex-1 min-w-0">
                    <p class="text-xs font-semibold text-neutral-900 dark:text-white truncate">{grupo.nome_grupo}</p>
                    <p class="text-xs text-neutral-500 dark:text-neutral-400">{formatarPreco(grupo.preco_medio)}</p>
                  </div>
                  <span class="flex-shrink-0 text-xs font-bold text-green-600 dark:text-green-400">
                    {grupo.total_lentes} un
                  </span>
                </div>
              {/each}
            </div>
          </div>

          <!-- Top 10 Premium -->
          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-neutral-900 dark:text-white">⭐ Premium</h3>
              <button
                on:click={() => goto('/ranking')}
                class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400"
              >
                Ver mais →
              </button>
            </div>
            <div class="space-y-2">
              {#each topPremium.slice(0, 10) as grupo, index}
                <div class="flex items-center gap-2 p-2 rounded-lg bg-neutral-50 dark:bg-neutral-700/50 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors">
                  <span class="flex-shrink-0 w-6 h-6 flex items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400 font-bold text-xs">
                    {index + 1}
                  </span>
                  <div class="flex-1 min-w-0">
                    <p class="text-xs font-semibold text-neutral-900 dark:text-white truncate">{grupo.nome_grupo}</p>
                    <p class="text-xs text-neutral-500 dark:text-neutral-400">{formatarTexto(grupo.tipo_lente)}</p>
                  </div>
                  <span class="flex-shrink-0 text-xs font-bold text-purple-600 dark:text-purple-400">
                    {formatarPreco(grupo.preco_medio)}
                  </span>
                </div>
              {/each}
            </div>
          </div>
        </div>
      </section>

      <!-- Distribuição por Tipo e Material -->
      <section class="mt-12">
        <SectionHeader
          title="📊 Análise de Distribuição"
          subtitle="Composição do catálogo por tipo de lente e material"
        />

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
          <!-- Por Tipo -->
          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-4">Por Tipo de Lente</h3>
            <div class="space-y-3">
              {#each distribuicaoTipo as item}
                {@const percentual = calcularPercentual(item.quantidade, stats?.total_lentes || 0)}
                <div>
                  <div class="flex justify-between items-center mb-1">
                    <span class="text-sm font-medium text-neutral-700 dark:text-neutral-300">
                      {formatarTexto(item.tipo)}
                    </span>
                    <span class="text-sm text-neutral-600 dark:text-neutral-400">
                      {formatNumber(item.quantidade)} ({percentual}%)
                    </span>
                  </div>
                  <div class="w-full bg-neutral-200 dark:bg-neutral-700 rounded-full h-2">
                    <div
                      class="bg-gradient-to-r from-blue-500 to-blue-600 h-2 rounded-full transition-all duration-500"
                      style="width: {percentual}%"
                    ></div>
                  </div>
                </div>
              {/each}
            </div>
          </div>

          <!-- Por Material -->
          <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
            <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-4">Por Material</h3>
            <div class="space-y-3">
              {#each distribuicaoMaterial as item}
                {@const percentual = calcularPercentual(item.quantidade, stats?.total_lentes || 0)}
                <div>
                  <div class="flex justify-between items-center mb-1">
                    <span class="text-sm font-medium text-neutral-700 dark:text-neutral-300">
                      {formatarTexto(item.material)}
                    </span>
                    <span class="text-sm text-neutral-600 dark:text-neutral-400">
                      {formatNumber(item.quantidade)} ({percentual}%)
                    </span>
                  </div>
                  <div class="w-full bg-neutral-200 dark:bg-neutral-700 rounded-full h-2">
                    <div
                      class="bg-gradient-to-r from-green-500 to-green-600 h-2 rounded-full transition-all duration-500"
                      style="width: {percentual}%"
                    ></div>
                  </div>
                </div>
              {/each}
            </div>
          </div>
        </div>
      </section>

      <!-- Performance de Fornecedores -->
      <section class="mt-12">
        <SectionHeader
          title="🏭 Performance de Fornecedores"
          subtitle="Análise comparativa dos distribuidores"
        />

        <div class="bg-white dark:bg-neutral-800 rounded-xl shadow-lg border border-neutral-200 dark:border-neutral-700 overflow-hidden mt-6">
          <div class="overflow-x-auto">
            <table class="w-full">
              <thead class="bg-neutral-100 dark:bg-neutral-700/50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-neutral-700 dark:text-neutral-300 uppercase tracking-wider">Fornecedor</th>
                  <th class="px-6 py-3 text-center text-xs font-medium text-neutral-700 dark:text-neutral-300 uppercase tracking-wider">Código</th>
                  <th class="px-6 py-3 text-center text-xs font-medium text-neutral-700 dark:text-neutral-300 uppercase tracking-wider">Lentes</th>
                  <th class="px-6 py-3 text-center text-xs font-medium text-neutral-700 dark:text-neutral-300 uppercase tracking-wider">Marcas</th>
                  <th class="px-6 py-3 text-center text-xs font-medium text-neutral-700 dark:text-neutral-300 uppercase tracking-wider">Status</th>
                  <th class="px-6 py-3 text-center text-xs font-medium text-neutral-700 dark:text-neutral-300 uppercase tracking-wider">Ações</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-neutral-200 dark:divide-neutral-700">
                {#each fornecedores as fornecedor}
                  <tr class="hover:bg-neutral-50 dark:hover:bg-neutral-700/30 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm font-medium text-neutral-900 dark:text-white">{fornecedor.nome}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center">
                      <span class="text-sm text-neutral-600 dark:text-neutral-400">{fornecedor.codigo}</span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center">
                      <span class="text-sm font-semibold text-blue-600 dark:text-blue-400">{formatNumber(fornecedor.total_lentes || 0)}</span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center">
                      <span class="text-sm text-neutral-600 dark:text-neutral-400">{fornecedor.marcas_diferentes_usadas || 0}</span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center">
                      <span class="px-2 py-1 text-xs font-medium rounded-full {fornecedor.is_ativo ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400' : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'}">
                        {fornecedor.is_ativo ? 'Ativo' : 'Inativo'}
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-center">
                      <button
                        on:click={() => goto('/fornecedores')}
                        class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 font-medium"
                      >
                        Detalhes →
                      </button>
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      <!-- Ações Rápidas -->
      <section class="mt-12 mb-8">
        <div class="flex flex-wrap gap-4 justify-center">
          <button
            on:click={() => goto('/dashboard')}
            class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors shadow-lg"
          >
            📊 Dashboard
          </button>
          
          <button
            on:click={() => goto('/ranking')}
            class="px-6 py-3 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-medium transition-colors shadow-lg"
          >
            🏆 Rankings Completos
          </button>
          
          <button
            on:click={() => goto('/fornecedores')}
            class="px-6 py-3 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition-colors shadow-lg"
          >
            🏭 Gerenciar Fornecedores
          </button>
          
          <button
            on:click={() => goto('/catalogo')}
            class="px-6 py-3 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-medium transition-colors shadow-lg"
          >
            🔍 Buscar no Catálogo
          </button>
        </div>
      </section>
    {/if}
  </Container>
</main>
