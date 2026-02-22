<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import {
    Search,
    RotateCcw,
    DollarSign,
    Stethoscope,
    Factory,
    ChevronDown,
    ChevronUp,
    Info,
  } from "lucide-svelte";
  import { slide } from "svelte/transition";
  import Button from "$lib/components/ui/Button.svelte";

  export let filters: any = {};
  export let loading = false;
  export let totalResults = 0;

  const dispatch = createEventDispatcher();

  // Opções para os selects (Valores em EN para o novo banco)
  const types = [
    { value: "single_vision", label: "Visão Simples" },
    { value: "bifocal", label: "Bifocal" },
    { value: "multifocal", label: "Multifocal" },
    { value: "reading", label: "Leitura" },
    { value: "occupational", label: "Ocupacional" },
  ];

  const materials = [
    { value: "cr39", label: "CR-39" },
    { value: "polycarbonate", label: "Policarbonato" },
    { value: "trivex", label: "Trivex" },
    { value: "high_index", label: "Alto Índice" },
    { value: "glass", label: "Vidro" },
  ];

  const categories = [
    { value: "standard", label: "Standard" },
    { value: "premium", label: "Premium" },
  ];

  const indices = [
    { value: 1.5, label: "1.50" },
    { value: 1.53, label: "1.53" },
    { value: 1.56, label: "1.56" },
    { value: 1.59, label: "1.59" },
    { value: 1.61, label: "1.61" },
    { value: 1.67, label: "1.67" },
    { value: 1.74, label: "1.74" },
  ];

  const priceRanges = [
    { value: "all", label: "Todos os preços" },
    { value: "0-300", label: "Até R$ 300" },
    { value: "300-600", label: "R$ 300 - 600" },
    { value: "600-1000", label: "R$ 600 - 1.000" },
    { value: "1000-3000", label: "R$ 1.000 - 3.000" },
    { value: "3000+", label: "Acima de R$ 3.000" },
  ];

  const labs = [
    "Brascor",
    "Sygma",
    "Polylux",
    "Express",
    "So Blocos",
    "Hoya",
    "Braslentes",
    "High Vision",
  ];

  // Valores selecionados
  let selectedType = "";
  let selectedMaterial = "";
  let selectedCategory = "";
  let selectedIndex = "";
  let selectedPriceRange = "all";
  let searchText = filters.busca || "";
  let selectedLabs: string[] = [];

  // Graus
  let esf: number | null = null;
  let cil: number | null = null;
  let add: number | null = null;

  let hasAR = false;
  let hasBlue = false;
  let hasFoto = false;
  let hasPolar = false;
  let onlyPremium = false;

  let showAdvancedGrades = false;

  // Aplicar filtros quando mudar
  function applyFilters() {
    const newFilters: any = { busca: searchText };

    if (selectedType) newFilters.tipos = [selectedType];
    if (selectedMaterial) newFilters.materiais = [selectedMaterial];
    if (selectedCategory) newFilters.categorias = [selectedCategory];
    if (selectedIndex) newFilters.indices = [selectedIndex];

    // Filtro Premium
    if (onlyPremium) {
      newFilters.marca_premium = true;
    }

    if (selectedPriceRange !== "all") {
      if (selectedPriceRange === "3000+") {
        newFilters.preco = { min: 3000 };
      } else {
        const parts = selectedPriceRange.split("-");
        if (parts.length === 2) {
          newFilters.preco = { min: Number(parts[0]), max: Number(parts[1]) };
        }
      }
    }

    if (selectedLabs.length > 0) {
      newFilters.fornecedores = selectedLabs;
    }

    if (esf !== null || cil !== null || add !== null) {
      newFilters.graus = {};
      if (esf !== null) newFilters.graus.esferico = esf;
      if (cil !== null) newFilters.graus.cilindrico = cil;
      if (add !== null) newFilters.graus.adicao = add;
    }

    // Tratamentos como filtros booleanos diretos
    const tratamentos: any = {};
    if (hasAR) tratamentos.ar = true;
    if (hasBlue) tratamentos.blue = true;
    if (hasPolar) tratamentos.polarizado = true;

    // Fotossensivel é um enum/string, não boolean
    if (hasFoto) tratamentos.fotossensivel = true;

    if (Object.keys(tratamentos).length > 0) {
      newFilters.tratamentos = tratamentos;
    }

    dispatch("change", newFilters);
  }

  function clearFilters() {
    selectedType = "";
    selectedMaterial = "";
    selectedCategory = "";
    selectedIndex = "";
    selectedPriceRange = "all";
    searchText = "";
    selectedLabs = [];
    esf = null;
    cil = null;
    add = null;
    hasAR = false;
    hasBlue = false;
    hasFoto = false;
    hasPolar = false;
    onlyPremium = false;
    dispatch("clear");
  }

  function toggleLab(lab: string) {
    if (selectedLabs.includes(lab)) {
      selectedLabs = selectedLabs.filter((l) => l !== lab);
    } else {
      selectedLabs = [...selectedLabs, lab];
    }
    applyFilters();
  }

  $: hasActiveFilters =
    selectedType ||
    selectedMaterial ||
    selectedIndex ||
    selectedPriceRange !== "all" ||
    searchText ||
    hasAR ||
    hasBlue ||
    hasFoto ||
    hasPolar ||
    onlyPremium ||
    selectedLabs.length > 0 ||
    esf !== null ||
    cil !== null ||
    add !== null;
</script>

<div class="glass-panel rounded-xl p-6">
  <!-- Grid de Filtros Compactos -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
    <!-- Busca Textual (Full Width em mobile) -->
    <div class="md:col-span-2 lg:col-span-5">
      <div class="relative">
        <Search
          class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400"
        />
        <input
          type="text"
          placeholder="Buscar por nome, marca ou código..."
          class="w-full pl-10 pr-4 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 outline-none transition-all"
          bind:value={searchText}
          on:input={applyFilters}
        />
      </div>
    </div>

    <!-- Tipo de Lente -->
    <div>
      <label
        class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5"
        >Tipo</label
      >
      <select
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 outline-none transition-all cursor-pointer"
        bind:value={selectedType}
        on:change={applyFilters}
      >
        <option value="">Todos os tipos</option>
        {#each types as type}
          <option value={type.value}>{type.label}</option>
        {/each}
      </select>
    </div>

    <!-- Material -->
    <div>
      <label
        class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5"
        >Material</label
      >
      <select
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 outline-none transition-all cursor-pointer"
        bind:value={selectedMaterial}
        on:change={applyFilters}
      >
        <option value="">Todos os materiais</option>
        {#each materials as mat}
          <option value={mat.value}>{mat.label}</option>
        {/each}
      </select>
    </div>

    <!-- Categoria -->
    <div>
      <label
        class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5"
        >Categoria</label
      >
      <select
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 outline-none transition-all cursor-pointer"
        bind:value={selectedCategory}
        on:change={applyFilters}
      >
        <option value="">Todas as categorias</option>
        {#each categories as cat}
          <option value={cat.value}>{cat.label}</option>
        {/each}
      </select>
    </div>

    <!-- Índice -->
    <div>
      <label
        class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5"
        >Índice</label
      >
      <select
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 outline-none transition-all cursor-pointer"
        bind:value={selectedIndex}
        on:change={applyFilters}
      >
        <option value="">Todos os índices</option>
        {#each indices as idx}
          <option value={idx.value}>{idx.label}</option>
        {/each}
      </select>
    </div>

    <!-- Faixa de Preço -->
    <div>
      <label
        class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-1.5"
        >Preço</label
      >
      <select
        class="w-full px-3 py-2.5 text-sm bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-primary-500/20 focus:border-primary-500 outline-none transition-all cursor-pointer"
        bind:value={selectedPriceRange}
        on:change={applyFilters}
      >
        {#each priceRanges as range}
          <option value={range.value}>{range.label}</option>
        {/each}
      </select>
    </div>
  </div>

  <!-- Nova Seção: Laboratórios (Multi-select visual) -->
  <div class="border-t border-neutral-200 dark:border-neutral-700 pt-4 mb-6">
    <div class="flex items-center gap-2 mb-3">
      <Factory class="w-4 h-4 text-primary-600 dark:text-primary-400" />
      <label
        class="text-xs font-medium text-neutral-900 dark:text-neutral-100 uppercase tracking-wider"
        >Laboratórios / Marcas</label
      >
    </div>
    <div class="flex flex-wrap gap-2">
      {#each labs as lab}
        <button
          on:click={() => toggleLab(lab)}
          class="px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-300 border
            {selectedLabs.includes(lab)
            ? 'bg-primary-600 border-primary-600 text-white shadow-md'
            : 'bg-neutral-50 dark:bg-neutral-800 border-neutral-200 dark:border-neutral-700 text-neutral-600 dark:text-neutral-400 hover:border-primary-300'}"
        >
          {lab}
        </button>
      {/each}
    </div>
  </div>

  <!-- Nova Seção: Dioptrias (O que o paciente precisa?) -->
  <div class="border-t border-neutral-200 dark:border-neutral-700 pt-4 mb-6">
    <div
      class="flex items-center justify-between cursor-pointer group"
      on:click={() => (showAdvancedGrades = !showAdvancedGrades)}
      role="button"
      tabindex="0"
      on:keydown={(e) =>
        e.key === "Enter" && (showAdvancedGrades = !showAdvancedGrades)}
    >
      <div class="flex items-center gap-2">
        <Stethoscope
          class="w-4 h-4 text-brand-gold-600 dark:text-brand-gold-400"
        />
        <label
          class="text-xs font-medium text-neutral-900 dark:text-neutral-100 uppercase tracking-wider"
          >Filtrar por Receita (Grau)</label
        >
      </div>
      <div class="flex items-center gap-2 text-neutral-500">
        <span
          class="text-[10px] font-medium opacity-0 group-hover:opacity-100 transition-opacity"
        >
          {showAdvancedGrades ? "RECOLHER" : "CONFIGURAR GRAU"}
        </span>
        {#if showAdvancedGrades}
          <ChevronUp class="w-4 h-4" />
        {:else}
          <ChevronDown class="w-4 h-4" />
        {/if}
      </div>
    </div>

    {#if showAdvancedGrades}
      <div
        transition:slide
        class="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-6 p-4 bg-neutral-50 dark:bg-neutral-900/50 rounded-xl border border-dashed border-neutral-200 dark:border-neutral-700"
      >
        <!-- Esférico -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <label
              class="text-xs font-semibold text-neutral-700 dark:text-neutral-300"
              >Esférico (SPH)</label
            >
            {#if esf !== null}
              <button
                class="text-[10px] text-primary-600 hover:underline"
                on:click={() => {
                  esf = null;
                  applyFilters();
                }}>Limpar</button
              >
            {/if}
          </div>
          <div class="relative">
            <input
              type="number"
              step="0.25"
              placeholder="0.00"
              class="w-full px-3 py-2 text-center font-mono font-bold bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-gold-500/20 outline-none"
              bind:value={esf}
              on:input={applyFilters}
            />
          </div>
          <p class="text-[10px] text-neutral-500 text-center italic">
            Ex: -2.00 ou +4.25
          </p>
        </div>

        <!-- Cilíndrico -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <label
              class="text-xs font-semibold text-neutral-700 dark:text-neutral-300"
              >Cilíndrico (CYL)</label
            >
            {#if cil !== null}
              <button
                class="text-[10px] text-primary-600 hover:underline"
                on:click={() => {
                  cil = null;
                  applyFilters();
                }}>Limpar</button
              >
            {/if}
          </div>
          <div class="relative">
            <input
              type="number"
              step="0.25"
              max="0"
              placeholder="0.00"
              class="w-full px-3 py-2 text-center font-mono font-bold bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-gold-500/20 outline-none"
              bind:value={cil}
              on:input={applyFilters}
            />
          </div>
          <p class="text-[10px] text-neutral-500 text-center italic">
            Sempre negativo (ex: -0.75)
          </p>
        </div>

        <!-- Adição -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <label
              class="text-xs font-semibold text-neutral-700 dark:text-neutral-300"
              >Adição (ADD)</label
            >
            {#if add !== null}
              <button
                class="text-[10px] text-primary-600 hover:underline"
                on:click={() => {
                  add = null;
                  applyFilters();
                }}>Limpar</button
              >
            {/if}
          </div>
          <div class="relative">
            <input
              type="number"
              step="0.25"
              min="0"
              placeholder="0.00"
              class="w-full px-3 py-2 text-center font-mono font-bold bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-lg focus:ring-2 focus:ring-brand-gold-500/20 outline-none"
              bind:value={add}
              on:input={applyFilters}
            />
          </div>
          <p class="text-[10px] text-neutral-500 text-center italic">
            Para multifocais (ex: 2.00)
          </p>
        </div>

        <div
          class="sm:col-span-3 flex items-start gap-2 text-neutral-500 text-[10px]"
        >
          <Info class="w-3 h-3 mt-0.5 flex-shrink-0" />
          <p>
            O sistema filtrará apenas as lentes que suportam fisicamente o grau
            informado nos seus respectivos ranges de fabricação.
          </p>
        </div>
      </div>
    {/if}
  </div>

  <!-- Tratamentos (Checkboxes Horizontais com Indicador Premium) -->
  <div class="border-t border-neutral-200 dark:border-neutral-700 pt-4">
    <label
      class="block text-xs font-medium text-neutral-600 dark:text-neutral-400 mb-3"
      >Tratamentos</label
    >
    <div class="flex flex-wrap gap-3">
      <!-- Filtro Premium (Destaque) -->
      <label
        class="inline-flex items-center gap-2 cursor-pointer group px-3 py-2 rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800/50"
      >
        <input
          type="checkbox"
          class="w-4 h-4 rounded border-amber-300 dark:border-amber-700 text-amber-600 focus:ring-2 focus:ring-amber-500/20 transition-all cursor-pointer"
          bind:checked={onlyPremium}
          on:change={applyFilters}
        />
        <span
          class="text-sm font-semibold text-amber-700 dark:text-amber-400 group-hover:text-amber-800 dark:group-hover:text-amber-300 transition-colors"
          >🔒 Apenas Premium</span
        >
      </label>

      <!-- Antirreflexo (Standard + Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input
          type="checkbox"
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-primary-600 focus:ring-2 focus:ring-primary-500/20 transition-all cursor-pointer"
          bind:checked={hasAR}
          on:change={applyFilters}
        />
        <span
          class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors"
          >💨 Antirreflexo</span
        >
        <span
          class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400"
          >620</span
        >
      </label>

      <!-- Blue Light (Standard + Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input
          type="checkbox"
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-primary-600 focus:ring-2 focus:ring-primary-500/20 transition-all cursor-pointer"
          bind:checked={hasBlue}
          on:change={applyFilters}
        />
        <span
          class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors"
          >🔵 Blue Light</span
        >
        <span
          class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400"
          >466</span
        >
      </label>

      <!-- Fotossensível (Transitions + Acclimates = Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input
          type="checkbox"
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-primary-600 focus:ring-2 focus:ring-primary-500/20 transition-all cursor-pointer"
          bind:checked={hasFoto}
          on:change={applyFilters}
        />
        <span
          class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors"
          >📷 Fotossensível</span
        >
        <span
          class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400"
          >382</span
        >
      </label>

      <!-- Polarizado (Standard + Premium) -->
      <label class="inline-flex items-center gap-2 cursor-pointer group">
        <input
          type="checkbox"
          class="w-4 h-4 rounded border-neutral-300 dark:border-neutral-600 text-primary-600 focus:ring-2 focus:ring-primary-500/20 transition-all cursor-pointer"
          bind:checked={hasPolar}
          on:change={applyFilters}
        />
        <span
          class="text-sm text-neutral-700 dark:text-neutral-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors"
          >😎 Polarizado</span
        >
        <span
          class="text-xs px-1.5 py-0.5 rounded-full bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-400"
          >60</span
        >
      </label>
    </div>

    <!-- Legenda de Tipos -->
    <div
      class="mt-3 flex items-center gap-4 text-xs text-neutral-600 dark:text-neutral-400"
    >
      <span>💨 = Standard</span>
      <span>🔒 = Premium</span>
    </div>
  </div>

  <!-- Footer com info e botão limpar -->
  <div
    class="flex items-center justify-between mt-6 pt-4 border-t border-neutral-200 dark:border-neutral-700"
  >
    <div class="text-sm text-neutral-600 dark:text-neutral-400">
      <span class="font-semibold text-primary-600 dark:text-primary-400"
        >{loading ? "..." : totalResults}</span
      > lentes encontradas
    </div>
    {#if hasActiveFilters}
      <Button variant="ghost" size="sm" on:click={clearFilters}>
        <RotateCcw class="w-3.5 h-3.5 mr-1.5" />
        Limpar Filtros
      </Button>
    {/if}
  </div>
</div>
