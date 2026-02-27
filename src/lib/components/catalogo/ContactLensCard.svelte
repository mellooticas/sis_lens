<script lang="ts">
    import type { RpcContactLensSearchResult as LenteContato } from "$lib/types/database-views";
    import { ChevronRight } from "lucide-svelte";

    export let lente: LenteContato;
    export let compact = false;

    // Formatação de Moeda
    function formatarPreco(preco: number): string {
        return new Intl.NumberFormat("pt-BR", {
            style: "currency",
            currency: "BRL",
        }).format(preco);
    }

    // Cores baseadas no descarte (Substituindo Categoria)
    function obterCorDescarte(tipo: string): string {
        const cores: Record<string, string> = {
            diaria: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
            quinzenal:
                "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200",
            mensal: "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200",
            anual: "bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200",
            trimestral:
                "bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-200",
        };
        return (
            cores[tipo] ||
            "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200"
        );
    }
</script>

<div
    class="lente-card bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden hover:shadow-lg transition-shadow duration-200"
    class:flex={compact}
    class:flex-row={compact}
    class:items-center={compact}
>
    <!-- Header -->
    <div
        class="px-4 py-3 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 border-b border-gray-200 dark:border-gray-700"
        class:border-b-0={compact}
        class:border-r={compact}
        class:flex-shrink-0={compact}
        style={compact ? "width: 40%;" : ""}
    >
        <div class="flex items-start justify-between">
            <div class="flex-1">
                <h3
                    class="text-sm font-semibold text-gray-900 dark:text-white line-clamp-2"
                >
                    {lente.product_name}
                </h3>
                <div class="flex items-center gap-2 mt-1 flex-wrap">
                    <span
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium {obterCorDescarte(
                            lente.lens_type,
                        )}"
                    >
                        {lente.lens_type}
                    </span>
                    {#if lente.stock_available > 0}
                        <span
                            class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
                        >
                            Em Estoque
                        </span>
                    {/if}
                </div>
            </div>
        </div>
    </div>

    <!-- Corpo -->
    <div
        class="px-4 py-3 space-y-3 flex-1"
        class:flex={compact}
        class:flex-row={compact}
        class:items-center={compact}
        class:justify-between={compact}
        class:space-y-0={compact}
        class:gap-4={compact}
    >
        {#if !compact}
            <!-- Marca e Fabricante -->
            <div class="flex items-center justify-between text-sm">
                <div>
                    <span class="text-gray-500 dark:text-gray-400">Marca:</span>
                    <strong class="ml-1 text-gray-900 dark:text-white"
                        >{lente.brand_name}</strong
                    >
                </div>
                {#if lente.manufacturer_name}
                    <div class="text-right">
                        <span class="text-gray-500 dark:text-gray-400"
                            >Fab:</span
                        >
                        <strong class="ml-1 text-gray-900 dark:text-white"
                            >{lente.manufacturer_name}</strong
                        >
                    </div>
                {/if}
            </div>
        {/if}

        {#if compact}
            <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
                <div class="text-gray-500 dark:text-gray-400">Marca</div>
                <div class="font-medium text-gray-900 dark:text-white">
                    {lente.brand_name}
                </div>
            </div>
        {/if}

        <!-- Material, Descarte, Dk/t -->
        <div class="grid grid-cols-3 gap-2 text-xs">
            <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
                <div class="text-gray-500 dark:text-gray-400">Material</div>
                <div class="font-medium text-gray-900 dark:text-white truncate">
                    {lente.material}
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
                <div class="text-gray-500 dark:text-gray-400">Descarte</div>
                <div class="font-medium text-gray-900 dark:text-white">
                    {lente.usage_days
                        ? lente.usage_days + " dias"
                        : lente.lens_type}
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5">
                <div class="text-gray-500 dark:text-gray-400">Dk/t</div>
                <div class="font-medium text-gray-900 dark:text-white">
                    {lente.dk_t || "-"}
                </div>
            </div>
        </div>

        {#if compact}
            <div
                class="bg-gray-50 dark:bg-gray-900 rounded px-2 py-1.5 text-xs"
            >
                <div class="text-gray-500 dark:text-gray-400">Finalidade</div>
                <div class="font-medium text-gray-900 dark:text-white">
                    {lente.purpose}
                </div>
            </div>
        {/if}

        <!-- Tratamento / Finalidade Chips -->
        {#if !compact}
            <div class="flex flex-wrap gap-1.5">
                <span
                    class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300"
                >
                    {lente.purpose.replace("_", " ")}
                </span>
                {#if lente.dk_t}
                    <span
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs bg-cyan-50 text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-300"
                    >
                        DK/t: {lente.dk_t}
                    </span>
                {/if}
            </div>
        {/if}

        {#if !compact}
            <!-- Info Adicional -->
            <div
                class="border-t border-gray-200 dark:border-gray-700 pt-2 text-xs text-gray-600 dark:text-gray-400"
            >
                <div class="flex items-center gap-2">
                    <span class="font-medium">Uso:</span>
                    {lente.lens_type}
                </div>
            </div>
        {/if}
    </div>

    <!-- Footer -->
    <div
        class="px-4 py-3 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700"
        class:border-t-0={compact}
        class:border-l={compact}
        class:flex-shrink-0={compact}
    >
        <div
            class="flex items-center justify-between"
            class:flex-col={compact}
            class:items-end={compact}
            class:gap-3={compact}
        >
            <div class:text-center={compact}>
                <div class="text-xs text-gray-500 dark:text-gray-400">
                    Preço / Caixa
                </div>
                <div
                    class="font-bold text-gray-900 dark:text-white"
                    class:text-2xl={!compact}
                    class:text-xl={compact}
                >
                    {formatarPreco(lente.price_suggested)}
                </div>
                {#if lente.units_per_box}
                    <div
                        class="text-xs text-gray-500 dark:text-gray-400 mt-0.5"
                    >
                        {lente.units_per_box} lentes
                    </div>
                {/if}
            </div>

            <div class="flex gap-2">
                <a
                    href="/contato/{lente.id}"
                    class="px-4 py-2 bg-gray-100 hover:bg-gray-200 dark:bg-gray-800 dark:hover:bg-gray-700 text-gray-900 dark:text-white text-sm font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2"
                >
                    Ver Detalhes
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    .lente-card {
        @apply w-full max-w-md;
    }

    .line-clamp-2 {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
</style>
