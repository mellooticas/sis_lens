<script lang="ts">
  /**
   * MobileMenu Component
   * Menu lateral (drawer) para mobile
   */
  
  import { fade, fly } from 'svelte/transition';
  import { browser } from '$app/environment';
  import Logo from './Logo.svelte';
  import ThemeToggle from '$lib/components/ui/ThemeToggle.svelte';
  
  export let open = false;
  export let currentPage = '';
  
  const navItems = [
    { id: 'home',      label: 'Dashboard',           href: '/',                    icon: '🏠' },
    { id: 'conceitos', label: 'Conceitos Canônicos', href: '/catalogo/conceitos',  icon: '🧠' },
    { id: 'standard',  label: 'Lentes Standard',     href: '/catalogo/standard',   icon: '📦' },
    { id: 'premium',   label: 'Lentes Premium',      href: '/catalogo/premium',    icon: '✨' },
    { id: 'contato',   label: 'Lentes de Contato',   href: '/catalogo/contato',    icon: '👁️' },
    { id: 'simulador', label: 'Simulador',            href: '/simulador/receita',   icon: '⚡' },
    { id: 'ranking',   label: 'Ranking',              href: '/ranking',             icon: '🏆' },
  ];
  
  function handleClose() {
    open = false;
  }
  
  function handleNavClick() {
    open = false;
  }
  
  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape' && open) {
      handleClose();
    }
  }
  
  // Prevenir scroll do body quando menu aberto
  $: if (browser) {
    if (open) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
  }
</script>

<svelte:window on:keydown={handleKeydown} />

{#if open}
  <!-- Backdrop -->
  <div
    class="mobile-menu-backdrop"
    transition:fade={{ duration: 200 }}
    on:click={handleClose}
    on:keydown={handleKeydown}
    role="presentation"
  ></div>

  <!-- Drawer -->
  <aside
    class="mobile-menu-drawer"
    transition:fly={{ x: -300, duration: 300 }}
  >
    <!-- Header -->
    <div class="drawer-header">
      <Logo size="md" />
      
      <button
        class="close-btn"
        on:click={handleClose}
        aria-label="Fechar menu"
      >
        <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    
    <!-- Navigation -->
    <nav class="drawer-nav">
      {#each navItems as item}
        <a
          href={item.href}
          class="nav-item"
          class:active={currentPage === item.id}
          on:click={handleNavClick}
        >
          <span class="nav-icon">{item.icon}</span>
          <span class="nav-label">{item.label}</span>
          
          {#if currentPage === item.id}
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          {/if}
        </a>
      {/each}
    </nav>
    
    <!-- Footer -->
    <div class="drawer-footer">
      <!-- Theme Toggle -->
      <div class="footer-item">
        <span class="footer-label">Tema</span>
        <ThemeToggle size="sm" />
      </div>

      <!-- User stub (aguarda SSO Gateway) -->
      <div class="user-btn">
        <div class="user-avatar">
          <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
        </div>
        <div class="user-info">
          <div class="user-name">Usuário</div>
          <div class="user-email">SIS Lens</div>
        </div>
      </div>
    </div>
  </aside>
{/if}

<style>
  .mobile-menu-backdrop {
    @apply fixed inset-0 z-40;
    @apply bg-black/50 backdrop-blur-sm;
  }
  
  .mobile-menu-drawer {
    @apply fixed top-0 left-0 bottom-0 z-50;
    @apply w-80 max-w-[85vw];
    @apply bg-white dark:bg-neutral-900;
    @apply border-r border-neutral-200 dark:border-neutral-800;
    @apply flex flex-col;
    @apply overflow-hidden;
  }
  
  .drawer-header {
    @apply flex items-center justify-between;
    @apply px-6 py-4;
    @apply border-b border-neutral-200 dark:border-neutral-800;
  }
  
  .close-btn {
    @apply p-2 rounded-lg;
    @apply text-neutral-600 dark:text-neutral-400;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-800;
    @apply transition-colors;
  }
  
  .drawer-nav {
    @apply flex-1 overflow-y-auto;
    @apply py-4;
  }
  
  .nav-item {
    @apply flex items-center gap-3;
    @apply px-6 py-3;
    @apply text-neutral-700 dark:text-neutral-300;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-800;
    @apply transition-colors;
  }
  
  .nav-item.active {
    @apply bg-primary-50 dark:bg-primary-900/20;
    @apply text-primary-700 dark:text-primary-300;
    @apply font-medium;
    @apply border-r-4 border-primary-500;
  }
  
  .nav-icon {
    @apply text-xl;
  }
  
  .nav-label {
    @apply flex-1;
  }
  
  .drawer-footer {
    @apply border-t border-neutral-200 dark:border-neutral-800;
    @apply p-4 space-y-3;
  }
  
  .footer-item {
    @apply flex items-center justify-between;
    @apply px-2 py-2;
  }
  
  .footer-label {
    @apply text-sm font-medium;
    @apply text-neutral-700 dark:text-neutral-300;
  }
  
  .user-btn {
    @apply w-full flex items-center gap-3;
    @apply px-2 py-2 rounded-lg;
    @apply hover:bg-neutral-100 dark:hover:bg-neutral-800;
    @apply transition-colors;
    @apply text-left;
  }
  
  .user-avatar {
    @apply w-10 h-10 rounded-full;
    @apply bg-primary-600 text-white;
    @apply flex items-center justify-center;
    @apply shrink-0;
  }
  
  .user-info {
    @apply flex-1;
  }
  
  .user-name {
    @apply text-sm font-medium;
    @apply text-neutral-900 dark:text-neutral-100;
  }
  
  .user-email {
    @apply text-xs;
    @apply text-neutral-500 dark:text-neutral-400;
  }
  
</style>