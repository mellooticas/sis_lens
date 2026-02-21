<script lang="ts">
  /**
   * Radio Button Component
   * Radio button customizado
   */
  
  export let value: string;
  export let group: string;
  export let label = '';
  export let disabled = false;
  export let id = `radio-${Math.random().toString(36).substring(7)}`;
  
  $: checked = group === value;
</script>

<div class="radio-wrapper">
  <input
    {id}
    type="radio"
    {value}
    bind:group
    {disabled}
    class="radio-input"
    on:change
  />
  
  <label for={id} class="radio-label" class:disabled>
    <span class="radio-circle">
      {#if checked}
        <span class="radio-dot"></span>
      {/if}
    </span>
    
    {#if label}
      <span class="radio-text">{label}</span>
    {:else}
      <slot />
    {/if}
  </label>
</div>

<style>
  .radio-wrapper {
    @apply inline-flex items-center;
  }
  
  .radio-input {
    @apply sr-only;
  }
  
  .radio-label {
    @apply flex items-center gap-2 cursor-pointer;
    @apply select-none;
  }
  
  .radio-label.disabled {
    @apply opacity-50 cursor-not-allowed;
  }
  
  .radio-circle {
    @apply w-5 h-5 rounded-full;
    @apply border-2 border-neutral-300 dark:border-neutral-600;
    @apply bg-white dark:bg-neutral-800;
    @apply flex items-center justify-center;
    @apply transition-all duration-200;
  }
  
  .radio-input:checked + .radio-label .radio-circle {
    @apply border-primary-500;
  }
  
  .radio-input:focus + .radio-label .radio-circle {
    @apply ring-2 ring-primary-500/20;
  }
  
  .radio-input:disabled + .radio-label .radio-circle {
    @apply bg-neutral-100 dark:bg-neutral-700;
  }
  
  .radio-dot {
    @apply w-2.5 h-2.5 rounded-full;
    @apply bg-primary-500;
  }
  
  .radio-text {
    @apply text-sm text-neutral-700 dark:text-neutral-300;
  }
</style>