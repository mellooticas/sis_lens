import csv
import json
import uuid
from pathlib import Path

def escape_sql(val):
    if val is None or val == '' or str(val).lower() == 'nan' or str(val).lower() == 'null': return "NULL"
    if isinstance(val, bool): return "true" if val else "false"
    # Se for uma string que representa booleano do CSV
    if str(val).lower() == 'true': return "true"
    if str(val).lower() == 'false': return "false"
    
    # Se for número, retornar sem aspas
    try:
        if isinstance(val, (int, float)): return str(val)
        # Tenta converter string para número se parecer um
        float(val)
        return str(val)
    except:
        pass
        
    return "'" + str(val).replace("'", "''") + "'"

def main():
    root_dir = Path(r'D:\projetos\sis_lens\povoar_banco\csv\banco')
    output_sql = root_dir / 'IMPORTAR_CONTATO_COMPLETO.sql'
    
    marcas_csv = root_dir / 'marcas_contato_final.csv'
    lentes_csv = root_dir / 'lentes_contato_final.csv'
    
    print(f"Gerando SQL a partir de:\n- {marcas_csv.name}\n- {lentes_csv.name}")
    
    with open(output_sql, 'w', encoding='utf-8') as f:
        f.write("-- ============================================================================\n")
        f.write("-- SCRIPT DE IMPORTAÇÃO: APENAS LENTES DE CONTATO (Lentenet + NewLentes)\n")
        f.write("-- ============================================================================\n\n")
        
        f.write("BEGIN;\n\n")
        
        # 1. MARCAS
        f.write("-- 1. IMPORTAR/ATUALIZAR MARCAS\n")
        if marcas_csv.exists():
            with open(marcas_csv, 'r', encoding='utf-8-sig') as m_file:
                reader = csv.DictReader(m_file)
                for row in reader:
                    f.write(f"INSERT INTO contact_lens.marcas (id, nome, slug, fabricante, is_premium, ativo) \n")
                    f.write(f"VALUES ({escape_sql(row['id'])}, {escape_sql(row['nome'])}, {escape_sql(row['slug'])}, {escape_sql(row['fabricante'])}, {escape_sql(row['is_premium'])}, {escape_sql(row['ativo'])}) \n")
                    f.write(f"ON CONFLICT (nome) DO UPDATE SET slug = EXCLUDED.slug, fabricante = EXCLUDED.fabricante, is_premium = EXCLUDED.is_premium;\n\n")
        
        # 2. LENTES
        f.write("-- 2. IMPORTAR LENTES DE CONTATO\n")
        if lentes_csv.exists():
            with open(lentes_csv, 'r', encoding='utf-8-sig') as l_file:
                reader = csv.DictReader(l_file)
                for row in reader:
                    f.write(f"INSERT INTO contact_lens.lentes (fornecedor_id, marca_id, nome_produto, slug, sku, codigo_fornecedor, tipo_lente, material, finalidade, preco_custo, preco_tabela, dias_uso, unidades_por_caixa, descricao_curta, disponivel, ativo, metadata) \n")
                    f.write(f"VALUES ({escape_sql(row['fornecedor_id'])}, {escape_sql(row['marca_id'])}, {escape_sql(row['nome_produto'])}, {escape_sql(row['slug'])}, {escape_sql(row['sku'])}, {escape_sql(row['codigo_fornecedor'])}, {escape_sql(row['tipo_lente'])}, {escape_sql(row['material'])}, {escape_sql(row['finalidade'])}, {row['preco_custo']}, {row['preco_tabela']}, {row['dias_uso']}, {row['unidades_por_caixa']}, {escape_sql(row['descricao_curta'])}, {escape_sql(row['disponivel'])}, {escape_sql(row['ativo'])}, {escape_sql(row['metadata'])})\n")
                    f.write(f"ON CONFLICT (slug) DO UPDATE SET \n")
                    f.write(f"    fornecedor_id = EXCLUDED.fornecedor_id, \n")
                    f.write(f"    preco_custo = EXCLUDED.preco_custo, \n")
                    f.write(f"    preco_tabela = EXCLUDED.preco_tabela, \n")
                    f.write(f"    unidades_por_caixa = EXCLUDED.unidades_por_caixa, \n")
                    f.write(f"    metadata = contact_lens.lentes.metadata || EXCLUDED.metadata;\n\n")

        f.write("\nCOMMIT;\n")
    
    print(f"\nSucesso! SQL consolidado gerado em: {output_sql}")
        
    print(f"SQL Consolidado gerado: {output_sql}")

if __name__ == "__main__":
    main()
