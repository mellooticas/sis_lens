<script lang="ts">
  /**
   * Componente Badge SIS Lens
   * Badges para status e destaques
   */

  export let variant:
    | "primary"
    | "success"
    | "warning"
    | "error"
    | "gold"
    | "orange"
    | "melhor-opcao"
    | "promocao"
    | "entrega-expressa"
    | "neutral"
    | "info"
    | "secondary" = "primary";
  export let size: "sm" | "md" = "md";

  // Classes base
  const baseClasses = "inline-flex items-center gap-1 rounded-full font-medium";

  // Variantes
  const variants = {
    primary: "bg-primary-100 text-primary-700",
    success: "bg-success/10 text-success-dark",
    warning: "bg-warning/10 text-warning-dark",
    error: "bg-error/10 text-error-dark",
    gold: "bg-brand-gold-100 text-brand-gold-700",
    orange: "bg-orange-100 text-orange-700",
    "melhor-opcao": "bg-brand-gold-500 text-white font-semibold shadow-md",
    promocao: "bg-orange-500 text-white",
    "entrega-expressa": "bg-success text-white",
    neutral:
      "bg-neutral-100 text-neutral-700 dark:bg-neutral-800 dark:text-neutral-300",
    info: "bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300",
    secondary:
      "bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-300",
  };

  // Tamanhos
  const sizes = {
    sm: "px-2 py-0.5 text-xs",
    md: "px-3 py-1 text-xs",
  };

  $: classes = `${baseClasses} ${variants[variant]} ${sizes[size]}`;
</script>

<span class={classes} {...$$restProps}>
  <slot />
</span>
