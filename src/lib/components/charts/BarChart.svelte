<script lang="ts">
  export let data: Array<{ label: string; value: number; color: string }> = [];
  export let height: number = 300;
  export let showValues: boolean = true;
  
  $: maxValue = Math.max(...data.map(d => d.value));
  $: sortedData = [...data].sort((a, b) => b.value - a.value);
</script>

<div class="space-y-4">
  {#each sortedData as item}
    {@const percentage = (item.value / maxValue) * 100}
    <div>
      <div class="flex justify-between items-center mb-2">
        <span class="text-sm font-medium text-neutral-700 dark:text-neutral-300">
          {item.label}
        </span>
        {#if showValues}
          <span class="text-sm font-bold text-neutral-900 dark:text-white">
            {item.value.toLocaleString('pt-BR')}
          </span>
        {/if}
      </div>
      <div class="relative">
        <div class="w-full bg-neutral-200 dark:bg-neutral-700 rounded-full h-8 overflow-hidden">
          <div
            class="h-full rounded-full transition-all duration-700 ease-out flex items-center justify-end pr-3"
            style="width: {percentage}%; background: linear-gradient(90deg, {item.color}, {item.color}dd)"
          >
            {#if percentage > 15}
              <span class="text-xs font-bold text-white">
                {percentage.toFixed(0)}%
              </span>
            {/if}
          </div>
        </div>
        {#if percentage <= 15}
          <span class="absolute right-0 top-1/2 -translate-y-1/2 -translate-x-full mr-2 text-xs font-bold text-neutral-600 dark:text-neutral-400">
            {percentage.toFixed(0)}%
          </span>
        {/if}
      </div>
    </div>
  {/each}
</div>
