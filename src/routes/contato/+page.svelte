<script lang="ts">
  /**
   * Página de Contato - Interface de Contato e Suporte
   * Formulário para entrar em contato com a equipe
   */

  import { goto } from "$app/navigation";
  import type { PageData } from "./$types";

  // === Layout ===
  import Header from "$lib/components/layout/Header.svelte";

  import Container from "$lib/components/layout/Container.svelte";
  import PageHero from "$lib/components/layout/PageHero.svelte";
  import SectionHeader from "$lib/components/layout/SectionHeader.svelte";

  // === UI ===
  import Button from "$lib/components/ui/Button.svelte";
  import Badge from "$lib/components/ui/Badge.svelte";
  import LoadingSpinner from "$lib/components/ui/LoadingSpinner.svelte";

  // === Forms ===
  import Input from "$lib/components/forms/Input.svelte";
  import Select from "$lib/components/forms/Select.svelte";
  import Textarea from "$lib/components/forms/Textarea.svelte";

  // === Cards ===
  import StatsCard from "$lib/components/cards/StatsCard.svelte";
  import FeatureCard from "$lib/components/cards/FeatureCard.svelte";

  export let data: PageData;

  // Estado do formulário
  let formData = { ...data.form_fields };
  let isSubmitting = false;
  let submitted = false;
  let errors: Record<string, string> = {};

  // Validação do formulário
  function validateForm() {
    errors = {};

    if (!formData.nome.trim()) {
      errors.nome = "Nome é obrigatório";
    }

    if (!formData.email.trim()) {
      errors.email = "E-mail é obrigatório";
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      errors.email = "E-mail inválido";
    }

    if (!formData.assunto.trim()) {
      errors.assunto = "Assunto é obrigatório";
    }

    if (!formData.mensagem.trim()) {
      errors.mensagem = "Mensagem é obrigatória";
    }

    return Object.keys(errors).length === 0;
  }

  // Enviar formulário
  async function handleSubmit(event: Event) {
    event.preventDefault();

    if (!validateForm()) return;

    isSubmitting = true;

    try {
      // Simular envio (aqui seria integração com API real)
      await new Promise((resolve) => setTimeout(resolve, 2000));

      submitted = true;
      formData = { ...data.form_fields }; // Reset form
    } catch (error) {
      console.error("Erro ao enviar formulário:", error);
      errors.submit = "Erro ao enviar mensagem. Tente novamente.";
    } finally {
      isSubmitting = false;
    }
  }

  // Reset de confirmação
  function resetForm() {
    submitted = false;
    formData = { ...data.form_fields };
    errors = {};
  }
</script>

<svelte:head>
  <title>Contato - BestLens</title>
  <meta
    name="description"
    content="Entre em contato com nossa equipe de suporte e vendas"
  />
</svelte:head>

<div class="min-h-screen bg-neutral-50 dark:bg-neutral-900 transition-colors">
  <Header currentPage="contato" />

  <main>
    <Container maxWidth="xl" padding="md">
      <!-- Hero Section -->
      <PageHero
        badge="📞 Suporte e Contato"
        title="Entre em Contato"
        subtitle="Nossa equipe está pronta para ajudar você com qualquer dúvida"
        alignment="center"
        maxWidth="lg"
      />

      <!-- Status do Sistema -->
      <section class="mt-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <StatsCard
            title="Sistema"
            value={data.estatisticas.sistema_online ? "Online" : "Offline"}
            icon="🟢"
            color="green"
          />

          <StatsCard
            title="Usuários Ativos"
            value={data.estatisticas.usuarios_ativos}
            icon="👥"
            color="blue"
          />

          <StatsCard
            title="Configurações"
            value={data.estatisticas.configuracoes_ativas}
            icon="⚙️"
            color="orange"
          />

          <StatsCard
            title="Status"
            value="Operacional"
            icon="✅"
            color="gold"
          />
        </div>
      </section>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 mt-12">
        <!-- Formulário de Contato -->
        <section>
          <SectionHeader
            title="Envie sua Mensagem"
            subtitle="Preencha o formulário abaixo e responderemos em breve"
          />

          {#if submitted}
            <div
              class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-xl p-6 text-center"
            >
              <div class="text-4xl mb-4">✅</div>
              <h3
                class="text-lg font-semibold text-green-900 dark:text-green-100 mb-2"
              >
                Mensagem Enviada com Sucesso!
              </h3>
              <p class="text-green-700 dark:text-green-300 mb-4">
                Recebemos sua mensagem e responderemos em até 24 horas.
              </p>
              <Button variant="secondary" on:click={resetForm}>
                Enviar Nova Mensagem
              </Button>
            </div>
          {:else}
            <form on:submit={handleSubmit} class="space-y-6">
              <!-- Dados Pessoais -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <Input
                  bind:value={formData.nome}
                  label="Nome Completo"
                  placeholder="Seu nome..."
                  required
                  error={errors.nome}
                />

                <Input
                  bind:value={formData.email}
                  type="email"
                  label="E-mail"
                  placeholder="seu@email.com"
                  required
                  error={errors.email}
                />
              </div>

              <!-- Dados da Empresa -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <Input
                  bind:value={formData.empresa}
                  label="Empresa/Ótica"
                  placeholder="Nome da sua empresa..."
                />

                <Input
                  bind:value={formData.telefone}
                  type="tel"
                  label="Telefone"
                  placeholder="(11) 99999-9999"
                />
              </div>

              <!-- Tipo de Contato -->
              <Select
                bind:value={formData.tipo_contato}
                label="Tipo de Contato"
                options={data.tipos_contato}
                required
              />

              <!-- Assunto -->
              <Input
                bind:value={formData.assunto}
                label="Assunto"
                placeholder="Resumo do seu contato..."
                required
                error={errors.assunto}
              />

              <!-- Mensagem -->
              <Textarea
                bind:value={formData.mensagem}
                label="Mensagem"
                placeholder="Descreva sua dúvida ou necessidade..."
                rows={6}
                required
                error={errors.mensagem}
              />

              <!-- Erro de envio -->
              {#if errors.submit}
                <div
                  class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4"
                >
                  <p class="text-red-700 dark:text-red-300 text-sm">
                    {errors.submit}
                  </p>
                </div>
              {/if}

              <!-- Botão de envio -->
              <Button
                type="submit"
                variant="primary"
                fullWidth
                disabled={isSubmitting}
              >
                {#if isSubmitting}
                  <LoadingSpinner size="sm" color="white" />
                  Enviando...
                {:else}
                  📧 Enviar Mensagem
                {/if}
              </Button>
            </form>
          {/if}
        </section>

        <!-- Informações de Contato -->
        <section>
          <SectionHeader
            title="Informações de Contato"
            subtitle="Outros meios de entrar em contato conosco"
          />

          <div class="space-y-6">
            <!-- Dados da Empresa -->
            <div
              class="bg-white dark:bg-neutral-800 rounded-xl border border-neutral-200 dark:border-neutral-700 p-6"
            >
              <h3
                class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 mb-4"
              >
                {data.contato_info.empresa}
              </h3>

              <div class="space-y-3">
                <div class="flex items-center gap-3">
                  <span class="text-blue-600 dark:text-blue-400">📧</span>
                  <span class="text-neutral-700 dark:text-neutral-300">
                    {data.contato_info.email}
                  </span>
                </div>

                <div class="flex items-center gap-3">
                  <span class="text-green-600 dark:text-green-400">📞</span>
                  <span class="text-neutral-700 dark:text-neutral-300">
                    {data.contato_info.telefone}
                  </span>
                </div>

                <div class="flex items-center gap-3">
                  <span class="text-orange-600 dark:text-orange-400">📍</span>
                  <span class="text-neutral-700 dark:text-neutral-300">
                    {data.contato_info.endereco}
                  </span>
                </div>

                <div class="flex items-center gap-3">
                  <span class="text-purple-600 dark:text-purple-400">🕒</span>
                  <span class="text-neutral-700 dark:text-neutral-300">
                    {data.contato_info.horario_funcionamento}
                  </span>
                </div>
              </div>
            </div>

            <!-- Tipos de Suporte -->
            <div class="grid grid-cols-1 gap-4">
              <FeatureCard
                icon="🔧"
                title="Suporte Técnico"
                description="Ajuda com problemas técnicos e configurações do sistema"
              />

              <FeatureCard
                icon="💼"
                title="Suporte Comercial"
                description="Informações sobre planos, preços e contratação"
              />

              <FeatureCard
                icon="📚"
                title="Treinamento"
                description="Capacitação e treinamento para uso do sistema"
              />
            </div>

            <!-- Links Rápidos -->
            <div
              class="bg-gradient-to-r from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20 rounded-xl p-6"
            >
              <h4
                class="font-semibold text-neutral-900 dark:text-neutral-100 mb-4"
              >
                🚀 Links Úteis
              </h4>

              <div class="space-y-2">
                <Button
                  variant="ghost"
                  size="sm"
                  on:click={() => goto("/buscar")}
                >
                  🔍 Sistema de Busca
                </Button>

                <Button
                  variant="ghost"
                  size="sm"
                  on:click={() => goto("/analytics")}
                >
                  📊 Analytics
                </Button>

                <Button
                  variant="ghost"
                  size="sm"
                  on:click={() => goto("/historico")}
                >
                  📋 Histórico
                </Button>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Container>
  </main>
</div>
