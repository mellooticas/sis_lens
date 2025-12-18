<!--
  🎨 Página Principal de Demos - SIS Lens
  Showcase de todos os componentes visuais disponíveis
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import GlassesShowcase from "$lib/components/ui/GlassesShowcase.svelte";
  import GlassesCarousel from "$lib/components/ui/GlassesCarousel.svelte";
  import Button from "$lib/components/ui/Button.svelte";

  // Produtos de exemplo para o carrossel
  const featuredProducts = [
    {
      id: '1',
      name: 'Classic Wayfarer Premium',
      style: 'wayfarer' as const,
      brand: 'Essilor',
      price: 459.90,
      originalPrice: 599.90,
      color: '#1C3B5A',
      colors: ['#1C3B5A', '#000000', '#8B4513'],
      rating: 4.8,
      stock: true,
      badge: '🏆 Mais Vendido',
      featured: true
    },
    {
      id: '2',
      name: 'Aviator Gold Edition',
      style: 'aviator' as const,
      brand: 'Zeiss',
      price: 589.90,
      color: '#CC6B2F',
      colors: ['#CC6B2F', '#FFD700', '#C0C0C0'],
      rating: 4.9,
      stock: true,
      featured: true
    },
    {
      id: '3',
      name: 'Round Vintage Style',
      style: 'round' as const,
      brand: 'Hoya',
      price: 389.90,
      originalPrice: 489.90,
      color: '#DEA742',
      colors: ['#DEA742', '#000000', '#8B0000'],
      rating: 4.6,
      stock: true
    },
    {
      id: '4',
      name: 'Minimal Rectangular',
      style: 'rectangular' as const,
      brand: 'Varilux',
      price: 429.90,
      color: '#3b82f6',
      colors: ['#3b82f6', '#1C3B5A', '#6b7280'],
      rating: 4.7,
      stock: true,
      badge: '✨ Novo'
    },
    {
      id: '5',
      name: 'Cat Eye Elegance',
      style: 'cat-eye' as const,
      brand: 'Crizal',
      price: 549.90,
      color: '#ec4899',
      colors: ['#ec4899', '#9333ea', '#000000'],
      rating: 4.9,
      stock: true,
      featured: true
    }
  ];

  function handleProductClick(product: any) {
    console.log('Produto clicado:', product);
  }

  function navigateToGlasses() {
    goto('/demo/glasses');
  }
</script>

<svelte:head>
  <title>Demos - Componentes Visuais | SIS Lens</title>
</svelte:head>

<Container>
  <!-- Hero -->
  <PageHero
    title="🎨 Galeria de Componentes"
    description="Explore todos os componentes visuais disponíveis no SIS Lens"
  />

  <!-- Quick Links -->
  <div class="grid md:grid-cols-3 gap-4 mb-12">
    <button 
      on:click={navigateToGlasses}
      class="demo-link-card group"
    >
      <div class="flex items-center gap-3">
        <span class="text-4xl">👓</span>
        <div class="text-left">
          <h3 class="font-bold text-neutral-900 dark:text-neutral-100 group-hover:text-brand-blue-500">
            Componentes de Óculos
          </h3>
          <p class="text-sm text-neutral-600 dark:text-neutral-400">
            Ícones, cards e showcases
          </p>
        </div>
      </div>
      <span class="arrow">→</span>
    </button>

    <button 
      on:click={() => goto('/demo/lenses')}
      class="demo-link-card group"
    >
      <div class="flex items-center gap-3">
        <span class="text-4xl">🔍</span>
        <div class="text-left">
          <h3 class="font-bold text-neutral-900 dark:text-neutral-100 group-hover:text-brand-blue-500">
            Comparador de Lentes
          </h3>
          <p class="text-sm text-neutral-600 dark:text-neutral-400">
            Visualizações de lentes
          </p>
        </div>
      </div>
      <span class="arrow">→</span>
    </button>

    <button 
      on:click={() => goto('/demo/sales')}
      class="demo-link-card group"
    >
      <div class="flex items-center gap-3">
        <span class="text-4xl">📊</span>
        <div class="text-left">
          <h3 class="font-bold text-neutral-900 dark:text-neutral-100 group-hover:text-brand-blue-500">
            Análise de Vendas
          </h3>
          <p class="text-sm text-neutral-600 dark:text-neutral-400">
            Dashboards e gráficos
          </p>
        </div>
      </div>
      <span class="arrow">→</span>
    </button>
  </div>

  <!-- Showcase Interativo -->
  <section class="mb-16">
    <GlassesShowcase 
      title="Explore Diferentes Estilos"
      subtitle="Navegue entre as armações mais populares"
    />
  </section>

  <!-- Carrossel de Destaques -->
  <section class="mb-16">
    <GlassesCarousel
      title="Produtos em Destaque"
      products={featuredProducts}
      autoPlay={true}
      interval={4000}
      onProductClick={handleProductClick}
    />
  </section>

  <!-- Recursos do Sistema -->
  <section class="mb-16">
    <SectionHeader
      title="Recursos do Sistema"
      description="Funcionalidades principais do SIS Lens"
    />

    <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="feature-card">
        <div class="feature-icon">🎯</div>
        <h4 class="feature-title">Decisão Inteligente</h4>
        <p class="feature-description">
          Algoritmo que analisa preço, prazo e margem para sugerir a melhor opção
        </p>
      </div>

      <div class="feature-card">
        <div class="feature-icon">⚡</div>
        <h4 class="feature-title">Busca Rápida</h4>
        <p class="feature-description">
          Encontre lentes em segundos com busca inteligente e sugestões automáticas
        </p>
      </div>

      <div class="feature-card">
        <div class="feature-icon">📊</div>
        <h4 class="feature-title">Analytics Avançado</h4>
        <p class="feature-description">
          Dashboards completos com métricas de desempenho e tendências
        </p>
      </div>

      <div class="feature-card">
        <div class="feature-icon">🔐</div>
        <h4 class="feature-title">Segurança Total</h4>
        <p class="feature-description">
          Sistema seguro com autenticação e controle de acesso por perfil
        </p>
      </div>
    </div>
  </section>

  <!-- Design Tokens -->
  <section class="mb-16">
    <SectionHeader
      title="Design System"
      description="Paleta de cores e elementos visuais"
    />

    <div class="bg-white dark:bg-neutral-800 rounded-2xl p-8 shadow-sm">
      <div class="grid md:grid-cols-4 gap-6">
        <!-- Azul Profundo -->
        <div>
          <div class="color-swatch" style="background: #1C3B5A;">
            <span class="color-label">#1C3B5A</span>
          </div>
          <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">
            Azul Profundo
          </p>
          <p class="text-xs text-neutral-500 dark:text-neutral-400">
            Primary / Confiança
          </p>
        </div>

        <!-- Laranja Premium -->
        <div>
          <div class="color-swatch" style="background: #CC6B2F;">
            <span class="color-label">#CC6B2F</span>
          </div>
          <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">
            Laranja Premium
          </p>
          <p class="text-xs text-neutral-500 dark:text-neutral-400">
            Accent / Ação
          </p>
        </div>

        <!-- Dourado Moderno -->
        <div>
          <div class="color-swatch" style="background: #DEA742;">
            <span class="color-label">#DEA742</span>
          </div>
          <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">
            Dourado Moderno
          </p>
          <p class="text-xs text-neutral-500 dark:text-neutral-400">
            Value / Premium
          </p>
        </div>

        <!-- Cinza Neutro -->
        <div>
          <div class="color-swatch" style="background: #E8E0D5;">
            <span class="color-label">#E8E0D5</span>
          </div>
          <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">
            Cinza Neutro
          </p>
          <p class="text-xs text-neutral-500 dark:text-neutral-400">
            Base / Suporte
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- Call to Action -->
  <section class="text-center py-16">
    <h2 class="text-3xl font-bold text-neutral-900 dark:text-neutral-100 mb-4">
      Pronto para explorar mais?
    </h2>
    <p class="text-lg text-neutral-600 dark:text-neutral-400 mb-8 max-w-2xl mx-auto">
      Navegue pela documentação completa dos componentes e descubra todas as possibilidades
    </p>
    <div class="flex gap-4 justify-center flex-wrap">
      <Button variant="primary" on:click={navigateToGlasses}>
        Ver Componentes de Óculos →
      </Button>
      <Button variant="secondary" on:click={() => goto('/dashboard')}>
        Ir para Dashboard
      </Button>
    </div>
  </section>
</Container>

<style>
  .demo-link-card {
    background: white;
    border: 2px solid #e5e7eb;
    border-radius: 1rem;
    padding: 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    transition: all 0.3s ease;
    cursor: pointer;
    text-align: left;
  }

  .demo-link-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
    border-color: #1C3B5A;
  }

  .demo-link-card .arrow {
    font-size: 1.5rem;
    color: #9ca3af;
    transition: all 0.3s ease;
  }

  .demo-link-card:hover .arrow {
    color: #1C3B5A;
    transform: translateX(4px);
  }

  :global(.dark) .demo-link-card {
    background: #1f2937;
    border-color: #374151;
  }

  :global(.dark) .demo-link-card:hover {
    border-color: #CC6B2F;
  }

  .feature-card {
    background: white;
    border-radius: 1rem;
    padding: 2rem;
    text-align: center;
    transition: all 0.3s ease;
    border: 1px solid #e5e7eb;
  }

  .feature-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  }

  .feature-icon {
    font-size: 3rem;
    margin-bottom: 1rem;
  }

  .feature-title {
    font-size: 1.125rem;
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 0.5rem;
  }

  .feature-description {
    font-size: 0.875rem;
    color: #6b7280;
    line-height: 1.5;
  }

  :global(.dark) .feature-card {
    background: #1f2937;
    border-color: #374151;
  }

  :global(.dark) .feature-title {
    color: #f3f4f6;
  }

  :global(.dark) .feature-description {
    color: #9ca3af;
  }

  .color-swatch {
    height: 120px;
    border-radius: 0.75rem;
    display: flex;
    align-items: flex-end;
    justify-content: center;
    padding: 1rem;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .color-label {
    font-family: 'Monaco', 'Courier New', monospace;
    font-size: 0.875rem;
    font-weight: 600;
    color: white;
    background: rgba(0, 0, 0, 0.3);
    padding: 0.25rem 0.75rem;
    border-radius: 0.375rem;
    backdrop-filter: blur(4px);
  }
</style>
