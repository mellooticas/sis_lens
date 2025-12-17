<script lang="ts">
  /**
   * Painel de Configurações de Acessibilidade
   * Controle completo de tema, contraste e cores
   */
  
  import { onMount } from 'svelte';
  import { theme } from '$lib/stores/theme';
  import { contrastStore, colorThemeStore } from '$lib/stores/colorSystem';
  import ContrastControl from './ContrastControl.svelte';
  import ThemeToggle from './ThemeToggle.svelte';
  import { getContrast, meetsWCAG } from '$lib/utils/colorSystem';
  
  export let isOpen = false;
  
  let mounted = false;
  let currentTheme: 'light' | 'dark' = 'light';
  
  // Cores customizáveis
  let customPrimary = '#1c3b5a';
  let customSecondary = '#d4af37';
  let customBackground = '#ffffff';
  let customText = '#000000';
  
  // Informações de contraste
  let contrastInfo = {
    ratio: 21,
    meetsAA: true,
    meetsAAA: true
  };
  
  onMount(() => {
    theme.subscribe(t => {
      currentTheme = t;
    });
    
    contrastStore.init();
    colorThemeStore.init();
    mounted = true;
    
    updateContrastInfo();
  });
  
  function updateContrastInfo() {
    const wcag = meetsWCAG(customText, customBackground, 'AAA');
    contrastInfo = {
      ratio: wcag.contrast,
      meetsAA: wcag.normalText,
      meetsAAA: getContrast(customText, customBackground) >= 7
    };
  }
  
  function handleColorChange() {
    updateContrastInfo();
    colorThemeStore.setTheme({
      primary: customPrimary,
      secondary: customSecondary,
      accent: '#3b82f6',
      success: '#10b981',
      warning: '#f59e0b',
      error: '#ef4444',
    });
  }
  
  function resetColors() {
    customPrimary = '#1c3b5a';
    customSecondary = '#d4af37';
    customBackground = currentTheme === 'light' ? '#ffffff' : '#0f172a';
    customText = currentTheme === 'light' ? '#000000' : '#ffffff';
    handleColorChange();
  }
</script>

{#if mounted && isOpen}
  <div 
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
    on:click={() => isOpen = false}
  >
    <div 
      class="
        w-full max-w-2xl max-h-[90vh] overflow-y-auto
        bg-white dark:bg-neutral-900 
        rounded-2xl shadow-2xl
        border border-neutral-200 dark:border-neutral-700
        m-4
      "
      on:click|stopPropagation
    >
      <!-- Header -->
      <div class="sticky top-0 z-10 bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-700 p-6">
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-2xl font-bold text-neutral-900 dark:text-neutral-100">
              ⚙️ Configurações de Acessibilidade
            </h2>
            <p class="text-sm text-neutral-600 dark:text-neutral-400 mt-1">
              Personalize cores, contraste e tema para melhor experiência
            </p>
          </div>
          <button
            on:click={() => isOpen = false}
            class="p-2 rounded-lg hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
      
      <!-- Content -->
      <div class="p-6 space-y-8">
        <!-- Tema Claro/Escuro -->
        <section>
          <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-4 flex items-center gap-2">
            🌓 Modo de Tema
          </h3>
          <div class="flex items-center justify-between p-4 bg-neutral-50 dark:bg-neutral-800 rounded-xl">
            <div>
              <div class="font-medium text-neutral-900 dark:text-neutral-100">
                Tema {currentTheme === 'light' ? 'Claro' : 'Escuro'}
              </div>
              <div class="text-sm text-neutral-600 dark:text-neutral-400">
                Alterne entre modo claro e escuro
              </div>
            </div>
            <ThemeToggle size="md" />
          </div>
        </section>
        
        <!-- Contraste -->
        <section>
          <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-4 flex items-center gap-2">
            ◐ Nível de Contraste
          </h3>
          <ContrastControl />
        </section>
        
        <!-- Cores Customizadas -->
        <section>
          <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-4 flex items-center gap-2">
            🎨 Cores Personalizadas
          </h3>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Cor Primária -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300">
                Cor Primária
              </label>
              <div class="flex gap-2">
                <input
                  type="color"
                  bind:value={customPrimary}
                  on:change={handleColorChange}
                  class="w-12 h-12 rounded-lg cursor-pointer border-2 border-neutral-300 dark:border-neutral-600"
                />
                <input
                  type="text"
                  bind:value={customPrimary}
                  on:input={handleColorChange}
                  class="flex-1 px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-600 bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
                  placeholder="#1c3b5a"
                />
              </div>
              <div class="h-8 rounded-lg" style="background-color: {customPrimary}"></div>
            </div>
            
            <!-- Cor Secundária -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300">
                Cor Secundária (Ouro)
              </label>
              <div class="flex gap-2">
                <input
                  type="color"
                  bind:value={customSecondary}
                  on:change={handleColorChange}
                  class="w-12 h-12 rounded-lg cursor-pointer border-2 border-neutral-300 dark:border-neutral-600"
                />
                <input
                  type="text"
                  bind:value={customSecondary}
                  on:input={handleColorChange}
                  class="flex-1 px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-600 bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
                  placeholder="#d4af37"
                />
              </div>
              <div class="h-8 rounded-lg" style="background-color: {customSecondary}"></div>
            </div>
            
            <!-- Fundo -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300">
                Cor de Fundo
              </label>
              <div class="flex gap-2">
                <input
                  type="color"
                  bind:value={customBackground}
                  on:change={updateContrastInfo}
                  class="w-12 h-12 rounded-lg cursor-pointer border-2 border-neutral-300 dark:border-neutral-600"
                />
                <input
                  type="text"
                  bind:value={customBackground}
                  on:input={updateContrastInfo}
                  class="flex-1 px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-600 bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
                  placeholder="#ffffff"
                />
              </div>
              <div class="h-8 rounded-lg border-2 border-neutral-300 dark:border-neutral-600" style="background-color: {customBackground}"></div>
            </div>
            
            <!-- Texto -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300">
                Cor de Texto
              </label>
              <div class="flex gap-2">
                <input
                  type="color"
                  bind:value={customText}
                  on:change={updateContrastInfo}
                  class="w-12 h-12 rounded-lg cursor-pointer border-2 border-neutral-300 dark:border-neutral-600"
                />
                <input
                  type="text"
                  bind:value={customText}
                  on:input={updateContrastInfo}
                  class="flex-1 px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-600 bg-white dark:bg-neutral-800 text-neutral-900 dark:text-neutral-100"
                  placeholder="#000000"
                />
              </div>
              <div class="h-8 rounded-lg border-2 border-neutral-300 dark:border-neutral-600" style="background-color: {customText}"></div>
            </div>
          </div>
          
          <!-- Análise de Contraste -->
          <div class="mt-4 p-4 rounded-xl bg-gradient-to-r from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 border border-blue-200 dark:border-blue-800">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-semibold text-neutral-900 dark:text-neutral-100">
                Contraste Texto/Fundo:
              </span>
              <span class="text-2xl font-bold text-brand-blue-600 dark:text-brand-blue-400">
                {contrastInfo.ratio}:1
              </span>
            </div>
            
            <div class="grid grid-cols-2 gap-2 text-xs">
              <div class="flex items-center gap-2 p-2 rounded bg-white/50 dark:bg-black/20">
                {#if contrastInfo.meetsAA}
                  <span class="text-green-600 dark:text-green-400">✓</span>
                {:else}
                  <span class="text-red-600 dark:text-red-400">✗</span>
                {/if}
                <span class="text-neutral-700 dark:text-neutral-300">WCAG AA</span>
              </div>
              
              <div class="flex items-center gap-2 p-2 rounded bg-white/50 dark:bg-black/20">
                {#if contrastInfo.meetsAAA}
                  <span class="text-green-600 dark:text-green-400">✓</span>
                {:else}
                  <span class="text-red-600 dark:text-red-400">✗</span>
                {/if}
                <span class="text-neutral-700 dark:text-neutral-300">WCAG AAA</span>
              </div>
            </div>
            
            <!-- Preview -->
            <div class="mt-3 p-3 rounded-lg" style="background-color: {customBackground}; color: {customText}">
              <p class="text-sm font-medium mb-1">Preview de Texto</p>
              <p class="text-xs">Este é um exemplo de como o texto aparecerá com as cores selecionadas.</p>
            </div>
          </div>
          
          <button
            on:click={resetColors}
            class="mt-4 w-full px-4 py-2 rounded-lg border border-neutral-300 dark:border-neutral-600 hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors text-sm font-medium text-neutral-700 dark:text-neutral-300"
          >
            🔄 Restaurar Cores Padrão
          </button>
        </section>
      </div>
      
      <!-- Footer -->
      <div class="sticky bottom-0 bg-white dark:bg-neutral-900 border-t border-neutral-200 dark:border-neutral-700 p-6">
        <div class="flex items-center justify-between">
          <div class="text-xs text-neutral-500 dark:text-neutral-400">
            💡 As configurações são salvas automaticamente
          </div>
          <button
            on:click={() => isOpen = false}
            class="px-6 py-2 rounded-lg bg-brand-blue-500 hover:bg-brand-blue-600 text-white font-medium transition-colors"
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}
