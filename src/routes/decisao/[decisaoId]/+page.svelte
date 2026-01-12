<script lang="ts">
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import { goto } from '$app/navigation';
  import type { PageData } from './$types';

  export let data: PageData;
  
  let confirmando = false;
  let observacoes = '';
  
  async function confirmarDecisao() {
    confirmando = true;
    try {
      // TODO: Implementar chamada para rpc_confirmar_decisao
      console.log('Confirmando decisão:', data.decisao?.id);
      console.log('Observações:', observacoes);
      
      // Simular delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Redirecionar para histórico
      await goto('/historico');
    } catch (error) {
      console.error('Erro ao confirmar decisão:', error);
    } finally {
      confirmando = false;
    }
  }
  
  function cancelar() {
    history.back();
  }
</script>

<svelte:head>
  <title>Confirmar Decisão - SIS Lens</title>
</svelte:head>

<main>
  <Container maxWidth="xl" padding="md">
      <!-- Breadcrumbs custom implementation for now (or replace with component later) -->
      <nav class="text-sm text-neutral-500 mb-6 font-medium">
         <a href="/catalogo" class="hover:text-brand-blue-600 transition-colors">Catálogo</a>
         <span class="mx-2">/</span>
         <a href="/ranking?lente_id={data.decisao?.lente_id}" class="hover:text-brand-blue-600 transition-colors">Ranking</a>
         <span class="mx-2">/</span>
         <span class="text-neutral-900 dark:text-neutral-100 font-semibold">Confirmar Decisão</span>
      </nav>

      <div class="max-w-4xl mx-auto">
        {#if data.decisao}
           <!-- Confirm Header -->
           <div class="mb-8 text-center">
              <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 dark:bg-green-900/30 text-green-600 dark:text-green-400 text-3xl mb-4 shadow-sm">
                ✅
              </div>
              <h1 class="text-3xl font-bold text-neutral-900 dark:text-white mb-2">Confirmar Compra</h1>
              <p class="text-neutral-600 dark:text-neutral-400 text-lg">Revise os detalhes antes de finalizar o pedido</p>
           </div>
           
           <!-- Details Card -->
           <div class="glass-panel rounded-2xl overflow-hidden shadow-xl border border-neutral-200 dark:border-neutral-700">
              
              <!-- Header stripe -->
              <div class="bg-gradient-to-r from-brand-blue-600 to-brand-blue-500 p-1"></div>

              <div class="p-8 space-y-8">
                  
                  <!-- Lente Info -->
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                     <div>
                        <h3 class="text-sm font-bold uppercase tracking-wider text-neutral-500 mb-4">Lente Selecionada</h3>
                        <div class="bg-neutral-50 dark:bg-neutral-800/50 p-5 rounded-xl border border-neutral-200 dark:border-neutral-700">
                           <div class="font-bold text-xl text-neutral-900 dark:text-white mb-2">{data.decisao.lente_nome}</div>
                           <div class="flex flex-wrap gap-2 mb-3">
                              <Badge variant="info" size="sm">{data.decisao.lente_marca}</Badge>
                              <Badge variant="secondary" size="sm">{data.decisao.lente_material}</Badge>
                              <Badge variant="neutral" size="sm">{data.decisao.lente_tipo}</Badge>
                           </div>
                           <div class="text-sm text-neutral-500">Índice: {data.decisao.lente_indice}</div>
                        </div>
                     </div>

                     <!-- Supplier Info -->
                      <div>
                        <h3 class="text-sm font-bold uppercase tracking-wider text-neutral-500 mb-4">Fornecedor</h3>
                         <div class="bg-neutral-50 dark:bg-neutral-800/50 p-5 rounded-xl border border-neutral-200 dark:border-neutral-700 h-full flex flex-col justify-center">
                           <div class="flex justify-between items-start">
                              <div>
                                 <div class="font-bold text-xl text-neutral-900 dark:text-white mb-1">{data.decisao.laboratorio_nome}</div>
                                 <div class="text-neutral-500 text-sm">📍 {data.decisao.laboratorio_regiao || 'Nacional'}</div>
                              </div>
                              <div class="text-right">
                                 <div class="text-xs text-neutral-500 uppercase tracking-wide">Ranking</div>
                                 <div class="text-2xl font-bold text-brand-orange-500">#{data.decisao.posicao_ranking || '?'}</div>
                              </div>
                           </div>
                        </div>
                     </div>
                  </div>

                  <!-- Financials & Logistics -->
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                      <!-- Price -->
                      <div class="bg-neutral-50 dark:bg-neutral-800/50 p-5 rounded-xl border border-neutral-200 dark:border-neutral-700">
                          <h3 class="text-xs font-bold uppercase text-neutral-500 mb-2">Resumo Financeiro</h3>
                          <div class="space-y-1">
                             <div class="flex justify-between text-sm">
                                <span class="text-neutral-600 dark:text-neutral-400">Base</span>
                                <span class="font-medium text-neutral-900 dark:text-neutral-200">R$ {data.decisao.preco_base?.toFixed(2)}</span>
                             </div>
                              {#if data.decisao.desconto_valor}
                                <div class="flex justify-between text-sm text-green-600">
                                    <span>Desconto</span>
                                    <span>- R$ {data.decisao.desconto_valor.toFixed(2)}</span>
                                </div>
                              {/if}
                             <div class="flex justify-between text-sm">
                                <span class="text-neutral-600 dark:text-neutral-400">Frete</span>
                                <span class="font-medium text-neutral-900 dark:text-neutral-200">R$ {data.decisao.frete_valor?.toFixed(2) || '0.00'}</span>
                             </div>
                             <div class="pt-2 mt-2 border-t border-neutral-200 dark:border-neutral-700 flex justify-between items-end">
                                <span class="font-bold text-neutral-900 dark:text-white">Total</span>
                                <span class="text-xl font-black text-brand-blue-600 dark:text-brand-blue-400">R$ {data.decisao.preco_final?.toFixed(2)}</span>
                             </div>
                          </div>
                      </div>

                      <!-- Delivery -->
                       <div class="bg-neutral-50 dark:bg-neutral-800/50 p-5 rounded-xl border border-neutral-200 dark:border-neutral-700">
                          <h3 class="text-xs font-bold uppercase text-neutral-500 mb-2">Entrega</h3>
                          <div class="flex items-center gap-3 h-full pb-6">
                             <div class="p-3 bg-purple-100 dark:bg-purple-900/30 text-purple-600 rounded-lg text-2xl">📅</div>
                             <div>
                                <div class="font-bold text-xl text-neutral-900 dark:text-white">{data.decisao.prazo_dias || '?'} dias</div>
                                <div class="text-xs text-neutral-500">Prazo estimado</div>
                             </div>
                          </div>
                       </div>

                       <!-- Criteria -->
                       <div class="bg-neutral-50 dark:bg-neutral-800/50 p-5 rounded-xl border border-neutral-200 dark:border-neutral-700">
                          <h3 class="text-xs font-bold uppercase text-neutral-500 mb-2">Critério</h3>
                          <div class="flex items-center gap-3 h-full pb-6">
                              {#if data.decisao.criterio === 'URGENCIA'}
                                 <div class="p-3 bg-red-100 dark:bg-red-900/30 text-red-600 rounded-lg text-2xl">🚨</div>
                                 <div class="font-bold text-neutral-900 dark:text-white">Urgência</div>
                              {:else if data.decisao.criterio === 'ESPECIAL'}
                                 <div class="p-3 bg-brand-orange-100 dark:bg-brand-orange-900/30 text-brand-orange-600 rounded-lg text-2xl">⭐</div>
                                 <div class="font-bold text-neutral-900 dark:text-white">Qualidade</div>
                              {:else}
                                 <div class="p-3 bg-brand-blue-100 dark:bg-brand-blue-900/30 text-brand-blue-600 rounded-lg text-2xl">⚖️</div>
                                 <div class="font-bold text-neutral-900 dark:text-white">Custo-Benefício</div>
                              {/if}
                          </div>
                       </div>
                  </div>

                  <!-- Observations -->
                  <div>
                    <label for="observacoes" class="block text-sm font-bold text-neutral-700 dark:text-neutral-300 mb-2">Observações (Opcional)</label>
                    <textarea 
                       id="observacoes" 
                       bind:value={observacoes} 
                       rows="3" 
                       class="input w-full resize-none"
                       placeholder="Adicione qualquer nota relevante para o histórico..."
                    ></textarea>
                  </div>

              </div>

              <!-- Action Footer -->
              <div class="bg-neutral-50 dark:bg-neutral-800 border-t border-neutral-200 dark:border-neutral-700 p-6 flex justify-end gap-4">
                  <Button variant="ghost" size="lg" on:click={cancelar} disabled={confirmando}>
                     Cancelar
                  </Button>
                  <Button variant="success" size="lg" on:click={confirmarDecisao} disabled={confirmando}>
                     {#if confirmando}
                        <span class="mr-2 animate-spin">⏳</span> Confirmando...
                     {:else}
                        ✅ Confirmar Compra
                     {/if}
                  </Button>
              </div>
           </div>
        {:else}
           <div class="glass-panel rounded-2xl p-6 shadow-xl flex flex-col items-center justify-center py-20">
              <div class="text-6xl mb-6">❌</div>
              <h2 class="text-2xl font-bold text-neutral-900 dark:text-white mb-2">Decisão não encontrada</h2>
              <p class="text-neutral-500 mb-8">Não foi possível carregar os detalhes desta decisão.</p>
              <Button variant="primary" on:click={() => goto('/catalogo')}>Voltar ao Catálogo</Button>
           </div>
        {/if}
      </div>
    </Container>
  </main>