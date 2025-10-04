<script lang="ts">
  /**
   * Container - Wrapper de conteúdo com largura máxima e padding responsivo
   * Substitui "container mx-auto px-4" repetido
   */
  
  export let maxWidth: 'sm' | 'md' | 'lg' | 'xl' | '2xl' | 'full' = 'xl';
  export let padding: 'none' | 'sm' | 'md' | 'lg' = 'md';
  export let className = '';
  
  const maxWidthClasses = {
    sm: 'max-w-screen-sm',
    md: 'max-w-screen-md',
    lg: 'max-w-screen-lg',
    xl: 'max-w-screen-xl',
    '2xl': 'max-w-screen-2xl',
    full: 'max-w-full'
  };
  
  const paddingClasses = {
    none: '',
    sm: 'px-4 py-4',
    md: 'px-4 py-8',
    lg: 'px-6 py-12'
  };
</script>

<div class="mx-auto {maxWidthClasses[maxWidth]} {paddingClasses[padding]} {className}">
  <slot />
</div>