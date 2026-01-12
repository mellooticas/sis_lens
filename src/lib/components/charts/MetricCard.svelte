<script lang="ts">
  export let title: string;
  export let value: string | number;
  export let trend: 'up' | 'down' | 'neutral' = 'neutral';
  export let trendValue: string = '';
  export let icon: string = '📊';
  export let color: 'blue' | 'green' | 'amber' | 'purple' | 'red' = 'blue';
  
  const colorClasses = {
    blue: 'from-blue-500 to-blue-600',
    green: 'from-green-500 to-green-600',
    amber: 'from-amber-500 to-amber-600',
    purple: 'from-purple-500 to-purple-600',
    red: 'from-red-500 to-red-600'
  };
  
  const trendColors = {
    up: 'text-green-600 dark:text-green-400',
    down: 'text-red-600 dark:text-red-400',
    neutral: 'text-neutral-600 dark:text-neutral-400'
  };
</script>

<div class="bg-white dark:bg-neutral-800 rounded-xl shadow-lg border border-neutral-200 dark:border-neutral-700 overflow-hidden">
  <div class="bg-gradient-to-r {colorClasses[color]} px-4 py-3">
    <div class="flex items-center gap-2 text-white">
      <span class="text-2xl">{icon}</span>
      <span class="text-sm font-medium opacity-90">{title}</span>
    </div>
  </div>
  <div class="p-6">
    <div class="text-3xl font-bold text-neutral-900 dark:text-white mb-2">
      {value}
    </div>
    {#if trendValue}
      <div class="flex items-center gap-2">
        {#if trend === 'up'}
          <span class="text-lg">📈</span>
        {:else if trend === 'down'}
          <span class="text-lg">📉</span>
        {:else}
          <span class="text-lg">➡️</span>
        {/if}
        <span class="text-sm {trendColors[trend]} font-medium">
          {trendValue}
        </span>
      </div>
    {/if}
  </div>
</div>
