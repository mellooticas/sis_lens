# 🎨 BestLens - Guia de Uso do Logo

## 📋 Índice
- [Variantes do Logo](#variantes-do-logo)
- [Tamanhos](#tamanhos)
- [Temas (Light/Dark)](#temas-lightdark)
- [Exemplos de Uso](#exemplos-de-uso)
- [Assets Disponíveis](#assets-disponíveis)

---

## 🎨 Variantes do Logo

### Full (Padrão)
Ícone + Texto + Tagline

```svelte
<Logo variant="full" size="md" />
```

### Icon Only
Apenas o círculo com check

```svelte
<Logo variant="icon" size="sm" />
```

### Text Only
Apenas o texto BestLens

```svelte
<Logo variant="text" size="md" />
```

---

## 📏 Tamanhos

| Size | Height | Uso Recomendado |
|------|--------|-----------------|
| `sm` | 32px | Navbar mobile, favicon |
| `md` | 48px | Navbar desktop (padrão) |
| `lg` | 64px | Hero sections, modais |
| `xl` | 80px | Landing page, splash |

### Exemplos

```svelte
<!-- Small: Navbar mobile -->
<Logo size="sm" />

<!-- Medium: Navbar desktop -->
<Logo size="md" />

<!-- Large: Hero section -->
<Logo size="lg" />

<!-- Extra Large: Landing page -->
<Logo size="xl" />
```

---

## 🌓 Temas (Light/Dark)

### Auto (Padrão)
Adapta automaticamente baseado no tema do sistema

```svelte
<Logo theme="auto" />
```

### Light
Sempre usa cor escura (#1C3B5A)

```svelte
<Logo theme="light" />
```

### Dark
Sempre usa cor clara (#FFFFFF)

```svelte
<!-- Fundo escuro -->
<div class="bg-neutral-900 p-4">
  <Logo theme="dark" />
</div>
```

---

## 💻 Exemplos de Uso

### Navbar

```svelte
<script>
  import Logo from '$lib/components/layout/Logo.svelte';
</script>

<nav class="bg-white border-b border-neutral-200 px-4 py-3">
  <div class="container mx-auto flex items-center justify-between">
    <Logo size="md" />
    
    <div class="flex gap-4">
      <!-- Navegação -->
    </div>
  </div>
</nav>
```

### Hero Section

```svelte
<section class="py-20 text-center">
  <Logo size="xl" class="mx-auto mb-6" />
  <h1 class="text-5xl font-bold">
    Compare. Decide. Gain.
  </h1>
</section>
```

### Footer

```svelte
<footer class="bg-neutral-900 text-white py-12">
  <div class="container mx-auto">
    <Logo theme="dark" size="md" />
    <p class="mt-4">© 2025 BestLens. Todos os direitos reservados.</p>
  </div>
</footer>
```

### Loading/Splash Screen

```svelte
<div class="h-screen flex items-center justify-center">
  <div class="text-center">
    <Logo size="xl" />
    <div class="mt-8 animate-pulse">
      <p>Carregando...</p>
    </div>
  </div>
</div>
```

---

## 📦 Assets Disponíveis

### SVGs Otimizados

```
static/images/logo/
├── logo-light.svg      # Logo completo (fundo claro)
├── logo-dark.svg       # Logo completo (fundo escuro)
└── logo-icon.svg       # Apenas ícone
```

### Uso Direto (sem componente)

```html
<!-- Light version -->
<img src="/images/logo/logo-light.svg" alt="BestLens" height="48">

<!-- Dark version -->
<img src="/images/logo/logo-dark.svg" alt="BestLens" height="48">

<!-- Icon only -->
<img src="/images/logo/logo-icon.svg" alt="BestLens" height="32">
```

### Favicon

```html
<!-- SVG Favicon (Moderno) -->
<link rel="icon" type="image/svg+xml" href="/favicon.svg">

<!-- Apple Touch Icon -->
<link rel="apple-touch-icon" href="/images/logo/logo-icon.svg">
```

---

## ✅ Boas Práticas

### ✓ Fazer

- Usar `variant="full"` em desktop
- Usar `variant="icon"` em mobile quando espaço é limitado
- Sempre incluir `alt` text descritivo
- Respeitar espaçamento mínimo ao redor do logo
- Usar `theme="auto"` para adaptar automaticamente

### ✗ Evitar

- Distorcer proporções do logo
- Usar cores diferentes das definidas
- Adicionar efeitos excessivos (sombras, gradientes)
- Usar logo muito pequeno (< 24px)
- Colocar logo sobre fundos com baixo contraste

---

## 🎨 Espaçamento Mínimo

Manter sempre um espaço livre ao redor do logo:

- **Mínimo**: Altura do ícone × 0.5
- **Recomendado**: Altura do ícone × 1

```svelte
<!-- Com padding adequado -->
<div class="p-4">
  <Logo size="md" />
</div>
```

---

## 📱 Responsividade

```svelte
<script>
  import Logo from '$lib/components/layout/Logo.svelte';
</script>

<!-- Adapta tamanho baseado na tela -->
<div class="hidden md:block">
  <Logo size="md" variant="full" />
</div>

<div class="block md:hidden">
  <Logo size="sm" variant="icon" />
</div>
```

---

## 🔗 Recursos

- **Componente**: `src/lib/components/layout/Logo.svelte`
- **Assets**: `static/images/logo/`
- **Favicon**: `static/favicon.svg`
- **Design System**: `docs/design-system.md`

---

**Versão**: 1.0.0  
**Última atualização**: Outubro 2025