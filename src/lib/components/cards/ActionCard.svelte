<script lang="ts">
  /**
   * ActionCard - Card com ícone, título, descrição e CTA
   * Usado para ações principais (Buscar, Ranking, Histórico)
   */

  import Button from "$lib/components/ui/Button.svelte";
  import { createEventDispatcher } from "svelte";

  export let icon = "📄";
  export let title = "";
  export let description = "";
  export let actionLabel = "Acessar";
  export let color: "blue" | "green" | "orange" | "gold" = "blue";
  export let disabled = false;

  const dispatch = createEventDispatcher();

  function handleClick() {
    if (!disabled) {
      dispatch("click");
    }
  }
</script>

<div
  class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 rounded-xl p-6 hover:shadow-card-hover transition-all duration-300"
  class:opacity-50={disabled}
>
  <!-- Header -->
  <div class="flex items-center gap-3 mb-4">
    <!-- Icon Container com classes condicionais -->
    <div
      class="p-3 rounded-lg"
      class:bg-primary-50={color === "blue"}
      class:dark:bg-primary-800={color === "blue"}
      class:bg-success-light={color === "green"}
      class:dark:bg-success-dark={color === "green"}
      class:bg-orange-50={color === "orange"}
      class:dark:bg-orange-800={color === "orange"}
      class:bg-brand-gold-50={color === "gold"}
      class:dark:bg-brand-gold-800={color === "gold"}
    >
      <span class="text-2xl">{icon}</span>
    </div>
    <h3 class="text-lg font-semibold text-neutral-900 dark:text-neutral-100">
      {title}
    </h3>
  </div>

  <!-- Description -->
  <p
    class="text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed mb-6"
  >
    {description}
  </p>

  <!-- CTA Button -->
  <Button
    variant="primary"
    size="md"
    fullWidth
    {disabled}
    on:click={handleClick}
  >
    {actionLabel}
  </Button>
</div>
