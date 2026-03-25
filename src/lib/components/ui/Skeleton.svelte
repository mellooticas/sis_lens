<script lang="ts">
  /**
   * Skeleton — Clearix Lens Component Contract
   * bg-muted animate-pulse rounded-md
   */
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    variant?: 'text' | 'title' | 'card' | 'circle' | 'button';
    width?: string;
    height?: string;
    count?: number;
  }

  let {
    variant = 'text',
    width,
    height,
    count = 1,
    class: className = '',
    ...restProps
  }: Props = $props();

  const variantClasses: Record<string, string> = {
    text: 'h-4 w-full',
    title: 'h-8 w-3/4',
    card: 'w-full h-48',
    circle: 'w-12 h-12 rounded-full',
    button: 'h-10 w-24 rounded-md'
  };

  const baseClasses = 'bg-muted animate-pulse rounded-md';
</script>

{#if variant === 'text'}
  {#each Array(count) as _}
    <div
      class="{baseClasses} {variantClasses.text} mb-2 {className}"
      style={width ? `width: ${width}` : ''}
      {...restProps}
    ></div>
  {/each}
{:else if variant === 'circle'}
  <div
    class="{baseClasses} {variantClasses.circle} {className}"
    style={width ? `width: ${width}; height: ${width}` : ''}
    {...restProps}
  ></div>
{:else}
  <div
    class="{baseClasses} {variantClasses[variant]} {className}"
    style="{width ? `width: ${width};` : ''} {height ? `height: ${height};` : ''}"
    {...restProps}
  ></div>
{/if}
