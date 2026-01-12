<!--
  ��� Detalhes Grupo Canônico Standard - SIS Lens
  Mostra todas as lentes pertencentes a este grupo
-->
<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { fade } from 'svelte/transition';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { VGruposCanonico, VLenteCatalogo } from '$lib/types/database-views';

  // Ícones
  import { ArrowLeft, Package, Users, TrendingUp, Eye } from 'lucide-svelte';

  // Componentes
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
  import LenteCard from "$lib/components/catalogo/LenteCard.svelte";
  import StatsCard from "$lib/components/cards/StatsCard.svelte";

  // State
  let grupo: VGruposCanonico | null = null;
  let lentes: VLenteCatalogo[] = [];
  let loading = true;
  let error = '';

  const grupoId = $page.params.id;

  onMount(async () => {
    await carregarDetalhes();
  });

  async function carregarDetalhes() {
    try {
      loading = true;
      error = '';
      
      if (!grupoId) {
        error = 'ID do grupo não encontrado';
        return;
      }
      
      // Buscar detalhes do grupo
      const resultadoGrupo = await CatalogoAPI.obterGrupoCanonico(grupoId);

      if (resultadoGrupo.success && resultadoGrupo.data) {
        grupo = resultadoGrupo.data;
      } else {
        error = 'Grupo não encontrado';
        return;
      }

      // Buscar lentes do grupo
      const resultadoLentes = await CatalogoAPI.buscarLentesDoGrupo(grupoId);

      if (resultadoLentes.success && resultadoLentes.data) {
        lentes = resultadoLentes.data;
      }

    } catch (err) {
      error = err instanceof Error ? err.message : 'Erro desconhecido';
    } finally {
      loading = false;
    }
  }

  function formatarPreco(preco: number): string {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 0 }).format(preco);
  }

  function voltarCatalogo() {
    goto('/catalogo/standard');
  }

  function getIndiceLabel(indice: string): string {
    const map: Record<string, string> = {
      '1.50': 'Standard (1.50)',
      '1.53': 'Médio (1.53)',
      '1.56': 'Médio Alto (1.56)',
      '1.59': 'Alto (1.59)',
      '1.60': 'Alto (1.60)',
      '1.67': 'Super Alto (1.67)',
      '1.70': 'Ultra Alto (1.70)',
      '1.74': 'Ultra Alto (1.74)',
      '1.76': 'Ultra Alto (1.76)'
    };
    return map[indice] || indice;
  }
</script>

<svelte:head>
  <title>{grupo?.nome_grupo || 'Grupo Canônico'} - SIS Lens</title>
</svelte:head>

{#if loading}
  <Container maxWidth="full" padding="lg">
    <div class="flex items-center justify-center py-20">
      <LoadingSpinner size="lg" />
    </div>
  </Container>
{:else if error || !grupo}
  <Container maxWidth="full" padding="lg">
    <div class="text-center py-20">
      <div class="text-5xl mb-4">⚠️</div>
      <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Grupo não encontrado</h3>
      <p class="text-gray-600 dark:text-gray-400 mb-6">{error}</p>
      <Button variant="primary" on:click={voltarCatalogo}>
        <ArrowLeft class="w-4 h-4" />
        Voltar ao Catálogo
      </Button>
    </div>
  </Container>
{:else}
  <div in:fade>
    <PageHero title={grupo.nome_grupo} subtitle={grupo.categoria_predominante || 'Grupo Canônico Standard'} />

    <Container maxWidth="full" padding="lg">
      <div class="space-y-6">
        <div class="flex items-center justify-between">
          <Button variant="secondary" size="sm" on:click={voltarCatalogo}>
            <ArrowLeft class="w-4 h-4" />
            Voltar
          </Button>
          <div class="flex items-center gap-2">
            <Badge variant="info">Standard</Badge>
            {#if grupo.tratamento_antirreflexo}
              <Badge variant="info">AR</Badge>
            {/if}
            {#if grupo.tratamento_blue_light}
              <Badge variant="info">Blue Light</Badge>
            {/if}
            {#if grupo.tratamento_fotossensiveis}
              <Badge variant="warning">Fotossensível</Badge>
            {/if}
            {#if grupo.tratamento_uv}
              <Badge variant="success">UV</Badge>
            {/if}
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <StatsCard title="Total de Lentes" value={grupo.total_lentes.toString()} icon="���" color="blue" />
          <StatsCard title="Marcas Diferentes" value={grupo.total_marcas.toString()} icon="🏢" color="blue" />
          <StatsCard title="Preço Médio" value={formatarPreco(grupo.preco_medio || 0)} icon="���" color="orange" />
          <StatsCard title="Faixa de Preço" value={`${formatarPreco(grupo.preco_minimo || 0)} - ${formatarPreco(grupo.preco_maximo || 0)}`} icon="���" color="green" />
        </div>

        <div class="glass-panel p-6 rounded-xl">
          <SectionHeader title="Especificações Técnicas" subtitle="Características do grupo" />
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-6">
            <div class="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Material</div>
              <div class="text-lg font-semibold text-gray-900 dark:text-white">{grupo.material || 'N/A'}</div>
            </div>

            <div class="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Índice de Refração</div>
              <div class="text-lg font-semibold text-gray-900 dark:text-white">{getIndiceLabel(grupo.indice_refracao)}</div>
            </div>

            <div class="bg-gray-50 dark:bg-gray-800 p-4 rounded-lg">
              <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Tipo</div>
              <div class="text-lg font-semibold text-gray-900 dark:text-white">{grupo.tipo_lente || 'N/A'}</div>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
            <div class="bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/30 dark:to-blue-800/30 p-4 rounded-lg border border-blue-200 dark:border-blue-700">
              <div class="text-sm text-blue-700 dark:text-blue-300 mb-1 font-medium">Grau Esférico</div>
              <div class="text-lg font-bold text-blue-900 dark:text-blue-100">
                {grupo.grau_esferico_min || 0} a {grupo.grau_esferico_max || 0}
              </div>
            </div>

            <div class="bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900/30 dark:to-purple-800/30 p-4 rounded-lg border border-purple-200 dark:border-purple-700">
              <div class="text-sm text-purple-700 dark:text-purple-300 mb-1 font-medium">Grau Cilíndrico</div>
              <div class="text-lg font-bold text-purple-900 dark:text-purple-100">
                {grupo.grau_cilindrico_min || 0} a {grupo.grau_cilindrico_max || 0}
              </div>
            </div>

            <div class="bg-gradient-to-br from-orange-50 to-orange-100 dark:from-orange-900/30 dark:to-orange-800/30 p-4 rounded-lg border border-orange-200 dark:border-orange-700">
              <div class="text-sm text-orange-700 dark:text-orange-300 mb-1 font-medium">Adição</div>
              <div class="text-lg font-bold text-orange-900 dark:text-orange-100">
                {grupo.adicao_min || 0} a {grupo.adicao_max || 0}
              </div>
            </div>
          </div>
        </div>

        <div class="glass-panel p-6 rounded-xl">
          <div class="flex items-center justify-between mb-6">
            <SectionHeader title="Lentes Disponíveis" subtitle={`${lentes.length} lente${lentes.length !== 1 ? 's' : ''} neste grupo`} />
          </div>

          {#if lentes.length === 0}
            <div class="text-center py-20">
              <div class="text-5xl mb-4">���</div>
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Nenhuma lente encontrada</h3>
              <p class="text-gray-600 dark:text-gray-400">Este grupo ainda não possui lentes cadastradas</p>
            </div>
          {:else}
            <div class="grid gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {#each lentes as lente (lente.id)}
                <div in:fade>
                  <LenteCard {lente} />
                </div>
              {/each}
            </div>
          {/if}
        </div>
      </div>
    </Container>
  </div>
{/if}
