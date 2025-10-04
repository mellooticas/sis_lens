<script lang="ts">
  /**
   * Skeleton Loader Component
   * Placeholder de loading
   */
  
  export let variant: 'text' | 'title' | 'card' | 'circle' | 'button' = 'text';
  export let width: string | undefined = undefined;
  export let height: string | undefined = undefined;
  export let count = 1;
</script>

{#if variant === 'text'}
  {#each Array(count) as _, i}
    <div 
      class="skeleton skeleton-text" 
      style={width ? `width: ${width}` : ''}
    ></div>
  {/each}
{:else if variant === 'title'}
  <div 
    class="skeleton skeleton-title"
    style={width ? `width: ${width}` : ''}
  ></div>
{:else if variant === 'card'}
  <div 
    class="skeleton skeleton-card"
    style={`${width ? `width: ${width};` : ''} ${height ? `height: ${height};` : ''}`}
  ></div>
{:else if variant === 'circle'}
  <div 
    class="skeleton skeleton-circle"
    style={width ? `width: ${width}; height: ${width}` : ''}
  ></div>
{:else if variant === 'button'}
  <div class="skeleton skeleton-button"></div>
{/if}

<style>
  .skeleton {
    @apply animate-pulse;
    @apply bg-neutral-200 dark:bg-neutral-700;
    @apply rounded;
  }
  
  .skeleton-text {
    @apply h-4 w-full mb-2;
  }
  
  .skeleton-title {
    @apply h-8 w-3/4 mb-4;
  }
  
  .skeleton-card {
    @apply w-full h-48;
  }
  
  .skeleton-circle {
    @apply w-12 h-12;
    @apply rounded-full;
  }
  
  .skeleton-button {
    @apply h-10 w-24;
    @apply rounded-lg;
  }
</style>