<script lang="ts">
    /**
     * DashboardMetricCard - Card de métrica estilo dashboard
     * Segue o padrão visual do dashboard principal
     */
    export let title: string;
    export let value: string | number;
    export let icon: string = "📊";
    export let color: "blue" | "purple" | "green" | "orange" | "cyan" = "blue";
    export let subtitle: string | undefined = undefined;
    export let trend: string | undefined = undefined;

    const colorSchemes = {
        blue: {
            header: "from-blue-600 to-blue-700",
            body: "bg-gradient-to-br from-blue-950/90 to-blue-900/80",
            text: "text-blue-400",
        },
        purple: {
            header: "from-purple-600 to-purple-700",
            body: "bg-gradient-to-br from-purple-950/90 to-purple-900/80",
            text: "text-purple-400",
        },
        green: {
            header: "from-green-600 to-green-700",
            body: "bg-gradient-to-br from-green-950/90 to-green-900/80",
            text: "text-green-400",
        },
        orange: {
            header: "from-orange-600 to-orange-700",
            body: "bg-gradient-to-br from-orange-950/90 to-orange-900/80",
            text: "text-orange-400",
        },
        cyan: {
            header: "from-cyan-600 to-cyan-700",
            body: "bg-gradient-to-br from-cyan-950/90 to-cyan-900/80",
            text: "text-cyan-400",
        },
    };

    $: scheme = colorSchemes[color];
</script>

<div
    class="rounded-xl overflow-hidden shadow-2xl hover:shadow-3xl transition-all duration-300 hover:-translate-y-1"
>
    <!-- Header colorido -->
    <div class="bg-gradient-to-r {scheme.header} px-5 py-4">
        <div class="flex items-center gap-3">
            <span class="text-3xl drop-shadow-lg">{icon}</span>
            <span
                class="text-white font-semibold text-sm uppercase tracking-wider opacity-95"
                >{title}</span
            >
        </div>
    </div>

    <!-- Body escuro -->
    <div class="{scheme.body} px-6 py-8 border-t-2 border-white/5">
        <!-- Valor principal -->
        <div class="text-5xl font-bold text-white mb-3 tracking-tight">
            {value}
        </div>

        <!-- Subtitle ou Trend -->
        {#if subtitle}
            <div class="text-sm text-neutral-400 font-medium">
                {subtitle}
            </div>
        {/if}

        {#if trend}
            <div
                class="inline-flex items-center gap-2 mt-2 px-3 py-1.5 rounded-lg bg-white/10 backdrop-blur-sm"
            >
                <span class="text-xs font-bold {scheme.text}">
                    {trend}
                </span>
            </div>
        {/if}
    </div>
</div>
