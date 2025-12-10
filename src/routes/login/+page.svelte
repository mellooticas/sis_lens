<script lang="ts">
  import { goto } from "$app/navigation";
  import Button from "$lib/components/ui/Button.svelte";
  import Input from "$lib/components/ui/Input.svelte";
  import Logo from "$lib/components/layout/Logo.svelte";

  let email = "";
  let password = "";
  let isLoading = false;
  let error = "";

  async function handleLogin() {
    isLoading = true;
    error = "";

    try {
      // TODO: Implementar login real com Supabase
      await new Promise((resolve) => setTimeout(resolve, 1500));

      // Simulação de sucesso
      goto("/dashboard");
    } catch (e) {
      error = "Erro ao realizar login. Tente novamente.";
    } finally {
      isLoading = false;
    }
  }
</script>

<svelte:head>
  <title>Login - SIS Lens</title>
</svelte:head>

<div
  class="min-h-screen flex items-center justify-center bg-neutral-50 dark:bg-neutral-900 px-4"
>
  <div class="w-full max-w-md">
    <!-- Card de Login -->
    <div
      class="bg-white dark:bg-neutral-800 rounded-2xl shadow-xl p-8 space-y-8 border border-neutral-100 dark:border-neutral-700"
    >
      <!-- Cabeçalho -->
      <div class="text-center space-y-2">
        <div class="flex justify-center mb-6">
          <Logo size="lg" />
        </div>
        <h1 class="text-2xl font-bold text-neutral-900 dark:text-white">
          Bem-vindo de volta
        </h1>
        <p class="text-neutral-500 dark:text-neutral-400">
          Acesse sua conta para continuar
        </p>
      </div>

      <!-- Formulário -->
      <form on:submit|preventDefault={handleLogin} class="space-y-6">
        <div class="space-y-4">
          <div class="space-y-2">
            <label
              for="email"
              class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
              >Email</label
            >
            <Input
              type="email"
              id="email"
              placeholder="seu@email.com"
              bind:value={email}
              required
            />
          </div>

          <div class="space-y-2">
            <div class="flex justify-between items-center">
              <label
                for="password"
                class="text-sm font-medium text-neutral-700 dark:text-neutral-300"
                >Senha</label
              >
              <a
                href="/recuperar-senha"
                class="text-sm font-medium text-brand-blue-600 hover:text-brand-blue-500"
                >Esqueceu a senha?</a
              >
            </div>
            <Input
              type="password"
              id="password"
              placeholder="••••••••"
              bind:value={password}
              required
            />
          </div>
        </div>

        {#if error}
          <div class="p-3 bg-red-50 text-red-600 text-sm rounded-lg">
            {error}
          </div>
        {/if}

        <Button
          type="submit"
          variant="primary"
          fullWidth
          size="lg"
          disabled={isLoading}
        >
          {#if isLoading}
            <span class="animate-spin mr-2">⏳</span> Entrando...
          {:else}
            Entrar
          {/if}
        </Button>
      </form>

      <!-- Rodapé -->
      <div class="text-center text-sm text-neutral-500">
        Não tem uma conta?
        <a
          href="/cadastro"
          class="font-medium text-brand-blue-600 hover:text-brand-blue-500"
          >Solicite acesso</a
        >
      </div>
    </div>

    <p class="text-center text-xs text-neutral-400 mt-8">
      &copy; 2024 SIS Lens Intelligence. Todos os direitos reservados.
    </p>
  </div>
</div>
