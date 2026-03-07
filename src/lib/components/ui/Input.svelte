<script lang="ts">
  /**
   * Input — SIS Lens Component Contract
   * h-10 rounded-md border border-input bg-background px-3 py-2 text-sm
   */
  import type { HTMLInputAttributes } from 'svelte/elements';

  interface Props extends HTMLInputAttributes {
    label?: string;
    error?: string;
  }

  let {
    value = $bindable(''),
    label = '',
    error = '',
    required = false,
    id,
    class: className = '',
    ...restProps
  }: Props = $props();

  const uniqueId = id || `input-${Math.random().toString(36).substr(2, 9)}`;

  const baseClasses = 'flex h-10 w-full rounded-md border bg-background px-3 py-2 text-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50';

  let inputClasses = $derived(
    `${baseClasses} ${
      error
        ? 'border-destructive focus-visible:ring-destructive/50'
        : 'border-input'
    } ${className}`.trim()
  );
</script>

<div class="space-y-1.5">
  {#if label}
    <label
      for={uniqueId}
      class="block text-sm font-medium text-foreground"
    >
      {label}
      {#if required}
        <span class="text-destructive ml-1">*</span>
      {/if}
    </label>
  {/if}

  <input
    id={uniqueId}
    {required}
    bind:value
    class={inputClasses}
    {...restProps}
  />

  {#if error}
    <p class="text-xs text-destructive mt-1">{error}</p>
  {/if}
</div>
