<script lang="ts">
  /**
   * ThemeToggle - Botão de alternar tema
   */
  
  import { theme } from '$lib/stores/theme';
  import { onMount } from 'svelte';
  
  export let size: 'sm' | 'md' = 'md';
  
  let mounted = false;
  
  onMount(() => {
    theme.init();
    mounted = true;
  });
  
  const sizes = {
    sm: 'w-8 h-8',
    md: 'w-10 h-10'
  };
</script>

{#if mounted}
  <button
    on:click={() => theme.toggle()}
    class="inline-flex items-center justify-center rounded-xl 
      bg-gradient-to-br from-neutral-100 to-neutral-200 dark:from-neutral-800 dark:to-neutral-900
      text-neutral-800 dark:text-neutral-100
      hover:from-brand-blue-100 hover:to-brand-blue-200 
      dark:hover:from-brand-blue-900/40 dark:hover:to-brand-blue-800/40
      border border-neutral-300/50 dark:border-neutral-700/50
      shadow-sm hover:shadow-md
      transition-all duration-300 hover:scale-110
      focus:outline-none focus:ring-2 focus:ring-brand-blue-500 focus:ring-offset-2 
      dark:focus:ring-offset-neutral-900
      {sizes[size]}"
    title={$theme === 'light' ? 'Ativar modo escuro' : 'Ativar modo claro'}
    aria-label="Alternar tema"
  >
    {#if $theme === 'light'}
      <!-- Ícone Lua (Dark Mode) -->
      <svg 
        width="22" 
        height="22" 
        fill="currentColor" 
        viewBox="0 0 24 24"
        class="transition-all duration-300 drop-shadow-sm"
      >
        <path 
          d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" 
        />
      </svg>
    {:else}
      <!-- Ícone Sol (Light Mode) -->
      <svg 
        width="22" 
        height="22" 
        fill="none" 
        stroke="currentColor" 
        viewBox="0 0 24 24"
        class="transition-all duration-300 drop-shadow-sm"
      >
        <path 
          stroke-linecap="round" 
          stroke-linejoin="round" 
          stroke-width="2.5" 
          d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" 
        />
      </svg>
    {/if}
  </button>
{/if}