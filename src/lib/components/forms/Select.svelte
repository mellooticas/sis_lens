<script lang="ts">
  /**
   * Select/Dropdown Component
   * Dropdown customizado com busca opcional
   */
  
  import { createEventDispatcher } from 'svelte';
  import { clickOutside } from '$lib/utils/click-outside';
  
  export let value = '';
  export let placeholder = 'Selecione...';
  export let options: Array<{ value: string; label: string }> = [];
  export let disabled = false;
  export let searchable = false;
  export let error = '';
  
  let isOpen = false;
  let searchQuery = '';
  let highlightedIndex = 0;
  
  const dispatch = createEventDispatcher();
  
  $: selectedOption = options.find(opt => opt.value === value);
  $: filteredOptions = searchable && searchQuery
    ? options.filter(opt => 
        opt.label.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : options;
  
  function toggleDropdown() {
    if (!disabled) {
      isOpen = !isOpen;
      if (isOpen && searchable) {
        searchQuery = '';
      }
    }
  }
  
  function selectOption(option: typeof options[0]) {
    value = option.value;
    isOpen = false;
    searchQuery = '';
    dispatch('change', option);
  }
  
  function handleKeydown(e: KeyboardEvent) {
    if (!isOpen) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        toggleDropdown();
      }
      return;
    }
    
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        highlightedIndex = Math.min(highlightedIndex + 1, filteredOptions.length - 1);
        break;
      case 'ArrowUp':
        e.preventDefault();
        highlightedIndex = Math.max(highlightedIndex - 1, 0);
        break;
      case 'Enter':
        e.preventDefault();
        if (filteredOptions[highlightedIndex]) {
          selectOption(filteredOptions[highlightedIndex]);
        }
        break;
      case 'Escape':
        isOpen = false;
        break;
    }
  }
</script>

<div class="select-wrapper" use:clickOutside={() => isOpen = false}>
  <!-- Trigger Button -->
  <button
    type="button"
    class="select-trigger"
    class:open={isOpen}
    class:error={error}
    class:disabled
    {disabled}
    on:click={toggleDropdown}
    on:keydown={handleKeydown}
    aria-haspopup="listbox"
    aria-expanded={isOpen}
  >
    <span class="select-value">
      {selectedOption?.label || placeholder}
    </span>
    
    <svg 
      class="select-icon" 
      class:rotate={isOpen}
      width="20" 
      height="20" 
      fill="none" 
      stroke="currentColor" 
      viewBox="0 0 24 24"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
  </button>
  
  <!-- Dropdown -->
  {#if isOpen}
    <div class="select-dropdown" role="listbox">
      {#if searchable}
        <div class="select-search">
          <input
            type="text"
            placeholder="Buscar..."
            bind:value={searchQuery}
            class="search-input"
            on:click|stopPropagation
          />
        </div>
      {/if}
      
      <div class="select-options">
        {#if filteredOptions.length === 0}
          <div class="select-empty">
            Nenhum resultado encontrado
          </div>
        {:else}
          {#each filteredOptions as option, i}
            <button
              type="button"
              class="select-option"
              class:selected={option.value === value}
              class:highlighted={i === highlightedIndex}
              on:click={() => selectOption(option)}
              role="option"
              aria-selected={option.value === value}
            >
              {option.label}
              {#if option.value === value}
                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              {/if}
            </button>
          {/each}
        {/if}
      </div>
    </div>
  {/if}
  
  {#if error}
    <p class="select-error">{error}</p>
  {/if}
</div>

<style>
  .select-wrapper {
    @apply relative w-full;
  }
  
  .select-trigger {
    @apply w-full flex items-center justify-between;
    @apply px-4 py-2 rounded-lg;
    @apply bg-white dark:bg-neutral-800;
    @apply border border-neutral-300 dark:border-neutral-700;
    @apply text-sm text-left;
    @apply transition-all duration-200;
    @apply hover:border-brand-blue-400 dark:hover:border-brand-blue-600;
    @apply focus:outline-none focus:ring-2 focus:ring-brand-blue-500/20 focus:border-brand-blue-500;
  }
  
  .select-trigger.open {
    @apply border-brand-blue-500;
    @apply ring-2 ring-brand-blue-500/20;
  }
  
  .select-trigger.error {
    @apply border-error;
  }
  
  .select-trigger.disabled {
    @apply opacity-50 cursor-not-allowed;
  }
  
  .select-value {
    @apply flex-1 text-neutral-900 dark:text-neutral-100;
  }
  
  .select-trigger:not(.disabled) .select-value:empty::before {
    content: attr(placeholder);
    @apply text-neutral-400;
  }
  
  .select-icon {
    @apply text-neutral-400 transition-transform duration-200;
  }
  
  .select-icon.rotate {
    @apply rotate-180;
  }
  
  .select-dropdown {
    @apply absolute z-50 w-full mt-2;
    @apply bg-white dark:bg-neutral-800;
    @apply border border-neutral-200 dark:border-neutral-700;
    @apply rounded-lg shadow-lg;
    @apply overflow-hidden;
  }
  
  .select-search {
    @apply p-2 border-b border-neutral-200 dark:border-neutral-700;
  }
  
  .search-input {
    @apply w-full px-3 py-2 rounded-lg;
    @apply bg-neutral-50 dark:bg-neutral-900;
    @apply border border-neutral-200 dark:border-neutral-700;
    @apply text-sm;
    @apply focus:outline-none focus:ring-2 focus:ring-brand-blue-500/20;
  }
  
  .select-options {
    @apply max-h-60 overflow-y-auto;
  }
  
  .select-option {
    @apply w-full flex items-center justify-between;
    @apply px-4 py-2 text-sm text-left;
    @apply text-neutral-700 dark:text-neutral-300;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-700;
    @apply transition-colors;
  }
  
  .select-option.selected {
    @apply bg-brand-blue-50 dark:bg-brand-blue-900/20;
    @apply text-brand-blue-700 dark:text-brand-blue-400;
    @apply font-medium;
  }
  
  .select-option.highlighted {
    @apply bg-neutral-100 dark:bg-neutral-700;
  }
  
  .select-empty {
    @apply px-4 py-8 text-center text-sm;
    @apply text-neutral-500 dark:text-neutral-400;
  }
  
  .select-error {
    @apply mt-1 text-xs text-error;
  }
</style>