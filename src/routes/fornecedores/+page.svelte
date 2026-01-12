<script lang="ts">
  /**
   * 🏭 Página de Fornecedores - Gestão de Laboratórios
   * Exibe informações completas dos fornecedores cadastrados
   */
  
  import { onMount } from 'svelte';
  import { FornecedoresAPI, type FornecedorComEstatisticas } from '$lib/api/fornecedores-api';
  import GlassCard from '$lib/components/ui/GlassCard.svelte';
  import PageHero from '$lib/components/layout/PageHero.svelte';
  import { Package, Clock, Layers } from 'lucide-svelte';
  
  let fornecedores: FornecedorComEstatisticas[] = [];
  let loading = true;
  let error = '';
  
  onMount(async () => {
    await carregarFornecedores();
  });
  
  async function carregarFornecedores() {
    loading = true;
    error = '';
    
    try {
      const response = await FornecedoresAPI.buscarFornecedores();
      
      if (response.success && response.data) {
        fornecedores = response.data;
        console.log('✅ Fornecedores carregados:', fornecedores.length);
      } else {
        error = response.error || 'Erro ao carregar fornecedores';
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'Erro ao carregar dados';
      console.error('❌ Erro ao carregar fornecedores:', err);
    } finally {
      loading = false;
    }
  }
  
  function formatarPrazo(dias: number | null | undefined): string {
    if (!dias) return 'N/A';
    return `${dias} dia${dias > 1 ? 's' : ''}`;
  }
</script>

<div class="page-fornecedores">
  <PageHero 
    title="🏭 Fornecedores"
    description="Gestão de laboratórios e fornecedores de lentes"
  />
  
  {#if loading}
    <div class="loading">
      <GlassCard variant="light" blur="md" padding="lg">
        <p>Carregando fornecedores...</p>
      </GlassCard>
    </div>
  {:else if error}
    <div class="error">
      <GlassCard variant="light" blur="md" padding="lg">
        <p class="error-message">❌ {error}</p>
      </GlassCard>
    </div>
  {:else if fornecedores.length === 0}
    <div class="empty">
      <GlassCard variant="light" blur="md" padding="lg">
        <p>Nenhum fornecedor encontrado</p>
      </GlassCard>
    </div>
  {:else}
    <div class="content">
      
      <!-- Estatísticas Gerais -->
      <div class="stats-grid">
        <GlassCard variant="light" blur="md" padding="md">
          <div class="stat-card">
            <div class="stat-icon">
              <Package size={24} />
            </div>
            <div class="stat-info">
              <h3 class="stat-value">{fornecedores.length}</h3>
              <p class="stat-label">Fornecedores Ativos</p>
            </div>
          </div>
        </GlassCard>
        
        <GlassCard variant="light" blur="md" padding="md">
          <div class="stat-card">
            <div class="stat-icon">
              <Layers size={24} />
            </div>
            <div class="stat-info">
              <h3 class="stat-value">
                {fornecedores.reduce((sum, f) => sum + f.total_lentes, 0)}
              </h3>
              <p class="stat-label">Total de Lentes</p>
            </div>
          </div>
        </GlassCard>
        
        <GlassCard variant="light" blur="md" padding="md">
          <div class="stat-card">
            <div class="stat-icon">
              <Clock size={24} />
            </div>
            <div class="stat-info">
              <h3 class="stat-value">
                {Math.round(
                  fornecedores
                    .filter(f => f.prazo_visao_simples)
                    .reduce((sum, f) => sum + (f.prazo_visao_simples || 0), 0) / 
                  fornecedores.filter(f => f.prazo_visao_simples).length
                ) || 0}
              </h3>
              <p class="stat-label">Prazo Médio (dias)</p>
            </div>
          </div>
        </GlassCard>
      </div>
      
      <!-- Lista de Fornecedores -->
      <section class="fornecedores-section">
        <h2 class="section-title">Lista de Fornecedores</h2>
        
        <div class="fornecedores-grid">
          {#each fornecedores as fornecedor}
            <GlassCard variant="light" blur="md" padding="lg" className="fornecedor-card">
              
              <!-- Header -->
              <div class="fornecedor-header">
                <div class="fornecedor-info">
                  <h3 class="fornecedor-nome">{fornecedor.nome}</h3>
                  {#if fornecedor.codigo}
                    <p class="fornecedor-codigo">Código: {fornecedor.codigo}</p>
                  {/if}
                </div>
                <span class="fornecedor-badge {fornecedor.ativo ? 'ativo' : 'inativo'}">
                  {fornecedor.ativo ? '✓ Ativo' : '⊗ Inativo'}
                </span>
              </div>
              
              <!-- Estatísticas -->
              <div class="fornecedor-stats">
                <div class="stat-item">
                  <span class="stat-icon-small">📦</span>
                  <span class="stat-text">{fornecedor.total_lentes} lentes</span>
                </div>
                <div class="stat-item">
                  <span class="stat-icon-small">🏷️</span>
                  <span class="stat-text">{fornecedor.marcas_diferentes_usadas} marcas</span>
                </div>
              </div>
              
              <!-- Marcas -->
              {#if fornecedor.marcas_lista && fornecedor.marcas_lista.length > 0}
                <div class="fornecedor-marcas">
                  <h4 class="marcas-title">Marcas:</h4>
                  <div class="marcas-list">
                    {#each fornecedor.marcas_lista.slice(0, 5) as marca}
                      <span class="marca-badge">{marca}</span>
                    {/each}
                    {#if fornecedor.marcas_lista.length > 5}
                      <span class="marca-badge more">+{fornecedor.marcas_lista.length - 5}</span>
                    {/if}
                  </div>
                </div>
              {/if}
              
              <!-- Prazos -->
              <div class="fornecedor-prazos">
                <h4 class="prazos-title">Prazos de Entrega:</h4>
                <div class="prazos-grid">
                  <div class="prazo-item">
                    <span class="prazo-label">Visão Simples</span>
                    <span class="prazo-value">{formatarPrazo(fornecedor.prazo_visao_simples)}</span>
                  </div>
                  <div class="prazo-item">
                    <span class="prazo-label">Multifocal</span>
                    <span class="prazo-value">{formatarPrazo(fornecedor.prazo_multifocal)}</span>
                  </div>
                  <div class="prazo-item">
                    <span class="prazo-label">Surfaçada</span>
                    <span class="prazo-value">{formatarPrazo(fornecedor.prazo_surfacada)}</span>
                  </div>
                  <div class="prazo-item">
                    <span class="prazo-label">Free Form</span>
                    <span class="prazo-value">{formatarPrazo(fornecedor.prazo_free_form)}</span>
                  </div>
                </div>
              </div>
              
              <!-- Observações -->
              {#if fornecedor.observacoes}
                <div class="fornecedor-obs">
                  <h4 class="obs-title">Observações:</h4>
                  <p class="obs-text">{fornecedor.observacoes}</p>
                </div>
              {/if}
              
            </GlassCard>
          {/each}
        </div>
      </section>
      
    </div>
  {/if}
</div>

<style>
  .page-fornecedores {
    padding: 2rem;
    min-height: 100vh;
  }
  
  .content {
    display: flex;
    flex-direction: column;
    gap: 2rem;
    max-width: 1400px;
    margin: 0 auto;
  }
  
  .loading, .error, .empty {
    display: flex;
    justify-content: center;
    padding: 4rem 2rem;
  }
  
  .error-message {
    color: #ef4444;
    font-weight: 600;
  }
  
  /* Stats Grid */
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
  }
  
  .stat-card {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  
  .stat-icon {
    width: 48px;
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
    border-radius: 0.75rem;
    color: white;
  }
  
  .stat-info {
    flex: 1;
  }
  
  .stat-value {
    font-size: 1.75rem;
    font-weight: 800;
    color: var(--color-text-primary);
    line-height: 1;
    margin-bottom: 0.25rem;
  }
  
  .stat-label {
    font-size: 0.875rem;
    color: var(--color-text-secondary);
  }
  
  /* Fornecedores Section */
  .fornecedores-section {
    width: 100%;
  }
  
  .section-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--color-text-primary);
    margin-bottom: 1.5rem;
  }
  
  .fornecedores-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
    gap: 1.5rem;
  }
  
  /* Fornecedor Card */
  :global(.fornecedor-card) {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    transition: all 0.3s ease;
  }
  
  :global(.fornecedor-card:hover) {
    transform: translateY(-4px);
  }
  
  .fornecedor-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  }
  
  .fornecedor-info {
    flex: 1;
  }
  
  .fornecedor-nome {
    font-size: 1.25rem;
    font-weight: 700;
    color: var(--color-text-primary);
    margin-bottom: 0.25rem;
  }
  
  .fornecedor-codigo {
    font-size: 0.875rem;
    color: var(--color-text-secondary);
  }
  
  .fornecedor-badge {
    padding: 0.375rem 0.75rem;
    border-radius: 999px;
    font-size: 0.875rem;
    font-weight: 600;
  }
  
  .fornecedor-badge.ativo {
    background: rgba(34, 197, 94, 0.2);
    color: #16a34a;
  }
  
  .fornecedor-badge.inativo {
    background: rgba(239, 68, 68, 0.2);
    color: #dc2626;
  }
  
  /* Estatísticas */
  .fornecedor-stats {
    display: flex;
    gap: 1.5rem;
    padding: 0.75rem;
    background: rgba(0, 0, 0, 0.05);
    border-radius: 0.5rem;
  }
  
  .stat-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }
  
  .stat-icon-small {
    font-size: 1.125rem;
  }
  
  .stat-text {
    font-size: 0.875rem;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  /* Marcas */
  .fornecedor-marcas {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .marcas-title {
    font-size: 0.875rem;
    font-weight: 600;
    color: var(--color-text-secondary);
  }
  
  .marcas-list {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }
  
  .marca-badge {
    padding: 0.25rem 0.625rem;
    background: rgba(59, 130, 246, 0.15);
    color: #2563eb;
    border-radius: 999px;
    font-size: 0.75rem;
    font-weight: 600;
  }
  
  .marca-badge.more {
    background: rgba(107, 114, 128, 0.15);
    color: #6b7280;
  }
  
  /* Prazos */
  .fornecedor-prazos {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .prazos-title {
    font-size: 0.875rem;
    font-weight: 600;
    color: var(--color-text-secondary);
  }
  
  .prazos-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 0.75rem;
  }
  
  .prazo-item {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    padding: 0.5rem;
    background: rgba(0, 0, 0, 0.03);
    border-radius: 0.5rem;
  }
  
  .prazo-label {
    font-size: 0.75rem;
    color: var(--color-text-secondary);
  }
  
  .prazo-value {
    font-size: 0.875rem;
    font-weight: 700;
    color: var(--color-primary);
  }
  
  /* Observações */
  .fornecedor-obs {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 1rem;
    background: rgba(234, 179, 8, 0.1);
    border-left: 3px solid #eab308;
    border-radius: 0.5rem;
  }
  
  .obs-title {
    font-size: 0.875rem;
    font-weight: 600;
    color: #854d0e;
  }
  
  .obs-text {
    font-size: 0.875rem;
    color: #713f12;
    line-height: 1.5;
  }
  
  /* Responsive */
  @media (max-width: 1024px) {
    .fornecedores-grid {
      grid-template-columns: 1fr;
    }
  }
  
  @media (max-width: 768px) {
    .page-fornecedores {
      padding: 1rem;
    }
    
    .stats-grid {
      grid-template-columns: 1fr;
    }
    
    .prazos-grid {
      grid-template-columns: 1fr;
    }
  }
</style>
