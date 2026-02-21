<script lang="ts">
  /**
   * ComparisonCard Component
   * Comparação lado a lado de 2 fornecedores
   */
  
  import Button from '$lib/components/ui/Button.svelte';
  import Badge from '$lib/components/ui/Badge.svelte';
  
  export let labA: any;
  export let labB: any;
  export let onSelect: ((lab: any) => void) | undefined = undefined;
  
  function getDifference(valA: number, valB: number, type: 'preco' | 'prazo' | 'score') {
    const diff = valA - valB;
    const absDiff = Math.abs(diff);
    
    if (type === 'preco') {
      const better = diff < 0 ? 'A' : 'B';
      return { diff: absDiff, better, text: `R$ ${absDiff.toFixed(2)}` };
    } else if (type === 'prazo') {
      const better = diff < 0 ? 'A' : 'B';
      return { diff: absDiff, better, text: `${absDiff} dias` };
    } else { // score
      const better = diff > 0 ? 'A' : 'B';
      return { diff: absDiff, better, text: absDiff.toFixed(1) };
    }
  }
  
  $: precoDiff = getDifference(labA.preco_final, labB.preco_final, 'preco');
  $: prazoDiff = getDifference(labA.prazo_dias, labB.prazo_dias, 'prazo');
  $: scoreDiff = getDifference(labA.score_qualidade, labB.score_qualidade, 'score');
</script>

<div class="comparison-card">
  <!-- Header -->
  <div class="comparison-header">
    <h3 class="text-xl font-bold text-neutral-900 dark:text-neutral-100">
      Comparação de Fornecedores
    </h3>
  </div>
  
  <!-- Grid de Comparação -->
  <div class="comparison-grid">
    <!-- Laboratório A -->
    <div class="lab-column" class:winner={precoDiff.better === 'A' && prazoDiff.better === 'A'}>
      <div class="lab-header">
        <h4 class="lab-name">{labA.nome}</h4>
        {#if precoDiff.better === 'A' && prazoDiff.better === 'A'}
          <Badge variant="melhor-opcao">🏆 Melhor Geral</Badge>
        {/if}
      </div>
      
      <div class="lab-metrics">
        <!-- Preço -->
        <div class="metric">
          <div class="metric-label">Preço</div>
          <div class="metric-value" class:better={precoDiff.better === 'A'}>
            R$ {labA.preco_final.toFixed(2)}
            {#if precoDiff.better === 'A'}
              <span class="metric-badge">✓ Menor</span>
            {/if}
          </div>
        </div>
        
        <!-- Prazo -->
        <div class="metric">
          <div class="metric-label">Prazo</div>
          <div class="metric-value" class:better={prazoDiff.better === 'A'}>
            {labA.prazo_dias} dias
            {#if prazoDiff.better === 'A'}
              <span class="metric-badge">✓ Mais rápido</span>
            {/if}
          </div>
        </div>
        
        <!-- Score -->
        <div class="metric">
          <div class="metric-label">Qualidade</div>
          <div class="metric-value" class:better={scoreDiff.better === 'A'}>
            ⭐ {labA.score_qualidade.toFixed(1)}
            {#if scoreDiff.better === 'A'}
              <span class="metric-badge">✓ Melhor</span>
            {/if}
          </div>
        </div>
        
        <!-- Margem -->
        <div class="metric">
          <div class="metric-label">Margem</div>
          <div class="metric-value">
            {labA.margem_pct}% (R$ {labA.margem_valor.toFixed(2)})
          </div>
        </div>
        
        <!-- Frete -->
        <div class="metric">
          <div class="metric-label">Frete</div>
          <div class="metric-value">
            R$ {labA.custo_frete.toFixed(2)}
          </div>
        </div>
      </div>
      
      <Button variant="primary" fullWidth on:click={() => onSelect?.(labA)}>
        Escolher {labA.nome}
      </Button>
    </div>
    
    <!-- Divider com diferenças -->
    <div class="comparison-divider">
      <div class="divider-line"></div>
      <div class="differences">
        <div class="diff-item">
          <div class="diff-label">Diferença de Preço</div>
          <div class="diff-value">
            {precoDiff.text}
            <span class="text-xs">
              ({precoDiff.better === 'A' ? labA.nome : labB.nome} ganha)
            </span>
          </div>
        </div>
        
        <div class="diff-item">
          <div class="diff-label">Diferença de Prazo</div>
          <div class="diff-value">
            {prazoDiff.text}
            <span class="text-xs">
              ({prazoDiff.better === 'A' ? labA.nome : labB.nome} mais rápido)
            </span>
          </div>
        </div>
        
        <div class="diff-item">
          <div class="diff-label">Diferença de Qualidade</div>
          <div class="diff-value">
            {scoreDiff.text}
            <span class="text-xs">
              ({scoreDiff.better === 'A' ? labA.nome : labB.nome} melhor)
            </span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Laboratório B -->
    <div class="lab-column" class:winner={precoDiff.better === 'B' && prazoDiff.better === 'B'}>
      <div class="lab-header">
        <h4 class="lab-name">{labB.nome}</h4>
        {#if precoDiff.better === 'B' && prazoDiff.better === 'B'}
          <Badge variant="melhor-opcao">🏆 Melhor Geral</Badge>
        {/if}
      </div>
      
      <div class="lab-metrics">
        <!-- Preço -->
        <div class="metric">
          <div class="metric-label">Preço</div>
          <div class="metric-value" class:better={precoDiff.better === 'B'}>
            R$ {labB.preco_final.toFixed(2)}
            {#if precoDiff.better === 'B'}
              <span class="metric-badge">✓ Menor</span>
            {/if}
          </div>
        </div>
        
        <!-- Prazo -->
        <div class="metric">
          <div class="metric-label">Prazo</div>
          <div class="metric-value" class:better={prazoDiff.better === 'B'}>
            {labB.prazo_dias} dias
            {#if prazoDiff.better === 'B'}
              <span class="metric-badge">✓ Mais rápido</span>
            {/if}
          </div>
        </div>
        
        <!-- Score -->
        <div class="metric">
          <div class="metric-label">Qualidade</div>
          <div class="metric-value" class:better={scoreDiff.better === 'B'}>
            ⭐ {labB.score_qualidade.toFixed(1)}
            {#if scoreDiff.better === 'B'}
              <span class="metric-badge">✓ Melhor</span>
            {/if}
          </div>
        </div>
        
        <!-- Margem -->
        <div class="metric">
          <div class="metric-label">Margem</div>
          <div class="metric-value">
            {labB.margem_pct}% (R$ {labB.margem_valor.toFixed(2)})
          </div>
        </div>
        
        <!-- Frete -->
        <div class="metric">
          <div class="metric-label">Frete</div>
          <div class="metric-value">
            R$ {labB.custo_frete.toFixed(2)}
          </div>
        </div>
      </div>
      
      <Button variant="primary" fullWidth on:click={() => onSelect?.(labB)}>
        Escolher {labB.nome}
      </Button>
    </div>
  </div>
</div>

<style>
  .comparison-card {
    @apply bg-white dark:bg-neutral-800;
    @apply border border-neutral-200 dark:border-neutral-700;
    @apply rounded-xl p-6;
  }
  
  .comparison-header {
    @apply mb-6 pb-4;
    @apply border-b border-neutral-200 dark:border-neutral-700;
  }
  
  .comparison-grid {
    @apply grid grid-cols-1 lg:grid-cols-[1fr_auto_1fr] gap-6;
  }
  
  .lab-column {
    @apply space-y-4;
    @apply p-4 rounded-lg;
    @apply border-2 border-transparent;
    @apply transition-all duration-200;
  }
  
  .lab-column.winner {
    @apply border-brand-gold-500 bg-brand-gold-50 dark:bg-brand-gold-900/10;
  }
  
  .lab-header {
    @apply space-y-2;
  }
  
  .lab-name {
    @apply text-lg font-bold;
    @apply text-primary-700 dark:text-primary-400;
  }
  
  .lab-metrics {
    @apply space-y-3;
  }
  
  .metric {
    @apply flex items-center justify-between;
    @apply py-2 border-b border-neutral-100 dark:border-neutral-700;
  }
  
  .metric:last-child {
    @apply border-b-0;
  }
  
  .metric-label {
    @apply text-sm text-neutral-600 dark:text-neutral-400;
  }
  
  .metric-value {
    @apply text-sm font-semibold;
    @apply text-neutral-900 dark:text-neutral-100;
    @apply flex items-center gap-2;
  }
  
  .metric-value.better {
    @apply text-success;
  }
  
  .metric-badge {
    @apply text-xs px-2 py-0.5 rounded;
    @apply bg-success/10 text-success;
  }
  
  .comparison-divider {
    @apply relative flex flex-col items-center justify-center;
    @apply px-4;
  }
  
  .divider-line {
    @apply hidden lg:block;
    @apply absolute inset-y-0 left-1/2;
    @apply w-px bg-neutral-200 dark:bg-neutral-700;
  }
  
  .differences {
    @apply space-y-4;
    @apply bg-neutral-50 dark:bg-neutral-900;
    @apply rounded-lg p-4;
  }
  
  .diff-item {
    @apply text-center;
  }
  
  .diff-label {
    @apply text-xs font-medium;
    @apply text-neutral-500 dark:text-neutral-400;
    @apply mb-1;
  }
  
  .diff-value {
    @apply text-sm font-bold;
    @apply text-primary-700 dark:text-primary-400;
  }
  
  .diff-value .text-xs {
    @apply block text-neutral-500 dark:text-neutral-400;
    @apply font-normal mt-1;
  }
</style>