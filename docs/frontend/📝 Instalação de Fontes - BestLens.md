# 📝 Instalação de Fontes - SIS Lens

## Opção 1: Google Fonts (Recomendado - Já incluído no CSS)

As fontes já estão configuradas no `app.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Montserrat:wght@700;800&display=swap');
```

✅ **Não precisa fazer nada!** As fontes carregam automaticamente.

---

## Opção 2: Self-Hosted (Melhor Performance)

Se preferir hospedar as fontes localmente:

### 1. Download das Fontes

**Inter**: https://fonts.google.com/specimen/Inter
- Baixar pesos: 300, 400, 500, 600, 700, 800

**Montserrat**: https://fonts.google.com/specimen/Montserrat
- Baixar pesos: 700, 800

### 2. Estrutura de Arquivos

```
apps/best_lens/static/fonts/
├── inter/
│   ├── Inter-Light.woff2         (300)
│   ├── Inter-Regular.woff2       (400)
│   ├── Inter-Medium.woff2        (500)
│   ├── Inter-SemiBold.woff2      (600)
│   ├── Inter-Bold.woff2          (700)
│   └── Inter-ExtraBold.woff2     (800)
└── montserrat/
    ├── Montserrat-Bold.woff2     (700)
    └── Montserrat-ExtraBold.woff2 (800)
```

### 3. Atualizar app.css

Substituir o import do Google Fonts por:

```css
/* Inter */
@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 300;
  font-display: swap;
  src: url('/fonts/inter/Inter-Light.woff2') format('woff2');
}

@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url('/fonts/inter/Inter-Regular.woff2') format('woff2');
}

@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 500;
  font-display: swap;
  src: url('/fonts/inter/Inter-Medium.woff2') format('woff2');
}

@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 600;
  font-display: swap;
  src: url('/fonts/inter/Inter-SemiBold.woff2') format('woff2');
}

@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 700;
  font-display: swap;
  src: url('/fonts/inter/Inter-Bold.woff2') format('woff2');
}

@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 800;
  font-display: swap;
  src: url('/fonts/inter/Inter-ExtraBold.woff2') format('woff2');
}

/* Montserrat */
@font-face {
  font-family: 'Montserrat';
  font-style: normal;
  font-weight: 700;
  font-display: swap;
  src: url('/fonts/montserrat/Montserrat-Bold.woff2') format('woff2');
}

@font-face {
  font-family: 'Montserrat';
  font-style: normal;
  font-weight: 800;
  font-display: swap;
  src: url('/fonts/montserrat/Montserrat-ExtraBold.woff2') format('woff2');
}
```

---

## ✅ Verificação

Para testar se as fontes estão carregando:

1. Abrir DevTools (F12)
2. Ir na aba **Network**
3. Filtrar por "Font"
4. Recarregar página
5. Verificar se `Inter-*.woff2` e `Montserrat-*.woff2` aparecem

---

## 🎯 Fallbacks

O sistema já tem fallbacks configurados:

```css
font-family: 'Inter', system-ui, -apple-system, sans-serif;
font-family: 'Montserrat', system-ui, -apple-system, sans-serif;
```

Se as fontes web não carregarem, usa fontes do sistema.