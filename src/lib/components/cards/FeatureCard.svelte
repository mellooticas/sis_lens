<script lang="ts">
  /**
   * FeatureCard - Card genérico de feature com ícone e destaque
   * Versão mais completa do BenefitCard para landing pages
   */
  
  import Badge from '$lib/components/ui/Badge.svelte';
  
  export let icon = '✨';
  export let badge = '';
  export let title = '';
  export let description = '';
  export let highlighted = false;
</script>

<div 
  class="bg-white dark:bg-neutral-800 rounded-xl border p-6 transition-all duration-200"
  class:border-brand-gold-500={highlighted}
  class:shadow-elevated={highlighted}
  class:border-neutral-200={!highlighted}
  class:dark:border-neutral-700={!highlighted}
  class:hover:shadow-card-hover={!highlighted}
>
  <!-- Icon + Badge -->
  <div class="flex items-start justify-between mb-4">
    <div class="text-4xl">
      {icon}
    </div>
    {#if badge}
      <Badge variant="info" size="sm">
        {badge}
      </Badge>
    {/if}
  </div>
  
  <!-- Title -->
  <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
    {title}
  </h3>
  
  <!-- Description -->
  <p class="text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">
    {description}
  </p>
  
  <!-- Slot para conteúdo adicional -->
  <slot />
</div>