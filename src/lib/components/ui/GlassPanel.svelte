<script lang="ts">
  /**
   * 📊 Glass Panel - Painel com efeito vitrificado
   * Componente para estatísticas e informações com glassmorphism
   */
  
  export let title: string = '';
  export let value: string | number = '';
  export let subtitle: string = '';
  export let icon: string = '';
  export let trend: 'up' | 'down' | 'neutral' = 'neutral';
  export let trendValue: string = '';
  export let variant: 'default' | 'primary' | 'success' | 'warning' | 'gradient' = 'default';
  export let size: 'sm' | 'md' | 'lg' = 'md';
  export let className: string = '';

  function getTrendIcon(trend: string): string {
    switch (trend) {
      case 'up': return '↗';
      case 'down': return '↘';
      default: return '→';
    }
  }

  function getTrendColor(trend: string): string {
    switch (trend) {
      case 'up': return '#22c55e';
      case 'down': return '#ef4444';
      default: return '#6b7280';
    }
  }
</script>

<div class="glass-panel {variant} {size} {className}">
  <div class="glass-panel-content">
    {#if icon}
      <div class="panel-icon">{icon}</div>
    {/if}
    
    <div class="panel-info">
      {#if title}
        <div class="panel-title">{title}</div>
      {/if}
      
      {#if value}
        <div class="panel-value">{value}</div>
      {/if}
      
      {#if subtitle}
        <div class="panel-subtitle">{subtitle}</div>
      {/if}
      
      {#if trendValue}
        <div class="panel-trend" style="color: {getTrendColor(trend)}">
          <span class="trend-icon">{getTrendIcon(trend)}</span>
          <span class="trend-value">{trendValue}</span>
        </div>
      {/if}
    </div>
  </div>
  
  <div class="glass-gradient"></div>
</div>

<style>
  .glass-panel {
    position: relative;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border-radius: 1.25rem;
    border: 1px solid rgba(255, 255, 255, 0.2);
    overflow: hidden;
    transition: all 0.3s ease;
  }

  .glass-panel:hover {
    transform: translateY(-2px);
    border-color: rgba(255, 255, 255, 0.3);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  }

  .glass-panel-content {
    position: relative;
    z-index: 1;
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .glass-gradient {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  }

  /* Icon */
  .panel-icon {
    font-size: 2.5rem;
    line-height: 1;
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
  }

  /* Info */
  .panel-info {
    flex: 1;
  }

  .panel-title {
    font-size: 0.875rem;
    font-weight: 500;
    color: rgba(255, 255, 255, 0.8);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin-bottom: 0.5rem;
  }

  .panel-value {
    font-size: 2rem;
    font-weight: 800;
    color: white;
    line-height: 1;
    margin-bottom: 0.25rem;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  }

  .panel-subtitle {
    font-size: 0.75rem;
    color: rgba(255, 255, 255, 0.6);
    margin-bottom: 0.5rem;
  }

  .panel-trend {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    font-size: 0.875rem;
    font-weight: 600;
  }

  .trend-icon {
    font-size: 1rem;
  }

  /* Sizes */
  .glass-panel.sm .glass-panel-content {
    padding: 1rem;
  }

  .glass-panel.sm .panel-value {
    font-size: 1.5rem;
  }

  .glass-panel.sm .panel-icon {
    font-size: 2rem;
  }

  .glass-panel.md .glass-panel-content {
    padding: 1.5rem;
  }

  .glass-panel.lg .glass-panel-content {
    padding: 2rem;
  }

  .glass-panel.lg .panel-value {
    font-size: 2.5rem;
  }

  .glass-panel.lg .panel-icon {
    font-size: 3rem;
  }

  /* Variants */
  .glass-panel.primary {
    background: rgba(28, 59, 90, 0.3);
    border-color: rgba(28, 59, 90, 0.4);
  }

  .glass-panel.success {
    background: rgba(34, 197, 94, 0.2);
    border-color: rgba(34, 197, 94, 0.3);
  }

  .glass-panel.warning {
    background: rgba(245, 158, 11, 0.2);
    border-color: rgba(245, 158, 11, 0.3);
  }

  .glass-panel.gradient {
    background: linear-gradient(
      135deg,
      rgba(204, 107, 47, 0.25) 0%,
      rgba(222, 167, 66, 0.25) 100%
    );
    border-color: rgba(204, 107, 47, 0.35);
  }

  /* Responsive */
  @media (max-width: 640px) {
    .panel-value {
      font-size: 1.5rem;
    }

    .panel-icon {
      font-size: 2rem;
    }
  }
</style>
