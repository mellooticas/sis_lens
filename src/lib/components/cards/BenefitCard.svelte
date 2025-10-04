 <script lang="ts">
  /**
   * BenefitCard - Card de benefício/feature
   * Usado em seções de destaque de valor
   */
  
  export let icon = '✨';
  export let title = '';
  export let description = '';
  export let alignment: 'left' | 'center' = 'center';
</script>

<div 
  class="space-y-2"
  class:text-center={alignment === 'center'}
  class:text-left={alignment === 'left'}
>
  <!-- Icon -->
  <div class="text-3xl mb-2">
    {icon}
  </div>
  
  <!-- Title -->
  <h4 class="font-semibold text-neutral-900 dark:text-neutral-100">
    {title}
  </h4>
  
  <!-- Description -->
  <p class="text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">
    {description}
  </p>
</div>