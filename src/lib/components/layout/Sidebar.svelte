<script lang="ts">
  /**
   * Sidebar — SIS Lens
   * Design System SIS_DIGIAI: Base Neutra + Sotaque Violet (primary)
   * SEM glassmorphism · SEM gradientes · SEM scale effects
   */
  import { page } from "$app/stores";
  import Logo from "$lib/components/layout/Logo.svelte";
  import ThemeToggle from "$lib/components/ui/ThemeToggle.svelte";

  export let collapsed = false;

  type MenuItem = {
    id: string;
    label: string;
    href?: string;
    icon: string;
  };

  type NavSection = {
    label?: string;
    items: MenuItem[];
  };

  const sections: NavSection[] = [
    {
      items: [{ id: "home", label: "Dashboard", href: "/", icon: "home" }],
    },
    {
      label: "Catálogos",
      items: [
        {
          id: "catalogo-all",
          label: "Catálogo Geral",
          href: "/catalogo",
          icon: "search",
        },
        {
          id: "standard",
          label: "Lentes Standard",
          href: "/catalogo/standard",
          icon: "box",
        },
        {
          id: "premium",
          label: "Lentes Premium",
          href: "/catalogo/premium",
          icon: "sparkles",
        },
        {
          id: "contato",
          label: "Lentes de Contato",
          href: "/catalogo/contato",
          icon: "eye",
        },
      ],
    },
    {
      label: "Operação",
      items: [
        {
          id: "simulador",
          label: "Simulador de Receita",
          href: "/simulador/receita",
          icon: "zap",
        },
        {
          id: "tabela-precos",
          label: "Tabela de Preços",
          href: "/tabela-precos",
          icon: "price-table",
        },
      ],
    },
    {
      label: "Estratégia & BI",
      items: [
        {
          id: "ranking",
          label: "Ranking de Lentes",
          href: "/ranking",
          icon: "trophy",
        },
        {
          id: "comparar",
          label: "Comparar Labs",
          href: "/comparar",
          icon: "scale",
        },
      ],
    },
    {
      label: "Gestão do Sistema",
      items: [
        {
          id: "saude",
          label: "Saúde do Sistema",
          href: "/saude",
          icon: "shield",
        },
      ],
    },
  ];

  function isActive(path: string) {
    if (!path) return false;
    if (path === "/") return $page.url.pathname === "/";
    return (
      $page.url.pathname === path || $page.url.pathname.startsWith(path + "/")
    );
  }

  // Classes reutilizáveis
  const activeItem =
    "bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300";
  const inactiveItem =
    "text-neutral-600 dark:text-neutral-400 hover:bg-neutral-100 dark:hover:bg-neutral-800 hover:text-neutral-900 dark:hover:text-neutral-100";
  const activeIcon = "text-primary-600 dark:text-primary-400";
  const inactiveIcon =
    "text-neutral-500 dark:text-neutral-500 group-hover:text-neutral-700 dark:group-hover:text-neutral-300";
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
  <div
    class="h-16 flex items-center justify-center border-b border-neutral-200 dark:border-neutral-700 px-3 shrink-0"
  >
    <Logo size="lg" variant={collapsed ? "icon" : "full"} />
  </div>

  <nav class="flex-1 overflow-y-auto custom-scrollbar pt-3 pb-6 px-2 space-y-6">
    {#each sections as section}
      <div class="space-y-1">
        {#if section.label && !collapsed}
          <h4
            class="px-3 text-[10px] font-bold uppercase tracking-wider text-neutral-400 dark:text-neutral-500 mb-2"
          >
            {section.label}
          </h4>
        {/if}

        {#each section.items as item}
          <a
            href={item.href}
            title={collapsed ? item.label : ""}
            class="
              relative flex items-center gap-3 px-3 py-2.5 rounded-lg
              transition-colors duration-150 group text-sm font-medium
              {isActive(item.href || '') ? activeItem : inactiveItem}
            "
          >
            <!-- Active bar -->
            {#if isActive(item.href || "")}
              <span
                class="absolute left-0 w-0.5 h-6 bg-primary-600 rounded-r"
                aria-hidden="true"
              ></span>
            {/if}

            <!-- Icon -->
            <span
              class="shrink-0 w-5 h-5 {isActive(item.href || '')
                ? activeIcon
                : inactiveIcon}"
            >
              {#if item.icon === "home"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                  />
                </svg>
              {:else if item.icon === "search"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                  />
                </svg>
              {:else if item.icon === "brain"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1m-1.636 6.364l-.707-.707M12 21v-1m-6.364-1.636l.707-.707M3 12h1m1.636-6.364l.707.707M12 9a3 3 0 100 6 3 3 0 000-6z"
                  />
                </svg>
              {:else if item.icon === "box"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                  />
                </svg>
              {:else if item.icon === "sparkles"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M5 3l3.057 2.197L12 3l1.943 5.197 5.057.803-4 3.197 1.943 5.197L12 15l-4.943 2.197L9 12l-4-3.197 5.057-.803L5 3z"
                  />
                </svg>
              {:else if item.icon === "eye"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                  />
                </svg>
              {:else if item.icon === "zap"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M13 10V3L4 14h7v7l9-11h-7z"
                  />
                </svg>
              {:else if item.icon === "trophy"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"
                  />
                </svg>
              {:else if item.icon === "scale"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"
                  />
                </svg>
              {:else if item.icon === "price-table"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"
                  />
                </svg>
              {:else if item.icon === "shield"}
                <svg
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  class="w-5 h-5"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.75"
                    d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                  />
                </svg>
              {/if}
            </span>

            {#if !collapsed}
              <span class="truncate">{item.label}</span>
            {/if}
          </a>
        {/each}
      </div>
    {/each}
  </nav>

  <!-- Footer: tema + usuário -->
  <div
    class="border-t border-neutral-200 dark:border-neutral-700 p-2 shrink-0 space-y-1"
  >
    <!-- Theme Toggle -->
    <div class="flex items-center justify-center py-1">
      <ThemeToggle size="sm" />
    </div>

    <!-- User stub -->
    <div
      class="flex items-center gap-2.5 px-2 py-2 rounded-lg hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors duration-150 cursor-pointer"
    >
      <div
        class="shrink-0 w-8 h-8 rounded-full bg-primary-600 flex items-center justify-center text-white text-xs font-semibold"
      >
        U
      </div>
      {#if !collapsed}
        <div class="overflow-hidden">
          <p
            class="text-xs font-medium text-neutral-800 dark:text-neutral-200 truncate leading-none mb-0.5"
          >
            Usuário
          </p>
          <p
            class="text-[11px] text-neutral-500 dark:text-neutral-500 truncate leading-none"
          >
            SIS Lens
          </p>
        </div>
      {/if}
    </div>
  </div>
</aside>
