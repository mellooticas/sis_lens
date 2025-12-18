<script lang="ts">
  /**
   * 👓 Galeria de Óculos em Carrossel
   * Slider horizontal de armações com navegação
   */
  
  import { onMount } from 'svelte';
  import GlassesCard from './GlassesCard.svelte';

  export let title: string = 'Destaques';
  export let products: Array<{
    id: string;
    name: string;
    style: 'aviator' | 'wayfarer' | 'round' | 'rectangular' | 'cat-eye';
    brand?: string;
    price: number;
    originalPrice?: number | null;
    color?: string;
    colors?: string[];
    rating?: number;
    stock?: boolean;
    badge?: string | null;
    featured?: boolean;
  }> = [];
  export let autoPlay: boolean = true;
  export let interval: number = 5000;
  export let onProductClick: ((product: any) => void) | null = null;

  let currentIndex = 0;
  let containerRef: HTMLDivElement;
  let isPaused = false;
  let touchStartX = 0;
  let touchEndX = 0;

  $: visibleProducts = getVisibleProducts(currentIndex);

  function getVisibleProducts(index: number) {
    if (products.length === 0) return [];
    
    // Para telas maiores, mostra 3 produtos
    const itemsToShow = 3;
    const result = [];
    
    for (let i = 0; i < itemsToShow; i++) {
      const idx = (index + i) % products.length;
      result.push(products[idx]);
    }
    
    return result;
  }

  function next() {
    currentIndex = (currentIndex + 1) % products.length;
  }

  function prev() {
    currentIndex = currentIndex === 0 ? products.length - 1 : currentIndex - 1;
  }

  function goToSlide(index: number) {
    currentIndex = index;
  }

  function handleTouchStart(e: TouchEvent) {
    touchStartX = e.touches[0].clientX;
  }

  function handleTouchMove(e: TouchEvent) {
    touchEndX = e.touches[0].clientX;
  }

  function handleTouchEnd() {
    const swipeThreshold = 50;
    const diff = touchStartX - touchEndX;

    if (Math.abs(diff) > swipeThreshold) {
      if (diff > 0) {
        next();
      } else {
        prev();
      }
    }
  }

  onMount(() => {
    if (autoPlay && products.length > 1) {
      const timer = setInterval(() => {
        if (!isPaused) {
          next();
        }
      }, interval);

      return () => clearInterval(timer);
    }
  });
</script>

<div class="glasses-carousel">
  <!-- Header -->
  <div class="carousel-header">
    <h3 class="carousel-title">{title}</h3>
    
    <!-- Navigation Dots -->
    {#if products.length > 1}
      <div class="dots">
        {#each products as _, index}
          <button
            class="dot"
            class:active={index === currentIndex}
            on:click={() => goToSlide(index)}
            aria-label="Ir para slide {index + 1}"
          />
        {/each}
      </div>
    {/if}
  </div>

  <!-- Carousel Container -->
  <div 
    class="carousel-container"
    bind:this={containerRef}
    on:mouseenter={() => isPaused = true}
    on:mouseleave={() => isPaused = false}
    on:touchstart={handleTouchStart}
    on:touchmove={handleTouchMove}
    on:touchend={handleTouchEnd}
  >
    <!-- Navigation Buttons -->
    {#if products.length > 1}
      <button
        class="nav-button prev"
        on:click={prev}
        aria-label="Anterior"
      >
        ‹
      </button>

      <button
        class="nav-button next"
        on:click={next}
        aria-label="Próximo"
      >
        ›
      </button>
    {/if}

    <!-- Products Grid -->
    <div class="products-grid">
      {#each visibleProducts as product (product.id)}
        <div class="product-slide">
          <GlassesCard
            {...product}
            onClick={() => onProductClick && onProductClick(product)}
          />
        </div>
      {/each}
    </div>
  </div>

  <!-- Progress Bar (optional) -->
  {#if autoPlay && !isPaused && products.length > 1}
    <div class="progress-bar">
      <div class="progress-fill" style="animation-duration: {interval}ms" />
    </div>
  {/if}
</div>

<style>
  .glasses-carousel {
    width: 100%;
    position: relative;
  }

  .carousel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    gap: 1rem;
    flex-wrap: wrap;
  }

  .carousel-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1f2937;
  }

  :global(.dark) .carousel-title {
    color: #f3f4f6;
  }

  /* Dots Navigation */
  .dots {
    display: flex;
    gap: 0.5rem;
    align-items: center;
  }

  .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #d1d5db;
    border: none;
    cursor: pointer;
    transition: all 0.3s ease;
    padding: 0;
  }

  .dot:hover {
    background: #9ca3af;
    transform: scale(1.2);
  }

  .dot.active {
    width: 24px;
    border-radius: 4px;
    background: #1C3B5A;
  }

  /* Carousel Container */
  .carousel-container {
    position: relative;
    overflow: visible;
    padding: 1rem 0;
  }

  /* Navigation Buttons */
  .nav-button {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: white;
    border: 2px solid #e5e7eb;
    color: #1C3B5A;
    font-size: 2rem;
    font-weight: 300;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
    z-index: 10;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .nav-button:hover {
    background: #1C3B5A;
    color: white;
    border-color: #1C3B5A;
    transform: translateY(-50%) scale(1.1);
  }

  .nav-button:active {
    transform: translateY(-50%) scale(0.95);
  }

  .nav-button.prev {
    left: -24px;
  }

  .nav-button.next {
    right: -24px;
  }

  :global(.dark) .nav-button {
    background: #1f2937;
    border-color: #374151;
    color: #f3f4f6;
  }

  :global(.dark) .nav-button:hover {
    background: #1C3B5A;
    border-color: #1C3B5A;
  }

  /* Products Grid */
  .products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 1.5rem;
    transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .product-slide {
    animation: slideIn 0.5s ease-out;
  }

  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translateX(20px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }

  /* Progress Bar */
  .progress-bar {
    width: 100%;
    height: 3px;
    background: #e5e7eb;
    border-radius: 999px;
    overflow: hidden;
    margin-top: 1.5rem;
  }

  .progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #1C3B5A 0%, #CC6B2F 100%);
    animation: progress linear;
    transform-origin: left;
  }

  @keyframes progress {
    from {
      transform: scaleX(0);
    }
    to {
      transform: scaleX(1);
    }
  }

  /* Responsive */
  @media (max-width: 1024px) {
    .products-grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  @media (max-width: 768px) {
    .carousel-header {
      flex-direction: column;
      align-items: flex-start;
    }

    .products-grid {
      grid-template-columns: 1fr;
    }

    .nav-button {
      width: 40px;
      height: 40px;
      font-size: 1.5rem;
    }

    .nav-button.prev {
      left: -12px;
    }

    .nav-button.next {
      right: -12px;
    }
  }

  @media (max-width: 640px) {
    .nav-button {
      display: none;
    }

    .carousel-container {
      padding: 0.5rem 0;
    }
  }
</style>
