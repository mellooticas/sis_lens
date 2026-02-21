<script lang="ts">
  import { goto } from '$app/navigation';
  import { fade } from 'svelte/transition';
  import type { PageData } from './$types';

  // Componentes
  import Container from "$lib/components/layout/Container.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LenteCard from "$lib/components/catalogo/LenteCard.svelte";

  // Dados vindos do servidor (+page.server.ts)
  export let data: PageData;

  $: grupo = data.grupo;
  $: lentes = data.lentes || [];

  // Estatísticas computadas a partir das lentes (VCatalogLensGroup não tem stats agregados)
  $: precos = lentes.map((l: any) => l.price_suggested).filter((p: number) => p > 0);
  $: precoMin = precos.length > 0 ? Math.min(...precos) : 0;
  $: precoMax = precos.length > 0 ? Math.max(...precos) : 0;
  $: precoMedio = precos.length > 0 ? precos.reduce((a: number, b: number) => a + b, 0) / precos.length : 0;
  $: marcas = [...new Set(lentes.map((l: any) => l.brand_name).filter(Boolean))];
  $: fornecedores = [...new Set(lentes.map((l: any) => l.supplier_name).filter(Boolean))];

  function formatarPreco(valor: number | null): string {
    if (!valor) return '-';
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }
</script>

<svelte:head>
  <title>{grupo?.name || 'Grupo Canônico Standard'} - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
  <!-- Botão Voltar -->
  <div class="mb-6">
    <Button variant="secondary" on:click={() => goto('/catalogo/standard')}>
      ← Voltar ao Catálogo Standard
    </Button>
  </div>

  <!-- Header -->
  <div class="glass-panel rounded-2xl p-8 mb-8 bg-gradient-to-br from-blue-50 to-indigo-50">
    <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
      <div class="flex-1">
        <div class="flex flex-wrap gap-2 mb-4">
          <Badge variant="primary">Standard</Badge>
          <Badge variant="neutral">{grupo.lens_type?.replace('_', ' ')}</Badge>
          <Badge variant="info">{grupo.material}</Badge>
          <Badge variant={grupo.is_active ? 'success' : 'neutral'} size="sm">
            {grupo.is_active ? 'Ativo' : 'Inativo'}
          </Badge>
        </div>

        <h1 class="text-3xl md:text-4xl font-bold text-slate-900 mb-2">
          {grupo.name}
        </h1>

        <p class="text-lg text-slate-600">
          {(grupo.lens_type || '').replace('_', ' ')} • {grupo.material} • Índice {grupo.refractive_index}
        </p>
      </div>

      <div class="text-right">
        {#if precos.length > 0}
          <div class="bg-gradient-to-br from-blue-600 to-indigo-600 text-white rounded-2xl p-6 min-w-[200px]">
            <div class="text-sm opacity-90 mb-1">Preço Médio</div>
            <div class="text-3xl font-bold">{formatarPreco(precoMedio)}</div>
            <div class="text-xs opacity-75 mt-2">
              De {formatarPreco(precoMin)} até {formatarPreco(precoMax)}
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>

  <!-- Estatísticas Gerais (computadas das lentes) -->
  <SectionHeader title="📊 Estatísticas Gerais" subtitle="Resumo do grupo" />

  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 mt-6">
    <div class="glass-panel p-6 rounded-xl text-center">
      <div class="text-4xl font-bold text-blue-600 mb-2">{lentes.length}</div>
      <div class="text-sm text-slate-600">Lentes</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center">
      <div class="text-4xl font-bold text-purple-600 mb-2">{marcas.length}</div>
      <div class="text-sm text-slate-600">Marcas</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center">
      <div class="text-4xl font-bold text-green-600 mb-2">{fornecedores.length}</div>
      <div class="text-sm text-slate-600">Fornecedores</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center">
      <div class="text-4xl font-bold text-orange-600 mb-2">{grupo.refractive_index}</div>
      <div class="text-sm text-slate-600">Índice Refração</div>
    </div>
  </div>

  <!-- Especificações Técnicas -->
  <SectionHeader title="🔬 Especificações Técnicas" subtitle="Características ópticas" />

  <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8 mt-6">
    <div class="glass-panel p-6 rounded-xl">
      <h3 class="font-semibold text-slate-900 mb-4">📏 Material e Índice</h3>
      <div class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-600">Material:</span>
          <span class="font-medium">{grupo.material}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Índice Refração:</span>
          <span class="font-medium">{grupo.refractive_index}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Tipo:</span>
          <span class="font-medium capitalize">{(grupo.lens_type || '').replace('_', ' ')}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Status:</span>
          <Badge variant={grupo.is_active ? 'success' : 'neutral'} size="sm">
            {grupo.is_active ? 'Ativo' : 'Inativo'}
          </Badge>
        </div>
      </div>
    </div>

    {#if precos.length > 0}
      <div class="glass-panel p-6 rounded-xl">
        <h3 class="font-semibold text-slate-900 mb-4">💰 Análise de Preços</h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-500">Mínimo:</span>
            <span class="font-medium">{formatarPreco(precoMin)}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-500">Médio:</span>
            <span class="font-semibold text-blue-600">{formatarPreco(precoMedio)}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-500">Máximo:</span>
            <span class="font-medium">{formatarPreco(precoMax)}</span>
          </div>
        </div>
      </div>
    {/if}
  </div>

  <!-- Marcas -->
  {#if marcas.length > 0}
    <SectionHeader title="🏷️ Marcas" subtitle={`${marcas.length} marca${marcas.length !== 1 ? 's' : ''} neste grupo`} />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="flex flex-wrap gap-3">
        {#each marcas as marca}
          <div class="flex items-center gap-2 bg-blue-50 px-4 py-2 rounded-lg border border-blue-200">
            <span class="font-medium text-slate-900">{marca}</span>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Fornecedores -->
  {#if fornecedores.length > 0}
    <SectionHeader title="🚚 Fornecedores" subtitle="Opções de fornecimento" />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="flex flex-wrap gap-3">
        {#each fornecedores as fornecedor}
          <div class="bg-white p-3 rounded-lg border border-slate-200">
            <span class="font-medium text-slate-900">{fornecedor}</span>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Lentes -->
  <SectionHeader
    title="🔍 Lentes"
    subtitle={`${lentes.length} lente${lentes.length !== 1 ? 's' : ''} cadastrada${lentes.length !== 1 ? 's' : ''}`}
  />

  <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
    {#if lentes.length === 0}
      <div class="text-center py-20">
        <div class="text-5xl mb-4">📭</div>
        <h3 class="text-xl font-semibold text-slate-900 mb-2">Nenhuma lente encontrada</h3>
        <p class="text-slate-600">Este grupo ainda não possui lentes cadastradas</p>
      </div>
    {:else}
      <div class="grid gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {#each lentes as lente (lente.id)}
          <div in:fade>
            <LenteCard {lente} isPremium={false} />
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <!-- Metadata -->
  <div class="glass-panel p-4 rounded-xl mb-8 bg-slate-50">
    <div class="grid grid-cols-2 md:grid-cols-3 gap-4 text-xs text-slate-600">
      <div>
        <span class="font-medium">ID:</span>
        <span class="font-mono">{grupo.id.slice(0, 8)}...</span>
      </div>
      <div>
        <span class="font-medium">Cadastro:</span>
        {new Date(grupo.created_at).toLocaleDateString('pt-BR')}
      </div>
      <div>
        <span class="font-medium">Atualização:</span>
        {new Date(grupo.updated_at).toLocaleDateString('pt-BR')}
      </div>
    </div>
  </div>

  <!-- Ações -->
  <div class="flex gap-4 justify-center">
    <Button variant="secondary" on:click={() => goto('/catalogo/standard')}>
      ← Voltar ao Catálogo
    </Button>
  </div>
</Container>
