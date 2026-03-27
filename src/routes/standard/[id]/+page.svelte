<script lang="ts">
    import { ChevronLeft } from "lucide-svelte";
    import type { PageData } from "./$types";
    import Container from "$lib/components/layout/Container.svelte";
    
    export let data: PageData;
    
    function formatPrice(value: number | null | undefined): string {
        if (value == null) return "—";
        return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(value);
    }
</script>

<svelte:head>
    <title>Standard | Clearix Lens</title>
</svelte:head>

<main class="min-h-screen bg-muted pb-20">
    <!-- Top Bar -->
    <div class="bg-card border-b border-border sticky top-0 z-30">
        <Container>
            <div class="flex items-center justify-between py-4">
                <a href="/lentes" class="flex items-center gap-2 text-muted-foreground hover:text-cyan-600 transition-colors text-sm font-medium">
                    <ChevronLeft class="h-4 w-4" /> Voltar
                </a>
                <span class="px-3 py-1 bg-cyan-100 dark:bg-cyan-900/40 text-cyan-800 dark:text-cyan-300 text-xs font-bold rounded-full">
                    Standard
                </span>
            </div>
        </Container>
    </div>

    <Container>
        <div class="py-12">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Main Info -->
                <div class="lg:col-span-2 space-y-6">
                    <h1 class="text-4xl font-black bg-gradient-to-r from-cyan-600 to-blue-600 bg-clip-text text-transparent">
                        Conceito Standard
                    </h1>
                    
                    <p class="text-muted-foreground text-lg">
                        Categoria de lentes Standard — conjunto de lentes similares de diferentes marcas com a mesma óptica base.
                    </p>
                    
                    <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-900/50 rounded-xl p-6">
                        <p class="text-sm text-blue-700 dark:text-blue-300">
                            ID: <span class="font-mono font-bold">{data.id}</span>
                        </p>
                    </div>
                </div>

                <!-- Pricing Sidebar -->
                <div class="lg:col-span-1">
                    <div class="bg-card border border-cyan-100 dark:border-cyan-900/30 rounded-xl p-6 sticky top-20">
                        <h3 class="font-bold text-lg mb-4">💰 Preços</h3>
                        <div class="space-y-3">
                            <div>
                                <p class="text-xs text-muted-foreground mb-1">Mínimo</p>
                                <p class="text-xl font-bold text-foreground">—</p>
                            </div>
                            <div class="border-t border-border pt-3">
                                <p class="text-xs text-muted-foreground mb-1">Máximo</p>
                                <p class="text-xl font-bold text-foreground">—</p>
                            </div>
                            <div class="border-t border-border pt-3">
                                <p class="text-xs text-muted-foreground mb-1">Médio</p>
                                <p class="text-xl font-bold text-cyan-600 dark:text-cyan-400">—</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </Container>
</main>
