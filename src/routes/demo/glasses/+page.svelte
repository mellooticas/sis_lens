<!--
  👓 Demo - Componentes de Óculos
  Página de demonstração dos componentes visuais de armações
-->
<script lang="ts">
  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import GlassesIcon from "$lib/components/ui/GlassesIcon.svelte";
  import GlassesShowcase from "$lib/components/ui/GlassesShowcase.svelte";
  import GlassesCard from "$lib/components/ui/GlassesCard.svelte";

  // Dados de exemplo para os cards
  const glassesProducts = [
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
    },
    {
      id: '6',
      name: 'Sport Aviator Pro',
      style: 'aviator' as const,
      brand: 'Transitions',
      price: 699.90,
      color: '#000000',
      colors: ['#000000', '#4b5563', '#CC6B2F'],
      rating: 4.5,
      stock: false
    }
  ];

  function handleProductClick(product: typeof glassesProducts[0]) {
    console.log('Produto clicado:', product);
    alert(`Você clicou em: ${product.name}`);
  }
</script>

<svelte:head>
  <title>Demo - Componentes de Óculos | SIS Lens</title>
</svelte:head>

<Container>
  <!-- Hero -->
  <PageHero
    title="👓 Componentes de Óculos"
    description="Demonstração dos componentes visuais de armações disponíveis no SIS Lens"
  />

  <!-- Showcase Principal -->
  <section class="mb-16">
    <GlassesShowcase 
      title="Escolha seu Estilo Preferido"
      subtitle="Navegue entre diferentes modelos de armações"
    />
  </section>

  <!-- Galeria de Ícones -->
  <section class="mb-16">
    <SectionHeader
      title="Ícones de Armações"
      description="Diferentes tamanhos e estilos disponíveis"
    />

    <div class="bg-white dark:bg-neutral-800 rounded-2xl p-8 shadow-sm">
      <!-- Tamanhos -->
      <div class="mb-12">
        <h3 class="text-lg font-semibold mb-6 text-neutral-800 dark:text-neutral-200">
          Tamanhos Disponíveis
        </h3>
        <div class="flex items-end gap-8 flex-wrap">
          <div class="text-center">
            <GlassesIcon style="wayfarer" size="sm" />
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-2">Small (24px)</p>
          </div>
          <div class="text-center">
            <GlassesIcon style="wayfarer" size="md" />
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-2">Medium (32px)</p>
          </div>
          <div class="text-center">
            <GlassesIcon style="wayfarer" size="lg" />
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-2">Large (48px)</p>
          </div>
          <div class="text-center">
            <GlassesIcon style="wayfarer" size="xl" />
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-2">XLarge (64px)</p>
          </div>
        </div>
      </div>

      <!-- Estilos -->
      <div>
        <h3 class="text-lg font-semibold mb-6 text-neutral-800 dark:text-neutral-200">
          Estilos de Armações
        </h3>
        <div class="grid grid-cols-2 md:grid-cols-5 gap-8">
          <div class="text-center">
            <GlassesIcon style="wayfarer" size="lg" color="#1C3B5A" />
            <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">Wayfarer</p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400">Clássico</p>
          </div>
          <div class="text-center">
            <GlassesIcon style="aviator" size="lg" color="#CC6B2F" />
            <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">Aviator</p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400">Piloto</p>
          </div>
          <div class="text-center">
            <GlassesIcon style="round" size="lg" color="#DEA742" />
            <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">Round</p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400">Redondo</p>
          </div>
          <div class="text-center">
            <GlassesIcon style="rectangular" size="lg" color="#3b82f6" />
            <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">Rectangular</p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400">Retangular</p>
          </div>
          <div class="text-center">
            <GlassesIcon style="cat-eye" size="lg" color="#ec4899" />
            <p class="text-sm font-medium text-neutral-700 dark:text-neutral-300 mt-3">Cat Eye</p>
            <p class="text-xs text-neutral-500 dark:text-neutral-400">Gatinho</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Cards de Produtos -->
  <section class="mb-16">
    <SectionHeader
      title="Catálogo de Produtos"
      description="Cards interativos com informações completas"
    />

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each glassesProducts as product}
        <GlassesCard
          {...product}
          onClick={() => handleProductClick(product)}
        />
      {/each}
    </div>
  </section>

  <!-- Exemplo de Integração -->
  <section class="mb-16">
    <SectionHeader
      title="Exemplo de Integração"
      description="Como usar os componentes em seu código"
    />

    <div class="bg-neutral-900 text-neutral-100 rounded-2xl p-6 overflow-x-auto">
      <pre class="text-sm"><code>{`<script>
  import GlassesIcon from '$lib/components/ui/GlassesIcon.svelte';
  import GlassesCard from '$lib/components/ui/GlassesCard.svelte';
  import GlassesShowcase from '$lib/components/ui/GlassesShowcase.svelte';
</script>

<!-- Ícone simples -->
<GlassesIcon style="wayfarer" size="lg" color="#1C3B5A" />

<!-- Showcase interativo -->
<GlassesShowcase 
  title="Escolha seu Estilo"
  animate={true}
/>

<!-- Card de produto -->
<GlassesCard
  name="Classic Wayfarer"
  style="wayfarer"
  brand="Essilor"
  price={459.90}
  rating={4.8}
  featured={true}
  onClick={() => console.log('Clicado!')}
/>`}</code></pre>
    </div>
  </section>

  <!-- Dicas de Uso -->
  <section class="mb-16">
    <SectionHeader
      title="Dicas de Uso"
      description="Melhores práticas para utilizar os componentes"
    />

    <div class="grid md:grid-cols-2 gap-6">
      <div class="bg-blue-50 dark:bg-blue-900/20 border-2 border-blue-200 dark:border-blue-800 rounded-xl p-6">
        <div class="flex items-start gap-3">
          <span class="text-2xl">💡</span>
          <div>
            <h4 class="font-bold text-blue-900 dark:text-blue-100 mb-2">Escolha o Estilo Certo</h4>
            <p class="text-sm text-blue-800 dark:text-blue-200">
              Use <code class="bg-blue-100 dark:bg-blue-800 px-1 rounded">wayfarer</code> para 
              armações clássicas, <code class="bg-blue-100 dark:bg-blue-800 px-1 rounded">aviator</code> 
              para estilo piloto, e <code class="bg-blue-100 dark:bg-blue-800 px-1 rounded">round</code> 
              para looks vintage.
            </p>
          </div>
        </div>
      </div>

      <div class="bg-green-50 dark:bg-green-900/20 border-2 border-green-200 dark:border-green-800 rounded-xl p-6">
        <div class="flex items-start gap-3">
          <span class="text-2xl">🎨</span>
          <div>
            <h4 class="font-bold text-green-900 dark:text-green-100 mb-2">Personalize as Cores</h4>
            <p class="text-sm text-green-800 dark:text-green-200">
              Utilize a paleta do design system para manter consistência visual:
              <code class="bg-green-100 dark:bg-green-800 px-1 rounded">#1C3B5A</code> (azul),
              <code class="bg-green-100 dark:bg-green-800 px-1 rounded">#CC6B2F</code> (laranja).
            </p>
          </div>
        </div>
      </div>

      <div class="bg-purple-50 dark:bg-purple-900/20 border-2 border-purple-200 dark:border-purple-800 rounded-xl p-6">
        <div class="flex items-start gap-3">
          <span class="text-2xl">⚡</span>
          <div>
            <h4 class="font-bold text-purple-900 dark:text-purple-100 mb-2">Performance</h4>
            <p class="text-sm text-purple-800 dark:text-purple-200">
              Os ícones são SVG inline, garantindo carregamento rápido e escalabilidade perfeita 
              em qualquer resolução.
            </p>
          </div>
        </div>
      </div>

      <div class="bg-orange-50 dark:bg-orange-900/20 border-2 border-orange-200 dark:border-orange-800 rounded-xl p-6">
        <div class="flex items-start gap-3">
          <span class="text-2xl">♿</span>
          <div>
            <h4 class="font-bold text-orange-900 dark:text-orange-100 mb-2">Acessibilidade</h4>
            <p class="text-sm text-orange-800 dark:text-orange-200">
              Todos os componentes são navegáveis por teclado e incluem feedback visual apropriado 
              para interações.
            </p>
          </div>
        </div>
      </div>
    </div>
  </section>
</Container>

<style>
  code {
    font-family: 'Monaco', 'Courier New', monospace;
    font-size: 0.875em;
  }

  pre {
    overflow-x: auto;
    line-height: 1.6;
  }
</style>
