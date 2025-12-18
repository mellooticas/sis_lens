<script lang="ts">
  /**
   * 💎 Glass Layout - Layout principal com design vitrificado
   */
  
  import GlassNavigation from "./GlassNavigation.svelte";
  import GlassCard from "$lib/components/ui/GlassCard.svelte";

  export let currentPage: string = "/";
  export let pageTitle: string = "";
  export let pageSubtitle: string = "";
  export let showHeader: boolean = true;

  // Atualizar horário
  let currentTime = new Date().toLocaleTimeString('pt-BR', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });

  setInterval(() => {
    currentTime = new Date().toLocaleTimeString('pt-BR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  }, 1000);
</script>

<div class="glass-layout">
  <!-- Background -->
  <div class="glass-background"></div>

  <!-- Sidebar Navigation -->
  <aside class="glass-sidebar">
    <GlassNavigation {currentPage} />
  </aside>

  <!-- Main Content -->
  <main class="glass-main">
    {#if showHeader}
      <!-- Header -->
      <header class="glass-header">
        <GlassCard variant="dark" blur="lg" padding="md">
          <div class="header-content">
            <div class="header-info">
              {#if pageTitle}
                <h1 class="page-title">{pageTitle}</h1>
              {/if}
              {#if pageSubtitle}
                <p class="page-subtitle">{pageSubtitle}</p>
              {/if}
            </div>
            
            <div class="header-actions">
              <div class="time-display">{currentTime}</div>
              <button class="notification-btn">
                <span class="notification-icon">🔔</span>
                <span class="notification-badge">3</span>
              </button>
            </div>
          </div>
        </GlassCard>
      </header>
    {/if}

    <!-- Content Area -->
    <div class="glass-content">
      <slot />
    </div>
  </main>
</div>

<style>
  :global(body) {
    margin: 0;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    overflow-x: hidden;
  }

  .glass-layout {
    position: relative;
    min-height: 100vh;
    display: grid;
    grid-template-columns: 280px 1fr;
    gap: 0;
  }

  /* Background */
  .glass-background {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: 
      linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
    z-index: -1;
  }

  .glass-background::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: 
      radial-gradient(circle at 20% 50%, rgba(245, 158, 11, 0.15) 0%, transparent 50%),
      radial-gradient(circle at 80% 80%, rgba(59, 130, 246, 0.15) 0%, transparent 50%),
      radial-gradient(circle at 40% 20%, rgba(139, 92, 246, 0.1) 0%, transparent 50%);
    animation: backgroundPulse 20s ease-in-out infinite;
  }

  @keyframes backgroundPulse {
    0%, 100% {
      transform: translate(0, 0) scale(1);
    }
    50% {
      transform: translate(-5%, -5%) scale(1.1);
    }
  }

  /* Sidebar */
  .glass-sidebar {
    position: sticky;
    top: 0;
    height: 100vh;
    z-index: 100;
  }

  /* Main Content */
  .glass-main {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    padding: 1rem;
  }

  /* Header */
  .glass-header {
    margin-bottom: 1.5rem;
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 2rem;
  }

  .header-info {
    flex: 1;
  }

  .page-title {
    font-size: 1.75rem;
    font-weight: 800;
    color: white;
    margin: 0;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  }

  .page-subtitle {
    font-size: 0.875rem;
    color: rgba(255, 255, 255, 0.7);
    margin: 0.25rem 0 0;
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: 1.5rem;
  }

  .time-display {
    font-size: 1.25rem;
    font-weight: 600;
    font-family: 'Courier New', monospace;
    color: white;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  .notification-btn {
    position: relative;
    width: 44px;
    height: 44px;
    border: none;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 50%;
    color: white;
    font-size: 1.25rem;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .notification-btn:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: scale(1.1);
  }

  .notification-badge {
    position: absolute;
    top: 6px;
    right: 6px;
    width: 18px;
    height: 18px;
    background: linear-gradient(135deg, #ef4444, #dc2626);
    border-radius: 50%;
    font-size: 0.625rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  }

  /* Content */
  .glass-content {
    flex: 1;
  }

  /* Responsive */
  @media (max-width: 1024px) {
    .glass-layout {
      grid-template-columns: 1fr;
    }

    .glass-sidebar {
      position: fixed;
      top: 0;
      left: -280px;
      width: 280px;
      height: 100vh;
      transition: left 0.3s ease;
      z-index: 200;
    }

    .glass-sidebar.open {
      left: 0;
    }
  }

  @media (max-width: 640px) {
    .glass-main {
      padding: 0.75rem;
    }

    .page-title {
      font-size: 1.25rem;
    }

    .header-actions {
      gap: 0.75rem;
    }

    .time-display {
      display: none;
    }
  }
</style>
