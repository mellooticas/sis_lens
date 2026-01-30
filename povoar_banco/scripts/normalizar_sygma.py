import pandas as pd
import uuid
import os
import re

def normalizar_sygma():
    folder = r'D:\projetos\sis_lens\povoar_banco\csv'
    input_path = os.path.join(folder, 'sygma.xlsx')
    output_path = os.path.join(folder, 'banco', 'sygma_final.csv')
    
    fornecedor_id = '199bae08-0217-4b70-b054-d3f0960b4a78' # Sygma
    id_marca_sygma = '57fc0111-0a99-4642-8b66-f1d87a79afce'
    
    # Marcas Premium
    marcas_premium = {
        'ESSILOR': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645',
        'VARILUX': '3f70213e-0b45-4f42-907a-28f7e7ac51c0',
        'CRIZAL': 'befba165-0aa0-496f-bfdf-774bfe94a856',
        'KODAK': 'a6091278-c827-40ea-a2fb-dcc26f1c8d20',
        'HOYA': '852e5fb8-8eae-4805-a5cb-a5a1e8638f5c',
        'NO LINE': 'bbe5a62d-1d7d-4d93-87af-0dbde68c0645' # Mapeado para Essilor se for o caso
    }

    def get_marca_id(nome_lente):
        text = str(nome_lente).upper()
        for marca, m_id in marcas_premium.items():
            if marca in text:
                return m_id
        return id_marca_sygma

    def parse_grade(grade_str):
        if pd.isnull(grade_str) or str(grade_str).strip() == '':
            return 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        
        text = str(grade_str).replace(',', '.').replace('à', ' a ')
        
        e_min, e_max, c_min, c_max, a_min, a_max = 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        
        # 1. Extrair Adição primeiro se tiver prefixo
        add_match = re.search(r'Ad\.?\s*([+-]?\d+\.?\d*)\s*[aà]\s*([+-]?\d+\.?\d*)', text)
        if add_match:
            a_min = float(add_match.group(1))
            a_max = float(add_match.group(2))
            # Remover o trecho da adição para não confundir com esférico
            text = text.replace(add_match.group(0), " ")
        
        # 2. Extrair Cilíndrico se tiver prefixo
        cil_match = re.search(r'Cil\.?\s*([+-]?\d+\.?\d*)\s*[aà]\s*([+-]?\d+\.?\d*)', text)
        if cil_match:
            c_min = float(cil_match.group(1))
            c_max = float(cil_match.group(2))
            text = text.replace(cil_match.group(0), " ")
        else:
            cil_ate_match = re.search(r'Cil\.?\s*até\s*([+-]?\d+\.?\d*)', text)
            if cil_ate_match:
                val = float(cil_ate_match.group(1))
                c_min, c_max = (val, 0.0) if val < 0 else (0.0, val)
                text = text.replace(cil_ate_match.group(0), " ")

        # 3. O que sobrou (ou o que tem prefixo Esf) é o Esférico
        esf_match = re.search(r'(?:Esf\.?\s*)?([+-]?\d+\.?\d*)\s*[aà]\s*([+-]?\d+\.?\d*)', text)
        if esf_match:
            e_min = float(esf_match.group(1))
            e_max = float(esf_match.group(2))
            
        return e_min, e_max, c_min, c_max, a_min, a_max

    def get_material_e_indice(material_sygma, indice_sygma, nome_lente=''):
        nome = str(nome_lente).upper()
        idx_to_parse = str(indice_sygma).replace(',', '.')
        
        # Se o índice na coluna for genérico (1.5) mas o nome tiver algo diferente
        if '1.59' in nome or 'POLI' in nome:
            idx_to_parse = '1.59'
        elif '1.67' in nome:
            idx_to_parse = '1.67'
        elif '1.74' in nome:
            idx_to_parse = '1.74'
        elif '1.61' in nome or '1.60' in nome:
            idx_to_parse = '1.61'
        elif '1.56' in nome:
            idx_to_parse = '1.56'
        elif '1.49' in nome or '1.50' in nome:
            idx_to_parse = '1.50'

        try:
            val = float(idx_to_parse)
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
            
        mat = str(material_sygma).upper() if pd.notnull(material_sygma) else ''
        
        if 'POLY' in mat or 'POLY' in nome or indice == "1.59":
            material = 'POLICARBONATO'
        elif 'TRIVEX' in mat or 'TRIVEX' in nome or val == 1.53:
            material = 'TRIVEX'
        elif float(indice) >= 1.6:
            material = 'HIGH_INDEX'
        else:
            material = 'CR39'
            
        if '1.67' in nome:
            print(f"DEBUG SYGMA: nome='{nome}' idx_sygma='{indice_sygma}' idx_to_parse='{idx_to_parse}' final_indice='{indice}'")
            
        return material, indice

    def parse_tratamentos(nome_lente, desc_extra=''):
        text = (str(nome_lente) + ' ' + str(desc_extra)).upper()
        res = {
            'ar': False,
            'blue': False,
            'uv400': False,
            'fotossensivel': 'nenhum',
            'antirrisco': False
        }
        
        if any(x in text for x in ['C/AR', 'AR ', 'ANTI-REFLEXO', 'ANTIRREFLEXO']):
            res['ar'] = True
            res['antirrisco'] = True
            
        if 'BLUE' in text:
            res['blue'] = True
            res['uv400'] = True
            
        if 'PHOTO' in text or 'FOTO' in text or 'TRANSITIONS' in text:
            res['fotossensivel'] = 'transitions' if 'TRANSITIONS' in text else 'fotocromático'
            
        return res

    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            if custo > 100: venda = custo * 4.0
        return round(venda, 2)

    all_lentes = []
    xl = pd.ExcelFile(input_path)
    
    sheets_config = {
        'vs': 'visao_simples',
        'vs_surf': 'visao_simples',
        'multi': 'multifocal',
        'multi_surf': 'multifocal',
        'multi_dig': 'multifocal',
        'multi_essilor': 'multifocal',
        'bifocais': 'bifocal',
        'color': 'visao_simples'
    }

    for sheet, tipo_base in sheets_config.items():
        if sheet not in xl.sheet_names:
            continue
            
        df = pd.read_excel(input_path, sheet_name=sheet)
        
        # Sygma columns vary. We'll map them carefully.
        for _, row in df.iterrows():
            nome = row.get('Descrição da Lente') or row.get('Descrição') or row.get('Tipo') or 'Lente Sygma'
            if pd.isnull(nome) or str(nome).strip() == '' or str(nome).lower() == 'nan':
                continue
            
            preco_raw = row.get('Valor / Par') or row.get('valor_par')
            try:
                preco = float(str(preco_raw).replace(',', '.'))
                if preco <= 0: continue
            except:
                continue

            grade_raw = row.get('Grade') or row.get('Dioptria') or ''
            e_min, e_max, c_min, c_max, a_min_g, a_max_g = parse_grade(grade_raw)
            
            # Additional Addition columns in some sheets
            add_col = row.get('Adição') or row.get('Adicao')
            if pd.notnull(add_col) and str(add_col).strip() != '':
                parts = str(add_col).replace(',', '.').replace('à', ' a ').split(' a ')
                try:
                    add_min = float(parts[0].strip())
                    add_max = float(parts[-1].strip())
                except:
                    add_min, add_max = a_min_g, a_max_g
            else:
                add_min, add_max = a_min_g, a_max_g
            
            # Garantir adição padrão para multifocais se vier zerado
            if tipo_base == 'multifocal' and (add_max == 0 or pd.isnull(add_max)):
                add_min, add_max = 1.0, 3.0
            
            idx_sygma = row.get('Índice') or (1.50 if 'CR' in str(nome) else 1.50)
            mat_sygma = row.get('Categoria') or ''
            
            material, indice = get_material_e_indice(mat_sygma, idx_sygma, nome)
            traits = parse_tratamentos(nome, sheet)
            
            marca_id = get_marca_id(nome)
            categoria = 'premium' if marca_id != id_marca_sygma else 'economica'
            
            # Construir nome final sem duplicar o índice
            nome_limpo = str(nome).strip()
            if indice in nome_limpo or (indice == '1.50' and '1.49' in nome_limpo):
                nome_completo = nome_limpo
            else:
                nome_completo = f"{nome_limpo} {indice}"

            lente = {
                'id': str(uuid.uuid4()),
                'fornecedor_id': fornecedor_id,
                'marca_id': marca_id,
                'nome_lente': nome_completo,
                'nome_comercial': nome_limpo,
                'tipo_lente': tipo_base,
                'material': material,
                'indice_refracao': indice,
                'categoria': categoria,
                'tratamento_antirreflexo': traits['ar'],
                'tratamento_antirrisco': traits['antirrisco'],
                'tratamento_uv': traits['uv400'] or float(indice) >= 1.6,
                'tratamento_blue_light': traits['blue'],
                'tratamento_fotossensiveis': traits['fotossensivel'],
                'fotossensivel': traits['fotossensivel'],
                'ar': traits['ar'],
                'blue': traits['blue'],
                'uv400': traits['uv400'] or float(indice) >= 1.6,
                'antirrisco': traits['antirrisco'],
                'polarizado': 'POLARIZADA' in str(nome).upper() or 'SOLAR' in str(nome).upper(),
                'esferico_min': e_min,
                'esferico_max': e_max,
                'cilindrico_min': min(c_min, c_max),
                'cilindrico_max': max(c_min, c_max),
                'grau_esferico_min': e_min,
                'grau_esferico_max': e_max,
                'grau_cilindrico_min': min(c_min, c_max),
                'grau_cilindrico_max': max(c_min, c_max),
                'adicao_min': add_min,
                'adicao_max': add_max,
                'preco_custo': float(preco),
                'custo_base': float(preco),
                'preco_tabela': calcular_preco_venda(float(preco)),
                'status': 'ativo',
                'ativo': True,
                'disponivel': True,
                'prazo_entrega': 5
            }
            all_lentes.append(lente)

    df_final = pd.DataFrame(all_lentes)
    if 'indice_refracao' in df_final.columns:
        df_final['indice_refracao'] = df_final['indice_refracao'].astype(str)
        
    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização SYGMA concluída: {output_path} ({len(df_final)} lentes)")

if __name__ == "__main__":
    normalizar_sygma()
