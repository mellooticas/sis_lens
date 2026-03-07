<script lang="ts">
  /**
   * Select — SIS Lens Component Contract
   * Styled consistently with Input contract
   */
  import type { HTMLSelectAttributes } from 'svelte/elements';

  interface SelectOption {
    value: string;
    label: string;
  }

  interface Props extends HTMLSelectAttributes {
    label?: string;
    options?: SelectOption[];
    error?: string;
    placeholder?: string;
  }

  let {
    value = $bindable(''),
    label = '',
    options = [],
    error = '',
    required = false,
    id,
    placeholder = '',
    class: className = '',
    ...restProps
  }: Props = $props();

  const uniqueId = id || `select-${Math.random().toString(36).substr(2, 9)}`;

  const baseClasses = 'flex h-10 w-full rounded-md border bg-background px-3 py-2 text-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 appearance-none';

  let selectClasses = $derived(
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

  <div class="relative">
    <select
      id={uniqueId}
      {required}
      bind:value
      class={selectClasses}
      {...restProps}
    >
      {#if placeholder}
        <option value="" disabled={value !== ''}>{placeholder}</option>
      {/if}

      {#each options as option}
        <option value={option.value}>
          {option.label}
        </option>
      {/each}
    </select>

    <!-- Arrow icon -->
    <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
      <svg class="w-4 h-4 text-muted-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </div>
  </div>

  {#if error}
    <p class="text-xs text-destructive mt-1">{error}</p>
  {/if}
</div>
