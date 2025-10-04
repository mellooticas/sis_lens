<script lang="ts">
  /**
   * Header/Navbar BestLens
   * Navegação principal do app
   */
  
  import Logo from './Logo.svelte';
  import ThemeToggle from '$lib/components/ui/ThemeToggle.svelte';
  import MobileMenu from './MobileMenu.svelte';
  
  export let currentPage = 'buscar';
  
  let mobileMenuOpen = false;
  
  const navItems = [
    { id: 'dashboard', label: 'Dashboard', href: '/dashboard', icon: '🏠' },
    { id: 'buscar', label: 'Buscar', href: '/buscar', icon: '🔍' },
    { id: 'ranking', label: 'Ranking', href: '/ranking', icon: '📊' },
    { id: 'catalogo', label: 'Catálogo', href: '/catalogo', icon: '📋' },
    { id: 'analytics', label: 'Analytics', href: '/analytics', icon: '📈' },
    { id: 'tabela-precos', label: 'Preços', href: '/tabela-precos', icon: '💰' }
  ];
  
  // Helper para classes dinâmicas
  function getNavClasses(itemId: string) {
    const isActive = currentPage === itemId;
    const base = 'flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors';
    
    if (isActive) {
      return `${base} text-brand-blue-600 dark:text-brand-blue-400 bg-brand-blue-50 dark:bg-neutral-800`;
    }
    
    return `${base} text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800`;
  }
</script>

<header class="bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800 sticky top-0 z-50 transition-colors">
  <div class="container mx-auto px-4">
    <nav class="flex items-center justify-between h-16">
      <!-- Logo -->
      <a href="/" class="flex items-center">
        <Logo size="md" theme="auto" />
      </a>

      <!-- Desktop Navigation -->
      <div class="hidden md:flex items-center gap-6">
        {#each navItems as item}
          <a
            href={item.href}
            class={getNavClasses(item.id)}
          >
            <span>{item.icon}</span>
            <span>{item.label}</span>
          </a>
        {/each}
      </div>

      <!-- User Menu + Theme Toggle -->
      <div class="hidden md:flex items-center gap-3">
        <ThemeToggle size="md" />
        
        <button class="px-4 py-2 text-sm font-medium text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors">
          👤 Minha Conta
        </button>
      </div>

      <!-- Mobile Menu Button -->
      <div class="flex md:hidden items-center gap-2"> 
        <ThemeToggle size="sm" />
        
        <button 
          class="p-2 text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg"
          on:click={() => mobileMenuOpen = true}
          aria-label="Abrir menu"
        >
          <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>
    </nav>
  </div>
</header>

<!-- Mobile Menu -->
<MobileMenu bind:open={mobileMenuOpen} {currentPage} />