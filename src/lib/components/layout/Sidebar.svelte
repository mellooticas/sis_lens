<script lang="ts">
  /**
   * Sidebar Navigation
   * Menu lateral retrátil SIS Lens
   */
  import { page } from "$app/stores";
  import Logo from "$lib/components/layout/Logo.svelte";

  export let collapsed = false;

  // Menu items
  const menuItems = [
    { id: "demo", label: "Nova Venda", href: "/demo", icon: "zap" },
    { id: "home", label: "Dashboard", href: "/", icon: "home" },
    { id: "buscar", label: "Buscar Lentes", href: "/buscar", icon: "search" },
    { id: "historico", label: "Histórico", href: "/historico", icon: "clock" },
    { id: "analytics", label: "Analytics", href: "/analytics", icon: "chart" },
    { id: "config", label: "Configurações", href: "/config", icon: "settings" },
  ];

  function isActive(path: string) {
    if (path === "/") return $page.url.pathname === "/";
    return $page.url.pathname.startsWith(path);
  }
</script>

<aside
  class="
    fixed left-0 top-0 h-full bg-white dark:bg-neutral-900 border-r border-neutral-200 dark:border-neutral-800
    transition-all duration-300 z-40 flex flex-col
    {collapsed ? 'w-20' : 'w-64'}
  "
>
  <!-- Logo Section -->
  <div
    class="h-16 flex items-center justify-center border-b border-neutral-100 dark:border-neutral-800"
  >
    <div class="scale-90">
      <Logo size="sm" variant={collapsed ? "icon" : "full"} />
    </div>
  </div>

  <!-- Navigation -->
  <nav class="flex-1 py-6 px-3 space-y-1 overflow-y-auto">
    {#each menuItems as item}
      <a
        href={item.href}
        class="
          flex items-center gap-3 px-3 py-3 rounded-lg transition-colors group
          {isActive(item.href)
          ? 'bg-brand-blue-50 text-brand-blue-600 dark:bg-neutral-800 dark:text-brand-blue-400 font-medium'
          : 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800 hover:text-neutral-900 dark:hover:text-neutral-200'}
        "
        title={collapsed ? item.label : ""}
      >
        <!-- Icon Placeholder (Lucide style) -->
        <span class="shrink-0">
          {#if item.icon === "home"}
            <svg
              class="w-6 h-6"
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
              class="w-6 h-6"
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
          {:else if item.icon === "clock"}
            <svg
              class="w-6 h-6"
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
              class="w-6 h-6"
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
              class="w-6 h-6"
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
          {:else if item.icon === "zap"}
            <svg
              class="w-6 h-6 text-brand-gold-500"
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
          <span class="whitespace-nowrap font-sans">{item.label}</span>
        {/if}
      </a>
    {/each}
  </nav>

  <!-- User Profile (Bottom) -->
  <div class="border-t border-neutral-100 dark:border-neutral-800 p-4">
    <button
      class="flex items-center gap-3 w-full hover:bg-neutral-50 dark:hover:bg-neutral-800 p-2 rounded-lg transition-colors"
    >
      <div
        class="w-8 h-8 rounded-full bg-brand-blue-100 flex items-center justify-center text-brand-blue-700 font-bold text-sm"
      >
        JS
      </div>
      {#if !collapsed}
        <div class="text-left overflow-hidden">
          <div
            class="text-sm font-medium text-neutral-900 dark:text-neutral-100 truncate"
          >
            Junior Silva
          </div>
          <div class="text-xs text-neutral-500 truncate">Admin</div>
        </div>
      {/if}
    </button>
  </div>
</aside>
