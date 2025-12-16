# 🎯 Como Popular o Banco de Dados

## Problema Identificado

O frontend está mostrando **tudo em 0** porque o banco de dados está vazio. Mesmo que as funções públicas estejam funcionando corretamente, elas retornam dados vazios.

## Solução Rápida

### Opção 1: Via Supabase SQL Editor (RECOMENDADO - 2 minutos)

1. Acesse o Supabase Dashboard: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **SQL Editor** (menu lateral esquerdo)
4. Abra o arquivo: `scripts/popular_dados_demo.sql`
5. Copie TODO o conteúdo
6. Cole no SQL Editor
7. Clique em **RUN** (ou Ctrl+Enter)

### O que será criado:

✅ **1 Tenant Demo** (Ótica Demo)  
✅ **3 Laboratórios:**
   - SIS Lens (Rápido - 3 dias)
   - Essilor (Premium - 5 dias)
   - Zeiss (Equilibrado - 4 dias)

✅ **Scores para cada Lab:**
   - SIS Lens: score_geral=85.5 (ótimo prazo=95)
   - Essilor: score_geral=92.0 (ótima qualidade=98)
   - Zeiss: score_geral=88.0 (equilibrado)

✅ **3 Marcas:**
   - SIS Lens (Marca Própria)
   - Essilor
   - Zeiss

✅ **5 Lentes de Exemplo:**
   - 2 da SIS Lens
   - 2 da Zeiss
   - 1 da Essilor

### Opção 2: Via Seeds Completos (10-15 minutos)

Se preferir dados mais completos (catálogos Essilor, Zeiss, Hoya completos):

```bash
cd database/seeds
./executar_populacao.sh prod
```

## Verificação Após Popular

Execute no SQL Editor do Supabase:

```sql
-- Verificar se há dados
SELECT 'LABORATÓRIOS' as tipo, COUNT(*) FROM suppliers.laboratorios;
SELECT 'SCORES' as tipo, COUNT(*) FROM scoring.scores_laboratorios;
SELECT 'LENTES' as tipo, COUNT(*) FROM lens_catalog.lentes;

-- Testar view pública
SELECT * FROM public.vw_laboratorios_completo;

-- Testar dashboard
SELECT public.obter_dashboard_kpis();
```

**Resultado Esperado:**
- LABORATÓRIOS: 3
- SCORES: 3
- LENTES: 5
- View retorna 3 labs com scores
- Dashboard retorna JSON com labs_ativos=3

## Após Popular

1. **Atualize a página** do frontend (http://localhost:5173)
2. Verifique que:
   - Dashboard mostra 3 labs ativos
   - Página de Fornecedores lista 3 laboratórios
   - Scores aparecem nos cards

## Troubleshooting

### Se ainda aparecer tudo 0:

1. Verifique no console do navegador (F12) se há erros
2. Verifique no terminal do servidor se há erros de conexão
3. Confirme que as variáveis de ambiente estão corretas:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

### Se der erro de permissão:

```sql
-- Execute no SQL Editor
GRANT USAGE ON SCHEMA suppliers TO authenticated;
GRANT SELECT ON suppliers.laboratorios TO authenticated;
GRANT USAGE ON SCHEMA scoring TO authenticated;
GRANT SELECT ON scoring.scores_laboratorios TO authenticated;
```

## Próximos Passos

Depois de confirmar que os dados aparecem:

1. ✅ Testar busca de lentes
2. ✅ Criar uma decisão de compra
3. ✅ Verificar ranking de fornecedores
4. 📊 Adicionar mais lentes conforme necessário
