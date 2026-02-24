import pandas as pd
import os
import json

folder = r"D:\OneDrive - Óticas Taty Mello\Grupo Mello\Tecnologia_da_Informação\CRM_ERP\banco_de_dados\lentes\tabelaslentes\Processado"
files = [f for f in os.listdir(folder) if f.endswith('.xlsx')]

mapping_report = {}

def identify_range_cols(df):
    cols = df.columns.tolist()
    found = {
        'sph_min': None, 'sph_max': None,
        'cyl_min': None, 'cyl_max': None,
        'add_min': None, 'add_max': None,
        'grade_text': None
    }
    
    for c in cols:
        cl = str(c).lower()
        if 'grade' in cl or 'perfil' in cl: found['grade_text'] = c
        elif ('esf' in cl or 'sph' in cl) and ('min' in cl or 'de' in cl): found['sph_min'] = c
        elif ('esf' in cl or 'sph' in cl) and ('max' in cl or 'até' in cl or 'ate' in cl): found['sph_max'] = c
        elif ('cil' in cl or 'cyl' in cl) and ('min' in cl or 'de' in cl): found['cyl_min'] = c
        elif ('cil' in cl or 'cyl' in cl) and ('max' in cl or 'até' in cl or 'ate' in cl): found['cyl_max'] = c
        elif ('add' in cl or 'adi' in cl) and ('min' in cl or 'de' in cl): found['add_min'] = c
        elif ('add' in cl or 'adi' in cl) and ('max' in cl or 'até' in cl or 'ate' in cl): found['add_max'] = c
        # Caso especial: colunas simples 'Cil', 'Esf'
        elif cl == 'esf' or cl == 'esf.': found['sph_min'] = c
        elif cl == 'cil' or cl == 'cil.': found['cyl_min'] = c
        
    return found

for file_name in files:
    file_path = os.path.join(folder, file_name)
    try:
        df = pd.read_excel(file_path, nrows=5)
        mapping_report[file_name] = {
            'columns': df.columns.tolist(),
            'range_mapping': identify_range_cols(df),
            'sample_data': df.head(2).to_dict(orient='records')
        }
    except Exception as e:
        mapping_report[file_name] = {'error': str(e)}

with open("range_mapping_report.json", "w", encoding="utf-8") as f:
    json.dump(mapping_report, f, indent=2, ensure_ascii=False)

print("Relatório de mapeamento de ranges gerado em range_mapping_report.json")
