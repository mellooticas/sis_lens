import csv
from pathlib import Path

def escape_sql(value):
    if value is None:
        return 'NULL'
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, (int, float)):
        return str(value)
    
    # Escape quotes
    return "'" + str(value).replace("'", "''") + "'"

def main():
    root_dir = Path(r'D:\projetos\sis_lens\povoar_banco\csv\banco')
    marcas_file = root_dir / 'marcas_contato_final.csv'
    lentes_file = root_dir / 'lentes_contato_final.csv'
    output_file = root_dir / 'IMPORTAR_CONTATO_ATUALIZADO.sql'

    with open(output_file, 'w', encoding='utf-8') as sql:
        sql.write("-- SCRIPT GERADO AUTOMATICAMENTE\n")
        sql.write("BEGIN;\n\n")

        # 1. Garantir Fornecedor Solótica (e outros se necessario)
        sql.write("-- 1. FORNECEDORES\n")
        sql.write("-- Solótica (Loja Oficial)\n")
        solotica_id = '189e3428-1b20-4246-86d3-25501e51147a'
        sql.write(f"""
INSERT INTO core.fornecedores (id, nome, razao_social, ativo)
VALUES ('{solotica_id}', 'Solótica Oficial', 'Solótica Indústria e Comércio Ltda', true)
ON CONFLICT (id) DO NOTHING;
\n""")

        # 2. Importar Marcas
        sql.write("-- 2. MARCAS\n")
        if marcas_file.exists():
            with open(marcas_file, 'r', encoding='utf-8-sig') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    # id,nome,slug,fabricante,fabricante_id,is_premium,ativo
                    # Note: fabricante_id can be empty string in CSV, handle it
                    fab_id = row['fabricante_id'] if row['fabricante_id'] else None
                    if fab_id:
                        fab_id_sql = f"'{fab_id}'"
                    else:
                        fab_id_sql = 'NULL'
                        
                    sql.write(f"""INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) 
VALUES ('{row['id']}', {escape_sql(row['nome'])}, {escape_sql(row['slug'])}, {escape_sql(row['fabricante'])}, {row['is_premium']}, {row['ativo']}) 
ON CONFLICT (id) DO UPDATE SET 
    nome = EXCLUDED.nome, slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, 
    is_premium = EXCLUDED.is_premium, ativo = EXCLUDED.ativo;\n""")

        # 3. Importar Lentes
        sql.write("\n-- 3. LENTES\n")
        if lentes_file.exists():
            with open(lentes_file, 'r', encoding='utf-8-sig') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    # id,fornecedor_id,marca_id,nome_produto,slug,sku,codigo_fornecedor,tipo_lente,material,finalidade,preco_custo,preco_tabela,dias_uso,unidades_por_caixa,descricao_curta,disponivel,ativo,metadata
                    
                    # Convert types
                    dias_uso = row['dias_uso'] if row['dias_uso'] else 'NULL'
                    unidades = row['unidades_por_caixa'] if row['unidades_por_caixa'] else 'NULL'
                    preco_c = row['preco_custo'] if row['preco_custo'] else '0.0'
                    preco_t = row['preco_tabela'] if row['preco_tabela'] else '0.0'
                    descr = escape_sql(row['descricao_curta']) if row['descricao_curta'] else 'NULL'
                    
                    # Metadata json needs gentle handling if it has quotes, but escape_sql handles single quotes.
                    # Metadata in CSV is likely double-quoted.
                    # In python CSV reader, we get the string.
                    meta = row['metadata']
                    
                    fornecedor_val = f"'{row['fornecedor_id']}'" if row['fornecedor_id'] else "NULL"
                    marca_val = f"'{row['marca_id']}'" if row['marca_id'] else "NULL"

                    sql.write(f"""INSERT INTO contact_lens.lentes 
(fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) 
VALUES ({fornecedor_val}, {marca_val}, {escape_sql(row['nome_produto'])}, {escape_sql(row['slug'])}, {escape_sql(row['sku'])}, {escape_sql(row['codigo_fornecedor'])}, {escape_sql(row['tipo_lente'])}, {escape_sql(row['material'])}, {escape_sql(row['finalidade'])}, {preco_c}, {preco_t}, {dias_uso}, {unidades}, {descr}, {row['disponivel']}, {row['ativo']}, {escape_sql(meta)}) 
ON CONFLICT (slug) DO UPDATE SET 
    nome_produto = EXCLUDED.nome_produto, sku = EXCLUDED.sku, 
    codigo_fornecedor = EXCLUDED.codigo_fornecedor, tipo_lente = EXCLUDED.tipo_lente, 
    material = EXCLUDED.material, finalidade = EXCLUDED.finalidade, 
    preco_custo = EXCLUDED.preco_custo, preco_tabela = EXCLUDED.preco_tabela, 
    dias_uso = EXCLUDED.dias_uso, unidades_por_caixa = EXCLUDED.unidades_por_caixa, 
    descricao_curta = EXCLUDED.descricao_curta, disponivel = EXCLUDED.disponivel, 
    ativo = EXCLUDED.ativo, metadata = EXCLUDED.metadata;\n""")

        sql.write("\nCOMMIT;\n")

    print(f"Script SQL gerado em: {output_file}")

if __name__ == "__main__":
    main()
