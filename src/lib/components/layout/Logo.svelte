<script lang="ts">
  import { cn } from "$lib/utils";
  import { theme } from "$lib/stores/theme";

  export let variant: "full" | "icon" | "text" = "full";
  export let size: "sm" | "md" | "lg" | "xl" | "2xl" | "3xl" = "md";
  export let themeMode: "auto" | "light" | "dark" = "auto";

  let className = "";
  export { className as class };
  
  // Determinar se está em dark mode
  $: isDark = $theme === 'dark';

  const sizeClasses = {
    sm: "max-h-8 w-auto",
    md: "max-h-12 w-auto",
    lg: "max-h-16 w-auto",
    xl: "max-h-20 w-auto",
    "2xl": "max-h-32 w-auto",
    "3xl": "max-h-40 w-auto",
  };

  const textSizeClasses = {
    sm: "text-lg",
    md: "text-2xl",
    lg: "text-3xl",
    xl: "text-4xl",
    "2xl": "text-5xl",
    "3xl": "text-6xl",
  };

  const themeClasses = {
    auto: "text-brand-blue-500 dark:text-white",
    light: "text-brand-blue-500",
    dark: "text-white",
  };
</script>

<div class={cn("flex items-center gap-2", className)}>
  {#if variant === "icon"}
    <!-- Apenas ícone - SVG inline com cores controláveis -->
    <div class={cn("transition-all duration-300", sizeClasses[size])}>
      <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg" class="w-full h-full">
        <!-- Círculo azul -->
        <circle cx="50" cy="50" r="35" fill="#0b80e3" />
        <!-- Lente laranja -->
        <path d="M50 25 C35 25 25 35 25 50 C25 65 35 75 50 75 L50 25Z" fill="#fc7422" opacity="0.8" />
        <!-- Detalhes em preto/branco conforme tema -->
        <circle cx="50" cy="50" r="20" fill="none" stroke="{isDark ? '#ffffff' : '#000000'}" stroke-width="2" />
        <path d="M45 50 L55 50 M50 45 L50 55" stroke="{isDark ? '#ffffff' : '#000000'}" stroke-width="2" stroke-linecap="round" />
      </svg>
    </div>
  {:else if variant === "full"}
    <!-- Logo completo - SVG inline com cores controláveis -->
    <div class={cn("transition-all duration-300", sizeClasses[size])}>
      <svg viewBox="0 0 200 60" fill="none" xmlns="http://www.w3.org/2000/svg" class="w-full h-full">
        <!-- Ícone -->
        <circle cx="30" cy="30" r="20" fill="#0b80e3" />
        <path d="M30 15 C20 15 15 20 15 30 C15 40 20 45 30 45 L30 15Z" fill="#fc7422" opacity="0.8" />
        <circle cx="30" cy="30" r="12" fill="none" stroke="{isDark ? '#ffffff' : '#000000'}" stroke-width="1.5" />
        
        <!-- Texto SIS -->
        <text x="60" y="40" font-family="Inter, sans-serif" font-size="28" font-weight="700" fill="{isDark ? '#ffffff' : '#000000'}">SIS</text>
        <!-- Texto Lens em dourado -->
        <text x="110" y="40" font-family="Inter, sans-serif" font-size="28" font-weight="700" fill="#eab308">Lens</text>
      </svg>
    </div>
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
