<script lang="ts">
  /**
   * SearchBar Component
   * Busca com autocomplete e histórico
   */
  
  import { createEventDispatcher } from 'svelte';
  import { clickOutside } from '$lib/utils/click-outside';
  
  export let value = '';
  export let placeholder = 'Buscar lente...';
  export let suggestions: Array<{ id: string; label: string; description?: string }> = [];
  export let recentSearches: string[] = [];
  export let loading = false;
  export let disabled = false;
  
  let isOpen = false;
  let highlightedIndex = 0;
  
  const dispatch = createEventDispatcher();
  
  $: if (value.length > 0) {
    isOpen = true;
  }
  
  $: filteredSuggestions = suggestions.filter(s => 
    s.label.toLowerCase().includes(value.toLowerCase())
  );
  
  function handleInput(e: Event) {
    const target = e.target as HTMLInputElement;
    value = target.value;
    highlightedIndex = 0;
    dispatch('input', value);
  }
  
  function handleSelect(item: typeof suggestions[0]) {
    value = item.label;
    isOpen = false;
    dispatch('select', item);
  }
  
  function handleRecentSearch(search: string) {
    value = search;
    isOpen = false;
    dispatch('select', { label: search });
  }
  
  function handleKeydown(e: KeyboardEvent) {
    if (!isOpen) return;
    
    const items = value.length > 0 ? filteredSuggestions : [];
    
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        highlightedIndex = Math.min(highlightedIndex + 1, items.length - 1);
        break;
      case 'ArrowUp':
        e.preventDefault();
        highlightedIndex = Math.max(highlightedIndex - 1, 0);
        break;
      case 'Enter':
        e.preventDefault();
        if (items[highlightedIndex]) {
          handleSelect(items[highlightedIndex]);
        } else if (value) {
          dispatch('submit', value);
          isOpen = false;
        }
        break;
      case 'Escape':
        isOpen = false;
        break;
    }
  }
  
  function clearSearch() {
    value = '';
    isOpen = false;
    dispatch('clear');
  }
</script>

<div class="searchbar-wrapper" use:clickOutside={() => isOpen = false}>
  <!-- Input -->
  <div class="searchbar-input">
    <div class="search-icon">
      <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
      </svg>
    </div>
    
    <input
      type="text"
      {value}
      {placeholder}
      {disabled}
      class="search-field"
      on:input={handleInput}
      on:keydown={handleKeydown}
      on:focus={() => isOpen = true}
    />
    
    {#if loading}
      <div class="search-loader">
        <div class="spinner-sm"></div>
      </div>
    {:else if value}
      <button class="search-clear" on:click={clearSearch}>
        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    {/if}
  </div>
  
  <!-- Dropdown -->
  {#if isOpen}
    <div class="searchbar-dropdown">
      {#if value.length > 0}
        <!-- Sugestões -->
        {#if filteredSuggestions.length > 0}
          <div class="dropdown-section">
            <div class="section-title">Sugestões</div>
            {#each filteredSuggestions as item, i}
              <button
                class="dropdown-item"
                class:highlighted={i === highlightedIndex}
                on:click={() => handleSelect(item)}
              >
                <div class="item-icon">🔍</div>
                <div class="item-content">
                  <div class="item-label">{item.label}</div>
                  {#if item.description}
                    <div class="item-description">{item.description}</div>
                  {/if}
                </div>
              </button>
            {/each}
          </div>
        {:else}
          <div class="dropdown-empty">
            Nenhuma lente encontrada para "{value}"
          </div>
        {/if}
      {:else if recentSearches.length > 0}
        <!-- Buscas Recentes -->
        <div class="dropdown-section">
          <div class="section-title">Buscas Recentes</div>
          {#each recentSearches as search}
            <button
              class="dropdown-item"
              on:click={() => handleRecentSearch(search)}
            >
              <div class="item-icon">🕐</div>
              <div class="item-content">
                <div class="item-label">{search}</div>
              </div>
            </button>
          {/each}
        </div>
      {:else}
        <div class="dropdown-empty">
          Digite para buscar lentes
        </div>
      {/if}
    </div>
  {/if}
</div>

<style>
  .searchbar-wrapper {
    @apply relative w-full;
  }
  
  .searchbar-input {
    @apply relative flex items-center;
    @apply w-full rounded-lg;
    @apply bg-white dark:bg-neutral-800;
    @apply border border-neutral-300 dark:border-neutral-700;
    @apply transition-all duration-200;
    @apply focus-within:border-brand-blue-500 focus-within:ring-2 focus-within:ring-brand-blue-500/20;
  }
  
  .search-icon {
    @apply absolute left-3;
    @apply text-neutral-400 dark:text-neutral-500;
  }
  
  .search-field {
    @apply w-full pl-10 pr-10 py-3;
    @apply bg-transparent;
    @apply text-sm text-neutral-900 dark:text-neutral-100;
    @apply placeholder:text-neutral-400 dark:placeholder:text-neutral-500;
    @apply focus:outline-none;
  }
  
  .search-loader {
    @apply absolute right-3;
  }
  
  .spinner-sm {
    @apply w-4 h-4;
    @apply border-2 border-neutral-300 dark:border-neutral-600;
    @apply border-t-brand-blue-500;
    @apply rounded-full;
    @apply animate-spin;
  }
  
  .search-clear {
    @apply absolute right-3;
    @apply p-1 rounded;
    @apply text-neutral-400 hover:text-neutral-600;
    @apply dark:text-neutral-500 dark:hover:text-neutral-300;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-700;
    @apply transition-colors;
  }
  
  .searchbar-dropdown {
    @apply absolute z-50 w-full mt-2;
    @apply bg-white dark:bg-neutral-800;
    @apply border border-neutral-200 dark:border-neutral-700;
    @apply rounded-lg shadow-lg;
    @apply max-h-96 overflow-y-auto;
  }
  
  .dropdown-section {
    @apply py-2;
  }
  
  .section-title {
    @apply px-4 py-2 text-xs font-semibold;
    @apply text-neutral-500 dark:text-neutral-400;
    @apply uppercase tracking-wider;
  }
  
  .dropdown-item {
    @apply w-full flex items-start gap-3;
    @apply px-4 py-2;
    @apply text-left;
    @apply hover:bg-neutral-50 dark:hover:bg-neutral-700;
    @apply transition-colors;
  }
  
  .dropdown-item.highlighted {
    @apply bg-neutral-100 dark:bg-neutral-700;
  }
  
  .item-icon {
    @apply flex-shrink-0 text-lg;
  }
  
  .item-content {
    @apply flex-1;
  }
  
  .item-label {
    @apply text-sm font-medium;
    @apply text-neutral-900 dark:text-neutral-100;
  }
  
  .item-description {
    @apply text-xs text-neutral-500 dark:text-neutral-400;
  }
  
  .dropdown-empty {
    @apply px-4 py-8 text-center;
    @apply text-sm text-neutral-500 dark:text-neutral-400;
  }
</style>