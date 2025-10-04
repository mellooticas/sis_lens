<script lang="ts">
  /**
   * Componente Badge BestLens
   * Badges para status e destaques
   */
  
  export let variant: 'primary' | 'success' | 'warning' | 'error' | 'gold' | 'orange' | 'melhor-opcao' | 'promocao' | 'entrega-expressa' = 'primary';
  export let size: 'sm' | 'md' = 'md';
  
  // Classes base
  const baseClasses = 'inline-flex items-center gap-1 rounded-full font-medium';
  
  // Variantes
  const variants = {
    primary: 'bg-brand-blue-100 text-brand-blue-700',
    success: 'bg-success/10 text-success-dark',
    warning: 'bg-warning/10 text-warning-dark',
    error: 'bg-error/10 text-error-dark',
    gold: 'bg-brand-gold-100 text-brand-gold-700',
    orange: 'bg-brand-orange-100 text-brand-orange-700',
    'melhor-opcao': 'bg-brand-gold-500 text-white font-semibold shadow-md',
    'promocao': 'bg-brand-orange-500 text-white',
    'entrega-expressa': 'bg-success text-white'
  };
  
  // Tamanhos
  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-3 py-1 text-xs'
  };
  
  $: classes = `${baseClasses} ${variants[variant]} ${sizes[size]}`;
</script>

<span class={classes} {...$$restProps}>
  <slot />
</span>