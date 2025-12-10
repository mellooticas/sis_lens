<!--
  ⚖️ Página de Comparação de Lentes
  Compare especificações e preços lado a lado
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import type { PageData } from "./$types";

  // Componentes padronizados
  import Header from "$lib/components/layout/Header.svelte";

  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import ActionCard from "$lib/components/cards/ActionCard.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";

  export let data: PageData;

  // Dados computados
  $: lentesComparacao = data.lentes_comparacao || [];
  $: lentesSugeridas = data.lentes_sugeridas || [];
  $: totalSelecionadas = data.total_selecionadas || 0;
  $: maxComparacao = data.max_comparacao || 3;
  $: podeAdicionarMais = totalSelecionadas < maxComparacao;

  // Funções
  function formatCurrency(value: number): string {
    if (!value) return "R$ 0,00";
    return value.toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
    });
  }

  function adicionarLente(lenteId: string) {
    const params = new URLSearchParams(window.location.search);
    const proximoSlot = `lente${totalSelecionadas + 1}`;
    params.set(proximoSlot, lenteId);
    goto(`/comparar?${params.toString()}`);
  }

  function removerLente(index: number) {
    const params = new URLSearchParams(window.location.search);
    params.delete(`lente${index + 1}`);
    goto(`/comparar?${params.toString()}`);
  }

  function limparComparacao() {
    goto("/comparar");
  }

  function verRanking(lenteId: string) {
    goto(`/ranking?lente_id=${lenteId}`);
  }
</script>

<svelte:head>
  <title>Comparar Lentes - BestLens</title>
  <meta
    name="description"
    content="Compare especificações e preços de lentes lado a lado"
  />
</svelte:head>

<div class="min-h-screen bg-neutral-50 dark:bg-neutral-900 transition-colors">
  <Header currentPage="comparar" />

  <main>
    <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="⚖️ Comparação Inteligente"
        title="Comparar Lentes"
        subtitle="Compare até 3 lentes lado a lado para tomar a melhor decisão"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Status da Comparação -->
      <section class="mt-8">
        <div
          class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6 shadow-sm"
        >
          <div class="flex items-center justify-between">
            <div>
              <h2
                class="text-lg font-semibold text-neutral-900 dark:text-neutral-100"
              >
                Comparação Ativa
              </h2>
              <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-1">
                {totalSelecionadas} de {maxComparacao} lentes selecionadas
              </p>
            </div>

            <div class="flex gap-2">
              {#if totalSelecionadas > 0}
                <Button variant="ghost" size="sm" on:click={limparComparacao}>
                  🗑️ Limpar Todas
                </Button>
              {/if}

              <Button
                variant="primary"
                size="sm"
                disabled={totalSelecionadas === 0}
              >
                📊 Gerar Relatório
              </Button>
            </div>
          </div>

          <!-- Indicador de Progresso -->
          <div class="mt-4">
            <div
              class="w-full bg-neutral-200 dark:bg-neutral-700 rounded-full h-2"
            >
              <div
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                style="width: {(totalSelecionadas / maxComparacao) * 100}%"
              ></div>
            </div>
          </div>
        </div>
      </section>

      <!-- Tabela de Comparação -->
      {#if lentesComparacao.length > 0}
        <section class="mt-12">
          <SectionHeader
            title="Comparação Detalhada"
            subtitle="Especificações lado a lado"
          />

          <div
            class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 overflow-hidden mt-6"
          >
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead
                  class="bg-neutral-50 dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-700"
                >
                  <tr>
                    <th
                      class="px-6 py-4 text-left text-sm font-semibold text-neutral-700 dark:text-neutral-300"
                    >
                      Especificação
                    </th>
                    {#each lentesComparacao as lente, index}
                      <th
                        class="px-6 py-4 text-center text-sm font-semibold text-neutral-700 dark:text-neutral-300"
                      >
                        <div class="space-y-2">
                          <div class="font-medium">Lente {index + 1}</div>
                          <Button
                            variant="ghost"
                            size="sm"
                            on:click={() => removerLente(index)}
                          >
                            ❌ Remover
                          </Button>
                        </div>
                      </th>
                    {/each}
                  </tr>
                </thead>

                <tbody
                  class="divide-y divide-neutral-200 dark:divide-neutral-700"
                >
                  <!-- Nome/Família -->
                  <tr>
                    <td
                      class="px-6 py-4 font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      Nome/Família
                    </td>
                    {#each lentesComparacao as lente}
                      <td class="px-6 py-4 text-center">
                        <div class="space-y-1">
                          <div
                            class="font-medium text-neutral-900 dark:text-neutral-100"
                          >
                            {lente.familia || "N/A"}
                          </div>
                          <div
                            class="text-xs text-neutral-500 dark:text-neutral-400"
                          >
                            {lente.sku_canonico || ""}
                          </div>
                        </div>
                      </td>
                    {/each}
                  </tr>

                  <!-- Marca -->
                  <tr class="bg-neutral-50 dark:bg-neutral-900/50">
                    <td
                      class="px-6 py-4 font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      Marca
                    </td>
                    {#each lentesComparacao as lente}
                      <td class="px-6 py-4 text-center">
                        <Badge variant="primary" size="sm">
                          {lente.marca_nome || "N/A"}
                        </Badge>
                      </td>
                    {/each}
                  </tr>

                  <!-- Tipo -->
                  <tr>
                    <td
                      class="px-6 py-4 font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      Tipo de Lente
                    </td>
                    {#each lentesComparacao as lente}
                      <td class="px-6 py-4 text-center">
                        <Badge variant="success" size="sm">
                          {lente.tipo_lente || "N/A"}
                        </Badge>
                      </td>
                    {/each}
                  </tr>

                  <!-- Material -->
                  <tr class="bg-neutral-50 dark:bg-neutral-900/50">
                    <td
                      class="px-6 py-4 font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      Material
                    </td>
                    {#each lentesComparacao as lente}
                      <td class="px-6 py-4 text-center">
                        <Badge variant="warning" size="sm">
                          {lente.material || "N/A"}
                        </Badge>
                      </td>
                    {/each}
                  </tr>

                  <!-- Índice de Refração -->
                  <tr>
                    <td
                      class="px-6 py-4 font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      Índice de Refração
                    </td>
                    {#each lentesComparacao as lente}
                      <td
                        class="px-6 py-4 text-center font-medium text-purple-600 dark:text-purple-400"
                      >
                        {lente.indice_refracao || "N/A"}
                      </td>
                    {/each}
                  </tr>

                  <!-- Preço Base -->
                  <tr class="bg-neutral-50 dark:bg-neutral-900/50">
                    <td
                      class="px-6 py-4 font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      Preço Base
                    </td>
                    {#each lentesComparacao as lente}
                      <td
                        class="px-6 py-4 text-center font-bold text-green-600 dark:text-green-400"
                      >
                        {formatCurrency(lente.preco_base || 0)}
                      </td>
                    {/each}
                  </tr>

                  <!-- Ações -->
                  <tr>
                    <td
                      class="px-6 py-4 font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      Ações
                    </td>
                    {#each lentesComparacao as lente}
                      <td class="px-6 py-4 text-center">
                        <div class="space-y-2">
                          <Button
                            variant="primary"
                            size="sm"
                            on:click={() => verRanking(lente.id)}
                          >
                            📊 Ver Ranking
                          </Button>
                        </div>
                      </td>
                    {/each}
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </section>
      {/if}

      <!-- Adicionar Lentes -->
      {#if podeAdicionarMais && lentesSugeridas.length > 0}
        <section class="mt-12">
          <SectionHeader
            title="Adicionar Lentes à Comparação"
            subtitle={`Selecione até ${maxComparacao - totalSelecionadas} lentes para comparar`}
          />

          <div
            class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6"
          >
            {#each lentesSugeridas.slice(0, 9) as lente}
              <div
                class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-4 hover:shadow-md transition-shadow"
              >
                <div class="space-y-3">
                  <div>
                    <h3
                      class="font-medium text-neutral-900 dark:text-neutral-100"
                    >
                      {lente.familia || "N/A"}
                    </h3>
                    <p class="text-sm text-neutral-600 dark:text-neutral-400">
                      {lente.marca_nome || "N/A"}
                    </p>
                  </div>

                  <div class="flex items-center gap-2">
                    <Badge variant="primary" size="sm">
                      {lente.tipo_lente || "N/A"}
                    </Badge>
                    <span
                      class="text-sm font-medium text-green-600 dark:text-green-400"
                    >
                      {formatCurrency(lente.preco_base || 0)}
                    </span>
                  </div>

                  <Button
                    variant="primary"
                    size="sm"
                    fullWidth
                    on:click={() => adicionarLente(lente.id)}
                  >
                    ➕ Adicionar
                  </Button>
                </div>
              </div>
            {/each}
          </div>
        </section>
      {/if}

      <!-- Estado Vazio -->
      {#if lentesComparacao.length === 0}
        <section class="mt-12">
          <EmptyState
            icon="⚖️"
            title="Nenhuma lente selecionada"
            description="Adicione lentes para começar a comparação. Você pode comparar até 3 lentes simultaneamente."
            actionLabel="Explorar Catálogo"
            on:action={() => goto("/catalogo")}
          />
        </section>
      {/if}

      <!-- Ações Rápidas -->
      <section class="mt-12 mb-8">
        <SectionHeader title="Ações Rápidas" />

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <ActionCard
            icon="📚"
            title="Explorar Catálogo"
            description="Navegue pelo catálogo completo de lentes"
            actionLabel="Ver Catálogo"
            color="blue"
            on:click={() => goto("/catalogo")}
          />

          <ActionCard
            icon="🔍"
            title="Busca Avançada"
            description="Use filtros específicos para encontrar lentes"
            actionLabel="Buscar"
            color="green"
            on:click={() => goto("/buscar")}
          />

          <ActionCard
            icon="📊"
            title="Ver Rankings"
            description="Compare fornecedores por lente específica"
            actionLabel="Rankings"
            color="orange"
            on:click={() => goto("/ranking")}
          />
        </div>
      </section>
    </Container>
  </main>
</div>
