<!--
  📋 Detalhes Completos da Lente
  View v_lentes + v_grupos_canonicos + alternativas do mesmo grupo
-->
<script lang="ts">
  import type { PageData } from './$types';
  import { formatarPreco } from '$lib/utils/formatters';
  
  export let data: PageData;
  
  const { lente, grupoCanonicos, alternativas } = data;
  
  // Formatar tratamentos disponíveis
  const tratamentos: string[] = [];
  if (lente.tem_ar) tratamentos.push('Antirreflexo');
  if (lente.tem_blue) tratamentos.push('Blue Light');
  if (lente.tem_uv) tratamentos.push('UV400');
  if (lente.tem_antirrisco) tratamentos.push('Antirrisco');
  if (lente.tratamento_hidrofobico) tratamentos.push('Hidrofóbico');
  if (lente.tratamento_antiembacante) tratamentos.push('Antiembaçante');
  if (lente.tem_polarizado) tratamentos.push('Polarizado');
  if (lente.tratamento_foto !== 'nenhum') tratamentos.push(`Fotossensível (${lente.tratamento_foto})`);
  if (lente.tem_digital) tratamentos.push('Digital');
  if (lente.tem_free_form) tratamentos.push('Free Form');
  if (lente.tem_indoor) tratamentos.push('Indoor');
  if (lente.tem_drive) tratamentos.push('Drive');
</script>

<svelte:head>
  <title>{lente.nome_lente} - Detalhes | SisLens</title>
</svelte:head>

<div class="container mx-auto px-4 py-8">
  <!-- Breadcrumb -->
  <nav class="text-sm mb-6">
    <a href="/buscar" class="text-blue-600 hover:underline">Buscar</a>
    <span class="mx-2">/</span>
    <span class="text-gray-600">{lente.nome_lente}</span>
  </nav>

  <!-- Header da Lente -->
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-6">
    <div class="flex justify-between items-start mb-4">
      <div class="flex-1">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2 truncate max-w-xl" title={lente.nome_lente}>
          {lente.nome_lente}
        </h1>
        <div class="flex gap-2 text-xs text-gray-500 font-semibold mb-2">
          <span class="uppercase">{lente.tipo_lente.replace('_', ' ')}</span>
          <span>•</span>
          <span class="capitalize">{lente.categoria.replace('_', ' ')}</span>
        </div>
        <p class="text-gray-600 dark:text-gray-300">
          {lente.marca_nome} • {lente.fornecedor_nome}
        </p>
      </div>
      <div class="text-right min-w-[180px]">
        <div class="text-sm text-gray-500">Preço Sugerido</div>
        <div class="text-4xl font-bold text-green-600">
          {formatarPreco(lente.preco_venda_sugerido)}
        </div>
        <div class="text-sm text-gray-600 mt-1">
          Prazo: {lente.prazo_dias} dia{lente.prazo_dias > 1 ? 's' : ''}
        </div>
      </div>
    </div>

    <!-- Status Badges -->
    <div class="flex flex-wrap gap-2">
      {#if lente.marca_premium}
        <span class="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-medium">Premium</span>
      {/if}
      {#if lente.novidade}
        <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium">Novidade</span>
      {/if}
      {#if lente.destaque}
        <span class="px-3 py-1 bg-purple-100 text-purple-800 rounded-full text-sm font-medium">Destaque</span>
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
            <span class="font-medium capitalize">{lente.tipo_lente.replace('_', ' ')}</span>
          </div>
          <div>
            <span class="text-gray-600 dark:text-gray-400 block">Categoria</span>
            <span class="font-medium capitalize">{lente.categoria.replace('_', ' ')}</span>
          </div>
          <div>
            <span class="text-gray-600 dark:text-gray-400 block">Material</span>
            <span class="font-medium">{lente.material}</span>
          </div>
          <div>
            <span class="text-gray-600 dark:text-gray-400 block">Índice de Refração</span>
            <span class="font-medium">{lente.indice_refracao}</span>
          </div>
          {#if lente.linha_produto}
            <div class="col-span-2">
              <span class="text-gray-600 dark:text-gray-400 block">Linha de Produto</span>
              <span class="font-medium">{lente.linha_produto}</span>
            </div>
          {/if}
        </div>
      </div>

      <!-- Ranges Ópticos -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-xl font-bold mb-4">Faixas Ópticas Disponíveis</h2>
        <div class="space-y-3">
          {#if lente.grau_esferico_min !== null && lente.grau_esferico_max !== null}
            <div class="flex justify-between items-center">
              <span class="text-gray-600">Esférico</span>
              <span class="font-medium">
                {lente.grau_esferico_min > 0 ? '+' : ''}{lente.grau_esferico_min} a 
                {lente.grau_esferico_max > 0 ? '+' : ''}{lente.grau_esferico_max}
              </span>
            </div>
          {/if}
          {#if lente.grau_cilindrico_min !== null && lente.grau_cilindrico_max !== null}
            <div class="flex justify-between items-center">
              <span class="text-gray-600">Cilíndrico</span>
              <span class="font-medium">{lente.grau_cilindrico_min} a {lente.grau_cilindrico_max}</span>
            </div>
          {/if}
          {#if lente.adicao_min !== null && lente.adicao_max !== null}
            <div class="flex justify-between items-center">
              <span class="text-gray-600">Adição</span>
              <span class="font-medium">+{lente.adicao_min} a +{lente.adicao_max}</span>
            </div>
          {/if}
          {#if lente.dnp_min !== null && lente.dnp_max !== null}
            <div class="flex justify-between items-center">
              <span class="text-gray-600">DNP</span>
              <span class="font-medium">{lente.dnp_min}mm a {lente.dnp_max}mm</span>
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

      <!-- Descrições -->
      {#if lente.descricao_completa || lente.beneficios || lente.indicacoes}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-xl font-bold mb-4">Informações Adicionais</h2>
          
          {#if lente.descricao_completa}
            <div class="mb-4">
              <h3 class="font-semibold mb-2">Descrição</h3>
              <p class="text-gray-600">{lente.descricao_completa}</p>
            </div>
          {/if}
          
          {#if lente.beneficios}
            <div class="mb-4">
              <h3 class="font-semibold mb-2">Benefícios</h3>
              <p class="text-gray-600">{lente.beneficios}</p>
            </div>
          {/if}
          
          {#if lente.indicacoes}
            <div class="mb-4">
              <h3 class="font-semibold mb-2">Indicações</h3>
              <p class="text-gray-600">{lente.indicacoes}</p>
            </div>
          {/if}

          {#if lente.contraindicacoes}
            <div class="mb-4">
              <h3 class="font-semibold mb-2">Contraindicações</h3>
              <p class="text-red-600">{lente.contraindicacoes}</p>
            </div>
          {/if}
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
              <span class="font-medium">{grupoCanonicos.nome_grupo}</span>
            </div>
            <div>
              <span class="text-gray-600 block text-sm">Total de Lentes</span>
              <span class="font-medium">{grupoCanonicos.total_lentes}</span>
            </div>
            <div>
              <span class="text-gray-600 block text-sm">Faixa de Preço</span>
              <span class="font-medium">
                {formatarPreco(grupoCanonicos.preco_minimo)} - {formatarPreco(grupoCanonicos.preco_maximo)}
              </span>
            </div>
            <div>
              <span class="text-gray-600 block text-sm">Preço Médio</span>
              <span class="font-medium text-lg text-green-600">
                {formatarPreco(grupoCanonicos.preco_medio)}
              </span>
            </div>
            {#if grupoCanonicos.total_fornecedores > 1}
              <div>
                <span class="text-gray-600 block text-sm">Fornecedores Disponíveis</span>
                <span class="font-medium">{grupoCanonicos.total_fornecedores}</span>
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
            <span class="font-medium text-lg">{lente.fornecedor_nome}</span>
          </div>
          {#if lente.fornecedor_razao_social}
            <div class="text-sm text-gray-600">
              {lente.fornecedor_razao_social}
            </div>
          {/if}
          <div class="text-sm">
            <span class="text-gray-600">Prazo de Entrega:</span>
            <span class="font-medium">{lente.prazo_dias} dia{lente.prazo_dias > 1 ? 's' : ''}</span>
          </div>
          {#if lente.obs_prazo}
            <div class="text-xs text-gray-500 mt-1">
              {lente.obs_prazo}
            </div>
          {/if}
        </div>
      </div>

      <!-- SKU e Códigos -->
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 class="text-xl font-bold mb-4">Identificação</h2>
        <div class="space-y-2 text-sm">
          <div>
            <span class="text-gray-600 block">SKU Fornecedor</span>
            <code class="bg-gray-100 px-2 py-1 rounded">{lente.sku_fornecedor}</code>
          </div>
          {#if lente.codigo_original}
            <div>
              <span class="text-gray-600 block">Código Original</span>
              <code class="bg-gray-100 px-2 py-1 rounded">{lente.codigo_original}</code>
            </div>
          {/if}
          <div>
            <span class="text-gray-600 block">ID</span>
            <code class="bg-gray-100 px-2 py-1 rounded text-xs">{lente.id}</code>
          </div>
        </div>
      </div>
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
            <h3 class="font-medium mb-2">{alt.nome_lente}</h3>
            <div class="text-sm text-gray-600 mb-2">
              {alt.fornecedor_nome}
            </div>
            <div class="flex justify-between items-center">
              <span class="text-lg font-bold text-green-600">
                {formatarPreco(alt.preco_venda_sugerido)}
              </span>
              <span class="text-sm text-gray-500">
                {alt.prazo_dias}d
              </span>
            </div>
          </a>
        {/each}
      </div>
    </div>
  {/if}
</div>
