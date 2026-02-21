<!--
  📋 Detalhes Completos da Lente
  View v_catalog_lenses + v_catalog_lens_groups + alternativas do mesmo grupo
-->
<script lang="ts">
  import type { PageData } from './$types';
  import { formatarPreco } from '$lib/utils/formatters';

  export let data: PageData;

  const { lente, grupoCanonicos, alternativas } = data;

  // Formatar tratamentos disponíveis
  const tratamentos: string[] = [];
  if (lente.anti_reflective) tratamentos.push('Antirreflexo');
  if (lente.blue_light) tratamentos.push('Blue Light');
  if (lente.uv_filter) tratamentos.push('UV400');
  if (lente.anti_scratch) tratamentos.push('Antirrisco');
  if (lente.polarized) tratamentos.push('Polarizado');
  if (lente.photochromic && lente.photochromic !== 'nenhum') tratamentos.push(`Fotossensível (${lente.photochromic})`);
  if (lente.digital) tratamentos.push('Digital');
  if (lente.free_form) tratamentos.push('Free Form');
  if (lente.indoor) tratamentos.push('Indoor');
  if (lente.drive) tratamentos.push('Drive');
</script>

<svelte:head>
  <title>{lente.lens_name} - Detalhes | SisLens</title>
</svelte:head>

<div class="container mx-auto px-4 py-8">
  <!-- Breadcrumb -->
  <nav class="text-sm mb-6">
    <a href="/buscar" class="text-blue-600 hover:underline">Buscar</a>
    <span class="mx-2">/</span>
    <span class="text-gray-600">{lente.lens_name}</span>
  </nav>

  <!-- Header da Lente -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-6">
    <div class="flex justify-between items-start mb-4">
      <div class="flex-1">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2 truncate max-w-xl" title={lente.lens_name}>
          {lente.lens_name}
        </h1>
        <div class="flex gap-2 text-xs text-gray-500 font-semibold mb-2">
          <span class="uppercase">{(lente.lens_type || '').replace('_', ' ')}</span>
          <span>•</span>
          <span class="capitalize">{(lente.category || '').replace('_', ' ')}</span>
        </div>
        <p class="text-gray-600 dark:text-gray-300">
          {lente.brand_name} • {lente.supplier_name}
        </p>
      </div>
      <div class="text-right min-w-[180px]">
        <div class="text-sm text-gray-500">Preço Sugerido</div>
        <div class="text-4xl font-bold text-green-600">
          {formatarPreco(lente.price_suggested)}
        </div>
        <div class="text-sm text-gray-600 mt-1">
          Prazo: {lente.lead_time_days} dia{lente.lead_time_days > 1 ? 's' : ''}
        </div>
      </div>
    </div>

    <!-- Status Badges -->
    <div class="flex flex-wrap gap-2">
      {#if lente.is_premium}
        <span class="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-medium">Premium</span>
      {/if}
      {#if lente.status === 'active'}
        <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-medium">Ativo</span>
      {:else}
        <span class="px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm font-medium">Inativo</span>
      {/if}
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Coluna Principal -->
    <div class="lg:col-span-2 space-y-6">

      <!-- Características Técnicas -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-xl font-bold mb-4">Características Técnicas</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <span class="text-gray-600 dark:text-gray-400 block">Tipo de Lente</span>
            <span class="font-medium capitalize">{(lente.lens_type || '').replace('_', ' ')}</span>
          </div>
          <div>
            <span class="text-gray-600 dark:text-gray-400 block">Categoria</span>
            <span class="font-medium capitalize">{(lente.category || '').replace('_', ' ')}</span>
          </div>
          <div>
            <span class="text-gray-600 dark:text-gray-400 block">Material</span>
            <span class="font-medium">{lente.material}</span>
          </div>
          <div>
            <span class="text-gray-600 dark:text-gray-400 block">Índice de Refração</span>
            <span class="font-medium">{lente.refractive_index}</span>
          </div>
        </div>
      </div>

      <!-- Ranges Ópticos -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-xl font-bold mb-4">Faixas Ópticas Disponíveis</h2>
        <div class="space-y-3">
          {#if lente.spherical_min !== null && lente.spherical_max !== null}
            <div class="flex justify-between items-center">
              <span class="text-gray-600">Esférico</span>
              <span class="font-medium">
                {lente.spherical_min > 0 ? '+' : ''}{lente.spherical_min} a
                {lente.spherical_max > 0 ? '+' : ''}{lente.spherical_max}
              </span>
            </div>
          {/if}
          {#if lente.cylindrical_min !== null && lente.cylindrical_max !== null}
            <div class="flex justify-between items-center">
              <span class="text-gray-600">Cilíndrico</span>
              <span class="font-medium">{lente.cylindrical_min} a {lente.cylindrical_max}</span>
            </div>
          {/if}
          {#if lente.addition_min !== null && lente.addition_max !== null}
            <div class="flex justify-between items-center">
              <span class="text-gray-600">Adição</span>
              <span class="font-medium">+{lente.addition_min} a +{lente.addition_max}</span>
            </div>
          {/if}
        </div>
      </div>

      <!-- Tratamentos -->
      {#if tratamentos.length > 0}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-xl font-bold mb-4">Tratamentos Aplicados</h2>
          <div class="flex flex-wrap gap-2">
            {#each tratamentos as tratamento}
              <span class="px-4 py-2 bg-blue-50 text-blue-700 rounded-lg font-medium">
                {tratamento}
              </span>
            {/each}
          </div>
        </div>
      {/if}
    </div>

    <!-- Coluna Lateral -->
    <div class="space-y-6">

      <!-- Informações do Grupo Canônico -->
      {#if grupoCanonicos}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-xl font-bold mb-4">Grupo Canônico</h2>
          <div class="space-y-3">
            <div>
              <span class="text-gray-600 block text-sm">Nome do Grupo</span>
              <span class="font-medium">{grupoCanonicos.name}</span>
            </div>
            <div>
              <span class="text-gray-600 block text-sm">Tipo</span>
              <span class="font-medium capitalize">{(grupoCanonicos.lens_type || '').replace('_', ' ')}</span>
            </div>
            <div>
              <span class="text-gray-600 block text-sm">Material</span>
              <span class="font-medium">{grupoCanonicos.material}</span>
            </div>
            <div>
              <span class="text-gray-600 block text-sm">Índice</span>
              <span class="font-medium">{grupoCanonicos.refractive_index}</span>
            </div>
            <div>
              <span class="text-gray-600 block text-sm">Status</span>
              <span class="font-medium">{grupoCanonicos.is_active ? 'Ativo' : 'Inativo'}</span>
            </div>
            {#if grupoCanonicos.is_premium}
              <span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-xs font-medium">⭐ Premium</span>
            {/if}
            {#if lente.group_id}
              <div class="mt-2">
                <a
                  href="/catalogo/{grupoCanonicos.is_premium ? 'premium' : 'standard'}/{lente.group_id}"
                  class="text-sm text-blue-600 hover:underline"
                >
                  Ver grupo completo →
                </a>
              </div>
            {/if}
          </div>
        </div>
      {/if}

      <!-- Fornecedor -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-xl font-bold mb-4">Fornecedor</h2>
        <div class="space-y-2">
          <div>
            <span class="font-medium text-lg">{lente.supplier_name}</span>
          </div>
          <div class="text-sm">
            <span class="text-gray-600">Prazo de Entrega:</span>
            <span class="font-medium">{lente.lead_time_days} dia{lente.lead_time_days > 1 ? 's' : ''}</span>
          </div>
        </div>
      </div>

      <!-- SKU e Identificação -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-xl font-bold mb-4">Identificação</h2>
        <div class="space-y-2 text-sm">
          <div>
            <span class="text-gray-600 block">SKU</span>
            <code class="bg-gray-100 px-2 py-1 rounded">{lente.sku}</code>
          </div>
          <div>
            <span class="text-gray-600 block">ID</span>
            <code class="bg-gray-100 px-2 py-1 rounded text-xs">{lente.id}</code>
          </div>
        </div>
      </div>

      <!-- Estoque -->
      {#if lente.stock_available !== null && lente.stock_available !== undefined}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-xl font-bold mb-4">Estoque</h2>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-gray-600">Disponível:</span>
              <span class="font-medium">{lente.stock_available}</span>
            </div>
            {#if lente.stock_minimum !== null && lente.stock_minimum !== undefined}
              <div class="flex justify-between">
                <span class="text-gray-600">Mínimo:</span>
                <span class="font-medium">{lente.stock_minimum}</span>
              </div>
            {/if}
          </div>
        </div>
      {/if}
    </div>
  </div>

  <!-- Alternativas do Mesmo Grupo -->
  {#if alternativas.length > 0}
    <div class="mt-8">
      <h2 class="text-2xl font-bold mb-4">Alternativas do Mesmo Grupo</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {#each alternativas as alt}
          <a
            href="/lentes/{alt.id}"
            class="block bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-lg transition p-4"
          >
            <h3 class="font-medium mb-2">{alt.lens_name}</h3>
            <div class="text-sm text-gray-600 mb-2">
              {alt.supplier_name}
            </div>
            <div class="flex justify-between items-center">
              <span class="text-lg font-bold text-green-600">
                {formatarPreco(alt.price_suggested)}
              </span>
              <span class="text-sm text-gray-500">
                {alt.lead_time_days}d
              </span>
            </div>
          </a>
        {/each}
      </div>
    </div>
  {/if}
</div>
