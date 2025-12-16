<script lang="ts">
  /**
   * Componente Button SIS Lens
   * Botões padronizados com variantes
   */
  
  export let variant: 'primary' | 'secondary' | 'ghost' | 'success' | 'danger' = 'primary';
  export let size: 'sm' | 'md' | 'lg' = 'md';
  export let disabled = false;
  export let fullWidth = false;
  export let type: 'button' | 'submit' | 'reset' = 'button';
  
  // Classes base
  const baseClasses = 'inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed';
  
  // Variantes de estilo
  const variants = {
    primary: 'bg-brand-blue-500 dark:bg-brand-blue-400 text-white hover:bg-brand-blue-600 dark:hover:bg-brand-blue-500 focus:ring-brand-blue-500 dark:focus:ring-brand-blue-400',
    secondary: 'bg-neutral-200 dark:bg-neutral-700 text-neutral-900 dark:text-neutral-100 hover:bg-neutral-300 dark:hover:bg-neutral-600 focus:ring-neutral-400 dark:focus:ring-neutral-500',
    ghost: 'bg-transparent text-neutral-700 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800',
    success: 'bg-success dark:bg-success-dark text-white hover:bg-success-dark dark:hover:bg-success focus:ring-success dark:focus:ring-success-light',
    danger: 'bg-error dark:bg-error-dark text-white hover:bg-error-dark dark:hover:bg-error focus:ring-error dark:focus:ring-error-light'
  };
  
  // Tamanhos
  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-sm',
    lg: 'px-6 py-3 text-base'
  };
  
  $: classes = `${baseClasses} ${variants[variant]} ${sizes[size]} ${fullWidth ? 'w-full' : ''}`;
</script>

<button
  {type}
  {disabled}
  class={classes}
  on:click
  on:mouseenter
  on:mouseleave
  {...$$restProps}
>
  <slot />
</button>