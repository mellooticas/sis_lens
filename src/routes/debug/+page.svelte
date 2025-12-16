<script lang="ts">
  /**
   * Página de Debug - Interface
   * Mostra todos os dados carregados do banco
   */
  
  export let data;
  
  const { debug } = data;
  
  // Helper para mostrar JSON formatado
  function formatJson(obj: any) {
    return JSON.stringify(obj, null, 2);
  }
  
  // Helper para status visual
  function getStatusIcon(success: boolean) {
    return success ? '✅' : '❌';
  }
  
  function getStatusClass(success: boolean) {
    return success ? 'text-green-600' : 'text-red-600';
  }
</script>

<svelte:head>
  <title>Debug - Dados do Banco | SIS Lens</title>
</svelte:head>

<div class="container mx-auto px-4 py-6">
  <!-- Header -->
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-2">🧪 Debug - Dados do Banco</h1>
    <p class="text-gray-600">Verificação completa da conexão com todas as views e dados</p>
  </div>
  
  {#if debug.error}
    <!-- Erro Geral -->
    <div class="bg-red-50 border border-red-200 rounded-lg p-6 mb-6">
      <h2 class="text-xl font-semibold text-red-800 mb-2">❌ Erro Geral</h2>
      <pre class="bg-red-100 p-4 rounded text-sm text-red-700 overflow-x-auto">{debug.error}</pre>
    </div>
  {:else}
    <!-- Resumo de Status -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
      <div class="bg-white border rounded-lg p-4">
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium text-gray-600">Catálogo</span>
          <span class="{getStatusClass(debug.catalogo.success)}">{getStatusIcon(debug.catalogo.success)}</span>
        </div>
        <div class="mt-2">
          <span class="text-2xl font-bold text-gray-900">{debug.catalogo.count}</span>
          <span class="text-sm text-gray-500 ml-1">lentes</span>
        </div>
      </div>
      
      <div class="bg-white border rounded-lg p-4">
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium text-gray-600">Fornecedores</span>
          <span class="{getStatusClass(debug.fornecedores.success)}">{getStatusIcon(debug.fornecedores.success)}</span>
        </div>
        <div class="mt-2">
          <span class="text-2xl font-bold text-gray-900">{debug.fornecedores.count}</span>
          <span class="text-sm text-gray-500 ml-1">laboratórios</span>
        </div>
      </div>
      
      <div class="bg-white border rounded-lg p-4">
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium text-gray-600">Busca</span>
          <span class="{getStatusClass(debug.busca.success)}">{getStatusIcon(debug.busca.success)}</span>
        </div>
        <div class="mt-2">
          <span class="text-2xl font-bold text-gray-900">{debug.busca.count}</span>
          <span class="text-sm text-gray-500 ml-1">resultados</span>
        </div>
      </div>
      
      <div class="bg-white border rounded-lg p-4">
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium text-gray-600">Decisões</span>
          <span class="{getStatusClass(debug.decisoes.success)}">{getStatusIcon(debug.decisoes.success)}</span>
        </div>
        <div class="mt-2">
          <span class="text-2xl font-bold text-gray-900">{debug.decisoes.count}</span>
          <span class="text-sm text-gray-500 ml-1">histórico</span>
        </div>
      </div>
      
      <div class="bg-white border rounded-lg p-4">
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium text-gray-600">Analytics</span>
          <span class="{getStatusClass(debug.analytics.success)}">{getStatusIcon(debug.analytics.success)}</span>
        </div>
        <div class="mt-2">
          <span class="text-2xl font-bold text-gray-900">{debug.analytics.count}</span>
          <span class="text-sm text-gray-500 ml-1">métricas</span>
        </div>
      </div>
    </div>
    
    <!-- Detalhes de Cada Seção -->
    <div class="space-y-6">
      
      <!-- 1. Catálogo de Lentes -->
      <div class="bg-white border rounded-lg">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900 flex items-center">
            {getStatusIcon(debug.catalogo.success)} Catálogo de Lentes
            <span class="ml-2 text-sm text-gray-500">({debug.catalogo.count} itens)</span>
          </h2>
        </div>
        <div class="p-6">
          {#if debug.catalogo.error}
            <div class="bg-red-50 border border-red-200 rounded p-4">
              <p class="text-red-700 font-medium">Erro:</p>
              <pre class="text-red-600 text-sm mt-1">{debug.catalogo.error}</pre>
            </div>
          {:else if debug.catalogo.data.length > 0}
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">SKU</th>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Marca</th>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Família</th>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Design</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  {#each debug.catalogo.data.slice(0, 5) as lente}
                    <tr>
                      <td class="px-4 py-2 text-sm text-gray-900 font-mono">{lente.lente_id?.substring(0, 8)}...</td>
                      <td class="px-4 py-2 text-sm text-gray-900">{lente.sku_canonico || '-'}</td>
                      <td class="px-4 py-2 text-sm text-gray-900">{lente.marca_nome || '-'}</td>
                      <td class="px-4 py-2 text-sm text-gray-900">{lente.familia || '-'}</td>
                      <td class="px-4 py-2 text-sm text-gray-900">{lente.design || '-'}</td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          {:else}
            <p class="text-gray-500">Nenhuma lente encontrada</p>
          {/if}
        </div>
      </div>
      
      <!-- 2. Fornecedores -->
      <div class="bg-white border rounded-lg">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900 flex items-center">
            {getStatusIcon(debug.fornecedores.success)} Fornecedores/Laboratórios
            <span class="ml-2 text-sm text-gray-500">({debug.fornecedores.count} itens)</span>
          </h2>
        </div>
        <div class="p-6">
          {#if debug.fornecedores.error}
            <div class="bg-red-50 border border-red-200 rounded p-4">
              <p class="text-red-700 font-medium">Erro:</p>
              <pre class="text-red-600 text-sm mt-1">{debug.fornecedores.error}</pre>
            </div>
          {:else if debug.fornecedores.data.length > 0}
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Nome</th>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">CNPJ</th>
                    <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Score</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  {#each debug.fornecedores.data.slice(0, 5) as fornecedor}
                    <tr>
                      <td class="px-4 py-2 text-sm text-gray-900 font-mono">{fornecedor.id?.substring(0, 8)}...</td>
                      <td class="px-4 py-2 text-sm text-gray-900">{fornecedor.nome || '-'}</td>
                      <td class="px-4 py-2 text-sm text-gray-900">{fornecedor.cnpj || '-'}</td>
                      <td class="px-4 py-2 text-sm text-gray-900">{fornecedor.credibilidade_score || '-'}</td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          {:else}
            <p class="text-gray-500">Nenhum fornecedor encontrado</p>
          {/if}
        </div>
      </div>
      
      <!-- 3. Teste de Busca -->
      <div class="bg-white border rounded-lg">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900 flex items-center">
            {getStatusIcon(debug.busca.success)} Busca (query: "progressive")
            <span class="ml-2 text-sm text-gray-500">({debug.busca.count} itens)</span>
          </h2>
        </div>
        <div class="p-6">
          {#if debug.busca.error}
            <div class="bg-red-50 border border-red-200 rounded p-4">
              <p class="text-red-700 font-medium">Erro:</p>
              <pre class="text-red-600 text-sm mt-1">{debug.busca.error}</pre>
            </div>
          {:else if debug.busca.data.length > 0}
            <div class="space-y-2">
              {#each debug.busca.data as resultado}
                <div class="border rounded p-3">
                  <p class="font-medium">{resultado.label}</p>
                  <p class="text-sm text-gray-600">SKU: {resultado.sku_fantasia}</p>
                </div>
              {/each}
            </div>
          {:else}
            <p class="text-gray-500">Nenhum resultado para "progressive"</p>
          {/if}
        </div>
      </div>
      
    </div>
  {/if}
  
  <!-- Botão para recarregar -->
  <div class="mt-8 text-center">
    <button 
      on:click={() => window.location.reload()} 
      class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
    >
      🔄 Recarregar Teste
    </button>
  </div>
</div>