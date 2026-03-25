<script lang="ts">
  export let size = 32;
  export let primary = "#1A3A5C";
  export let accent = "#06B6D4";
  export let moduleName = "Hub";
  export let variant: "icon" | "horizontal" | "stacked" | "lens" = "horizontal";

  let className = "";
  export { className as class };

  // Lens variant overrides
  $: effectiveAccent = variant === "lens" ? "#14B8A6" : accent;
  $: effectiveModuleName = variant === "lens" ? "Lens" : moduleName;
</script>

{#if variant === "icon"}
  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" width={size} height={size} {...$$restProps}>
    <circle cx="85" cy="50" r="7" fill={effectiveAccent} />
    <path d="M 74.75 25.25 A 35 35 0 1 0 74.75 74.75" stroke={primary} stroke-width="14" stroke-linecap="round" />
  </svg>
{:else if variant === "horizontal" || variant === "lens"}
  <div class="flex items-center gap-2 {className}">
    <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" width={size} height={size}>
      <circle cx="85" cy="50" r="7" fill={effectiveAccent} />
      <path d="M 74.75 25.25 A 35 35 0 1 0 74.75 74.75" stroke={primary} stroke-width="14" stroke-linecap="round" />
    </svg>
    <div class="flex flex-col leading-tight">
      <span class="font-headline font-semibold text-sm tracking-tight" style="color: {primary}">
        Clearix <span class="font-normal">{effectiveModuleName}</span>
      </span>
    </div>
  </div>
{:else if variant === "stacked"}
  <div class="flex flex-col items-center gap-1.5 {className}">
    <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" width={size} height={size}>
      <circle cx="85" cy="50" r="7" fill={effectiveAccent} />
      <path d="M 74.75 25.25 A 35 35 0 1 0 74.75 74.75" stroke={primary} stroke-width="14" stroke-linecap="round" />
    </svg>
    <span class="font-headline font-semibold text-base tracking-tight" style="color: {primary}">
      Clearix <span class="font-normal">{effectiveModuleName}</span>
    </span>
  </div>
{/if}
