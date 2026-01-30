import pandas as pd
import uuid
import os

def normalizar_style_completo():
    folder = r'D:\projetos\sis_lens\povoar_banco\csv'
    output_path = r'D:\projetos\sis_lens\povoar_banco\csv\banco\style_final.csv'
    
    fornecedor_id = 'd88018ac-ecae-4b38-b321-94babe5f85e3' # Style
    id_marca_style = '731a86d5-2d61-42ca-9533-1af470184bad'
    
    # Mapeamento de Marcas Premium REAIS (IDs vindos do banco)
    marcas_premium = {
        'VARILUX': '3f70213e-0b45-4f42-907a-28f7e7ac51c0',
        'HOYA': '852e5fb8-8eae-4805-a5cb-a5a1e8638f5c',
        'KODAK': 'a6091278-c827-40ea-a2fb-dcc26f1c8d20',
        'ESSILOR': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645',
        'CRIZAL': 'befba165-0aa0-496f-bfdf-774bfe94a856',
        'ESPACE': '731a86d5-2d61-42ca-9533-1af470184bad' # Marcando como Style se não houver ID específico para Espace
    }

    def get_marca_id(nome_lente, linha):
        nome_upper = nome_lente.upper()
        linha_upper = str(linha).upper()
        for marca, id_m in marcas_premium.items():
            if marca in nome_upper or marca in linha_upper:
                return id_m
        return id_marca_style

    def transform_row(row, tipo_lente_auto):
        nome = str(row['nome_completo_lente'])
        linha = str(row.get('linha', ''))
        material_raw = str(row['material']).upper()
        
        # Mapeamento de Material
        if 'POLI' in material_raw:
            material = 'POLICARBONATO'
        elif any(x in material_raw for x in ['1.67', '1.74', '1.61']):
            material = 'HIGH_INDEX'
        else:
            material = 'CR39'
            
        foto_raw = str(row.get('foto', 'NAO')).upper()
        marca_foto = str(row.get('marca_foto', '')).upper()
        
        if 'TRANSITIONS' in marca_foto or 'TRANSITIONS' in nome.upper():
            foto = 'transitions'
        elif foto_raw == 'SIM' or 'FOTO' in nome.upper():
            foto = 'fotocromático'
        else:
            foto = 'nenhum'
            
        has_blue_base = str(row.get('blue_uv', 'NAO')).upper() == 'SIM' or 'BLUE' in nome.upper()
        
        # Colunas de tratamento variam na aba 'marcas'
        precos_map = {
            'Incolor': {'ar': False, 'blue': False, 'hidro': False},
            'AR_SClean': {'ar': True, 'blue': False, 'hidro': False},
            'SClean_Hidro': {'ar': True, 'blue': False, 'hidro': True},
            'AR_BlueHidro': {'ar': True, 'blue': True, 'hidro': True},
            'GEN8': {'ar': False, 'blue': False, 'hidro': False, 'foto': 'transitions'},
            'Easy': {'ar': True, 'blue': False, 'hidro': False, 'suffix': 'Crizal Easy'},
            'Rock': {'ar': True, 'blue': False, 'hidro': True, 'suffix': 'Crizal Rock'},
            'Sapphire': {'ar': True, 'blue': False, 'hidro': True, 'suffix': 'Crizal Sapphire'},
            'Crizal_Easy': {'ar': True, 'blue': False, 'hidro': False, 'suffix': 'Crizal Easy'}
        }
        
        lentes_geradas = []
        
        for col_preco, traits in precos_map.items():
            if col_preco in row and pd.notnull(row[col_preco]) and str(row[col_preco]).strip() != '' and float(row[col_preco]) > 0:
                current_ar = traits.get('ar', False)
                current_blue = has_blue_base or traits.get('blue', False)
                current_foto = traits.get('foto', foto)
                suffix = traits.get('suffix', f"({col_preco})")
                
                # Mapeamento de Índices
                try:
                    idx_val = float(row['indice'])
                    if idx_val < 1.53: 
                        indice = "1.50"
                    elif abs(idx_val - 1.56) < 0.01:
                        indice = "1.56"
                    elif abs(idx_val - 1.59) < 0.01:
                        indice = "1.59"
                    elif 1.60 <= idx_val <= 1.62:
                        indice = "1.61"
                    elif abs(idx_val - 1.67) < 0.01:
                        indice = "1.67"
                    elif idx_val >= 1.70:
                        indice = "1.74"
                    else:
                        indice = "{:.2f}".format(idx_val)
                except:
                    indice = "1.50"

                has_uv = material == 'POLICARBONATO' or material == 'HIGH_INDEX' or float(indice) >= 1.6 or current_blue
                
                def calcular_preco_venda(custo):
                    if custo <= 0: return 0.0
                    venda = max(custo * 3.0, 250.0 + (custo * 0.1))
                    if venda > custo * 4.0:
                        if custo > 100: venda = custo * 4.0
                    return round(venda, 2)

                lentes_geradas.append({
                    'id': str(uuid.uuid4()),
                    'fornecedor_id': fornecedor_id,
                    'marca_id': get_marca_id(nome, linha),
                    'nome_lente': f"{nome} {suffix}",
                    'nome_comercial': f"{nome} {suffix}",
                    'tipo_lente': tipo_lente_auto,
                    'material': material,
                    'indice_refracao': indice,
                    'categoria': 'premium' if get_marca_id(nome, linha) != id_marca_style else 'economica',
                    'tratamento_antirreflexo': current_ar,
                    'tratamento_antirrisco': True if current_ar or material == 'POLICARBONATO' else False,
                    'tratamento_uv': has_uv,
                    'tratamento_blue_light': current_blue,
                    'tratamento_fotossensiveis': current_foto,
                    'fotossensivel': current_foto,
                    'ar': current_ar,
                    'blue': current_blue,
                    'uv400': has_uv,
                    'antirrisco': True if current_ar or material == 'POLICARBONATO' else False,
                    'polarizado': 'POLARIZADO' in nome.upper(),
                    'esferico_min': row.get('esf_min', 0.0) if pd.notnull(row.get('esf_min')) and str(row.get('esf_min')).strip() != '' else 0.0,
                    'esferico_max': row.get('esf_max', 0.0) if pd.notnull(row.get('esf_max')) and str(row.get('esf_max')).strip() != '' else 0.0,
                    'cilindrico_min': row.get('cil_min', 0.0) if pd.notnull(row.get('cil_min')) and str(row.get('cil_min')).strip() != '' else 0.0,
                    'cilindrico_max': row.get('cil_max', 0.0) if pd.notnull(row.get('cil_max')) and str(row.get('cil_max')).strip() != '' else 0.0,
                    'grau_esferico_min': row.get('esf_min', 0.0) if pd.notnull(row.get('esf_min')) and str(row.get('esf_min')).strip() != '' else 0.0,
                    'grau_esferico_max': row.get('esf_max', 0.0) if pd.notnull(row.get('esf_max')) and str(row.get('esf_max')).strip() != '' else 0.0,
                    'grau_cilindrico_min': row.get('cil_min', 0.0) if pd.notnull(row.get('cil_min')) and str(row.get('cil_min')).strip() != '' else 0.0,
                    'grau_cilindrico_max': row.get('cil_max', 0.0) if pd.notnull(row.get('cil_max')) and str(row.get('cil_max')).strip() != '' else 0.0,
                    'adicao_min': row.get('add_min', 0.0) if pd.notnull(row.get('add_min')) and str(row.get('add_min')).strip() != '' and float(row.get('add_min')) != 0 else (1.0 if tipo_lente_auto == 'multifocal' else 0.0),
                    'adicao_max': row.get('add_max', 0.0) if pd.notnull(row.get('add_max')) and str(row.get('add_max')).strip() != '' and float(row.get('add_max')) != 0 else (3.0 if tipo_lente_auto == 'multifocal' else 0.0),
                    'preco_custo': float(row[col_preco]),
                    'custo_base': float(row[col_preco]),
                    'preco_tabela': calcular_preco_venda(float(row[col_preco])),
                    'status': 'ativo',
                    'ativo': True,
                    'disponivel': True,
                    'prazo_entrega': 10 # Padrão para marcas premium
                })
        return lentes_geradas

    all_lentes = []
    
    # Lista de arquivos incluindo a aba marcas
    files_to_process = [
        ('style_vs_surf_raw.csv', 'visao_simples'),
        ('style_multi_raw.csv', 'multifocal'),
        ('style_bifocal_raw.csv', 'bifocal'),
        ('style_marcas_raw.csv', 'inferred') # Tipo será inferido por linha
    ]
    
    for filename, tipo_base in files_to_process:
        path = os.path.join(folder, filename)
        if os.path.exists(path):
            df = pd.read_csv(path)
            
            for _, row in df.iterrows():
                # Pular linhas de cabeçalho repetidas ou vazias
                nome_lente = str(row.get('nome_completo_lente', ''))
                if nome_lente.strip() == '' or 'nome_completo_lente' in nome_lente or 'codigo_item' in str(row.get('codigo_item', '')):
                    continue
                
                tipo = tipo_base
                if tipo == 'inferred':
                    tipo = 'multifocal' if pd.notnull(row.get('add_min')) and str(row.get('add_min')).strip() != '' else 'visao_simples'
                
                # Conversão segura de preços para a função transform_row
                # transform_row já lida com a lógica de explosão por coluna
                res = transform_row(row, tipo)
                all_lentes.extend(res)
    
    df_final = pd.DataFrame(all_lentes)
    if 'indice_refracao' in df_final.columns:
        df_final['indice_refracao'] = df_final['indice_refracao'].astype(str)

    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização STYLE (com Marcas Premium) concluída: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_style_completo()
