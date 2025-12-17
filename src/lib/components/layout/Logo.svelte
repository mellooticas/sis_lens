<script lang="ts">
  import { cn } from "$lib/utils";

  export let variant: "full" | "icon" | "text" = "full";
  export let size: "sm" | "md" | "lg" | "xl" = "md";
  export let theme: "auto" | "light" | "dark" = "auto";

  let className = "";
  export { className as class };

  const sizeClasses = {
    sm: "h-8",
    md: "h-12",
    lg: "h-16",
    xl: "h-20",
  };

  const textSizeClasses = {
    sm: "text-lg",
    md: "text-2xl",
    lg: "text-3xl",
    xl: "text-4xl",
  };

  const themeClasses = {
    auto: "text-brand-blue-500 dark:text-white",
    light: "text-brand-blue-500",
    dark: "text-white",
  };
</script>

<div class={cn("flex items-center gap-2", className)}>
  {#if variant === "icon"}
    <!-- Apenas ícone - usa sis_lens_icon.svg -->
    <img
      src="/sis_lens_icon.svg"
      alt="SIS Lens"
      class={cn("object-contain", sizeClasses[size])}
    />
  {:else if variant === "full"}
    <!-- Logo completo - usa SISlens.svg -->
    <img
      src="/SISlens.svg"
      alt="SIS Lens Intelligence"
      class={cn("object-contain", sizeClasses[size])}
    />
  {:else if variant === "text"}
    <!-- Apenas texto -->
    <div class="flex flex-col">
      <h1
        class={cn(
          "font-headline font-bold leading-tight tracking-tight flex items-center",
          textSizeClasses[size],
          themeClasses[theme],
        )}
      >
        SIS<span class="text-brand-gold-500 ml-0.5">Lens</span>
      </h1>

      {#if size === "lg" || size === "xl"}
        <p
          class={cn(
            "text-xs font-medium tracking-wider opacity-90 mt-1 text-brand-gold-600",
            size === "xl" ? "text-sm" : "text-xs",
          )}
        >
          INTELLIGENCE SYSTEM
        </p>
      {/if}
    </div>
  {/if}
</div>
