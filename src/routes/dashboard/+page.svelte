<!--
  🏠 Dashboard Principal - BestLens
  Visão geral completa do sistema decisor de lentes
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";
  import type { PageData } from "./$types";

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";
  import Table from "$lib/components/ui/Table.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  export let data: PageData;

  // Estado local
  let currentTime = new Date();
  let isLoading = false;

  // Dados computados
  $: estatisticas = data.estatisticas || {};
  $: decisoesRecentes = data.decisoes_recentes || [];
  $: topLentes = data.top_lentes || [];
  $: topMarcas = data.top_marcas || [];
  $: disponibilidade = data.disponibilidade || {};
  $: tendenciasMensais = data.tendencias_mensais || [];
  $: atividadeRecente = data.atividade_recente || {};
  $: alertas = data.alertas || [];

  // Atualizar relógio
  onMount(() => {
    const interval = setInterval(() => {
      currentTime = new Date();
    }, 1000);

    return () => clearInterval(interval);
  });

  // Funções utilitárias
  function formatCurrency(value: number): string {
    if (!value) return "R$ 0,00";
    return value.toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
    });
  }

  function formatNumber(value: number): string {
    if (!value) return "0";
    return value.toLocaleString("pt-BR");
  }

  function formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  function getMarcaColor(marca: string): string {
    const cores = {
      essilor: "primary",
      zeiss: "success",
      hoya: "warning",
      kodak: "orange",
      default: "primary",
    };
    return cores[marca?.toLowerCase()] || cores.default;
  }

  function getTipoColor(tipo: string): string {
    switch (tipo?.toLowerCase()) {
      case "progressive":
        return "primary";
      case "bifocal":
        return "orange";
      case "single":
        return "success";
      default:
        return "primary";
    }
  }

  function getAlertColor(tipo: string): string {
    switch (tipo) {
      case "success":
        return "success";
      case "warning":
        return "warning";
      case "error":
        return "error";
      default:
        return "primary";
    }
  }

  function getDisponibilidadeColor(status: string): string {
    switch (status?.toLowerCase()) {
      case "disponivel":
        return "success";
      case "limitado":
        return "warning";
      case "indisponivel":
        return "error";
      default:
        return "primary";
    }
  }

  // Headers para tabelas
  const decisoesHeaders = [
    { key: "lente", label: "Lente", sortable: false },
    { key: "marca", label: "Marca", sortable: false },
    { key: "economia", label: "Economia", sortable: false },
    { key: "confianca", label: "Confiança", sortable: false },
    { key: "data", label: "Data", sortable: false },
  ];

  const lentesHeaders = [
    { key: "familia", label: "Lente", sortable: false },
    { key: "marca", label: "Marca", sortable: false },
    { key: "tipo", label: "Tipo", sortable: false },
    { key: "recomendacoes", label: "Recomendações", sortable: false },
  ];

  // Funções de navegação
  function irPara(rota: string) {
    goto(rota);
  }

  function atualizarDashboard() {
    isLoading = true;
    // Simular atualização
    setTimeout(() => {
      window.location.reload();
    }, 1000);
  }
</script>

<svelte:head>
  <title>Dashboard - BestLens</title>
  <meta
    name="description"
    content="Painel principal do sistema decisor de lentes BestLens"
  />
</svelte:head>

<Container maxWidth="xl" padding="md">
  <!-- Hero Section -->

  <!-- Estatísticas Principais -->
  <section class="mt-8">
    <SectionHeader
      title="📊 Visão Geral"
      subtitle="Estatísticas principais do sistema"
    />

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
      <StatsCard
        title="Lentes no Catálogo"
        value={formatNumber(estatisticas.total_lentes)}
        icon="👓"
        color="blue"
        subtitle="Total disponível"
      />

      <StatsCard
        title="Marcas Parceiras"
        value={formatNumber(estatisticas.total_marcas)}
        icon="🏷️"
        color="green"
        subtitle="Fornecedores ativos"
      />

      <StatsCard
        title="Decisões Tomadas"
        value={formatNumber(estatisticas.total_decisoes)}
        icon="🎯"
        color="orange"
        subtitle="Recomendações feitas"
      />

      <StatsCard
        title="Economia Total"
        value={formatCurrency(estatisticas.economia_total)}
        icon="💰"
        color="purple"
        subtitle="Valor economizado"
      />
    </div>
  </section>

  <!-- Atividade Hoje -->
  <section class="mt-12">
    <SectionHeader
      title="⚡ Atividade de Hoje"
      subtitle="Movimentação do sistema nas últimas 24h"
    />

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
      <StatsCard
        title="Decisões Hoje"
        value={formatNumber(atividadeRecente.decisoes_hoje)}
        icon="🎯"
        color="blue"
        subtitle="Recomendações feitas"
      />

      <StatsCard
        title="Economia Hoje"
        value={formatCurrency(atividadeRecente.economia_hoje)}
        icon="💵"
        color="green"
        subtitle="Valor economizado"
      />

      <StatsCard
        title="Lentes Consultadas"
        value={formatNumber(atividadeRecente.lentes_consultadas)}
        icon="🔍"
        color="orange"
        subtitle="Produtos pesquisados"
      />

      <StatsCard
        title="Fornecedores Ativos"
        value={formatNumber(atividadeRecente.fornecedores_ativos)}
        icon="🏪"
        color="purple"
        subtitle="Parceiros online"
      />
    </div>
  </section>

  <!-- Preços e Qualidade -->
  <section class="mt-12">
    <SectionHeader
      title="💎 Qualidade e Preços"
      subtitle="Informações sobre o catálogo de lentes"
    />

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <StatsCard
        title="Preço Médio"
        value={formatCurrency(estatisticas.preco_medio)}
        icon="📊"
        color="blue"
        subtitle="Valor médio das lentes"
      />

      <StatsCard
        title="Faixa de Preços"
        value={`${formatCurrency(estatisticas.preco_min)} - ${formatCurrency(estatisticas.preco_max)}`}
        icon="💹"
        color="green"
        subtitle="Menor e maior preço"
      />

      <StatsCard
        title="Confiança Média"
        value={`${estatisticas.confianca_media}%`}
        icon="🎯"
        color="orange"
        subtitle="Precisão das recomendações"
      />
    </div>
  </section>

  <!-- Disponibilidade -->
  {#if Object.keys(disponibilidade).length > 0}
    <section class="mt-12">
      <SectionHeader
        title="📦 Status de Disponibilidade"
        subtitle="Situação atual do estoque"
      />

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
        {#each Object.entries(disponibilidade) as [status, count]}
          <StatsCard
            title={status.charAt(0).toUpperCase() + status.slice(1)}
            value={formatNumber(count)}
            icon={status === "disponivel"
              ? "✅"
              : status === "limitado"
                ? "⚠️"
                : "❌"}
            color={getDisponibilidadeColor(status)}
            subtitle="lentes"
          />
        {/each}
      </div>
    </section>
  {/if}

  <!-- Layout de duas colunas -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-12">
    <!-- Coluna Esquerda -->
    <div class="space-y-8">
      <!-- Decisões Recentes -->
      <section>
        <div class="glass-panel rounded-xl p-6 shadow-xl">
          <SectionHeader
            title="🕒 Decisões Recentes"
            subtitle="Últimas recomendações do sistema"
          />

          {#if decisoesRecentes.length > 0}
            <div class="mt-6">
              <Table
                headers={decisoesHeaders}
                data={decisoesRecentes}
                hoverable
                size="sm"
              >
                <svelte:fragment slot="cell" let:row let:column>
                  {#if column === "lente"}
                    <div class="space-y-1">
                      <p
                        class="font-medium text-neutral-900 dark:text-neutral-100 text-sm"
                      >
                        {row.lentes_catalogo?.familia || "N/A"}
                      </p>
                      <p class="text-xs text-neutral-500 dark:text-neutral-400">
                        {row.lentes_catalogo?.tipo_lente || "N/A"}
                      </p>
                    </div>
                  {:else if column === "marca"}
                    <Badge
                      variant={getMarcaColor(row.lentes_catalogo?.marca_nome)}
                      size="sm"
                    >
                      {row.lentes_catalogo?.marca_nome || "N/A"}
                    </Badge>
                  {:else if column === "economia"}
                    <span
                      class="font-medium text-green-600 dark:text-green-400 text-sm"
                    >
                      {formatCurrency(row.economia_estimada || 0)}
                    </span>
                  {:else if column === "confianca"}
                    <span
                      class="font-medium text-blue-600 dark:text-blue-400 text-sm"
                    >
                      {Math.round((row.confianca_score || 0) * 100)}%
                    </span>
                  {:else if column === "data"}
                    <span
                      class="text-xs text-neutral-500 dark:text-neutral-400"
                    >
                      {formatDate(row.created_at)}
                    </span>
                  {:else}
                    {row[column] || "N/A"}
                  {/if}
                </svelte:fragment>
              </Table>
            </div>

            <div class="mt-4 text-center">
              <Button
                variant="ghost"
                size="sm"
                on:click={() => irPara("/historico")}
              >
                Ver Histórico Completo →
              </Button>
            </div>
          {:else}
            <div class="text-center py-8">
              <p class="text-neutral-500 dark:text-neutral-400">
                Nenhuma decisão recente encontrada
              </p>
            </div>
          {/if}
        </div>
      </section>

      <!-- Top Marcas -->
      <section>
        <div class="glass-panel rounded-xl p-6 shadow-xl">
          <SectionHeader
            title="🏆 Top Marcas"
            subtitle="Marcas mais recomendadas"
          />

          {#if topMarcas.length > 0}
            <div class="space-y-3 mt-6">
              {#each topMarcas as marca, index}
                <div
                  class="flex items-center justify-between p-3 bg-neutral-50 dark:bg-neutral-900 rounded-lg"
                >
                  <div class="flex items-center gap-3">
                    <span
                      class="text-sm font-bold text-neutral-500 dark:text-neutral-400 w-6"
                    >
                      #{index + 1}
                    </span>
                    <Badge variant={getMarcaColor(marca.marca)} size="sm">
                      {marca.marca}
                    </Badge>
                  </div>
                  <span
                    class="text-sm font-medium text-neutral-600 dark:text-neutral-400"
                  >
                    {formatNumber(marca.count)} lentes
                  </span>
                </div>
              {/each}
            </div>

            <div class="mt-4 text-center">
              <Button
                variant="ghost"
                size="sm"
                on:click={() => irPara("/analytics")}
              >
                Ver Analytics Completo →
              </Button>
            </div>
          {:else}
            <div class="text-center py-8">
              <p class="text-neutral-500 dark:text-neutral-400">
                Dados não disponíveis
              </p>
            </div>
          {/if}
        </div>
      </section>
    </div>

    <!-- Coluna Direita -->
    <div class="space-y-8">
      <!-- Top Lentes -->
      <section>
        <div class="glass-panel rounded-xl p-6 shadow-xl">
          <SectionHeader
            title="🌟 Lentes Mais Recomendadas"
            subtitle="Top 5 produtos do mês"
          />

          {#if topLentes.length > 0}
            <div class="mt-6">
              <Table
                headers={lentesHeaders}
                data={topLentes}
                hoverable
                size="sm"
              >
                <svelte:fragment slot="cell" let:row let:column>
                  {#if column === "familia"}
                    <div class="space-y-1">
                      <p
                        class="font-medium text-neutral-900 dark:text-neutral-100 text-sm"
                      >
                        {row.familia || "N/A"}
                      </p>
                      <p class="text-xs text-neutral-500 dark:text-neutral-400">
                        {formatCurrency(row.preco_base || 0)}
                      </p>
                    </div>
                  {:else if column === "marca"}
                    <Badge variant={getMarcaColor(row.marca_nome)} size="sm">
                      {row.marca_nome || "N/A"}
                    </Badge>
                  {:else if column === "tipo"}
                    <Badge variant={getTipoColor(row.tipo_lente)} size="sm">
                      {row.tipo_lente || "N/A"}
                    </Badge>
                  {:else if column === "recomendacoes"}
                    <span
                      class="font-medium text-blue-600 dark:text-blue-400 text-sm"
                    >
                      {formatNumber(row.count || 0)}×
                    </span>
                  {:else}
                    {row[column] || "N/A"}
                  {/if}
                </svelte:fragment>
              </Table>
            </div>

            <div class="mt-4 text-center">
              <Button
                variant="ghost"
                size="sm"
                on:click={() => irPara("/ranking")}
              >
                Ver Ranking Completo →
              </Button>
            </div>
          {:else}
            <div class="text-center py-8">
              <p class="text-neutral-500 dark:text-neutral-400">
                Dados não disponíveis
              </p>
            </div>
          {/if}
        </div>
      </section>

      <!-- Alertas -->
      {#if alertas.length > 0}
        <section>
          <div class="glass-panel rounded-xl p-6 shadow-xl">
            <SectionHeader
              title="🔔 Alertas e Notificações"
              subtitle="Informações importantes do sistema"
            />

            <div class="space-y-3 mt-6">
              {#each alertas as alerta}
                <div
                  class="p-4 border border-neutral-200 dark:border-neutral-700 rounded-lg"
                >
                  <div class="flex items-start gap-3">
                    <Badge variant={getAlertColor(alerta.tipo)} size="sm">
                      {alerta.tipo}
                    </Badge>
                    <div class="flex-1 space-y-1">
                      <h4
                        class="font-medium text-neutral-900 dark:text-neutral-100 text-sm"
                      >
                        {alerta.titulo}
                      </h4>
                      <p class="text-sm text-neutral-600 dark:text-neutral-400">
                        {alerta.mensagem}
                      </p>
                      <p class="text-xs text-neutral-500 dark:text-neutral-500">
                        {formatDate(alerta.timestamp)}
                      </p>
                    </div>
                  </div>
                </div>
              {/each}
            </div>
          </div>
        </section>
      {/if}
    </div>
  </div>

  <!-- Ações Rápidas -->
  <section class="mt-12">
    <SectionHeader
      title="🚀 Ações Rápidas"
      subtitle="Acesse rapidamente as principais funcionalidades"
    />

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-6">
      <ActionCard
        icon="🔍"
        title="Buscar Lentes"
        description="Encontre a lente ideal para seu cliente"
        actionLabel="Iniciar Busca"
        color="blue"
        on:click={() => irPara("/buscar")}
      />

      <ActionCard
        icon="📊"
        title="Ver Ranking"
        description="Ranking das melhores lentes por categoria"
        actionLabel="Ver Ranking"
        color="green"
        on:click={() => irPara("/ranking")}
      />

      <ActionCard
        icon="📋"
        title="Catálogo"
        description="Explore nosso catálogo completo"
        actionLabel="Ver Catálogo"
        color="orange"
        on:click={() => irPara("/catalogo")}
      />

      <ActionCard
        icon="💰"
        title="Tabela de Preços"
        description="Consulte preços para vouchers"
        actionLabel="Ver Preços"
        color="purple"
        on:click={() => irPara("/tabela-precos")}
      />

      <ActionCard
        icon="⚖️"
        title="Comparar Lentes"
        description="Compare até 3 lentes lado a lado"
        actionLabel="Comparar"
        color="blue"
        on:click={() => irPara("/comparar")}
      />

      <ActionCard
        icon="📈"
        title="Analytics"
        description="Relatórios e insights de negócio"
        actionLabel="Ver Analytics"
        color="green"
        on:click={() => irPara("/analytics")}
      />

      <ActionCard
        icon="🏪"
        title="Fornecedores"
        description="Gerencie parceiros e fornecedores"
        actionLabel="Gerenciar"
        color="orange"
        on:click={() => irPara("/fornecedores")}
      />

      <ActionCard
        icon="⚙️"
        title="Configurações"
        description="Ajuste parâmetros do sistema"
        actionLabel="Configurar"
        color="purple"
        on:click={() => irPara("/configuracoes")}
      />
    </div>
  </section>

  <!-- Atualização -->
  <section class="mt-12 mb-8">
    <div class="text-center">
      <Button
        variant="ghost"
        size="md"
        disabled={isLoading}
        on:click={atualizarDashboard}
      >
        {#if isLoading}
          <LoadingSpinner size="sm" />
          <span class="ml-2">Atualizando...</span>
        {:else}
          🔄 Atualizar Dashboard
        {/if}
      </Button>

      <p class="text-xs text-neutral-500 dark:text-neutral-500 mt-2">
        Última atualização: {currentTime.toLocaleTimeString("pt-BR")}
      </p>
    </div>
  </section>
</Container>
