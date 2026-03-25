<script lang="ts">
  /**
   * Layout Raiz
   * Inclui providers globais, layout sidebar e componentes persistentes
   *
   * O listener onAuthStateChange sincroniza mudanças de sessão (login,
   * logout, token refresh) com o SvelteKit data layer via invalidateAll().
   */

  import "../app.css";
  import ToastContainer from "$lib/components/feedback/ToastContainer.svelte";
  import MainLayout from "$lib/components/layout/MainLayout.svelte";
  import { onMount } from "svelte";
  import { theme } from "$lib/stores/theme";
  import { contrastStore, colorThemeStore } from "$lib/stores/colorSystem";
  import { page } from "$app/stores";
  import { invalidateAll } from "$app/navigation";

  // Inicializar tema, sistema de cores e listener de auth
  onMount(() => {
    theme.init();
    contrastStore.init();
    colorThemeStore.init();

    // Sincronizar mudanças de auth (login/logout/refresh) com SvelteKit
    const { data: { subscription } } = $page.data.supabase.auth.onAuthStateChange(
      (_event: string, session: { expires_at?: number } | null) => {
        if (session?.expires_at !== $page.data.session?.expires_at) {
          invalidateAll();
        }
      }
    );

    return () => subscription.unsubscribe();
  });
</script>

<!-- Layout Principal (Sidebar + Header + Content) -->
<!-- Auth é controlada pelo hooks.server.ts via Clearix Hub SSO -->
<MainLayout currentPage={$page.url.pathname}>
  <slot />
</MainLayout>

<!-- Toast Container (global) -->
<ToastContainer />
