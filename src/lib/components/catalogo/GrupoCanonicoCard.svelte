<script lang="ts">
  import type { VGruposCanonico } from '$lib/types/database-views';
  
  export let grupo: VGruposCanonico;
  export let variant: 'standard' | 'premium' = 'standard';
  export let compact = false; // Modo lista compacto

  function formatarPreco(preco: number): string {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(preco);
  }

  function obterCorCategoria(categoria: string | null): string {
    const cores: Record<string, string> = {
      economica: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
      intermediaria: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
      premium: 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200',
      super_premium: 'bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-200'
    };
    return cores[categoria || 'intermediaria'] || cores.intermediaria;
  }
  
  function formatarTexto(texto: string | null): string {
    return texto ? texto.replace(/_/g, ' ') : '-';
  }
  
  $: badgeClasses = variant === 'premium' 
    ? 'bg-gradient-to-r from-amber-100 to-orange-100 text-amber-800 dark:from-amber-900/30 dark:to-orange-900/30 dark:text-amber-300'
    : 'bg-brand-blue-100 text-brand-blue-800 dark:bg-brand-blue-900 dark:text-brand-blue-200';
    
  $: badgeText = variant === 'premium' ? 'Premium' : 'Standard';
  $: linkBase = variant === 'premium' ? '/catalogo/premium' : '/catalogo/standard';
</script>

<a
  href="{linkBase}/{grupo.id}"
  class="grupo-card glass-panel rounded-xl hover:shadow-xl transition-all duration-200 hover:scale-[1.02] block"
  class:p-6={!compact}
  class:p-4={compact}
  class:flex={compact}
  class:items-center={compact}
  class:gap-4={compact}
>
  <!-- Header -->
  <div 
    class:mb-4={!compact} 
    class:flex-shrink-0={compact}
    style={compact ? 'width: 33%;' : ''}
  >
    <h3 
      class="font-bold text-gray-900 dark:text-white mb-2 line-clamp-2"
      class:text-lg={!compact}
      class:text-base={compact}
    >
      {grupo.nome_grupo}
    </h3>
    <div class="flex flex-wrap gap-2">
      {#if grupo.categoria_predominante}
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {obterCorCategoria(grupo.categoria_predominante)}">
          {formatarTexto(grupo.categoria_predominante)}
        </span>
      {/if}
      <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {badgeClasses}">
        {badgeText}
      </span>
    </div>
  </div>

  <!-- Especificações Técnicas -->
  <div class="gap-2 mb-4 text-xs flex-1"
       class:grid={!compact}
       class:grid-cols-3={!compact}
       class:flex={compact}
       class:flex-wrap={compact}>
    <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
      <div class="text-gray-500 dark:text-gray-400">Material</div>
      <div class="font-medium text-gray-900 dark:text-white">{grupo.material}</div>
    </div>
    <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
      <div class="text-gray-500 dark:text-gray-400">Índice</div>
      <div class="font-medium text-gray-900 dark:text-white">{grupo.indice_refracao}</div>
    </div>
    <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
      <div class="text-gray-500 dark:text-gray-400">Tipo</div>
      <div class="font-medium text-gray-900 dark:text-white capitalize">
        {formatarTexto(grupo.tipo_lente)}
      </div>
    </div>
  </div>

  <!-- Tratamentos -->
  {#if grupo.tratamento_antirreflexo || grupo.tratamento_blue_light || grupo.tratamento_fotossensiveis !== 'nenhum' || grupo.tratamento_uv}
    <div class="flex flex-wrap gap-1.5"
         class:mb-4={!compact}
         class:flex-shrink-0={compact}>
      {#if grupo.tratamento_antirreflexo}
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
          AR
        </span>
      {/if}
      {#if grupo.tratamento_blue_light}
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-indigo-50 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300">
          Blue Light
        </span>
      {/if}
      {#if grupo.tratamento_fotossensiveis !== 'nenhum'}
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-purple-50 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300">
          {grupo.tratamento_fotossensiveis}
        </span>
      {/if}
      {#if grupo.tratamento_uv}
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-yellow-50 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300">
          UV
        </span>
      {/if}
    </div>
  {/if}

  {#if !compact}
  <!-- Faixas Ópticas -->
  <div class="border-t border-gray-200 dark:border-gray-700 pt-3 mb-4 text-xs text-gray-600 dark:text-gray-400">
    <div class="grid grid-cols-2 gap-2">
      <div>
        <span class="font-medium">Esférico:</span>
        {grupo.grau_esferico_min > 0 ? '+' : ''}{grupo.grau_esferico_min} a {grupo.grau_esferico_max > 0 ? '+' : ''}{grupo.grau_esferico_max}
      </div>
      <div>
        <span class="font-medium">Cilíndrico:</span>
        {grupo.grau_cilindrico_min} a {grupo.grau_cilindrico_max}
      </div>
    </div>
    {#if grupo.adicao_min !== null && grupo.adicao_max !== null}
      <div class="mt-1">
        <span class="font-medium">Adição:</span>
        +{grupo.adicao_min} a +{grupo.adicao_max}
      </div>
    {/if}
  </div>

  <!-- Estatísticas -->
  <div class="bg-gradient-to-br from-brand-blue-50 to-brand-orange-50 dark:from-gray-900 dark:to-gray-800 rounded-lg p-3 mb-4">
    <div class="grid grid-cols-2 gap-3 text-xs">
      <div>
        <div class="text-gray-600 dark:text-gray-400 mb-1">Lentes Disponíveis</div>
        <div class="text-2xl font-bold text-brand-blue-600">{grupo.total_lentes}</div>
      </div>
      <div>
        <div class="text-gray-600 dark:text-gray-400 mb-1">Marcas</div>
        <div class="text-2xl font-bold text-brand-orange-600">{grupo.total_marcas}</div>
      </div>
    </div>
  </div>
  {/if}

  <!-- Preços -->
  <div class:border-t={!compact}
       class:border-l={compact}
       class:border-gray-200={!compact}
       class:dark:border-gray-700={!compact}
       class:pt-3={!compact}
       class:pl-4={compact}
       class:flex-shrink-0={compact}>
    <div class="flex items-center justify-between mb-2"
         class:flex-col={compact}
         class:items-end={compact}>
      <span class="text-xs text-gray-500 dark:text-gray-400">Preço Médio</span>
      <span class="font-bold text-brand-blue-600"
            class:text-xl={!compact}
            class:text-2xl={compact}>
        {formatarPreco(grupo.preco_medio || 0)}
      </span>
    </div>
    <div class="flex items-center justify-between text-xs text-gray-600 dark:text-gray-400"
         class:flex-col={compact}
         class:items-end={compact}
         class:gap-1={compact}>
      <span>Faixa:</span>
      <span>
        {formatarPreco(grupo.preco_minimo || 0)} - {formatarPreco(grupo.preco_maximo || 0)}
      </span>
    </div>
  </div>
</a>

<style>
  .grupo-card {
    @apply w-full max-w-md;
  }
  
  .line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
</style>
