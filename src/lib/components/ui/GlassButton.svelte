<script lang="ts">
  /**
   * 💎 Glass Button - Botão com efeito vitrificado
   */
  
  export let variant: 'primary' | 'secondary' | 'success' | 'danger' | 'ghost' = 'primary';
  export let size: 'sm' | 'md' | 'lg' = 'md';
  export let disabled: boolean = false;
  export let loading: boolean = false;
  export let fullWidth: boolean = false;
  export let icon: string = '';
  export let className: string = '';
  export let type: 'button' | 'submit' | 'reset' = 'button';
</script>

<button
  {type}
  {disabled}
  class="glass-button {variant} {size} {className}"
  class:full-width={fullWidth}
  class:loading
  on:click
>
  {#if loading}
    <span class="loading-spinner"></span>
  {:else if icon}
    <span class="button-icon">{icon}</span>
  {/if}
  
  <span class="button-text">
    <slot />
  </span>
</button>

<style>
  .glass-button {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    font-weight: 600;
    border-radius: 0.75rem;
    border: 1px solid;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    overflow: hidden;
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
  }

  .glass-button::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transition: left 0.5s ease;
  }

  .glass-button:hover::before {
    left: 100%;
  }

  .glass-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .glass-button:disabled::before {
    display: none;
  }

  .glass-button.loading {
    cursor: wait;
  }

  /* Sizes */
  .glass-button.sm {
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
  }

  .glass-button.md {
    padding: 0.75rem 1.5rem;
    font-size: 0.9375rem;
  }

  .glass-button.lg {
    padding: 1rem 2rem;
    font-size: 1rem;
  }

  .glass-button.full-width {
    width: 100%;
  }

  /* Variants */
  .glass-button.primary {
    background: linear-gradient(135deg, rgba(245, 158, 11, 0.3), rgba(239, 68, 68, 0.3));
    border-color: rgba(245, 158, 11, 0.5);
    color: white;
  }

  .glass-button.primary:hover:not(:disabled) {
    background: linear-gradient(135deg, rgba(245, 158, 11, 0.4), rgba(239, 68, 68, 0.4));
    border-color: rgba(245, 158, 11, 0.7);
    transform: translateY(-2px);
    box-shadow: 0 8px 16px rgba(245, 158, 11, 0.3);
  }

  .glass-button.secondary {
    background: rgba(255, 255, 255, 0.1);
    border-color: rgba(255, 255, 255, 0.2);
    color: white;
  }

  .glass-button.secondary:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.3);
    transform: translateY(-2px);
  }

  .glass-button.success {
    background: linear-gradient(135deg, rgba(34, 197, 94, 0.3), rgba(22, 163, 74, 0.3));
    border-color: rgba(34, 197, 94, 0.5);
    color: white;
  }

  .glass-button.success:hover:not(:disabled) {
    background: linear-gradient(135deg, rgba(34, 197, 94, 0.4), rgba(22, 163, 74, 0.4));
    border-color: rgba(34, 197, 94, 0.7);
    transform: translateY(-2px);
    box-shadow: 0 8px 16px rgba(34, 197, 94, 0.3);
  }

  .glass-button.danger {
    background: linear-gradient(135deg, rgba(239, 68, 68, 0.3), rgba(220, 38, 38, 0.3));
    border-color: rgba(239, 68, 68, 0.5);
    color: white;
  }

  .glass-button.danger:hover:not(:disabled) {
    background: linear-gradient(135deg, rgba(239, 68, 68, 0.4), rgba(220, 38, 38, 0.4));
    border-color: rgba(239, 68, 68, 0.7);
    transform: translateY(-2px);
    box-shadow: 0 8px 16px rgba(239, 68, 68, 0.3);
  }

  .glass-button.ghost {
    background: transparent;
    border-color: transparent;
    color: rgba(255, 255, 255, 0.8);
  }

  .glass-button.ghost:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.1);
    color: white;
  }

  /* Loading Spinner */
  .loading-spinner {
    width: 1rem;
    height: 1rem;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-top-color: white;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .button-icon {
    font-size: 1.25rem;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .button-text {
    position: relative;
    z-index: 1;
  }
</style>
