<script lang="ts">
  /**
   * Select Component
   * Select field padronizado para o sistema
   */
  
  export let value = '';
  export let label = '';
  export let options: Array<{ value: string; label: string }> = [];
  export let disabled = false;
  export let required = false;
  export let error = '';
  export let name = '';
  export let id = '';
  export let placeholder = '';
  
  // Classes base
  const baseClasses = 'w-full rounded-lg border bg-white dark:bg-neutral-800 px-4 py-2.5 text-sm text-neutral-900 dark:text-neutral-100 transition-all duration-200 focus:outline-none focus:ring-2 disabled:opacity-50 disabled:cursor-not-allowed appearance-none bg-no-repeat bg-right bg-[length:1rem] pr-10';
  
  $: selectClasses = `${baseClasses} ${
    error 
      ? 'border-error focus:border-error focus:ring-error/20' 
      : 'border-neutral-300 dark:border-neutral-600 focus:border-brand-blue-500 focus:ring-brand-blue-500/20'
  }`;
  
  // Gerar ID único se não fornecido
  const uniqueId = id || `select-${Math.random().toString(36).substr(2, 9)}`;
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
  
  <div class="relative">
    <select
      {name}
      {disabled}
      {required}
      id={uniqueId}
      bind:value
      class={selectClasses}
      style="background-image: url('data:image/svg+xml;charset=US-ASCII,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 4 5%22><path fill=%22%23666%22 d=%22M2 0L0 2h4zm0 5L0 3h4z%22/></svg>');"
      on:change
      on:focus
      on:blur
      {...$$restProps}
    >
      {#if placeholder}
        <option value="" disabled={value !== ''}>{placeholder}</option>
      {/if}
      
      {#each options as option}
        <option value={option.value}>
          {option.label}
        </option>
      {/each}
    </select>
    
    <!-- Ícone de seta customizado para dark mode -->
    <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
      <svg class="w-4 h-4 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </div>
  </div>
  
  {#if error}
    <p class="text-xs text-error mt-1">{error}</p>
  {/if}
</div>