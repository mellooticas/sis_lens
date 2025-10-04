<script lang="ts">
  /**
   * Breadcrumbs Component
   * Navegação em migalhas de pão
   */
  
  export let items: Array<{ label: string; href?: string }> = [];
</script>

<nav aria-label="Breadcrumb" class="breadcrumbs">
  <ol class="breadcrumb-list">
    {#each items as item, i}
      <li class="breadcrumb-item">
        {#if item.href && i < items.length - 1}
          <a href={item.href} class="breadcrumb-link">
            {item.label}
          </a>
        {:else}
          <span class="breadcrumb-current">
            {item.label}
          </span>
        {/if}
        
        {#if i < items.length - 1}
          <svg 
            class="breadcrumb-separator" 
            width="16" 
            height="16" 
            fill="none" 
            stroke="currentColor" 
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        {/if}
      </li>
    {/each}
  </ol>
</nav>

<style>
  .breadcrumbs {
    @apply mb-6;
  }
  
  .breadcrumb-list {
    @apply flex items-center flex-wrap gap-2;
  }
  
  .breadcrumb-item {
    @apply flex items-center gap-2;
  }
  
  .breadcrumb-link {
    @apply text-sm font-medium;
    @apply text-neutral-600 dark:text-neutral-400;
    @apply hover:text-brand-blue-600 dark:hover:text-brand-blue-400;
    @apply transition-colors;
  }
  
  .breadcrumb-current {
    @apply text-sm font-medium;
    @apply text-neutral-900 dark:text-neutral-100;
  }
  
  .breadcrumb-separator {
    @apply text-neutral-400 dark:text-neutral-600;
  }
</style>