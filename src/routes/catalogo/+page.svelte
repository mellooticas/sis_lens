<!--
  📚 Página de Catálogo de Lentes - Versão Completa
  Catálogo completo com filtros avançados e dados reais
-->
<script lang="ts">
  import { enhance } from "$app/forms";
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
  let mostrarFiltrosAvancados = false;

  // Filtros
  let busca = data.filtros?.busca || "";
  let categoria = data.filtros?.categoria || "";
  let material = data.filtros?.material || "";
  let preco_min = data.filtros?.preco_min?.toString() || "";
  let preco_max = data.filtros?.preco_max?.toString() || "";

  // Dados computados
  $: lentes = data.lentes || [];
  $: estatisticas = data.estatisticas || {};
  $: totalResultados = data.total_resultados || 0;
  $: paginaAtual = data.pagina_atual || 1;
  $: totalPaginas = data.total_paginas || 0;
  $: temResultados = lentes.length > 0;
  $: temFiltrosAtivos =
    busca || categoria || material || preco_min || preco_max;

  // Opções para selects
  $: categoriaOptions = [
    { value: "", label: "Todas as categorias" },
    ...(data.filtros?.opcoes?.categorias || []),
  ];

  $: materialOptions = [
    { value: "", label: "Todos os materiais" },
    ...(data.filtros?.opcoes?.materiais || []),
  ];

  // Headers da tabela
  const tableHeaders = [
    { key: "familia", label: "Lente", sortable: true },
    { key: "marca_nome", label: "Marca", sortable: true },
    { key: "tipo_lente", label: "Tipo", sortable: false },
    { key: "material", label: "Material", sortable: true },
    { key: "indice_refracao", label: "Índice", sortable: true },
    { key: "preco_base", label: "Preço Base", sortable: true },
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

  function getMaterialColor(material: string): string {
    switch (material?.toLowerCase()) {
      case "plastic":
        return "success";
      case "trivex":
        return "warning";
      case "polycarbonate":
        return "primary";
      default:
        return "primary";
    }
  }

  function limparFiltros() {
    busca = "";
    categoria = "";
    material = "";
    preco_min = "";
    preco_max = "";
    aplicarFiltros();
  }

  function toggleFiltrosAvancados() {
    mostrarFiltrosAvancados = !mostrarFiltrosAvancados;
  }

  function aplicarFiltros() {
    isLoading = true;
    const params = new URLSearchParams();

    if (busca) params.set("busca", busca);
    if (categoria) params.set("categoria", categoria);
    if (material) params.set("material", material);
    if (preco_min) params.set("preco_min", preco_min);
    if (preco_max) params.set("preco_max", preco_max);

    goto(`/catalogo?${params.toString()}`);
  }

  function irParaPagina(pagina: number) {
    const params = new URLSearchParams(window.location.search);
    params.set("pagina", pagina.toString());
    goto(`/catalogo?${params.toString()}`);
  }

  function verRanking(lenteId: string) {
    goto(`/ranking?lente_id=${lenteId}`);
  }

  function verDetalhes(lenteId: string) {
    goto(`/lentes/${lenteId}`);
  }

  function compararLentes() {
    goto("/comparar");
  }
</script>

<svelte:head>
  <title>Catálogo de Lentes - SIS Lens</title>
  <meta
    name="description"
    content="Catálogo completo de lentes oftálmicas com filtros avançados e comparação de fornecedores"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="📚 Catálogo Completo"
        title="Catálogo de Lentes"
        subtitle="Explore nosso catálogo completo com mais de 1.000 lentes de diferentes marcas e especificações"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Estatísticas do Catálogo -->
      {#if estatisticas}
        <section class="mt-8">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
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
          </div>
        </section>
      {/if}

      <!-- Filtros de Busca -->
      <section class="mt-12">
        <div
          class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6 shadow-sm"
        >
          <SectionHeader
            title="Buscar no Catálogo"
            subtitle="Use os filtros para encontrar a lente ideal"
          />

          <div class="space-y-6 mt-6">
            <!-- Busca Principal -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-4">
              <div class="lg:col-span-3">
                <Input
                  label="Buscar lentes"
                  placeholder="Nome, marca, SKU..."
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

            <!-- Toggle Filtros Avançados -->
            <div class="flex items-center gap-3">
              <Button
                variant="ghost"
                size="sm"
                on:click={toggleFiltrosAvancados}
              >
                {mostrarFiltrosAvancados ? "▼" : "▶"} Filtros Avançados
                {#if temFiltrosAtivos}
                  <Badge variant="primary" size="sm" class="ml-2">Ativos</Badge>
                {/if}
              </Button>

              {#if temFiltrosAtivos}
                <Button variant="ghost" size="sm" on:click={limparFiltros}>
                  🗑️ Limpar Filtros
                </Button>
              {/if}
            </div>

            <!-- Filtros Avançados (Colapsável) -->
            {#if mostrarFiltrosAvancados}
              <div
                class="pt-4 border-t border-neutral-200 dark:border-neutral-700 space-y-4"
              >
                <h3
                  class="text-sm font-semibold text-neutral-700 dark:text-neutral-300"
                >
                  Filtros Avançados
                </h3>

                <div
                  class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4"
                >
                  <Select
                    placeholder="Selecionar categoria"
                    bind:value={categoria}
                    options={categoriaOptions}
                  />

                  <Select
                    placeholder="Selecionar material"
                    bind:value={material}
                    options={materialOptions}
                  />

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
            {/if}
          </div>
        </div>
      </section>

      <!-- Resultados -->
      <section class="mt-12">
        <SectionHeader
          title="Resultados do Catálogo"
          subtitle={temResultados
            ? `${totalResultados} lentes encontradas (Página ${paginaAtual} de ${totalPaginas})`
            : ""}
        />

        {#if isLoading}
          <div class="flex justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        {:else if temResultados}
          <div
            class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 overflow-hidden mt-6"
          >
            <Table headers={tableHeaders} data={lentes} hoverable striped>
              <svelte:fragment slot="cell" let:row let:column>
                {#if column === "familia"}
                  <div class="space-y-1">
                    <p
                      class="font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      {row.familia || "N/A"}
                    </p>
                    {#if row.sku_canonico}
                      <p class="text-xs text-neutral-500 dark:text-neutral-400">
                        SKU: {row.sku_canonico}
                      </p>
                    {/if}
                  </div>
                {:else if column === "marca_nome"}
                  <span class="font-medium text-blue-600 dark:text-blue-400">
                    {row.marca_nome || "N/A"}
                  </span>
                {:else if column === "tipo_lente"}
                  <Badge variant={getTipoColor(row.tipo_lente)} size="sm">
                    {row.tipo_lente || "N/A"}
                  </Badge>
                {:else if column === "material"}
                  <Badge variant={getMaterialColor(row.material)} size="sm">
                    {row.material || "N/A"}
                  </Badge>
                {:else if column === "indice_refracao"}
                  <span
                    class="font-medium text-purple-600 dark:text-purple-400"
                  >
                    {row.indice_refracao || "N/A"}
                  </span>
                {:else if column === "preco_base"}
                  <span class="font-medium text-green-600 dark:text-green-400">
                    {formatCurrency(row.preco_base || 0)}
                  </span>
                {:else if column === "actions"}
                  <div class="flex gap-2 justify-center">
                    <Button
                      variant="primary"
                      size="sm"
                      on:click={() => verRanking(row.id)}
                    >
                      📊 Ranking
                    </Button>

                    <Button
                      variant="ghost"
                      size="sm"
                      on:click={() => verDetalhes(row.id)}
                    >
                      👁️ Ver
                    </Button>
                  </div>
                {:else}
                  {row[column] || "N/A"}
                {/if}
              </svelte:fragment>
            </Table>
          </div>

          <!-- Paginação -->
          {#if totalPaginas > 1}
            <div class="flex justify-center items-center gap-4 mt-6">
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
            icon="📚"
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

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <ActionCard
            icon="⚖️"
            title="Comparar Lentes"
            description="Compare especificações e preços lado a lado"
            actionLabel="Comparar"
            color="blue"
            on:click={compararLentes}
          />

          <ActionCard
            icon="📊"
            title="Análise de Mercado"
            description="Veja tendências e insights do mercado"
            actionLabel="Ver Análise"
            color="green"
            on:click={() => goto("/analytics")}
          />

          <ActionCard
            icon="🔍"
            title="Busca Avançada"
            description="Use filtros específicos para encontrar lentes"
            actionLabel="Buscar"
            color="orange"
            on:click={() => goto("/buscar")}
          />
        </div>
      </section>
    </Container>
  </main>
