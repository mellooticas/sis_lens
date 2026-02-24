import pandas as pd
import os
import json
import re

def clean_num(val):
    if pd.isna(val) or val == '' or str(val).lower() == 'nan':
        return None
    try:
        if isinstance(val, str):
            val = val.replace(',', '.')
            # Extract number if it has prefix
            m = re.search(r'[\-\+]?\d+\.\d+|[\-\+]?\d+', val)
            if m:
                return float(m.group(0))
        return float(val)
    except:
        return None

def parse_grade(text):
    if pd.isna(text) or not isinstance(text, str):
        return {}
    
    text = text.replace(',', '.')
    res = {}
    
    # Esf. -6,00 a +6,00 or Esferico: -6.00 a +6.00
    m_sph = re.search(r'(?:Esf|sph)\.?[^0-9\-]*([\-\+]?\d+(?:\.\d+)?)\s*a\s*([\-\+]?\d+(?:\.\d+)?)', text, re.I)
    if m_sph:
        res['sph_min'] = float(m_sph.group(1))
        res['sph_max'] = float(m_sph.group(2))
        
    m_cyl = re.search(r'(?:Cil|cyl)\.?[^0-9\-]*([\-\+]?\d+(?:\.\d+)?)\s*a\s*([\-\+]?\d+(?:\.\d+)?)', text, re.I)
    if m_cyl:
        res['cyl_min'] = float(m_cyl.group(1))
        res['cyl_max'] = float(m_cyl.group(2))
        
    m_add = re.search(r'(?:Add|adi)\.?[^0-9\-]*([\-\+]?\d+(?:\.\d+)?)\s*a\s*([\-\+]?\d+(?:\.\d+)?)', text, re.I)
    if m_add:
        res['add_min'] = float(m_add.group(1))
        res['add_max'] = float(m_add.group(2))
        
    return res

folder = r"D:\OneDrive - Óticas Taty Mello\Grupo Mello\Tecnologia_da_Informação\CRM_ERP\banco_de_dados\lentes\tabelaslentes\Processado"
files = [f for f in os.listdir(folder) if f.endswith('.xlsx')]

all_ranges = set()
all_lenses = []

# Mapeamento Sugerido de Fornecedores e Marcas baseado nos nomes dos arquivos
# (Ajustar conforme o que já existe no banco se necessário)
file_to_brand = {
    'brascor.xlsx': 'Brascor',
    'bras_lentes_2026.xlsx': 'Braslentes',
    'high_vision.xlsx': 'High Vision',
    'hoya.xlsx': 'Hoya',
    'lentes_express.xlsx': 'Lentes Express',
    'polilux.xlsx': 'Polilux',
    'so_blocos.xlsx': 'So Blocos',
    'style.xlsx': 'Style',
    'sygma.xlsx': 'Sygma'
}

for file_name in files:
    file_path = os.path.join(folder, file_name)
    brand_name = file_to_brand.get(file_name, file_name.replace('.xlsx', '').title())
    
    try:
        # sheet_name=None lê TODAS as abas → retorna dict {nome_aba: DataFrame}
        all_sheets = pd.read_excel(file_path, sheet_name=None)
        print(f"  [{file_name}] Abas encontradas: {list(all_sheets.keys())}")

        for sheet_name, df in all_sheets.items():
            if df.empty:
                print(f"    -> Aba '{sheet_name}' vazia, ignorando.")
                continue

            cols = {str(c).lower(): c for c in df.columns}

            # Identificar colunas dinamicamente por aba
            c_sph_min = next((cols[c] for c in cols if 'esf' in c and ('min' in c or 'de' in c)), None)
            c_sph_max = next((cols[c] for c in cols if 'esf' in c and ('max' in c or 'ate' in c or 'até' in c)), None)
            c_cyl_min = next((cols[c] for c in cols if 'cil' in c and ('min' in c or 'de' in c)), None)
            c_cyl_max = next((cols[c] for c in cols if 'cil' in c and ('max' in c or 'ate' in c or 'até' in c)), None)
            c_add_min = next((cols[c] for c in cols if 'add' in c or 'adi' in c and ('min' in c or 'de' in c)), None)
            c_add_max = next((cols[c] for c in cols if 'add' in c or 'adi' in c and ('max' in c or 'ate' in c or 'até' in c)), None)
            c_grade = next((cols[c] for c in cols if 'grade' in c or 'perfil' in c), None)

            c_name = next((cols[c] for c in cols if 'nome' in c or 'descricao' in c or 'descrição' in c or 'produto' in c), None)
            c_cost = next((cols[c] for c in cols if 'custo' in c or 'valor' in c or 'preco' in c or 'preço' in c), None)
            c_material = next((cols[c] for c in cols if 'material' in c), None)
            c_index = next((cols[c] for c in cols if 'indice' in c or 'índice' in c), None)

            print(f"    -> Aba '{sheet_name}': {len(df)} linhas | nome={c_name}, custo={c_cost}, material={c_material}")

            for _, row in df.iterrows():
                lens = {
                    'brand': brand_name,
                    'name': str(row[c_name]) if c_name else 'Lente Indefinida',
                    'material': str(row[c_material]) if c_material else None,
                    'refractive_index': clean_num(row[c_index]) if c_index else None,
                    'cost': clean_num(row[c_cost]) if c_cost else 0,
                }

                # Extrair graus
                g = {}
                if c_grade:
                    g = parse_grade(row[c_grade])

                # Merge com colunas unitárias (preferência para colunas unitárias se existirem e não forem nulas)
                for k, col in [('sph_min', c_sph_min), ('sph_max', c_sph_max),
                                ('cyl_min', c_cyl_min), ('cyl_max', c_cyl_max),
                                ('add_min', c_add_min), ('add_max', c_add_max)]:
                    if col:
                        val = clean_num(row[col])
                        if val is not None:
                            g[k] = val

                lens.update(g)
                all_lenses.append(lens)

                # Adicionar ao set de ranges únicos (apenas se tiver algum valor)
                if any(k in g for k in ['sph_min', 'sph_max', 'cyl_min', 'cyl_max', 'add_min', 'add_max']):
                    range_tuple = (
                        g.get('sph_min'), g.get('sph_max'),
                        g.get('cyl_min'), g.get('cyl_max'),
                        g.get('add_min'), g.get('add_max')
                    )
                    all_ranges.add(range_tuple)

    except Exception as e:
        print(f"Erro processando {file_name}: {e}")

# Salvar resultados
with open("extracted_ranges.json", "w", encoding="utf-8") as f:
    json.dump(list(all_ranges), f, indent=2)

with open("extracted_lenses.json", "w", encoding="utf-8") as f:
    json.dump(all_lenses, f, indent=2, ensure_ascii=False)

print(f"Total de lentes extraídas: {len(all_lenses)}")
print(f"Total de ranges técnicos únicos: {len(all_ranges)}")
