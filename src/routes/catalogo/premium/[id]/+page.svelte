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
  <title>{grupo?.name || 'Grupo Canônico Premium'} - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
  <!-- Botão Voltar -->
  <div class="mb-6">
    <Button variant="secondary" on:click={() => goto('/catalogo/premium')}>
      ← Voltar ao Catálogo Premium
    </Button>
  </div>

  <!-- Header Premium -->
  <div class="glass-panel rounded-2xl p-8 mb-8 bg-gradient-to-br from-yellow-50 to-amber-50 border-2 border-yellow-200">
    <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
      <div class="flex-1">
        <div class="flex flex-wrap gap-2 mb-4">
          <Badge variant="gold">⭐ Premium</Badge>
          <Badge variant="neutral">{grupo.lens_type?.replace('_', ' ')}</Badge>
          <Badge variant="gold">{grupo.material}</Badge>
          <Badge variant={grupo.is_active ? 'success' : 'neutral'} size="sm">
            {grupo.is_active ? 'Ativo' : 'Inativo'}
          </Badge>
        </div>

        <h1 class="text-3xl md:text-4xl font-bold bg-gradient-to-r from-yellow-700 to-amber-600 bg-clip-text text-transparent mb-2">
          {grupo.name}
        </h1>

        <p class="text-lg text-amber-900">
          {(grupo.lens_type || '').replace('_', ' ')} • {grupo.material} • Índice {grupo.refractive_index}
        </p>
      </div>

      <div class="text-right">
        {#if precos.length > 0}
          <div class="bg-gradient-to-br from-yellow-600 to-amber-600 text-white rounded-2xl p-6 min-w-[200px] shadow-lg">
            <div class="text-sm opacity-90 mb-1">Preço Médio Premium</div>
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
  <SectionHeader title="📊 Estatísticas Gerais" subtitle="Resumo do grupo premium" />

  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 mt-6">
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-yellow-200">
      <div class="text-4xl font-bold text-yellow-600 mb-2">{lentes.length}</div>
      <div class="text-sm text-slate-600">Lentes Premium</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-purple-200">
      <div class="text-4xl font-bold text-purple-600 mb-2">{marcas.length}</div>
      <div class="text-sm text-slate-600">Marcas Premium</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-green-200">
      <div class="text-4xl font-bold text-green-600 mb-2">{fornecedores.length}</div>
      <div class="text-sm text-slate-600">Fornecedores</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-orange-200">
      <div class="text-4xl font-bold text-orange-600 mb-2">{grupo.refractive_index}</div>
      <div class="text-sm text-slate-600">Índice Refração</div>
    </div>
  </div>

  <!-- Especificações Técnicas -->
  <SectionHeader title="🔬 Especificações Técnicas" subtitle="Características ópticas premium" />

  <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8 mt-6">
    <div class="glass-panel p-6 rounded-xl border-2 border-yellow-100">
      <h3 class="font-semibold text-slate-900 mb-4">📏 Material e Índice</h3>
      <div class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-600">Material:</span>
          <span class="font-medium text-yellow-700">{grupo.material}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Índice Refração:</span>
          <span class="font-medium text-yellow-700">{grupo.refractive_index}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Tipo:</span>
          <span class="font-medium capitalize text-yellow-700">{(grupo.lens_type || '').replace('_', ' ')}</span>
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
      <div class="glass-panel p-6 rounded-xl border-2 border-amber-100">
        <h3 class="font-semibold text-slate-900 mb-4">💰 Análise de Preços Premium</h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-500">Mínimo:</span>
            <span class="font-medium">{formatarPreco(precoMin)}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-500">Médio:</span>
            <span class="font-semibold text-amber-600">{formatarPreco(precoMedio)}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-500">Máximo:</span>
            <span class="font-medium">{formatarPreco(precoMax)}</span>
          </div>
        </div>
      </div>
    {/if}
  </div>

  <!-- Marcas Premium -->
  {#if marcas.length > 0}
    <SectionHeader title="👑 Marcas Premium" subtitle={`${marcas.length} marca${marcas.length !== 1 ? 's' : ''} premium neste grupo`} />

    <div class="glass-panel p-6 rounded-xl mb-8 mt-6 border-2 border-yellow-100">
      <div class="flex flex-wrap gap-3">
        {#each marcas as marca}
          <div class="flex items-center gap-2 bg-gradient-to-br from-yellow-50 to-amber-50 px-4 py-2 rounded-lg border-2 border-yellow-200 shadow-sm">
            <span class="font-medium text-amber-900">{marca}</span>
            <Badge variant="gold" size="sm">⭐ Premium</Badge>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Fornecedores -->
  {#if fornecedores.length > 0}
    <SectionHeader title="🚚 Fornecedores" subtitle="Opções de fornecimento premium" />

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

  <!-- Lentes Premium -->
  <SectionHeader
    title="🔍 Lentes Premium"
    subtitle={`${lentes.length} lente${lentes.length !== 1 ? 's' : ''} premium cadastrada${lentes.length !== 1 ? 's' : ''}`}
  />

  <div class="glass-panel p-6 rounded-xl mb-8 mt-6 border-2 border-yellow-100">
    {#if lentes.length === 0}
      <div class="text-center py-20">
        <div class="text-5xl mb-4">📭</div>
        <h3 class="text-xl font-semibold text-slate-900 mb-2">Nenhuma lente encontrada</h3>
        <p class="text-slate-600">Este grupo ainda não possui lentes premium cadastradas</p>
      </div>
    {:else}
      <div class="grid gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {#each lentes as lente (lente.id)}
          <div in:fade>
            <LenteCard {lente} isPremium={true} />
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <!-- Metadata -->
  <div class="glass-panel p-4 rounded-xl mb-8 bg-yellow-50 border-2 border-yellow-100">
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
    <Button variant="secondary" on:click={() => goto('/catalogo/premium')}>
      ← Voltar ao Catálogo Premium
    </Button>
  </div>
</Container>
