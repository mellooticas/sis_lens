import pandas as pd
import uuid
import os

def normalizar_polylux():
    folder = r'D:\projetos\sis_lens\povoar_banco\csv'
    input_path = os.path.join(folder, 'polilux.xlsx')
    output_path = os.path.join(folder, 'banco', 'polylux_final.csv')
    
    fornecedor_id = '3a0a8ad3-4c55-44a2-b9fa-232a9f2fdc21' # Polylux
    id_marca_polylux = 'e7ef4c94-a80a-492f-9195-24e6ab2f5056'
    
    # Marcas Premium
    marcas_premium = {
        'ESSILOR': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645',
        'VARILUX': '3f70213e-0b45-4f42-907a-28f7e7ac51c0',
        'CRIZAL': 'befba165-0aa0-496f-bfdf-774bfe94a856',
        'KODAK': 'a6091278-c827-40ea-a2fb-dcc26f1c8d20',
        'HOYA': '852e5fb8-8eae-4805-a5cb-a5a1e8638f5c'
    }

    def get_marca_id(nome_lente, bloco=''):
        text = (str(nome_lente) + ' ' + str(bloco)).upper()
        for marca, m_id in marcas_premium.items():
            if marca in text:
                return m_id
        return id_marca_polylux

    def parse_tratamentos(tratamento_str):
        trat = str(tratamento_str).upper()
        res = {
            'ar': False,
            'blue': False,
            'uv400': False,
            'fotossensivel': 'nenhum',
            'antirrisco': False
        }
        
        if 'AR' in trat or 'ANTI-REFLEXO' in trat or 'ANTI REFLEXO' in trat:
            res['ar'] = True
            res['antirrisco'] = True
            
        if 'BLUE' in trat:
            res['blue'] = True
            res['uv400'] = True
            
        if 'FOTO' in trat or 'TRANSITIONS' in trat:
            res['fotossensivel'] = 'transitions' if 'TRANSITIONS' in trat else 'fotocromático'
            
        if 'INCOLOR' in trat or 'WHITE' in trat:
            # Mantém defaults
            pass
            
        return res

    def get_material(material_raw, indice):
        m = str(material_raw).upper()
        try:
            idx = float(indice)
        except:
            idx = 1.50

        if 'POLI' in m or idx == 1.59:
            return 'POLICARBONATO'
        if idx >= 1.6:
            return 'HIGH_INDEX'
        return 'CR39'

    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            if custo > 100: venda = custo * 4.0
        return round(venda, 2)

    all_lentes = []
    xl = pd.ExcelFile(input_path)
    
    # Mapeamento de abas para tipos base
    sheets_config = {
        'vs': 'visao_simples',
        'multi': 'multifocal',
        'vs_surf': 'visao_simples',
        'multi_surf': 'multifocal',
        'mulit_marcas': 'multifocal',
        'bifocais': 'bifocal'
    }

    for sheet, tipo_lente in sheets_config.items():
        if sheet not in xl.sheet_names:
            continue
            
        df = pd.read_excel(input_path, sheet_name=sheet)
        
        for _, row in df.iterrows():
            # Limpeza básica: pular linhas sem preço ou sem nome
            preco_raw = row.get('valor_custo')
            try:
                preco = float(preco_raw)
                if preco <= 0: continue
            except (ValueError, TypeError):
                continue
                
            # Identificar nome
            nome_raw = row.get('linha_comercial') or row.get('tipo_lente') or row.get('bloco') or 'Lente'
            if pd.isnull(nome_raw) or str(nome_raw).strip() == '' or str(nome_raw).lower() == 'nan':
                continue
            
            nome_base = str(nome_raw).strip()
            if nome_base.lower() == 'linha_comercial': continue # Header repetido

            if sheet == 'vs' and pd.isnull(row.get('linha_comercial')):
                 nome_base = f"Visão Simples"
            
            trat_raw = str(row.get('tratamento', 'Incolor'))
            if trat_raw.lower() == 'nan': trat_raw = 'Incolor'
            traits = parse_tratamentos(trat_raw)
            
            indice_raw = row.get('indice_refracao', 1.50)
            try:
                idx_val = float(indice_raw)
                if idx_val < 1.53: 
                    indice_f = "1.50"
                elif abs(idx_val - 1.56) < 0.01:
                    indice_f = "1.56"
                elif abs(idx_val - 1.59) < 0.01:
                    indice_f = "1.59"
                elif 1.60 <= idx_val <= 1.62:
                    indice_f = "1.61"
                elif abs(idx_val - 1.67) < 0.01:
                    indice_f = "1.67"
                elif idx_val >= 1.70:
                    indice_f = "1.74"
                else:
                    indice_f = "{:.2f}".format(idx_val)
            except:
                continue 
            
            indice_format = indice_f
                
            # Construir nome final sem duplicar o índice se ele já estiver no nome_base
            if indice_format in nome_base:
                nome_completo = f"{nome_base} {trat_raw}".strip()
            else:
                nome_completo = f"{nome_base} {indice_format} {trat_raw}".strip()
            
            material = get_material(row.get('material', 'CR39'), indice_format)
            
            # Ajuste de Categoria
            marca_id = get_marca_id(nome_completo, row.get('bloco', ''))
            categoria = 'premium' if marca_id != id_marca_polylux else 'economica'
            
            def safe_float(val, default=0.0):
                try:
                    v = float(val)
                    return v if pd.notnull(v) else default
                except:
                    return default

            lente = {
                'id': str(uuid.uuid4()),
                'fornecedor_id': fornecedor_id,
                'marca_id': marca_id,
                'nome_lente': nome_completo,
                'nome_comercial': nome_completo,
                'tipo_lente': tipo_lente,
                'material': material,
                'indice_refracao': indice_format,
                'categoria': categoria,
                'tratamento_antirreflexo': traits['ar'],
                'tratamento_antirrisco': traits['antirrisco'],
                'tratamento_uv': traits['uv400'] or float(indice_format) >= 1.6,
                'tratamento_blue_light': traits['blue'],
                'tratamento_fotossensiveis': traits['fotossensivel'],
                'fotossensivel': traits['fotossensivel'],
                'ar': traits['ar'],
                'blue': traits['blue'],
                'uv400': traits['uv400'] or float(indice_format) >= 1.6,
                'antirrisco': traits['antirrisco'],
                'polarizado': 'POLARIZADO' in nome_completo.upper(),
                'esferico_min': safe_float(row.get('esf_min')),
                'esferico_max': safe_float(row.get('esf_max')),
                'cilindrico_min': safe_float(row.get('cil_min')),
                'cilindrico_max': safe_float(row.get('cil_max')),
                'grau_esferico_min': safe_float(row.get('esf_min')),
                'grau_esferico_max': safe_float(row.get('esf_max')),
                'grau_cilindrico_min': safe_float(row.get('cil_min')),
                'grau_cilindrico_max': safe_float(row.get('cil_max')),
                'adicao_min': safe_float(row.get('add_min')) or (1.0 if tipo_lente == 'multifocal' else 0.0),
                'adicao_max': safe_float(row.get('add_max')) or (3.0 if tipo_lente == 'multifocal' else 0.0),
                'preco_custo': float(preco),
                'custo_base': float(preco),
                'preco_tabela': calcular_preco_venda(float(preco)),
                'status': 'ativo',
                'ativo': True,
                'disponivel': True,
                'prazo_entrega': 7
            }
            all_lentes.append(lente)

    df_final = pd.DataFrame(all_lentes)
    if 'indice_refracao' in df_final.columns:
        df_final['indice_refracao'] = df_final['indice_refracao'].astype(str)
        
    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização POLYLUX concluída: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_polylux()
