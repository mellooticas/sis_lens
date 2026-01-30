import pandas as pd
import uuid
import os
import re

def normalizar_brascor():
    folder = r'D:\projetos\sis_lens\povoar_banco\csv'
    input_path = os.path.join(folder, 'brascor.xlsx')
    output_path = os.path.join(folder, 'banco', 'brascor_final.csv')
    
    fornecedor_id = '15db4d9c-8c60-4b4d-8b8d-7cc9a5fd97e1' # Brascor
    id_marca_brascor = '98deae91-ee66-4c32-8a5d-8a6f83681993'
    
    # Marcas Premium
    marcas_premium = {
        'ESSILOR': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645',
        'VARILUX': '3f70213e-0b45-4f42-907a-28f7e7ac51c0',
        'CRIZAL': 'befba165-0aa0-496f-bfdf-774bfe94a856',
        'KODAK': 'a6091278-c827-40ea-a2fb-dcc26f1c8d20',
        'HOYA': '852e5fb8-8eae-4805-a5cb-a5a1e8638f5c',
        'EYEZEN': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645', # Essilor
        'ESPACE': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645', # Essilor
        'STYLIS': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645', # Essilor
        'AIRWEAR': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645', # Essilor
        'ORMA': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645' # Essilor
    }

    def get_marca_id(nome_lente):
        text = str(nome_lente).upper()
        for marca, m_id in marcas_premium.items():
            if marca in text:
                return m_id
        return id_marca_brascor

    def parse_tratamentos_brascor(col_name, nome_lente=''):
        c = str(col_name).upper()
        n = str(nome_lente).upper()
        res = {
            'ar': False,
            'blue': False,
            'uv400': False,
            'fotossensivel': 'nenhum',
            'antirrisco': False,
            'suffix': f" ({col_name})"
        }
        
        # Detecção por Coluna ou Nome da Lente
        if any(x in c or x in n for x in ['AWAY', 'CLARUS', 'CLEAN', 'CRIZAL', 'OPTIFOG', 'TRIO', 'AR ']):
            res['ar'] = True
            res['antirrisco'] = True
            
        if any(x in c or x in n for x in ['BLUE', 'PREVENCIA', 'SAPPHIRE']):
            res['blue'] = True
            res['uv400'] = True
            
        if any(x in c or x in n for x in ['PHOTO', 'TRANSITIONS', 'GEN 8', 'GEN S', 'ACC']):
            res['fotossensivel'] = 'transitions' if any(x in c or x in n for x in ['TRANSITIONS', 'GEN']) else 'fotocromático'
            
        return res

    def get_material_e_indice(material_raw, indice_raw, nome_lente=''):
        idx_s = str(indice_raw).replace(',', '.')
        nome = str(nome_lente).upper()
        
        try:
            val = float(idx_s)
            if val < 1.53: indice = "1.50"
            elif abs(val - 1.56) < 0.02: indice = "1.56"
            elif abs(val - 1.59) < 0.02: indice = "1.59"
            elif 1.60 <= val <= 1.62: indice = "1.61"
            elif abs(val - 1.67) < 0.02: indice = "1.67"
            elif val >= 1.70: indice = "1.74"
            else: indice = "1.50"
        except:
            indice = "1.50"
            val = 1.50

        if '1.59' in nome or 'POLI' in nome or indice == '1.59' or 'AIRWEAR' in nome:
            material = 'POLICARBONATO'
        elif 'TRIVEX' in nome or val == 1.53:
            material = 'TRIVEX'
        elif float(indice) >= 1.6:
            material = 'HIGH_INDEX'
        else:
            material = 'CR39'
            
        return material, indice

    all_lentes = []
    xl = pd.ExcelFile(input_path)
    
    def safe_float_brascor(val, default=0.0):
        try:
            if pd.isnull(val): return default
            s_val = str(val).strip().replace(',', '.').replace('—', '0').replace('+', '')
            if s_val == '' or s_val.isalpha(): return default
            return float(s_val)
        except:
            return default
    
    # Abas que usam colunas de tratamento como preço
    pivot_sheets = {
        'multi_dig': ['AWAY', 'CLARUS', 'BLUE PROT', 'CLEAN', 'WHITE', 'INCOLOR'],
        'bifocais': ['away', 'clarus', 'blue_prot', 'clean', 'white', 'incolor'],
        'vs_surf': ['away', 'clarus', 'blue_prot', 'clean', 'white', 'incolor'],
        'multi_essilor': ['Crizal_Prevencia', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog'],
        'multi_essilor_color': ['Crizal_Sapphire_HR', 'Optifog', 'Verniz_HC'],
        'vs_essilor': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'Trio_Easy_Clean', 'Verniz_HC'],
        'vs_kids': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'Trio_Easy_Clean', 'Verniz_HC'],
        'vs_surfacada_essilor': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'No_Reflexo', 'Trio_Easy_Clean', 'Sem_AR'],
        'vs_essilor_solares': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'Trio_Easy_Clean', 'Verniz_HC'],
        'vs_essilor_coloracao': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'Trio_Easy_Clean', 'Verniz_HC'],
        'multi_kodak': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'No_Reflex', 'Trio_Easy_Clean', 'Verniz_HC'],
        'ocupacional_kodak': ['861.00', '861.00.1', '694.00', '478.00', '647.00', '388.00', '386.00', '239.00'], # Kodak Softwear has weird headers
        'vs_kodak': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'No_Reflex', 'Trio_Easy_Clean', 'Verniz_HC'],
        'vs_kodak_polarizada': ['Crizal_Sapphire_HR', 'Optifog', 'Verniz_HC'],
        'vs_kodak_coloridas': ['Verniz_HC'],
        'multi_kodak_polarizada': ['Crizal_Sapphire_HR', 'Optifog', 'Verniz_HC'],
        'multi_kodak_colorida': ['Verniz_HC'],
        'multi_espace': ['Crizal_Prevenica', 'Crizal_Sapphire_HR', 'Crizal_Rock', 'Crizal_Easy_Pro', 'Optifog', 'Trio_Easy_Clean', 'Sem_AR'],
    }

    sheet_types = {
        'vs_surf': 'visao_simples',
        'vs_pronta': 'visao_simples',
        'vs_essilor': 'visao_simples',
        'vs_kids': 'visao_simples',
        'vs_essilor_pronta': 'visao_simples',
        'vs_surfacada_essilor': 'visao_simples',
        'vs_essilor_solares': 'visao_simples',
        'vs_essilor_coloracao': 'visao_simples',
        'vs_kodak': 'visao_simples',
        'vs_pront_kodak': 'visao_simples',
        'vs_kodak_polarizada': 'visao_simples',
        'vs_kodak_coloridas': 'visao_simples',
        'multi_dig': 'multifocal',
        'multi_essilor': 'multifocal',
        'multi_essilor_color': 'multifocal',
        'multi_kodak': 'multifocal',
        'multi_kodak_polarizada': 'multifocal',
        'multi_kodak_colorida': 'multifocal',
        'multi_espace': 'multifocal',
        'bifocais': 'bifocal',
        'ocupacional_kodak': 'ocupacional',
        'color': 'visao_simples',
        'promocoes_completas': 'visao_simples'
    }

    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        # Regra: Base 3x, Piso 250.00, Teto 4x.
        # Adicionamos uma pequena fração do custo ao piso para garantir que preços de custo diferentes 
        # gerem preços de venda diferentes, mesmo no piso.
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            # Se o piso de 250 for maior que 4x o custo (casos de custo < 62.50), 
            # priorizamos o piso de 250 conforme solicitado ("mínimo 250").
            # Mas se a lente for cara, não passamos de 4x.
            if custo > 100: 
                venda = custo * 4.0
        return round(venda, 2)

    for sheet in xl.sheet_names:
        df = pd.read_excel(input_path, sheet_name=sheet)
        tipo_base = sheet_types.get(sheet, 'visao_simples')
        
        # Especial: promocoes_completas
        if sheet == 'promocoes_completas':
            for _, row in df.iterrows():
                preco = safe_float_brascor(row.get('preco_promocional', 0))
                if preco <= 0: continue
                nome = str(row.get('nome_lente', 'Lente')).strip()
                mat, ind = get_material_e_indice('', row.get('indice', 1.5), nome)
                all_lentes.append({
                    'id': str(uuid.uuid4()), 'fornecedor_id': fornecedor_id, 'marca_id': get_marca_id(nome),
                    'nome_lente': nome, 'nome_comercial': nome, 'tipo_lente': tipo_base,
                    'material': mat, 'indice_refracao': ind, 'categoria': 'economica',
                    'tratamento_antirreflexo': False, 'tratamento_antirrisco': False,
                    'tratamento_uv': float(ind) >= 1.6, 'tratamento_blue_light': False,
                    'tratamento_fotossensiveis': 'nenhum',
                    'preco_custo': float(preco), 'custo_base': float(preco), 
                    'preco_tabela': calcular_preco_venda(float(preco)),
                    'status': 'ativo', 'ativo': True, 'disponivel': True, 'prazo_entrega': 7,
                    'esferico_min': safe_float_brascor(row.get('esf_min', 0)),
                    'esferico_max': safe_float_brascor(row.get('esf_max', 0)),
                    'cilindrico_min': safe_float_brascor(row.get('cil_max', 0)),
                    'cilindrico_max': 0.0,
                    'adicao_min': safe_float_brascor(row.get('adicao_min', 0)),
                    'adicao_max': safe_float_brascor(row.get('adicao_max', 0))
                })
            continue

        price_cols = pivot_sheets.get(sheet, [])
        
        for _, row in df.iterrows():
            nome_base = row.get('Nome completo da lente') or row.get('nome_completo_lente') or row.get('nome_produto') or row.get('nome_lente') or 'Lente Brascor'
            if pd.isnull(nome_base) or str(nome_base).strip() == '' or str(nome_base).lower() == 'nan':
                continue
            
            idx_v = row.get('Índice') or row.get('indice') or (1.50 if 'ORMA' in str(nome_base) else 1.50)
            material_v = row.get('Material') or row.get('material') or ''
            
            # Se a aba for pivoteada
            if price_cols:
                for col in price_cols:
                    if col not in df.columns: continue
                    preco = row.get(col)
                    try:
                        p_val = float(preco)
                        if p_val <= 0 or pd.isnull(p_val): continue
                    except:
                        continue
                    
                    traits = parse_tratamentos_brascor(col, nome_base)
                    mat, ind = get_material_e_indice(material_v, idx_v, nome_base)
                    
                    nome_final = f"{nome_base}{traits['suffix']}"
                    
                    # Adição Padrão para Multifocais (Evitar Adicao=0 que quebra canonização)
                    a_min = safe_float_brascor(row.get('Esf Min', row.get('esf_min')))
                    a_max = safe_float_brascor(row.get('Esf Max', row.get('esf_max')))
                    add_min = safe_float_brascor(row.get('Add Min', row.get('adicao_min')))
                    add_max = safe_float_brascor(row.get('Add Max', row.get('adicao_max')))
                    
                    if tipo_base == 'multifocal' and add_max == 0:
                        add_min, add_max = 1.0, 3.0

                    lente = {
                        'id': str(uuid.uuid4()),
                        'fornecedor_id': fornecedor_id,
                        'marca_id': get_marca_id(nome_final),
                        'nome_lente': nome_final,
                        'nome_comercial': str(nome_base),
                        'tipo_lente': tipo_base,
                        'material': mat,
                        'indice_refracao': ind,
                        'categoria': 'premium' if get_marca_id(nome_final) != id_marca_brascor else 'economica',
                        'tratamento_antirreflexo': traits['ar'],
                        'tratamento_antirrisco': traits['antirrisco'],
                        'tratamento_uv': traits['uv400'] or float(ind) >= 1.6,
                        'tratamento_blue_light': traits['blue'],
                        'tratamento_fotossensiveis': traits['fotossensivel'] if 'fotossensivel' in traits else 'nenhum',
                        'status': 'ativo', 'ativo': True, 'disponivel': True, 'prazo_entrega': 7,
                        'esferico_min': safe_float_brascor(row.get('Esf Min', row.get('esf_min'))),
                        'esferico_max': safe_float_brascor(row.get('Esf Max', row.get('esf_max'))),
                        'cilindrico_min': safe_float_brascor(row.get('Cil Max', row.get('cil_max'))),
                        'cilindrico_max': 0.0,
                        'adicao_min': add_min,
                        'adicao_max': add_max,
                        'preco_custo': p_val,
                        'custo_base': p_val,
                        'preco_tabela': calcular_preco_venda(p_val)
                    }
                    all_lentes.append(lente)
            else:
                # Aba não pivoteada (ex: vs_pronta)
                preco = row.get('valor') or row.get('preco_custo')
                try:
                    p_val = float(preco)
                    if p_val <= 0: continue
                except:
                    continue
                
                mat, ind = get_material_e_indice(material_v, idx_v, nome_base)
                traits = parse_tratamentos_brascor('', nome_base)
                
                lente = {
                    'id': str(uuid.uuid4()), 'fornecedor_id': fornecedor_id, 'marca_id': get_marca_id(nome_base),
                    'nome_lente': str(nome_base), 'nome_comercial': str(nome_base), 'tipo_lente': tipo_base,
                    'material': mat, 'indice_refracao': ind, 'categoria': 'economica',
                    'tratamento_antirreflexo': traits['ar'],
                    'tratamento_antirrisco': traits['antirrisco'],
                    'tratamento_uv': traits['uv400'] or float(ind) >= 1.6,
                    'tratamento_blue_light': traits['blue'],
                    'tratamento_fotossensiveis': traits['fotossensivel'],
                    'preco_custo': p_val, 'custo_base': p_val, 
                    'preco_tabela': calcular_preco_venda(p_val),
                    'status': 'ativo', 'ativo': True, 'disponivel': True, 'prazo_entrega': 7,
                    'esferico_min': safe_float_brascor(row.get('esf_min')),
                    'esferico_max': safe_float_brascor(row.get('esf_max')),
                    'cilindrico_min': safe_float_brascor(row.get('cil_max')),
                    'cilindrico_max': 0.0,
                    'adicao_min': safe_float_brascor(row.get('adicao_min')),
                    'adicao_max': safe_float_brascor(row.get('adicao_max'))
                }
                all_lentes.append(lente)

    df_final = pd.DataFrame(all_lentes)
    # Limpeza final de nomes e duplicatas
    df_final = df_final.drop_duplicates(subset=['nome_lente', 'indice_refracao', 'material', 'preco_custo'])
    
    if 'indice_refracao' in df_final.columns:
        df_final['indice_refracao'] = df_final['indice_refracao'].astype(str)
        
    # Garantir que booleanos não fiquem vazios (o banco odeia "" para boolean)
    bool_cols = ['tratamento_antirreflexo', 'tratamento_antirrisco', 'tratamento_uv', 
                 'tratamento_blue_light', 'ativo', 'disponivel']
    for col in bool_cols:
        if col in df_final.columns:
            df_final[col] = df_final[col].fillna(False).astype(bool)

    # Garantir que numéricos de grade não fiquem vazios (trigger de canonização falha com NULL)
    grade_cols = ['esferico_min', 'esferico_max', 'cilindrico_min', 'cilindrico_max', 'adicao_min', 'adicao_max']
    for col in grade_cols:
        if col in df_final.columns:
            df_final[col] = df_final[col].fillna(0.0).astype(float)

    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização BRASCOR concluída: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_brascor()
