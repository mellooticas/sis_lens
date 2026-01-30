# Análise e Plano de Importação - Lentes de Contato

## 📊 Situação Atual

### CSVs Disponíveis

1. **lentenet.csv** - 75 produtos
   - Fonte: lentedecontato.lentenet.com.br
   - Campos: id, nome, sku, preco_original, preco_promocional, categorias, descricao, url, timestamp, http_status

2. **newlentes.csv** - 100 produtos
   - Fonte: newlentes.com.br
   - Campos: mesma estrutura do lentenet.csv

### Schema contact_lens

Estrutura já criada em `docs/database/reestruturation_database_sis_lens/02_CRIAR_CONTACT_LENS.sql`:

**Tabelas:**
- `contact_lens.lentes` - Tabela principal de lentes
- `contact_lens.marcas` - Marcas de lentes
- `contact_lens.grupos_canonicos` - Agrupamento de lentes similares

**ENUMs:**
- `tipo_lente_contato`: diaria, quinzenal, mensal, trimestral, anual, rgp, escleral
- `material_contato`: hidrogel, silicone_hidrogel, rgp_gas_perm, pmma
- `finalidade`: visao_simples, torica, multifocal, cosmetica, terapeutica, orto_k
- `status_produto`: ativo, inativo, descontinuado, pre_lancamento

## 🔍 Análise dos Dados

### Categorias Encontradas nos CSVs

**Tipos de Lente (baseado em período de troca):**
- Diárias
- Quinzenais
- Mensais
- Anuais

**Finalidades:**
- Astigmatismo / Tórica
- Multifocal / Multifocais
- Coloridas
- Visão Simples (padrão quando não especificado)

**Marcas Identificadas:**
- Acuvue (Johnson & Johnson) - Premium
- Alcon (Air Optix, Precision, Dailies) - Premium
- Bausch & Lomb (Soflens, Purevision, Biotrue, Ultra) - Premium
- CooperVision (Biofinity, Clariti, Proclear, Avaira, Biomedics) - Premium
- Solótica (Hidrocor, Natural Colors, Solflex) - Nacional
- Optolentes (Magic Top, Optogel) - Nacional
- Natural Vision - Nacional
- Central Oftálmica (Biosoft, Bioview) - Nacional

## 📋 Mapeamento de Dados

### Extração de Informações das Categorias

```
Categorias: "Acuvue; Diárias; Fabricantes; Lentes de contato"
→ Marca: Acuvue
→ Tipo: diaria
→ Finalidade: visao_simples

Categorias: "Astigmatismo / Tórica; Black Friday; CooperVision; Diárias"
→ Marca: CooperVision
→ Tipo: diaria
→ Finalidade: torica

Categorias: "CooperVision; Diárias; Lentes de contato; Multifocais"
→ Marca: CooperVision
→ Tipo: diaria
→ Finalidade: multifocal

Categorias: "Anuais; Coloridas; Fabricantes; Solótica"
→ Marca: Solótica
→ Tipo: anual
→ Finalidade: cosmetica
```

### Conversão de Preços

Os preços nos CSVs estão em centavos:
- `preco_original: 26600` → R$ 266,00
- `preco_promocional: 24500` → R$ 245,00

## 🎯 Plano de Importação

### Fase 1: Preparação do Banco

1. ✅ Verificar se schema `contact_lens` existe
2. ✅ Verificar tabelas e estrutura
3. ⏳ Criar fornecedores:
   - Lentenet (tipo: distribuidor)
   - NewLentes (tipo: distribuidor)

### Fase 2: Criação/Atualização de Marcas

Marcas já existentes no schema (ver linha 378-385 do 02_CRIAR_CONTACT_LENS.sql):
- Acuvue
- Air Optix
- Biofinity
- Dailies
- Biosoft
- Soflens
- Hidrocor

**Marcas a adicionar:**
- Bausch & Lomb (genérico)
- CooperVision (genérico)
- Alcon (genérico)
- Solótica (genérico)
- Precision
- Clariti
- Proclear
- Avaira
- Biomedics
- Purevision
- Biotrue
- Ultra
- Natural Colors
- Solflex
- Magic Top
- Optogel
- Natural Vision
- Lunare
- Bioview

### Fase 3: Script de Importação

Criar script Python/SQL para:

1. **Parser de Categorias**
   ```python
   def parse_categorias(categorias_str):
       categorias = categorias_str.split(';')
       
       # Extrair tipo de lente
       tipo = 'mensal'  # padrão
       if 'Diárias' in categorias:
           tipo = 'diaria'
       elif 'Quinzenais' in categorias:
           tipo = 'quinzenal'
       elif 'Mensais' in categorias:
           tipo = 'mensal'
       elif 'Anuais' in categorias:
           tipo = 'anual'
       
       # Extrair finalidade
       finalidade = 'visao_simples'  # padrão
       if 'Astigmatismo' in categorias or 'Tórica' in categorias:
           finalidade = 'torica'
       elif 'Multifocal' in categorias or 'Multifocais' in categorias:
           finalidade = 'multifocal'
       elif 'Coloridas' in categorias:
           finalidade = 'cosmetica'
       
       # Extrair marca (primeira palavra relevante)
       marcas_conhecidas = ['Acuvue', 'Alcon', 'Bausch', 'CooperVision', 'Solótica', ...]
       marca = next((m for m in marcas_conhecidas if m in categorias_str), None)
       
       return tipo, finalidade, marca
   ```

2. **Conversão de Preços**
   ```python
   def converter_preco(preco_centavos):
       return float(preco_centavos) / 100.0
   ```

3. **Determinar Material**
   ```python
   def determinar_material(marca, tipo):
       # Marcas premium geralmente usam silicone hidrogel
       marcas_premium = ['Acuvue', 'Air Optix', 'Biofinity', 'Dailies', 'Precision']
       
       if marca in marcas_premium:
           return 'silicone_hidrogel'
       else:
           return 'hidrogel'
   ```

### Fase 4: Validação

1. Verificar duplicatas (por nome/SKU)
2. Validar preços (não podem ser 0 ou negativos)
3. Verificar relacionamentos (marca_id, fornecedor_id)
4. Conferir enums (tipo_lente, finalidade, material)

### Fase 5: Criação de Grupos Canônicos

Após importação, agrupar lentes similares:
- Mesmo tipo de lente
- Mesma finalidade
- Mesmo material
- Faixa de preço similar

## 🚀 Próximos Passos

1. **Executar investigation.sql** no banco para ver estado atual
2. **Criar script de importação** (Python ou PL/pgSQL)
3. **Importar lentenet.csv** primeiro (75 produtos)
4. **Importar newlentes.csv** depois (100 produtos)
5. **Criar grupos canônicos** automaticamente
6. **Validar dados** importados
7. **Atualizar app** para usar schema contact_lens

## ⚠️ Considerações

- **Duplicatas**: Alguns produtos podem estar em ambos CSVs
- **Preços**: Verificar se são preços de custo ou venda
- **Fornecedor**: Decidir se lentenet e newlentes são fornecedores ou apenas fontes de dados
- **Estoque**: CSVs não têm info de estoque, iniciar com 0
- **Especificações técnicas**: CSVs não têm dados técnicos (diâmetro, curva base, etc)
