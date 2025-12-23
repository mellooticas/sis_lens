# 🗺️ Mapa de Dados Extraordinários
> Guia definitivo para conectar os dados robustos do schema `lens_catalog` com a interface ágil via `public` views.

## 🎯 Arquitetura de Dados (O Segredo do App Rápido)

O app não acessa as tabelas pesadas diretamente. Ele usa **Canais de Acesso** (Views e Funções) otimizados para cada situação de uso.

### 1. 🔍 Canal de Busca Inteligente (Prescription Matcher)
*Para quando o cliente chega com a receita na mão.*

- **Fonte:** `lens_catalog.lentes` + `lens_catalog.marcas`
- **Ferramenta:** Função `public.buscar_lentes_por_receita(esf, cil, add, tipo)`
- **Por que é extraordinário?**
  - Não baixa 1.400 lentes para filtrar no celular do vendedor.
  - O banco filtra dioptrias (`esferico_min/max`) instantaneamente.
  - Retorna apenas o que pode ser vendido. **Zero frustração.**
  - **Uso:** Tela "Nova Venda" > "Selecionar Lentes".

### 2. ⚡ Canal de Busca Rápida (Full Text)
*Para quando o vendedor digita "Varilux Comfort".*

- **Fonte:** Coluna indexada `busca_vector` (criada no script de upgrade)
- **Ferramenta:** Função `public.buscar_lentes_texto('varilux comfort')`
- **Por que é extraordinário?**
  - Instantâneo (< 50ms).
  - Encontra partes do nome, código ou descrição.
  - **Uso:** Barra de busca global ou catálogo.

### 3. 📋 Canal de Catálogo Visual (Navegação)
*Para explorar opções e comparar preços.*

- **Fonte:** View `public.vw_lentes_catalogo`
- **Estrutura:** Traz TUDO pronto (join com marcas, formatação de preços).
- **Colunas Chave:**
  - `nome_comercial` (Título do Card)
  - `marca_nome` & `marca_premium` (Badge de Qualidade)
  - `preco_tabela` (Preço Principal)
  - `ar`, `blue`, `fotossensivel` (Ícones de Tratamento - Booleanos prontos)
- **Uso:** Página `/catalogo` ou `/buscar`.

### 4. 📊 Canal de Business Intelligence (Gestão)
*Para o dono da ótica saber onde ganha dinheiro.*

- **Ferramenta:** View `public.vw_bi_lentes_lucratividade`
- **Dados:** Margem média por Marca e Categoria.
- **Uso:** Dashboard Administrativo.

---

## 🛠️ Como Garantir que Funcione (Passo a Passo)

Como estamos trabalhando com dados internos (`lens_catalog`) expostos em público, a sincronia é vital.

### Passo 1: Blindar a Estrutura (Crucial)
Mesmo "sem popular novamente", precisamos garantir que as tabelas internas tenham as colunas que as Views pedem (como `esferico_min`, `preco_tabela`). Se faltar uma coluna na tabela interna, a View Pública quebra.

👉 **Executar:** `povoar_banco/EXTRAORDINARY_DB_STRUCTURE_FIX_V3.sql`
*(Este script é seguro: ele só cria as colunas se elas não existirem. Não apaga dados.)*

### Passo 2: Criar os Canais de Acesso
Agora que a base tem as colunas, criamos as "janelas" (Views) para o mundo público ver.

👉 **Executar:** `povoar_banco/14_VIEWS_FINAIS_V3.sql`
*(Este script recria a `vw_lentes_catalogo` garantindo que ela leia todas as colunas novas.)*

### Passo 3: Testar a Inteligência
Verifique se o motor de busca está ativo.

```sql
-- Teste de busca por receita no SQL Editor
SELECT * FROM public.buscar_lentes_por_receita(-2.00, -0.50, 2.00, 'multifocal');
```

---

## ✨ Diferencial Competitivo dos Dados

| Dado Comum (Apps Normais) | Dado Extraordinário (Seu App) |
| :--- | :--- |
| Lista de nomes | **Filtro automático por grau (Esferico/Cilindrico)** |
| Pesquisa lenta (LIKE) | **Busca Vetorial Instantânea (Full Text Search)** |
| Preço estático | **Preço + Margem de Lucro (BI integrado)** |
| Filtro manual de tipo | **Detecção automática de compatibilidade** |

Utilize as Views e Funções sugeridas acima e seu Frontend ficará leve, rápido e à prova de falhas operacionais.
