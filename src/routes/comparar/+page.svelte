<!--
  ⚖️ Página de Comparação de Fornecedores
  Compare preços de diferentes fornecedores para produtos similares
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import { page } from "$app/stores";

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import EmptyState from "$lib/components/ui/EmptyState.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  
  // Componente de comparação real
  import CompararFornecedores from "$lib/components/catalogo/CompararFornecedores.svelte";

  // Hooks com dados reais
  import { useCompararFornecedores } from "$lib/hooks/useCompararFornecedores";
  
  // State do hook
  const { state, compararPorGrupo } = useCompararFornecedores();

  // Obter parâmetros da URL
  $: skuCanonicoParam = $page.url.searchParams.get('sku') || '';
  
  // Dados reativos
  $: comparacoes = $state.comparacoes || [];
  $: loading = $state.loading;
  $: error = $state.error;

  // Buscar dados automaticamente se há SKU na URL
  $: if (skuCanonicoParam && !loading && comparacoes.length === 0) {
    compararPorGrupo(skuCanonicoParam);
  }
  
  // Estado local para busca
  let skuInput = skuCanonicoParam;

  // Funções
  function buscarComparacao() {
    if (!skuInput.trim()) return;
    goto(`/comparar?sku=${encodeURIComponent(skuInput)}`);
    compararPorGrupo(skuInput);
  }
  
  function limpar() {
    skuInput = '';
    goto('/comparar');
  }
</script>

<svelte:head>
  <title>Comparar Fornecedores - SIS Lens</title>
  <meta
    name="description"
    content="Compare preços entre fornecedores para o mesmo produto canônico"
  />
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
    <!-- Hero Section -->
    <PageHero
      badge="⚖️ Comparação Inteligente"
      title="Comparar Fornecedores"
      subtitle="Encontre o melhor preço comparando diferentes fornecedores para o mesmo produto"
      alignment="center"
      maxWidth="lg"
    />

    <!-- Busca por SKU Canônico -->
    <section class="mt-8">
      <div class="glass-panel rounded-xl p-6 shadow-xl max-w-2xl mx-auto">
        <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-4">
          Buscar por SKU Canônico
        </h3>
        
        <form on:submit|preventDefault={buscarComparacao} class="flex gap-4">
          <input
            type="text"
            bind:value={skuInput}
            placeholder="Ex: SV_CR39_150, PROG_POLY_167..."
            class="flex-1 px-4 py-2 rounded-lg border border-neutral-300 dark:border-neutral-600 
                   bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100
                   focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          
          <Button variant="primary" type="submit" disabled={!skuInput.trim()}>
            🔍 Comparar
          </Button>
          
          {#if skuInput}
            <Button variant="ghost" type="button" on:click={limpar}>
              Limpar
            </Button>
          {/if}
        </form>
        
        <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-2">
          Digite o SKU canônico para comparar preços entre todos os fornecedores
        </p>
      </div>
    </section>

    <!-- Resultados da Comparação -->
    <section class="mt-12">
      {#if loading}
        <div class="flex justify-center py-12">
          <LoadingSpinner size="lg" />
        </div>
      {:else if error}
        <EmptyState
          icon="⚠️"
          title="Erro ao carregar comparação"
          description={error}
        />
      {:else if comparacoes.length === 0 && skuCanonicoParam}
        <EmptyState
          icon="🔍"
          title="Nenhum fornecedor encontrado"
          description="Não encontramos fornecedores para este SKU canônico"
        />
      {:else if comparacoes.length > 0}
        <SectionHeader
          title="Comparação de Fornecedores"
          subtitle={`${comparacoes.length} fornecedor(es) encontrado(s) para "${skuCanonicoParam}"`}
        />
        
        <div class="mt-6 glass-panel rounded-xl p-6 shadow-xl">
          <p class="text-lg font-semibold mb-4">Produto: {comparacoes[0]?.produto || skuCanonicoParam}</p>
          <div class="overflow-x-auto">
            <table class="w-full">
              <thead>
                <tr class="border-b border-neutral-200 dark:border-neutral-700">
                  <th class="text-left p-4">Fornecedor</th>
                  <th class="text-left p-4">SKU</th>
                  <th class="text-right p-4">Preço Tabela</th>
                </tr>
              </thead>
              <tbody>
                {#each comparacoes as comp}
                  {#each comp.opcoes as opcao}
                    <tr class="border-b border-neutral-100 dark:border-neutral-800 hover:bg-neutral-50 dark:hover:bg-neutral-800">
                      <td class="p-4">
                        <p class="font-medium">{opcao.fornecedor}</p>
                        <p class="text-sm text-neutral-600 dark:text-neutral-400">{opcao.marca}</p>
                      </td>
                      <td class="p-4">
                        <p class="text-sm font-mono">{opcao.sku}</p>
                        <p class="text-xs text-neutral-600 dark:text-neutral-400">{opcao.nome_lente}</p>
                      </td>
                      <td class="p-4 text-right">
                        <p class="font-medium text-green-600 dark:text-green-400">
                          {new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(opcao.preco_venda_sugerido || 0)}
                        </p>
                        <p class="text-xs text-neutral-600 dark:text-neutral-400">
                          Custo: {new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(opcao.preco_custo || 0)}
                        </p>
                      </td>
                    </tr>
                  {/each}
                {/each}
              </tbody>
            </table>
          </div>
        </div>
      {:else}
        <EmptyState
          icon="⚖️"
          title="Comece uma comparação"
          description="Digite um SKU canônico acima para comparar preços entre fornecedores"
        />
      {/if}
    </section>

    <!-- Exemplos de SKUs -->
    {#if !skuCanonicoParam}
      <section class="mt-12">
        <SectionHeader
          title="Exemplos de SKUs Canônicos"
          subtitle="Clique para testar a comparação"
        />
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
          <button
            class="glass-panel rounded-lg p-4 hover:shadow-lg transition-shadow text-left"
            on:click={() => {
              skuInput = 'SV_CR39_150';
              buscarComparacao();
            }}
          >
            <p class="font-mono text-blue-600 dark:text-blue-400 font-medium">SV_CR39_150</p>
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-1">
              Visão Simples • CR-39 • Índice 1.50
            </p>
          </button>
          
          <button
            class="glass-panel rounded-lg p-4 hover:shadow-lg transition-shadow text-left"
            on:click={() => {
              skuInput = 'PROG_POLY_167';
              buscarComparacao();
            }}
          >
            <p class="font-mono text-purple-600 dark:text-purple-400 font-medium">PROG_POLY_167</p>
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-1">
              Progressiva • Policarbonato • Índice 1.67
            </p>
          </button>
          
          <button
            class="glass-panel rounded-lg p-4 hover:shadow-lg transition-shadow text-left"
            on:click={() => {
              skuInput = 'BIF_TRIVEX_153';
              buscarComparacao();
            }}
          >
            <p class="font-mono text-green-600 dark:text-green-400 font-medium">BIF_TRIVEX_153</p>
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-1">
              Bifocal • Trivex • Índice 1.53
            </p>
          </button>
        </div>
      </section>
    {/if}
  </Container>
</main>
