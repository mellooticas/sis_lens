<!--
  💎 Demo - Design Vitrificado (Glassmorphism)
  Página de demonstração do efeito glass/vidro fosco
-->
<script lang="ts">
  import GlassCard from "$lib/components/ui/GlassCard.svelte";
  import GlassPanel from "$lib/components/ui/GlassPanel.svelte";
  import GlassCreditCard from "$lib/components/ui/GlassCreditCard.svelte";

  // Dados de exemplo
  let currentTime = new Date().toLocaleTimeString('pt-BR', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });

  // Atualizar horário
  setInterval(() => {
    currentTime = new Date().toLocaleTimeString('pt-BR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  }, 1000);

  // Transações exemplo
  const transactions = [
    { name: 'Akeem Jamiu', date: '15/01/2024 13:30PM', amount: 2000.99, type: 'salary' },
    { name: 'Maria Silva', date: '14/01/2024 10:15AM', amount: -350.00, type: 'expense' },
    { name: 'João Santos', date: '13/01/2024 15:45PM', amount: 1250.50, type: 'transfer' },
  ];

  // Goals exemplo
  const goals = [
    { name: 'Travel Abroad', progress: 60, target: '100%' },
    { name: 'Real Estate', progress: 89, target: '100%' }
  ];
</script>

<svelte:head>
  <title>Demo - Design Vitrificado | SIS Lens</title>
  <style>
    body {
      background: url('https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=1920&q=80') center/cover no-repeat fixed;
      background-color: #1a1a2e;
    }
  </style>
</svelte:head>

<div class="glass-demo">
  <!-- Header Glass -->
  <div class="demo-header">
    <GlassCard variant="dark" blur="lg" className="header-card">
      <div class="header-content">
        <div>
          <h1 class="header-title">My Dashboard</h1>
          <p class="header-subtitle">Glassmorphism Design System</p>
        </div>
        <div class="header-time">{currentTime}</div>
      </div>
    </GlassCard>
  </div>

  <!-- Main Content -->
  <div class="demo-container">
    <!-- Sidebar -->
    <aside class="sidebar">
      <GlassCard variant="dark" blur="xl" className="sidebar-card">
        <nav class="sidebar-nav">
          <button class="nav-item active">
            <span class="nav-icon">🏠</span>
          </button>
          <button class="nav-item">
            <span class="nav-icon">📊</span>
          </button>
          <button class="nav-item">
            <span class="nav-icon">💳</span>
          </button>
          <button class="nav-item">
            <span class="nav-icon">⚙️</span>
          </button>
          <button class="nav-item">
            <span class="nav-icon">🔄</span>
          </button>
        </nav>
      </GlassCard>
    </aside>

    <!-- Main Dashboard -->
    <main class="main-content">
      <!-- Stats Grid -->
      <div class="stats-grid">
        <GlassPanel 
          title="Total Balance"
          value="$789,999.56"
          icon="💰"
          trend="up"
          trendValue="+12.5%"
          variant="default"
          size="md"
        />
        
        <GlassPanel 
          title="Earnings"
          value="$958,999.56"
          icon="💼"
          trend="up"
          trendValue="+8.2%"
          variant="success"
          size="md"
        />
        
        <GlassPanel 
          title="Expenses"
          value="$39,999.67"
          icon="🔒"
          trend="down"
          trendValue="-3.1%"
          variant="warning"
          size="md"
        />
      </div>

      <!-- Chart Section -->
      <div class="chart-section">
        <GlassCard variant="dark" blur="lg" padding="lg">
          <div class="chart-header">
            <div>
              <h3 class="section-title">Statistic</h3>
              <p class="section-subtitle">Top half-year Earning and Expenses source</p>
            </div>
            <select class="glass-select">
              <option>All Transaction</option>
              <option>Income</option>
              <option>Expenses</option>
            </select>
          </div>
          
          <div class="chart-container">
            <!-- Simplified chart visualization -->
            <div class="chart-legend">
              <div class="legend-item">
                <span class="legend-dot" style="background: #22c55e;"></span>
                <span>Groceries</span>
              </div>
              <div class="legend-item">
                <span class="legend-dot" style="background: #f59e0b;"></span>
                <span>Invest Corporate</span>
              </div>
              <div class="legend-item">
                <span class="legend-dot" style="background: #ef4444;"></span>
                <span>Hobbies</span>
              </div>
            </div>
            
            <div class="chart-visual">
              <svg viewBox="0 0 500 200" class="line-chart">
                <!-- Grid lines -->
                <line x1="0" y1="50" x2="500" y2="50" stroke="rgba(255,255,255,0.1)" stroke-width="1"/>
                <line x1="0" y1="100" x2="500" y2="100" stroke="rgba(255,255,255,0.1)" stroke-width="1"/>
                <line x1="0" y1="150" x2="500" y2="150" stroke="rgba(255,255,255,0.1)" stroke-width="1"/>
                
                <!-- Orange line -->
                <path 
                  d="M 0 120 Q 100 80, 200 100 T 400 80 T 500 60" 
                  stroke="#f59e0b" 
                  stroke-width="3" 
                  fill="none"
                  stroke-linecap="round"
                />
                
                <!-- Green line -->
                <path 
                  d="M 0 140 Q 100 160, 200 130 T 400 120 T 500 100" 
                  stroke="#22c55e" 
                  stroke-width="3" 
                  fill="none"
                  stroke-linecap="round"
                />
                
                <!-- Data point -->
                <circle cx="200" cy="100" r="6" fill="white" stroke="#f59e0b" stroke-width="2"/>
                <text x="200" y="85" fill="white" font-size="12" text-anchor="middle">18,256,599</text>
              </svg>
              
              <!-- X-axis labels -->
              <div class="chart-labels">
                <span>Jan</span>
                <span>Feb</span>
                <span>Mar</span>
                <span>Apr</span>
                <span>May</span>
                <span>Jun</span>
              </div>
            </div>
          </div>
        </GlassCard>
      </div>

      <!-- Bottom Section -->
      <div class="bottom-grid">
        <!-- Goals -->
        <GlassCard variant="dark" blur="lg" padding="lg">
          <h3 class="section-title">My Goals</h3>
          <div class="goals-list">
            {#each goals as goal}
              <div class="goal-item">
                <div class="goal-header">
                  <span class="goal-name">{goal.name}</span>
                  <span class="goal-progress">{goal.progress}%</span>
                </div>
                <div class="progress-bar">
                  <div class="progress-fill" style="width: {goal.progress}%"></div>
                </div>
              </div>
            {/each}
          </div>
          
          <button class="glass-button">
            <span>➕</span>
          </button>
        </GlassCard>

        <!-- Business Stats -->
        <GlassCard variant="dark" blur="lg" padding="lg">
          <h3 class="section-title">Business</h3>
          
          <div class="business-stat">
            <div class="stat-label">Target Savings</div>
            <div class="stat-value">$1,000,000.00</div>
          </div>
          
          <div class="business-stat">
            <div class="stat-label">Total Savings</div>
            <div class="progress-ring">
              <svg width="100" height="100" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="40" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="8"/>
                <circle cx="50" cy="50" r="40" fill="none" stroke="#f59e0b" stroke-width="8" 
                        stroke-dasharray="251.2" stroke-dashoffset="75.36" 
                        transform="rotate(-90 50 50)" stroke-linecap="round"/>
              </svg>
              <div class="ring-value">65%</div>
            </div>
            <div class="stat-value">$700,345.98</div>
          </div>
        </GlassCard>
      </div>
    </main>

    <!-- Right Sidebar -->
    <aside class="right-sidebar">
      <!-- User Card -->
      <GlassCard variant="dark" blur="lg" padding="md" className="user-card">
        <div class="user-avatar">
          <div class="avatar-circle">
            <span>👤</span>
          </div>
        </div>
        <div class="user-name">Emmanuella Takureea</div>
        
        <div class="quick-actions">
          <button class="quick-action">
            <span>💸</span>
            <span class="action-label">Transfer</span>
          </button>
          <button class="quick-action">
            <span>📥</span>
            <span class="action-label">Receive</span>
          </button>
          <button class="quick-action">
            <span>📄</span>
            <span class="action-label">Bill</span>
          </button>
          <button class="quick-action">
            <span>⬆️</span>
            <span class="action-label">Top up</span>
          </button>
        </div>
      </GlassCard>

      <!-- Credit Card -->
      <div class="card-section">
        <GlassCreditCard 
          cardName="Gluwakemi"
          cardHolder="Emmanuella T."
          balance="$74,330"
          cardNumber="•••• •••• •••• 3792"
          validThru="09/27"
          gradient="orange"
        />
      </div>

      <!-- Transactions -->
      <GlassCard variant="dark" blur="lg" padding="md">
        <div class="transactions-header">
          <h3 class="section-title">Month Transaction</h3>
          <button class="view-all">See all →</button>
        </div>
        
        <div class="transactions-list">
          {#each transactions as transaction}
            <div class="transaction-item">
              <div class="transaction-avatar">
                <span>{transaction.name[0]}</span>
              </div>
              <div class="transaction-info">
                <div class="transaction-name">{transaction.name}</div>
                <div class="transaction-date">{transaction.date}</div>
              </div>
              <div class="transaction-amount" class:positive={transaction.amount > 0}>
                ${Math.abs(transaction.amount).toFixed(2)}
              </div>
            </div>
          {/each}
        </div>
      </GlassCard>
    </aside>
  </div>
</div>

<style>
  :global(body) {
    margin: 0;
    font-family: 'Inter', -apple-system, sans-serif;
    overflow-x: hidden;
  }

  .glass-demo {
    min-height: 100vh;
    padding: 2rem;
    color: white;
  }

  /* Header */
  .demo-header {
    margin-bottom: 2rem;
  }

  :global(.header-card) {
    width: 100%;
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .header-title {
    font-size: 2rem;
    font-weight: 800;
    margin: 0;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  }

  .header-subtitle {
    font-size: 0.875rem;
    opacity: 0.8;
    margin: 0.25rem 0 0;
  }

  .header-time {
    font-size: 1.5rem;
    font-weight: 600;
    font-family: 'Courier New', monospace;
  }

  /* Container */
  .demo-container {
    display: grid;
    grid-template-columns: auto 1fr auto;
    gap: 1.5rem;
    max-width: 1800px;
    margin: 0 auto;
  }

  /* Sidebar */
  .sidebar {
    width: 80px;
  }

  :global(.sidebar-card) {
    height: 100%;
    position: sticky;
    top: 2rem;
  }

  .sidebar-nav {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    align-items: center;
  }

  .nav-item {
    width: 48px;
    height: 48px;
    border: none;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
    font-size: 1.5rem;
  }

  .nav-item:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: translateX(4px);
  }

  .nav-item.active {
    background: linear-gradient(135deg, #f59e0b, #ef4444);
  }

  /* Main Content */
  .main-content {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1.5rem;
  }

  .chart-section {
    margin-top: 1rem;
  }

  .chart-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 2rem;
  }

  .section-title {
    font-size: 1.25rem;
    font-weight: 700;
    margin: 0 0 0.25rem;
  }

  .section-subtitle {
    font-size: 0.875rem;
    opacity: 0.7;
    margin: 0;
  }

  .glass-select {
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 0.5rem;
    padding: 0.5rem 1rem;
    color: white;
    font-size: 0.875rem;
    cursor: pointer;
  }

  .chart-container {
    margin-top: 2rem;
  }

  .chart-legend {
    display: flex;
    justify-content: flex-end;
    gap: 1.5rem;
    margin-bottom: 1rem;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.875rem;
  }

  .legend-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }

  .chart-visual {
    position: relative;
  }

  .line-chart {
    width: 100%;
    height: auto;
  }

  .chart-labels {
    display: flex;
    justify-content: space-between;
    margin-top: 1rem;
    font-size: 0.875rem;
    opacity: 0.7;
  }

  /* Bottom Grid */
  .bottom-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1.5rem;
  }

  .goals-list {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    margin: 1.5rem 0;
  }

  .goal-item {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .goal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .goal-name {
    font-size: 0.875rem;
    font-weight: 500;
  }

  .goal-progress {
    font-size: 1.25rem;
    font-weight: 700;
  }

  .progress-bar {
    height: 8px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 999px;
    overflow: hidden;
  }

  .progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #f59e0b, #ef4444);
    border-radius: 999px;
    transition: width 0.3s ease;
  }

  .glass-button {
    width: 48px;
    height: 48px;
    border: none;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 50%;
    color: white;
    font-size: 1.5rem;
    cursor: pointer;
    transition: all 0.3s ease;
    margin-top: 1rem;
  }

  .glass-button:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: scale(1.1);
  }

  .business-stat {
    margin: 1.5rem 0;
  }

  .stat-label {
    font-size: 0.875rem;
    opacity: 0.7;
    margin-bottom: 0.5rem;
  }

  .stat-value {
    font-size: 1.25rem;
    font-weight: 700;
  }

  .progress-ring {
    position: relative;
    display: inline-block;
    margin: 1rem 0;
  }

  .ring-value {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    font-size: 1.25rem;
    font-weight: 700;
  }

  /* Right Sidebar */
  .right-sidebar {
    width: 320px;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  :global(.user-card) {
    text-align: center;
  }

  .user-avatar {
    margin-bottom: 1rem;
  }

  .avatar-circle {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, #f59e0b, #ef4444);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2.5rem;
    margin: 0 auto;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
  }

  .user-name {
    font-size: 1.125rem;
    font-weight: 600;
    margin-bottom: 1.5rem;
  }

  .quick-actions {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0.75rem;
  }

  .quick-action {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 0.75rem;
    padding: 0.75rem 0.5rem;
    cursor: pointer;
    transition: all 0.3s ease;
    font-size: 1.5rem;
  }

  .quick-action:hover {
    background: rgba(255, 255, 255, 0.1);
    transform: translateY(-2px);
  }

  .action-label {
    font-size: 0.625rem;
    text-transform: capitalize;
  }

  .card-section {
    display: flex;
    justify-content: center;
  }

  .transactions-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }

  .view-all {
    background: none;
    border: none;
    color: rgba(255, 255, 255, 0.7);
    font-size: 0.875rem;
    cursor: pointer;
    transition: color 0.3s ease;
  }

  .view-all:hover {
    color: white;
  }

  .transactions-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .transaction-item {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 0.75rem;
    transition: background 0.3s ease;
  }

  .transaction-item:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  .transaction-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: linear-gradient(135deg, #3b82f6, #8b5cf6);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
  }

  .transaction-info {
    flex: 1;
  }

  .transaction-name {
    font-size: 0.875rem;
    font-weight: 500;
  }

  .transaction-date {
    font-size: 0.75rem;
    opacity: 0.6;
    margin-top: 0.125rem;
  }

  .transaction-amount {
    font-size: 1rem;
    font-weight: 700;
    color: #ef4444;
  }

  .transaction-amount.positive {
    color: #22c55e;
  }

  /* Responsive */
  @media (max-width: 1400px) {
    .demo-container {
      grid-template-columns: 1fr;
    }

    .sidebar,
    .right-sidebar {
      display: none;
    }

    .stats-grid {
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    }
  }

  @media (max-width: 768px) {
    .glass-demo {
      padding: 1rem;
    }

    .stats-grid,
    .bottom-grid {
      grid-template-columns: 1fr;
    }

    .header-title {
      font-size: 1.5rem;
    }
  }
</style>
