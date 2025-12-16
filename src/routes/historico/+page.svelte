<script lang="ts">
  /**
   * Página de Histórico de Decisões - Interface Principal
   * Lista e filtra todas as decisões de compra realizadas
   */

  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import type { PageData } from "./$types";

  // === Layout ===
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

  // === UI ===
  import Button from "$lib/components/ui/Button.svelte";
  import Input from "$lib/components/ui/Input.svelte";
  import Select from "$lib/components/ui/Select.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import Table from "$lib/components/ui/Table.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // === Cards ===
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";

  export let data: PageData;

  // Filtros
  let filtroLab = $page.url.searchParams.get("laboratorio") || "";
  let filtroCriterio = $page.url.searchParams.get("criterio") || "";
  let filtroDataInicio = $page.url.searchParams.get("data_inicio") || "";
  let filtroDataFim = $page.url.searchParams.get("data_fim") || "";
  let busca = $page.url.searchParams.get("busca") || "";

  // Estado local
  let isLoading = false;

  // Paginação
  let paginaAtual = parseInt($page.url.searchParams.get("pagina") || "1");
  const itensPorPagina = 15;

  // Dados
  const { decisoes, estatisticas, laboratorios } = data;

  // Formatadores
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(value);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  // Dados filtrados e paginados
  $: decisoesFiltradas = filtrarDecisoes(decisoes || []);
  $: totalPaginas = Math.ceil(decisoesFiltradas.length / itensPorPagina);
  $: decisoesPaginadas = decisoesFiltradas.slice(
    (paginaAtual - 1) * itensPorPagina,
    paginaAtual * itensPorPagina,
  );

  // Opções para selects
  const criterioOptions = [
    { value: "", label: "Todos os critérios" },
    { value: "PRECO", label: "Melhor Preço" },
    { value: "PRAZO", label: "Menor Prazo" },
    { value: "URGENCIA", label: "Urgência" },
    { value: "ESPECIAL", label: "Especial" },
  ];

  $: laboratorioOptions = [
    { value: "", label: "Todos os laboratórios" },
    ...(laboratorios || []).map((lab: any) => ({
      value: lab.id,
      label: lab.nome,
    })),
  ];

  // Headers da tabela
  const tableHeaders = [
    { key: "data_decisao", label: "Data/Hora" },
    { key: "lente_nome", label: "Lente" },
    { key: "laboratorio_nome", label: "Laboratório" },
    { key: "criterio", label: "Critério" },
    { key: "preco_final", label: "Preço Final", align: "right" as const },
    { key: "economia", label: "Economia", align: "right" as const },
    { key: "status", label: "Status" },
    { key: "actions", label: "Ações", align: "center" as const },
  ];

  // Função de filtros
  function filtrarDecisoes(decisoes: any[]) {
    return decisoes.filter((decisao) => {
      const matchBusca =
        !busca ||
        decisao.lente_nome.toLowerCase().includes(busca.toLowerCase()) ||
        decisao.laboratorio_nome.toLowerCase().includes(busca.toLowerCase());

      const matchLab = !filtroLab || decisao.laboratorio_id === filtroLab;
      const matchCriterio =
        !filtroCriterio || decisao.criterio === filtroCriterio;

      const matchDataInicio =
        !filtroDataInicio ||
        new Date(decisao.data_decisao) >= new Date(filtroDataInicio);

      const matchDataFim =
        !filtroDataFim ||
        new Date(decisao.data_decisao) <= new Date(filtroDataFim);

      return (
        matchBusca &&
        matchLab &&
        matchCriterio &&
        matchDataInicio &&
        matchDataFim
      );
    });
  }

  // Aplicar filtros
  function aplicarFiltros() {
    const params = new URLSearchParams();

    if (busca) params.set("busca", busca);
    if (filtroLab) params.set("laboratorio", filtroLab);
    if (filtroCriterio) params.set("criterio", filtroCriterio);
    if (filtroDataInicio) params.set("data_inicio", filtroDataInicio);
    if (filtroDataFim) params.set("data_fim", filtroDataFim);
    params.set("pagina", "1");

    goto(`/historico?${params.toString()}`);
  }

  // Limpar filtros
  function limparFiltros() {
    busca = "";
    filtroLab = "";
    filtroCriterio = "";
    filtroDataInicio = "";
    filtroDataFim = "";
    paginaAtual = 1;
    goto("/historico");
  }

  // Navegar para página
  function irParaPagina(pagina: number) {
    const params = new URLSearchParams($page.url.searchParams);
    params.set("pagina", pagina.toString());
    goto(`/historico?${params.toString()}`);
  }

  // Funções de cor para status e critério
  function getCriterioColor(criterio: string) {
    switch (criterio) {
      case "PRECO":
        return "success";
      case "PRAZO":
        return "warning";
      case "URGENCIA":
        return "danger";
      case "ESPECIAL":
        return "info";
      default:
        return "info";
    }
  }

  function getStatusColor(status: string) {
    switch (status) {
      case "CONFIRMADO":
        return "success";
      case "PENDENTE":
        return "warning";
      case "CANCELADO":
        return "danger";
      default:
        return "info";
    }
  }
</script>

<svelte:head>
  <title>Histórico de Decisões - SIS Lens</title>
  <meta
    name="description"
    content="Histórico completo de todas as decisões de compra realizadas"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="📋 Sistema de Histórico"
        title="Histórico de Decisões"
        subtitle="Acompanhe todas as decisões de compra realizadas"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Estatísticas -->
      {#if estatisticas}
        <section class="mt-8">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <StatsCard
              title="Total de Decisões"
              value={estatisticas.total_decisoes}
              icon="📊"
              color="blue"
            />

            <StatsCard
              title="Economia Total"
              value={formatCurrency(estatisticas.economia_total)}
              icon="💰"
              color="green"
            />

            <StatsCard
              title="Lab. Mais Usado"
              value={estatisticas.laboratorio_top?.nome || "N/A"}
              icon="🏆"
              color="orange"
            />

            <StatsCard
              title="Média/Decisão"
              value={formatCurrency(estatisticas.valor_medio)}
              icon="📈"
              color="gold"
            />
          </div>
        </section>
      {/if}

      <!-- Filtros -->
      <section class="mt-12">
        <div
          class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6"
        >
          <SectionHeader title="Filtros de Busca" />

          <div class="space-y-6">
            <!-- Busca Geral -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
              <div class="lg:col-span-2">
                <Input
                  label="Buscar"
                  placeholder="Nome da lente, laboratório ou código..."
                  bind:value={busca}
                />
              </div>
              <div>
                <Button
                  variant="primary"
                  size="md"
                  fullWidth
                  on:click={aplicarFiltros}
                  disabled={isLoading}
                >
                  🔍 Filtrar
                </Button>
              </div>
            </div>

            <!-- Filtros Específicos -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <Select
                label="Laboratório"
                bind:value={filtroLab}
                options={laboratorioOptions}
              />

              <Select
                label="Critério"
                bind:value={filtroCriterio}
                options={criterioOptions}
              />

              <Input
                label="Data Início"
                type="date"
                bind:value={filtroDataInicio}
              />

              <Input label="Data Fim" type="date" bind:value={filtroDataFim} />
            </div>

            <!-- Ações -->
            <div class="flex gap-3">
              <Button variant="ghost" on:click={limparFiltros}>
                🗑️ Limpar Filtros
              </Button>

              <div class="flex-1"></div>

              <Button variant="secondary" on:click={() => goto("/buscar")}>
                ➕ Nova Busca
              </Button>
            </div>
          </div>
        </div>
      </section>

      <!-- Tabela de Decisões -->
      <section class="mt-12">
        <SectionHeader
          title="Decisões Realizadas"
          subtitle={decisoesFiltradas.length
            ? `${decisoesFiltradas.length} decisões encontradas`
            : ""}
        />

        {#if isLoading}
          <div class="flex justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        {:else if decisoesPaginadas && decisoesPaginadas.length > 0}
          <Table headers={tableHeaders} rows={decisoesPaginadas} hoverable>
            <svelte:fragment slot="cell" let:row let:header>
              {#if header.key === "data_decisao"}
                <div class="text-sm">
                  {formatDate(row.data_decisao)}
                </div>
              {:else if header.key === "criterio"}
                <Badge variant={getCriterioColor(row.criterio)} size="sm">
                  {row.criterio}
                </Badge>
              {:else if header.key === "preco_final"}
                <span class="font-medium">
                  {formatCurrency(row.preco_final || 0)}
                </span>
              {:else if header.key === "economia"}
                <span
                  class="font-medium"
                  class:text-success={row.economia > 0}
                  class:text-neutral-500={row.economia <= 0}
                >
                  {row.economia > 0 ? `+${formatCurrency(row.economia)}` : "-"}
                </span>
              {:else if header.key === "status"}
                <Badge variant={getStatusColor(row.status)} size="sm">
                  {row.status}
                </Badge>
              {:else if header.key === "actions"}
                <div class="flex gap-2 justify-center">
                  <Button
                    variant="primary"
                    size="sm"
                    on:click={() => goto(`/decisao/${row.id}`)}
                  >
                    📄 Ver
                  </Button>
                  <Button
                    variant="secondary"
                    size="sm"
                    on:click={() =>
                      goto(`/ranking/${row.lente_id}?criterio=${row.criterio}`)}
                  >
                    🔄 Repetir
                  </Button>
                </div>
              {:else}
                {row[header.key] || "N/A"}
              {/if}
            </svelte:fragment>
          </Table>

          <!-- Paginação -->
          {#if totalPaginas > 1}
            <div class="flex justify-center items-center gap-2 mt-6">
              <Button
                variant="secondary"
                size="sm"
                disabled={paginaAtual <= 1}
                on:click={() => irParaPagina(paginaAtual - 1)}
              >
                ← Anterior
              </Button>

              <span
                class="px-4 py-2 text-sm text-neutral-600 dark:text-neutral-400"
              >
                Página {paginaAtual} de {totalPaginas}
              </span>

              <Button
                variant="secondary"
                size="sm"
                disabled={paginaAtual >= totalPaginas}
                on:click={() => irParaPagina(paginaAtual + 1)}
              >
                Próxima →
              </Button>
            </div>
          {/if}
        {:else}
          <EmptyState
            icon="📋"
            title="Nenhuma decisão encontrada"
            description="Não há decisões que correspondam aos filtros aplicados"
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
            icon="🔍"
            title="Nova Busca"
            description="Buscar lentes e criar nova decisão"
            actionLabel="Buscar Lentes"
            color="blue"
            on:click={() => goto("/buscar")}
          />

          <ActionCard
            icon="📊"
            title="Analytics"
            description="Ver relatórios e análises detalhadas"
            actionLabel="Ver Analytics"
            color="green"
            on:click={() => goto("/analytics")}
          />

          <ActionCard
            icon="🏢"
            title="Fornecedores"
            description="Gerenciar laboratórios e configurações"
            actionLabel="Gerenciar"
            color="orange"
            on:click={() => goto("/fornecedores")}
          />
        </div>
      </section>
    </Container>
  </main>
