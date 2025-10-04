# 📋 GUIA COMPLETO DE COMPONENTES REUTILIZÁVEIS - BestLens

## Visão Geral
Este documento apresenta todos os componentes reutilizáveis do sistema BestLens, organizados por categoria, com suas props, funcionalidades e exemplos de uso.

---

## 🎨 UI Components (9 componentes)

### Badge
**Localização:** `/lib/components/ui/Badge.svelte`

**Props:**
- `variant: 'primary'|'secondary'|'success'|'warning'|'danger'|'info'` (default: 'primary')
- `size: 'sm'|'md'|'lg'` (default: 'md')
- `children: string`

**Função:** Exibe etiquetas coloridas para status, categorias, etc.

**Import:**
```javascript
import Badge from '$lib/components/ui/Badge.svelte';
```

**Exemplo de Uso:**
```svelte
<Badge variant="success" size="sm">Ativo</Badge>
<Badge variant="warning">Pendente</Badge>
<Badge variant="danger" size="lg">Cancelado</Badge>
```

---

### Button
**Localização:** `/lib/components/ui/Button.svelte`

**Props:**
- `variant: 'primary'|'secondary'|'ghost'|'danger'` (default: 'primary')
- `size: 'sm'|'md'|'lg'` (default: 'md')
- `fullWidth: boolean` (default: false)
- `disabled: boolean` (default: false)
- `type: 'button'|'submit'|'reset'` (default: 'button')

**Função:** Botões padronizados com diferentes estilos e suporte completo ao dark mode

**Import:**
```javascript
import Button from '$lib/components/ui/Button.svelte';
```

**Exemplo de Uso:**
```svelte
<Button variant="primary" on:click={handler}>Salvar</Button>
<Button variant="secondary" size="sm" disabled>Cancelar</Button>
<Button variant="danger" fullWidth>Excluir</Button>
```

---

### Breadcrumbs
**Localização:** `/lib/components/ui/Breadcrumbs.svelte`

**Props:**
- `items: Array<{label: string, href?: string}>` (required)

**Função:** Navegação breadcrumb para indicar localização atual na aplicação

**Import:**
```javascript
import Breadcrumbs from '$lib/components/ui/Breadcrumbs.svelte';
```

**Exemplo de Uso:**
```svelte
<Breadcrumbs items={[
  {label: 'Home', href: '/'},
  {label: 'Buscar', href: '/buscar'},
  {label: 'Resultados'}
]} />
```

---

### EmptyState
**Localização:** `/lib/components/ui/EmptyState.svelte`

**Props:**
- `icon: string` (required)
- `title: string` (required)
- `description: string` (required)
- `actionLabel?: string`

**Função:** Exibe estado vazio quando não há dados para mostrar

**Import:**
```javascript
import EmptyState from '$lib/components/ui/EmptyState.svelte';
```

**Exemplo de Uso:**
```svelte
<EmptyState 
  icon="📋" 
  title="Nenhum resultado encontrado" 
  description="Tente ajustar os filtros ou realizar uma nova busca"
  actionLabel="Nova Busca"
  on:action={resetSearch}
/>
```

---

### ErrorState
**Localização:** `/lib/components/ui/ErrorState.svelte`

**Props:**
- `title: string` (required)
- `message: string` (required)
- `actionLabel?: string`

**Função:** Exibe estados de erro com ações de recuperação

**Import:**
```javascript
import ErrorState from '$lib/components/ui/ErrorState.svelte';
```

**Exemplo de Uso:**
```svelte
<ErrorState 
  title="Erro ao carregar dados" 
  message="Não foi possível conectar ao servidor"
  actionLabel="Tentar novamente"
  on:action={retry}
/>
```

---

### LoadingSpinner
**Localização:** `/lib/components/ui/LoadingSpinner.svelte`

**Props:**
- `size: 'sm'|'md'|'lg'` (default: 'md')
- `color: 'primary'|'white'|'neutral'` (default: 'primary')

**Função:** Indicador de carregamento animado

**Import:**
```javascript
import LoadingSpinner from '$lib/components/ui/LoadingSpinner.svelte';
```

**Exemplo de Uso:**
```svelte
<LoadingSpinner size="lg" color="primary" />
<LoadingSpinner size="sm" color="white" />
```

---

### Pagination
**Localização:** `/lib/components/ui/Pagination.svelte`

**Props:**
- `currentPage: number` (required)
- `totalPages: number` (required)
- `showInfo: boolean` (default: true)

**Função:** Navegação paginada para listas longas

**Import:**
```javascript
import Pagination from '$lib/components/ui/Pagination.svelte';
```

**Exemplo de Uso:**
```svelte
<Pagination 
  currentPage={1} 
  totalPages={10} 
  showInfo={true}
  on:pageChange={(e) => loadPage(e.detail.page)}
/>
```

---

### Table
**Localização:** `/lib/components/ui/Table.svelte`

**Props:**
- `headers: Array<{key: string, label: string, align?: string}>` (required)
- `rows: Array<object>` (required)
- `hoverable: boolean` (default: true)

**Função:** Tabela padronizada com slots customizáveis

**Import:**
```javascript
import Table from '$lib/components/ui/Table.svelte';
```

**Exemplo de Uso:**
```svelte
<Table {headers} {rows} hoverable>
  <svelte:fragment slot="cell" let:row let:header>
    {#if header.key === 'actions'}
      <Button size="sm">Editar</Button>
    {:else}
      {row[header.key]}
    {/if}
  </svelte:fragment>
</Table>
```

---

### ThemeToggle
**Localização:** `/lib/components/ui/ThemeToggle.svelte`

**Props:** Sem props principais

**Função:** Alternador entre dark mode e light mode

**Import:**
```javascript
import ThemeToggle from '$lib/components/ui/ThemeToggle.svelte';
```

**Exemplo de Uso:**
```svelte
<ThemeToggle />
```

---

## 📝 Form Components (9 componentes)

### Checkbox
**Localização:** `/lib/components/forms/Checkbox.svelte`

**Props:**
- `checked: boolean` (required)
- `label: string` (required)
- `name: string`
- `disabled: boolean` (default: false)

**Função:** Checkbox customizado com label e suporte ao dark mode

**Import:**
```javascript
import Checkbox from '$lib/components/forms/Checkbox.svelte';
```

**Exemplo de Uso:**
```svelte
<Checkbox bind:checked={aceito} label="Aceito os termos e condições" />
<Checkbox bind:checked={newsletter} label="Receber newsletter" disabled />
```

---

### CriterioSelector
**Localização:** `/lib/components/forms/CriterioSelector.svelte`

**Props:**
- `selected: string` (required)
- `criterios: Array<object>` (required)

**Função:** Seletor especializado para critérios de decisão do sistema

**Import:**
```javascript
import CriterioSelector from '$lib/components/forms/CriterioSelector.svelte';
```

**Exemplo de Uso:**
```svelte
<CriterioSelector 
  bind:selected={criterioEscolhido} 
  criterios={[
    {id: 'urgencia', nome: 'Urgência', descricao: 'Prioriza prazo de entrega'},
    {id: 'custo', nome: 'Custo', descricao: 'Prioriza menor preço'}
  ]}
/>
```

---

### FilterPanel
**Localização:** `/lib/components/forms/FilterPanel.svelte`

**Props:**
- `filters: object` (required)
- `marcasDisponiveis: Array<string>` (required)
- `tratamentosDisponiveis: Array<string>` (required)

**Função:** Panel avançado de filtros para busca de lentes

**Import:**
```javascript
import FilterPanel from '$lib/components/forms/FilterPanel.svelte';
```

**Exemplo de Uso:**
```svelte
<FilterPanel 
  bind:filters={filtrosAtivos}
  marcasDisponiveis={['Essilor', 'Zeiss', 'Hoya']}
  tratamentosDisponiveis={['Antirreflexo', 'Fotocromático']}
  on:apply={aplicarFiltros}
/>
```

---

### Input
**Localização:** `/lib/components/forms/Input.svelte`

**Props:**
- `value: string` (required)
- `label: string` (required)
- `type: 'text'|'email'|'password'|'number'|'search'` (default: 'text')
- `placeholder: string`
- `required: boolean` (default: false)
- `error: string`
- `name: string`
- `disabled: boolean` (default: false)

**Função:** Campo de entrada padronizado com validação e acessibilidade

**Import:**
```javascript
import Input from '$lib/components/forms/Input.svelte';
```

**Exemplo de Uso:**
```svelte
<Input 
  bind:value={nome} 
  label="Nome completo" 
  placeholder="Digite seu nome..."
  required
  error={erros.nome}
/>
<Input 
  bind:value={email} 
  type="email" 
  label="E-mail" 
  placeholder="seu@email.com"
/>
```

---

### Radio
**Localização:** `/lib/components/forms/Radio.svelte`

**Props:**
- `group: string` (required)
- `value: string` (required)
- `label: string` (required)
- `name: string` (required)
- `disabled: boolean` (default: false)

**Função:** Radio button customizado para seleção única

**Import:**
```javascript
import Radio from '$lib/components/forms/Radio.svelte';
```

**Exemplo de Uso:**
```svelte
<Radio bind:group={opcaoEscolhida} value="A" label="Opção A" name="opcoes" />
<Radio bind:group={opcaoEscolhida} value="B" label="Opção B" name="opcoes" />
<Radio bind:group={opcaoEscolhida} value="C" label="Opção C" name="opcoes" />
```

---

### SearchBar
**Localização:** `/lib/components/forms/SearchBar.svelte`

**Props:**
- `value: string` (required)
- `placeholder: string`
- `suggestions: Array<string>` (default: [])
- `loading: boolean` (default: false)

**Função:** Barra de busca inteligente com autocomplete

**Import:**
```javascript
import SearchBar from '$lib/components/forms/SearchBar.svelte';
```

**Exemplo de Uso:**
```svelte
<SearchBar 
  bind:value={termoBusca}
  placeholder="Buscar lentes..."
  suggestions={sugestoes}
  loading={carregandoSugestoes}
  on:search={realizarBusca}
  on:select={selecionarSugestao}
/>
```

---

### Select
**Localização:** `/lib/components/forms/Select.svelte`

**Props:**
- `value: string` (required)
- `label: string` (required)
- `options: Array<{value: string, label: string}>` (required)
- `required: boolean` (default: false)
- `error: string`
- `name: string`
- `disabled: boolean` (default: false)

**Função:** Dropdown de seleção padronizado

**Import:**
```javascript
import Select from '$lib/components/forms/Select.svelte';
```

**Exemplo de Uso:**
```svelte
<Select 
  bind:value={categoria}
  label="Categoria da lente"
  options={[
    {value: 'monofocal', label: 'Monofocal'},
    {value: 'multifocal', label: 'Multifocal'},
    {value: 'progressiva', label: 'Progressiva'}
  ]}
  required
/>
```

---

### Textarea
**Localização:** `/lib/components/forms/Textarea.svelte`

**Props:**
- `value: string` (required)
- `label: string` (required)
- `placeholder: string`
- `rows: number` (default: 4)
- `required: boolean` (default: false)
- `error: string`
- `name: string`
- `disabled: boolean` (default: false)

**Função:** Área de texto multilinha padronizada

**Import:**
```javascript
import Textarea from '$lib/components/forms/Textarea.svelte';
```

**Exemplo de Uso:**
```svelte
<Textarea 
  bind:value={observacoes}
  label="Observações"
  placeholder="Digite suas observações..."
  rows={6}
  error={erros.observacoes}
/>
```

---

### Toggle
**Localização:** `/lib/components/forms/Toggle.svelte`

**Props:**
- `checked: boolean` (required)
- `label: string` (required)
- `disabled: boolean` (default: false)

**Função:** Switch on/off customizado

**Import:**
```javascript
import Toggle from '$lib/components/forms/Toggle.svelte';
```

**Exemplo de Uso:**
```svelte
<Toggle bind:checked={notificacoes} label="Ativar notificações por e-mail" />
<Toggle bind:checked={modo_publico} label="Perfil público" disabled />
```

---

## 🃏 Card Components (7 componentes)

### ActionCard
**Localização:** `/lib/components/cards/ActionCard.svelte`

**Props:**
- `icon: string` (required)
- `title: string` (required)
- `description: string` (required)
- `actionLabel: string` (required)
- `color: 'blue'|'green'|'orange'|'gold'` (default: 'blue')

**Função:** Card interativo com ação/navegação, ideal para dashboards

**Import:**
```javascript
import ActionCard from '$lib/components/cards/ActionCard.svelte';
```

**Exemplo de Uso:**
```svelte
<ActionCard 
  icon="🔍" 
  title="Buscar Lentes" 
  description="Encontre lentes com filtros por graduação, material e tratamentos"
  actionLabel="Iniciar Busca"
  color="blue"
  on:click={() => goto('/buscar')}
/>
```

---

### BenefitCard
**Localização:** `/lib/components/cards/BenefitCard.svelte`

**Props:**
- `icon: string` (required)
- `title: string` (required)
- `description: string` (required)

**Função:** Card para exibir benefícios e recursos do sistema

**Import:**
```javascript
import BenefitCard from '$lib/components/cards/BenefitCard.svelte';
```

**Exemplo de Uso:**
```svelte
<BenefitCard 
  icon="⚡" 
  title="Decisões Rápidas" 
  description="Algoritmo inteligente toma decisões em segundos baseado em seus critérios"
/>
```

---

### CardFornecedor
**Localização:** `/lib/components/cards/CardFornecedor.svelte`

**Props:**
- `fornecedor: object` (required)
- `showActions: boolean` (default: true)

**Função:** Card especializado para exibir dados de fornecedores/laboratórios

**Import:**
```javascript
import CardFornecedor from '$lib/components/cards/CardFornecedor.svelte';
```

**Exemplo de Uso:**
```svelte
<CardFornecedor 
  fornecedor={{
    nome: 'Laboratório ABC',
    qualidade: 4.8,
    prazo_entrega: '3-5 dias',
    regiao: 'Sul'
  }}
  showActions={true}
  on:select={selecionarFornecedor}
/>
```

---

### ComparisonCard
**Localização:** `/lib/components/cards/ComparisonCard.svelte`

**Props:**
- `title: string` (required)
- `items: Array<object>` (required)
- `highlightBest: boolean` (default: false)

**Função:** Card para comparação lado a lado de produtos/opções

**Import:**
```javascript
import ComparisonCard from '$lib/components/cards/ComparisonCard.svelte';
```

**Exemplo de Uso:**
```svelte
<ComparisonCard 
  title="Comparar Preços"
  items={[
    {nome: 'Fornecedor A', preco: 150, prazo: '3 dias'},
    {nome: 'Fornecedor B', preco: 120, prazo: '5 dias'}
  ]}
  highlightBest={true}
/>
```

---

### FeatureCard
**Localização:** `/lib/components/cards/FeatureCard.svelte`

**Props:**
- `icon: string` (required)
- `title: string` (required)
- `description: string` (required)
- `link?: string`

**Função:** Card para destacar funcionalidades específicas

**Import:**
```javascript
import FeatureCard from '$lib/components/cards/FeatureCard.svelte';
```

**Exemplo de Uso:**
```svelte
<FeatureCard 
  icon="📊" 
  title="Analytics Avançado" 
  description="Relatórios detalhados sobre performance de fornecedores e economia gerada"
  link="/analytics"
/>
```

---

### StatsCard
**Localização:** `/lib/components/cards/StatsCard.svelte`

**Props:**
- `title: string` (required)
- `value: string|number` (required)
- `icon: string` (required)
- `color: 'blue'|'green'|'orange'|'gold'` (default: 'blue')
- `change?: number` (opcional, para mostrar variação percentual)

**Função:** Card para exibir métricas e KPIs do dashboard

**Import:**
```javascript
import StatsCard from '$lib/components/cards/StatsCard.svelte';
```

**Exemplo de Uso:**
```svelte
<StatsCard 
  title="Economia Total" 
  value="R$ 25.840" 
  icon="💰" 
  color="green"
  change={12.5}
/>
<StatsCard 
  title="Decisões Realizadas" 
  value="847" 
  icon="✅" 
  color="blue"
/>
```

---

### StepCard
**Localização:** `/lib/components/cards/StepCard.svelte`

**Props:**
- `number: number` (required)
- `title: string` (required)
- `description: string` (required)
- `color: 'blue'|'green'|'orange'|'gold'` (default: 'blue')

**Função:** Card numerado para mostrar processos e etapas

**Import:**
```javascript
import StepCard from '$lib/components/cards/StepCard.svelte';
```

**Exemplo de Uso:**
```svelte
<StepCard 
  number={1} 
  title="Definir Critérios" 
  description="Escolha o que é mais importante: prazo, custo ou qualidade"
  color="blue"
/>
<StepCard 
  number={2} 
  title="Buscar Lentes" 
  description="O sistema encontra as melhores opções baseado em seus critérios"
  color="green"
/>
```

---

## 📐 Layout Components (7 componentes)

### Container
**Localização:** `/lib/components/layout/Container.svelte`

**Props:**
- `maxWidth: 'sm'|'md'|'lg'|'xl'|'2xl'|'full'` (default: 'xl')
- `padding: 'sm'|'md'|'lg'` (default: 'md')
- `center: boolean` (default: true)

**Função:** Container responsivo com padding e max-width configuráveis

**Import:**
```javascript
import Container from '$lib/components/layout/Container.svelte';
```

**Exemplo de Uso:**
```svelte
<Container maxWidth="xl" padding="lg" center={true}>
  <h1>Conteúdo da página</h1>
  <!-- Resto do conteúdo -->
</Container>
```

---

### Footer
**Localização:** `/lib/components/layout/Footer.svelte`

**Props:** Sem props principais

**Função:** Rodapé padronizado do sistema com links e informações

**Import:**
```javascript
import Footer from '$lib/components/layout/Footer.svelte';
```

**Exemplo de Uso:**
```svelte
<Footer />
```

---

### Header
**Localização:** `/lib/components/layout/Header.svelte`

**Props:**
- `currentPage?: string` (para destacar página ativa)
- `showMobileMenu?: boolean` (controle do menu mobile)

**Função:** Cabeçalho com navegação principal e menu responsivo

**Import:**
```javascript
import Header from '$lib/components/layout/Header.svelte';
```

**Exemplo de Uso:**
```svelte
<Header currentPage="buscar" showMobileMenu={menuAberto} />
```

---

### Logo
**Localização:** `/lib/components/layout/Logo.svelte`

**Props:**
- `size: 'sm'|'md'|'lg'` (default: 'md')
- `variant: 'default'|'white'` (default: 'default')

**Função:** Logo da marca com variações de tamanho e cor

**Import:**
```javascript
import Logo from '$lib/components/layout/Logo.svelte';
```

**Exemplo de Uso:**
```svelte
<Logo size="lg" variant="default" />
<Logo size="sm" variant="white" />
```

---

### MobileMenu
**Localização:** `/lib/components/layout/MobileMenu.svelte`

**Props:**
- `isOpen: boolean` (required)
- `currentPage: string` (required)

**Função:** Menu mobile responsivo com animações

**Import:**
```javascript
import MobileMenu from '$lib/components/layout/MobileMenu.svelte';
```

**Exemplo de Uso:**
```svelte
<MobileMenu 
  isOpen={menuMobileAberto} 
  currentPage="dashboard"
  on:close={() => menuMobileAberto = false}
  on:navigate={handleNavigation}
/>
```

---

### PageHero
**Localização:** `/lib/components/layout/PageHero.svelte`

**Props:**
- `badge?: string` (texto do badge opcional)
- `title: string` (required)
- `subtitle?: string` (descrição opcional)
- `alignment: 'left'|'center'|'right'` (default: 'left')
- `maxWidth: 'sm'|'md'|'lg'|'xl'` (default: 'lg')

**Função:** Seção hero para início de páginas com título e descrição

**Import:**
```javascript
import PageHero from '$lib/components/layout/PageHero.svelte';
```

**Exemplo de Uso:**
```svelte
<PageHero 
  badge="Nova Funcionalidade"
  title="Dashboard Executivo" 
  subtitle="Visão geral completa dos KPIs e métricas do sistema"
  alignment="center"
  maxWidth="xl"
/>
```

---

### SectionHeader
**Localização:** `/lib/components/layout/SectionHeader.svelte`

**Props:**
- `title: string` (required)
- `subtitle?: string` (descrição opcional)
- `align: 'left'|'center'|'right'` (default: 'left')

**Função:** Cabeçalho padronizado para seções dentro das páginas

**Import:**
```javascript
import SectionHeader from '$lib/components/layout/SectionHeader.svelte';
```

**Exemplo de Uso:**
```svelte
<SectionHeader 
  title="Resultados da Busca" 
  subtitle="Encontramos 42 opções para sua consulta"
  align="left"
/>
```

---

## 💬 Feedback Components (4 componentes)

### LoadingOverlay
**Localização:** `/lib/components/feedback/LoadingOverlay.svelte`

**Props:**
- `show: boolean` (required)
- `message?: string` (default: 'Carregando...')
- `blur: boolean` (default: true)

**Função:** Overlay de carregamento para toda a tela com backdrop blur

**Import:**
```javascript
import LoadingOverlay from '$lib/components/feedback/LoadingOverlay.svelte';
```

**Exemplo de Uso:**
```svelte
<LoadingOverlay 
  show={processandoPedido} 
  message="Processando sua decisão..."
  blur={true}
/>
```

---

### Modal
**Localização:** `/lib/components/feedback/Modal.svelte`

**Props:**
- `show: boolean` (required)
- `title: string` (required)
- `size: 'sm'|'md'|'lg'|'xl'` (default: 'md')
- `closeable: boolean` (default: true)

**Função:** Modal customizável com slots para header, body e footer

**Import:**
```javascript
import Modal from '$lib/components/feedback/Modal.svelte';
```

**Exemplo de Uso:**
```svelte
<Modal 
  show={mostrarModal} 
  title="Confirmar Decisão"
  size="lg"
  closeable={true}
  on:close={() => mostrarModal = false}
>
  <div slot="body">
    <p>Tem certeza que deseja confirmar esta decisão?</p>
  </div>
  
  <div slot="footer" class="flex gap-3">
    <Button variant="secondary" on:click={() => mostrarModal = false}>
      Cancelar
    </Button>
    <Button variant="primary" on:click={confirmarDecisao}>
      Confirmar
    </Button>
  </div>
</Modal>
```

---

### Toast
**Localização:** `/lib/components/feedback/Toast.svelte`

**Props:**
- `type: 'success'|'error'|'warning'|'info'` (required)
- `message: string` (required)
- `duration: number` (default: 4000ms)
- `closeable: boolean` (default: true)

**Função:** Notificação temporária com auto-dismiss

**Import:**
```javascript
import Toast from '$lib/components/feedback/Toast.svelte';
```

**Exemplo de Uso:**
```svelte
<Toast 
  type="success" 
  message="Decisão confirmada com sucesso!"
  duration={5000}
  closeable={true}
  on:close={handleToastClose}
/>
```

---

### ToastContainer
**Localização:** `/lib/components/feedback/ToastContainer.svelte`

**Props:** Sem props (usa store global de toasts)

**Função:** Container global para gerenciar múltiplos toasts

**Import:**
```javascript
import ToastContainer from '$lib/components/feedback/ToastContainer.svelte';
```

**Exemplo de Uso:**
```svelte
<!-- No layout principal da aplicação -->
<ToastContainer />

<!-- Para adicionar toast programaticamente -->
<script>
  import { addToast } from '$lib/stores/toast';
  
  function showSuccess() {
    addToast({
      type: 'success',
      message: 'Operação realizada com sucesso!'
    });
  }
</script>
```

---

## 📊 Padrões de Uso Comuns

### 🎯 Layout Padrão de Página
```svelte
<script>
  import Header from '$lib/components/layout/Header.svelte';
  import Footer from '$lib/components/layout/Footer.svelte';
  import Container from '$lib/components/layout/Container.svelte';
  import PageHero from '$lib/components/layout/PageHero.svelte';
  import Breadcrumbs from '$lib/components/ui/Breadcrumbs.svelte';
</script>

<div class="min-h-screen bg-neutral-50 dark:bg-neutral-900 transition-colors">
  <Header currentPage="buscar" />
  
  <main>
    <Container maxWidth="xl" padding="md">
      <Breadcrumbs items={breadcrumbItems} />
      
      <PageHero 
        title="Título da Página" 
        subtitle="Descrição da funcionalidade"
        alignment="left"
      />
      
      <!-- Conteúdo específico da página -->
      
    </Container>
  </main>
  
  <Footer />
</div>
```

### 🃏 Dashboard com Cards de Métricas
```svelte
<script>
  import StatsCard from '$lib/components/cards/StatsCard.svelte';
  import ActionCard from '$lib/components/cards/ActionCard.svelte';
  import SectionHeader from '$lib/components/layout/SectionHeader.svelte';
</script>

<!-- Seção de Métricas -->
<SectionHeader title="Indicadores Principais" />
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
  <StatsCard 
    title="Economia Total" 
    value="R$ 25.840" 
    icon="💰" 
    color="green"
    change={12.5}
  />
  <StatsCard 
    title="Decisões Realizadas" 
    value="847" 
    icon="✅" 
    color="blue"
  />
  <StatsCard 
    title="Fornecedores Ativos" 
    value="23" 
    icon="🏭" 
    color="orange"
  />
  <StatsCard 
    title="Tempo Médio" 
    value="2.3s" 
    icon="⚡" 
    color="gold"
  />
</div>

<!-- Seção de Ações Rápidas -->
<SectionHeader title="Acesso Rápido" />
<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
  <ActionCard 
    icon="🔍" 
    title="Buscar Lentes" 
    description="Encontre as melhores opções de lentes"
    actionLabel="Iniciar Busca"
    color="blue"
    on:click={() => goto('/buscar')} 
  />
  <ActionCard 
    icon="📊" 
    title="Ver Analytics" 
    description="Relatórios detalhados de performance"
    actionLabel="Ver Relatórios"
    color="green"
    on:click={() => goto('/analytics')} 
  />
</div>
```

### 📝 Formulário Completo com Validação
```svelte
<script>
  import Input from '$lib/components/forms/Input.svelte';
  import Select from '$lib/components/forms/Select.svelte';
  import Textarea from '$lib/components/forms/Textarea.svelte';
  import Checkbox from '$lib/components/forms/Checkbox.svelte';
  import Button from '$lib/components/ui/Button.svelte';
  import LoadingSpinner from '$lib/components/ui/LoadingSpinner.svelte';
  
  let formData = {
    nome: '',
    email: '',
    categoria: '',
    observacoes: '',
    aceito: false
  };
  
  let errors = {};
  let loading = false;
</script>

<form on:submit={handleSubmit} class="space-y-6">
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <Input 
      bind:value={formData.nome}
      label="Nome completo" 
      placeholder="Digite seu nome"
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
  
  <Select 
    bind:value={formData.categoria}
    label="Categoria"
    options={categoriaOptions}
    required
    error={errors.categoria}
  />
  
  <Textarea 
    bind:value={formData.observacoes}
    label="Observações"
    placeholder="Informações adicionais..."
    rows={4}
  />
  
  <Checkbox 
    bind:checked={formData.aceito}
    label="Aceito os termos e condições"
  />
  
  <div class="flex justify-end gap-3">
    <Button variant="secondary" type="button" on:click={resetForm}>
      Cancelar
    </Button>
    
    <Button 
      variant="primary" 
      type="submit" 
      disabled={loading || !formData.aceito}
    >
      {#if loading}
        <LoadingSpinner size="sm" color="white" />
        Salvando...
      {:else}
        Salvar
      {/if}
    </Button>
  </div>
</form>
```

### 📋 Lista com Tabela e Paginação
```svelte
<script>
  import Table from '$lib/components/ui/Table.svelte';
  import Pagination from '$lib/components/ui/Pagination.svelte';
  import EmptyState from '$lib/components/ui/EmptyState.svelte';
  import Badge from '$lib/components/ui/Badge.svelte';
  import Button from '$lib/components/ui/Button.svelte';
  
  const headers = [
    {key: 'nome', label: 'Nome', align: 'left'},
    {key: 'status', label: 'Status', align: 'center'},
    {key: 'data', label: 'Data', align: 'center'},
    {key: 'actions', label: 'Ações', align: 'right'}
  ];
</script>

{#if data.length > 0}
  <Table {headers} rows={data} hoverable>
    <svelte:fragment slot="cell" let:row let:header>
      {#if header.key === 'status'}
        <Badge 
          variant={row.status === 'ativo' ? 'success' : 'warning'}
          size="sm"
        >
          {row.status}
        </Badge>
      {:else if header.key === 'actions'}
        <div class="flex gap-2 justify-end">
          <Button size="sm" variant="ghost" on:click={() => editItem(row)}>
            Editar
          </Button>
          <Button size="sm" variant="danger" on:click={() => deleteItem(row)}>
            Excluir
          </Button>
        </div>
      {:else}
        {row[header.key]}
      {/if}
    </svelte:fragment>
  </Table>
  
  <div class="mt-6">
    <Pagination 
      currentPage={currentPage} 
      totalPages={totalPages}
      on:pageChange={handlePageChange}
    />
  </div>
{:else}
  <EmptyState 
    icon="📋"
    title="Nenhum item encontrado"
    description="Não há dados para exibir no momento"
    actionLabel="Adicionar Novo"
    on:action={addNew}
  />
{/if}
```

### 🎉 Feedback e Notificações
```svelte
<script>
  import Modal from '$lib/components/feedback/Modal.svelte';
  import LoadingOverlay from '$lib/components/feedback/LoadingOverlay.svelte';
  import ToastContainer from '$lib/components/feedback/ToastContainer.svelte';
  import { addToast } from '$lib/stores/toast';
  
  let showConfirmModal = false;
  let processing = false;
  
  function showSuccess() {
    addToast({
      type: 'success',
      message: 'Operação realizada com sucesso!'
    });
  }
  
  function showError() {
    addToast({
      type: 'error',
      message: 'Erro ao processar solicitação'
    });
  }
</script>

<!-- Overlay para operações longas -->
<LoadingOverlay 
  show={processing} 
  message="Processando solicitação..."
/>

<!-- Modal de confirmação -->
<Modal 
  show={showConfirmModal}
  title="Confirmar Ação"
  size="md"
  on:close={() => showConfirmModal = false}
>
  <div slot="body">
    <p>Esta ação não pode ser desfeita. Deseja continuar?</p>
  </div>
  
  <div slot="footer" class="flex gap-3 justify-end">
    <Button variant="secondary" on:click={() => showConfirmModal = false}>
      Cancelar
    </Button>
    <Button variant="danger" on:click={confirmAction}>
      Confirmar
    </Button>
  </div>
</Modal>

<!-- Container global de toasts -->
<ToastContainer />
```

---

## 🎨 Padronização de Cores e Temas

Todos os componentes seguem o mesmo sistema de cores definido no `tailwind.config.js`:

### Cores Principais
- **Primary**: `blue` - Para ações principais e destaque
- **Success**: `green` - Para confirmações e status positivos  
- **Warning**: `orange` - Para alertas e atenção
- **Gold**: `gold` - Para destaque especial e premiações
- **Danger**: `red` - Para erros e ações destrutivas

### Suporte ao Dark Mode
Todos os componentes incluem classes `dark:` para tema escuro:
- Backgrounds: `bg-white dark:bg-neutral-800`
- Bordas: `border-neutral-200 dark:border-neutral-700`
- Textos: `text-neutral-900 dark:text-neutral-100`

### Responsividade
Sistema mobile-first com breakpoints:
- `sm`: 640px+
- `md`: 768px+ 
- `lg`: 1024px+
- `xl`: 1280px+
- `2xl`: 1536px+

---

## 🚀 Conclusão

Este sistema de componentes foi projetado para:

✅ **Consistência Visual** - Mesmo padrão em toda aplicação  
✅ **Acessibilidade** - ARIA labels, keyboard navigation  
✅ **Responsividade** - Funciona em todos dispositivos  
✅ **Dark Mode** - Suporte completo a temas  
✅ **Reutilização** - Máxima reutilização de código  
✅ **Manutenibilidade** - Fácil atualização e extensão

Para dúvidas ou sugestões de melhorias nos componentes, consulte a documentação técnica ou entre em contato com a equipe de desenvolvimento.