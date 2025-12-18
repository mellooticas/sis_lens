<script lang="ts">
  /**
   * 💳 Glass Credit Card - Cartão com efeito vitrificado
   * Card estilo cartão de crédito com glassmorphism
   */
  
  export let cardName: string = 'Exclusive Card';
  export let cardHolder: string = '';
  export let balance: string = '$0.00';
  export let cardNumber: string = '•••• •••• •••• ••••';
  export let validThru: string = '00/00';
  export let gradient: 'orange' | 'blue' | 'purple' | 'green' = 'orange';
  export let className: string = '';

  const gradients = {
    orange: 'linear-gradient(135deg, #f59e0b 0%, #ef4444 100%)',
    blue: 'linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%)',
    purple: 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
    green: 'linear-gradient(135deg, #10b981 0%, #3b82f6 100%)'
  };
</script>

<div 
  class="glass-credit-card {className}"
  style="background: {gradients[gradient]}"
>
  <div class="card-overlay"></div>
  
  <div class="card-content">
    <!-- Header -->
    <div class="card-header">
      <div class="card-name">{cardName}</div>
      <div class="card-chip">
        <svg width="40" height="30" viewBox="0 0 40 30" fill="none">
          <rect width="40" height="30" rx="4" fill="rgba(255,255,255,0.3)"/>
          <rect x="5" y="5" width="10" height="8" rx="1" fill="rgba(255,255,255,0.5)"/>
          <rect x="18" y="5" width="10" height="8" rx="1" fill="rgba(255,255,255,0.5)"/>
          <rect x="5" y="17" width="10" height="8" rx="1" fill="rgba(255,255,255,0.5)"/>
          <rect x="18" y="17" width="10" height="8" rx="1" fill="rgba(255,255,255,0.5)"/>
        </svg>
      </div>
    </div>

    <!-- Balance -->
    <div class="card-balance">
      <div class="balance-label">Balance</div>
      <div class="balance-value">{balance}</div>
    </div>

    <!-- Card Number -->
    <div class="card-number">{cardNumber}</div>

    <!-- Footer -->
    <div class="card-footer">
      {#if cardHolder}
        <div class="card-holder">
          <div class="holder-label">Card Holder</div>
          <div class="holder-name">{cardHolder}</div>
        </div>
      {/if}
      
      <div class="card-valid">
        <div class="valid-label">Valid Thru</div>
        <div class="valid-date">{validThru}</div>
      </div>
    </div>
  </div>

  <!-- Decorative circles -->
  <div class="circle circle-1"></div>
  <div class="circle circle-2"></div>
</div>

<style>
  .glass-credit-card {
    position: relative;
    width: 100%;
    max-width: 400px;
    aspect-ratio: 1.586;
    border-radius: 1.5rem;
    padding: 2rem;
    overflow: hidden;
    box-shadow: 
      0 20px 40px rgba(0, 0, 0, 0.2),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
    transition: transform 0.3s ease;
  }

  .glass-credit-card:hover {
    transform: translateY(-8px) rotateX(5deg);
  }

  .card-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
  }

  .card-content {
    position: relative;
    z-index: 1;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    color: white;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
  }

  .card-name {
    font-size: 1rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  .card-chip {
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
  }

  .card-balance {
    margin-top: 1rem;
  }

  .balance-label {
    font-size: 0.75rem;
    opacity: 0.8;
    margin-bottom: 0.25rem;
  }

  .balance-value {
    font-size: 2rem;
    font-weight: 800;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  }

  .card-number {
    font-size: 1.25rem;
    font-weight: 500;
    letter-spacing: 0.1em;
    font-family: 'Courier New', monospace;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  .card-footer {
    display: flex;
    justify-content: space-between;
    gap: 1rem;
  }

  .card-holder,
  .card-valid {
    flex: 1;
  }

  .holder-label,
  .valid-label {
    font-size: 0.625rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    opacity: 0.8;
    margin-bottom: 0.25rem;
  }

  .holder-name,
  .valid-date {
    font-size: 0.875rem;
    font-weight: 600;
    text-transform: uppercase;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  }

  /* Decorative circles */
  .circle {
    position: absolute;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
    pointer-events: none;
  }

  .circle-1 {
    width: 200px;
    height: 200px;
    top: -100px;
    right: -50px;
  }

  .circle-2 {
    width: 150px;
    height: 150px;
    bottom: -75px;
    left: -50px;
  }

  /* Responsive */
  @media (max-width: 640px) {
    .glass-credit-card {
      max-width: 100%;
      padding: 1.5rem;
    }

    .balance-value {
      font-size: 1.5rem;
    }

    .card-number {
      font-size: 1rem;
    }
  }
</style>
