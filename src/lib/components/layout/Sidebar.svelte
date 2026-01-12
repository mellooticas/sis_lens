<script lang="ts">
  /**
   * Sidebar Navigation Moderno
   * Menu lateral flutuante com glassmorphism
   */
  import { page } from "$app/stores";
  import Logo from "$lib/components/layout/Logo.svelte";
  import ThemeToggle from "$lib/components/ui/ThemeToggle.svelte";
  import AccessibilityPanel from "$lib/components/ui/AccessibilityPanel.svelte";
  import { fly } from "svelte/transition";

  export let collapsed = false;

  let showAccessibilityPanel = false;

  // Menu items com novos ícones e labels
  type MenuItem = {
    id: string;
    label: string;
    href?: string;
    icon: string;
    color: string;
    submenu?: MenuItem[];
  };
  
  let expandedMenus: Record<string, boolean> = {};
  
  const menuItems: MenuItem[] = [
    {
      id: "home",
      label: "Dashboard",
      href: "/",
      icon: "home",
      color: "text-blue-500",
    },
    {
      id: "catalogo",
      label: "Catálogo",
      href: "/catalogo",
      icon: "search",
      color: "text-indigo-500",
      submenu: [
        {
          id: "catalogo-all",
          label: "Ver Tudo",
          href: "/catalogo",
          icon: "search",
          color: "text-indigo-500",
        },
        {
          id: "standard",
          label: "Standard",
          href: "/catalogo/standard",
          icon: "box",
          color: "text-violet-500",
        },
        {
          id: "catalogo-premium",
          label: "Premium",
          href: "/catalogo/premium",
          icon: "sparkles",
          color: "text-amber-500",
        },
      ]
    },
    {
      id: "ranking",
      label: "Ranking",
      href: "/ranking",
      icon: "trophy",
      color: "text-yellow-500",
    },
    {
      id: "fornecedores",
      label: "Fornecedores",
      href: "/fornecedores",
      icon: "truck",
      color: "text-orange-500",
    },
    {
      id: "simulador",
      label: "Simulador",
      href: "/simulador/receita",
      icon: "zap",
      color: "text-purple-500",
    },
    {
      id: "bi",
      label: "BI/Relatórios",
      href: "/bi",
      icon: "chart",
      color: "text-green-500",
    },
    {
      id: "config",
      label: "Configurações",
      href: "/configuracoes",
      icon: "settings",
      color: "text-gray-500",
    },
  ];
  
  function toggleSubmenu(itemId: string) {
    expandedMenus[itemId] = !expandedMenus[itemId];
  }

  function isActive(path: string) {
    // Para a home, deve ser exatamente "/"
    if (path === "/") return $page.url.pathname === "/";

    // Para outras rotas, verifica se começa com o path
    // Mas garante que não pega sub-rotas não relacionadas
    const currentPath = $page.url.pathname;

    // Se for exatamente o path, é ativo
    if (currentPath === path) return true;

    // Se começa com o path seguido de /, é uma sub-rota
    if (currentPath.startsWith(path + "/")) return true;

    return false;
  }
</script>

<aside
  class="
    fixed left-0 top-0 h-full z-50 flex flex-col transition-all duration-500 ease-out
    {collapsed ? 'w-[7.25rem]' : 'w-[18rem]'}
    p-4
  "
>
  <!-- Glass Container -->
  <div
    class="
      h-full w-full rounded-2xl glass-sidebar border border-white/20 dark:border-white/5 shadow-2xl
      flex flex-col overflow-hidden relative
      bg-gradient-to-b from-white/90 to-white/70 dark:from-neutral-900/90 dark:to-neutral-900/70
    "
  >
    <!-- Logo Section -->
    <div
      class="h-32 flex items-center justify-center border-b border-neutral-200/50 dark:border-neutral-700/50 px-4"
    >
      <div class="flex items-center justify-center w-full">
        <Logo size="2xl" variant={collapsed ? "icon" : "full"} />
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 py-6 px-3 space-y-2 overflow-y-auto custom-scrollbar">
      {#each menuItems as item}
        {#if item.submenu}
          <!-- Item com submenu -->
          <div class="space-y-1">
            <button
              on:click={() => toggleSubmenu(item.id)}
              class="
                w-full relative flex items-center gap-4 px-3 py-3.5 rounded-xl transition-all duration-300 group
                {isActive(item.href || '')
                ? 'bg-brand-blue-50 dark:bg-brand-blue-900/40 shadow-inner'
                : 'hover:bg-neutral-100/80 dark:hover:bg-neutral-800/60 hover:shadow-sm hover:translate-x-1'}
              "
              title={collapsed ? item.label : ""}
            >
              <!-- Active Indicator Line -->
              {#if isActive(item.href || '')}
                <div
                  class="absolute left-0 h-8 w-1 bg-brand-blue-500 rounded-r-full shadow-[0_0_10px_rgba(28,59,90,0.5)]"
                  transition:fly={{ x: -5, duration: 300 }}
                ></div>
              {/if}

              <!-- Icon Gradient Wrapper -->
              <span
                class="
                  shrink-0 flex items-center justify-center w-8 h-8 rounded-lg
                  {isActive(item.href || '')
                  ? 'bg-white dark:bg-neutral-800 shadow-sm scale-110'
                  : 'bg-transparent scale-100'}
                  transition-all duration-300
                "
              >
                {#if item.icon === "search"}
                  <svg
                    class="w-5 h-5 {item.color}"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                    ><path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                    /></svg
                  >
                {/if}
              </span>

              {#if !collapsed}
                <div
                  class="flex flex-1 items-center justify-between overflow-hidden"
                  in:fly={{ x: -10, duration: 300 }}
                >
                  <span
                    class="whitespace-nowrap font-medium text-sm {isActive(
                      item.href || '',
                    )
                      ? 'text-brand-blue-700 dark:text-brand-blue-300'
                      : 'text-neutral-600 dark:text-neutral-300 group-hover:text-neutral-900 dark:group-hover:text-white'}"
                  >
                    {item.label}
                  </span>
                  <svg
                    class="w-4 h-4 transition-transform duration-300 {expandedMenus[item.id] ? 'rotate-90' : ''}"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                  </svg>
                </div>
              {/if}
            </button>
            
            {#if expandedMenus[item.id] && item.submenu}
              <div class="ml-4 space-y-1">
                {#each item.submenu as subitem}
                  <a
                    href={subitem.href}
                    class="
                      relative flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-300 group
                      {isActive(subitem.href || '')
                      ? 'bg-brand-blue-50/50 dark:bg-brand-blue-900/20 shadow-inner'
                      : 'hover:bg-neutral-100/60 dark:hover:bg-neutral-800/40 hover:translate-x-1'}
                    "
                    title={collapsed ? subitem.label : ""}
                  >
                    <span
                      class="
                        shrink-0 flex items-center justify-center w-6 h-6 rounded-lg
                        {isActive(subitem.href || '')
                        ? 'bg-white dark:bg-neutral-800 shadow-sm'
                        : 'bg-transparent'}
                        transition-all duration-300
                      "
                    >
                      {#if subitem.icon === "search"}
                        <svg class="w-4 h-4 {subitem.color}" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                      {:else if subitem.icon === "box"}
                        <svg class="w-4 h-4 {subitem.color}" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z" />
                        </svg>
                      {:else if subitem.icon === "sparkles"}
                        <svg class="w-4 h-4 {subitem.color}" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                        </svg>
                      {/if}
                    </span>
                    
                    {#if !collapsed}
                      <span
                        class="whitespace-nowrap font-medium text-xs {isActive(subitem.href || '')
                          ? 'text-brand-blue-600 dark:text-brand-blue-400'
                          : 'text-neutral-500 dark:text-neutral-400 group-hover:text-neutral-800 dark:group-hover:text-white'}"
                      >
                        {subitem.label}
                      </span>
                    {/if}
                  </a>
                {/each}
              </div>
            {/if}
          </div>
        {:else}
          <!-- Item normal -->
          <a
            href={item.href}
            class="
              relative flex items-center gap-4 px-3 py-3.5 rounded-xl transition-all duration-300 group
              {isActive(item.href || '')
              ? 'bg-brand-blue-50 dark:bg-brand-blue-900/40 shadow-inner'
              : 'hover:bg-neutral-100/80 dark:hover:bg-neutral-800/60 hover:shadow-sm hover:translate-x-1'}
            "
            title={collapsed ? item.label : ""}
          >
            <!-- Active Indicator Line -->
            {#if isActive(item.href || '')}
              <div
                class="absolute left-0 h-8 w-1 bg-brand-blue-500 rounded-r-full shadow-[0_0_10px_rgba(28,59,90,0.5)]"
                transition:fly={{ x: -5, duration: 300 }}
              ></div>
            {/if}

            <!-- Icon Gradient Wrapper -->
            <span
              class="
                shrink-0 flex items-center justify-center w-8 h-8 rounded-lg
                {isActive(item.href || '')
                ? 'bg-white dark:bg-neutral-800 shadow-sm scale-110'
                : 'bg-transparent scale-100'}
                transition-all duration-300
              "
            >
              {#if item.icon === "home"}
                <svg
                  class="w-5 h-5 {item.color}"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                  /></svg
                >
              {:else if item.icon === "trophy"}
                <svg
                  class="w-5 h-5 {item.color}"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 15v5m-3 0h6M12 15c2.21 0 4-1.79 4-4V5c0-1.1-.9-2-2-2H10c-1.1 0-2 .9-2 2v6c0 2.21 1.79 4 4 4zm0 0c-2.67 0-8 1.34-8 4v1c0 .55.45 1 1 1h14c.55 0 1-.45 1-1v-1c0-2.66-5.33-4-8-4z"
                  /></svg
                >
              {:else if item.icon === "truck"}
                <svg
                  class="w-5 h-5 {item.color}"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  ><rect x="1" y="3" width="15" height="13" stroke-width="2" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 8h4l3 3v5h-7V8z" />
                  <circle cx="5.5" cy="18.5" r="2.5" />
                  <circle cx="18.5" cy="18.5" r="2.5" />
                </svg>
              {:else if item.icon === "chart"}
                <svg
                  class="w-5 h-5 {item.color}"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                  /></svg
                >
              {:else if item.icon === "zap"}
                <svg
                  class="w-5 h-5 {item.color}"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 10V3L4 14h7v7l9-11h-7z"
                  /></svg
                >
              {:else if item.icon === "settings"}
                <svg
                  class="w-5 h-5 {item.color}"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
                  /><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  /></svg
                >
              {/if}
            </span>

            {#if !collapsed}
              <div
                class="flex flex-col overflow-hidden"
                in:fly={{ x: -10, duration: 300 }}
              >
                <span
                  class="whitespace-nowrap font-medium text-sm {isActive(
                    item.href || '',
                  )
                    ? 'text-brand-blue-700 dark:text-brand-blue-300'
                    : 'text-neutral-600 dark:text-neutral-300 group-hover:text-neutral-900 dark:group-hover:text-white'}"
                >
                  {item.label}
                </span>
              </div>
            {/if}
          </a>
        {/if}
      {/each}
    </nav>

    <!-- Theme Toggle & Accessibility Section -->
    <div
      class="px-3 py-3 border-t border-neutral-200/50 dark:border-neutral-700/50"
    >
      <div class="flex items-center justify-center gap-2">
        <ThemeToggle size="md" />
        <button
          on:click={() => (showAccessibilityPanel = true)}
          class="
            inline-flex items-center justify-center rounded-xl
            bg-gradient-to-br from-purple-100 to-purple-200 dark:from-purple-900/40 dark:to-purple-800/40
            text-purple-800 dark:text-purple-100
            hover:from-purple-200 hover:to-purple-300
            dark:hover:from-purple-800/50 dark:hover:to-purple-700/50
            border border-purple-300/50 dark:border-purple-700/50
            shadow-sm hover:shadow-md
            transition-all duration-300 hover:scale-110
            focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2
            dark:focus:ring-offset-neutral-900
            w-10 h-10
          "
          title="Configurações de Acessibilidade"
          aria-label="Abrir painel de acessibilidade"
        >
          <svg
            width="22"
            height="22"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"
            />
          </svg>
        </button>
      </div>
    </div>

    <!-- User Profile (Bottom) -->
    <div
      class="border-t border-neutral-200/50 dark:border-neutral-700/50 p-4 bg-white/30 dark:bg-black/20 backdrop-blur-sm"
    >
      <button
        class="flex items-center gap-3 w-full hover:bg-white/50 dark:hover:bg-white/10 p-2 rounded-xl transition-all duration-300 group"
      >
        <div class="relative">
          <div
            class="w-10 h-10 rounded-full bg-gradient-to-tr from-brand-blue-500 to-brand-blue-400 flex items-center justify-center text-white font-bold text-sm shadow-lg ring-2 ring-white dark:ring-neutral-800"
          >
            JS
          </div>
          <div
            class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white dark:border-neutral-800 rounded-full"
          ></div>
        </div>

        {#if !collapsed}
          <div
            class="text-left overflow-hidden"
            in:fly={{ y: 10, duration: 300 }}
          >
            <div
              class="text-sm font-semibold text-neutral-900 dark:text-white truncate"
            >
              Junior Silva
            </div>
            <div
              class="text-xs text-neutral-500 dark:text-neutral-400 truncate"
            >
              Admin Master
            </div>
          </div>
        {/if}
      </button>
    </div>
  </div>
</aside>

<!-- Accessibility Panel -->
<AccessibilityPanel bind:isOpen={showAccessibilityPanel} />

<style>
  /* Glass Effect for Sidebar */
  :global(.glass-sidebar) {
    background: rgba(255, 255, 255, 0.15) !important;
    backdrop-filter: blur(12px) !important;
    -webkit-backdrop-filter: blur(12px) !important;
    box-shadow:
      0 8px 32px rgba(0, 0, 0, 0.1),
      inset 0 1px 0 rgba(255, 255, 255, 0.3) !important;
    border-right: 1px solid rgba(255, 255, 255, 0.25) !important;
  }

  :global(.dark .glass-sidebar) {
    background: rgba(0, 0, 0, 0.3) !important;
    border-right: 1px solid rgba(255, 255, 255, 0.15) !important;
    box-shadow:
      0 8px 32px rgba(255, 255, 255, 0.08),
      0 4px 16px rgba(255, 255, 255, 0.05),
      inset 0 1px 0 rgba(255, 255, 255, 0.1) !important;
  }
</style>
