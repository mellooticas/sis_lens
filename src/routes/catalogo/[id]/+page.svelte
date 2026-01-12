<!--
  📋 Detalhes da Lente
  Todas as informações completas do banco de dados
-->
<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CatalogoAPI } from '$lib/api/catalogo-api';
  import type { LenteCatalogo } from '$lib/types/database-views';

  // Componentes padronizados
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // State
  let lente: LenteCatalogo | null = null;
  let loading = true;
  let error = '';

  const lenteId = $page.params.id;

  onMount(async () => {
    await carregarDetalhes();
  });

  async function carregarDetalhes() {
    try {
      loading = true;
      error = '';
      
      const resultado = await CatalogoAPI.obterLente(lenteId);

      if (resultado.success && resultado.data) {
        lente = resultado.data;
      } else {
        error = resultado.error || 'Lente não encontrada';
      }
    } catch (err) {
      error = 'Erro ao carregar detalhes';
      console.error('Erro:', err);
    } finally {
      loading = false;
    }
  }

  function formatarPreco(valor: number | null): string {
    if (!valor) return '-';
    return `R$ ${valor.toFixed(2)}`;
  }

  function formatarBoolean(valor: boolean): string {
    return valor ? '✅ Sim' : '❌ Não';
  }
</script>

<svelte:head>
  <title>{lente?.nome_comercial || 'Detalhes da Lente'} - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
  {#if loading}
    <div class="flex flex-col justify-center items-center py-20">
      <LoadingSpinner size="lg" />
      <p class="mt-4 text-slate-600">Carregando detalhes...</p>
    </div>
  
  {:else if error || !lente}
    <div class="bg-red-50 border-2 border-red-200 rounded-2xl p-8 text-center">
      <div class="text-5xl mb-4">⚠️</div>
      <p class="text-red-800 text-lg font-medium mb-4">{error}</p>
      <Button variant="primary" on:click={() => goto('/catalogo')}>
        Voltar ao Catálogo
      </Button>
    </div>
  
  {:else}
    <!-- Botão Voltar -->
    <div class="mb-6">
      <Button variant="secondary" on:click={() => goto('/catalogo')}>
        ← Voltar ao Catálogo
      </Button>
    </div>

    <!-- Header -->
    <div class="glass-panel rounded-2xl p-8 mb-8">
      <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
        <div class="flex-1">
          <div class="flex flex-wrap gap-2 mb-4">
            <Badge variant="primary">{lente.marca_nome}</Badge>
            <Badge variant={lente.categoria.includes('premium') ? 'gold' : 'neutral'}>
              {lente.categoria.replace('_', ' ')}
            </Badge>
            {#if lente.destaque}
              <Badge variant="gold">⭐ Destaque</Badge>
            {/if}
            {#if lente.novidade}
              <Badge variant="blue">🆕 Novidade</Badge>
            {/if}
          </div>
          
          <h1 class="text-3xl md:text-4xl font-bold text-slate-900 mb-2">
            {lente.nome_lente}
          </h1>
          
          {#if lente.nome_grupo}
            <p class="text-lg text-slate-600 mb-4">Grupo: {lente.nome_grupo}</p>
          {/if}
        </div>

        <div class="text-right">
          <div class="bg-gradient-to-br from-indigo-600 to-purple-600 text-white rounded-2xl p-6 min-w-[200px]">
            <div class="text-sm opacity-90 mb-1">Preço Sugerido</div>
            <div class="text-3xl font-bold">{formatarPreco(lente.preco_venda_sugerido)}</div>
            <div class="text-xs opacity-75 mt-2">Custo: {formatarPreco(lente.preco_custo)}</div>
            {#if lente.margem_lucro}
              <div class="text-xs opacity-75">Margem: {lente.margem_lucro.toFixed(1)}%</div>
            {/if}
          </div>
        </div>
      </div>
    </div>

    <!-- Informações Técnicas -->
    <SectionHeader title="🔬 Especificações Técnicas" subtitle="Características ópticas e técnicas" />
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8 mt-6">
      <!-- Tipo e Material -->
      <div class="glass-panel p-6 rounded-xl">
        <h3 class="font-semibold text-slate-900 mb-4 flex items-center gap-2">
          👓 Tipo e Material
        </h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-600">Tipo:</span>
            <span class="font-medium capitalize">{lente.tipo_lente.replace('_', ' ')}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Material:</span>
            <span class="font-medium">{lente.material}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Índice Refração:</span>
            <span class="font-medium">{lente.indice_refracao}</span>
          </div>
        </div>
      </div>

      <!-- Dimensões -->
      <div class="glass-panel p-6 rounded-xl">
        <h3 class="font-semibold text-slate-900 mb-4 flex items-center gap-2">
          📏 Dimensões
        </h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-600">Diâmetro:</span>
            <span class="font-medium">{lente.diametro ? `${lente.diametro} mm` : '-'}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Espessura Central:</span>
            <span class="font-medium">{lente.espessura_central ? `${lente.espessura_central} mm` : '-'}</span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Peso Aproximado:</span>
            <span class="font-medium">{lente.peso_aproximado ? `${lente.peso_aproximado} g` : '-'}</span>
          </div>
        </div>
      </div>

      <!-- Faixas Ópticas -->
      <div class="glass-panel p-6 rounded-xl">
        <h3 class="font-semibold text-slate-900 mb-4 flex items-center gap-2">
          🎯 Faixas Ópticas
        </h3>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-slate-600">Esférico:</span>
            <span class="font-medium">
              {lente.esferico_min != null && lente.esferico_max != null 
                ? `${lente.esferico_min} a ${lente.esferico_max}` 
                : '-'}
            </span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Cilíndrico:</span>
            <span class="font-medium">
              {lente.cilindrico_min != null && lente.cilindrico_max != null 
                ? `${lente.cilindrico_min} a ${lente.cilindrico_max}` 
                : '-'}
            </span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">Adição:</span>
            <span class="font-medium">
              {lente.adicao_min != null && lente.adicao_max != null 
                ? `${lente.adicao_min} a ${lente.adicao_max}` 
                : '-'}
            </span>
          </div>
          <div class="flex justify-between">
            <span class="text-slate-600">DNP:</span>
            <span class="font-medium">
              {lente.dnp_min != null && lente.dnp_max != null 
                ? `${lente.dnp_min} a ${lente.dnp_max} mm` 
                : '-'}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Tratamentos -->
    <SectionHeader title="✨ Tratamentos e Proteções" subtitle="Tecnologias aplicadas" />
    
    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.ar ? '✅' : '❌'}</span>
          <span class="text-sm">Anti-Reflexo</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.antirrisco ? '✅' : '❌'}</span>
          <span class="text-sm">Anti-Risco</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.hidrofobico ? '✅' : '❌'}</span>
          <span class="text-sm">Hidrofóbico</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.antiembaçante ? '✅' : '❌'}</span>
          <span class="text-sm">Anti-Embaçante</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.blue ? '✅' : '❌'}</span>
          <span class="text-sm">Blue Light</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.uv400 ? '✅' : '❌'}</span>
          <span class="text-sm">UV400</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.fotossensivel !== 'nenhum' ? '✅' : '❌'}</span>
          <span class="text-sm">Fotossensível ({lente.fotossensivel})</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.polarizado ? '✅' : '❌'}</span>
          <span class="text-sm">Polarizado</span>
        </div>
      </div>
    </div>

    <!-- Tecnologias -->
    <SectionHeader title="🚀 Tecnologias" subtitle="Recursos avançados" />
    
    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.digital ? '✅' : '❌'}</span>
          <span class="text-sm">Digital</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.free_form ? '✅' : '❌'}</span>
          <span class="text-sm">Free-Form</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.indoor ? '✅' : '❌'}</span>
          <span class="text-sm">Indoor</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">{lente.drive ? '✅' : '❌'}</span>
          <span class="text-sm">Drive</span>
        </div>
      </div>
    </div>

    <!-- Descrição Completa -->
    {#if lente.descricao_completa}
      <SectionHeader title="📝 Descrição Completa" />
      <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
        <p class="text-slate-700 whitespace-pre-wrap">{lente.descricao_completa}</p>
      </div>
    {/if}

    <!-- Benefícios -->
    {#if lente.beneficios && lente.beneficios.length > 0}
      <SectionHeader title="⭐ Benefícios" />
      <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
        <ul class="space-y-2">
          {#each lente.beneficios as beneficio}
            <li class="flex items-start gap-2">
              <span class="text-green-600 mt-1">✓</span>
              <span class="text-slate-700">{beneficio}</span>
            </li>
          {/each}
        </ul>
      </div>
    {/if}

    <!-- Indicações -->
    {#if lente.indicacoes && lente.indicacoes.length > 0}
      <SectionHeader title="👍 Indicações" />
      <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
        <ul class="space-y-2">
          {#each lente.indicacoes as indicacao}
            <li class="flex items-start gap-2">
              <span class="text-blue-600 mt-1">→</span>
              <span class="text-slate-700">{indicacao}</span>
            </li>
          {/each}
        </ul>
      </div>
    {/if}

    <!-- Contraindicações -->
    {#if lente.contraindicacoes}
      <SectionHeader title="⚠️ Contraindicações" />
      <div class="glass-panel p-6 rounded-xl mb-8 mt-6 bg-amber-50">
        <p class="text-slate-700">{lente.contraindicacoes}</p>
      </div>
    {/if}

    <!-- Logística e Entrega -->
    <SectionHeader title="📦 Logística e Entrega" />
    
    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div>
          <div class="text-sm text-slate-600 mb-1">Prazo de Entrega</div>
          <div class="text-lg font-semibold">
            {lente.prazo_entrega ? `${lente.prazo_entrega} dias` : '-'}
          </div>
          {#if lente.obs_prazo}
            <div class="text-xs text-slate-500 mt-1">{lente.obs_prazo}</div>
          {/if}
        </div>
        <div>
          <div class="text-sm text-slate-600 mb-1">Peso Frete</div>
          <div class="text-lg font-semibold">
            {lente.peso_frete ? `${lente.peso_frete} kg` : '-'}
          </div>
        </div>
        <div>
          <div class="text-sm text-slate-600 mb-1">Receita Especial</div>
          <div class="text-lg font-semibold">
            {lente.exige_receita_especial !== null 
              ? (lente.exige_receita_especial ? '✅ Requerido' : '❌ Não requerido')
              : '-'}
          </div>
        </div>
      </div>
    </div>

    <!-- Informações Comerciais -->
    <SectionHeader title="💰 Informações Comerciais" />
    
    <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div>
          <div class="text-sm text-slate-600 mb-1">SKU Fornecedor</div>
          <div class="font-mono text-sm">{lente.sku_fornecedor}</div>
        </div>
        {#if lente.codigo_original}
          <div>
            <div class="text-sm text-slate-600 mb-1">Código Original</div>
            <div class="font-mono text-sm">{lente.codigo_original}</div>
          </div>
        {/if}
        <div>
          <div class="text-sm text-slate-600 mb-1">Custo Base</div>
          <div class="text-lg font-semibold">{formatarPreco(lente.custo_base)}</div>
        </div>
        <div>
          <div class="text-sm text-slate-600 mb-1">Status</div>
          <div>
            <Badge variant={lente.status === 'ativo' ? 'success' : 'neutral'}>
              {lente.status}
            </Badge>
          </div>
        </div>
      </div>
    </div>

    <!-- Observações -->
    {#if lente.observacoes}
      <SectionHeader title="📌 Observações" />
      <div class="glass-panel p-6 rounded-xl mb-8 mt-6">
        <p class="text-slate-700 whitespace-pre-wrap">{lente.observacoes}</p>
      </div>
    {/if}

    <!-- Datas -->
    <div class="glass-panel p-4 rounded-xl mb-8 bg-slate-50">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-xs text-slate-600">
        <div>
          <span class="font-medium">Cadastro:</span> {new Date(lente.created_at).toLocaleDateString('pt-BR')}
        </div>
        <div>
          <span class="font-medium">Atualização:</span> {new Date(lente.updated_at).toLocaleDateString('pt-BR')}
        </div>
        {#if lente.data_lancamento}
          <div>
            <span class="font-medium">Lançamento:</span> {new Date(lente.data_lancamento).toLocaleDateString('pt-BR')}
          </div>
        {/if}
        {#if lente.data_descontinuacao}
          <div>
            <span class="font-medium">Descontinuação:</span> {new Date(lente.data_descontinuacao).toLocaleDateString('pt-BR')}
          </div>
        {/if}
      </div>
    </div>

    <!-- Ações -->
    <div class="flex gap-4 justify-center">
      <Button variant="secondary" on:click={() => goto('/catalogo')}>
        ← Voltar ao Catálogo
      </Button>
      <Button variant="primary">
        🛒 Adicionar ao Pedido
      </Button>
    </div>
  {/if}
</Container>
