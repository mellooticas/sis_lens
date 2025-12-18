<script lang="ts">
  /**
   * 💎 Glass Input - Campo de entrada com efeito vitrificado
   */
  
  export let type: string = 'text';
  export let value: string = '';
  export let placeholder: string = '';
  export let label: string = '';
  export let error: string = '';
  export let disabled: boolean = false;
  export let required: boolean = false;
  export let icon: string = '';
  export let className: string = '';

  let isFocused = false;
</script>

<div class="glass-input-wrapper {className}">
  {#if label}
    <label class="input-label">
      {label}
      {#if required}
        <span class="required">*</span>
      {/if}
    </label>
  {/if}
  
  <div class="input-container" class:focused={isFocused} class:has-error={error} class:disabled>
    {#if icon}
      <span class="input-icon">{icon}</span>
    {/if}
    
    <input
      {type}
      bind:value
      {placeholder}
      {disabled}
      {required}
      class="glass-input"
      on:focus={() => isFocused = true}
      on:blur={() => isFocused = false}
      on:input
      on:change
      on:keydown
    />
  </div>
  
  {#if error}
    <div class="error-message">{error}</div>
  {/if}
</div>

<style>
  .glass-input-wrapper {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .input-label {
    font-size: 0.875rem;
    font-weight: 500;
    color: rgba(255, 255, 255, 0.9);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  }

  .required {
    color: #ef4444;
    margin-left: 0.25rem;
  }

  .input-container {
    position: relative;
    display: flex;
    align-items: center;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 0.75rem;
    padding: 0.75rem 1rem;
    transition: all 0.3s ease;
  }

  .input-container:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.3);
  }

  .input-container.focused {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(245, 158, 11, 0.5);
    box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
  }

  .input-container.has-error {
    border-color: rgba(239, 68, 68, 0.5);
  }

  .input-container.has-error.focused {
    box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
  }

  .input-container.disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .input-icon {
    font-size: 1.25rem;
    margin-right: 0.75rem;
    filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.2));
  }

  .glass-input {
    flex: 1;
    background: none;
    border: none;
    outline: none;
    color: white;
    font-size: 0.9375rem;
    font-weight: 400;
  }

  .glass-input::placeholder {
    color: rgba(255, 255, 255, 0.5);
  }

  .glass-input:disabled {
    cursor: not-allowed;
  }

  .error-message {
    font-size: 0.75rem;
    color: #ef4444;
    margin-top: 0.25rem;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  }
</style>
