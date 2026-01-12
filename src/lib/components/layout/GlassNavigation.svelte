<script lang="ts">
  /**
   * 💎 Glass Navigation - Navegação com efeito vitrificado
   * Sidebar moderna com glassmorphism
   */
  
  import { page } from "$app/stores";
  import { goto } from "$app/navigation";
  import GlassCard from "$lib/components/ui/GlassCard.svelte";

  export let currentPage: string = "/";
  
  type MenuItem = {
    icon: string;
    label: string;
    path: string;
    submenu?: MenuItem[];
  };
  
  const menuItems: MenuItem[] = [
    { icon: "🏠", label: "Dashboard", path: "/dashboard" },
    { 
      icon: "📦", 
      label: "Catálogo", 
      path: "/catalogo",
      submenu: [
        { icon: "🔍", label: "Ver Tudo", path: "/catalogo" },
        { icon: "📋", label: "Standard", path: "/catalogo/standard" },
        { icon: "👑", label: "Premium", path: "/catalogo/premium" },
      ]
    },
    { icon: "🏆", label: "Ranking", path: "/ranking" },
    { icon: "🏭", label: "Fornecedores", path: "/fornecedores" },
    { icon: "📊", label: "BI/Relatórios", path: "/bi" },
    { icon: "⚙️", label: "Configurações", path: "/configuracoes" },
  ];
  
  let expandedMenus: Record<string, boolean> = {};

  function isActive(path: string): boolean {
    return currentPage === path || currentPage.startsWith(path + "/");
  }

  function handleNavigation(path: string) {
    goto(path);
  }
  
  function toggleSubmenu(path: string) {
    expandedMenus[path] = !expandedMenus[path];
  }
</script>

<nav class="glass-navigation">
  <GlassCard variant="dark" blur="xl" padding="md" className="nav-container">
    <!-- Logo -->
    <div class="nav-logo">
      <div class="logo-icon">👓</div>
      <div class="logo-text">
        <span class="logo-primary">SIS</span>
        <span class="logo-secondary">Lens</span>
      </div>
    </div>

    <!-- Menu Items -->
    <div class="nav-menu">
      {#each menuItems as item}
        {#if item.submenu}
          <!-- Item com submenu -->
          <div class="nav-item-group">
            <button
              class="nav-item"
              class:active={isActive(item.path)}
              class:has-submenu={true}
              on:click={() => toggleSubmenu(item.path)}
              title={item.label}
            >
              <span class="nav-icon">{item.icon}</span>
              <span class="nav-label">{item.label}</span>
              <span class="submenu-arrow" class:expanded={expandedMenus[item.path]}>›</span>
              {#if isActive(item.path)}
                <div class="active-indicator"></div>
              {/if}
            </button>
            
            {#if expandedMenus[item.path]}
              <div class="submenu">
                {#each item.submenu as subitem}
                  <button
                    class="nav-item submenu-item"
                    class:active={isActive(subitem.path)}
                    on:click={() => handleNavigation(subitem.path)}
                    title={subitem.label}
                  >
                    <span class="nav-icon">{subitem.icon}</span>
                    <span class="nav-label">{subitem.label}</span>
                    {#if isActive(subitem.path)}
                      <div class="active-indicator"></div>
                    {/if}
                  </button>
                {/each}
              </div>
            {/if}
          </div>
        {:else}
          <!-- Item normal -->
          <button
            class="nav-item"
            class:active={isActive(item.path)}
            on:click={() => handleNavigation(item.path)}
            title={item.label}
          >
            <span class="nav-icon">{item.icon}</span>
            <span class="nav-label">{item.label}</span>
            {#if isActive(item.path)}
              <div class="active-indicator"></div>
            {/if}
          </button>
        {/if}
      {/each}
    </div>

    <!-- User Section -->
    <div class="nav-user">
      <div class="user-avatar">
        <span>👤</span>
      </div>
      <div class="user-info">
        <div class="user-name">Admin</div>
        <div class="user-role">Gerente</div>
      </div>
    </div>
  </GlassCard>
</nav>

<style>
  .glass-navigation {
    position: sticky;
    top: 0;
    height: 100vh;
    padding: 1rem;
  }

  :global(.nav-container) {
    height: 100%;
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  /* Logo */
  .nav-logo {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .logo-icon {
    font-size: 2rem;
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
  }

  .logo-text {
    display: flex;
    flex-direction: column;
    line-height: 1.2;
  }

  .logo-primary {
    font-size: 1.25rem;
    font-weight: 800;
    color: white;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  .logo-secondary {
    font-size: 0.875rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.7);
  }

  /* Menu */
  .nav-menu {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    overflow-y: auto;
  }

  .nav-item {
    position: relative;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.875rem 1rem;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 0.75rem;
    color: rgba(255, 255, 255, 0.8);
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    text-align: left;
    overflow: hidden;
  }

  .nav-item:hover {
    background: rgba(255, 255, 255, 0.1);
    border-color: rgba(255, 255, 255, 0.2);
    transform: translateX(4px);
  }

  .nav-item.active {
    background: linear-gradient(135deg, rgba(245, 158, 11, 0.3), rgba(239, 68, 68, 0.3));
    border-color: rgba(245, 158, 11, 0.5);
    color: white;
  }

  .nav-icon {
    font-size: 1.25rem;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
  }

  .nav-label {
    font-size: 0.875rem;
    font-weight: 500;
    flex: 1;
  }

  .active-indicator {
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    width: 3px;
    background: linear-gradient(180deg, #f59e0b, #ef4444);
    border-radius: 999px 0 0 999px;
  }
  
  /* Submenu */
  .nav-item-group {
    display: flex;
    flex-direction: column;
  }
  
  .nav-item.has-submenu {
    cursor: pointer;
  }
  
  .submenu-arrow {
    font-size: 1.25rem;
    transition: transform 0.3s ease;
    color: rgba(255, 255, 255, 0.5);
  }
  
  .submenu-arrow.expanded {
    transform: rotate(90deg);
  }
  
  .submenu {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    margin-left: 1rem;
    margin-top: 0.25rem;
    padding-left: 0.5rem;
    border-left: 2px solid rgba(255, 255, 255, 0.1);
  }
  
  .submenu-item {
    padding: 0.625rem 0.875rem;
    font-size: 0.8125rem;
  }
  
  .submenu-item .nav-icon {
    font-size: 1rem;
  }

  /* User Section */
  .nav-user {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 0.75rem;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }

  .user-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: linear-gradient(135deg, #f59e0b, #ef4444);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  }

  .user-info {
    flex: 1;
  }

  .user-name {
    font-size: 0.875rem;
    font-weight: 600;
    color: white;
  }

  .user-role {
    font-size: 0.75rem;
    color: rgba(255, 255, 255, 0.6);
  }

  /* Scrollbar */
  .nav-menu::-webkit-scrollbar {
    width: 4px;
  }

  .nav-menu::-webkit-scrollbar-track {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 999px;
  }

  .nav-menu::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.2);
    border-radius: 999px;
  }

  .nav-menu::-webkit-scrollbar-thumb:hover {
    background: rgba(255, 255, 255, 0.3);
  }
</style>
