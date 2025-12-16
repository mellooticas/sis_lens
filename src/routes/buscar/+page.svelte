<script lang="ts">
  /**
   * Página de Busca de Lentes - Interface Principal
   * Sistema de busca com filtros avançados e resultados em tempo real
   */

  import { goto } from "$app/navigation";
  import { page } from "$app/stores";
  import { enhance } from "$app/forms";
  import type { PageData, ActionData } from "./$types";

  // === Layout ===
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

  // === UI ===
  import Button from "$lib/components/ui/Button.svelte";
  import Input from "$lib/components/forms/Input.svelte";
  import Select from "$lib/components/forms/Select.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import Table from "$lib/components/ui/Table.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // === Cards ===
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";

  // === Feedback ===
  import { toast } from "$lib/stores/toast";

  export let data: PageData;
  export let form: ActionData;

  // Estado da busca
  let query = data.filtros_ativos.query || "";
  let categoria = data.filtros_ativos.categoria || "";
  let material = data.filtros_ativos.material || "";
  let preco_min = data.filtros_ativos.preco_min?.toString() || "";
  let preco_max = data.filtros_ativos.preco_max?.toString() || "";
  let isLoading = false;
  let mostrarFiltrosAvancados = false;

  // Dados reativos
  $: lentes = form?.lentes || data.lentes || [];
  $: totalResultados = form?.total || data.total_resultados || 0;
  $: temResultados = lentes.length > 0;
  $: temFiltrosAtivos = categoria || material || preco_min || preco_max;

  // Mostrar toast se veio do form
  $: if (form?.sucesso) {
    toast.show(form.mensagem || "Busca realizada com sucesso", "success");
  } else if (form?.erro) {
    toast.show(form.erro, "error");
  }

  // Formatador de moeda
  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(value);
  };

  // Opções para selects
  const categoriaOptions = [
    { value: "", label: "Todas as categorias" },
    { value: "monofocal", label: "Monofocal" },
    { value: "bifocal", label: "Bifocal" },
    { value: "progressiva", label: "Progressiva" },
    { value: "office", label: "Office/Antifadiga" },
  ];

  const materialOptions = [
    { value: "", label: "Todos os materiais" },
    { value: "cr39", label: "CR-39 (Resina)" },
    { value: "policarbonato", label: "Policarbonato" },
    { value: "trivex", label: "Trivex" },
    { value: "hi-index-1.67", label: "Hi-Index 1.67" },
    { value: "hi-index-1.74", label: "Hi-Index 1.74" },
    { value: "mineral", label: "Mineral (Vidro)" },
  ];

  // Headers da tabela
  const tableHeaders = [
    { key: "sku_fantasia", label: "SKU", align: "left" as const },
    { key: "descricao_completa", label: "Descrição", align: "left" as const },
    { key: "tipo_lente", label: "Tipo", align: "center" as const },
    { key: "material", label: "Material", align: "center" as const },
    { key: "indice_refracao", label: "Índice", align: "center" as const },
    { key: "actions", label: "Ações", align: "center" as const },
  ];

  // Limpar filtros
  function limparFiltros() {
    query = "";
    categoria = "";
    material = "";
    preco_min = "";
    preco_max = "";
    goto("/buscar");
  }

  // Toggle filtros avançados
  function toggleFiltrosAvancados() {
    mostrarFiltrosAvancados = !mostrarFiltrosAvancados;
  }

  // Navegar para ranking
  function verRanking(lenteId: string) {
    goto(`/ranking?lente_id=${lenteId}`);
  }

  // Ver detalhes
  function verDetalhes(lenteId: string) {
    goto(`/lentes/${lenteId}`);
  }
</script>

<svelte:head>
  <title>Buscar Lentes - SIS Lens</title>
  <meta
    name="description"
    content="Busque lentes oftálmicas com filtros avançados e compare fornecedores"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="🔍 Sistema de Busca Inteligente"
        title="Buscar Lentes"
        subtitle="Encontre as melhores opções com filtros avançados e compare fornecedores em tempo real"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Estatísticas da Busca -->
      {#if data.estatisticas}
        <section class="mt-8">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <StatsCard
              title="Lentes Disponíveis"
              value={data.estatisticas.total_lentes.toString()}
              icon="👓"
              color="blue"
            />

            <StatsCard
              title="Fornecedores Ativos"
              value={data.estatisticas.total_fornecedores.toString()}
              icon="🏢"
              color="green"
            />

            <StatsCard
              title="Preço Médio"
              value={formatCurrency(data.estatisticas.preco_medio)}
              icon="💰"
              color="orange"
            />
          </div>
        </section>
      {/if}

      <!-- Formulário de Busca -->
      <section class="mt-12">
        <div
          class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6 shadow-sm"
        >
          <SectionHeader
            title="Buscar Lentes"
            subtitle="Digite o nome, família ou SKU da lente"
          />

          <form
            method="POST"
            action="?/buscar"
            use:enhance={({ formData }) => {
              isLoading = true;
              return async ({ result, update }) => {
                isLoading = false;
                await update();
              };
            }}
            class="space-y-6"
          >
            <!-- Busca Principal -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-4">
              <div class="lg:col-span-3">
                <Input
                  label="Buscar lentes"
                  placeholder="Ex: Varilux, Essilor 1.67, Progressive..."
                  bind:value={query}
                  name="query"
                  required
                />
              </div>
              <div class="flex items-end">
                <Button
                  type="submit"
                  variant="primary"
                  size="md"
                  fullWidth
                  disabled={isLoading || !query.trim()}
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
                type="button"
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
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  on:click={limparFiltros}
                >
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
                    label="Categoria"
                    bind:value={categoria}
                    name="categoria"
                    options={categoriaOptions}
                  />

                  <Select
                    label="Material"
                    bind:value={material}
                    name="material"
                    options={materialOptions}
                  />

                  <Input
                    label="Preço Mínimo"
                    type="number"
                    placeholder="R$ 0,00"
                    bind:value={preco_min}
                    name="preco_min"
                    min="0"
                    step="0.01"
                  />

                  <Input
                    label="Preço Máximo"
                    type="number"
                    placeholder="R$ 999,99"
                    bind:value={preco_max}
                    name="preco_max"
                    min="0"
                    step="0.01"
                  />
                </div>
              </div>
            {/if}
          </form>
        </div>
      </section>

      <!-- Resultados da Busca -->
      <section class="mt-12">
        <SectionHeader
          title="Resultados da Busca"
          subtitle={temResultados
            ? `${totalResultados} lentes encontradas`
            : ""}
        />

        {#if isLoading}
          <div class="flex justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        {:else if temResultados}
          <div
            class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 overflow-hidden"
          >
            <Table headers={tableHeaders} rows={lentes} hoverable>
              <svelte:fragment slot="cell" let:row let:header>
                {#if header.key === "tipo_lente"}
                  <Badge variant="info" size="sm">
                    {row.tipo_lente || "N/A"}
                  </Badge>
                {:else if header.key === "indice_refracao"}
                  <Badge variant="secondary" size="sm">
                    {row.indice_refracao || "N/A"}
                  </Badge>
                {:else if header.key === "material"}
                  <span class="text-sm text-neutral-600 dark:text-neutral-400">
                    {row.material || "N/A"}
                  </span>
                {:else if header.key === "descricao_completa"}
                  <div class="space-y-1">
                    <p
                      class="font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      {row.descricao_completa || row.familia || "Sem descrição"}
                    </p>
                    {#if row.tratamentos && row.tratamentos.length > 0}
                      <div class="flex flex-wrap gap-1">
                        {#each row.tratamentos as tratamento}
                          <Badge variant="success" size="sm">{tratamento}</Badge
                          >
                        {/each}
                      </div>
                    {/if}
                  </div>
                {:else if header.key === "actions"}
                  <div class="flex gap-2 justify-center">
                    <Button
                      variant="primary"
                      size="sm"
                      on:click={() => verRanking(row.lente_id)}
                    >
                      📊 Ranking
                    </Button>

                    <Button
                      variant="ghost"
                      size="sm"
                      on:click={() => verDetalhes(row.lente_id)}
                    >
                      👁️ Ver
                    </Button>
                  </div>
                {:else}
                  {row[header.key] || "N/A"}
                {/if}
              </svelte:fragment>
            </Table>
          </div>
        {:else if query}
          <EmptyState
            icon="🔍"
            title="Nenhuma lente encontrada"
            description="Não encontramos lentes com os critérios especificados. Tente ajustar os filtros."
            actionLabel="Limpar Filtros"
            on:action={limparFiltros}
          />
        {:else}
          <EmptyState
            icon="👓"
            title="Comece sua busca"
            description="Digite o nome, família ou SKU da lente que você procura"
            actionLabel="Ver Todas as Lentes"
            on:action={() => goto("/catalogo")}
          />
        {/if}
      </section>

      <!-- Ações Rápidas -->
      <section class="mt-12 mb-8">
        <SectionHeader title="Ações Rápidas" />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <ActionCard
            icon="📊"
            title="Ver Fornecedores"
            description="Compare todos os fornecedores disponíveis"
            actionLabel="Ver Fornecedores"
            color="blue"
            on:click={() => goto("/fornecedores")}
          />

          <ActionCard
            icon="📋"
            title="Histórico de Decisões"
            description="Veja suas decisões de compra anteriores"
            actionLabel="Ver Histórico"
            color="green"
            on:click={() => goto("/historico")}
          />

          <ActionCard
            icon="🏢"
            title="Fornecedores"
            description="Veja todos os fornecedores ativos"
            actionLabel="Ver Fornecedores"
            color="orange"
            on:click={() => goto("/fornecedores")}
          />
        </div>
      </section>
    </Container>
  </main>
