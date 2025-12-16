<!--
  💰 Tabela de Preços - Módulo Completo para Vouchers
  Interface unificada para consulta de lentes com filtros avançados
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import type { PageData } from "./$types";

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";
  import Table from "$lib/components/ui/Table.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Input from "$lib/components/ui/Input.svelte";
  import Select from "$lib/components/ui/Select.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";

  export let data: PageData;

  // Estado local
  let isLoading = false;
  let mostrarFiltrosAvancados = true;
  let lenteSelecionada: any = null;
  let showModal = false;

  // Filtros
  let busca = data.filtros?.busca || "";
  let marca = data.filtros?.marca || "";
  let tipo_lente = data.filtros?.tipo_lente || "";
  let material = data.filtros?.material || "";
  let indice = data.filtros?.indice || "";
  let tratamento = data.filtros?.tratamento || "";
  let preco_min = data.filtros?.preco_min?.toString() || "";
  let preco_max = data.filtros?.preco_max?.toString() || "";
  let visualizacao = data.visualizacao || "tabela";

  // Dados computados
  $: lentes = data.lentes || [];
  $: estatisticas = data.estatisticas || {};
  $: totalResultados = data.total_resultados || 0;
  $: paginaAtual = data.pagina_atual || 1;
  $: totalPaginas = data.total_paginas || 0;
  $: temResultados = lentes.length > 0;
  $: temFiltrosAtivos =
    busca ||
    marca ||
    tipo_lente ||
    material ||
    indice ||
    tratamento ||
    preco_min ||
    preco_max;

  // Opções para selects
  $: marcaOptions = [
    { value: "", label: "Todas as marcas" },
    ...(data.filtros?.opcoes?.marcas || []),
  ];

  $: tipoOptions = [
    { value: "", label: "Todos os tipos" },
    ...(data.filtros?.opcoes?.tipos || []),
  ];

  $: materialOptions = [
    { value: "", label: "Todos os materiais" },
    ...(data.filtros?.opcoes?.materiais || []),
  ];

  $: indiceOptions = [
    { value: "", label: "Todos os índices" },
    ...(data.filtros?.opcoes?.indices || []),
  ];

  $: tratamentoOptions = [
    { value: "", label: "Todos os tratamentos" },
    ...(data.filtros?.opcoes?.tratamentos || []),
  ];

  // Headers da tabela
  const tableHeaders = [
    { key: "marca_nome", label: "Marca", sortable: true },
    { key: "familia", label: "Família/Nome", sortable: true },
    { key: "tipo_lente", label: "Tipo", sortable: true },
    { key: "material", label: "Material", sortable: true },
    { key: "indice_refracao", label: "Índice", sortable: true },
    { key: "preco_base", label: "Preço", sortable: true },
    { key: "disponibilidade", label: "Status", sortable: false },
    { key: "actions", label: "Ações", sortable: false },
  ];

  // Funções
  function formatCurrency(value: number): string {
    if (!value) return "R$ 0,00";
    return value.toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
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

  function getStatusColor(status: string): string {
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

  function limparFiltros() {
    busca = "";
    marca = "";
    tipo_lente = "";
    material = "";
    indice = "";
    tratamento = "";
    preco_min = "";
    preco_max = "";
    aplicarFiltros();
  }

  function toggleVisualizacao() {
    visualizacao = visualizacao === "tabela" ? "cards" : "tabela";
    aplicarFiltros();
  }

  function aplicarFiltros() {
    isLoading = true;
    const params = new URLSearchParams();

    if (busca) params.set("busca", busca);
    if (marca) params.set("marca", marca);
    if (tipo_lente) params.set("tipo_lente", tipo_lente);
    if (material) params.set("material", material);
    if (indice) params.set("indice", indice);
    if (tratamento) params.set("tratamento", tratamento);
    if (preco_min) params.set("preco_min", preco_min);
    if (preco_max) params.set("preco_max", preco_max);
    if (visualizacao) params.set("view", visualizacao);

    goto(`/tabela-precos?${params.toString()}`);
  }

  function irParaPagina(pagina: number) {
    const params = new URLSearchParams(window.location.search);
    params.set("pagina", pagina.toString());
    goto(`/tabela-precos?${params.toString()}`);
  }

  function verDetalhes(lente: any) {
    lenteSelecionada = lente;
    showModal = true;
  }

  function gerarVoucher(lente: any) {
    const params = new URLSearchParams();
    params.set("lente_id", lente.id);
    params.set("familia", lente.familia);
    params.set("marca", lente.marca_nome);
    params.set("preco", lente.preco_base.toString());
    goto(`/vouchers/novo?${params.toString()}`);
  }

  function verRanking(lenteId: string) {
    goto(`/ranking?lente_id=${lenteId}`);
  }
</script>

<svelte:head>
  <title>Tabela de Preços - SIS Lens</title>
  <meta
    name="description"
    content="Tabela normalizada de preços de lentes para geração de vouchers"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="💰 Sistema de Vouchers"
        title="Tabela de Preços"
        subtitle="Tabela normalizada de lentes para consulta e geração de vouchers com filtros avançados"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Estatísticas -->
      {#if estatisticas}
        <section class="mt-8">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatsCard
              title="Total de Lentes"
              value={estatisticas.total_lentes?.toString() || "0"}
              icon="👓"
              color="blue"
            />

            <StatsCard
              title="Marcas Disponíveis"
              value={estatisticas.total_marcas?.toString() || "0"}
              icon="🏷️"
              color="green"
            />

            <StatsCard
              title="Preço Médio"
              value={formatCurrency(estatisticas.preco_medio || 0)}
              icon="💰"
              color="orange"
            />

            <StatsCard
              title="Faixa de Preços"
              value={`${formatCurrency(estatisticas.preco_min || 0)} - ${formatCurrency(estatisticas.preco_max || 0)}`}
              icon="📊"
              color="purple"
            />
          </div>
        </section>
      {/if}

      <!-- Filtros -->
      <section class="mt-12">
        <div
          class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6 shadow-sm"
        >
          <div class="flex items-center justify-between mb-6">
            <SectionHeader
              title="Filtros Avançados"
              subtitle="Use os filtros para encontrar lentes específicas"
            />

            <div class="flex items-center gap-3">
              <!-- Toggle Visualização -->
              <Button variant="ghost" size="sm" on:click={toggleVisualizacao}>
                {#if visualizacao === "tabela"}
                  🃏 Cards
                {:else}
                  📋 Tabela
                {/if}
              </Button>

              {#if temFiltrosAtivos}
                <Button variant="ghost" size="sm" on:click={limparFiltros}>
                  🗑️ Limpar
                </Button>
              {/if}
            </div>
          </div>

          <div class="space-y-6">
            <!-- Busca Principal -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-4">
              <div class="lg:col-span-3">
                <Input
                  label="Busca Geral"
                  placeholder="Nome, marca, SKU, descrição..."
                  bind:value={busca}
                />
              </div>
              <div class="flex items-end">
                <Button
                  variant="primary"
                  size="md"
                  fullWidth
                  disabled={isLoading}
                  on:click={aplicarFiltros}
                >
                  {#if isLoading}
                    <LoadingSpinner size="sm" color="white" />
                    <span class="ml-2">Buscando...</span>
                  {:else}
                    🔍 Buscar
                  {/if}
                </Button>
              </div>
            </div>

            <!-- Filtros Específicos -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
              <Select
                placeholder="Selecionar marca"
                bind:value={marca}
                options={marcaOptions}
              />

              <Select
                placeholder="Selecionar tipo"
                bind:value={tipo_lente}
                options={tipoOptions}
              />

              <Select
                placeholder="Selecionar material"
                bind:value={material}
                options={materialOptions}
              />

              <Select
                placeholder="Selecionar índice"
                bind:value={indice}
                options={indiceOptions}
              />

              <Select
                placeholder="Selecionar tratamento"
                bind:value={tratamento}
                options={tratamentoOptions}
              />
            </div>

            <!-- Filtros de Preço -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Input
                label="Preço Mínimo"
                type="number"
                placeholder="R$ 0,00"
                bind:value={preco_min}
                min="0"
                step="0.01"
              />

              <Input
                label="Preço Máximo"
                type="number"
                placeholder="R$ 999,99"
                bind:value={preco_max}
                min="0"
                step="0.01"
              />
            </div>
          </div>
        </div>
      </section>

      <!-- Resultados -->
      <section class="mt-12">
        <div class="flex items-center justify-between mb-6">
          <SectionHeader
            title="Resultados"
            subtitle={temResultados
              ? `${totalResultados} lentes encontradas (Página ${paginaAtual} de ${totalPaginas})`
              : ""}
          />

          <div class="flex items-center gap-2">
            <Badge variant="primary" size="sm">
              {visualizacao === "tabela" ? "📋 Tabela" : "🃏 Cards"}
            </Badge>
            {#if temFiltrosAtivos}
              <Badge variant="warning" size="sm">Filtros Ativos</Badge>
            {/if}
          </div>
        </div>

        {#if isLoading}
          <div class="flex justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        {:else if temResultados}
          {#if visualizacao === "tabela"}
            <!-- Visualização Tabela -->
            <div
              class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 overflow-hidden"
            >
              <Table headers={tableHeaders} data={lentes} hoverable striped>
                <svelte:fragment slot="cell" let:row let:column>
                  {#if column === "marca_nome"}
                    <Badge variant={getMarcaColor(row.marca_nome)} size="sm">
                      {row.marca_nome || "N/A"}
                    </Badge>
                  {:else if column === "familia"}
                    <div class="space-y-1">
                      <p
                        class="font-medium text-neutral-900 dark:text-neutral-100"
                      >
                        {row.familia || "N/A"}
                      </p>
                      {#if row.sku_canonico}
                        <p
                          class="text-xs text-neutral-500 dark:text-neutral-400"
                        >
                          {row.sku_canonico}
                        </p>
                      {/if}
                    </div>
                  {:else if column === "tipo_lente"}
                    <Badge variant={getTipoColor(row.tipo_lente)} size="sm">
                      {row.tipo_lente || "N/A"}
                    </Badge>
                  {:else if column === "material"}
                    <span
                      class="text-sm text-neutral-600 dark:text-neutral-400"
                    >
                      {row.material || "N/A"}
                    </span>
                  {:else if column === "indice_refracao"}
                    <span
                      class="font-medium text-purple-600 dark:text-purple-400"
                    >
                      {row.indice_refracao || "N/A"}
                    </span>
                  {:else if column === "preco_base"}
                    <div class="space-y-1">
                      <span
                        class="font-bold text-green-600 dark:text-green-400"
                      >
                        {formatCurrency(row.preco_base || 0)}
                      </span>
                      {#if row.preco_promocional && row.preco_promocional < row.preco_base}
                        <div class="text-xs">
                          <span class="line-through text-neutral-500">
                            {formatCurrency(row.preco_promocional)}
                          </span>
                          <Badge variant="error" size="sm" class="ml-1"
                            >PROMO</Badge
                          >
                        </div>
                      {/if}
                    </div>
                  {:else if column === "disponibilidade"}
                    <Badge
                      variant={getStatusColor(row.disponibilidade)}
                      size="sm"
                    >
                      {row.disponibilidade || "N/A"}
                    </Badge>
                  {:else if column === "actions"}
                    <div class="flex gap-1 justify-center">
                      <Button
                        variant="primary"
                        size="sm"
                        on:click={() => gerarVoucher(row)}
                        title="Gerar Voucher"
                      >
                        🎫
                      </Button>

                      <Button
                        variant="ghost"
                        size="sm"
                        on:click={() => verDetalhes(row)}
                        title="Ver Detalhes"
                      >
                        👁️
                      </Button>

                      <Button
                        variant="ghost"
                        size="sm"
                        on:click={() => verRanking(row.id)}
                        title="Ver Ranking"
                      >
                        📊
                      </Button>
                    </div>
                  {:else}
                    {row[column] || "N/A"}
                  {/if}
                </svelte:fragment>
              </Table>
            </div>
          {:else}
            <!-- Visualização Cards -->
            <div
              class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
            >
              {#each lentes as lente}
                <div
                  class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-4 hover:shadow-lg transition-all duration-200"
                >
                  <div class="space-y-4">
                    <!-- Header do Card -->
                    <div class="space-y-2">
                      <div class="flex items-center justify-between">
                        <Badge
                          variant={getMarcaColor(lente.marca_nome)}
                          size="sm"
                        >
                          {lente.marca_nome}
                        </Badge>
                        <Badge
                          variant={getStatusColor(lente.disponibilidade)}
                          size="sm"
                        >
                          {lente.disponibilidade}
                        </Badge>
                      </div>

                      <h3
                        class="font-semibold text-neutral-900 dark:text-neutral-100 line-clamp-2"
                      >
                        {lente.familia || "N/A"}
                      </h3>

                      {#if lente.sku_canonico}
                        <p
                          class="text-xs text-neutral-500 dark:text-neutral-400"
                        >
                          SKU: {lente.sku_canonico}
                        </p>
                      {/if}
                    </div>

                    <!-- Especificações -->
                    <div class="space-y-2">
                      <div class="flex items-center gap-2">
                        <Badge
                          variant={getTipoColor(lente.tipo_lente)}
                          size="sm"
                        >
                          {lente.tipo_lente}
                        </Badge>
                        <span
                          class="text-sm text-neutral-600 dark:text-neutral-400"
                        >
                          {lente.material}
                        </span>
                      </div>

                      <div
                        class="text-sm text-neutral-600 dark:text-neutral-400"
                      >
                        <span class="font-medium">Índice:</span>
                        {lente.indice_refracao}
                      </div>

                      {#if lente.tratamentos && lente.tratamentos.length > 0}
                        <div class="flex flex-wrap gap-1">
                          {#each lente.tratamentos.slice(0, 2) as tratamento}
                            <Badge variant="warning" size="sm"
                              >{tratamento}</Badge
                            >
                          {/each}
                          {#if lente.tratamentos.length > 2}
                            <span class="text-xs text-neutral-500"
                              >+{lente.tratamentos.length - 2}</span
                            >
                          {/if}
                        </div>
                      {/if}
                    </div>

                    <!-- Preço -->
                    <div class="space-y-1">
                      <div
                        class="text-xl font-bold text-green-600 dark:text-green-400"
                      >
                        {formatCurrency(lente.preco_base || 0)}
                      </div>
                      {#if lente.preco_promocional && lente.preco_promocional < lente.preco_base}
                        <div class="text-sm">
                          <span class="line-through text-neutral-500">
                            {formatCurrency(lente.preco_promocional)}
                          </span>
                          <Badge variant="error" size="sm" class="ml-1"
                            >PROMO</Badge
                          >
                        </div>
                      {/if}
                    </div>

                    <!-- Ações -->
                    <div class="flex gap-2">
                      <Button
                        variant="primary"
                        size="sm"
                        fullWidth
                        on:click={() => gerarVoucher(lente)}
                      >
                        🎫 Voucher
                      </Button>

                      <Button
                        variant="ghost"
                        size="sm"
                        on:click={() => verDetalhes(lente)}
                      >
                        👁️
                      </Button>

                      <Button
                        variant="ghost"
                        size="sm"
                        on:click={() => verRanking(lente.id)}
                      >
                        📊
                      </Button>
                    </div>
                  </div>
                </div>
              {/each}
            </div>
          {/if}

          <!-- Paginação -->
          {#if totalPaginas > 1}
            <div class="flex justify-center items-center gap-4 mt-8">
              <Button
                variant="ghost"
                size="sm"
                disabled={paginaAtual <= 1}
                on:click={() => irParaPagina(paginaAtual - 1)}
              >
                ← Anterior
              </Button>

              <span class="text-sm text-neutral-600 dark:text-neutral-400">
                Página {paginaAtual} de {totalPaginas}
              </span>

              <Button
                variant="ghost"
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
            icon="💰"
            title="Nenhuma lente encontrada"
            description="Não encontramos lentes com os critérios especificados. Tente ajustar os filtros."
            actionLabel="Limpar Filtros"
            on:action={limparFiltros}
          />
        {/if}
      </section>

      <!-- Ações Rápidas -->
      <section class="mt-12 mb-8">
        <SectionHeader title="Ações Rápidas" />

        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mt-6">
          <ActionCard
            icon="🎫"
            title="Criar Voucher"
            description="Gere um novo voucher para cliente"
            actionLabel="Novo Voucher"
            color="blue"
            on:click={() => goto("/vouchers/novo")}
          />

          <ActionCard
            icon="📋"
            title="Histórico Vouchers"
            description="Consulte vouchers gerados"
            actionLabel="Ver Histórico"
            color="green"
            on:click={() => goto("/vouchers")}
          />

          <ActionCard
            icon="📊"
            title="Relatórios"
            description="Analytics e relatórios de vouchers"
            actionLabel="Ver Relatórios"
            color="orange"
            on:click={() => goto("/analytics")}
          />

          <ActionCard
            icon="⚙️"
            title="Configurações"
            description="Configurar fornecedores e políticas"
            actionLabel="Configurar"
            color="purple"
            on:click={() => goto("/configuracoes")}
          />
        </div>
      </section>
    </Container>
  </main>

<!-- Modal de Detalhes -->
{#if showModal && lenteSelecionada}
  <div
    class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
  >
    <div
      class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 max-w-2xl w-full max-h-[90vh] overflow-y-auto"
    >
      <div class="p-6">
        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
          <h3
            class="text-xl font-semibold text-neutral-900 dark:text-neutral-100"
          >
            Detalhes da Lente
          </h3>
          <Button
            variant="ghost"
            size="sm"
            on:click={() => (showModal = false)}
          >
            ✕ Fechar
          </Button>
        </div>

        <!-- Conteúdo -->
        <div class="space-y-6">
          <!-- Informações Básicas -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="space-y-3">
              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >Família/Nome</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.familia}
                </p>
              </div>

              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >Marca</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.marca_nome}
                </p>
              </div>

              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >SKU</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.sku_canonico}
                </p>
              </div>
            </div>

            <div class="space-y-3">
              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >Tipo</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.tipo_lente}
                </p>
              </div>

              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >Material</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.material}
                </p>
              </div>

              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >Índice de Refração</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.indice_refracao}
                </p>
              </div>
            </div>
          </div>

          <!-- Preços -->
          <div class="bg-neutral-50 dark:bg-neutral-900 rounded-lg p-4">
            <h4 class="font-medium text-neutral-900 dark:text-neutral-100 mb-3">
              Preços
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >Preço Base</span
                >
                <p class="text-lg font-bold text-green-600 dark:text-green-400">
                  {formatCurrency(lenteSelecionada.preco_base)}
                </p>
              </div>

              {#if lenteSelecionada.preco_promocional}
                <div>
                  <span
                    class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                    >Preço Promocional</span
                  >
                  <p class="text-lg font-bold text-red-600 dark:text-red-400">
                    {formatCurrency(lenteSelecionada.preco_promocional)}
                  </p>
                </div>
              {/if}
            </div>
          </div>

          <!-- Tratamentos -->
          {#if lenteSelecionada.tratamentos && lenteSelecionada.tratamentos.length > 0}
            <div>
              <span
                class="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-2"
                >Tratamentos</span
              >
              <div class="flex flex-wrap gap-2">
                {#each lenteSelecionada.tratamentos as tratamento}
                  <Badge variant="warning" size="sm">{tratamento}</Badge>
                {/each}
              </div>
            </div>
          {/if}

          <!-- Descrição -->
          {#if lenteSelecionada.descricao_completa}
            <div>
              <span
                class="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-2"
                >Descrição</span
              >
              <p class="text-neutral-900 dark:text-neutral-100 text-sm">
                {lenteSelecionada.descricao_completa}
              </p>
            </div>
          {/if}

          <!-- Ações -->
          <div class="flex gap-3">
            <Button
              variant="primary"
              size="md"
              on:click={() => {
                gerarVoucher(lenteSelecionada);
                showModal = false;
              }}
            >
              🎫 Gerar Voucher
            </Button>

            <Button
              variant="ghost"
              size="md"
              on:click={() => {
                verRanking(lenteSelecionada.id);
                showModal = false;
              }}
            >
              📊 Ver Ranking
            </Button>
          </div>
        </div>
      </div>
    </div>
  </div>
{/if}
