<script lang="ts">
  /**
   * Badge — Clearix Lens Component Contract
   * Core variants: default, secondary, destructive, outline
   * Domain variants: melhor-opcao, promocao, entrega-expressa, success, warning, info, gold, orange, neutral
   */
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends HTMLAttributes<HTMLSpanElement> {
    variant?:
      | 'default'
      | 'secondary'
      | 'destructive'
      | 'outline'
      | 'success'
      | 'warning'
      | 'info'
      | 'gold'
      | 'orange'
      | 'neutral'
      | 'melhor-opcao'
      | 'promocao'
      | 'entrega-expressa'
      | 'primary';
    size?: 'sm' | 'md';
    children?: Snippet;
  }

  let {
    variant = 'default',
    size = 'md',
    children,
    class: className = '',
    ...restProps
  }: Props = $props();

  const baseClasses = 'inline-flex items-center gap-1 rounded-full font-semibold';

  const variantClasses: Record<string, string> = {
    // Core contract variants
    default: 'bg-primary text-primary-foreground',
    secondary: 'bg-secondary text-secondary-foreground',
    destructive: 'bg-destructive text-white',
    outline: 'border border-border text-foreground bg-transparent',

    // Semantic / domain-specific variants
    primary: 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-400',
    success: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400',
    warning: 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400',
    info: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400',
    gold: 'bg-brand-gold-100 text-brand-gold-700 dark:bg-brand-gold-900/30 dark:text-brand-gold-400',
    orange: 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400',
    neutral: 'bg-muted text-muted-foreground',
    'melhor-opcao': 'bg-brand-gold-500 text-white font-semibold shadow-md',
    promocao: 'bg-orange-500 text-white',
    'entrega-expressa': 'bg-success text-white'
  };

  const sizeClasses: Record<string, string> = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-0.5 text-xs'
  };

  let classes = $derived(
    `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${className}`.trim()
  );
</script>

<span class={classes} {...restProps}>
  {#if children}
    {@render children()}
  {/if}
</span>
