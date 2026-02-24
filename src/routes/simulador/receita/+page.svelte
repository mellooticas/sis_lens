<!--
  👓 Simulador de Receita Oftalmológica
  Interface profissional para busca de lentes por prescrição
-->
<script lang="ts">
    import { LensOracleAPI } from "$lib/api/lens-oracle";
    import type { VCanonicalLens } from "$lib/types/database-views";
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
    import LenteCard from "$lib/components/catalogo/LenteCard.svelte";
    import { Eye, Search, RotateCcw } from "lucide-svelte";

    // ... ranges mapping ...
    const esféricos = Array.from({ length: 81 }, (_, i) => -20 + i * 0.25);
    const cilíndricos = Array.from({ length: 33 }, (_, i) => -8 + i * 0.25);
    const eixos = Array.from({ length: 181 }, (_, i) => i);
    const adições = Array.from({ length: 17 }, (_, i) => 0.75 + i * 0.25);

    // ... od/oe state ...
    let od = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };
    let oe = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };

    let tipoLente: "single_vision" | "multifocal" | "bifocal" = "single_vision";
    let usarMesmaReceita = false;

    let loading = false;
    let resultados: VCanonicalLens[] = [];
    let erro = "";
    let mostrarPreview = true;

    // Copia receita do OD para OE
    function copiarODparaOE() {
        oe = { ...od };
    }

    // Limpa o formulário
    function limparReceita() {
        od = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };
        oe = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };
        resultados = [];
        erro = "";
    }

    // Formata valor para exibição (com sinal +/-)
    function formatarGrau(valor: number): string {
        if (valor === 0) return "0.00";
        return (valor > 0 ? "+" : "") + valor.toFixed(2);
    }

    async function buscarLentes() {
        loading = true;
        erro = "";
        resultados = [];

        try {
            // No novo banco, as buscas por receita são otimizadas via RPC
            const res = await LensOracleAPI.searchByPrescription({
                spherical_needed:   od.esferico,
                cylindrical_needed: od.cilindrico,
                addition_needed:    tipoLente !== "single_vision" ? od.adicao : undefined,
                lens_type:          tipoLente,
                limit:              100,
            });

            if (res.data) {
                resultados = res.data;
            } else {
                erro =
                    res.error?.message || "Erro ao buscar lentes compatíveis";
            }
        } catch (e: any) {
            erro = e.message || "Erro ao processar busca";
        } finally {
            loading = false;
        }
    }

    // Atualiza OE quando "mesma receita" está ativo
    $: if (usarMesmaReceita) {
        copiarODparaOE();
    }
</script>

<svelte:head>
    <title>Simulador de Receita - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
    <PageHero
        badge="👓 Simulador"
        title="Buscar Lentes por Receita"
        subtitle="Encontre lentes compatíveis com a prescrição oftalmológica"
    />

    <div class="mt-8 space-y-6">
        <!-- Tipo de Lente -->
        <div class="glass-panel p-6 rounded-xl">
            <h3 class="text-lg font-bold text-neutral-900 dark:text-white mb-4">
                Tipo de Lente
            </h3>
            <div class="flex gap-4 flex-wrap">
                <label class="tipo-radio">
                    <input
                        type="radio"
                        bind:group={tipoLente}
                        value="single_vision"
                    />
                    <span>Visão Simples</span>
                </label>
                <label class="tipo-radio">
                    <input
                        type="radio"
                        bind:group={tipoLente}
                        value="bifocal"
                    />
                    <span>Bifocal</span>
                </label>
                <label class="tipo-radio">
                    <input
                        type="radio"
                        bind:group={tipoLente}
                        value="multifocal"
                    />
                    <span>Multifocal / Progressiva</span>
                </label>
            </div>
        </div>

        <!-- Receita Oftalmológica -->
        <div class="grid lg:grid-cols-2 gap-6">
            <!-- OD - Olho Direito -->
            <div class="receita-card">
                <div class="receita-header">
                    <Eye class="text-primary-500" size={24} />
                    <h3>OD - Olho Direito</h3>
                </div>

                <div class="receita-body">
                    <!-- Esférico -->
                    <div class="campo-receita">
                        <label for="od-esf">Esférico</label>
                        <select id="od-esf" bind:value={od.esferico} class="select-receita">
                            {#each esféricos as valor}
                                <option value={valor}>{formatarGrau(valor)}</option>
                            {/each}
                        </select>
                    </div>

                    <!-- Cilíndrico -->
                    <div class="campo-receita">
                        <label for="od-cil">Cilíndrico</label>
                        <select
                            id="od-cil"
                            bind:value={od.cilindrico}
                            class="select-receita"
                        >
                            {#each cilíndricos as valor}
                                <option value={valor}>{formatarGrau(valor)}</option>
                            {/each}
                        </select>
                    </div>

                    <!-- Eixo -->
                    <div class="campo-receita">
                        <label for="od-eixo">Eixo</label>
                        <select id="od-eixo" bind:value={od.eixo} class="select-receita">
                            {#each eixos as valor}
                                <option value={valor}>{valor}°</option>
                            {/each}
                        </select>
                    </div>

                    <!-- Adição (apenas para multifocal/bifocal) -->
                    {#if tipoLente !== "single_vision"}
                        <div class="campo-receita">
                            <label for="od-add">Adição</label>
                            <select
                                id="od-add"
                                bind:value={od.adicao}
                                class="select-receita"
                            >
                                <option value={0}>Sem adição</option>
                                {#each adições as valor}
                                    <option value={valor}>{formatarGrau(valor)}</option>
                                {/each}
                            </select>
                        </div>
                    {/if}

                    <!-- DNP -->
                    <div class="campo-receita">
                        <label for="od-dnp">DNP (mm)</label>
                        <input
                            id="od-dnp"
                            type="number"
                            bind:value={od.dnp}
                            min="20"
                            max="40"
                            step="0.5"
                            class="input-receita"
                        />
                    </div>
                </div>
            </div>

            <!-- OE - Olho Esquerdo -->
            <div class="receita-card">
                <div class="receita-header">
                    <Eye class="text-orange-500" size={24} />
                    <h3>OE - Olho Esquerdo</h3>
                    <label
                        class="ml-auto flex items-center gap-2 text-sm cursor-pointer"
                    >
                        <input
                            type="checkbox"
                            bind:checked={usarMesmaReceita}
                            class="checkbox"
                        />
                        <span>Mesma receita</span>
                    </label>
                </div>

                <div class="receita-body">
                    <!-- Esférico -->
                    <div class="campo-receita">
                        <label for="oe-esf">Esférico</label>
                        <select
                            id="oe-esf"
                            bind:value={oe.esferico}
                            class="select-receita"
                            disabled={usarMesmaReceita}
                        >
                            {#each esféricos as valor}
                                <option value={valor}>{formatarGrau(valor)}</option>
                            {/each}
                        </select>
                    </div>

                    <!-- Cilíndrico -->
                    <div class="campo-receita">
                        <label for="oe-cil">Cilíndrico</label>
                        <select
                            id="oe-cil"
                            bind:value={oe.cilindrico}
                            class="select-receita"
                            disabled={usarMesmaReceita}
                        >
                            {#each cilíndricos as valor}
                                <option value={valor}>{formatarGrau(valor)}</option>
                            {/each}
                        </select>
                    </div>

                    <!-- Eixo -->
                    <div class="campo-receita">
                        <label for="oe-eixo">Eixo</label>
                        <select
                            id="oe-eixo"
                            bind:value={oe.eixo}
                            class="select-receita"
                            disabled={usarMesmaReceita}
                        >
                            {#each eixos as valor}
                                <option value={valor}>{valor}°</option>
                            {/each}
                        </select>
                    </div>

                    <!-- Adição (apenas para multifocal/bifocal) -->
                    {#if tipoLente !== "single_vision"}
                        <div class="campo-receita">
                            <label for="oe-add">Adição</label>
                            <select
                                id="oe-add"
                                bind:value={oe.adicao}
                                class="select-receita"
                                disabled={usarMesmaReceita}
                            >
                                <option value={0}>Sem adição</option>
                                {#each adições as valor}
                                    <option value={valor}>{formatarGrau(valor)}</option>
                                {/each}
                            </select>
                        </div>
                    {/if}

                    <!-- DNP -->
                    <div class="campo-receita">
                        <label for="oe-dnp">DNP (mm)</label>
                        <input
                            id="oe-dnp"
                            type="number"
                            bind:value={oe.dnp}
                            min="20"
                            max="40"
                            step="0.5"
                            class="input-receita"
                            disabled={usarMesmaReceita}
                        />
                    </div>
                </div>
            </div>
        </div>

        <!-- Preview da Receita -->
        {#if mostrarPreview}
            <div class="receita-preview">
                <h4
                    class="text-sm font-bold text-neutral-600 dark:text-neutral-400 mb-3"
                >
                    📋 Preview da Receita
                </h4>
                <div class="preview-table">
                    <table>
                        <thead>
                            <tr>
                                <th></th>
                                <th>Esférico</th>
                                <th>Cilíndrico</th>
                                <th>Eixo</th>
                                {#if tipoLente !== "single_vision"}
                                    <th>Adição</th>
                                {/if}
                                <th>DNP</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="label-col">OD</td>
                                <td>{formatarGrau(od.esferico)}</td>
                                <td>{formatarGrau(od.cilindrico)}</td>
                                <td>{od.eixo}°</td>
                                {#if tipoLente !== "single_vision"}
                                    <td>{formatarGrau(od.adicao)}</td>
                                {/if}
                                <td>{od.dnp} mm</td>
                            </tr>
                            <tr>
                                <td class="label-col">OE</td>
                                <td>{formatarGrau(oe.esferico)}</td>
                                <td>{formatarGrau(oe.cilindrico)}</td>
                                <td>{oe.eixo}°</td>
                                {#if tipoLente !== "single_vision"}
                                    <td>{formatarGrau(oe.adicao)}</td>
                                {/if}
                                <td>{oe.dnp} mm</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        {/if}

        <!-- Ações -->
        <div class="flex gap-4 justify-center flex-wrap">
            <Button
                variant="primary"
                on:click={buscarLentes}
                disabled={loading}
            >
                {#if loading}
                    <LoadingSpinner size="sm" />
                    Buscando...
                {:else}
                    <Search size={18} />
                    Buscar Lentes Compatíveis
                {/if}
            </Button>
            <Button variant="secondary" on:click={limparReceita}>
                <RotateCcw size={18} />
                Limpar
            </Button>
        </div>

        <!-- Erro -->
        {#if erro}
            <div class="erro-card">
                <p>❌ {erro}</p>
            </div>
        {/if}

        <!-- Resultados -->
        {#if resultados.length > 0}
            <div class="resultados-section">
                <div class="resultados-header">
                    <h3>Lentes Compatíveis</h3>
                    <span class="badge-count"
                        >{resultados.length} lente{resultados.length !== 1
                            ? "s"
                            : ""}</span
                    >
                </div>

                <div class="lentes-grid">
                    {#each resultados as lente}
                        <LenteCard {lente} mostrarFornecedor={true} />
                    {/each}
                </div>
            </div>
        {:else if !loading && !erro}
            <div class="empty-state">
                <div class="empty-icon">👓</div>
                <p>
                    Preencha a receita e clique em "Buscar" para encontrar
                    lentes compatíveis
                </p>
            </div>
        {/if}
    </div>
</Container>

<style>
    /* Tipo de Lente Radio */
    .tipo-radio {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.75rem 1.5rem;
        background: rgba(255, 255, 255, 0.5);
        border: 2px solid transparent;
        border-radius: 0.75rem;
        cursor: pointer;
        transition: all 0.2s;
    }

    :global(.dark) .tipo-radio {
        background: rgba(30, 30, 30, 0.5);
    }

    .tipo-radio:hover {
        background: rgba(255, 255, 255, 0.8);
        border-color: var(--color-primary);
    }

    :global(.dark) .tipo-radio:hover {
        background: rgba(40, 40, 40, 0.8);
    }

    .tipo-radio input[type="radio"] {
        width: 1.25rem;
        height: 1.25rem;
        accent-color: var(--color-primary);
        cursor: pointer;
    }

    .tipo-radio span {
        font-weight: 600;
        color: var(--color-text-primary);
    }

    /* Cards de Receita */
    .receita-card {
        background: linear-gradient(
            135deg,
            rgba(255, 255, 255, 0.9),
            rgba(255, 255, 255, 0.7)
        );
        backdrop-filter: blur(10px);
        border: 1px solid rgba(0, 0, 0, 0.1);
        border-radius: 1rem;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    }

    :global(.dark) .receita-card {
        background: linear-gradient(
            135deg,
            rgba(30, 30, 30, 0.9),
            rgba(40, 40, 40, 0.7)
        );
        border-color: rgba(255, 255, 255, 0.1);
    }

    .receita-header {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 1.25rem 1.5rem;
        background: linear-gradient(
            90deg,
            rgba(59, 130, 246, 0.1),
            rgba(249, 115, 22, 0.1)
        );
        border-bottom: 2px solid rgba(0, 0, 0, 0.05);
    }

    :global(.dark) .receita-header {
        background: linear-gradient(
            90deg,
            rgba(59, 130, 246, 0.2),
            rgba(249, 115, 22, 0.2)
        );
        border-bottom-color: rgba(255, 255, 255, 0.05);
    }

    .receita-header h3 {
        font-size: 1.125rem;
        font-weight: 700;
        color: var(--color-text-primary);
    }

    .receita-body {
        padding: 1.5rem;
        display: grid;
        gap: 1.25rem;
    }

    /* Campos da Receita */
    .campo-receita {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
    }

    .campo-receita label {
        font-size: 0.875rem;
        font-weight: 600;
        color: var(--color-text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .select-receita,
    .input-receita {
        width: 100%;
        padding: 0.75rem 1rem;
        font-size: 1rem;
        font-weight: 600;
        background: white;
        border: 2px solid rgba(0, 0, 0, 0.1);
        border-radius: 0.5rem;
        color: var(--color-text-primary);
        transition: all 0.2s;
        cursor: pointer;
    }

    :global(.dark) .select-receita,
    :global(.dark) .input-receita {
        background: rgba(30, 30, 30, 0.8);
        border-color: rgba(255, 255, 255, 0.1);
    }

    .select-receita:focus,
    .input-receita:focus {
        outline: none;
        border-color: var(--color-primary);
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
    }

    .select-receita:disabled,
    .input-receita:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .checkbox {
        width: 1.125rem;
        height: 1.125rem;
        accent-color: var(--color-primary);
        cursor: pointer;
    }

    /* Preview da Receita */
    .receita-preview {
        background: linear-gradient(
            135deg,
            rgba(234, 179, 8, 0.1),
            rgba(249, 115, 22, 0.1)
        );
        border: 2px dashed rgba(234, 179, 8, 0.3);
        border-radius: 1rem;
        padding: 1.5rem;
    }

    :global(.dark) .receita-preview {
        background: linear-gradient(
            135deg,
            rgba(234, 179, 8, 0.2),
            rgba(249, 115, 22, 0.2)
        );
        border-color: rgba(234, 179, 8, 0.5);
    }

    .preview-table {
        overflow-x: auto;
        border-radius: 0.5rem;
        border: 1px solid rgba(0, 0, 0, 0.1);
    }

    :global(.dark) .preview-table {
        border-color: rgba(255, 255, 255, 0.1);
    }

    .preview-table table {
        width: 100%;
        border-collapse: collapse;
        background: white;
    }

    :global(.dark) .preview-table table {
        background: rgba(30, 30, 30, 0.8);
    }

    .preview-table thead {
        background: rgba(59, 130, 246, 0.1);
    }

    :global(.dark) .preview-table thead {
        background: rgba(59, 130, 246, 0.2);
    }

    .preview-table th,
    .preview-table td {
        padding: 0.75rem 1rem;
        text-align: center;
        border: 1px solid rgba(0, 0, 0, 0.05);
    }

    :global(.dark) .preview-table th,
    :global(.dark) .preview-table td {
        border-color: rgba(255, 255, 255, 0.05);
    }

    .preview-table th {
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        color: var(--color-text-secondary);
    }

    .preview-table td {
        font-size: 0.875rem;
        font-weight: 600;
        font-family: "Courier New", monospace;
        color: var(--color-text-primary);
    }

    .preview-table .label-col {
        background: rgba(59, 130, 246, 0.05);
        font-weight: 800;
        color: var(--color-primary);
    }

    :global(.dark) .preview-table .label-col {
        background: rgba(59, 130, 246, 0.15);
    }

    /* Erro */
    .erro-card {
        background: rgba(239, 68, 68, 0.1);
        border: 2px solid rgba(239, 68, 68, 0.3);
        border-radius: 1rem;
        padding: 1.25rem;
        text-align: center;
    }

    .erro-card p {
        font-weight: 600;
        color: #dc2626;
    }

    /* Resultados */
    .resultados-section {
        margin-top: 3rem;
    }

    .resultados-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
        padding-bottom: 1rem;
        border-bottom: 2px solid rgba(0, 0, 0, 0.1);
    }

    :global(.dark) .resultados-header {
        border-bottom-color: rgba(255, 255, 255, 0.1);
    }

    .resultados-header h3 {
        font-size: 1.5rem;
        font-weight: 800;
        color: var(--color-text-primary);
    }

    .badge-count {
        padding: 0.5rem 1rem;
        background: linear-gradient(
            135deg,
            var(--color-primary),
            var(--color-secondary)
        );
        color: white;
        border-radius: 999px;
        font-size: 0.875rem;
        font-weight: 700;
    }

    .lentes-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(min(100%, 350px), 1fr));
        gap: 1.5rem;
    }

    /* Empty State */
    .empty-state {
        text-align: center;
        padding: 4rem 2rem;
        opacity: 0.6;
    }

    .empty-icon {
        font-size: 4rem;
        margin-bottom: 1rem;
    }

    .empty-state p {
        font-size: 1.125rem;
        color: var(--color-text-secondary);
    }

    /* Responsive */
    @media (max-width: 768px) {
        .lentes-grid {
            grid-template-columns: 1fr;
        }

        .preview-table {
            font-size: 0.75rem;
        }

        .preview-table th,
        .preview-table td {
            padding: 0.5rem;
            font-size: 0.75rem;
        }

        .tipo-radio {
            padding: 0.5rem 1rem;
            font-size: 0.875rem;
        }
    }
</style>
