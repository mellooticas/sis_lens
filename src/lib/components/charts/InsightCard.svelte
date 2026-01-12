<script lang="ts">
  export let title: string;
  export let insight: string;
  export let icon: string = '💡';
  export let type: 'success' | 'warning' | 'info' | 'danger' = 'info';
  
  const typeClasses = {
    success: 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800 text-green-800 dark:text-green-200',
    warning: 'bg-amber-50 dark:bg-amber-900/20 border-amber-200 dark:border-amber-800 text-amber-800 dark:text-amber-200',
    info: 'bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800 text-blue-800 dark:text-blue-200',
    danger: 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800 text-red-800 dark:text-red-200'
  };
</script>

<div class="rounded-xl border-2 p-4 {typeClasses[type]}">
  <div class="flex items-start gap-3">
    <span class="text-2xl flex-shrink-0">{icon}</span>
    <div class="flex-1">
      <h4 class="font-bold text-sm mb-1">{title}</h4>
      <p class="text-sm opacity-90">{insight}</p>
    </div>
  </div>
</div>
