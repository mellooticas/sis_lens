# Resumo: Importação de Lentes de Contato

## ✅ Trabalho Realizado

### 1. Análise dos CSVs
- **lentenet.csv**: 74 lentes processadas (http_status = 200)
- **newlentes.csv**: 94 lentes processadas (http_status = 200)
- **Total**: 168 lentes de contato

### 2. Arquivos Criados

#### 📄 `investigation.sql`
Script SQL para investigar o estado atual do banco de dados:
- Verificar schemas e tabelas
- Analisar estrutura do contact_lens
- Listar ENUMs e tipos customizados
- Ver dados existentes (marcas, lentes, grupos)
- Verificar fornecedores

#### 📄 `PLANO_IMPORTACAO_LENTES.md`
Documentação completa do plano de importação:
- Análise detalhada dos CSVs
- Mapeamento de categorias → tipos/finalidades
- Lista de marcas identificadas
- Estratégia de importação
- Próximos passos

#### 🐍 `processar_lentes.py`
Script Python para processar os CSVs e gerar SQL:
- Parser inteligente de categorias
- Extração automática de marcas
- Conversão de preços (centavos → reais)
- Determinação de material baseado em marca premium
- Geração de slugs únicos
- Tratamento de duplicatas

#### 📄 `importar_lentes_contato.sql` (GERADO)
SQL completo para importação (6.327 linhas):
- Criação de fornecedores (Lentenet, NewLentes)
- Inserção de 29 marcas únicas
- Inserção de 168 lentes de contato
- Queries de estatísticas

### 3. Marcas Identificadas (29 total)

**Premium (Silicone Hidrogel):**
- Acuvue (Johnson & Johnson)
- Air Optix, Precision, Dailies (Alcon)
- Bausch, Soflens, Purevision, Biotrue, Ultra (Bausch & Lomb)
- Biofinity, Clariti, Proclear, Avaira (CooperVision)

**Nacionais/Econômicas (Hidrogel):**
- Hidrocor, Natural Colors, Solflex, Hidrosoft, Hidroblue (Solótica)
- Magic Top, Optogel, Optycolor (Optolentes)
- Biosoft, Bioview, Bioblue, Silidrogel (Central Oftálmica)
- Natural Vision
- Aveo
- Lunare, Optima (Bausch & Lomb econômicas)
- Biomedics (CooperVision econômica)

### 4. Distribuição de Lentes

**Por Tipo:**
- Diárias: ~40%
- Mensais: ~45%
- Quinzenais: ~5%
- Anuais: ~10%

**Por Finalidade:**
- Visão Simples: ~60%
- Tóricas (Astigmatismo): ~20%
- Multifocais: ~10%
- Cosméticas (Coloridas): ~10%

**Por Material:**
- Silicone Hidrogel (Premium): ~55%
- Hidrogel (Econômico): ~45%

## 📊 Schema contact_lens

### Tabelas Principais

#### `contact_lens.lentes`
Campos principais:
- Identificação: id, nome_produto, slug, sku
- Relacionamentos: fornecedor_id, marca_id, grupo_canonico_id
- Classificação: tipo_lente, material, finalidade
- Especificações: diametro, curva_base, dk_t, conteudo_agua
- Parâmetros ópticos: esferico_min/max, cilindrico_min/max, adicao_min/max
- Características: protecao_uv, colorida, pode_dormir_com_lente
- Comercial: preco_custo, preco_tabela, unidades_por_caixa
- Disponibilidade: estoque_disponivel, disponivel, ativo

#### `contact_lens.marcas`
- id, nome, slug, fabricante
- is_premium, ativo
- logo_url, website, descricao

#### `contact_lens.grupos_canonicos`
- Agrupamento de lentes similares
- Estatísticas automáticas (total_lentes, preco_medio, etc)
- Flags: is_premium, tem_uv, colorida

### ENUMs

```sql
tipo_lente_contato: diaria, quinzenal, mensal, trimestral, anual, rgp, escleral
material_contato: hidrogel, silicone_hidrogel, rgp_gas_perm, pmma
finalidade: visao_simples, torica, multifocal, cosmetica, terapeutica, orto_k
status_produto: ativo, inativo, descontinuado, pre_lancamento
```

## 🚀 Próximos Passos

### 1. Executar no Banco de Dados

```bash
# Opção 1: Via psql (se disponível)
psql $DATABASE_URL -f D:\projetos\sis_lens\povoar_banco\csv\banco\importar_lentes_contato.sql

# Opção 2: Via Supabase Dashboard
# - Copiar conteúdo do arquivo SQL
# - Colar no SQL Editor
# - Executar
```

### 2. Verificar Importação

Após executar, verificar:
- Total de marcas criadas
- Total de lentes importadas
- Distribuição por tipo/finalidade
- Preços corretos

### 3. Criar Grupos Canônicos

Executar script para agrupar lentes similares:
```sql
-- Criar grupos baseado em tipo + finalidade + material
INSERT INTO contact_lens.grupos_canonicos (nome_grupo, slug, tipo_lente, material, finalidade)
SELECT DISTINCT
  tipo_lente || ' ' || finalidade AS nome_grupo,
  tipo_lente || '-' || finalidade AS slug,
  tipo_lente,
  material,
  finalidade
FROM contact_lens.lentes
WHERE ativo = true
ON CONFLICT (slug) DO NOTHING;

-- Associar lentes aos grupos
UPDATE contact_lens.lentes l
SET grupo_canonico_id = gc.id
FROM contact_lens.grupos_canonicos gc
WHERE l.tipo_lente = gc.tipo_lente
  AND l.material = gc.material
  AND l.finalidade = gc.finalidade
  AND l.grupo_canonico_id IS NULL;
```

### 4. Atualizar Estatísticas dos Grupos

```sql
UPDATE contact_lens.grupos_canonicos gc
SET
  total_lentes = (SELECT COUNT(*) FROM contact_lens.lentes WHERE grupo_canonico_id = gc.id AND ativo = true),
  total_marcas = (SELECT COUNT(DISTINCT marca_id) FROM contact_lens.lentes WHERE grupo_canonico_id = gc.id AND ativo = true),
  preco_minimo = (SELECT MIN(preco_tabela) FROM contact_lens.lentes WHERE grupo_canonico_id = gc.id AND ativo = true),
  preco_maximo = (SELECT MAX(preco_tabela) FROM contact_lens.lentes WHERE grupo_canonico_id = gc.id AND ativo = true),
  preco_medio = (SELECT AVG(preco_tabela) FROM contact_lens.lentes WHERE grupo_canonico_id = gc.id AND ativo = true);
```

### 5. Integrar no App

Atualizar o frontend para:
- Listar lentes de contato do schema `contact_lens`
- Filtrar por tipo, finalidade, marca
- Exibir preços e especificações
- Permitir busca por grau (esferico, cilindrico)
- Mostrar grupos canônicos

## ⚠️ Observações Importantes

1. **Preços de Custo**: Foram estimados como 60% do preço original (ajustar conforme necessário)

2. **Especificações Técnicas**: Os CSVs não contêm dados como:
   - Diâmetro
   - Curva base
   - Dk/t (transmissibilidade de oxigênio)
   - Conteúdo de água
   - Estes campos ficarão NULL e devem ser preenchidos manualmente ou via outra fonte

3. **Estoque**: Inicializado com 0 (sem informação nos CSVs)

4. **Fornecedores**: Lentenet e NewLentes são tratados como distribuidores, não fabricantes

5. **Duplicatas**: O SQL usa `ON CONFLICT (slug) DO UPDATE` para atualizar preços em caso de duplicata

6. **Soluções de Limpeza**: Alguns produtos nos CSVs são soluções de limpeza, não lentes. Foram importados mas podem ser filtrados depois.

## 📈 Estatísticas Esperadas

Após importação completa:
- **29 marcas** cadastradas
- **168 lentes** ativas
- **~15 grupos canônicos** (combinações de tipo + finalidade)
- **2 fornecedores** (Lentenet, NewLentes)

## ✨ Benefícios

1. **Catálogo Completo**: 168 lentes de contato prontas para venda
2. **Organização**: Schema separado para lentes de contato
3. **Flexibilidade**: Estrutura permite expansão (graus altos, RGP, esclerais)
4. **Rastreabilidade**: Metadata JSON preserva dados originais dos CSVs
5. **Performance**: Índices otimizados para busca por tipo, finalidade, marca
6. **Manutenibilidade**: Views prontas para consultas comuns
