<!--
  📊 Página de Analytics - Dashboard de Métricas
  Relatórios e insights com dados reais usando componentes padronizados
-->
<script lang="ts">
  import { enhance } from '$app/forms';
  import { goto } from '$app/navigation';
  import type { PageData } from './$types';
  
  // Componentes padronizados
  import Header from '$lib/components/layout/Header.svelte';
  import Footer from '$lib/components/layout/Footer.svelte';
  import Container from '$lib/components/layout/Container.svelte';
  import PageHero from '$lib/components/layout/PageHero.svelte';
  import SectionHeader from '$lib/components/layout/SectionHeader.svelte';
  import StatsCard from '$lib/components/cards/StatsCard.svelte';
  import ActionCard from '$lib/components/cards/ActionCard.svelte';
  import Table from '$lib/components/ui/Table.svelte';
  import Button from '$lib/components/ui/Button.svelte';
  import Input from '$lib/components/ui/Input.svelte';
  import Badge from '$lib/components/ui/Badge.svelte';
  import LoadingSpinner from '$lib/components/ui/LoadingSpinner.svelte';
  import EmptyState from '$lib/components/ui/EmptyState.svelte';
  
  export let data: PageData;
  
  // Estado local
  let isLoading = false;
  let periodoInicio = data.periodo?.dataInicio || '';
  let periodoFim = data.periodo?.dataFim || '';
  
  // Dados computados
  $: metricas = data.performance || {};
  $: economia = data.economia || {};
  $: topFornecedores = data.topFornecedores || [];
  $: tendencias = data.tendencias || {};
  
  // Headers das tabelas
  const fornecedoresHeaders = [
    { key: 'posicao', label: '#', sortable: false },
    { key: 'nome', label: 'Fornecedor', sortable: true },
    { key: 'total_vendas', label: 'Vendas', sortable: true },
    { key: 'economia_gerada', label: 'Economia', sortable: true },
    { key: 'prazo_medio', label: 'Prazo Médio', sortable: true },
    { key: 'score_qualidade', label: 'Qualidade', sortable: true }
  ];
  
  // Funções
  function formatCurrency(value: number): string {
    if (!value) return 'R$ 0,00';
    return value.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  }
  
  function formatPercentage(value: number): string {
    if (!value) return '0%';
    return `${value.toFixed(1)}%`;
  }
  
  function getQualidadeColor(score: number): string {
    if (score >= 8) return 'success';
    if (score >= 6) return 'warning';
    return 'error';
  }
  
  function setPeriodo(dias: number) {
    const fim = new Date();
    const inicio = new Date(fim.getTime() - dias * 24 * 60 * 60 * 1000);
    
    periodoInicio = inicio.toISOString().split('T')[0];
    periodoFim = fim.toISOString().split('T')[0];
  }
  
  function aplicarPeriodo() {
    isLoading = true;
    const params = new URLSearchParams();
    if (periodoInicio) params.set('inicio', periodoInicio);
    if (periodoFim) params.set('fim', periodoFim);
    
    goto(`/analytics?${params.toString()}`);
  }
  
  // Preparar dados dos fornecedores para tabela
  $: fornecedoresData = topFornecedores.map((fornecedor, index) => ({
    ...fornecedor,
    posicao: index + 1
  }));
</script>

<svelte:head>
  <title>Analytics & Relatórios - BestLens</title>
  <meta name="description" content="Dashboard de métricas e insights de negócio com dados em tempo real" />
</svelte:head>

<div class="min-h-screen bg-neutral-50 dark:bg-neutral-900 transition-colors">
  <Header currentPage="analytics" />
  
  <main>
    <Container maxWidth="xl" padding="md">
      
      <!-- Hero Section -->
      <PageHero
        badge="📊 Business Intelligence"
        title="Analytics & Relatórios"
        subtitle="Insights e métricas detalhadas sobre decisões, economia e performance dos fornecedores"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Controles de Período -->
      <section class="mt-8">
        <div class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6 shadow-sm">
          <SectionHeader title="Período de Análise" subtitle="Selecione o período para visualizar os dados" />
          
          <div class="grid grid-cols-1 lg:grid-cols-5 gap-4 mt-6">
            <!-- Botões de Período Rápido -->
            <div class="lg:col-span-2 space-y-2">
              <span class="block text-sm font-medium text-neutral-700 dark:text-neutral-300">
                Períodos Rápidos
              </span>
              <div class="flex flex-wrap gap-2">
                <Button variant="ghost" size="sm" on:click={() => setPeriodo(7)}>
                  7 dias
                </Button>
                <Button variant="ghost" size="sm" on:click={() => setPeriodo(30)}>
                  30 dias
                </Button>
                <Button variant="ghost" size="sm" on:click={() => setPeriodo(90)}>
                  90 dias
                </Button>
              </div>
            </div>
            
            <!-- Período Customizado -->
            <Input
              label="Data Início"
              type="text"
              bind:value={periodoInicio}
              placeholder="YYYY-MM-DD"
            />
            
            <Input
              label="Data Fim"
              type="text"
              bind:value={periodoFim}
              placeholder="YYYY-MM-DD"
            />
            
            <div class="flex items-end">
              <Button
                variant="primary"
                size="md"
                fullWidth
                disabled={isLoading}
                on:click={aplicarPeriodo}
              >
                {#if isLoading}
                  <LoadingSpinner size="sm" color="white" />
                  <span class="ml-2">Carregando...</span>
                {:else}
                  📊 Aplicar
                {/if}
              </Button>
            </div>
          </div>
        </div>
      </section>

      <!-- Métricas Gerais -->
      {#if metricas && Object.keys(metricas).length > 0}
        <section class="mt-12">
          <SectionHeader title="Métricas Gerais" subtitle="Visão geral do período selecionado" />
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
            <StatsCard
              title="Total de Decisões"
              value={metricas.total_decisoes?.toString() || '0'}
              icon="📋"
              color="blue"
              trend={metricas.crescimento_decisoes}
            />
            
            <StatsCard
              title="Economia Total"
              value={formatCurrency(metricas.economia_total || 0)}
              icon="💰"
              color="green"
              trend={metricas.crescimento_economia}
            />
            
            <StatsCard
              title="Prazo Médio"
              value={`${metricas.prazo_medio || 0} dias`}
              icon="⏱️"
              color="orange"
              trend={metricas.melhoria_prazo}
            />
            
            <StatsCard
              title="Taxa de Sucesso"
              value={formatPercentage(metricas.taxa_sucesso || 0)}
              icon="✅"
              color="purple"
              trend={metricas.melhoria_sucesso}
            />
          </div>
        </section>
      {/if}

      <!-- Economia por Categoria -->
      {#if economia && Object.keys(economia).length > 0}
        <section class="mt-12">
          <SectionHeader title="Economia por Categoria" subtitle="Onde você está economizando mais" />
          
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
            <div class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100">
                  Por Tipo de Lente
                </h3>
                <Badge variant="primary" size="sm">TOP</Badge>
              </div>
              
              {#if economia.por_tipo}
                <div class="space-y-3">
                  {#each economia.por_tipo as item}
                    <div class="flex justify-between items-center">
                      <span class="text-sm text-neutral-600 dark:text-neutral-400">
                        {item.tipo}
                      </span>
                      <span class="font-medium text-green-600 dark:text-green-400">
                        {formatCurrency(item.economia)}
                      </span>
                    </div>
                  {/each}
                </div>
              {:else}
                <EmptyState
                  icon="📊"
                  title="Sem dados"
                  description="Não há dados de economia por tipo no período"
                />
              {/if}
            </div>
            
            <div class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100">
                  Por Fornecedor
                </h3>
                <Badge variant="success" size="sm">DESTAQUE</Badge>
              </div>
              
              {#if economia.por_fornecedor}
                <div class="space-y-3">
                  {#each economia.por_fornecedor as item}
                    <div class="flex justify-between items-center">
                      <span class="text-sm text-neutral-600 dark:text-neutral-400">
                        {item.nome}
                      </span>
                      <span class="font-medium text-green-600 dark:text-green-400">
                        {formatCurrency(item.economia)}
                      </span>
                    </div>
                  {/each}
                </div>
              {:else}
                <EmptyState
                  icon="🏢"
                  title="Sem dados"
                  description="Não há dados de economia por fornecedor no período"
                />
              {/if}
            </div>
            
            <div class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100">
                  Por Critério
                </h3>
                <Badge variant="warning" size="sm">ESTRATÉGIA</Badge>
              </div>
              
              {#if economia.por_criterio}
                <div class="space-y-3">
                  {#each economia.por_criterio as item}
                    <div class="flex justify-between items-center">
                      <span class="text-sm text-neutral-600 dark:text-neutral-400">
                        {item.criterio}
                      </span>
                      <span class="font-medium text-green-600 dark:text-green-400">
                        {formatCurrency(item.economia)}
                      </span>
                    </div>
                  {/each}
                </div>
              {:else}
                <EmptyState
                  icon="🎯"
                  title="Sem dados"
                  description="Não há dados de economia por critério no período"
                />
              {/if}
            </div>
          </div>
        </section>
      {/if}

      <!-- Top Fornecedores -->
      <section class="mt-12">
        <SectionHeader 
          title="Top Fornecedores" 
          subtitle={`Melhores fornecedores do período (${topFornecedores.length} encontrados)`}
        />
        
        {#if topFornecedores.length > 0}
          <div class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 overflow-hidden mt-6">
            <Table
              headers={fornecedoresHeaders}
              data={fornecedoresData}
              hoverable
              striped
            >
              <svelte:fragment slot="cell" let:row let:column>
                {#if column === 'posicao'}
                  <div class="flex items-center justify-center">
                    {#if row.posicao <= 3}
                      <span class="text-xl">
                        {row.posicao === 1 ? '🥇' : row.posicao === 2 ? '🥈' : '🥉'}
                      </span>
                    {:else}
                      <span class="font-medium text-neutral-600 dark:text-neutral-400">
                        #{row.posicao}
                      </span>
                    {/if}
                  </div>
                  
                {:else if column === 'nome'}
                  <div class="space-y-1">
                    <p class="font-medium text-neutral-900 dark:text-neutral-100">
                      {row.nome || 'N/A'}
                    </p>
                    {#if row.regiao}
                      <p class="text-xs text-neutral-500 dark:text-neutral-400">
                        {row.regiao}
                      </p>
                    {/if}
                  </div>
                  
                {:else if column === 'total_vendas'}
                  <span class="font-medium text-blue-600 dark:text-blue-400">
                    {row.total_vendas || 0}
                  </span>
                  
                {:else if column === 'economia_gerada'}
                  <span class="font-medium text-green-600 dark:text-green-400">
                    {formatCurrency(row.economia_gerada || 0)}
                  </span>
                  
                {:else if column === 'prazo_medio'}
                  <Badge variant="primary" size="sm">
                    {row.prazo_medio || 0} dias
                  </Badge>
                  
                {:else if column === 'score_qualidade'}
                  <Badge variant={getQualidadeColor(row.score_qualidade || 0)} size="sm">
                    {(row.score_qualidade || 0).toFixed(1)}
                  </Badge>
                  
                {:else}
                  {row[column] || 'N/A'}
                {/if}
              </svelte:fragment>
            </Table>
          </div>
        {:else}
          <EmptyState
            icon="📊"
            title="Nenhum fornecedor encontrado"
            description="Não há dados de fornecedores no período selecionado"
            actionLabel="Ajustar Período"
            on:action={() => setPeriodo(90)}
          />
        {/if}
      </section>

      <!-- Ações Rápidas -->
      <section class="mt-12 mb-8">
        <SectionHeader title="Ações Rápidas" />
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <ActionCard
            icon="📈"
            title="Relatório Detalhado"
            description="Baixe um relatório completo em PDF"
            actionLabel="Gerar PDF"
            color="blue"
            on:click={() => goto('/analytics/relatorio')}
          />
          
          <ActionCard
            icon="📊"
            title="Dashboard Executivo"
            description="Visão estratégica para tomada de decisão"
            actionLabel="Ver Dashboard"
            color="green"
            on:click={() => goto('/analytics/dashboard')}
          />
          
          <ActionCard
            icon="⚙️"
            title="Configurar Alertas"
            description="Receba notificações sobre métricas importantes"
            actionLabel="Configurar"
            color="orange"
            on:click={() => goto('/configuracoes/alertas')}
          />
        </div>
      </section>
       
    </Container>
  </main>
  
  <Footer />
</div>
