<script lang="ts">
  /**
   * Textarea Component
   * Textarea com contador de caracteres opcional
   */
  
  export let value = '';
  export let placeholder = '';
  export let disabled = false;
  export let error = '';
  export let rows = 4;
  export let maxLength: number | undefined = undefined;
  export let showCounter = false;
  export let resize: 'none' | 'vertical' | 'horizontal' | 'both' = 'vertical';
  
  $: remainingChars = maxLength ? maxLength - value.length : 0;
  $: isNearLimit = maxLength && remainingChars < maxLength * 0.1;
</script>

<div class="textarea-wrapper">
  <textarea
    bind:value
    {placeholder}
    {disabled}
    {rows}
    maxlength={maxLength}
    class="textarea"
    class:error
    class:resize-none={resize === 'none'}
    class:resize-y={resize === 'vertical'}
    class:resize-x={resize === 'horizontal'}
    class:resize={resize === 'both'}
    on:input
    on:change
    on:focus
    on:blur
    {...$$restProps}
  ></textarea>
  
  <div class="textarea-footer">
    {#if error}
      <p class="textarea-error">{error}</p>
    {/if}
    
    {#if showCounter && maxLength}
      <p class="textarea-counter" class:near-limit={isNearLimit}>
        {value.length} / {maxLength}
      </p>
    {/if}
  </div>
</div>

<style>
  .textarea-wrapper {
    @apply w-full;
  }
  
  .textarea {
    @apply w-full rounded-lg;
    @apply px-4 py-2;
    @apply bg-white dark:bg-neutral-800;
    @apply border border-neutral-300 dark:border-neutral-700;
    @apply text-sm text-neutral-900 dark:text-neutral-100;
    @apply placeholder:text-neutral-400 dark:placeholder:text-neutral-500;
    @apply transition-all duration-200;
    @apply focus:border-brand-blue-500 focus:ring-2 focus:ring-brand-blue-500/20;
    @apply disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .textarea.error {
    @apply border-error;
  }
  
  .textarea-footer {
    @apply flex items-center justify-between mt-1;
    @apply text-xs;
  }
  
  .textarea-error {
    @apply text-error;
  }
  
  .textarea-counter {
    @apply text-neutral-500 dark:text-neutral-400;
    @apply ml-auto;
  }
  
  .textarea-counter.near-limit {
    @apply text-warning font-medium;
  }
</style>