<script lang="ts">
  import type { VCatalogLensGroup } from '$lib/types/database-views';

  export let grupo: VCatalogLensGroup;
  export let variant: 'standard' | 'premium' = 'standard';
  export let compact = false;

  function formatarTexto(texto: string | null | undefined): string {
    return texto ? texto.replace(/_/g, ' ') : '—';
  }

  $: badgeClasses = variant === 'premium'
    ? 'bg-gradient-to-r from-amber-100 to-orange-100 text-amber-800 dark:from-amber-900/30 dark:to-orange-900/30 dark:text-amber-300'
    : 'bg-primary-100 text-primary-800 dark:bg-primary-900 dark:text-primary-200';

  $: badgeText = variant === 'premium' ? 'Premium' : 'Standard';
  $: linkBase = variant === 'premium' ? '/catalogo/premium' : '/catalogo/standard';
</script>

<a
  href="{linkBase}/{grupo.id}"
  class="grupo-card glass-panel rounded-xl hover:shadow-xl transition-all duration-200 hover:scale-[1.02] block"
  class:p-6={!compact}
  class:p-4={compact}
  class:flex={compact}
  class:items-center={compact}
  class:gap-4={compact}
>
  <!-- Header -->
  <div
    class:mb-4={!compact}
    class:flex-shrink-0={compact}
    style={compact ? 'width: 33%;' : ''}
  >
    <h3
      class="font-bold text-gray-900 dark:text-white mb-2 line-clamp-2"
      class:text-lg={!compact}
      class:text-base={compact}
    >
      {grupo.name}
    </h3>
    <div class="flex flex-wrap gap-2">
      {#if grupo.is_premium}
        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">
          ★ Premium
        </span>
      {/if}
      <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {badgeClasses}">
        {badgeText}
      </span>
    </div>
  </div>

  <!-- Especificações Técnicas -->
  <div class="gap-2 mb-4 text-xs flex-1"
       class:grid={!compact}
       class:grid-cols-3={!compact}
       class:flex={compact}
       class:flex-wrap={compact}>
    {#if grupo.material}
    <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
      <div class="text-gray-500 dark:text-gray-400">Material</div>
      <div class="font-medium text-gray-900 dark:text-white">{grupo.material}</div>
    </div>
    {/if}
    {#if grupo.refractive_index !== null && grupo.refractive_index !== undefined}
    <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
      <div class="text-gray-500 dark:text-gray-400">Índice</div>
      <div class="font-medium text-gray-900 dark:text-white">{grupo.refractive_index}</div>
    </div>
    {/if}
    {#if grupo.lens_type}
    <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
      <div class="text-gray-500 dark:text-gray-400">Tipo</div>
      <div class="font-medium text-gray-900 dark:text-white capitalize">
        {formatarTexto(grupo.lens_type)}
      </div>
    </div>
    {/if}
  </div>

  <!-- Status -->
  {#if !grupo.is_active}
    <div class="flex flex-wrap gap-1.5" class:mb-4={!compact}>
      <span class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400">
        Inativo
      </span>
    </div>
  {/if}

</a>

<style>
  .grupo-card {
    @apply w-full max-w-md;
  }

  .line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
</style>
