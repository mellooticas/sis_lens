<script lang="ts">
  /**
   * StatsCard Component
   * Card de estatísticas/métricas
   */

  export let title = "";
  export let value: string | number = "";
  export let change: number | undefined = undefined;
  export let icon = "📊";
  export let trend: "up" | "down" | "neutral" = "neutral";
  export let color: "blue" | "green" | "orange" | "gold" | "cyan" | "purple" = "blue";
  export let subtitle: string | undefined = undefined;

  const colors = {
    blue: "bg-primary-50 text-primary-600 dark:bg-primary-800 dark:text-primary-300",
    green:
      "bg-success-light text-success-dark dark:bg-success-dark dark:text-success-light",
    orange:
      "bg-orange-50 text-orange-600 dark:bg-orange-800 dark:text-orange-300",
    gold: "bg-brand-gold-50 text-brand-gold-600 dark:bg-brand-gold-800 dark:text-brand-gold-300",
    cyan: "bg-cyan-50 text-cyan-600 dark:bg-cyan-800 dark:text-cyan-300",
    purple: "bg-purple-50 text-purple-600 dark:bg-purple-800 dark:text-purple-300",
  };
</script>

<div
  class="glass-panel rounded-xl p-6 flex items-start gap-4 hover:shadow-card-hover hover:-translate-y-1 transition-all duration-300"
>
  <!-- Icon -->
  <div
    class="flex items-center justify-center w-14 h-14 rounded-lg {colors[
      color
    ]}"
  >
    {#if $$slots.icon}
      <slot name="icon" />
    {:else}
      <span class="text-2xl">{icon}</span>
    {/if}
  </div>

  <!-- Content -->
  <div class="flex-1">
    <div
      class="text-sm font-medium text-neutral-600 dark:text-neutral-400 mb-1"
    >
      {title}
    </div>
    <div class="text-2xl font-bold text-neutral-900 dark:text-neutral-100 mb-2">
      {value}
    </div>
    
    {#if subtitle}
      <div class="text-xs text-neutral-500 dark:text-neutral-500 mb-2">
        {subtitle}
      </div>
    {/if}

    {#if change !== undefined}
      <div
        class="flex items-center gap-1 text-sm font-medium"
        class:text-success={trend === "up"}
        class:dark:text-success-light={trend === "up"}
        class:text-error={trend === "down"}
        class:dark:text-error-light={trend === "down"}
      >
        {#if trend === "up"}
          <svg
            width="16"
            height="16"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
            />
          </svg>
        {:else if trend === "down"}
          <svg
            width="16"
            height="16"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 17h8m0 0V9m0 8l-8-8-4 4-6-6"
            />
          </svg>
        {/if}
        <span>{Math.abs(change)}%</span>
      </div>
    {/if}
  </div>
</div>
