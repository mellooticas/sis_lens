<script lang="ts">
  /**
   * Página de Configurações de Fornecedores
   * Interface para gerenciar configurações específicas dos laboratórios
   */

  import { goto } from "$app/navigation";
  import type { PageData } from "./$types";

  // === Layout ===
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

  // === UI ===
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import Table from "$lib/components/ui/Table.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";

  // === Forms ===
  import Input from "$lib/components/forms/Input.svelte";
  import Select from "$lib/components/forms/Select.svelte";
  import Toggle from "$lib/components/forms/Toggle.svelte";

  // === Cards ===
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";

  // === Feedback ===
  import Modal from "$lib/components/feedback/Modal.svelte";

  export let data: PageData;

  // Estado local
  let isLoading = false;
  let showEditModal = false;
  let editingConfig: any = null;
  let filtros = {
    busca: "",
    status: "",
    regiao: "",
  };

  // Dados filtrados
  $: configuracoesFiltradas = data.configuracoes.filter((config) => {
    const buscaMatch =
      !filtros.busca ||
      config.fornecedor_nome
        .toLowerCase()
        .includes(filtros.busca.toLowerCase());

    const statusMatch = !filtros.status || config.status === filtros.status;

    const regiaoMatch =
      !filtros.regiao || config.regiao_atendimento === filtros.regiao;

    return buscaMatch && statusMatch && regiaoMatch;
  });

  // Headers da tabela
  const tableHeaders = [
    { key: "fornecedor_nome", label: "Fornecedor" },
    { key: "status", label: "Status", align: "center" as const },
    { key: "prioridade", label: "Prioridade", align: "center" as const },
    { key: "desconto_maximo", label: "Desc. Máx.", align: "right" as const },
    { key: "prazo_padrao", label: "Prazo", align: "center" as const },
    { key: "regiao_atendimento", label: "Região", align: "center" as const },
    { key: "actions", label: "Ações", align: "center" as const },
  ];

  // Função para obter cor do status
  function getStatusColor(status: string) {
    switch (status) {
      case "ativo":
        return "success";
      case "inativo":
        return "danger";
      case "manutencao":
        return "warning";
      default:
        return "secondary";
    }
  }

  // Função para obter cor da prioridade
  function getPrioridadeColor(prioridade: number) {
    if (prioridade >= 5) return "danger";
    if (prioridade >= 4) return "warning";
    if (prioridade >= 3) return "info";
    return "secondary";
  }

  // Abrir modal de edição
  function editarConfiguracao(config: any) {
    editingConfig = { ...config };
    showEditModal = true;
  }

  // Fechar modal
  function fecharModal() {
    showEditModal = false;
    editingConfig = null;
  }

  // Salvar configuração
  async function salvarConfiguracao() {
    if (!editingConfig) return;

    isLoading = true;
    try {
      // Simular salvamento
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Atualizar na lista local
      const index = data.configuracoes.findIndex(
        (c) => c.id === editingConfig.id,
      );
      if (index !== -1) {
        data.configuracoes[index] = { ...editingConfig };
      }

      fecharModal();
    } catch (error) {
      console.error("Erro ao salvar configuração:", error);
    } finally {
      isLoading = false;
    }
  }

  // Limpar filtros
  function limparFiltros() {
    filtros = {
      busca: "",
      status: "",
      regiao: "",
    };
  }
</script>

<svelte:head>
  <title>Configurações de Fornecedores - SIS Lens</title>
  <meta
    name="description"
    content="Gerencie configurações específicas dos fornecedores e laboratórios"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="⚙️ Configurações"
        title="Configurações de Fornecedores"
        subtitle="Gerencie configurações específicas dos laboratórios e fornecedores"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Estatísticas -->
      <section class="mt-8">
        <div class="grid grid-cols-1 md:grid-cols-5 gap-6">
          <StatsCard
            title="Total"
            value={data.estatisticas.total_fornecedores}
            icon="🏢"
            color="blue"
          />

          <StatsCard
            title="Ativos"
            value={data.estatisticas.fornecedores_ativos}
            icon="✅"
            color="green"
          />

          <StatsCard
            title="Inativos"
            value={data.estatisticas.fornecedores_inativos}
            icon="❌"
            color="orange"
          />

          <StatsCard
            title="Desc. Médio"
            value="{data.estatisticas.desconto_medio.toFixed(1)}%"
            icon="💰"
            color="gold"
          />

          <StatsCard
            title="Prazo Médio"
            value="{data.estatisticas.prazo_medio.toFixed(0)} dias"
            icon="⏱️"
            color="blue"
          />
        </div>
      </section>

      <!-- Filtros -->
      <section class="mt-8">
        <div
          class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6"
        >
          <h3
            class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-4"
          >
            🔍 Filtros
          </h3>

          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <Input
              bind:value={filtros.busca}
              label="Buscar Fornecedor"
              placeholder="Nome do fornecedor..."
            />

            <Select
              bind:value={filtros.status}
              label="Status"
              options={[
                { value: "", label: "Todos" },
                ...data.opcoes.status_opcoes,
              ]}
            />

            <Select
              bind:value={filtros.regiao}
              label="Região"
              options={[
                { value: "", label: "Todas" },
                ...data.opcoes.regioes.map((r) => ({ value: r, label: r })),
              ]}
            />

            <div class="flex items-end">
              <Button variant="secondary" on:click={limparFiltros}>
                🧹 Limpar Filtros
              </Button>
            </div>
          </div>
        </div>
      </section>

      <!-- Tabela de Configurações -->
      <section class="mt-8">
        <SectionHeader
          title="Configurações dos Fornecedores"
          subtitle={`${configuracoesFiltradas.length} configurações encontradas`}
        />

        {#if configuracoesFiltradas.length > 0}
          <Table headers={tableHeaders} rows={configuracoesFiltradas} hoverable>
            <svelte:fragment slot="cell" let:row let:header>
              {#if header.key === "status"}
                <Badge variant={getStatusColor(row.status)} size="sm">
                  {row.status}
                </Badge>
              {:else if header.key === "prioridade"}
                <Badge variant={getPrioridadeColor(row.prioridade)} size="sm">
                  {row.prioridade}
                </Badge>
              {:else if header.key === "desconto_maximo"}
                <span class="font-medium text-green-600 dark:text-green-400">
                  {row.desconto_maximo}%
                </span>
              {:else if header.key === "prazo_padrao"}
                <Badge variant="info" size="sm">
                  {row.prazo_padrao} dias
                </Badge>
              {:else if header.key === "actions"}
                <div class="flex gap-2 justify-center">
                  <Button
                    variant="secondary"
                    size="sm"
                    on:click={() => editarConfiguracao(row)}
                  >
                    ✏️ Editar
                  </Button>
                </div>
              {:else}
                {row[header.key]}
              {/if}
            </svelte:fragment>
          </Table>
        {:else}
          <EmptyState
            icon="⚙️"
            title="Nenhuma configuração encontrada"
            description="Não há configurações que correspondam aos filtros aplicados"
            actionLabel="Limpar Filtros"
            on:action={limparFiltros}
          />
        {/if}
      </section>

      <!-- Ações Rápidas -->
      <section class="mt-12">
        <SectionHeader title="Ações Rápidas" />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <ActionCard
            icon="🏢"
            title="Gerenciar Fornecedores"
            description="Ver lista completa de fornecedores cadastrados"
            actionLabel="Ver Fornecedores"
            color="blue"
            on:click={() => goto("/fornecedores")}
          />

          <ActionCard
            icon="📊"
            title="Analytics"
            description="Relatórios de performance dos fornecedores"
            actionLabel="Ver Analytics"
            color="green"
            on:click={() => goto("/analytics")}
          />

          <ActionCard
            icon="🔍"
            title="Sistema de Busca"
            description="Testar configurações no sistema de busca"
            actionLabel="Testar Busca"
            color="orange"
            on:click={() => goto("/buscar")}
          />
        </div>
      </section>
    </Container>
  </main>

<!-- Modal de Edição -->
{#if showEditModal && editingConfig}
  <Modal
    show={showEditModal}
    title="Editar Configuração do Fornecedor"
    size="lg"
    on:close={fecharModal}
  >
    <div slot="body" class="space-y-6">
      <!-- Nome do Fornecedor -->
      <Input
        bind:value={editingConfig.fornecedor_nome}
        label="Nome do Fornecedor"
        required
      />

      <!-- Configurações Básicas -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Select
          bind:value={editingConfig.status}
          label="Status"
          options={data.opcoes.status_opcoes}
          required
        />

        <Select
          bind:value={editingConfig.prioridade}
          label="Prioridade"
          options={data.opcoes.prioridades}
          required
        />
      </div>

      <!-- Configurações Comerciais -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Input
          bind:value={editingConfig.desconto_maximo}
          type="number"
          label="Desconto Máximo (%)"
          min="0"
          max="50"
        />

        <Input
          bind:value={editingConfig.prazo_padrao}
          type="number"
          label="Prazo Padrão (dias)"
          min="1"
          max="30"
        />
      </div>

      <!-- Configurações de Localização -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Select
          bind:value={editingConfig.regiao_atendimento}
          label="Região de Atendimento"
          options={data.opcoes.regioes.map((r) => ({ value: r, label: r }))}
          required
        />

        <Select
          bind:value={editingConfig.tipo_pagamento}
          label="Tipo de Pagamento"
          options={data.opcoes.tipos_pagamento.map((t) => ({
            value: t,
            label: t,
          }))}
          required
        />
      </div>

      <!-- Configurações Avançadas -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Input
          bind:value={editingConfig.margem_minima}
          type="number"
          label="Margem Mínima (%)"
          min="0"
          max="100"
        />

        <Input
          bind:value={editingConfig.comissao_percentual}
          type="number"
          label="Comissão (%)"
          min="0"
          max="20"
        />
      </div>

      <!-- Configurações Especiais -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <Toggle
            bind:checked={editingConfig.aceita_urgencia}
            label="Aceita Pedidos de Urgência"
          />
        </div>

        <div>
          <Toggle
            bind:checked={editingConfig.aceita_especiais}
            label="Aceita Lentes Especiais"
          />
        </div>
      </div>
    </div>

    <div slot="footer" class="flex gap-3 justify-end">
      <Button variant="secondary" on:click={fecharModal} disabled={isLoading}>
        Cancelar
      </Button>

      <Button
        variant="primary"
        on:click={salvarConfiguracao}
        disabled={isLoading}
      >
        {#if isLoading}
          <LoadingSpinner size="sm" color="white" />
          Salvando...
        {:else}
          💾 Salvar
        {/if}
      </Button>
    </div>
  </Modal>
{/if}
