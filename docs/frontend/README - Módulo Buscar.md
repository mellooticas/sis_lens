# 📁 Módulo Buscar - Documentação

## Estrutura de Arquivos

```
src/routes/buscar/
├── +page.server.ts    ✅ MANTER - Server load e actions
├── +page.svelte       ✅ MANTER - Interface principal
└── +page.ts           ❌ REMOVER - Redundante
```

---

## ✅ Arquivos Essenciais

### **1. `+page.server.ts`** (Server-Side)

**Responsabilidades:**
- Carregar dados iniciais (estatísticas, fornecedores)
- Processar busca via RPC `rpc_buscar_lente`
- Aplicar filtros avançados
- Retornar dados formatados para a página

**RPCs Utilizados:**
```sql
-- Busca de lentes
rpc_buscar_lente(p_query, p_limit)

-- Estatísticas (custom - precisa criar)
get_busca_stats() -- retorna total_lentes, preco_medio
```

**Fluxo:**
1. **Load**: Busca inicial se há query na URL
2. **Action `buscar`**: Processa formulário com filtros
3. Retorna dados para renderização

---

### **2. `+page.svelte`** (Client-Side)

**Componentes Usados:**
- ✅ Layout: `Header`, `Footer`, `Container`, `PageHero`, `SectionHeader`
- ✅ Forms: `Input`, `Select`
- ✅ UI: `Button`, `Badge`, `Table`, `EmptyState`, `LoadingSpinner`
- ✅ Cards: `StatsCard`, `ActionCard`

**Features:**
- 🔍 Busca principal (query)
- 🎛️ Filtros avançados colapsáveis
- 📊 Estatísticas em cards
- 📋 Tabela de resultados
- 🚀 Ações rápidas (Ranking, Histórico, Fornecedores)

**Estados Reativos:**
```typescript
$: lentes = form?.lentes || data.lentes || [];
$: temResultados = lentes.length > 0;
$: temFiltrosAtivos = categoria || material || preco_min || preco_max;
```

---

## ❌ Arquivo para Remover

### **`+page.ts`** (Client Load)

**Por que remover:**
1. **Redundante**: O `.server.ts` já faz todo o load necessário
2. **Performance**: Evita double-loading (cliente + servidor)
3. **Complexidade**: Não adiciona valor ao fluxo

**Se existir, pode deletar sem medo!**

```bash
rm src/routes/buscar/+page.ts
```

---

## 🔧 Dependências Necessárias

### **RPC que PRECISA CRIAR** (se não existe):

```sql
-- Estatísticas de busca
CREATE OR REPLACE FUNCTION get_busca_stats()
RETURNS TABLE(
  total_lentes INTEGER,
  preco_medio NUMERIC
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER AS total_lentes,
    ROUND(AVG(preco_base), 2) AS preco_medio
  FROM vw_lentes_catalogo
  WHERE ativo = true;
END;
$$;
```

### **RPC Existente** (já funciona):
- ✅ `rpc_buscar_lente(p_query, p_limit)`

---

## 🎯 Fluxo de Uso

1. **Usuário acessa** `/buscar`
   - Load server carrega estatísticas
   - Renderiza formulário vazio

2. **Usuário digita busca** e clica "Buscar"
   - Form submit → action `buscar`
   - Server chama `rpc_buscar_lente`
   - Aplica filtros (categoria, material, preço)
   - Retorna resultados

3. **Resultados exibidos**
   - Tabela com lentes
   - Botões "Ver Ranking" e "Ver Detalhes"

4. **Navegação**
   - Ranking: `/ranking/{lente_id}`
   - Detalhes: `/lentes/{lente_id}`

---

## 🧪 Testes Recomendados

### **Teste 1: Busca Simples**
```typescript
// Input: "Varilux"
// Esperado: Lista de lentes Varilux
```

### **Teste 2: Filtros Avançados**
```typescript
// Input: query="Essilor", categoria="progressiva", material="hi-index-1.67"
// Esperado: Lentes progressivas Essilor em Hi-Index 1.67
```

### **Teste 3: Sem Resultados**
```typescript
// Input: "XXXXXXXXX"
// Esperado: EmptyState com mensagem "Nenhuma lente encontrada"
```

### **Teste 4: Performance**
```typescript
// Busca com 1000+ resultados
// Esperado: < 500ms de resposta
```

---

## 📊 Métricas

**KPIs para monitorar:**
- ⏱️ Tempo médio de busca: < 300ms
- 📈 Taxa de conversão (busca → ranking): > 60%
- 🔄 Taxa de rejeição (busca sem resultados): < 20%
- 🎯 Uso de filtros avançados: > 30%

---

## 🚀 Próximos Passos

1. **Criar RPC** `get_busca_stats()` se não existir
2. **Testar** busca com diferentes queries
3. **Validar** filtros avançados
4. **Integrar** com módulo de Ranking
5. **Adicionar** analytics (track buscas populares)

---

## 📝 Notas Importantes

⚠️ **Lembre-se:**
- RPC `rpc_buscar_lente` retorna dados da view `vw_lentes_catalogo`
- Filtros de preço são aplicados no servidor (segurança)
- Tratamentos são arrays no banco (usar `@>` para buscar)
- SKU fantasia é o identificador amigável

✅ **Boas práticas:**
- Sempre validar query no servidor
- Limitar resultados (max 100)
- Cachear estatísticas quando possível
- Usar debounce em autosuggest futuro



# ✅ Correções Finais - Módulo Buscar

## 📝 **O que foi ajustado:**

### ✅ **1. Imports corrigidos no `+page.server.ts`**
**Antes:**
```typescript
import { getSupabaseServerClient } from '$lib/server/supabase';
```

**Agora:**
```typescript
import { supabase } from '$lib/supabase';
```

---

### ✅ **2. Imports corrigidos no `+page.svelte`**
**Antes:**
```typescript
import { addToast } from '$lib/stores/toast';
```

**Agora:**
```typescript
import { toast } from '$lib/stores/toast';
```

---

### ✅ **3. Uso do toast corrigido**
**Antes:**
```typescript
addToast({ type: 'success', message: 'Mensagem' });
```

**Agora:**
```typescript
toast.show('Mensagem', 'success');
```

---

## 🚀 **Ação Necessária:**

### **OPÇÃO A: Copiar arquivos atualizados** (Recomendado)

1. **Copie novamente o `+page.server.ts`**
   - Use o artifact atualizado: **"+page.server.ts - Server Load Buscar Lentes"**
   - Sobrescreva o arquivo existente

2. **Copie novamente o `+page.svelte`**
   - Use o artifact atualizado: **"+page.svelte - Interface Buscar Lentes"**
   - Sobrescreva o arquivo existente

3. **Reinicie o servidor**
   ```bash
   # Parar (Ctrl+C)
   npm run dev
   ```

---

### **OPÇÃO B: Editar manualmente** (Se preferir)

#### No arquivo `src/routes/buscar/+page.server.ts`:

**Linha 4 - Alterar de:**
```typescript
import { getSupabaseServerClient } from '$lib/server/supabase';
```

**Para:**
```typescript
import { supabase } from '$lib/supabase';
```

**Linha 13 - REMOVER esta linha:**
```typescript
const supabase = getSupabaseServerClient(locals);
```

**Linha 63 (dentro da action) - REMOVER esta linha:**
```typescript
const supabase = getSupabaseServerClient(locals);
```

---

#### No arquivo `src/routes/buscar/+page.svelte`:

**Linha ~28 - Alterar de:**
```typescript
import { addToast } from '$lib/stores/toast';
```

**Para:**
```typescript
import { toast } from '$lib/stores/toast';
```

**Linha ~42 - Alterar de:**
```typescript
$: if (form?.sucesso) {
  addToast({ type: 'success', message: form.mensagem || 'Busca realizada com sucesso' });
} else if (form?.erro) {
  addToast({ type: 'error', message: form.erro });
}
```

**Para:**
```typescript
$: if (form?.sucesso) {
  toast.show(form.mensagem || 'Busca realizada com sucesso', 'success');
} else if (form?.erro) {
  toast.show(form.erro, 'error');
}
```

---

## 🧪 **Testar novamente:**

```bash
npm run dev
```

Acesse: **http://localhost:5173/buscar**

---

## ✅ **O que deve funcionar agora:**

1. ✅ Página carrega sem erros
2. ✅ Cards de estatísticas aparecem (4 lentes, 3 fornecedores, R$ 300)
3. ✅ Buscar "Varilux" retorna resultado
4. ✅ Tabela mostra lentes encontradas
5. ✅ Botão "Ver Ranking" navega para `/ranking/{id}`

---

## 🐛 **Se ainda der erro:**

### Erro: "Cannot find module '$lib/supabase'"

**Verifique onde está o arquivo do Supabase:**
```bash
find src -name "supabase.ts"
```

**Possíveis localizações:**
- `src/lib/supabase.ts` ✅
- `src/lib/db/supabase.ts`
- `src/lib/config/supabase.ts`

**Se estiver em outro local, ajuste o import:**
```typescript
import { supabase } from '$lib/caminho/correto/supabase';
```

---

### Erro: "Cannot find module '$lib/stores/toast'"

**Verifique onde está o arquivo de toast:**
```bash
find src -name "toast.ts"
```

**Se estiver em outro local, ajuste o import**

---

## 📊 **Status Final:**

| Item | Status |
|------|--------|
| ✅ SQL Functions | OK |
| ✅ Dados de teste | 4 lentes OK |
| ✅ Imports corrigidos | OK |
| ⏳ Testar interface | Pendente |

---

## 🚀 **Próximo Passo:**

Após confirmar que funciona, podemos:

1. **Criar mais lentes de teste** (seeds)
2. **Implementar filtros avançados**
3. **Criar módulo Ranking**
4. **Adicionar autocomplete**

---

**Me avise:**
- ✅ Se funcionou!
- ❌ Se ainda tiver erro (copie a mensagem completa)
- 🤔 Se tiver dúvidas sobre os imports