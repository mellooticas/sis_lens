<!--
  🏠 SIS Lens - Página Principal
  Sistema Decisor de Lentes Inteligente
-->
<script lang="ts">
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";

  // Redirecionar para dashboard
  onMount(() => {
    goto("/dashboard");
  });
</script>

<svelte:head>
  <title>SIS Lens - Sistema de Inteligência</title>
  <meta
    name="description"
    content="Sistema inteligente para decisão de lentes oftálmicas"
  />
</svelte:head>

<!-- Página de loading simples enquanto redireciona -->
<div
  class="min-h-screen bg-neutral-50 dark:bg-neutral-900 flex items-center justify-center"
>
  <div class="text-center space-y-4">
    <div
      class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"
    ></div>
    <h1 class="text-2xl font-bold text-neutral-900 dark:text-neutral-100">
      SIS Lens
    </h1>
    <p class="text-neutral-600 dark:text-neutral-400">Carregando sistema...</p>
  </div>
</div>
