<script lang="ts">
  export let data: Array<{ label: string; value: number; color: string }> = [];
  export let size: number = 200;
  
  $: total = data.reduce((sum, item) => sum + item.value, 0);
  
  function calculateArcs() {
    let currentAngle = -90; // Start from top
    const radius = size / 2;
    const innerRadius = radius * 0.6; // Donut hole
    
    return data.map(item => {
      const percentage = (item.value / total) * 100;
      const angle = (item.value / total) * 360;
      const startAngle = currentAngle;
      const endAngle = currentAngle + angle;
      
      const startRad = (startAngle * Math.PI) / 180;
      const endRad = (endAngle * Math.PI) / 180;
      
      const x1 = radius + radius * Math.cos(startRad);
      const y1 = radius + radius * Math.sin(startRad);
      const x2 = radius + radius * Math.cos(endRad);
      const y2 = radius + radius * Math.sin(endRad);
      
      const x3 = radius + innerRadius * Math.cos(endRad);
      const y3 = radius + innerRadius * Math.sin(endRad);
      const x4 = radius + innerRadius * Math.cos(startRad);
      const y4 = radius + innerRadius * Math.sin(startRad);
      
      const largeArc = angle > 180 ? 1 : 0;
      
      const pathData = [
        `M ${x1} ${y1}`,
        `A ${radius} ${radius} 0 ${largeArc} 1 ${x2} ${y2}`,
        `L ${x3} ${y3}`,
        `A ${innerRadius} ${innerRadius} 0 ${largeArc} 0 ${x4} ${y4}`,
        'Z'
      ].join(' ');
      
      currentAngle += angle;
      
      return {
        path: pathData,
        color: item.color,
        label: item.label,
        value: item.value,
        percentage: percentage.toFixed(1)
      };
    });
  }
  
  $: arcs = calculateArcs();
</script>

<div class="flex items-center gap-6">
  <svg width={size} height={size} class="flex-shrink-0">
    {#each arcs as arc}
      <path
        d={arc.path}
        fill={arc.color}
        class="transition-opacity duration-200 hover:opacity-80"
      />
    {/each}
    <text
      x={size / 2}
      y={size / 2}
      text-anchor="middle"
      dominant-baseline="middle"
      class="text-2xl font-bold fill-neutral-700 dark:fill-neutral-300"
    >
      {data.length}
    </text>
  </svg>
  
  <div class="flex-1 space-y-2">
    {#each arcs as arc}
      <div class="flex items-center gap-3">
        <div class="w-4 h-4 rounded-sm flex-shrink-0" style="background-color: {arc.color}"></div>
        <span class="text-sm text-neutral-700 dark:text-neutral-300 flex-1">{arc.label}</span>
        <span class="text-sm font-semibold text-neutral-900 dark:text-white">{arc.percentage}%</span>
        <span class="text-xs text-neutral-500 dark:text-neutral-400">({arc.value})</span>
      </div>
    {/each}
  </div>
</div>
