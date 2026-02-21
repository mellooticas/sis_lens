<script lang="ts">
  /**
   * Toggle Switch Component
   * Switch on/off customizado
   */
  
  export let checked = false;
  export let label = '';
  export let disabled = false;
  export let size: 'sm' | 'md' | 'lg' = 'md';
  export let id = `toggle-${Math.random().toString(36).substring(7)}`;
  
  const sizes = {
    sm: 'w-8 h-5',
    md: 'w-11 h-6',
    lg: 'w-14 h-7'
  };
  
  const dotSizes = {
    sm: 'w-3 h-3',
    md: 'w-4 h-4',
    lg: 'w-5 h-5'
  };
</script>

<div class="toggle-wrapper">
  <input
    {id}
    type="checkbox"
    bind:checked
    {disabled}
    class="toggle-input"
    on:change
  />
  
  <label for={id} class="toggle-label" class:disabled>
    {#if label}
      <span class="toggle-text">{label}</span>
    {:else if $$slots.default}
      <slot />
    {/if}
    
    <span class="toggle-switch {sizes[size]}" class:checked>
      <span class="toggle-dot {dotSizes[size]}" class:checked></span>
    </span>
  </label>
</div>

<style>
  .toggle-wrapper {
    @apply inline-flex items-center;
  }
  
  .toggle-input {
    @apply sr-only;
  }
  
  .toggle-label {
    @apply flex items-center gap-3 cursor-pointer;
    @apply select-none;
  }
  
  .toggle-label.disabled {
    @apply opacity-50 cursor-not-allowed;
  }
  
  .toggle-text {
    @apply text-sm text-neutral-700 dark:text-neutral-300;
  }
  
  .toggle-switch {
    @apply relative flex items-center;
    @apply rounded-full;
    @apply bg-neutral-300 dark:bg-neutral-600;
    @apply transition-all duration-200;
  }
  
  .toggle-switch.checked {
    @apply bg-primary-500;
  }
  
  .toggle-input:focus + .toggle-label .toggle-switch {
    @apply ring-2 ring-primary-500/20;
  }
  
  .toggle-dot {
    @apply absolute left-1;
    @apply rounded-full bg-white;
    @apply transition-transform duration-200;
    @apply shadow-sm;
  }
  
  .toggle-dot.checked {
    @apply transform translate-x-full;
  }
</style>