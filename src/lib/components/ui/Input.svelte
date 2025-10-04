<script lang="ts">
  /**
   * Input Component
   * Input field padronizado para o sistema
   */
  
  export let value = '';
  export let label = '';
  export let placeholder = '';
  export let type: 'text' | 'email' | 'password' | 'number' | 'search' = 'text';
  export let disabled = false;
  export let required = false;
  export let error = '';
  export let name = '';
  export let id = '';
  export let min: string | undefined = undefined;
  export let max: string | undefined = undefined;
  export let step: string | undefined = undefined;
  
  // Classes base
  const baseClasses = 'w-full rounded-lg border bg-white dark:bg-neutral-800 px-4 py-2.5 text-sm text-neutral-900 dark:text-neutral-100 transition-all duration-200 focus:outline-none focus:ring-2 disabled:opacity-50 disabled:cursor-not-allowed';
  
  $: inputClasses = `${baseClasses} ${
    error 
      ? 'border-error focus:border-error focus:ring-error/20' 
      : 'border-neutral-300 dark:border-neutral-600 focus:border-brand-blue-500 focus:ring-brand-blue-500/20'
  }`;
  
  // Gerar ID único se não fornecido
  const uniqueId = id || `input-${Math.random().toString(36).substr(2, 9)}`;
</script>

<div class="space-y-1">
  {#if label}
    <label 
      for={uniqueId}
      class="block text-sm font-medium text-neutral-700 dark:text-neutral-300"
    >
      {label}
      {#if required}
        <span class="text-error ml-1">*</span>
      {/if}
    </label>
  {/if}
  
  <input
    {name}
    {type}
    {placeholder}
    {disabled}
    {required}
    {min}
    {max}
    {step}
    id={uniqueId}
    bind:value
    class={inputClasses}
    on:input
    on:change
    on:focus
    on:blur
    on:keydown
    on:keyup
    on:keypress
    {...$$restProps}
  />
  
  {#if error}
    <p class="text-xs text-error mt-1">{error}</p>
  {/if}
</div>