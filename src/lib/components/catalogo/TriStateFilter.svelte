<script lang="ts">
  import { createEventDispatcher } from "svelte";

  export let label: string;
  export let value: boolean | null = null;
  export let count: number | null = null;

  const dispatch = createEventDispatcher<{ change: boolean | null }>();

  function cycle() {
    value = value === null ? true : value === true ? false : null;
    dispatch("change", value);
  }

  $: title =
    value === true
      ? `${label}: obrigatório (clique para excluir)`
      : value === false
      ? `${label}: excluído (clique para limpar)`
      : `${label}: indiferente (clique para exigir)`;
</script>

<button
  type="button"
  on:click={cycle}
  {title}
  aria-label={title}
  class="inline-flex items-center gap-2 rounded-lg border px-3 py-2 text-sm font-medium transition-colors
    {value === true
      ? 'border-green-600 bg-green-600 text-white hover:bg-green-700'
      : value === false
      ? 'border-red-600 bg-red-600 text-white hover:bg-red-700'
      : 'border-border bg-muted text-foreground hover:bg-accent'}"
>
  <span
    class="h-2 w-2 rounded-full
      {value === true || value === false ? 'bg-white' : 'bg-muted-foreground/40'}"
  />
  <span>{label}</span>
  {#if count !== null}
    <span
      class="text-xs px-1.5 py-0.5 rounded-full
        {value === null ? 'bg-background/50 text-muted-foreground' : 'bg-white/20 text-white'}"
    >
      {count}
    </span>
  {/if}
  {#if value === false}
    <span class="text-xs leading-none">✕</span>
  {/if}
</button>
