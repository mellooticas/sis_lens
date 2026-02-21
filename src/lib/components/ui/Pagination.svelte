<script lang="ts">
  /**
   * Pagination Component
   * Paginação de dados
   */
  
  import { createEventDispatcher } from 'svelte';
  
  export let currentPage = 1;
  export let totalPages = 1;
  export let totalItems = 0;
  export let itemsPerPage = 10;
  export let showFirstLast = true;
  export let maxButtons = 5;
  
  const dispatch = createEventDispatcher();
  
  $: startItem = (currentPage - 1) * itemsPerPage + 1;
  $: endItem = Math.min(currentPage * itemsPerPage, totalItems);
  
  $: pageNumbers = getPageNumbers(currentPage, totalPages, maxButtons);
  
  function getPageNumbers(current: number, total: number, max: number) {
    if (total <= max) {
      return Array.from({ length: total }, (_, i) => i + 1);
    }
    
    const half = Math.floor(max / 2);
    let start = current - half;
    let end = current + half;
    
    if (start < 1) {
      start = 1;
      end = max;
    }
    
    if (end > total) {
      end = total;
      start = total - max + 1;
    }
    
    return Array.from({ length: end - start + 1 }, (_, i) => start + i);
  }
  
  function goToPage(page: number) {
    if (page >= 1 && page <= totalPages && page !== currentPage) {
      dispatch('change', page);
    }
  }
</script>

<div class="pagination">
  <!-- Info -->
  <div class="pagination-info">
    <span class="text-sm text-neutral-600 dark:text-neutral-400">
      Mostrando <strong>{startItem}</strong> a <strong>{endItem}</strong> de <strong>{totalItems}</strong> resultados
    </span>
  </div>
  
  <!-- Buttons -->
  <div class="pagination-buttons">
    <!-- First -->
    {#if showFirstLast && currentPage > 1}
      <button
        class="pagination-btn"
        on:click={() => goToPage(1)}
        aria-label="Primeira página"
      >
        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
        </svg>
      </button>
    {/if}
    
    <!-- Previous -->
    <button
      class="pagination-btn"
      disabled={currentPage === 1}
      on:click={() => goToPage(currentPage - 1)}
      aria-label="Página anterior"
    >
      <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
      </svg>
    </button>
    
    <!-- Page Numbers -->
    {#each pageNumbers as page}
      <button
        class="pagination-btn"
        class:active={page === currentPage}
        on:click={() => goToPage(page)}
      >
        {page}
      </button>
    {/each}
    
    <!-- Next -->
    <button
      class="pagination-btn"
      disabled={currentPage === totalPages}
      on:click={() => goToPage(currentPage + 1)}
      aria-label="Próxima página"
    >
      <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
      </svg>
    </button>
    
    <!-- Last -->
    {#if showFirstLast && currentPage < totalPages}
      <button
        class="pagination-btn"
        on:click={() => goToPage(totalPages)}
        aria-label="Última página"
      >
        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
        </svg>
      </button>
    {/if}
  </div>
</div>

<style>
  .pagination {
    @apply flex items-center justify-between;
    @apply flex-wrap gap-4;
  }
  
  .pagination-info {
    @apply text-sm;
  }
  
  .pagination-buttons {
    @apply flex items-center gap-1;
  }
  
  .pagination-btn {
    @apply min-w-[2rem] h-8 px-2;
    @apply flex items-center justify-center;
    @apply rounded-lg;
    @apply text-sm font-medium;
    @apply text-neutral-700 dark:text-neutral-300;
    @apply border border-neutral-300 dark:border-neutral-600;
    @apply bg-white dark:bg-neutral-800;
    @apply hover:bg-neutral-50 dark:hover:bg-neutral-700;
    @apply transition-colors;
    @apply disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .pagination-btn.active {
    @apply bg-primary-500 border-primary-500;
    @apply text-white;
    @apply hover:bg-primary-600;
  }
</style>