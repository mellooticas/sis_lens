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
  {#if variant === "full" || variant === "icon"}
    <!-- Logo Icon -->
    <div class={cn("flex-shrink-0", sizeClasses[size])}>
      <svg
        viewBox="0 0 100 100"
        class={cn("w-full h-full", themeClasses[theme])}
        fill="currentColor"
      >
        <!-- Círculo principal -->
        <circle cx="50" cy="50" r="45" class="opacity-10" />

        <!-- Círculo interno -->
        <circle cx="50" cy="50" r="35" class="opacity-20" />

        <!-- Check mark estilizado representando lente -->
        <path
          d="M35 50 L45 60 L65 40"
          stroke="currentColor"
          stroke-width="6"
          stroke-linecap="round"
          stroke-linejoin="round"
          fill="none"
        />

        <!-- Detalhe da lente -->
        <circle cx="50" cy="50" r="25" class="opacity-5" />
        <circle cx="50" cy="50" r="15" class="opacity-10" />
      </svg>
    </div>
  {/if}

  {#if variant === "full" || variant === "text"}
    <!-- Logo Text -->
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
