<script lang="ts">
  /**
   * Card — Clearix Lens Component Contract
   * Composable card with header/content/footer snippets
   */
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    header?: Snippet;
    children?: Snippet;
    footer?: Snippet;
  }

  let {
    header,
    children,
    footer,
    class: className = '',
    ...restProps
  }: Props = $props();
</script>

<div
  class="bg-card text-card-foreground rounded-xl border border-border shadow-sm {className}"
  {...restProps}
>
  {#if header}
    <div class="px-6 py-4 border-b border-border">
      {@render header()}
    </div>
  {/if}

  {#if children}
    <div class="px-6 py-4">
      {@render children()}
    </div>
  {/if}

  {#if footer}
    <div class="px-6 py-4 border-t border-border">
      {@render footer()}
    </div>
  {/if}
</div>
