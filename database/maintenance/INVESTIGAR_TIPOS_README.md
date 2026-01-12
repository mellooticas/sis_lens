# 🔍 Investigação: Tipos de Dados - buscar_lentes_por_receita

## ❌ Erros Encontrados (Cronologia)

### Erro 1: Coluna não existe
```
ERROR: column v.nome_lente does not exist
```
✅ **Resolvido**: Usar `nome_comercial` ao invés de `nome_lente`

### Erro 2: Operador não existe para ENUM
```
ERROR: operator does not exist: lens_catalog.tipo_lente = text
```
✅ **Resolvido**: Adicionar `::TEXT` nas comparações WHERE

### Erro 3: Valor inválido do ENUM
```
ERROR: invalid input value for enum lens_catalog.indice_refracao: "1.76"
```
✅ **Resolvido**: Usar valores corretos: 1.50, 1.56, 1.59, 1.61, 1.67, 1.74

### Erro 4: Tipo do retorno não corresponde
```
ERROR: structure of query does not match function result type
DETAIL: Returned type lens_catalog.tipo_lente does not match expected type text in column 3
```
✅ **Resolvido**: Adicionar `::TEXT` no SELECT para converter ENUMs

### Erro 5: VARCHAR vs TEXT
```
ERROR: Returned type character varying(100) does not match expected type text in column 8
```
⚠️ **ATUAL**: Coluna 8 = `marca_nome` é VARCHAR(100), não TEXT

## 🎯 Próximos Passos

Execute o arquivo `INVESTIGAR_TIPOS_VIEW.sql` no Supabase para:

1. ✅ Ver todos os tipos de dados da view
2. ✅ Identificar quais colunas são VARCHAR vs TEXT
3. ✅ Verificar estrutura da tabela marcas
4. ✅ Testar SELECT com casts corretos
5. ✅ Ajustar RETURNS TABLE com tipos corretos

## 📋 Colunas da Função (posição = problema)

| # | Nome              | Tipo Esperado | Tipo Real      | Status |
|---|-------------------|---------------|----------------|--------|
| 1 | id                | UUID          | UUID           | ✅     |
| 2 | nome_comercial    | TEXT          | VARCHAR(?)     | ❓     |
| 3 | tipo_lente        | TEXT          | ENUM→TEXT      | ✅     |
| 4 | categoria         | TEXT          | ENUM→TEXT      | ✅     |
| 5 | material          | TEXT          | ENUM→TEXT      | ✅     |
| 6 | indice_refracao   | TEXT          | ENUM→TEXT      | ✅     |
| 7 | preco_tabela      | NUMERIC       | NUMERIC        | ✅     |
| 8 | marca_nome        | TEXT          | VARCHAR(100)   | ❌ ERRO |
| 9 | marca_premium     | BOOLEAN       | BOOLEAN        | ❓     |
| 10| ar                | BOOLEAN       | BOOLEAN        | ❓     |
| 11| blue              | BOOLEAN       | BOOLEAN        | ❓     |
| 12| fotossensivel     | BOOLEAN       | ENUM→TEXT      | ❌     |
| 13| uv400             | BOOLEAN       | BOOLEAN        | ❓     |
| 14| esferico_min      | NUMERIC       | NUMERIC        | ❓     |
| 15| esferico_max      | NUMERIC       | NUMERIC        | ❓     |
| 16| cilindrico_min    | NUMERIC       | NUMERIC        | ❓     |
| 17| cilindrico_max    | NUMERIC       | NUMERIC        | ❓     |
| 18| adicao_min        | NUMERIC       | NUMERIC        | ❓     |
| 19| adicao_max        | NUMERIC       | NUMERIC        | ❓     |

## 🔧 Possíveis Soluções

### Opção 1: Mudar RETURNS TABLE
Usar os tipos EXATOS da view (VARCHAR, etc.)

### Opção 2: Cast no SELECT
Adicionar `::TEXT` para converter VARCHAR → TEXT

### Opção 3: Investigar fotossensivel
- Esperamos BOOLEAN no RETURNS TABLE
- View retorna ENUM tratamento_foto
- Já fizemos cast ::TEXT
- **Problema**: Deveria ser BOOLEAN ou TEXT?

## 📝 Próxima Ação

Execute `INVESTIGAR_TIPOS_VIEW.sql` e cole aqui os resultados da Query 1.
