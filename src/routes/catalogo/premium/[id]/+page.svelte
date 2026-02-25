<script lang="ts">
  import { goto } from "$app/navigation";
  import { fade, fly } from "svelte/transition";
  import type { PageData } from "./$types";

  // Componentes
  import Container from "$lib/components/layout/Container.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LenteCard from "$lib/components/catalogo/LenteCard.svelte";
  import {
    ChevronLeft,
    Crown,
    Zap,
    ShieldCheck,
    Info,
    ArrowRight,
    TrendingUp,
    CheckCircle2,
    Brain,
  } from "lucide-svelte";

  // Dados vindos do servidor (+page.server.ts)
  export let data: PageData;

  $: grupo = data.grupo;
  $: lentes = (data.lentes || []) as any[];

  // Estatísticas computadas
  $: precos = lentes
    .map((l: any) => l.price_suggested)
    .filter((p: number) => p > 0);
  $: precoMin = precos.length > 0 ? Math.min(...precos) : 0;
  $: precoMax = precos.length > 0 ? Math.max(...precos) : 0;
  $: precoMedio =
    precos.length > 0
      ? precos.reduce((a: number, b: number) => a + b, 0) / precos.length
      : 0;

  function formatarPreco(valor: number | null): string {
    if (!valor) return "-";
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(valor);
  }
</script>

<svelte:head>
  <title>{grupo?.name || "Conceito Premium"} | SIS Lens Oracle</title>
</svelte:head>

<main class="min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-20">
  <!-- Top Bar / Navigation -->
  <div
    class="bg-white dark:bg-neutral-800 border-b border-neutral-200 dark:border-neutral-700 sticky top-0 z-30"
  >
    <Container maxWidth="xl" padding="sm">
      <div class="flex items-center justify-between py-3">
        <button
          on:click={() => history.back()}
          class="flex items-center gap-2 text-neutral-500 hover:text-primary-600 transition-colors text-sm font-medium"
        >
          <ChevronLeft class="w-4 h-4" />
          Voltar ao Catálogo
        </button>
        <div class="flex items-center gap-2">
          <Badge variant="gold" class="flex items-center gap-1">
            <Crown class="w-3 h-3" /> Oracle Premium
          </Badge>
        </div>
      </div>
    </Container>
  </div>

  <Container maxWidth="xl" padding="lg">
    <!-- Hero Section -->
    <div class="mt-8 mb-12">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Main Info -->
        <div class="lg:col-span-2 space-y-6">
          <div in:fly={{ y: 20, duration: 500 }}>
            <div class="flex items-center gap-3 mb-4">
              <span
                class="px-3 py-1 bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400 text-xs font-bold rounded-full uppercase tracking-widest"
              >
                Segmento Premium
              </span>
              <span class="text-neutral-400">•</span>
              <span class="text-sm text-neutral-500 font-medium"
                >Ref: {grupo.id.substring(0, 8)}</span
              >
            </div>

            <h1
              class="text-3xl md:text-5xl font-black text-neutral-900 dark:text-white leading-tight mb-4"
            >
              {grupo.name}
            </h1>

            <div
              class="flex flex-wrap gap-4 text-neutral-600 dark:text-neutral-400"
            >
              <div
                class="flex items-center gap-2 bg-white dark:bg-neutral-800 px-4 py-2 rounded-xl shadow-sm border border-neutral-100 dark:border-neutral-700"
              >
                <Zap class="w-4 h-4 text-amber-500" />
                <span
                  class="font-bold text-neutral-900 dark:text-white capitalize"
                  >{(grupo.lens_type || "Desconhecido").replace("_", " ")}</span
                >
              </div>
              <div
                class="flex items-center gap-2 bg-white dark:bg-neutral-800 px-4 py-2 rounded-xl shadow-sm border border-neutral-100 dark:border-neutral-700"
              >
                <ShieldCheck class="w-4 h-4 text-blue-500" />
                <span class="font-bold text-neutral-900 dark:text-white"
                  >{grupo.material}</span
                >
              </div>
              <div
                class="flex items-center gap-2 bg-white dark:bg-neutral-800 px-4 py-2 rounded-xl shadow-sm border border-neutral-100 dark:border-neutral-700"
              >
                <TrendingUp class="w-4 h-4 text-green-500" />
                <span class="font-bold text-neutral-900 dark:text-white"
                  >n = {grupo.refractive_index}</span
                >
              </div>
            </div>
          </div>

          <!-- Description / Intel -->
          <div
            class="bg-white dark:bg-neutral-900 p-6 rounded-2xl border-l-4 border-amber-500"
            in:fade={{ delay: 200 }}
          >
            <div class="flex gap-4">
              <div
                class="p-3 bg-amber-50 dark:bg-amber-900/20 rounded-xl h-fit"
              >
                <Brain class="w-6 h-6 text-amber-600 dark:text-amber-400" />
              </div>
              <div>
                <h3
                  class="text-lg font-bold text-neutral-900 dark:text-white mb-1"
                >
                  Inteligência do Conceito
                </h3>
                <p
                  class="text-neutral-600 dark:text-neutral-400 leading-relaxed text-sm"
                >
                  Este conceito agrupa todas as lentes de padrão <strong
                    >Premium</strong
                  >
                  que compartilham a mesma física ótica. O SIS Oracle validou {lentes.length}
                  opções reais no seu mercado que atendem rigorosamente a esta especificação.
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Price Matrix Card -->
        <div in:fly={{ x: 20, duration: 500 }}>
          <div
            class="bg-gradient-to-br from-neutral-900 to-neutral-800 dark:from-black dark:to-neutral-900 text-white rounded-3xl p-8 shadow-2xl relative overflow-hidden h-full"
          >
            <div class="absolute -right-10 -bottom-10 opacity-10">
              <Crown size={200} />
            </div>

            <div class="relative z-10 space-y-8">
              <div>
                <p
                  class="text-amber-400 text-xs font-bold uppercase tracking-widest mb-2"
                >
                  Ticket Médio Premium
                </p>
                <h2 class="text-5xl font-black">{formatarPreco(precoMedio)}</h2>
              </div>

              <div class="space-y-4">
                <div
                  class="flex justify-between items-center text-sm border-b border-white/10 pb-2"
                >
                  <span class="opacity-60">Entrada Premium</span>
                  <span class="font-bold text-amber-200"
                    >{formatarPreco(precoMin)}</span
                  >
                </div>
                <div
                  class="flex justify-between items-center text-sm border-b border-white/10 pb-2"
                >
                  <span class="opacity-60">Pico de Mercado</span>
                  <span class="font-bold text-amber-200"
                    >{formatarPreco(precoMax)}</span
                  >
                </div>
                <div class="flex justify-between items-center text-sm">
                  <span class="opacity-60">Opções Disponíveis</span>
                  <span class="font-bold">{lentes.length}</span>
                </div>
              </div>

              <Button
                variant="primary"
                fullWidth
                class="!bg-amber-500 !text-black hover:!bg-amber-400 font-bold py-4 rounded-xl"
              >
                Simular venda com este grupo
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Features & Technical Ranges -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16">
      <div class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 p-8 rounded-2xl h-full">
        <SectionHeader
          title="🧬 Especificações Fisiológicas"
          subtitle="Range de fabricação garantido"
        />
        <div class="grid grid-cols-2 gap-6 mt-8">
          <div class="space-y-1">
            <p
              class="text-[10px] text-neutral-400 uppercase font-black tracking-widest"
            >
              Esférico
            </p>
            <p class="text-xl font-bold dark:text-white">
              {grupo.spherical_min
                ? (grupo.spherical_min > 0 ? "+" : "") + grupo.spherical_min
                : "—"} a
              {grupo.spherical_max
                ? (grupo.spherical_max > 0 ? "+" : "") + grupo.spherical_max
                : "—"}
            </p>
          </div>
          <div class="space-y-1">
            <p
              class="text-[10px] text-neutral-400 uppercase font-black tracking-widest"
            >
              Cilíndrico
            </p>
            <p class="text-xl font-bold dark:text-white">
              {grupo.cylindrical_min || "—"} a {grupo.cylindrical_max || "—"}
            </p>
          </div>
          <div class="space-y-1">
            <p
              class="text-[10px] text-neutral-400 uppercase font-black tracking-widest"
            >
              Adição
            </p>
            <p class="text-xl font-bold dark:text-white">
              {grupo.addition_min ? "+" + grupo.addition_min : "—"} a
              {grupo.addition_max ? "+" + grupo.addition_max : "—"}
            </p>
          </div>
          <div class="space-y-1">
            <p
              class="text-[10px] text-neutral-400 uppercase font-black tracking-widest"
            >
              Tratamentos inclusos
            </p>
            <div class="flex flex-wrap gap-2 mt-2">
              {#if grupo.anti_reflective}<Badge variant="info" size="sm"
                  >Antirreflexo</Badge
                >{/if}
              {#if grupo.blue_light}<Badge variant="primary" size="sm"
                  >Blue Cut</Badge
                >{/if}
              {#if grupo.photochromic && grupo.photochromic !== "nenhum"}<Badge
                  variant="success"
                  size="sm">{grupo.photochromic}</Badge
                >{/if}
            </div>
          </div>
        </div>
      </div>

      <div
        class="bg-white dark:bg-neutral-900 border border-neutral-200 dark:border-neutral-700 p-8 rounded-2xl h-full flex flex-col justify-center"
      >
        <div class="text-center space-y-4">
          <div
            class="inline-flex items-center justify-center p-4 bg-green-50 dark:bg-green-900/20 rounded-full mb-2"
          >
            <CheckCircle2 class="w-8 h-8 text-green-600 dark:text-green-400" />
          </div>
          <h3 class="text-2xl font-black text-neutral-900 dark:text-white">
            Conceito Homologado
          </h3>
          <p class="text-neutral-500 text-sm max-w-xs mx-auto">
            Este agrupamento passou pelos filtros de colisão ótica. Somente
            lentes com 100% de paridade técnica estão listadas abaixo.
          </p>
        </div>
      </div>
    </div>

    <!-- List of Real Lenses -->
    <div class="space-y-8">
      <SectionHeader
        title="🔍 Lentes Reais Mapeadas"
        subtitle="As opções comerciais abaixo compõem este conceito. O preço exibido já inclui regras de markup do seu tenant."
      />

      <div
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
      >
        {#each lentes as lente, i (lente.id)}
          <div in:fly={{ y: 30, delay: i * 50, duration: 500 }}>
            <div class="relative group">
              <LenteCard {lente} />

              <div
                class="absolute top-2 right-2 flex items-center gap-1 px-2 py-1 bg-white/90 dark:bg-neutral-800/90 backdrop-blur rounded-lg text-[10px] font-black border border-neutral-200 dark:border-neutral-700 shadow-sm opacity-0 group-hover:opacity-100 transition-opacity"
              >
                <ShieldCheck class="w-3 h-3 text-green-500" />
                CONFIDENCE: {Math.round((lente.confidence_score || 1) * 100)}%
              </div>
            </div>
          </div>
        {/each}
      </div>
    </div>
  </Container>
</main>

<style>
</style>
