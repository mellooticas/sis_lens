<script lang="ts">
    import { goto } from "$app/navigation";
    import Container from "$lib/components/layout/Container.svelte";
    import PageHero from "$lib/components/layout/PageHero.svelte";
    import SectionHeader from "$lib/components/layout/SectionHeader.svelte";
    import ActionCard from "$lib/components/cards/ActionCard.svelte";
    import Button from "$lib/components/ui/Button.svelte";

    // Mock data for settings functionality
    const systemVersion = "1.2.0";
</script>

<svelte:head>
    <title>Configurações - SIS Lens</title>
</svelte:head>

<main>
    <Container maxWidth="xl" padding="md">
            <!-- Hero -->
            <PageHero
                badge="⚙️ Sistema"
                title="Configurações"
                subtitle="Gerencie preferências, usuários e parâmetros do sistema"
            />

            <!-- Settings Groups -->
            <section class="mt-8 space-y-12">
                <!-- Geral -->
                <div>
                    <SectionHeader
                        title="Geral"
                        subtitle="Configurações básicas da aplicação"
                    />
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6"
                    >
                        <ActionCard
                            icon="👤"
                            title="Perfil de Usuário"
                            description="Gerencie seus dados e senha"
                            actionLabel="Editar Perfil"
                            color="blue"
                            on:click={() => goto("/perfil")}
                        />
                        <ActionCard
                            icon="bell"
                            title="Notificações"
                            description="Preferências de alertas e avisos"
                            actionLabel="Configurar"
                            color="orange"
                            on:click={() => goto("/notificacoes")}
                        />
                        <ActionCard
                            icon="🎨"
                            title="Aparência"
                            description="Tema e customização visual"
                            actionLabel="Personalizar"
                            color="purple"
                            on:click={() => goto("/aparencia")}
                        />
                    </div>
                </div>

                <!-- Negócio -->
                <div>
                    <SectionHeader
                        title="Negócio"
                        subtitle="Parâmetros comerciais e integradores"
                    />
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6"
                    >
                        <ActionCard
                            icon="🏢"
                            title="Fornecedores"
                            description="Gerenciar laboratórios parceiros"
                            actionLabel="Gerenciar"
                            color="green"
                            on:click={() => goto("/fornecedores")}
                        />
                        <ActionCard
                            icon="gavel"
                            title="Regras de Negócio"
                            description="Margens, markups e regras de preço"
                            actionLabel="Ajustar Regras"
                            color="blue"
                            on:click={() => goto("/comercial")}
                        />
                        <ActionCard
                            icon="key"
                            title="Integrações"
                            description="Chaves de API e conexões externas"
                            actionLabel="Gerenciar APIs"
                            color="orange"
                            on:click={() => goto("/integracoes")}
                        />
                    </div>
                </div>

                <!-- Sistema -->
                <div>
                    <SectionHeader
                        title="Sistema"
                        subtitle="Manutenção e informações"
                    />
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-6"
                    >
                        <ActionCard
                            icon="database"
                            title="Banco de Dados"
                            description="Status e manutenção de dados"
                            actionLabel="Ver Status"
                            color="red"
                            on:click={() => goto("/sistema/banco")}
                        />
                        <ActionCard
                            icon="users"
                            title="Usuários e Permissões"
                            description="Gerenciar acesso ao sistema"
                            actionLabel="Gerenciar"
                            color="blue"
                            on:click={() => goto("/usuarios")}
                        />
                        <div
                            class="glass-panel p-6 rounded-xl flex flex-col items-center justify-center text-center space-y-4"
                        >
                            <div
                                class="p-3 rounded-full bg-neutral-100 dark:bg-neutral-800 text-neutral-500"
                            >
                                ℹ️
                            </div>
                            <div>
                                <h3
                                    class="font-bold text-neutral-900 dark:text-neutral-100"
                                >
                                    Versão do Sistema
                                </h3>
                                <p class="text-sm text-neutral-500 mt-1">
                                    v{systemVersion}
                                </p>
                            </div>
                            <Button
                                variant="ghost"
                                size="sm"
                                on:click={() => window.location.reload()}
                            >
                                Verificar Atualizações
                            </Button>
                        </div>
                    </div>
                </div>
            </section>
        </Container>
    </main>
