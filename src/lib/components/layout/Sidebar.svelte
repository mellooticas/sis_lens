<script lang="ts">
  /**
   * Sidebar Navigation Moderno
   * Menu lateral flutuante com glassmorphism
   */
  import { page } from "$app/stores";
  import Logo from "$lib/components/layout/Logo.svelte";
  import { fly } from "svelte/transition";

  export let collapsed = false;

  // Menu items com novos ícones e labels
  const menuItems = [
    {
      id: "home",
      label: "Dashboard",
      href: "/",
      icon: "home",
      color: "text-blue-500",
    },
    {
      id: "buscar",
      label: "Buscar Lentes",
      href: "/buscar",
      icon: "search",
      color: "text-indigo-500",
    },
    {
      id: "ranking",
      label: "Ranking",
      href: "/ranking",
      icon: "trophy",
      color: "text-yellow-500",
    },
    {
      id: "comercial",
      label: "Comercial",
      href: "/comercial",
      icon: "dollar-sign",
      color: "text-emerald-500",
    },
    {
      id: "vouchers",
      label: "Vouchers",
      href: "/vouchers",
      icon: "ticket",
      color: "text-pink-500",
    },
    {
      id: "fornecedores",
      label: "Fornecedores",
      href: "/fornecedores",
      icon: "truck",
      color: "text-orange-500",
    },
    {
      id: "historico",
      label: "Histórico",
      href: "/historico",
      icon: "clock",
      color: "text-purple-500",
    },
    {
      id: "analytics",
      label: "Analytics",
      href: "/analytics",
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
      class="h-20 flex items-center justify-center border-b border-neutral-200/50 dark:border-neutral-700/50"
    >
      <div
        class="transform transition-transform duration-300 {collapsed
          ? 'scale-75'
          : 'scale-90'}"
      >
        <Logo size="sm" variant={collapsed ? "icon" : "full"} />
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 py-6 px-3 space-y-2 overflow-y-auto custom-scrollbar">
      {#each menuItems as item}
        <a
          href={item.href}
          class="
            relative flex items-center gap-4 px-3 py-3.5 rounded-xl transition-all duration-300 group
            {isActive(item.href)
            ? 'bg-brand-blue-50 dark:bg-brand-blue-900/40 shadow-inner' // Active State
            : 'hover:bg-neutral-100/80 dark:hover:bg-neutral-800/60 hover:shadow-sm hover:translate-x-1'} // Hover State
          "
          title={collapsed ? item.label : ""}
        >
          <!-- Active Indicator Line -->
          {#if isActive(item.href)}
            <div
              class="absolute left-0 h-8 w-1 bg-brand-blue-500 rounded-r-full shadow-[0_0_10px_rgba(28,59,90,0.5)]"
              transition:fly={{ x: -5, duration: 300 }}
            ></div>
          {/if}

          <!-- Icon Gradient Wrapper -->
          <span
            class="
              shrink-0 flex items-center justify-center w-8 h-8 rounded-lg
              {isActive(item.href)
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
            {:else if item.icon === "search"}
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
                /><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M5.25 7.5A2.25 2.25 0 017.5 5.25M18.75 7.5A2.25 2.25 0 0116.5 5.25"
                /></svg
              >
            {:else if item.icon === "clock"}
              <svg
                class="w-5 h-5 {item.color}"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                ><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                /></svg
              >
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
            {:else if item.icon === "dollar-sign"}
              <svg
                class="w-5 h-5 {item.color}"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                ><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"
                /></svg
              >
            {:else if item.icon === "ticket"}
              <svg
                class="w-5 h-5 {item.color}"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                ><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M21 12H3m7 8l-4-4 4-4m5 8l4-4-4-4"
                /><!-- Wait, this is not a ticket icon. Using a generic tag icon path instead -->
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"
                />
                <line x1="7" y1="7" x2="7.01" y2="7" stroke-width="2"></line>
              </svg>
            {:else if item.icon === "truck"}
              <svg
                class="w-5 h-5 {item.color}"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                ><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M1 3h15v13H1z"
                /><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M16 8h4l3 3v5h-7V8z"
                /><circle cx="5.5" cy="18.5" r="2.5" />
                <circle cx="18.5" cy="18.5" r="2.5" />
              </svg>
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
            {/if}
          </span>

          {#if !collapsed}
            <div
              class="flex flex-col overflow-hidden"
              in:fly={{ x: -10, duration: 300 }}
            >
              <span
                class="whitespace-nowrap font-medium text-sm {isActive(
                  item.href,
                )
                  ? 'text-brand-blue-700 dark:text-brand-blue-300'
                  : 'text-neutral-600 dark:text-neutral-300 group-hover:text-neutral-900 dark:group-hover:text-white'}"
              >
                {item.label}
              </span>
            </div>
          {/if}
        </a>
      {/each}
    </nav>

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
