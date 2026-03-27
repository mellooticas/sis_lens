<script lang="ts">
  /**
   * LensGrid — Grid view para lentes canônicas
   */
  import { Grid3x3, Loader2 } from 'lucide-svelte'
  import LenteCanonicoCard from './LenteCanonicoCard.svelte'
  import type { CanonicalPremiumV3, CanonicalStandardV3 } from '$lib/types/lentes'

  export let lentes: (CanonicalPremiumV3 | CanonicalStandardV3)[] = []
  export let loading: boolean = false
  export let erro: string | null = null
  export let isPremium: boolean = false
  export let itemCount: number = 0

  const COLS = 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4'
</script>

{#if erro}
  <div class="rounded-xl border border-red-200 dark:border-red-900/50 bg-red-50 dark:bg-red-900/20 p-4">
    <p class="text-sm text-red-700 dark:text-red-300">{erro}</p>
  </div>
{:else if loading}
  <div class="min-h-96 flex items-center justify-center">
    <div class="flex flex-col items-center gap-3">
      <Loader2 class="h-8 w-8 text-muted-foreground animate-spin" />
      <p class="text-sm text-muted-foreground">Carregando lentes...</p>
    </div>
  </div>
{:else if lentes.length === 0}
  <div class="rounded-xl border border-border bg-card p-12 text-center">
    <Grid3x3 class="h-12 w-12 text-muted-foreground mx-auto mb-3 opacity-50" />
    <p class="text-sm text-muted-foreground">Nenhuma lente encontrada</p>
  </div>
{:else}
  <div>
    <div class="mb-3 flex items-center justify-between">
      <p class="text-xs text-muted-foreground">
        Exibindo <span class="font-semibold text-foreground">{lentes.length}</span> de
        <span class="font-semibold text-foreground">{itemCount.toLocaleString('pt-BR')}</span> lentes
      </p>
    </div>
    <div class={`grid ${COLS} gap-4`}>
      {#each lentes as lente (lente.id)}
        <LenteCanonicoCard
          {lente}
          {isPremium}
          href={isPremium ? `/premium/${lente.id}` : `/standard/${lente.id}`}
        />
      {/each}
    </div>
  </div>
{/if}
