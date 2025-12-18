<script lang="ts">
  /**
   * 👓 Card de Produto de Óculos
   * Card animado para exibir armações com informações e interações
   */
  
  import GlassesIcon from './GlassesIcon.svelte';

  export let id: string;
  export let name: string;
  export let style: 'aviator' | 'wayfarer' | 'round' | 'rectangular' | 'cat-eye' = 'wayfarer';
  export let brand: string = '';
  export let price: number = 0;
  export let originalPrice: number | null = null;
  export let color: string = '#1C3B5A';
  export let colors: string[] = ['#1C3B5A', '#CC6B2F', '#000000'];
  export let rating: number = 0;
  export let stock: boolean = true;
  export let badge: string | null = null;
  export let featured: boolean = false;
  export let onClick: (() => void) | null = null;

  let selectedColor = color;
  let isHovered = false;

  function formatPrice(value: number): string {
    return value.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  }

  function getDiscount(): number | null {
    if (originalPrice && originalPrice > price) {
      return Math.round(((originalPrice - price) / originalPrice) * 100);
    }
    return null;
  }

  function handleColorSelect(newColor: string) {
    selectedColor = newColor;
  }

  function handleCardClick() {
    if (onClick) onClick();
  }
</script>

<div 
  class="glasses-card"
  class:featured
  class:hovered={isHovered}
  on:mouseenter={() => isHovered = true}
  on:mouseleave={() => isHovered = false}
  on:click={handleCardClick}
  on:keydown={(e) => e.key === 'Enter' && handleCardClick()}
  role="button"
  tabindex="0"
>
  <!-- Badges -->
  <div class="badges">
    {#if badge}
      <span class="badge custom">{badge}</span>
    {/if}
    {#if featured}
      <span class="badge featured">⭐ Destaque</span>
    {/if}
    {#if getDiscount()}
      <span class="badge discount">-{getDiscount()}%</span>
    {/if}
    {#if !stock}
      <span class="badge out-of-stock">Sem estoque</span>
    {/if}
  </div>

  <!-- Icon Container -->
  <div class="icon-container">
    <div class="icon-wrapper" class:animate-bounce={isHovered}>
      <GlassesIcon {style} size="lg" color={selectedColor} />
    </div>
    
    <!-- Reflection effect -->
    <div class="reflection"></div>
  </div>

  <!-- Info -->
  <div class="info">
    {#if brand}
      <div class="brand">{brand}</div>
    {/if}
    
    <h3 class="name">{name}</h3>

    <!-- Rating -->
    {#if rating > 0}
      <div class="rating">
        {#each Array(5) as _, i}
          <span class="star" class:filled={i < Math.floor(rating)}>
            {i < Math.floor(rating) ? '★' : '☆'}
          </span>
        {/each}
        <span class="rating-value">{rating.toFixed(1)}</span>
      </div>
    {/if}

    <!-- Colors -->
    {#if colors.length > 1}
      <div class="colors">
        {#each colors as c}
          <button
            class="color-option"
            class:selected={c === selectedColor}
            style="background-color: {c}"
            on:click|stopPropagation={() => handleColorSelect(c)}
            aria-label="Selecionar cor"
          >
            {#if c === selectedColor}
              <span class="checkmark">✓</span>
            {/if}
          </button>
        {/each}
      </div>
    {/if}

    <!-- Price -->
    <div class="price-container">
      {#if originalPrice}
        <span class="original-price">{formatPrice(originalPrice)}</span>
      {/if}
      <span class="price">{formatPrice(price)}</span>
    </div>

    <!-- CTA Button -->
    <button 
      class="cta-button" 
      class:disabled={!stock}
      disabled={!stock}
      on:click|stopPropagation={handleCardClick}
    >
      {#if stock}
        <span>Ver Detalhes</span>
        <span class="arrow">→</span>
      {:else}
        Indisponível
      {/if}
    </button>
  </div>
</div>

<style>
  .glasses-card {
    background: white;
    border-radius: 1rem;
    padding: 1.5rem;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
    position: relative;
    overflow: hidden;
    border: 2px solid transparent;
  }

  .glasses-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(135deg, rgba(28, 59, 90, 0.03) 0%, rgba(204, 107, 47, 0.03) 100%);
    opacity: 0;
    transition: opacity 0.3s ease;
    pointer-events: none;
  }

  .glasses-card.hovered::before {
    opacity: 1;
  }

  .glasses-card:hover,
  .glasses-card:focus-visible {
    transform: translateY(-8px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
    border-color: #e5e7eb;
  }

  .glasses-card.featured {
    border-color: #DEA742;
    background: linear-gradient(135deg, #fffbeb 0%, #ffffff 50%);
  }

  .glasses-card:focus-visible {
    outline: 2px solid #1C3B5A;
    outline-offset: 2px;
  }

  /* Badges */
  .badges {
    position: absolute;
    top: 1rem;
    left: 1rem;
    right: 1rem;
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    z-index: 10;
  }

  .badge {
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 600;
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
  }

  .badge.custom {
    background: #1C3B5A;
    color: white;
  }

  .badge.featured {
    background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
    color: #78350f;
  }

  .badge.discount {
    background: #ef4444;
    color: white;
  }

  .badge.out-of-stock {
    background: #6b7280;
    color: white;
  }

  /* Icon */
  .icon-container {
    position: relative;
    padding: 3rem 1rem;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 1rem;
  }

  .icon-wrapper {
    transition: transform 0.3s ease;
    position: relative;
    z-index: 1;
  }

  .icon-wrapper.animate-bounce {
    animation: gentle-bounce 0.6s ease-in-out;
  }

  @keyframes gentle-bounce {
    0%, 100% {
      transform: translateY(0) rotate(0deg);
    }
    25% {
      transform: translateY(-8px) rotate(-3deg);
    }
    50% {
      transform: translateY(0) rotate(0deg);
    }
    75% {
      transform: translateY(-4px) rotate(3deg);
    }
  }

  .reflection {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 120%;
    height: 120%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.4) 0%, transparent 70%);
    opacity: 0;
    transition: opacity 0.3s ease;
    pointer-events: none;
  }

  .glasses-card:hover .reflection {
    opacity: 1;
  }

  /* Info */
  .info {
    text-align: center;
  }

  .brand {
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #CC6B2F;
    font-weight: 600;
    margin-bottom: 0.5rem;
  }

  .name {
    font-size: 1.125rem;
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 0.75rem;
    line-height: 1.4;
  }

  /* Rating */
  .rating {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.25rem;
    margin-bottom: 1rem;
  }

  .star {
    color: #d1d5db;
    font-size: 1rem;
    transition: color 0.2s ease;
  }

  .star.filled {
    color: #fbbf24;
  }

  .rating-value {
    font-size: 0.875rem;
    font-weight: 600;
    color: #6b7280;
    margin-left: 0.25rem;
  }

  /* Colors */
  .colors {
    display: flex;
    justify-content: center;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .color-option {
    width: 2rem;
    height: 2rem;
    border-radius: 50%;
    border: 2px solid #e5e7eb;
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .color-option:hover {
    transform: scale(1.1);
    border-color: #9ca3af;
  }

  .color-option.selected {
    border-color: #1C3B5A;
    border-width: 3px;
    box-shadow: 0 0 0 2px rgba(28, 59, 90, 0.1);
  }

  .checkmark {
    color: white;
    font-size: 0.75rem;
    font-weight: bold;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
  }

  /* Price */
  .price-container {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.75rem;
    margin-bottom: 1rem;
  }

  .original-price {
    font-size: 0.875rem;
    color: #9ca3af;
    text-decoration: line-through;
  }

  .price {
    font-size: 1.5rem;
    font-weight: 800;
    color: #1C3B5A;
  }

  /* CTA Button */
  .cta-button {
    width: 100%;
    padding: 0.75rem 1.5rem;
    background: linear-gradient(135deg, #1C3B5A 0%, #2d5a8a 100%);
    color: white;
    border: none;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
  }

  .cta-button:hover:not(.disabled) {
    background: linear-gradient(135deg, #2d5a8a 0%, #1C3B5A 100%);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(28, 59, 90, 0.3);
  }

  .cta-button:active:not(.disabled) {
    transform: translateY(0);
  }

  .cta-button.disabled {
    background: #d1d5db;
    cursor: not-allowed;
  }

  .arrow {
    transition: transform 0.3s ease;
  }

  .cta-button:hover:not(.disabled) .arrow {
    transform: translateX(4px);
  }

  /* Dark mode */
  :global(.dark) .glasses-card {
    background: #1f2937;
    border-color: #374151;
  }

  :global(.dark) .glasses-card:hover {
    border-color: #4b5563;
  }

  :global(.dark) .name {
    color: #f3f4f6;
  }

  :global(.dark) .price {
    color: #DEA742;
  }

  /* Responsive */
  @media (max-width: 640px) {
    .glasses-card {
      padding: 1rem;
    }

    .icon-container {
      padding: 2rem 1rem;
    }

    .name {
      font-size: 1rem;
    }

    .price {
      font-size: 1.25rem;
    }
  }
</style>
