import pandas as pd
import uuid
import os

def normalizar_high_vision():
    raw_path = r'D:\projetos\sis_lens\povoar_banco\csv\high_vision_raw.csv'
    output_path = r'D:\projetos\sis_lens\povoar_banco\csv\banco\high_vision_final.csv'
    
    # IDs que definimos no script 18_CADASTRAR_HIGHVISION.sql
    fornecedor_id = '2ee5b31f-0e98-467b-9c69-251f284c4a78'
    marca_id = '89264c78-2dcb-494b-a9f8-d7b6e54c3a10'
    
    def calcular_preco_venda(custo):
        if custo <= 0: return 0.0
        venda = max(custo * 3.0, 250.0 + (custo * 0.1))
        if venda > custo * 4.0:
            if custo > 100: venda = custo * 4.0
        return round(venda, 2)

    def transform_row(row):
        nome = str(row['nome_completo_lente'])
        material_raw = str(row['material']).upper()
        
        # Mapeamento de Material
        if 'POLI' in material_raw:
            material = 'POLICARBONATO'
        elif 'ALTO_INDICE' in material_raw:
            material = 'HIGH_INDEX'
        else:
            material = 'CR39'
            
        # Fotossensível
        foto_raw = str(row['foto']).upper()
        foto = 'fotocromático' if foto_raw == 'SIM' else 'nenhum'
        
        # Tratamentos
        has_blue = str(row['blue']).upper() == 'SIM'
        # Quase todas são AR pelo nome "HV PRIME CR AR"
        has_ar = ' AR ' in nome or ' AR' in nome
        has_uv = material == 'POLICARBONATO' or material == 'HIGH_INDEX' or float(row['indice']) >= 1.6
        has_antirrisco = has_ar or material == 'POLICARBONATO'
        
        # Normalização de Índices (conforme enums do banco)
        indice_raw = float(row['indice'])
        if indice_raw == 1.56:
            indice = "1.56"
        elif indice_raw == 1.59:
            indice = "1.59"
        elif indice_raw == 1.61:
            indice = "1.61"
        elif indice_raw == 1.67:
            indice = "1.67"
        elif indice_raw == 1.74:
            indice = "1.74"
        else:
            indice = "{:.2f}".format(indice_raw)
            if indice == "1.50": pass # OK
            else: indice = "1.50" # Default para resina
            
        return {
            'id': str(uuid.uuid4()),
            'fornecedor_id': fornecedor_id,
            'marca_id': marca_id,
            'nome_lente': nome,
            'nome_comercial': nome,
            'tipo_lente': 'visao_simples',
            'material': material,
            'indice_refracao': indice,
            'categoria': 'intermediaria' if material != 'CR39' else 'economica',
            'tratamento_antirreflexo': has_ar,
            'tratamento_antirrisco': has_antirrisco,
            'tratamento_uv': has_uv,
            'tratamento_blue_light': has_blue,
            'tratamento_fotossensiveis': foto,
            'fotossensivel': foto,
            'ar': has_ar,
            'blue': has_blue,
            'uv400': has_uv,
            'antirrisco': has_antirrisco,
            'esferico_min': row['esf_min'],
            'esferico_max': row['esf_max'],
            'cilindrico_min': row['cil_min'],
            'cilindrico_max': row['cil_max'],
            'grau_esferico_min': row['esf_min'],
            'grau_esferico_max': row['esf_max'],
            'grau_cilindrico_min': row['cil_min'],
            'grau_cilindrico_max': row['cil_max'],
            'preco_custo': row['valor'],
            'custo_base': row['valor'],
            'preco_tabela': calcular_preco_venda(float(row['valor'])),
            'status': 'ativo',
            'ativo': True,
            'disponivel': True,
            'prazo_entrega': 3,
            'adicao_min': None,
            'adicao_max': None
        }

    df_raw = pd.read_csv(raw_path)
    final_data = [transform_row(row) for _, row in df_raw.iterrows()]
    
    df_final = pd.DataFrame(final_data)
    df_final.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Normalização High Vision concluída: {output_path}")

if __name__ == "__main__":
    normalizar_high_vision()
