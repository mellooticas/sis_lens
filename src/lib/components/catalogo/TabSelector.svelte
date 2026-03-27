<script lang="ts">
  /**
   * TabSelector — Premium | Standard tabs component
   * Inspirado em clearix_vendas mas em Svelte
   */
  import { Crown, Sparkles } from 'lucide-svelte'
  
  export let activeTab: 'premium' | 'standard' = 'premium'
  export let premiumCount: number = 0
  export let standardCount: number = 0

  function handleTabChange(tab: 'premium' | 'standard') {
    activeTab = tab
  }
</script>

<div class="flex gap-2 border-b border-border">
  <button
    on:click={() => handleTabChange('premium')}
    class={`flex items-center gap-2 px-4 py-3 font-semibold text-sm transition-all ${
      activeTab === 'premium'
        ? 'border-b-2 border-amber-500 text-amber-600 dark:text-amber-400'
        : 'text-muted-foreground hover:text-foreground'
    }`}
  >
    <Crown class="h-4 w-4" />
    <span>Premium</span>
    {#if premiumCount > 0}
      <span class="ml-1 px-2 py-0.5 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 text-xs font-bold rounded-full">
        {premiumCount.toLocaleString('pt-BR')}
      </span>
    {/if}
  </button>

  <button
    on:click={() => handleTabChange('standard')}
    class={`flex items-center gap-2 px-4 py-3 font-semibold text-sm transition-all ${
      activeTab === 'standard'
        ? 'border-b-2 border-cyan-500 text-cyan-600 dark:text-cyan-400'
        : 'text-muted-foreground hover:text-foreground'
    }`}
  >
    <Sparkles class="h-4 w-4" />
    <span>Standard</span>
    {#if standardCount > 0}
      <span class="ml-1 px-2 py-0.5 bg-cyan-100 dark:bg-cyan-900/30 text-cyan-700 dark:text-cyan-300 text-xs font-bold rounded-full">
        {standardCount.toLocaleString('pt-BR')}
      </span>
    {/if}
  </button>
</div>
