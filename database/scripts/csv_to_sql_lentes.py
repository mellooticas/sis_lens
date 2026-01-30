#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CSV para SQL - Conversor de Lentes para SIS Lens
=================================================

Este script converte um arquivo CSV com lentes para comandos SQL INSERT.
Baseado na estrutura REAL da tabela lens_catalog.lentes (Jan/2026).

USO:
    python csv_to_sql_lentes.py input.csv output.sql --fornecedor-id UUID --marca-id UUID

IMPORTANTE:
    - O preco_venda_sugerido é calculado AUTOMATICAMENTE pela trigger
    - O grupo_canonico_id é atribuído AUTOMATICAMENTE pela trigger
    - O slug é gerado AUTOMATICAMENTE pela trigger

ESTRUTURA DO CSV:
    - nome_lente (obrigatório): Nome da lente
    - tipo_lente (obrigatório): visao_simples, multifocal, bifocal
    - material (obrigatório): CR39, POLICARBONATO, HIGH_INDEX
    - indice_refracao (obrigatório): 1.50, 1.56, 1.59, 1.61, 1.67, 1.74
    - categoria (obrigatório): economica, intermediaria, premium
    - preco_custo (obrigatório): Custo de compra
    - grau_esferico_min, grau_esferico_max
    - grau_cilindrico_min, grau_cilindrico_max
    - adicao_min, adicao_max (para multifocais)
    - tratamento_antirreflexo, tratamento_blue_light, etc. (boolean)
    - fotossensivel: nenhum, transitions, fotocromático, acclimates, polarizado
"""

import csv
import uuid
import argparse
import sys
from pathlib import Path
from typing import Optional, Dict, Any, List, Tuple


# Valores válidos para enums (baseado no banco real)
TIPOS_LENTE = ['visao_simples', 'multifocal', 'bifocal']
MATERIAIS = ['CR39', 'POLICARBONATO', 'HIGH_INDEX', 'TRIVEX']
INDICES = ['1.50', '1.56', '1.59', '1.61', '1.67', '1.74', '1.49']
CATEGORIAS = ['economica', 'intermediaria', 'premium']
FOTOSSENSIVEIS = ['nenhum', 'transitions', 'fotocromático', 'fotocrom\u00e1tico', 'acclimates', 'polarizado']
TRATAMENTOS_FOTO_ENUM = ['nenhum', 'fotocromático']  # Valores do ENUM lens_catalog.tratamento_foto


def parse_boolean(value: str) -> bool:
    """Converte string para boolean."""
    if not value:
        return False
    return str(value).lower().strip() in ('true', 'yes', 'sim', '1', 't', 's')


def parse_numeric(value: str) -> Optional[float]:
    """Converte string para numeric, retorna None se vazio."""
    if not value or str(value).strip() == '':
        return None
    try:
        return float(str(value).replace(',', '.'))
    except ValueError:
        return None


def escape_sql(value: str) -> str:
    """Escapa aspas simples para SQL."""
    if value is None:
        return ''
    return str(value).replace("'", "''")


def convert_fotossensivel_to_enum(value: str) -> str:
    """Converte valor de fotossensivel TEXT para ENUM tratamento_foto."""
    if not value or value.lower() == 'nenhum':
        return 'nenhum'
    if value.lower() in ('transitions', 'fotocromático', 'fotocrom\u00e1tico', 'acclimates'):
        return 'fotocromático'
    return 'nenhum'


def validate_row(row: Dict[str, Any], line_num: int) -> List[str]:
    """Valida uma linha do CSV e retorna lista de erros."""
    errors = []

    # Campos obrigatórios
    required = ['nome_lente', 'tipo_lente', 'material', 'indice_refracao',
                'categoria', 'preco_custo']

    for field in required:
        if field not in row or not row[field] or str(row[field]).strip() == '':
            errors.append(f"Linha {line_num}: Campo obrigatório '{field}' está vazio")

    # Validar enums
    tipo = str(row.get('tipo_lente', '')).lower().strip()
    if tipo and tipo not in TIPOS_LENTE:
        errors.append(f"Linha {line_num}: tipo_lente inválido '{tipo}'. "
                      f"Válidos: {TIPOS_LENTE}")

    material = str(row.get('material', '')).upper().strip()
    if material and material not in MATERIAIS:
        errors.append(f"Linha {line_num}: material inválido '{material}'. "
                      f"Válidos: {MATERIAIS}")

    indice = str(row.get('indice_refracao', '')).strip()
    if indice and indice not in INDICES:
        errors.append(f"Linha {line_num}: indice_refracao inválido '{indice}'. "
                      f"Válidos: {INDICES}")

    categoria = str(row.get('categoria', '')).lower().strip()
    if categoria and categoria not in CATEGORIAS:
        errors.append(f"Linha {line_num}: categoria inválida '{categoria}'. "
                      f"Válidos: {CATEGORIAS}")

    foto = str(row.get('fotossensivel', 'nenhum')).lower().strip()
    if foto and foto not in FOTOSSENSIVEIS:
        errors.append(f"Linha {line_num}: fotossensivel inválido '{foto}'. "
                      f"Válidos: {FOTOSSENSIVEIS}")

    # Validar preco_custo é número
    preco = parse_numeric(row.get('preco_custo', ''))
    if preco is None and 'preco_custo' in row and row['preco_custo']:
        errors.append(f"Linha {line_num}: preco_custo inválido '{row['preco_custo']}' - deve ser número")

    return errors


def row_to_sql_values(row: Dict[str, Any], fornecedor_id: str, marca_id: Optional[str]) -> str:
    """Converte uma linha do CSV para VALUES do SQL."""

    # Processar campos obrigatórios
    nome = escape_sql(row.get('nome_lente', ''))
    tipo = str(row.get('tipo_lente', 'visao_simples')).lower().strip()
    material = str(row.get('material', 'CR39')).upper().strip()
    indice = str(row.get('indice_refracao', '1.56')).strip()
    categoria = str(row.get('categoria', 'intermediaria')).lower().strip()
    preco_custo = parse_numeric(row.get('preco_custo', '0')) or 0

    # Campos de grau
    esf_min = parse_numeric(row.get('grau_esferico_min') or row.get('esferico_min'))
    esf_max = parse_numeric(row.get('grau_esferico_max') or row.get('esferico_max'))
    cil_min = parse_numeric(row.get('grau_cilindrico_min') or row.get('cilindrico_min'))
    cil_max = parse_numeric(row.get('grau_cilindrico_max') or row.get('cilindrico_max'))
    adi_min = parse_numeric(row.get('adicao_min'))
    adi_max = parse_numeric(row.get('adicao_max'))

    # Tratamentos (novos campos)
    trat_ar = parse_boolean(row.get('tratamento_antirreflexo') or row.get('ar'))
    trat_antirrisco = parse_boolean(row.get('tratamento_antirrisco') or row.get('antirrisco'))
    trat_uv = parse_boolean(row.get('tratamento_uv') or row.get('uv400'))
    trat_blue = parse_boolean(row.get('tratamento_blue_light') or row.get('blue'))

    # Fotossensivel
    foto_text = str(row.get('fotossensivel', 'nenhum')).lower().strip()
    foto_enum = convert_fotossensivel_to_enum(foto_text)

    # Identificadores
    sku = row.get('sku') or row.get('sku_fornecedor') or f"LVN-{uuid.uuid4().hex[:8].upper()}"
    codigo = row.get('codigo_fornecedor') or row.get('codigo_original')

    # Formatar valores NULL
    def sql_val(v, is_string=False):
        if v is None:
            return 'NULL'
        if is_string:
            return f"'{escape_sql(str(v))}'"
        return str(v)

    def sql_uuid(v):
        if v is None or v == '' or v.lower() == 'null':
            return 'NULL'
        return f"'{v}'"

    # Montar VALUES
    values = f"""(
    '{nome}',
    '{fornecedor_id}',
    {sql_uuid(marca_id)},
    '{tipo}'::lens_catalog.tipo_lente,
    '{material}'::lens_catalog.material_lente,
    '{indice}'::lens_catalog.indice_refracao,
    '{categoria}'::lens_catalog.categoria_lente,
    {preco_custo},
    {sql_val(esf_min)},
    {sql_val(esf_max)},
    {sql_val(cil_min)},
    {sql_val(cil_max)},
    {sql_val(adi_min)},
    {sql_val(adi_max)},
    {str(trat_ar).lower()},
    {str(trat_antirrisco).lower()},
    {str(trat_uv).lower()},
    {str(trat_blue).lower()},
    '{foto_enum}'::lens_catalog.tratamento_foto,
    '{foto_text}',
    '{sku}',
    {sql_val(codigo, True) if codigo else 'NULL'},
    'ativo'::lens_catalog.status_lente,
    true
)"""
    return values


def convert_csv_to_sql(input_file: str, output_file: str,
                       fornecedor_id: str, marca_id: Optional[str],
                       batch_size: int = 50) -> Tuple[int, List[str]]:
    """
    Converte CSV para SQL.
    Retorna (total_linhas, erros)
    """
    errors = []
    values_list = []
    total = 0

    with open(input_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)

        for i, row in enumerate(reader, start=2):  # Começa em 2 (linha 1 é header)
            # Validar
            row_errors = validate_row(row, i)
            if row_errors:
                errors.extend(row_errors)
                continue

            # Converter para SQL
            values = row_to_sql_values(row, fornecedor_id, marca_id)
            values_list.append(values)
            total += 1

    # Gerar arquivo SQL
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"""-- ============================================================================
-- SQL GERADO AUTOMATICAMENTE - SIS LENS
-- ============================================================================
-- Arquivo fonte: {input_file}
-- Total de lentes: {total}
-- Fornecedor ID: {fornecedor_id}
-- Marca ID: {marca_id or 'NULL'}
-- ============================================================================
--
-- IMPORTANTE:
-- - preco_venda_sugerido será calculado AUTOMATICAMENTE pela trigger
-- - grupo_canonico_id será atribuído AUTOMATICAMENTE pela trigger
-- - slug será gerado AUTOMATICAMENTE pela trigger
--
-- ============================================================================

-- Inserir lentes
INSERT INTO lens_catalog.lentes (
    -- Campos obrigatórios
    nome_lente,
    fornecedor_id,
    marca_id,
    tipo_lente,
    material,
    indice_refracao,
    categoria,
    preco_custo,
    -- Campos de grau
    grau_esferico_min,
    grau_esferico_max,
    grau_cilindrico_min,
    grau_cilindrico_max,
    adicao_min,
    adicao_max,
    -- Tratamentos (usados na canonização)
    tratamento_antirreflexo,
    tratamento_antirrisco,
    tratamento_uv,
    tratamento_blue_light,
    tratamento_fotossensiveis,
    -- Campo legado
    fotossensivel,
    -- Identificadores
    sku,
    codigo_fornecedor,
    -- Status
    status,
    ativo
) VALUES
""")
        # Escrever valores
        f.write(",\n".join(values_list))
        f.write(";\n")

        # Adicionar verificação
        f.write(f"""
-- ============================================================================
-- VERIFICAÇÃO PÓS-IMPORTAÇÃO
-- ============================================================================

-- Total de lentes importadas deste fornecedor
SELECT
    'Total importadas' as metrica,
    COUNT(*) as valor
FROM lens_catalog.lentes
WHERE fornecedor_id = '{fornecedor_id}'
UNION ALL
SELECT
    'Com grupo canônico',
    COUNT(*)
FROM lens_catalog.lentes
WHERE fornecedor_id = '{fornecedor_id}'
  AND grupo_canonico_id IS NOT NULL
UNION ALL
SELECT
    'Sem grupo (órfãs)',
    COUNT(*)
FROM lens_catalog.lentes
WHERE fornecedor_id = '{fornecedor_id}'
  AND grupo_canonico_id IS NULL;

-- Distribuição por tipo
SELECT tipo_lente, COUNT(*) as total
FROM lens_catalog.lentes
WHERE fornecedor_id = '{fornecedor_id}'
GROUP BY tipo_lente
ORDER BY total DESC;

-- Verificar preços calculados
SELECT
    nome_lente,
    preco_custo,
    preco_venda_sugerido,
    ROUND((preco_venda_sugerido / NULLIF(preco_custo, 0) - 1) * 100, 1) as markup_percent
FROM lens_catalog.lentes
WHERE fornecedor_id = '{fornecedor_id}'
LIMIT 5;

-- Verificar canonização
SELECT
    gc.nome_grupo,
    COUNT(l.id) as lentes_neste_grupo
FROM lens_catalog.lentes l
JOIN lens_catalog.grupos_canonicos gc ON gc.id = l.grupo_canonico_id
WHERE l.fornecedor_id = '{fornecedor_id}'
GROUP BY gc.nome_grupo
ORDER BY lentes_neste_grupo DESC
LIMIT 10;

-- ============================================================================
-- FIM
-- ============================================================================
""")

    return total, errors


def main():
    parser = argparse.ArgumentParser(
        description='Converte CSV de lentes para SQL INSERT (SIS Lens)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplo:
  python csv_to_sql_lentes.py lentes.csv output.sql \\
    --fornecedor-id e1e1eace-11b4-4f26-9f15-620808a4a410 \\
    --marca-id 4af04ba6-e600-4874-b8dc-45a2e1773725

IDs dos fornecedores existentes (com lentes):
  So Blocos:   e1e1eace-11b4-4f26-9f15-620808a4a410 (1097 lentes)
  Polylux:     3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21 (158 lentes)
  Express:     8eb9498c-3d99-4d26-bb8c-e503f97ccf2c (84 lentes)
  Brascor:     15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1 (58 lentes)
  Braslentes:  43721f5b-4f4a-4a75-bb34-6e8b373c5948 (36 lentes)
  Sygma:       199bae08-0217-4b70-b054-d3f0960b4a78 (14 lentes)

IDs das marcas existentes:
  PREMIUM (is_premium=true):
    ESSILOR:     bbe5a62d-1d7d-4d93-87af-0dbde68c0645
    VARILUX:     3f70213e-0b45-4f42-907a-28f7e7ac51c0
    TRANSITIONS: 3f8ac428-2224-415e-8a20-c9e6879754d3
    ZEISS:       a8ee9f1e-53d9-41ed-bc68-9c4a9881e828
    HOYA:        852e5fb8-8eae-4805-a5cb-a5a1e8638f5c
    CRIZAL:      befba165-0aa0-496f-bfdf-774bfe94a856

  STANDARD (is_premium=false):
    SO BLOCOS:   4af04ba6-e600-4874-b8dc-45a2e1773725
    POLYLUX:     e7ef4c94-a80a-492f-9195-24e6ab2f5056
    BRASCOR:     98deae91-ee66-4c32-8a5d-8a6f83681993
    EXPRESS:     7bf35e08-7a88-4547-a06a-a6ce62fcc827
    SYGMA:       57fc0111-0a99-4642-8b66-f1d87a79afce
    BRASLENTES:  d53785a4-37a2-48d1-b807-d172a31417ff
    GENÉRICA:    7f1aa237-edaf-4376-8b91-6c93c3c079a4
"""
    )

    parser.add_argument('input', help='Arquivo CSV de entrada')
    parser.add_argument('output', help='Arquivo SQL de saída')
    parser.add_argument('--fornecedor-id', required=True,
                        help='UUID do fornecedor/laboratório')
    parser.add_argument('--marca-id', default=None,
                        help='UUID da marca (opcional, pode ser NULL)')
    parser.add_argument('--batch-size', type=int, default=50,
                        help='Tamanho do batch para INSERT (default: 50)')
    parser.add_argument('--validate-only', action='store_true',
                        help='Apenas validar, não gerar SQL')

    args = parser.parse_args()

    # Verificar arquivo de entrada
    if not Path(args.input).exists():
        print(f"❌ Erro: Arquivo '{args.input}' não encontrado")
        sys.exit(1)

    print(f"📖 Lendo arquivo: {args.input}")
    print(f"🏭 Fornecedor ID: {args.fornecedor_id}")
    print(f"🏷️ Marca ID: {args.marca_id or 'NULL'}")
    print()

    if args.validate_only:
        # Apenas validar
        with open(args.input, 'r', encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            errors = []
            total = 0
            for i, row in enumerate(reader, start=2):
                row_errors = validate_row(row, i)
                errors.extend(row_errors)
                total += 1

        print(f"📊 Total de linhas: {total}")
        if errors:
            print(f"❌ {len(errors)} erros encontrados:")
            for e in errors[:20]:
                print(f"   - {e}")
            if len(errors) > 20:
                print(f"   ... e mais {len(errors) - 20} erros")
            sys.exit(1)
        else:
            print("✅ Nenhum erro encontrado!")
    else:
        # Converter
        total, errors = convert_csv_to_sql(
            args.input, args.output,
            args.fornecedor_id, args.marca_id,
            args.batch_size
        )

        print(f"📊 Total de lentes processadas: {total}")

        if errors:
            print(f"⚠️ {len(errors)} linhas com erro foram ignoradas:")
            for e in errors[:10]:
                print(f"   - {e}")
            if len(errors) > 10:
                print(f"   ... e mais {len(errors) - 10} erros")

        print(f"✅ Arquivo SQL gerado: {args.output}")
        print()
        print("Próximos passos:")
        print(f"  1. Revise o arquivo {args.output}")
        print(f"  2. Execute no banco: psql -f {args.output}")
        print(f"  3. O preço de venda será calculado automaticamente")
        print(f"  4. O grupo canônico será atribuído automaticamente")


if __name__ == '__main__':
    main()
