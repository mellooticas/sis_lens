<!--
  🏆 Página de Produtos Premium
  Catálogo de produtos premium agrupados por canônicas
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
  let marca_id = data.filtros?.marca_id || "";
  let tipo_lente = data.filtros?.tipo_lente || "";

  $: produtos = data.produtos || [];
  $: estatisticas = data.estatisticas || {};
  $: marcasOptions = data.filtros?.opcoes?.marcas || [];
  $: tiposOptions = data.filtros?.opcoes?.tipos_lente || [];

  function aplicarFiltros() {
    const params = new URLSearchParams();
    if (marca_id) params.set("marca_id", marca_id);
    if (tipo_lente) params.set("tipo_lente", tipo_lente);
    goto(`/catalogo/premium?${params.toString()}`);
  }

  function limparFiltros() {
    marca_id = "";
    tipo_lente = "";
    aplicarFiltros();
  }

  function verDetalhes(produtoId: string) {
    goto(`/catalogo/premium/${produtoId}`);
  }
</script>

<svelte:head>
  <title>Produtos Premium - SIS Lens</title>
</svelte:head>

<PageHero
  title="🏆 Produtos Premium"
  description="Catálogo de lentes premium agrupadas por produto canônico"
  icon="sparkles"
/>

<Container>
  <!-- Estatísticas -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <StatsCard
      title="Total de Produtos"
      value={estatisticas.total_produtos?.toString() || "0"}
      icon="box"
      variant="primary"
    />
    <StatsCard
      title="Marcas Premium"
      value={estatisticas.total_marcas?.toString() || "0"}
      icon="award"
      variant="success"
    />
    <StatsCard
      title="Média Labs/Produto"
      value={estatisticas.media_labs_por_produto?.toFixed(1) || "0.0"}
      icon="users"
      variant="warning"
    />
  </div>

  <!-- Filtros -->
  <div class="glass-panel p-6 rounded-xl shadow-xl mb-6">
    <SectionHeader title="Filtros" icon="filter" />

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
      <Select
        label="Marca"
        bind:value={marca_id}
        options={marcasOptions}
        on:change={aplicarFiltros}
      />

      <Select
        label="Tipo de Lente"
        bind:value={tipo_lente}
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
      title="Nenhum produto premium encontrado"
      description="Tente ajustar os filtros para ver mais resultados"
      icon="search"
    />
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each produtos as produto}
        <div
          class="glass-panel rounded-xl shadow-xl p-6 hover:shadow-2xl transition-all duration-300"
        >
          <!-- Header do Card -->
          <div class="flex items-start justify-between mb-4">
            <div class="flex-1">
              <Badge variant="primary" size="sm" class="mb-2">PREMIUM</Badge>
              <h3 class="font-semibold text-gray-900 text-lg mb-1">
                {produto.nome}
              </h3>
              <p class="text-sm text-gray-600">{produto.marca}</p>
            </div>
          </div>

          <!-- Características -->
          <div class="space-y-2 mb-4">
            <div class="flex justify-between text-sm">
              <span class="text-gray-600">Tipo:</span>
              <span class="font-medium">{produto.tipo_lente}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-gray-600">Material:</span>
              <span class="font-medium">{produto.material}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-gray-600">Índice:</span>
              <span class="font-medium">{produto.indice_refracao}</span>
            </div>
          </div>

          <!-- Tratamentos -->
          {#if produto.tratamentos && produto.tratamentos.length > 0}
            <div class="mb-4">
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

          <!-- Disponibilidade em Labs -->
          <div class="border-t pt-4 mb-4">
            <p class="text-sm font-medium text-gray-700 mb-2">
              Disponível em {produto.qtd_laboratorios} laboratório{produto.qtd_laboratorios !==
              1
                ? "s"
                : ""}:
            </p>
            <div class="space-y-1">
              {#each produto.laboratorios?.slice(0, 3) || [] as lab}
                <div class="text-xs text-gray-600">
                  • {lab.laboratorio}
                </div>
              {/each}
              {#if produto.laboratorios?.length > 3}
                <div class="text-xs text-blue-600">
                  + {produto.laboratorios.length - 3} mais
                </div>
              {/if}
            </div>
          </div>

          <!-- Ações -->
          <Button
            variant="primary"
            size="sm"
            fullWidth
            on:click={() => verDetalhes(produto.id)}
          >
            Ver Detalhes e Comparar
          </Button>
        </div>
      {/each}
    </div>
  {/if}
</Container>

<style>
  /* Adicione estilos customizados se necessário */
</style>
