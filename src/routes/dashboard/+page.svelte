<!--
  🏠 Dashboard Principal - SIS Lens
  Visão geral completa do sistema decisor de lentes
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // APIs
  import { CatalogoAPI } from "$lib/api/catalogo-api";
  import { FornecedoresAPI } from "$lib/api/fornecedores-api";

  // Estado local
  let loading = false;
  let loadingExtras = true;
  let currentTime = new Date();
  
  // Dados principais - agora da view vw_stats_catalogo unificada
  let stats: any = null;
  
  // Dados adicionais
  let topCaros: any[] = [];
  let topPopulares: any[] = [];
  let fornecedoresAtivos = 0;

  // Carregar dados e atualizar relógio
  onMount(() => {
    // Carregar dados iniciais
    carregarEstatisticas();
    carregarDadosExtras();

    const interval = setInterval(() => {
      currentTime = new Date();
    }, 1000);

    return () => clearInterval(interval);
  });
  
  // Carregar estatísticas unificadas da view vw_stats_catalogo
  async function carregarEstatisticas() {
    loading = true;
    try {
      const response = await CatalogoAPI.obterEstatisticas();
      if (response.success && response.data) {
        stats = response.data;
      }
    } catch (err) {
      console.error('Erro ao carregar estatísticas:', err);
    } finally {
      loading = false;
    }
  }
  
  async function carregarDadosExtras() {
    loadingExtras = true;
    try {
      // Buscar top 5 mais caros e populares + fornecedores
      const [
        resCaros, 
        resPopulares, 
        resFornecedores
      ] = await Promise.all([
        CatalogoAPI.buscarTopCaros(5),
        CatalogoAPI.buscarTopPopulares(5),
        FornecedoresAPI.buscarFornecedores()
      ]);
      
      if (resCaros.success && resCaros.data) topCaros = resCaros.data;
      if (resPopulares.success && resPopulares.data) topPopulares = resPopulares.data;
      if (resFornecedores.success && resFornecedores.data) {
        fornecedoresAtivos = resFornecedores.data.length;
      }
    } catch (err) {
      console.error('Erro ao carregar dados extras:', err);
    } finally {
      loadingExtras = false;
    }
  }

  // Funções utilitárias
  function formatNumber(value: number): string {
    if (!value) return "0";
    return value.toLocaleString("pt-BR");
  }
  
  function formatarPreco(valor: number | null): string {
    if (!valor) return 'N/A';
    return new Intl.NumberFormat('pt-BR', { 
      style: 'currency', 
      currency: 'BRL' 
    }).format(valor);
  }
  
  function formatarTexto(texto: string | null): string {
    if (!texto) return 'N/A';
    return texto.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
  }
</script>

<svelte:head>
  <title>Dashboard - SIS Lens</title>
  <meta name="description" content="Dashboard principal do sistema decisor de lentes" />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero Section -->
    <PageHero
      badge="🏠 Dashboard"
      title="Sistema Decisor de Lentes"
      subtitle={`Última atualização: ${currentTime.toLocaleTimeString('pt-BR')}`}
      alignment="center"
      maxWidth="lg"
    />

    <!-- Estatísticas Principais -->
    {#if loading}
      <div class="flex justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    {:else if stats}
      <section class="mt-8">
        <SectionHeader
          title="📊 Visão Geral do Catálogo"
          subtitle="Estatísticas atualizadas em tempo real"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
          <StatsCard
            title="Total de Lentes"
            value={formatNumber(stats?.total_lentes || 0)}
            icon="👓"
            color="blue"
          />

          <StatsCard
            title="Lentes Premium"
            value={formatNumber(stats?.grupos_premium || 0)}
            icon="⭐"
            color="orange"
            subtitle="Grupos premium no catálogo"
          />

          <StatsCard
            title="Fornecedores"
            value={formatNumber(fornecedoresAtivos)}
            icon="🏭"
            color="green"
          />

          <StatsCard
            title="Marcas"
            value={formatNumber(stats?.total_marcas || 0)}
            icon="🏷️"
            color="gold"
          />
        </div>
      </section>
      
      <!-- Top Lentes -->
      {#if !loadingExtras}
        <section class="mt-8">
          <SectionHeader
            title="🏆 Destaques do Catálogo"
            subtitle="Lentes mais relevantes por diferentes critérios"
          />

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
            <!-- Top 5 Mais Caras -->
            <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-bold text-neutral-900 dark:text-white">💰 Top 5 Mais Caras</h3>
                <button
                  on:click={() => goto('/ranking')}
                  class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 font-medium"
                >
                  Ver todas →
                </button>
              </div>
              <div class="space-y-3">
                {#each topCaros as grupo, index}
                  <div class="flex items-center gap-3 p-3 rounded-lg bg-neutral-50 dark:bg-neutral-700/50 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors">
                    <span class="flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 font-bold text-sm">
                      #{index + 1}
                    </span>
                    <div class="flex-1 min-w-0">
                      <p class="text-sm font-semibold text-neutral-900 dark:text-white truncate">{grupo.nome_grupo}</p>
                      <p class="text-xs text-neutral-500 dark:text-neutral-400">{formatarTexto(grupo.tipo_lente)} • {grupo.total_lentes} lentes</p>
                    </div>
                    <span class="flex-shrink-0 text-sm font-bold text-amber-600 dark:text-amber-400">
                      {formatarPreco(grupo.preco_medio)}
                    </span>
                  </div>
                {/each}
              </div>
            </div>

            <!-- Top 5 Mais Populares -->
            <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-bold text-neutral-900 dark:text-white">🔥 Top 5 Mais Populares</h3>
                <button
                  on:click={() => goto('/ranking')}
                  class="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 font-medium"
                >
                  Ver todas →
                </button>
              </div>
              <div class="space-y-3">
                {#each topPopulares as grupo, index}
                  <div class="flex items-center gap-3 p-3 rounded-lg bg-neutral-50 dark:bg-neutral-700/50 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors">
                    <span class="flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 font-bold text-sm">
                      #{index + 1}
                    </span>
                    <div class="flex-1 min-w-0">
                      <p class="text-sm font-semibold text-neutral-900 dark:text-white truncate">{grupo.nome_grupo}</p>
                      <p class="text-xs text-neutral-500 dark:text-neutral-400">{formatarTexto(grupo.tipo_lente)} • {formatarPreco(grupo.preco_medio)}</p>
                    </div>
                    <span class="flex-shrink-0 text-sm font-bold text-green-600 dark:text-green-400">
                      {grupo.total_lentes} lentes
                    </span>
                  </div>
                {/each}
              </div>
            </div>
          </div>
        </section>
      {/if}

      <!-- Estatísticas por Tipo -->
      <section class="mt-8">
        <SectionHeader
          title="📈 Distribuição por Tipo"
          subtitle="Categorização das lentes no catálogo"
        />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <StatsCard
            title="Visão Simples"
            value={formatNumber(stats?.total_visao_simples || 0)}
            icon="👓"
            color="blue"
          />

          <StatsCard
            title="Multifocais"
            value={formatNumber(stats?.total_multifocal || 0)}
            icon="🔄"
            color="green"
          />

          <StatsCard
            title="Bifocais"
            value={formatNumber(stats?.total_bifocal || 0)}
            icon="👁️"
            color="orange"
          />
        </div>
      </section>

      <!-- Estatísticas por Material -->
      <section class="mt-8">
        <SectionHeader
          title="🔬 Distribuição por Material"
          subtitle="Materiais das lentes disponíveis"
        />

        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mt-6">
          <StatsCard
            title="CR-39"
            value={formatNumber(stats?.total_cr39 || 0)}
            icon="🔵"
            color="blue"
          />

          <StatsCard
            title="Policarbonato"
            value={formatNumber(stats?.total_policarbonato || 0)}
            icon="💪"
            color="green"
          />

          <StatsCard
            title="Trivex"
            value={formatNumber(stats?.total_trivex || 0)}
            icon="⚡"
            color="purple"
          />

          <StatsCard
            title="High Index"
            value={formatNumber(stats?.total_high_index || 0)}
            icon="✨"
            color="gold"
          />
        </div>
      </section>

      <!-- Tratamentos Especiais -->
      <section class="mt-8">
        <SectionHeader
          title="✨ Tratamentos e Recursos"
          subtitle="Tecnologias aplicadas nas lentes"
        />

        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mt-6">
          <StatsCard
            title="Anti-Reflexo"
            value={formatNumber(stats?.total_com_ar || 0)}
            icon="💎"
            color="blue"
          />

          <StatsCard
            title="Blue Light"
            value={formatNumber(stats?.total_com_blue || 0)}
            icon="🔵"
            color="cyan"
          />

          <StatsCard
            title="Fotossensíveis"
            value={formatNumber(stats?.total_fotossensiveis || 0)}
            icon="☀️"
            color="orange"
          />

          <StatsCard
            title="Polarizadas"
            value={formatNumber(stats?.total_polarizado || 0)}
            icon="🕶️"
            color="purple"
          />
        </div>
      </section>

      <!-- Tecnologia -->
      <section class="mt-8">
        <SectionHeader
          title="🎯 Tecnologias Avançadas"
          subtitle="Manufatura e processos especiais"
        />

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          <StatsCard
            title="Free-Form"
            value="0"
            icon="🔧"
            color="blue"
            subtitle="Campo não disponível"
          />

          <StatsCard
            title="Digitais"
            value="0"
            icon="💻"
            color="green"
            subtitle="Campo não disponível"
          />
        </div>
      </section>

      <!-- Faixa de Preços -->
      <section class="mt-8">
        <SectionHeader
          title="💰 Faixa de Preços"
          subtitle="Range de valores do catálogo"
        />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <StatsCard
            title="Preço Mínimo"
            value={formatarPreco(stats?.preco_minimo_catalogo)}
            icon="⬇️"
            color="green"
          />

          <StatsCard
            title="Preço Médio"
            value={formatarPreco(stats?.preco_medio_catalogo)}
            icon="📊"
            color="blue"
          />

          <StatsCard
            title="Preço Máximo"
            value={formatarPreco(stats?.preco_maximo_catalogo)}
            icon="⬆️"
            color="orange"
          />
        </div>
      </section>
    {/if}

    <!-- Ações Rápidas -->
    <section class="mt-12">
      <SectionHeader
        title="⚡ Ações Rápidas"
        subtitle="Acesse rapidamente as funcionalidades principais"
      />

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
        <button
          on:click={() => goto('/catalogo')}
          class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700 hover:shadow-xl transition-all hover:scale-105"
        >
          <div class="text-4xl mb-3">🔍</div>
          <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-2">Buscar Lentes</h3>
          <p class="text-sm text-neutral-600 dark:text-neutral-400">Pesquise no catálogo completo de {formatNumber(stats?.total_lentes || 0)} lentes</p>
        </button>

        <button
          on:click={() => goto('/ranking')}
          class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700 hover:shadow-xl transition-all hover:scale-105"
        >
          <div class="text-4xl mb-3">🏆</div>
          <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-2">Ver Rankings</h3>
          <p class="text-sm text-neutral-600 dark:text-neutral-400">Consulte os grupos mais caros e populares</p>
        </button>

        <button
          on:click={() => goto('/fornecedores')}
          class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700 hover:shadow-xl transition-all hover:scale-105"
        >
          <div class="text-4xl mb-3">🏭</div>
          <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-2">Fornecedores</h3>
          <p class="text-sm text-neutral-600 dark:text-neutral-400">Gerencie {formatNumber(fornecedoresAtivos)} fornecedores ativos</p>
        </button>

        <button
          on:click={() => goto('/simulador/receita')}
          class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-lg border border-neutral-200 dark:border-neutral-700 hover:shadow-xl transition-all hover:scale-105"
        >
          <div class="text-4xl mb-3">⚡</div>
          <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-2">Simulador</h3>
          <p class="text-sm text-neutral-600 dark:text-neutral-400">Encontre a lente ideal pela receita</p>
        </button>
      </div>
    </section>
  </Container>
</main>
