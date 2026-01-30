import pandas as pd
import uuid
import os
import re

def normalizar_hoya():
    folder = r'D:\projetos\sis_lens\povoar_banco\csv'
    input_path = os.path.join(folder, 'hoya.xlsx')
    output_path = os.path.join(folder, 'banco', 'hoya_final.csv')
    
    # Hoya ID (Brand and Supplier)
    hoya_id = '852e5fb8-8eae-4805-a5cb-a5a1e8638f5c'
    
    def parse_grade_hoya(esf_str, cil_str):
        e_min, e_max, c_min, c_max = 0.0, 0.0, 0.0, 0.0
        
        def safe_range(s):
            if pd.isnull(s) or str(s).strip() == '' or str(s).lower() == 'nan':
                return 0.0, 0.0
            text = str(s).replace(',', '.').replace('à', ' a ')
            match = re.search(r'([+-]?\d+\.?\d*)\s*a\s*([+-]?\d+\.?\d*)', text)
            if match:
                return float(match.group(1)), float(match.group(2))
            # Se for "até -4.00"
            match_ate = re.search(r'até\s*([+-]?\d+\.?\d*)', text)
            if match_ate:
                val = float(match_ate.group(1))
                return (val, 0.0) if val < 0 else (0.0, val)
            return 0.0, 0.0

        e_min, e_max = safe_range(esf_str)
        c_min, c_max = safe_range(cil_str)
        
        return e_min, e_max, min(c_min, c_max), max(c_min, c_max)

    def parse_tratamentos_hoya(trat_str):
        t = str(trat_str).upper()
        res = {
            'ar': False,
            'blue': False,
            'uv400': False,
            'fotossensivel': 'nenhum',
            'antirrisco': False
        }
        
        if any(x in t for x in ['AR', 'LONGLIFE', 'CONTROL', 'SINCITY', 'VIEW', 'MIYOSMART']):
            res['ar'] = True
            res['antirrisco'] = True
            
        if 'BLUE' in t:
            res['blue'] = True
            res['uv400'] = True
            
        if 'FOTO' in t or 'TRANSITIONS' in t or 'SENSITY' in t:
            res['fotossensivel'] = 'transitions' if 'TRANSITIONS' in t else 'fotocromático'
            
        return res

    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            if custo > 100: venda = custo * 4.0
        return round(venda, 2)

    all_lentes = []
    xl = pd.ExcelFile(input_path)
    
    # Colunas de matriz: Nome da Coluna -> (Indice, Material)
    hoya_matrix = {
        'eyvia_1_74': ('1.74', 'HIGH_INDEX'),
        'eynoa_1_67': ('1.67', 'HIGH_INDEX'),
        'eyas_1_60': ('1.61', 'HIGH_INDEX'), # Mapeado 1.60 -> 1.61
        'pnx_1_53': ('1.50', 'TRIVEX'),       # Mapeado 1.53 -> 1.50 (closest enum)
        'organic_1_50': ('1.50', 'CR39')
    }

    for sheet in xl.sheet_names:
        df = pd.read_excel(input_path, sheet_name=sheet)
        
        for _, row in df.iterrows():
            linha = row.get('linha', 'Hoya')
            modelo = row.get('modelo', 'Lente')
            design = row.get('design', '')
            tipo_base = str(row.get('tipo_lente', 'visao_simples')).lower().replace(' ', '_')
            
            if 'multifocal' in tipo_base: tipo_base = 'multifocal'
            elif 'ocupacional' in tipo_base: tipo_base = 'ocupacional'
            elif 'visao_simples' in tipo_base: tipo_base = 'visao_simples'
            else: tipo_base = 'visao_simples'

            trat_nome = str(row.get('tratamento', '')).strip()
            traits = parse_tratamentos_hoya(trat_nome)
            
            e_min, e_max, c_min, c_max = parse_grade_hoya(row.get('esferico'), row.get('cilindrico'))
            
            add_min, add_max = 0.0, 0.0
            add_s = str(row.get('adicao', '')).lower()
            if ' a ' in add_s:
                parts = add_s.replace(',', '.').split(' a ')
                try:
                    add_min = float(re.findall(r'[+-]?\d+\.?\d*', parts[0])[0])
                    add_max = float(re.findall(r'[+-]?\d+\.?\d*', parts[-1])[0])
                except: pass
            
            # Validação: Adição nunca passa de 4.00 ou 5.00 na prática e é SEMPRE positiva.
            # Numeric(3,2) permite até 9.99. Vamos travar em 8.0 para evitar lixo de outras colunas.
            if abs(add_min) >= 8.0 or add_min < 0: add_min = 0.0
            if abs(add_max) >= 8.0 or add_max < 0: add_max = 0.0

            for col, (indice, material) in hoya_matrix.items():
                if col not in df.columns: continue
                
                preco = row.get(col)
                try:
                    p_val = float(preco)
                    if p_val <= 0 or pd.isnull(p_val): continue
                except:
                    continue
                
                nome_formatado = f"HOYA {linha} {modelo} {indice} {trat_nome}".strip()
                
                lente = {
                    'id': str(uuid.uuid4()),
                    'fornecedor_id': hoya_id,
                    'marca_id': hoya_id,
                    'nome_lente': nome_formatado,
                    'nome_comercial': f"{linha} {modelo}",
                    'tipo_lente': tipo_base,
                    'material': material,
                    'indice_refracao': indice,
                    'categoria': 'premium',
                    'tratamento_antirreflexo': traits['ar'],
                    'tratamento_antirrisco': traits['antirrisco'],
                    'tratamento_uv': traits['uv400'] or float(indice) >= 1.6,
                    'tratamento_blue_light': traits['blue'],
                    'tratamento_fotossensiveis': traits['fotossensivel'],
                    'ar': traits['ar'],
                    'blue': traits['blue'],
                    'uv400': traits['uv400'] or float(indice) >= 1.6,
                    'antirrisco': traits['antirrisco'],
                    'polarizado': 'POLARIZADO' in nome_formatado.upper(),
                    'esferico_min': e_min,
                    'esferico_max': e_max,
                    'cilindrico_min': c_min,
                    'cilindrico_max': c_max,
                    'adicao_min': add_min,
                    'adicao_max': add_max,
                    'preco_custo': p_val,
                    'custo_base': p_val,
                    'preco_tabela': calcular_preco_venda(p_val),
                    'status': 'ativo',
                    'ativo': True,
                    'disponivel': True,
                    'prazo_entrega': 10
                }
                all_lentes.append(lente)

    df_final = pd.DataFrame(all_lentes)
    if 'indice_refracao' in df_final.columns:
        df_final['indice_refracao'] = df_final['indice_refracao'].astype(str)
        
    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização HOYA concluída: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_hoya()
