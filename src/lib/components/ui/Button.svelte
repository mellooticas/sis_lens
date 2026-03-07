<script lang="ts">
  /**
   * Button — SIS Lens Component Contract
   * Variants: default, destructive, outline, secondary, ghost, link
   * Sizes: xs, sm, default, lg, icon
   */
  import type { Snippet } from 'svelte';
  import type { HTMLButtonAttributes } from 'svelte/elements';

  interface Props extends HTMLButtonAttributes {
    variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link' | 'primary' | 'danger' | 'success';
    size?: 'xs' | 'sm' | 'default' | 'lg' | 'icon' | 'md';
    fullWidth?: boolean;
    children?: Snippet;
  }

  let {
    variant = 'default',
    size = 'default',
    fullWidth = false,
    children,
    class: className = '',
    ...restProps
  }: Props = $props();

  const baseClasses = 'inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50';

  const variantClasses: Record<string, string> = {
    default: 'bg-primary text-primary-foreground hover:bg-primary/90',
    primary: 'bg-primary text-primary-foreground hover:bg-primary/90',
    destructive: 'bg-destructive text-white hover:bg-destructive/90',
    danger: 'bg-destructive text-white hover:bg-destructive/90',
    outline: 'border border-input bg-background hover:bg-accent hover:text-accent-foreground',
    secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
    ghost: 'hover:bg-accent hover:text-accent-foreground',
    link: 'text-primary underline-offset-4 hover:underline',
    success: 'bg-success text-white hover:bg-success-dark'
  };

  const sizeClasses: Record<string, string> = {
    xs: 'h-6 px-2 text-xs',
    sm: 'h-8 px-3 text-xs',
    default: 'h-9 px-4 py-2 text-sm',
    md: 'h-9 px-4 py-2 text-sm',
    lg: 'h-10 px-6 text-sm',
    icon: 'size-9'
  };

  let classes = $derived(
    `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${fullWidth ? 'w-full' : ''} ${className}`.trim()
  );
</script>

<button
  class={classes}
  {...restProps}
>
  {#if children}
    {@render children()}
  {/if}
</button>
