<script lang="ts">
  /**
   * Card de Fornecedor - Ranking
   * Mostra informações do laboratório e métricas
   */
  
  import Badge from '$lib/components/ui/Badge.svelte';
  import Button from '$lib/components/ui/Button.svelte';
  import tokens from '$lib/design-tokens';
  
  export let laboratorio = {
    id: '',
    nome: 'Laboratório',
    sku: 'SKU-123',
    preco_final: 0,
    prazo_dias: 0,
    custo_frete: 0,
    margem_pct: 0,
    margem_valor: 0,
    score_qualidade: 0,
    rank_posicao: 1,
    justificativa: ''
  };
  
  export let destaque = false;
  export let onEscolher: (() => void) | undefined = undefined;
  
  // Função para cor do prazo (semáforo)
  function getCorPrazo(dias: number) {
    if (dias < 5) return tokens.colors.ranking.prazo.rapido;
    if (dias <= 10) return tokens.colors.ranking.prazo.medio;
    return tokens.colors.ranking.prazo.longo;
  }
  
  // Função para cor do score
  function getCorScore(score: number) {
    if (score >= 8) return tokens.colors.semantic.success.DEFAULT;
    if (score >= 6) return tokens.colors.semantic.warning.DEFAULT;
    return tokens.colors.semantic.error.DEFAULT;
  }
</script>

<div 
  class="card-fornecedor"
  class:destaque
>
  <!-- Header com badge -->
  <div class="flex items-start justify-between mb-4">
    <div class="flex-1">
      <h3 class="font-headline text-xl font-bold text-brand-blue-700 mb-1">
        {laboratorio.nome}
      </h3>
      <p class="text-sm text-neutral-600">SKU: {laboratorio.sku}</p>
    </div>
    
    {#if destaque}
      <Badge variant="melhor-opcao">
        🏆 Melhor Opção
      </Badge>
    {/if}
  </div>

  <!-- Métricas -->
  <div class="grid grid-cols-2 gap-4 mb-4">
    <!-- Preço -->
    <div>
      <div class="text-sm text-neutral-600 mb-1">Preço Final</div>
      <div class="text-2xl font-bold text-brand-blue-700">
        R$ {laboratorio.preco_final.toFixed(2)}
      </div>
      <div class="text-xs text-neutral-500">
        Margem: {laboratorio.margem_pct}% (R$ {laboratorio.margem_valor.toFixed(2)})
      </div>
    </div>

    <!-- Prazo -->
    <div>
      <div class="text-sm text-neutral-600 mb-1">Prazo de Entrega</div>
      <div class="flex items-center gap-2">
        <span 
          class="text-2xl font-bold" 
          style="color: {getCorPrazo(laboratorio.prazo_dias)}"
        >
          {laboratorio.prazo_dias} dias
        </span>
      </div>
      <div class="text-xs text-neutral-500">
        Frete: R$ {laboratorio.custo_frete.toFixed(2)}
      </div>
    </div>
  </div>

  <!-- Score de Qualidade -->
  <div class="flex items-center gap-2 mb-4 pb-4 border-b border-neutral-200">
    <div class="flex items-center gap-1">
      <span class="text-lg">⭐</span>
      <span 
        class="font-semibold text-lg"
        style="color: {getCorScore(laboratorio.score_qualidade)}"
      >
        {laboratorio.score_qualidade.toFixed(1)}
      </span>
      <span class="text-sm text-neutral-600">/ 10</span>
    </div>
    <span class="text-xs text-neutral-500">Score de Qualidade</span>
  </div>

  <!-- Justificativa -->
  {#if laboratorio.justificativa}
    <div class="bg-neutral-50 rounded-lg p-3 mb-4">
      <div class="text-sm text-neutral-700">
        <strong class="text-brand-blue-700">Por que {destaque ? 'é a melhor opção' : `está na posição ${laboratorio.rank_posicao}`}?</strong><br>
        {laboratorio.justificativa}
      </div>
    </div>
  {/if}

  <!-- Botão de Ação -->
  <Button 
    variant={destaque ? 'success' : 'primary'} 
    fullWidth
    on:click={onEscolher}
  >
    {#if destaque}
      ✓ Escolher {laboratorio.nome}
    {:else}
      Ver Detalhes
    {/if}
  </Button>
</div>

<style>
  .card-fornecedor {
    @apply rounded-xl bg-white p-6 shadow-card transition-shadow duration-200;
    @apply border-2 border-transparent;
  }
  
  .card-fornecedor:hover {
    @apply shadow-card-hover;
  }
  
  .card-fornecedor.destaque {
    @apply border-brand-gold-500 shadow-elevated;
  }
</style>