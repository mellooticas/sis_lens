<script lang="ts">
  /**
   * 👓 Showcase de Óculos
   * Vitrine animada de diferentes estilos de armações
   */
  
  import { onMount } from 'svelte';
  import GlassesIcon from './GlassesIcon.svelte';

  export let title: string = 'Escolha seu Estilo';
  export let subtitle: string = 'Diversos modelos de armações disponíveis';
  export let animate: boolean = true;
  
  const glassesStyles = [
    {
      id: 'wayfarer',
      name: 'Wayfarer',
      description: 'Clássico e versátil',
      color: '#1C3B5A',
      popular: true
    },
    {
      id: 'aviator',
      name: 'Aviator',
      description: 'Estilo piloto',
      color: '#CC6B2F',
      popular: true
    },
    {
      id: 'round',
      name: 'Redondo',
      description: 'Vintage e moderno',
      color: '#DEA742',
      popular: false
    },
    {
      id: 'rectangular',
      name: 'Retangular',
      description: 'Minimalista e elegante',
      color: '#3b82f6',
      popular: false
    },
    {
      id: 'cat-eye',
      name: 'Cat Eye',
      description: 'Sofisticado e feminino',
      color: '#ec4899',
      popular: true
    }
  ];

  let selectedStyle = 0;
  let hoveredIndex: number | null = null;

  onMount(() => {
    if (animate) {
      const interval = setInterval(() => {
        if (hoveredIndex === null) {
          selectedStyle = (selectedStyle + 1) % glassesStyles.length;
        }
      }, 3000);

      return () => clearInterval(interval);
    }
  });

  function handleStyleClick(index: number) {
    selectedStyle = index;
  }
</script>

<div class="glasses-showcase">
  <!-- Header -->
  <div class="text-center mb-8">
    <h2 class="text-3xl font-bold text-neutral-900 dark:text-neutral-100 mb-2">
      {title}
    </h2>
    <p class="text-neutral-600 dark:text-neutral-400">
      {subtitle}
    </p>
  </div>

  <!-- Main Display -->
  <div class="main-display mb-12 relative">
    <div class="display-card">
      <!-- Featured Glasses -->
      <div class="featured-icon" class:animate={animate && hoveredIndex === null}>
        <GlassesIcon 
          style={glassesStyles[selectedStyle].id} 
          size="xl" 
          color={glassesStyles[selectedStyle].color}
        />
      </div>

      <!-- Info -->
      <div class="mt-6 text-center">
        <h3 class="text-2xl font-bold text-neutral-900 dark:text-neutral-100">
          {glassesStyles[selectedStyle].name}
        </h3>
        <p class="text-neutral-600 dark:text-neutral-400 mt-2">
          {glassesStyles[selectedStyle].description}
        </p>
        {#if glassesStyles[selectedStyle].popular}
          <span class="inline-flex items-center gap-1 mt-3 px-3 py-1 bg-brand-gold-100 text-brand-gold-700 rounded-full text-sm font-medium">
            ⭐ Mais Popular
          </span>
        {/if}
      </div>
    </div>
  </div>

  <!-- Style Selector -->
  <div class="style-grid">
    {#each glassesStyles as style, index}
      <button
        class="style-card"
        class:active={selectedStyle === index}
        on:click={() => handleStyleClick(index)}
        on:mouseenter={() => hoveredIndex = index}
        on:mouseleave={() => hoveredIndex = null}
      >
        <div class="style-icon">
          <GlassesIcon 
            style={style.id} 
            size="md" 
            color={selectedStyle === index ? style.color : '#9ca3af'}
          />
        </div>
        <div class="style-name">
          {style.name}
        </div>
        {#if style.popular}
          <div class="popular-badge">🔥</div>
        {/if}
      </button>
    {/each}
  </div>
</div>

<style>
  .glasses-showcase {
    padding: 2rem;
    max-width: 800px;
    margin: 0 auto;
  }

  .main-display {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 300px;
  }

  .display-card {
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    padding: 3rem;
    border-radius: 1.5rem;
    box-shadow: 
      0 10px 40px rgba(0, 0, 0, 0.1),
      0 0 0 1px rgba(0, 0, 0, 0.05);
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
  }

  .display-card::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.3) 0%, transparent 70%);
    opacity: 0.5;
  }

  .featured-icon {
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    z-index: 1;
    transition: transform 0.3s ease;
  }

  .featured-icon.animate {
    animation: float 3s ease-in-out infinite;
  }

  @keyframes float {
    0%, 100% {
      transform: translateY(0px) rotate(0deg);
    }
    25% {
      transform: translateY(-10px) rotate(-2deg);
    }
    50% {
      transform: translateY(0px) rotate(0deg);
    }
    75% {
      transform: translateY(-5px) rotate(2deg);
    }
  }

  .style-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: 1rem;
    margin-top: 2rem;
  }

  .style-card {
    position: relative;
    background: white;
    border: 2px solid #e5e7eb;
    border-radius: 1rem;
    padding: 1.5rem 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.75rem;
  }

  .style-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
    border-color: #cbd5e1;
  }

  .style-card.active {
    border-color: #1C3B5A;
    background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
    box-shadow: 0 8px 20px rgba(28, 59, 90, 0.15);
  }

  .style-icon {
    transition: transform 0.3s ease;
  }

  .style-card:hover .style-icon {
    transform: scale(1.1);
  }

  .style-name {
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
    text-align: center;
  }

  .style-card.active .style-name {
    color: #1C3B5A;
  }

  .popular-badge {
    position: absolute;
    top: -8px;
    right: -8px;
    background: #fef3c7;
    border: 2px solid #fbbf24;
    border-radius: 50%;
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.875rem;
    animation: pulse 2s ease-in-out infinite;
  }

  @keyframes pulse {
    0%, 100% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.1);
    }
  }

  /* Dark mode */
  :global(.dark) .display-card {
    background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
  }

  :global(.dark) .style-card {
    background: #1f2937;
    border-color: #374151;
  }

  :global(.dark) .style-card:hover {
    border-color: #4b5563;
  }

  :global(.dark) .style-card.active {
    background: linear-gradient(135deg, #1e3a5f 0%, #1C3B5A 100%);
    border-color: #CC6B2F;
  }

  :global(.dark) .style-name {
    color: #d1d5db;
  }

  :global(.dark) .style-card.active .style-name {
    color: #f3f4f6;
  }

  /* Responsive */
  @media (max-width: 640px) {
    .glasses-showcase {
      padding: 1rem;
    }

    .display-card {
      padding: 2rem 1.5rem;
    }

    .style-grid {
      grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
      gap: 0.75rem;
    }

    .style-card {
      padding: 1rem 0.5rem;
    }
  }
</style>
