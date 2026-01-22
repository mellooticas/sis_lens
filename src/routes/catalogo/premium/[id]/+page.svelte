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

  function formatarPreco(valor: number | null): string {
    if (!valor) return '-';
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
  }

  function formatarPercentual(valor: number | null): string {
    if (!valor) return '-';
    return `${valor.toFixed(2)}%`;
  }
</script>

<svelte:head>
  <title>{grupo?.nome_grupo || 'Grupo Canônico Premium'} - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
  <!-- Botão Voltar -->
  <div class="mb-6">
    <Button variant="secondary" on:click={() => goto('/catalogo/premium')}>
      ← Voltar ao Catálogo Premium
    </Button>
  </div>

  <!-- Header -->
  <div class="glass-panel rounded-2xl p-8 mb-8 bg-gradient-to-br from-yellow-50 to-amber-50 border-2 border-yellow-200">
    <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
      <div class="flex-1">
        <div class="flex flex-wrap gap-2 mb-4">
          <Badge variant="gold">⭐ Premium</Badge>
          <Badge variant="neutral">{grupo.tipo_lente?.replace('_', ' ')}</Badge>
          <Badge variant="gold">{grupo.categoria_preco || grupo.categoria_predominante}</Badge>
          {#if grupo.tem_antirreflexo}
            <Badge variant="success">AR</Badge>
          {/if}
          {#if grupo.tem_blue_light}
            <Badge variant="blue">Blue Light</Badge>
          {/if}
          {#if grupo.tratamento_foto !== 'nenhum'}
            <Badge variant="warning">Fotossensível</Badge>
          {/if}
          {#if grupo.tem_uv}
            <Badge variant="success">UV</Badge>
          {/if}
        </div>
        
        <h1 class="text-3xl md:text-4xl font-bold bg-gradient-to-r from-yellow-700 to-amber-600 bg-clip-text text-transparent mb-2">
          {grupo.nome_grupo}
        </h1>
        
        {#if grupo.descricao_ranges}
          <p class="text-lg text-amber-900">{grupo.descricao_ranges}</p>
        {/if}
      </div>

      <div class="text-right">
        <div class="bg-gradient-to-br from-yellow-600 to-amber-600 text-white rounded-2xl p-6 min-w-[200px] shadow-lg">
          <div class="text-sm opacity-90 mb-1">Preço Médio Premium</div>
          <div class="text-3xl font-bold">{formatarPreco(grupo.preco_medio)}</div>
          <div class="text-xs opacity-75 mt-2">
            De {formatarPreco(grupo.preco_minimo)} até {formatarPreco(grupo.preco_maximo)}
          </div>
          {#if grupo.faixa_preco}
            <div class="text-xs opacity-75 mt-1">{grupo.faixa_preco}</div>
          {/if}
        </div>
      </div>
    </div>
  </div>

  <!-- Estatísticas Gerais -->
  <SectionHeader title="📊 Estatísticas Gerais" subtitle="Resumo do grupo premium" />
  
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 mt-6">
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-yellow-200">
      <div class="text-4xl font-bold text-yellow-600 mb-2">{grupo.total_lentes || 0}</div>
      <div class="text-sm text-slate-600">Lentes Premium</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-purple-200">
      <div class="text-4xl font-bold text-purple-600 mb-2">{grupo.total_marcas || 0}</div>
      <div class="text-sm text-slate-600">Marcas Premium</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-green-200">
      <div class="text-4xl font-bold text-green-600 mb-2">{grupo.total_fornecedores || 0}</div>
      <div class="text-sm text-slate-600">Fornecedores</div>
    </div>
    <div class="glass-panel p-6 rounded-xl text-center border-2 border-orange-200">
      <div class="text-4xl font-bold text-orange-600 mb-2">{grupo.prazo_medio_dias || 0}</div>
      <div class="text-sm text-slate-600">Prazo Médio (dias)</div>
    </div>
  </div>

  <!-- Especificações Técnicas -->
  <SectionHeader title="🔬 Especificações Técnicas" subtitle="Características ópticas premium" />
  
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8 mt-6">
    <div class="glass-panel p-6 rounded-xl border-2 border-yellow-100">
      <h3 class="font-semibold text-slate-900 mb-4">📏 Material e Índice</h3>
      <div class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-600">Material:</span>
          <span class="font-medium text-yellow-700">{grupo.material}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Índice Refração:</span>
          <span class="font-medium text-yellow-700">{grupo.indice_refracao}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Tipo:</span>
          <span class="font-medium capitalize text-yellow-700">{grupo.tipo_lente.replace('_', ' ')}</span>
        </div>
      </div>
    </div>

    <div class="glass-panel p-6 rounded-xl border-2 border-purple-100">
      <h3 class="font-semibold text-slate-900 mb-4">🎯 Faixas de Graus</h3>
      <div class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-600">Esférico:</span>
          <span class="font-medium text-purple-700">
            {grupo.grau_esferico_min ?? '-'} a {grupo.grau_esferico_max ?? '-'}
          </span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Cilíndrico:</span>
          <span class="font-medium text-purple-700">
            {grupo.grau_cilindrico_min ?? '-'} a {grupo.grau_cilindrico_max ?? '-'}
          </span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Adição:</span>
          <span class="font-medium text-purple-700">
            {grupo.adicao_min ?? '-'} a {grupo.adicao_max ?? '-'}
          </span>
        </div>
      </div>
    </div>

    <div class="glass-panel p-6 rounded-xl border-2 border-green-100">
      <h3 class="font-semibold text-slate-900 mb-4">✨ Tratamentos</h3>
      <div class="space-y-2 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-600">Anti-Reflexo:</span>
          <span>{grupo.tem_antirreflexo ? '✅' : '❌'}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Anti-Risco:</span>
          <span>{grupo.tem_antirrisco ? '✅' : '❌'}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Blue Light:</span>
          <span>{grupo.tem_blue_light ? '✅' : '❌'}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">UV:</span>
          <span>{grupo.tem_uv ? '✅' : '❌'}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-600">Fotossensível:</span>
          <span class="font-medium capitalize">{grupo.tratamento_foto}</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Análise Financeira -->
  <SectionHeader title="💰 Análise Financeira Premium" subtitle="Custos, margens e lucratividade" />
  
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 mt-6">
    <div class="glass-panel p-6 rounded-xl border-2 border-blue-100">
      <h4 class="text-sm text-slate-600 mb-2">Preços</h4>
      <div class="space-y-1 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-500">Mínimo:</span>
          <span class="font-medium">{formatarPreco(grupo.preco_minimo)}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-500">Médio:</span>
          <span class="font-semibold text-blue-600">{formatarPreco(grupo.preco_medio)}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-500">Máximo:</span>
          <span class="font-medium">{formatarPreco(grupo.preco_maximo)}</span>
        </div>
      </div>
    </div>

    <div class="glass-panel p-6 rounded-xl border-2 border-orange-100">
      <h4 class="text-sm text-slate-600 mb-2">Custos</h4>
      <div class="space-y-1 text-sm">
        <div class="flex justify-between">
          <span class="text-slate-500">Mínimo:</span>
          <span class="font-medium">{formatarPreco(grupo.custo_minimo)}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-500">Médio:</span>
          <span class="font-semibold text-orange-600">{formatarPreco(grupo.custo_medio)}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-slate-500">Máximo:</span>
          <span class="font-medium">{formatarPreco(grupo.custo_maximo)}</span>
        </div>
      </div>
    </div>

    <div class="glass-panel p-6 rounded-xl bg-gradient-to-br from-green-50 to-emerald-50 border-2 border-green-200">
      <h4 class="text-sm text-green-800 mb-2 font-medium">Lucro Unitário</h4>
      <div class="text-3xl font-bold text-green-700">
        {formatarPreco(grupo.lucro_unitario)}
      </div>
      <div class="text-xs text-green-600 mt-1">Por lente vendida</div>
    </div>

    <div class="glass-panel p-6 rounded-xl bg-gradient-to-br from-purple-50 to-indigo-50 border-2 border-purple-200">
      <h4 class="text-sm text-purple-800 mb-2 font-medium">Margem</h4>
      <div class="text-3xl font-bold text-purple-700">
        {formatarPercentual(grupo.margem_percentual)}
      </div>
      <div class="text-xs text-purple-600 mt-1">Markup: {grupo.markup || '-'}x</div>
    </div>
  </div>

  <!-- Marcas Premium -->
  {#if grupo.marcas_disponiveis && Array.isArray(grupo.marcas_disponiveis) && grupo.marcas_disponiveis.length > 0}
    <SectionHeader title="👑 Marcas Premium" subtitle={`${grupo.marcas_disponiveis.length} marca${grupo.marcas_disponiveis.length !== 1 ? 's' : ''} premium neste grupo`} />
    
    <div class="glass-panel p-6 rounded-xl mb-8 mt-6 border-2 border-yellow-100">
      <div class="flex flex-wrap gap-3">
        {#each grupo.marcas_disponiveis as marca}
          <div class="flex items-center gap-2 bg-gradient-to-br from-yellow-50 to-amber-50 px-4 py-2 rounded-lg border-2 border-yellow-200 shadow-sm">
            <span class="font-medium text-amber-900">{typeof marca === 'string' ? marca : marca.marca_nome}</span>
            <Badge variant="gold" size="sm">⭐ Premium</Badge>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Fornecedores -->
  {#if grupo.fornecedores_disponiveis && Array.isArray(grupo.fornecedores_disponiveis) && grupo.fornecedores_disponiveis.length > 0}
    <SectionHeader title="🚚 Fornecedores" subtitle="Opções de fornecimento premium" />
    
    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {#each grupo.fornecedores_disponiveis as fornecedor}
          <div class="bg-white p-4 rounded-lg border border-slate-200">
            <div class="font-semibold text-slate-900 mb-2">{typeof fornecedor === 'string' ? fornecedor : fornecedor.nome}</div>
            {#if typeof fornecedor === 'object' && fornecedor.prazo_visao_simples}
              <div class="text-xs text-slate-600 space-y-1">
                <div>Visão Simples: {fornecedor.prazo_visao_simples || 0} dias</div>
                <div>Multifocal: {fornecedor.prazo_multifocal || 0} dias</div>
              </div>
            {/if}
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
        <span class="font-medium">Slug:</span> {grupo.slug}
      </div>
      <div>
        <span class="font-medium">Peso:</span> {grupo.peso}
      </div>
      <div>
        <span class="font-medium">Cadastro:</span> 
        {new Date(grupo.created_at).toLocaleDateString('pt-BR')}
      </div>
      <div>
        <span class="font-medium">Atualização:</span> 
        {new Date(grupo.updated_at).toLocaleDateString('pt-BR')}
      </div>
      <div>
        <span class="font-medium">Status:</span> 
        <Badge variant={grupo.ativo ? 'gold' : 'neutral'} size="sm">
          {grupo.ativo ? '⭐ Ativo' : 'Inativo'}
        </Badge>
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
