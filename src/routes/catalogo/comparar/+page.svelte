<!--
  🔄 Página de Comparação de Labs
  Mostra produtos disponíveis em múltiplos laboratórios
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import type { PageData } from "./$types";

  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Select from "$lib/components/ui/Select.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";

  export let data: PageData;

  // Filtros
  let min_labs = data.filtros?.min_labs?.toString() || "2";
  let tipo = data.filtros?.tipo || "";

  $: produtos = data.produtos || [];
  $: estatisticas = data.estatisticas || {};
  $: minLabsOptions = data.filtros?.opcoes?.min_labs || [];
  $: tiposOptions = data.filtros?.opcoes?.tipos || [];

  function aplicarFiltros() {
    const params = new URLSearchParams();
    if (min_labs) params.set("min_labs", min_labs);
    if (tipo) params.set("tipo", tipo);
    goto(`/catalogo/comparar?${params.toString()}`);
  }

  function limparFiltros() {
    min_labs = "2";
    tipo = "";
    aplicarFiltros();
  }

  function getTipoBadgeVariant(tipo: string) {
    return tipo === "PREMIUM" ? "primary" : "success";
  }
</script>

<svelte:head>
  <title>Comparar Laboratórios - SIS Lens</title>
</svelte:head>

<PageHero
  title="🔄 Comparar Laboratórios"
  description="Produtos disponíveis em múltiplos laboratórios para melhor comparação de preços"
  icon="arrow-left-right"
/>

<Container>
  <!-- Estatísticas -->
  <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
    <StatsCard
      title="Total de Produtos"
      value={estatisticas.total_produtos?.toString() || "0"}
      icon="box"
      variant="primary"
    />
    <StatsCard
      title="Produtos Premium"
      value={estatisticas.total_premium?.toString() || "0"}
      icon="award"
      variant="primary"
    />
    <StatsCard
      title="Produtos Genéricos"
      value={estatisticas.total_generica?.toString() || "0"}
      icon="package"
      variant="success"
    />
    <StatsCard
      title="Máx Labs/Produto"
      value={estatisticas.max_labs_por_produto?.toString() || "0"}
      icon="users"
      variant="warning"
    />
  </div>

  <!-- Filtros -->
  <div class="glass-panel p-6 rounded-xl shadow-xl mb-6">
    <SectionHeader title="Filtros" icon="filter" />

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
      <Select
        label="Mínimo de Labs"
        bind:value={min_labs}
        options={minLabsOptions}
        on:change={aplicarFiltros}
      />

      <Select
        label="Tipo de Produto"
        bind:value={tipo}
        options={tiposOptions}
        on:change={aplicarFiltros}
      />

      <div class="flex items-end gap-2">
        <Button variant="outline" on:click={limparFiltros}>
          Limpar Filtros
        </Button>
      </div>
    </div>
  </div>

  <!-- Lista de Produtos -->
  {#if produtos.length === 0}
    <EmptyState
      title="Nenhum produto encontrado"
      description="Tente ajustar os filtros para ver produtos disponíveis em múltiplos labs"
      icon="search"
    />
  {:else}
    <div class="space-y-6">
      {#each produtos as produto}
        <div class="glass-panel rounded-xl shadow-xl overflow-hidden">
          <!-- Header -->
          <div class="bg-gradient-to-r from-blue-50 to-purple-50 p-6">
            <div class="flex items-start justify-between mb-3">
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-2">
                  <Badge variant={getTipoBadgeVariant(produto.tipo)}>
                    {produto.tipo}
                  </Badge>
                  <Badge variant="outline">
                    {produto.qtd_labs} Labs
                  </Badge>
                </div>
                <h3 class="font-bold text-gray-900 text-xl mb-1">
                  {produto.produto}
                </h3>
                {#if produto.marca}
                  <p class="text-sm text-gray-600">
                    Marca: <span class="font-medium">{produto.marca}</span>
                  </p>
                {/if}
              </div>
            </div>

            <!-- Características -->
            <div class="grid grid-cols-3 gap-4 mt-4">
              <div>
                <p class="text-xs text-gray-600">Tipo de Lente</p>
                <p class="font-medium text-gray-900">{produto.tipo_lente}</p>
              </div>
              <div>
                <p class="text-xs text-gray-600">Material</p>
                <p class="font-medium text-gray-900">{produto.material}</p>
              </div>
              <div>
                <p class="text-xs text-gray-600">Índice</p>
                <p class="font-medium text-gray-900">
                  {produto.indice_refracao}
                </p>
              </div>
            </div>

            <!-- Tratamentos -->
            {#if produto.tratamentos && produto.tratamentos.length > 0}
              <div class="mt-4">
                <p class="text-xs text-gray-600 mb-2">Tratamentos:</p>
                <div class="flex flex-wrap gap-1">
                  {#each produto.tratamentos as tratamento}
                    <Badge variant="outline" size="xs">
                      {tratamento}
                    </Badge>
                  {/each}
                </div>
              </div>
            {/if}
          </div>

          <!-- Opções de Labs -->
          <div class="p-6">
            <h4 class="font-semibold text-gray-900 mb-4">
              Disponível em {produto.qtd_labs} laboratório{produto.qtd_labs !==
              1
                ? "s"
                : ""}:
            </h4>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {#each produto.opcoes_labs || [] as opcao}
                <div
                  class="border border-white/20 rounded-lg p-4 hover:border-blue-300 hover:shadow-sm transition-all bg-white/5"
                >
                  <div class="flex items-start justify-between mb-2">
                    <div class="flex-1">
                      <p class="font-semibold text-gray-900">
                        {opcao.laboratorio}
                      </p>
                      <p class="text-xs text-gray-600 mt-1">
                        SKU: {opcao.sku_laboratorio || "N/A"}
                      </p>
                    </div>
                    <Badge variant="success" size="xs">Disponível</Badge>
                  </div>

                  <Button
                    variant="outline"
                    size="sm"
                    fullWidth
                    class="mt-3"
                    on:click={() => goto(`/ranking?lente_id=${opcao.lente_id}`)}
                  >
                    Ver Ranking
                  </Button>
                </div>
              {/each}
            </div>

            <!-- Ação de Comparação -->
            <div class="mt-6 pt-6 border-t border-gray-200">
              <Button
                variant="primary"
                fullWidth
                on:click={() => goto(`/ranking?grupo_id=${produto.grupo_id}`)}
              >
                🔍 Comparar Preços e Prazos
              </Button>
            </div>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</Container>

<style>
  /* Estilos customizados */
</style>
