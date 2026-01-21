<!--
  🏆 Detalhes Canônica Premium
  Mostra todas as lentes de diferentes laboratórios normalizadas neste grupo
-->
<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { DetalhePremium } from '$lib/types/database-views';

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // State
  let lentes: DetalhePremium[] = [];
  let loading = true;
  let error = '';
  let canonicaInfo: DetalhePremium | null = null;

  const canonicaId = $page.params.id;

  onMount(async () => {
    await carregarDetalhes();
  });

  async function carregarDetalhes() {
    try {
      loading = true;
      error = '';
      
      const resultado = await CatalogoAPI.listarDetalhesPremium(canonicaId);

      if (resultado.success && resultado.data && resultado.data.length > 0) {
        lentes = resultado.data;
        canonicaInfo = lentes[0]; // Pega info da canônica do primeiro item
      } else {
        error = 'Canônica não encontrada ou sem lentes disponíveis';
      }
    } catch (err) {
      error = 'Erro ao carregar detalhes';
    } finally {
      loading = false;
    }
  }

  // Agrupar por marca
  $: lentesAgrupadas = lentes.reduce((acc, lente) => {
    if (!acc[lente.marca_nome]) {
      acc[lente.marca_nome] = [];
    }
    acc[lente.marca_nome].push(lente);
    return acc;
  }, {} as Record<string, DetalhePremium[]>);

  $: marcas = Object.keys(lentesAgrupadas).sort();
  $: precoMinimo = Math.min(...lentes.map(l => l.preco_venda_sugerido));
  $: precoMaximo = Math.max(...lentes.map(l => l.preco_venda_sugerido));
  $: precoMedio = lentes.reduce((sum, l) => sum + l.preco_venda_sugerido, 0) / lentes.length;

  function formatarPreco(valor: number): string {
    return `R$ ${valor.toFixed(2)}`;
  }
</script>

<svelte:head>
  <title>{canonicaInfo?.nome_canonico || 'Detalhes Premium'} - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
  {#if loading}
    <div class="flex flex-col justify-center items-center py-20">
      <LoadingSpinner size="lg" />
      <p class="mt-4 text-slate-600">Carregando detalhes...</p>
    </div>
  
  {:else if error || !canonicaInfo}
    <div class="bg-red-50 border-2 border-red-200 rounded-2xl p-8 text-center">
      <div class="text-5xl mb-4">⚠️</div>
      <p class="text-red-800 text-lg font-medium mb-4">{error}</p>
      <Button variant="primary" on:click={() => goto('/catalogo/premium')}>
        Voltar para Premium
      </Button>
    </div>
  
  {:else}
    <!-- Botão Voltar -->
    <div class="mb-6">
      <Button variant="secondary" on:click={() => goto('/catalogo/premium')}>
        ← Voltar para Premium
      </Button>
    </div>

    <!-- Header da Canônica -->
    <div class="glass-panel rounded-2xl p-8 mb-8">
      <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-6">
        <div class="flex-1">
          <div class="flex flex-wrap gap-2 mb-4">
            <Badge variant="gold">🏆 Premium</Badge>
            <Badge variant="primary">{canonicaInfo.canonica_tipo_lente.replace('_', ' ')}</Badge>
            <Badge variant="neutral">{canonicaInfo.canonica_material}</Badge>
            <Badge variant="neutral">Índice {canonicaInfo.canonica_indice}</Badge>
          </div>
          
          <h1 class="text-3xl md:text-4xl font-bold text-slate-900 mb-2">
            {canonicaInfo.nome_canonico}
          </h1>
          
          {#if canonicaInfo.canonica_linha}
            <p class="text-lg text-slate-600 mb-4">Linha: {canonicaInfo.canonica_linha}</p>
          {/if}

          <p class="text-slate-700">
            {lentes.length} lente{lentes.length > 1 ? 's' : ''} disponíve{lentes.length > 1 ? 'is' : 'l'} 
            de {marcas.length} laboratório{marcas.length > 1 ? 's' : ''}
          </p>
        </div>

        <!-- Estatísticas de Preço -->
        <div class="grid grid-cols-3 gap-4">
          <div class="bg-green-50 rounded-xl p-4 text-center">
            <div class="text-xs text-green-700 mb-1">Mínimo</div>
            <div class="text-lg font-bold text-green-800">{formatarPreco(precoMinimo)}</div>
          </div>
          <div class="bg-blue-50 rounded-xl p-4 text-center">
            <div class="text-xs text-blue-700 mb-1">Médio</div>
            <div class="text-lg font-bold text-blue-800">{formatarPreco(precoMedio)}</div>
          </div>
          <div class="bg-orange-50 rounded-xl p-4 text-center">
            <div class="text-xs text-orange-700 mb-1">Máximo</div>
            <div class="text-lg font-bold text-orange-800">{formatarPreco(precoMaximo)}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Características Comuns -->
    <SectionHeader 
      title="🔬 Características Comuns" 
      subtitle="Especificações técnicas compartilhadas por todas as lentes deste grupo"
    />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
        <div>
          <div class="text-slate-600 text-xs mb-1">Tipo</div>
          <div class="font-medium capitalize">{canonicaInfo.canonica_tipo_lente.replace('_', ' ')}</div>
        </div>
        <div>
          <div class="text-slate-600 text-xs mb-1">Material</div>
          <div class="font-medium">{canonicaInfo.canonica_material}</div>
        </div>
        <div>
          <div class="text-slate-600 text-xs mb-1">Índice</div>
          <div class="font-medium">{canonicaInfo.canonica_indice}</div>
        </div>
        <div>
          <div class="text-slate-600 text-xs mb-1">Categoria</div>
          <div class="font-medium capitalize">{canonicaInfo.categoria.replace('_', ' ')}</div>
        </div>
      </div>
    </div>

    <!-- Comparação por Laboratório -->
    <SectionHeader 
      title="🏭 Comparação por Laboratório" 
      subtitle="Todas as lentes normalizadas com as mesmas características técnicas"
    />

    <div class="space-y-6 mt-6">
      {#each marcas as marca}
        <div class="glass-panel rounded-xl overflow-hidden">
          <!-- Header do Laboratório -->
          <div class="bg-gradient-to-r from-indigo-600 to-purple-600 p-4">
            <div class="flex items-center justify-between">
              <h3 class="text-xl font-bold text-white">{marca}</h3>
              <Badge variant="neutral" className="bg-white/20 text-white">
                {lentesAgrupadas[marca].length} lente{lentesAgrupadas[marca].length > 1 ? 's' : ''}
              </Badge>
            </div>
          </div>

          <!-- Grid de Lentes -->
          <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {#each lentesAgrupadas[marca] as lente}
                <div class="bg-slate-50 rounded-lg p-4 hover:shadow-md transition-shadow">
                  <!-- Nome -->
                  <h4 class="font-semibold text-slate-900 mb-2 leading-tight">
                    {lente.nome_lente}
                  </h4>

                  {#if lente.linha_produto}
                    <p class="text-xs text-slate-600 mb-3">Linha: {lente.linha_produto}</p>
                  {/if}

                  <!-- Tratamentos -->
                  <div class="flex flex-wrap gap-1 mb-3">
                    {#if lente.tem_ar}<Badge variant="blue" size="sm">AR</Badge>{/if}
                    {#if lente.tem_blue}<Badge variant="cyan" size="sm">Blue</Badge>{/if}
                    {#if lente.tratamento_foto !== 'nenhum'}<Badge variant="orange" size="sm">Foto</Badge>{/if}
                    {#if lente.tem_polarizado}<Badge variant="purple" size="sm">Polar</Badge>{/if}
                    {#if lente.tem_digital}<Badge variant="green" size="sm">Digital</Badge>{/if}
                    {#if lente.tem_free_form}<Badge variant="gold" size="sm">Free-Form</Badge>{/if}
                  </div>

                  <!-- Especificações -->
                  <div class="space-y-1 text-xs mb-3">
                    {#if lente.esferico_min != null && lente.esferico_max != null}
                      <div class="flex justify-between">
                        <span class="text-slate-600">Esférico:</span>
                        <span class="font-medium">{lente.esferico_min} a {lente.esferico_max}</span>
                      </div>
                    {/if}
                    {#if lente.cilindrico_min != null && lente.cilindrico_max != null}
                      <div class="flex justify-between">
                        <span class="text-slate-600">Cilíndrico:</span>
                        <span class="font-medium">{lente.cilindrico_min} a {lente.cilindrico_max}</span>
                      </div>
                    {/if}
                    {#if lente.diametro}
                      <div class="flex justify-between">
                        <span class="text-slate-600">Diâmetro:</span>
                        <span class="font-medium">{lente.diametro} mm</span>
                      </div>
                    {/if}
                  </div>

                  <!-- Preço e Disponibilidade -->
                  <div class="border-t pt-3">
                    <div class="flex items-center justify-between mb-2">
                      <div>
                        <div class="text-2xl font-bold text-indigo-700">
                          {formatarPreco(lente.preco_venda_sugerido)}
                        </div>
                        {#if lente.preco_fabricante}
                          <div class="text-xs text-slate-500">
                            Fabricante: {formatarPreco(lente.preco_fabricante)}
                          </div>
                        {/if}
                      </div>
                      <div class="text-right">
                        {#if lente.disponivel}
                          <Badge variant="success" size="sm">Disponível</Badge>
                        {:else}
                          <Badge variant="neutral" size="sm">Indisponível</Badge>
                        {/if}
                        {#if lente.novidade}
                          <Badge variant="blue" size="sm">🆕</Badge>
                        {/if}
                        {#if lente.destaque}
                          <Badge variant="gold" size="sm">⭐</Badge>
                        {/if}
                      </div>
                    </div>

                    {#if lente.prazo_entrega}
                      <div class="text-xs text-slate-600">
                        📦 Prazo: {lente.prazo_entrega} dias
                        {#if lente.obs_prazo}
                          ({lente.obs_prazo})
                        {/if}
                      </div>
                    {/if}
                  </div>

                  <!-- Ações -->
                  <div class="mt-3 pt-3 border-t flex gap-2">
                    <a
                      href="/buscar/{lente.lente_id}"
                      class="flex-1 text-center py-1.5 px-3 bg-indigo-600 text-white text-sm rounded-lg hover:bg-indigo-700 transition-colors"
                    >
                      Ver Detalhes
                    </a>
                  </div>
                </div>
              {/each}
            </div>
          </div>
        </div>
      {/each}
    </div>

    <!-- Resumo de Economia -->
    {#if precoMaximo - precoMinimo > 0}
      <div class="glass-panel p-6 rounded-xl mt-8 bg-green-50 border-2 border-green-200">
        <div class="text-center">
          <div class="text-4xl mb-2">💰</div>
          <h3 class="text-xl font-bold text-green-900 mb-2">Economia de até {formatarPreco(precoMaximo - precoMinimo)}</h3>
          <p class="text-green-700">
            Comparando o preço mais baixo ({formatarPreco(precoMinimo)}) com o mais alto ({formatarPreco(precoMaximo)})
          </p>
          <p class="text-sm text-green-600 mt-2">
            Diferença de {((precoMaximo - precoMinimo) / precoMaximo * 100).toFixed(1)}% entre fornecedores
          </p>
        </div>
      </div>
    {/if}

    <!-- Ações -->
    <div class="flex gap-4 justify-center mt-8">
      <Button variant="secondary" on:click={() => goto('/catalogo/premium')}>
        ← Voltar para Premium
      </Button>
    </div>
  {/if}
</Container>
