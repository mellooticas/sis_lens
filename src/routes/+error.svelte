<script lang="ts">
    import { page } from "$app/stores";
    import Button from "$lib/components/ui/Button.svelte";

    $: statusCode = $page.status;
    $: message = $page.error?.message || "Algo deu errado";
</script>

<div
    class="min-h-[60vh] flex flex-col items-center justify-center text-center p-4"
>
    <div class="mb-6 text-6xl">
        {#if statusCode === 404}
            🔍
        {:else}
            ⚠️
        {/if}
    </div>

    <h1 class="text-4xl font-bold text-foreground mb-2">
        {statusCode}
    </h1>

    <p class="text-xl text-muted-foreground mb-8 max-w-md">
        {message}
    </p>

    <div class="flex gap-4">
        <Button variant="secondary" on:click={() => history.back()}>
            Voltar
        </Button>
        <Button on:click={() => (window.location.href = "/")}>
            Ir para Início
        </Button>
    </div>
</div>
