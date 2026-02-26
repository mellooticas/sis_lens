<!--
  👓 Simulador de Receita Oftalmológica — Canonical Engine v2
  Busca conceitos canônicos via rpc_canonical_for_prescription (migration 278).
  Exibe resultados Standard (CST) e Premium (CPR) com SKU, pricing e tratamentos.
-->
<script lang="ts">
    import { LensOracleAPI } from "$lib/api/lens-oracle";
    import type { PrescriptionSearchResult } from "$lib/types/database-views";
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import Button from "$lib/components/ui/Button.svelte";
    import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";
    import { Eye, Search, RotateCcw, Package, Star } from "lucide-svelte";

    // ── Ranges de graus ───────────────────────────────────────────────────────
    const esféricos   = Array.from({ length: 81 }, (_, i) => -20 + i * 0.25);
    const cilíndricos = Array.from({ length: 33 }, (_, i) =>  -8 + i * 0.25);
    const eixos       = Array.from({ length: 181 }, (_, i) => i);
    const adições     = Array.from({ length: 17 },  (_, i) => 0.75 + i * 0.25);

    // ── Estado da receita ─────────────────────────────────────────────────────
    let od = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };
    let oe = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };
    let tipoLente: "single_vision" | "multifocal" | "bifocal" = "single_vision";
    let usarMesmaReceita = false;

    // ── Estado de busca ───────────────────────────────────────────────────────
    let loading = false;
    let resultadosStandard: PrescriptionSearchResult[] = [];
    let resultadosPremium:  PrescriptionSearchResult[] = [];
    let erro = "";
    let jaBuscou = false;
    let mostrarStandard = true;
    let mostrarPremium  = true;

    // ── Formatadores ──────────────────────────────────────────────────────────
    function formatarGrau(valor: number): string {
        if (valor === 0) return "0.00";
        return (valor > 0 ? "+" : "") + valor.toFixed(2);
    }

    function formatarPreco(valor: number | null): string {
        if (valor == null) return "—";
        return new Intl.NumberFormat("pt-BR", {
            style: "currency", currency: "BRL", minimumFractionDigits: 0
        }).format(valor);
    }

    function formatarTratamento(code: string): string {
        const mapa: Record<string, string> = {
            ar: "AR", scratch: "Anti-Risco", blue: "Blue Cut",
            uv: "UV", photo: "Fotossensível",
        };
        return mapa[code] ?? code.toUpperCase();
    }

    function tratamentoBadgeClass(code: string): string {
        const mapa: Record<string, string> = {
            ar:      "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-300",
            scratch: "bg-green-100 text-green-800 dark:bg-green-900/40 dark:text-green-300",
            blue:    "bg-indigo-100 text-indigo-800 dark:bg-indigo-900/40 dark:text-indigo-300",
            uv:      "bg-purple-100 text-purple-800 dark:bg-purple-900/40 dark:text-purple-300",
            photo:   "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-300",
        };
        return mapa[code] ?? "bg-neutral-100 text-neutral-700 dark:bg-neutral-800 dark:text-neutral-300";
    }

    // ── Ações ─────────────────────────────────────────────────────────────────
    function copiarODparaOE() { oe = { ...od }; }

    function limparReceita() {
        od = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };
        oe = { esferico: 0, cilindrico: 0, eixo: 0, adicao: 0, dnp: 32 };
        resultadosStandard = [];
        resultadosPremium  = [];
        erro = "";
        jaBuscou = false;
    }

    async function buscarConceitos() {
        loading = true;
        erro = "";
        resultadosStandard = [];
        resultadosPremium  = [];
        jaBuscou = false;

        const adicaoOD = tipoLente !== "single_vision" ? od.adicao || undefined : undefined;

        try {
            // Busca paralela Standard + Premium via rpc_canonical_for_prescription
            const [resStd, resPre] = await Promise.all([
                LensOracleAPI.searchByPrescriptionV2({
                    spherical:   od.esferico,
                    cylindrical: od.cilindrico !== 0 ? od.cilindrico : undefined,
                    addition:    adicaoOD,
                    lens_type:   tipoLente,
                    is_premium:  false,
                    limit:       30,
                }),
                LensOracleAPI.searchByPrescriptionV2({
                    spherical:   od.esferico,
                    cylindrical: od.cilindrico !== 0 ? od.cilindrico : undefined,
                    addition:    adicaoOD,
                    lens_type:   tipoLente,
                    is_premium:  true,
                    limit:       20,
                }),
            ]);

            if (resStd.data) resultadosStandard = resStd.data;
            if (resPre.data) resultadosPremium  = resPre.data;

            if (resStd.error && resPre.error) {
                erro = resStd.error.message || "Erro ao buscar conceitos compatíveis";
            }

            jaBuscou = true;
        } catch (e: any) {
            erro = e.message || "Erro ao processar busca";
            jaBuscou = true;
        } finally {
            loading = false;
        }
    }

    $: if (usarMesmaReceita) copiarODparaOE();
    $: totalResultados = resultadosStandard.length + resultadosPremium.length;
</script>

<svelte:head>
    <title>Simulador de Receita - SIS Lens</title>
</svelte:head>

<Container maxWidth="xl" padding="md">
    <PageHero
        badge="👓 Simulador"
        title="Buscar por Receita"
        subtitle="Encontre conceitos canônicos compatíveis — Standard e Premium com pricing"
    />

    <div class="mt-8 space-y-6">

        <!-- ── Tipo de Lente ────────────────────────────────────────────────── -->
        <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 p-5 rounded-xl shadow-sm">
            <h3 class="text-sm font-bold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider mb-4">
                🔭 Tipo de Lente
            </h3>
            <div class="flex gap-3 flex-wrap">
                {#each [
                    { value: "single_vision", label: "Visão Simples",      emoji: "👁️" },
                    { value: "bifocal",        label: "Bifocal",            emoji: "👓" },
                    { value: "multifocal",     label: "Multifocal / Prog.", emoji: "🔬" },
                ] as opt (opt.value)}
                    <label
                        class="flex items-center gap-2.5 px-4 py-2.5 rounded-xl cursor-pointer border-2 transition-all duration-200 font-semibold text-sm select-none
                            {tipoLente === opt.value
                                ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300'
                                : 'border-neutral-200 dark:border-neutral-700 bg-white dark:bg-neutral-900 text-neutral-600 dark:text-neutral-400 hover:border-primary-300 dark:hover:border-primary-600'}"
                    >
                        <input type="radio" bind:group={tipoLente} value={opt.value} class="sr-only" />
                        <span>{opt.emoji}</span>
                        <span>{opt.label}</span>
                        {#if tipoLente === opt.value}
                            <span class="w-2 h-2 rounded-full bg-primary-500 ml-1"></span>
                        {/if}
                    </label>
                {/each}
            </div>
        </div>

        <!-- ── Formulário OD / OE ───────────────────────────────────────────── -->
        <div class="grid lg:grid-cols-2 gap-6">

            <!-- OD -->
            <div class="receita-card border-blue-200/60 dark:border-blue-800/30">
                <div class="receita-header bg-gradient-to-r from-blue-50 to-sky-50 dark:from-blue-950/30 dark:to-sky-950/20 border-b border-blue-100 dark:border-blue-900/20">
                    <div class="w-8 h-8 rounded-lg bg-blue-500 flex items-center justify-center">
                        <Eye size={16} class="text-white" />
                    </div>
                    <div>
                        <h3 class="font-bold text-neutral-900 dark:text-white text-sm">OD — Olho Direito</h3>
                        <p class="text-[11px] text-neutral-500 dark:text-neutral-500 font-mono">{formatarGrau(od.esferico)} / {formatarGrau(od.cilindrico)} × {od.eixo}°</p>
                    </div>
                </div>
                <div class="receita-body">
                    <!-- Esférico -->
                    <div class="campo-receita">
                        <label for="od-esf">Esférico</label>
                        <select id="od-esf" bind:value={od.esferico} class="select-receita">
                            {#each esféricos as v}
                                <option value={v}>{formatarGrau(v)}</option>
                            {/each}
                        </select>
                    </div>
                    <!-- Cilíndrico -->
                    <div class="campo-receita">
                        <label for="od-cil">Cilíndrico</label>
                        <select id="od-cil" bind:value={od.cilindrico} class="select-receita">
                            {#each cilíndricos as v}
                                <option value={v}>{formatarGrau(v)}</option>
                            {/each}
                        </select>
                    </div>
                    <!-- Eixo -->
                    <div class="campo-receita">
                        <label for="od-eixo">Eixo</label>
                        <select id="od-eixo" bind:value={od.eixo} class="select-receita">
                            {#each eixos as v}
                                <option value={v}>{v}°</option>
                            {/each}
                        </select>
                    </div>
                    <!-- Adição (multifocal/bifocal) -->
                    {#if tipoLente !== "single_vision"}
                        <div class="campo-receita">
                            <label for="od-add">Adição</label>
                            <select id="od-add" bind:value={od.adicao} class="select-receita">
                                <option value={0}>Sem adição</option>
                                {#each adições as v}
                                    <option value={v}>{formatarGrau(v)}</option>
                                {/each}
                            </select>
                        </div>
                    {/if}
                    <!-- DNP -->
                    <div class="campo-receita">
                        <label for="od-dnp">DNP (mm)</label>
                        <input id="od-dnp" type="number" bind:value={od.dnp} min="20" max="40" step="0.5" class="select-receita" />
                    </div>
                </div>
            </div>

            <!-- OE -->
            <div class="receita-card border-orange-200/60 dark:border-orange-800/30">
                <div class="receita-header bg-gradient-to-r from-orange-50 to-amber-50 dark:from-orange-950/30 dark:to-amber-950/20 border-b border-orange-100 dark:border-orange-900/20">
                    <div class="w-8 h-8 rounded-lg bg-orange-500 flex items-center justify-center">
                        <Eye size={16} class="text-white" />
                    </div>
                    <div>
                        <h3 class="font-bold text-neutral-900 dark:text-white text-sm">OE — Olho Esquerdo</h3>
                        <p class="text-[11px] text-neutral-500 dark:text-neutral-500 font-mono">{formatarGrau(oe.esferico)} / {formatarGrau(oe.cilindrico)} × {oe.eixo}°</p>
                    </div>
                    <label class="ml-auto flex items-center gap-2 text-xs cursor-pointer text-neutral-500 dark:text-neutral-400 font-medium">
                        <input type="checkbox" bind:checked={usarMesmaReceita} class="w-3.5 h-3.5 accent-orange-500 cursor-pointer" />
                        Mesma do OD
                    </label>
                </div>
                <div class="receita-body">
                    <!-- Esférico -->
                    <div class="campo-receita">
                        <label for="oe-esf">Esférico</label>
                        <select id="oe-esf" bind:value={oe.esferico} class="select-receita" disabled={usarMesmaReceita}>
                            {#each esféricos as v}
                                <option value={v}>{formatarGrau(v)}</option>
                            {/each}
                        </select>
                    </div>
                    <!-- Cilíndrico -->
                    <div class="campo-receita">
                        <label for="oe-cil">Cilíndrico</label>
                        <select id="oe-cil" bind:value={oe.cilindrico} class="select-receita" disabled={usarMesmaReceita}>
                            {#each cilíndricos as v}
                                <option value={v}>{formatarGrau(v)}</option>
                            {/each}
                        </select>
                    </div>
                    <!-- Eixo -->
                    <div class="campo-receita">
                        <label for="oe-eixo">Eixo</label>
                        <select id="oe-eixo" bind:value={oe.eixo} class="select-receita" disabled={usarMesmaReceita}>
                            {#each eixos as v}
                                <option value={v}>{v}°</option>
                            {/each}
                        </select>
                    </div>
                    <!-- Adição -->
                    {#if tipoLente !== "single_vision"}
                        <div class="campo-receita">
                            <label for="oe-add">Adição</label>
                            <select id="oe-add" bind:value={oe.adicao} class="select-receita" disabled={usarMesmaReceita}>
                                <option value={0}>Sem adição</option>
                                {#each adições as v}
                                    <option value={v}>{formatarGrau(v)}</option>
                                {/each}
                            </select>
                        </div>
                    {/if}
                    <!-- DNP -->
                    <div class="campo-receita">
                        <label for="oe-dnp">DNP (mm)</label>
                        <input id="oe-dnp" type="number" bind:value={oe.dnp} min="20" max="40" step="0.5" class="select-receita" disabled={usarMesmaReceita} />
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Preview da Receita ───────────────────────────────────────────── -->
        <div class="bg-amber-50/60 dark:bg-amber-950/10 border-2 border-dashed border-amber-200 dark:border-amber-700/30 rounded-xl p-4">
            <p class="text-[11px] font-bold text-amber-600 dark:text-amber-500 uppercase tracking-wider mb-3">📋 Preview da Receita</p>
            <div class="overflow-x-auto rounded-lg border border-amber-100 dark:border-amber-900/20">
                <table class="w-full border-collapse text-sm">
                    <thead class="bg-amber-50 dark:bg-amber-950/30">
                        <tr>
                            <th class="preview-th"></th>
                            <th class="preview-th">Esférico</th>
                            <th class="preview-th">Cilíndrico</th>
                            <th class="preview-th">Eixo</th>
                            {#if tipoLente !== "single_vision"}<th class="preview-th">Adição</th>{/if}
                            <th class="preview-th">DNP</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="bg-white dark:bg-neutral-900">
                            <td class="preview-td label-td">OD</td>
                            <td class="preview-td">{formatarGrau(od.esferico)}</td>
                            <td class="preview-td">{formatarGrau(od.cilindrico)}</td>
                            <td class="preview-td">{od.eixo}°</td>
                            {#if tipoLente !== "single_vision"}<td class="preview-td">{formatarGrau(od.adicao)}</td>{/if}
                            <td class="preview-td">{od.dnp} mm</td>
                        </tr>
                        <tr class="bg-neutral-50 dark:bg-neutral-900/60">
                            <td class="preview-td label-td">OE</td>
                            <td class="preview-td">{formatarGrau(oe.esferico)}</td>
                            <td class="preview-td">{formatarGrau(oe.cilindrico)}</td>
                            <td class="preview-td">{oe.eixo}°</td>
                            {#if tipoLente !== "single_vision"}<td class="preview-td">{formatarGrau(oe.adicao)}</td>{/if}
                            <td class="preview-td">{oe.dnp} mm</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ── Ações ────────────────────────────────────────────────────────── -->
        <div class="flex gap-3 justify-center flex-wrap">
            <Button variant="primary" on:click={buscarConceitos} disabled={loading}>
                {#if loading}
                    <LoadingSpinner size="sm" />
                    Buscando...
                {:else}
                    <Search size={18} />
                    Buscar Conceitos Compatíveis
                {/if}
            </Button>
            <Button variant="secondary" on:click={limparReceita} disabled={loading}>
                <RotateCcw size={18} />
                Limpar
            </Button>
        </div>

        <!-- ── Erro ─────────────────────────────────────────────────────────── -->
        {#if erro}
            <div class="bg-red-50 dark:bg-red-950/20 border-2 border-red-200 dark:border-red-800/40 rounded-xl p-4 text-center">
                <p class="font-semibold text-red-600 dark:text-red-400">❌ {erro}</p>
            </div>
        {/if}

        <!-- ── Resultados ───────────────────────────────────────────────────── -->
        {#if jaBuscou && totalResultados > 0}

            <!-- Header + filtros rápidos -->
            <div class="flex items-center justify-between flex-wrap gap-4 pt-4">
                <div class="flex items-center gap-3">
                    <h3 class="text-xl font-black text-neutral-900 dark:text-white">Conceitos Compatíveis</h3>
                    <span class="px-3 py-1 rounded-full bg-gradient-to-r from-primary-600 to-indigo-600 text-white text-sm font-bold">
                        {totalResultados}
                    </span>
                </div>
                <div class="flex gap-2">
                    <button
                        on:click={() => mostrarStandard = !mostrarStandard}
                        class="px-3 py-1.5 rounded-lg text-xs font-bold border-2 transition-all
                            {mostrarStandard
                                ? 'border-primary-400 bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-300'
                                : 'border-neutral-200 dark:border-neutral-700 text-neutral-400 opacity-50'}"
                    >
                        📦 Standard ({resultadosStandard.length})
                    </button>
                    <button
                        on:click={() => mostrarPremium = !mostrarPremium}
                        class="px-3 py-1.5 rounded-lg text-xs font-bold border-2 transition-all
                            {mostrarPremium
                                ? 'border-amber-400 bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300'
                                : 'border-neutral-200 dark:border-neutral-700 text-neutral-400 opacity-50'}"
                    >
                        ★ Premium ({resultadosPremium.length})
                    </button>
                </div>
            </div>

            <!-- Standard results -->
            {#if mostrarStandard && resultadosStandard.length > 0}
                <div class="space-y-4">
                    <div class="flex items-center gap-3">
                        <Package size={16} class="text-primary-500" />
                        <h4 class="font-bold text-sm text-neutral-600 dark:text-neutral-400">Lentes Standard</h4>
                        <div class="h-px flex-1 bg-neutral-200 dark:bg-neutral-700"></div>
                        <span class="text-xs text-neutral-400 font-mono">{resultadosStandard.length} conceito{resultadosStandard.length !== 1 ? 's' : ''}</span>
                    </div>
                    <div class="grid sm:grid-cols-2 xl:grid-cols-3 gap-4">
                        {#each resultadosStandard as res (res.id)}
                            <a href="/catalogo/standard/{res.id}" class="result-card group border-neutral-200 dark:border-neutral-700 hover:border-primary-400 dark:hover:border-primary-600">
                                <!-- Header -->
                                <div class="px-4 pt-4 pb-3 bg-gradient-to-br from-primary-50 to-blue-50 dark:from-primary-950/20 dark:to-blue-950/20">
                                    <div class="flex items-start justify-between gap-2 mb-2">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-black tracking-wider font-mono bg-primary-100 text-primary-800 dark:bg-primary-900/40 dark:text-primary-300 border border-primary-200 dark:border-primary-700">
                                            {res.sku}
                                        </span>
                                        <span class="text-[10px] font-mono text-neutral-400">{res.tenant_lens_count} lente{res.tenant_lens_count !== 1 ? 's' : ''}</span>
                                    </div>
                                    <h5 class="font-bold text-neutral-900 dark:text-white text-sm leading-snug line-clamp-2 group-hover:text-primary-700 dark:group-hover:text-primary-300 transition-colors">
                                        {res.canonical_name}
                                    </h5>
                                    <p class="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                                        {res.material_display} · n={res.refractive_index}
                                    </p>
                                </div>

                                <!-- Tratamentos -->
                                <div class="px-4 py-2.5 flex-1 min-h-[42px]">
                                    {#if res.treatment_codes && res.treatment_codes.length > 0}
                                        <div class="flex flex-wrap gap-1">
                                            {#each res.treatment_codes as code (code)}
                                                <span class="px-1.5 py-0.5 rounded text-[10px] font-bold uppercase tracking-wide {tratamentoBadgeClass(code)}">
                                                    {formatarTratamento(code)}
                                                </span>
                                            {/each}
                                        </div>
                                    {:else}
                                        <span class="text-[11px] text-neutral-400 italic">Sem tratamentos adicionais</span>
                                    {/if}
                                </div>

                                <!-- Pricing -->
                                {#if res.price_min != null}
                                    <div class="px-4 py-2.5 bg-gradient-to-r from-primary-600 to-indigo-600">
                                        <div class="flex items-center justify-between">
                                            <div>
                                                <p class="text-[9px] text-white/70 uppercase font-bold tracking-widest">Faixa de Preço</p>
                                                <p class="text-white font-bold text-sm">
                                                    {formatarPreco(res.price_min)}{#if res.price_max && res.price_max !== res.price_min} — {formatarPreco(res.price_max)}{/if}
                                                </p>
                                            </div>
                                            {#if res.markup_min != null}
                                                <div class="text-right">
                                                    <p class="text-[9px] text-white/70 uppercase font-bold tracking-widest">Markup</p>
                                                    <p class="text-white font-bold text-xs">{res.markup_min?.toFixed(1)}x+</p>
                                                </div>
                                            {/if}
                                        </div>
                                    </div>
                                {:else}
                                    <div class="px-4 py-2 bg-neutral-100 dark:bg-neutral-800">
                                        <p class="text-[10px] text-neutral-400 font-medium">Sem pricing cadastrado</p>
                                    </div>
                                {/if}
                            </a>
                        {/each}
                    </div>
                </div>
            {/if}

            <!-- Premium results -->
            {#if mostrarPremium && resultadosPremium.length > 0}
                <div class="space-y-4">
                    <div class="flex items-center gap-3">
                        <Star size={16} class="text-amber-500" />
                        <h4 class="font-bold text-sm text-neutral-600 dark:text-neutral-400">Lentes Premium</h4>
                        <div class="h-px flex-1 bg-amber-200/60 dark:bg-amber-800/30"></div>
                        <span class="text-xs text-neutral-400 font-mono">{resultadosPremium.length} conceito{resultadosPremium.length !== 1 ? 's' : ''}</span>
                    </div>
                    <div class="grid sm:grid-cols-2 xl:grid-cols-3 gap-4">
                        {#each resultadosPremium as res (res.id)}
                            <a href="/catalogo/premium/{res.id}" class="result-card group border-amber-200 dark:border-amber-800/40 hover:border-amber-400 dark:hover:border-amber-500">
                                <!-- Header -->
                                <div class="px-4 pt-4 pb-3 bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950/20 dark:to-orange-950/20">
                                    <div class="flex items-start justify-between gap-2 mb-2">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-black tracking-wider font-mono bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300 border border-amber-200 dark:border-amber-700">
                                            {res.sku}
                                        </span>
                                        <span class="flex items-center gap-1 text-[10px] text-amber-500 font-bold">
                                            ★ <span class="text-neutral-400 font-normal font-mono">{res.tenant_lens_count}L</span>
                                        </span>
                                    </div>
                                    <h5 class="font-bold text-neutral-900 dark:text-white text-sm leading-snug line-clamp-2 group-hover:text-amber-700 dark:group-hover:text-amber-300 transition-colors">
                                        {res.canonical_name}
                                    </h5>
                                    <p class="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                                        {res.material_display} · n={res.refractive_index}
                                    </p>
                                </div>

                                <!-- Tratamentos -->
                                <div class="px-4 py-2.5 flex-1 min-h-[42px]">
                                    {#if res.treatment_codes && res.treatment_codes.length > 0}
                                        <div class="flex flex-wrap gap-1">
                                            {#each res.treatment_codes as code (code)}
                                                <span class="px-1.5 py-0.5 rounded text-[10px] font-bold uppercase tracking-wide {tratamentoBadgeClass(code)}">
                                                    {formatarTratamento(code)}
                                                </span>
                                            {/each}
                                        </div>
                                    {:else}
                                        <span class="text-[11px] text-neutral-400 italic">Sem tratamentos adicionais</span>
                                    {/if}
                                </div>

                                <!-- Pricing Premium -->
                                {#if res.price_min != null}
                                    <div class="px-4 py-2.5 bg-gradient-to-r from-amber-600 to-orange-600">
                                        <div class="flex items-center justify-between">
                                            <div>
                                                <p class="text-[9px] text-white/70 uppercase font-bold tracking-widest">Faixa de Preço</p>
                                                <p class="text-white font-bold text-sm">
                                                    {formatarPreco(res.price_min)}{#if res.price_max && res.price_max !== res.price_min} — {formatarPreco(res.price_max)}{/if}
                                                </p>
                                            </div>
                                            {#if res.markup_min != null}
                                                <div class="text-right">
                                                    <p class="text-[9px] text-white/70 uppercase font-bold tracking-widest">Markup</p>
                                                    <p class="text-white font-bold text-xs">{res.markup_min?.toFixed(1)}x+</p>
                                                </div>
                                            {/if}
                                        </div>
                                    </div>
                                {:else}
                                    <div class="px-4 py-2 bg-amber-50 dark:bg-amber-950/20">
                                        <p class="text-[10px] text-amber-500 font-medium">Sem pricing cadastrado</p>
                                    </div>
                                {/if}
                            </a>
                        {/each}
                    </div>
                </div>
            {/if}

        {:else if jaBuscou && totalResultados === 0 && !loading}
            <!-- Zero resultados -->
            <div class="text-center py-16 border-2 border-dashed border-neutral-200 dark:border-neutral-700 rounded-2xl">
                <div class="text-5xl mb-4">🔍</div>
                <h4 class="text-lg font-bold text-neutral-700 dark:text-neutral-300 mb-2">Nenhum conceito encontrado</h4>
                <p class="text-sm text-neutral-500 max-w-sm mx-auto">
                    Não encontramos conceitos compatíveis com essa receita. Tente ajustar os graus ou o tipo de lente.
                </p>
            </div>

        {:else if !jaBuscou && !loading}
            <!-- Estado inicial -->
            <div class="text-center py-16 opacity-60">
                <div class="text-5xl mb-4">👓</div>
                <p class="text-base text-neutral-500 dark:text-neutral-400 mb-1">
                    Preencha a receita e clique em <strong>Buscar Conceitos Compatíveis</strong>
                </p>
                <p class="text-sm text-neutral-400">
                    Retorna conceitos Standard (CST) e Premium (CPR) com faixa de preço do pricing_book
                </p>
            </div>
        {/if}

    </div>
</Container>

<style>
    /* ── Cards de Receita ────────────────────────────────────────────────────── */
    .receita-card {
        background: white;
        border-width: 1px;
        border-style: solid;
        border-radius: 1rem;
        overflow: hidden;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
        transition: box-shadow 0.2s;
    }

    :global(.dark) .receita-card {
        background: rgb(18, 18, 18);
    }

    .receita-header {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0.875rem 1.25rem;
    }

    .receita-body {
        padding: 1.25rem;
        display: grid;
        gap: 0.875rem;
    }

    /* ── Campos ──────────────────────────────────────────────────────────────── */
    .campo-receita {
        display: flex;
        flex-direction: column;
        gap: 0.35rem;
    }

    .campo-receita label {
        font-size: 0.65rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: rgb(115, 115, 115);
    }

    :global(.dark) .campo-receita label {
        color: rgb(140, 140, 140);
    }

    .select-receita {
        width: 100%;
        padding: 0.55rem 0.875rem;
        font-size: 0.9375rem;
        font-weight: 600;
        background: white;
        border: 1.5px solid rgba(0, 0, 0, 0.09);
        border-radius: 0.5rem;
        color: rgb(17, 24, 39);
        transition: border-color 0.15s, box-shadow 0.15s;
        cursor: pointer;
    }

    :global(.dark) .select-receita {
        background: rgb(23, 23, 23);
        border-color: rgba(255, 255, 255, 0.1);
        color: rgb(229, 231, 235);
    }

    .select-receita:focus {
        outline: none;
        border-color: rgb(99, 102, 241);
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12);
    }

    .select-receita:disabled {
        opacity: 0.4;
        cursor: not-allowed;
    }

    /* ── Tabela Preview ──────────────────────────────────────────────────────── */
    .preview-th {
        padding: 0.5rem 0.875rem;
        text-align: center;
        font-size: 0.65rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: rgb(180, 120, 20);
        border: 1px solid rgba(251, 191, 36, 0.15);
    }

    :global(.dark) .preview-th {
        color: rgb(217, 155, 48);
        border-color: rgba(251, 191, 36, 0.08);
    }

    .preview-td {
        padding: 0.6rem 0.875rem;
        text-align: center;
        font-family: "Courier New", monospace;
        font-size: 0.8125rem;
        font-weight: 600;
        color: rgb(17, 24, 39);
        border: 1px solid rgba(0, 0, 0, 0.04);
    }

    :global(.dark) .preview-td {
        color: rgb(229, 231, 235);
        border-color: rgba(255, 255, 255, 0.04);
    }

    .label-td {
        font-weight: 800;
        color: rgb(99, 102, 241);
        background: rgba(99, 102, 241, 0.05);
        font-size: 0.75rem;
    }

    :global(.dark) .label-td {
        color: rgb(129, 140, 248);
        background: rgba(99, 102, 241, 0.08);
    }

    /* ── Cards de Resultado ──────────────────────────────────────────────────── */
    .result-card {
        display: flex;
        flex-direction: column;
        background: white;
        border-width: 1.5px;
        border-style: solid;
        border-radius: 1rem;
        overflow: hidden;
        text-decoration: none;
        transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
    }

    :global(.dark) .result-card {
        background: rgb(18, 18, 18);
    }

    .result-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    }

    :global(.dark) .result-card:hover {
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
    }

    .line-clamp-2 {
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
</style>
