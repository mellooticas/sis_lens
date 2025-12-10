<script>
    import DualComparison from "$lib/components/sales/DualComparison.svelte";
    import SourcingAdmin from "$lib/components/sales/SourcingAdmin.svelte";
    import GradeVisualizer from "$lib/components/sales/GradeVisualizer.svelte";
</script>

<div class="min-h-screen bg-gray-50 pb-20">
    <!-- Header Demo -->
    <header class="bg-brand-blue-900 text-white py-6 shadow-lg">
        <div class="container mx-auto px-4 flex justify-between items-center">
            <div>
                <h1 class="text-2xl font-bold font-headline tracking-tight">
                    SIS Lens <span class="text-brand-gold-400 font-light"
                        >Intelligence</span
                    >
                </h1>
                <p class="text-sm text-brand-blue-200">
                    Ambiente de Demonstração Visual v2.0
                </p>
            </div>
            <div class="text-right">
                <span
                    class="bg-brand-gold-500 text-brand-blue-900 text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wider"
                    >Modo Demo</span
                >
            </div>
        </div>
    </header>

    <main class="container mx-auto px-4 py-12 space-y-16">
        <!-- Seção 1: A Experiência de Venda -->
        <section>
            <div class="mb-6 flex items-center justify-between">
                <div>
                    <h2
                        class="text-xl font-bold text-gray-800 font-headline border-l-4 border-brand-gold-500 pl-4"
                    >
                        1. Experiência de Venda (Front-end)
                    </h2>
                    <p class="text-gray-500 ml-5 mt-1">
                        Como o vendedor compara Grife vs Marca Própria na mesa.
                    </p>
                </div>
            </div>

            <DualComparison />
        </section>

        <!-- Seção 2: O Sourcing (Backoffice) -->
        <section>
            <div class="mb-6">
                <h2
                    class="text-xl font-bold text-gray-800 font-headline border-l-4 border-brand-blue-500 pl-4"
                >
                    2. Gestão de Sourcing (Back-end)
                </h2>
                <p class="text-gray-500 ml-5 mt-1">
                    O motor invisível que escolhe o laboratório mais barato para
                    a marca própria.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <div class="lg:col-span-2">
                    <SourcingAdmin />
                </div>
                <div class="space-y-6">
                    <!-- Card Explicativo -->
                    <div
                        class="bg-blue-50 p-6 rounded-xl border border-blue-100"
                    >
                        <h4 class="font-bold text-blue-900 mb-2 font-headline">
                            Como funciona?
                        </h4>
                        <p class="text-sm text-blue-800 leading-relaxed">
                            Quando vendemos uma <strong>SIS Lens Gold</strong>,
                            o sistema faz um leilão instantâneo entre os
                            laboratórios homologados.
                            <br /><br />
                            Hoje, o <strong>Lab Beta</strong> está R$ 5,00 mais barato
                            que o Alpha. O pedido é roteado automaticamente para
                            lá.
                        </p>
                    </div>

                    <!-- Visualizador de Grade -->
                    <div
                        class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm"
                    >
                        <h4 class="font-bold text-gray-800 mb-4 font-headline">
                            Validação Técnica
                        </h4>
                        <div class="flex justify-center">
                            <GradeVisualizer />
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>
</div>
