<!--
  💰 Tabela de Preços - Módulo Completo para Vouchers
  Interface unificada para consulta de lentes com filtros avançados
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import type { PageData } from "./$types";
  import type { VCatalogLens } from "$lib/types/database-views";

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
  let lenteSelecionada: VCatalogLens | null = null;
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
  $: lentes = (data.lentes || []) as VCatalogLens[];
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

  // Headers da tabela (chaves do novo banco)
  const tableHeaders = [
    { key: "brand_name", label: "Marca", sortable: true },
    { key: "lens_name", label: "Nome", sortable: true },
    { key: "lens_type", label: "Tipo", sortable: true },
    { key: "material", label: "Material", sortable: true },
    { key: "refractive_index", label: "Índice", sortable: true },
    { key: "price_suggested", label: "Preço", sortable: true },
    { key: "status", label: "Status", sortable: false },
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

  type BadgeVariant = "error" | "success" | "warning" | "info" | "primary" | "secondary" | "orange" | "gold" | "melhor-opcao" | "promocao" | "entrega-expressa" | "neutral";

  function getMarcaColor(marcaVal: string): BadgeVariant {
    const cores: Record<string, BadgeVariant> = {
      essilor: "primary",
      zeiss: "success",
      hoya: "warning",
      kodak: "orange",
      default: "primary",
    };
    return cores[marcaVal?.toLowerCase()] || cores.default;
  }

  function getTipoColor(tipo: string): BadgeVariant {
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

  function getStatusColor(status: string): BadgeVariant {
    switch (status?.toLowerCase()) {
      case "active":
        return "success";
      case "limited":
        return "warning";
      case "discontinued":
        return "error";
      default:
        return "primary";
    }
  }

  function getStatusLabel(status: string): string {
    switch (status?.toLowerCase()) {
      case "active":
        return "Disponível";
      case "limited":
        return "Limitado";
      case "discontinued":
        return "Descontinuado";
      default:
        return status || "N/A";
    }
  }

  function getLenteTratamentos(lente: VCatalogLens): string[] {
    const t: string[] = [];
    if (lente.anti_reflective) t.push("AR");
    if (lente.blue_light) t.push("Blue Light");
    if (lente.uv_filter) t.push("UV");
    if (lente.anti_scratch) t.push("Antirrisco");
    if (lente.photochromic && lente.photochromic !== "nenhum") t.push("Fotossensível");
    if (lente.polarized) t.push("Polarizado");
    if (lente.digital) t.push("Digital");
    if (lente.free_form) t.push("Free Form");
    return t;
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

  function verDetalhes(lente: VCatalogLens) {
    lenteSelecionada = lente;
    showModal = true;
  }

  function gerarVoucher(lente: VCatalogLens) {
    const params = new URLSearchParams();
    params.set("lente_id", lente.id);
    params.set("familia", lente.lens_name || "");
    params.set("marca", lente.brand_name || "");
    params.set("preco", (lente.price_suggested || 0).toString());
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
      <div class="glass-panel rounded-xl p-6 shadow-xl">
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
          <div class="glass-panel rounded-xl p-6 shadow-xl overflow-hidden">
            <Table headers={tableHeaders} data={lentes} hoverable striped>
              <svelte:fragment slot="cell" let:row let:column>
                {#if column === "brand_name"}
                  <Badge variant={getMarcaColor(row.brand_name)} size="sm">
                    {row.brand_name || "N/A"}
                  </Badge>
                {:else if column === "lens_name"}
                  <div class="space-y-1">
                    <p
                      class="font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      {row.lens_name || "N/A"}
                    </p>
                    {#if row.sku}
                      <p
                        class="text-xs text-neutral-500 dark:text-neutral-400"
                      >
                        {row.sku}
                      </p>
                    {/if}
                  </div>
                {:else if column === "lens_type"}
                  <Badge variant={getTipoColor(row.lens_type)} size="sm">
                    {row.lens_type || "N/A"}
                  </Badge>
                {:else if column === "material"}
                  <span
                    class="text-sm text-neutral-600 dark:text-neutral-400"
                  >
                    {row.material || "N/A"}
                  </span>
                {:else if column === "refractive_index"}
                  <span
                    class="font-medium text-purple-600 dark:text-purple-400"
                  >
                    {row.refractive_index || "N/A"}
                  </span>
                {:else if column === "price_suggested"}
                  <span
                    class="font-bold text-green-600 dark:text-green-400"
                  >
                    {formatCurrency(row.price_suggested || 0)}
                  </span>
                {:else if column === "status"}
                  <Badge
                    variant={getStatusColor(row.status)}
                    size="sm"
                  >
                    {getStatusLabel(row.status)}
                  </Badge>
                {:else if column === "actions"}
                  <div class="flex gap-1 justify-center">
                    <Button
                      variant="primary"
                      size="sm"
                      on:click={() => gerarVoucher(row as unknown as VCatalogLens)}
                      title="Gerar Voucher"
                    >
                      🎫
                    </Button>

                    <Button
                      variant="ghost"
                      size="sm"
                      on:click={() => verDetalhes(row as unknown as VCatalogLens)}
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
              {@const tratamentos = getLenteTratamentos(lente)}
              <div
                class="glass-panel rounded-xl p-4 hover:shadow-lg transition-all duration-200"
              >
                <div class="space-y-4">
                  <!-- Header do Card -->
                  <div class="space-y-2">
                    <div class="flex items-center justify-between">
                      <Badge
                        variant={getMarcaColor(lente.brand_name || '')}
                        size="sm"
                      >
                        {lente.brand_name || 'N/A'}
                      </Badge>
                      <Badge
                        variant={getStatusColor(lente.status || '')}
                        size="sm"
                      >
                        {getStatusLabel(lente.status || '')}
                      </Badge>
                    </div>

                    <h3
                      class="font-semibold text-neutral-900 dark:text-neutral-100 line-clamp-2"
                    >
                      {lente.lens_name || "N/A"}
                    </h3>

                    {#if lente.sku}
                      <p
                        class="text-xs text-neutral-500 dark:text-neutral-400"
                      >
                        SKU: {lente.sku}
                      </p>
                    {/if}
                  </div>

                  <!-- Especificações -->
                  <div class="space-y-2">
                    <div class="flex items-center gap-2">
                      <Badge
                        variant={getTipoColor(lente.lens_type || '')}
                        size="sm"
                      >
                        {lente.lens_type || 'N/A'}
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
                      {lente.refractive_index}
                    </div>

                    {#if tratamentos.length > 0}
                      <div class="flex flex-wrap gap-1">
                        {#each tratamentos.slice(0, 2) as t}
                          <Badge variant="warning" size="sm">{t}</Badge>
                        {/each}
                        {#if tratamentos.length > 2}
                          <span class="text-xs text-neutral-500"
                            >+{tratamentos.length - 2}</span
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
                      {formatCurrency(lente.price_suggested || 0)}
                    </div>
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
          color="orange"
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
                  >Nome</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.lens_name}
                </p>
              </div>

              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >Marca</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.brand_name}
                </p>
              </div>

              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                  >SKU</span
                >
                <p class="text-neutral-900 dark:text-neutral-100">
                  {lenteSelecionada.sku}
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
                  {lenteSelecionada.lens_type}
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
                  {lenteSelecionada.refractive_index}
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
                  >Preço Sugerido</span
                >
                <p class="text-lg font-bold text-green-600 dark:text-green-400">
                  {formatCurrency(lenteSelecionada.price_suggested || 0)}
                </p>
              </div>

              {#if lenteSelecionada.price_cost}
                <div>
                  <span
                    class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                    >Preço de Custo</span
                  >
                  <p class="text-lg font-bold text-orange-600 dark:text-orange-400">
                    {formatCurrency(lenteSelecionada.price_cost)}
                  </p>
                </div>
              {/if}
            </div>
          </div>

          <!-- Tratamentos -->
          {#each [getLenteTratamentos(lenteSelecionada)] as tratamentosModal}
            {#if tratamentosModal.length > 0}
              <div>
                <span
                  class="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-2"
                  >Tratamentos</span
                >
                <div class="flex flex-wrap gap-2">
                  {#each tratamentosModal as t}
                    <Badge variant="warning" size="sm">{t}</Badge>
                  {/each}
                </div>
              </div>
            {/if}
          {/each}

          <!-- Ações -->
          <div class="flex gap-3">
            <Button
              variant="primary"
              size="md"
              on:click={() => {
                if (lenteSelecionada) gerarVoucher(lenteSelecionada);
                showModal = false;
              }}
            >
              🎫 Gerar Voucher
            </Button>

            <Button
              variant="ghost"
              size="md"
              on:click={() => {
                if (lenteSelecionada) verRanking(lenteSelecionada.id);
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
