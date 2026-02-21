<script lang="ts">
  /**
   * Controle de Contraste e Acessibilidade
   * Permite ajustar níveis de contraste para melhor legibilidade
   */
  
  import { onMount } from 'svelte';
  import { 
    type ContrastLevel, 
    applyContrastLevel, 
    getSavedContrastLevel 
  } from '$lib/utils/colorSystem';
  
  let currentLevel: ContrastLevel = 'normal';
  let mounted = false;
  
  const levels: { value: ContrastLevel; label: string; description: string }[] = [
    { 
      value: 'normal', 
      label: 'Normal', 
      description: 'Contraste padrão' 
    },
    { 
      value: 'medium', 
      label: 'Médio', 
      description: 'Contraste aumentado' 
    },
    { 
      value: 'high', 
      label: 'Alto', 
      description: 'Alto contraste' 
    },
    { 
      value: 'maximum', 
      label: 'Máximo', 
      description: 'Contraste máximo (WCAG AAA)' 
    },
  ];
  
  onMount(() => {
    currentLevel = getSavedContrastLevel();
    applyContrastLevel(currentLevel);
    mounted = true;
  });
  
  function handleLevelChange(level: ContrastLevel) {
    currentLevel = level;
    applyContrastLevel(level);
  }
</script>

{#if mounted}
  <div class="contrast-control">
    <div class="mb-3">
      <h3 class="text-sm font-semibold text-neutral-900 dark:text-neutral-100 mb-1">
        Contraste
      </h3>
      <p class="text-xs text-neutral-600 dark:text-neutral-400">
        Ajuste o contraste para melhor legibilidade
      </p>
    </div>
    
    <div class="space-y-2">
      {#each levels as level}
        <button
          on:click={() => handleLevelChange(level.value)}
          class="
            w-full flex items-center justify-between p-3 rounded-lg
            border-2 transition-all duration-200
            {currentLevel === level.value
              ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20'
              : 'border-neutral-200 dark:border-neutral-700 hover:border-neutral-300 dark:hover:border-neutral-600'}
          "
        >
          <div class="flex items-center gap-3">
            <!-- Radio indicator -->
            <div class="
              w-5 h-5 rounded-full border-2 flex items-center justify-center
              {currentLevel === level.value
                ? 'border-primary-500 bg-primary-500'
                : 'border-neutral-300 dark:border-neutral-600'}
            ">
              {#if currentLevel === level.value}
                <div class="w-2 h-2 rounded-full bg-white"></div>
              {/if}
            </div>
            
            <div class="text-left">
              <div class="text-sm font-medium text-neutral-900 dark:text-neutral-100">
                {level.label}
              </div>
              <div class="text-xs text-neutral-600 dark:text-neutral-400">
                {level.description}
              </div>
            </div>
          </div>
          
          <!-- Visual indicator bars -->
          <div class="flex gap-0.5">
            {#each Array(4) as _, i}
              <div 
                class="w-1 h-6 rounded-full transition-all duration-200
                  {i < levels.findIndex(l => l.value === level.value) + 1
                    ? 'bg-primary-500'
                    : 'bg-neutral-200 dark:bg-neutral-700'}"
              ></div>
            {/each}
          </div>
        </button>
      {/each}
    </div>
    
    <!-- Preview de contraste -->
    <div class="mt-4 p-4 rounded-lg bg-neutral-100 dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700">
      <div class="text-xs font-semibold mb-2 text-neutral-700 dark:text-neutral-300">
        Preview:
      </div>
      <div class="space-y-2">
        <div class="text-sm text-neutral-900 dark:text-neutral-100">
          Texto normal em {currentLevel}
        </div>
        <div class="text-xs text-neutral-600 dark:text-neutral-400">
          Texto secundário em {currentLevel}
        </div>
      </div>
    </div>
  </div>
{/if}

<style>
  .contrast-control {
    @apply w-full;
  }
</style>
