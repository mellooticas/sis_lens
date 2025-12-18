<script lang="ts">
  /**
   * 💎 Glass Card - Efeito Vitrificado
   * Card com backdrop blur e efeito de vidro fosco
   */
  
  export let variant: 'default' | 'primary' | 'secondary' | 'dark' = 'default';
  export let blur: 'sm' | 'md' | 'lg' | 'xl' = 'md';
  export let padding: 'sm' | 'md' | 'lg' = 'md';
  export let className: string = '';
  export let onClick: (() => void) | null = null;
  export let hoverable: boolean = false;

  const blurMap = {
    sm: '4px',
    md: '8px',
    lg: '12px',
    xl: '16px'
  };

  const paddingMap = {
    sm: '1rem',
    md: '1.5rem',
    lg: '2rem'
  };
</script>

<div 
  class="glass-card {variant} {className}"
  class:clickable={onClick || hoverable}
  style="
    --blur-amount: {blurMap[blur]};
    --padding: {paddingMap[padding]};
  "
  on:click={onClick}
  on:keydown={(e) => e.key === 'Enter' && onClick && onClick()}
  role={onClick ? 'button' : undefined}
  tabindex={onClick ? 0 : undefined}
>
  <div class="glass-content">
    <slot />
  </div>
  <div class="glass-shine"></div>
</div>

<style>
  .glass-card {
    position: relative;
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(var(--blur-amount));
    -webkit-backdrop-filter: blur(var(--blur-amount));
    border-radius: 1.25rem;
    border: 1px solid rgba(255, 255, 255, 0.25);
    box-shadow: 
      0 8px 32px rgba(0, 0, 0, 0.1),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
    overflow: hidden;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .glass-content {
    position: relative;
    z-index: 1;
    padding: var(--padding);
  }

  .glass-shine {
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.15),
      transparent
    );
    transition: left 0.5s ease;
    pointer-events: none;
  }

  .glass-card.clickable {
    cursor: pointer;
  }

  .glass-card.clickable:hover {
    transform: translateY(-4px);
    border-color: rgba(255, 255, 255, 0.4);
    box-shadow: 
      0 12px 40px rgba(0, 0, 0, 0.15),
      inset 0 1px 0 rgba(255, 255, 255, 0.4);
  }

  .glass-card.clickable:hover .glass-shine {
    left: 100%;
  }

  .glass-card.clickable:active {
    transform: translateY(-2px);
  }

  /* Variantes */
  .glass-card.primary {
    background: rgba(28, 59, 90, 0.25);
    border-color: rgba(28, 59, 90, 0.4);
  }

  .glass-card.secondary {
    background: rgba(204, 107, 47, 0.2);
    border-color: rgba(204, 107, 47, 0.35);
  }

  .glass-card.dark {
    background: rgba(0, 0, 0, 0.3);
    border-color: rgba(255, 255, 255, 0.15);
  }

  /* Focus state */
  .glass-card.clickable:focus-visible {
    outline: 2px solid rgba(28, 59, 90, 0.5);
    outline-offset: 2px;
  }

  /* Responsive */
  @media (max-width: 640px) {
    .glass-card {
      border-radius: 1rem;
    }
  }
</style>
