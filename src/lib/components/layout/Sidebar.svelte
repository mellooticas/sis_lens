<script lang="ts">
  /**
   * Sidebar — SIS Lens
   * Design System SIS_DIGIAI: Base Neutra + Sotaque Violet (primary)
   * SEM glassmorphism · SEM gradientes · SEM scale effects
   */
  import { page } from '$app/stores';
  import Logo from '$lib/components/layout/Logo.svelte';
  import ThemeToggle from '$lib/components/ui/ThemeToggle.svelte';

  export let collapsed = false;

  type MenuItem = {
    id: string;
    label: string;
    href?: string;
    icon: string;
    submenu?: MenuItem[];
  };

  let expandedMenus: Record<string, boolean> = {};

  const menuItems: MenuItem[] = [
    { id: 'home',        label: 'Dashboard',        href: '/',                    icon: 'home'        },
    { id: 'catalogo',    label: 'Catálogo',          href: '/catalogo',            icon: 'search',
      submenu: [
        { id: 'catalogo-all',     label: 'Ver Tudo',  href: '/catalogo',          icon: 'search'   },
        { id: 'standard',         label: 'Standard',  href: '/catalogo/standard', icon: 'box'      },
        { id: 'catalogo-premium', label: 'Premium',   href: '/catalogo/premium',  icon: 'sparkles' },
      ]
    },
    { id: 'simulador',      label: 'Simulador',        href: '/simulador/receita', icon: 'zap'         },
    { id: 'ranking',        label: 'Ranking',          href: '/ranking',           icon: 'trophy'      },
    { id: 'comparar',       label: 'Comparar Labs',    href: '/comparar',          icon: 'scale'       },
    { id: 'tabela-precos',  label: 'Tabela de Preços', href: '/tabela-precos',     icon: 'price-table' },
  ];

  function toggleSubmenu(itemId: string) {
    expandedMenus[itemId] = !expandedMenus[itemId];
  }

  function isActive(path: string) {
    if (!path) return false;
    if (path === '/') return $page.url.pathname === '/';
    return $page.url.pathname === path || $page.url.pathname.startsWith(path + '/');
  }

  // Classes reutilizáveis
  const activeItem   = 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300';
  const inactiveItem = 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-100 dark:hover:bg-neutral-800 hover:text-neutral-900 dark:hover:text-neutral-100';
  const activeIcon   = 'text-primary-600 dark:text-primary-400';
  const inactiveIcon = 'text-neutral-500 dark:text-neutral-500 group-hover:text-neutral-700 dark:group-hover:text-neutral-300';
</script>

<aside
  class="
    fixed left-0 top-0 h-full z-50 flex flex-col
    transition-all duration-300 ease-in-out
    {collapsed ? 'w-[4.5rem]' : 'w-[16rem]'}
    border-r border-neutral-200 dark:border-neutral-700
    bg-white dark:bg-neutral-900
  "
>

  <!-- Logo -->
  <div class="h-16 flex items-center justify-center border-b border-neutral-200 dark:border-neutral-700 px-3 shrink-0">
    <Logo size="lg" variant={collapsed ? 'icon' : 'full'} />
  </div>

  <!-- Navigation -->
  <nav class="flex-1 overflow-y-auto custom-scrollbar py-3 px-2 space-y-0.5">
    {#each menuItems as item}
      {#if item.submenu}
        <!-- Item com submenu -->
        <div>
          <button
            on:click={() => toggleSubmenu(item.id)}
            title={collapsed ? item.label : ''}
            class="
              w-full flex items-center gap-3 px-3 py-2.5 rounded-lg
              transition-colors duration-150 group text-sm font-medium
              {isActive(item.href || '') ? activeItem : inactiveItem}
            "
          >
            <!-- Active bar -->
            {#if isActive(item.href || '')}
              <span class="absolute left-0 w-0.5 h-6 bg-primary-600 rounded-r" aria-hidden="true"></span>
            {/if}

            <!-- Icon -->
            <span class="shrink-0 w-5 h-5 {isActive(item.href || '') ? activeIcon : inactiveIcon}">
              {#if item.icon === 'search'}
                <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
              {/if}
            </span>

            {#if !collapsed}
              <span class="flex-1 text-left truncate">{item.label}</span>
              <svg class="w-4 h-4 shrink-0 transition-transform duration-200 {expandedMenus[item.id] ? 'rotate-90' : ''}"
                fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
              </svg>
            {/if}
          </button>

          <!-- Submenu -->
          {#if expandedMenus[item.id] && !collapsed}
            <div class="ml-4 mt-0.5 space-y-0.5">
              {#each item.submenu as sub}
                <a
                  href={sub.href}
                  title={collapsed ? sub.label : ''}
                  class="
                    flex items-center gap-3 px-3 py-2 rounded-lg
                    transition-colors duration-150 group text-xs font-medium
                    {isActive(sub.href || '') ? activeItem : inactiveItem}
                  "
                >
                  <span class="shrink-0 w-4 h-4 {isActive(sub.href || '') ? activeIcon : inactiveIcon}">
                    {#if sub.icon === 'search'}
                      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-4 h-4">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                      </svg>
                    {:else if sub.icon === 'box'}
                      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-4 h-4">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/>
                      </svg>
                    {:else if sub.icon === 'sparkles'}
                      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-4 h-4">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
                      </svg>
                    {/if}
                  </span>
                  <span class="truncate">{sub.label}</span>
                </a>
              {/each}
            </div>
          {/if}
        </div>

      {:else}
        <!-- Item normal -->
        <a
          href={item.href}
          title={collapsed ? item.label : ''}
          class="
            relative flex items-center gap-3 px-3 py-2.5 rounded-lg
            transition-colors duration-150 group text-sm font-medium
            {isActive(item.href || '') ? activeItem : inactiveItem}
          "
        >
          <!-- Active bar -->
          {#if isActive(item.href || '')}
            <span class="absolute left-0 w-0.5 h-6 bg-primary-600 rounded-r" aria-hidden="true"></span>
          {/if}

          <!-- Icon -->
          <span class="shrink-0 {isActive(item.href || '') ? activeIcon : inactiveIcon}">
            {#if item.icon === 'home'}
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
              </svg>
            {:else if item.icon === 'zap'}
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M13 10V3L4 14h7v7l9-11h-7z"/>
              </svg>
            {:else if item.icon === 'trophy'}
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/>
              </svg>
            {:else if item.icon === 'scale'}
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"/>
              </svg>
            {:else if item.icon === 'price-table'}
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
              </svg>
            {/if}
          </span>

          {#if !collapsed}
            <span class="truncate">{item.label}</span>
          {/if}
        </a>
      {/if}
    {/each}
  </nav>

  <!-- Footer: tema + usuário -->
  <div class="border-t border-neutral-200 dark:border-neutral-700 p-2 shrink-0 space-y-1">

    <!-- Theme Toggle -->
    <div class="flex items-center justify-center py-1">
      <ThemeToggle size="sm" />
    </div>

    <!-- User stub (aguarda integração com SSO do SIS Gateway) -->
    <div class="flex items-center gap-2.5 px-2 py-2 rounded-lg hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors duration-150 cursor-pointer">
      <div class="shrink-0 w-8 h-8 rounded-full bg-primary-600 flex items-center justify-center text-white text-xs font-semibold">
        <!-- TODO: iniciais do usuário real via $page.data.session (SSO Gateway) -->
        U
      </div>
      {#if !collapsed}
        <div class="overflow-hidden">
          <p class="text-xs font-medium text-neutral-800 dark:text-neutral-200 truncate leading-none mb-0.5">
            <!-- TODO: nome real via SSO Gateway -->
            Usuário
          </p>
          <p class="text-[11px] text-neutral-500 dark:text-neutral-500 truncate leading-none">
            SIS Lens
          </p>
        </div>
      {/if}
    </div>

  </div>
</aside>
