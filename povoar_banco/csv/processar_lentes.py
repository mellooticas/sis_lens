import csv
import re
import json
import uuid
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple

# ============================================================================
# CONFIGURAÇÕES E MAPEAMENTOS REAIS (vincos IDs do banco)
# ============================================================================

# IDs dos Fornecedores (conforme docs/database/reestruturation_database_sis_lens/DIAGNOSTICO_IMPORTACAO_CSV.sql)
ID_FORNECEDOR_LENTENET = 'b01bd4fe-a383-4006-b4ec-1d397ba2c0c1'
ID_FORNECEDOR_NEWLENTES = '4f4dc190-4e26-4352-a7e9-a748880d9365'

# IDs de Marcas Existentes (conforme investigação no banco)
MARCAS_EXISTENTES_IDS = {
    'Acuvue': '4ba0d55f-70a5-4e51-8ddc-b1f283d298f4',
    'Air Optix': 'b2c6b318-0842-4cea-9871-8f949445dede',
    'Biofinity': 'c8a1c72b-14b8-4fb6-b5e2-8fab6cf99c88',
    'Biosoft': '58dacfaf-b712-4fca-b972-0cd5a89008f1',
    'Dailies': '4fcb3afe-be54-49bf-973e-d627090b0e2b',
    'Hidrocor': 'a16aa23b-815c-421c-96e6-c652fc239d94',
    'Soflens': '38d91af6-0fed-43bc-97e8-1cab30a9631d',
}

# --- CONFIGURAÇÕES DE FABRICANTES (IDs Reais da tabela core.fornecedores) ---
FABRICANTES_IDS = {
    'Alcon': 'f0c192cd-1ba8-459b-a82e-b3ff049644d9',
    'Johnson & Johnson': '4b2d639c-1895-4c17-8a6f-442dc8a8d046',
    'CooperVision': '9400f665-2f93-47ba-97c5-2a2248236e6a',
    'Bausch & Lomb': 'a725651f-79ee-4558-8f69-dc8b066b3319',
    'Solótica': 'f8b6d0f7-42b5-46ff-b216-ad717ce0e8bb',
    'Optolentes': None,
    'Natural Vision': None,
    'Central Oftálmica': None,
    'Aveo': None,
}

MARCAS_CONHECIDAS = {
    'Acuvue': {'fabricante': 'Johnson & Johnson', 'premium': True},
    'Air Optix': {'fabricante': 'Alcon', 'premium': True},
    'Precision': {'fabricante': 'Alcon', 'premium': True},
    'Dailies': {'fabricante': 'Alcon', 'premium': True},
    'Alcon': {'fabricante': 'Alcon', 'premium': True},
    'Bausch': {'fabricante': 'Bausch & Lomb', 'premium': True},
    'Soflens': {'fabricante': 'Bausch & Lomb', 'premium': True},
    'Purevision': {'fabricante': 'Bausch & Lomb', 'premium': True},
    'Biotrue': {'fabricante': 'Bausch & Lomb', 'premium': True},
    'Ultra': {'fabricante': 'Bausch & Lomb', 'premium': True},
    'Optima': {'fabricante': 'Bausch & Lomb', 'premium': False},
    'Lunare': {'fabricante': 'Bausch & Lomb', 'premium': False},
    'Biofinity': {'fabricante': 'CooperVision', 'premium': True},
    'Clariti': {'fabricante': 'CooperVision', 'premium': True},
    'Proclear': {'fabricante': 'CooperVision', 'premium': True},
    'Avaira': {'fabricante': 'CooperVision', 'premium': True},
    'Biomedics': {'fabricante': 'CooperVision', 'premium': False},
    'CooperVision': {'fabricante': 'CooperVision', 'premium': True},
    'Hidrocor': {'fabricante': 'Solótica', 'premium': False},
    'Natural Colors': {'fabricante': 'Solótica', 'premium': False},
    'Solflex': {'fabricante': 'Solótica', 'premium': False},
    'Hidrosoft': {'fabricante': 'Solótica', 'premium': False},
    'Hidroblue': {'fabricante': 'Solótica', 'premium': False},
    'Solotica': {'fabricante': 'Solótica', 'premium': False},
    'Solótica': {'fabricante': 'Solótica', 'premium': False},
    'Magic Top': {'fabricante': 'Optolentes', 'premium': False},
    'Optogel': {'fabricante': 'Optolentes', 'premium': False},
    'Optycolor': {'fabricante': 'Optolentes', 'premium': False},
    'Natural Vision': {'fabricante': 'Natural Vision', 'premium': False},
    'Biosoft': {'fabricante': 'Central Oftálmica', 'premium': False},
    'Bioview': {'fabricante': 'Central Oftálmica', 'premium': False},
    'Bioblue': {'fabricante': 'Central Oftálmica', 'premium': False},
    'Silidrogel': {'fabricante': 'Central Oftálmica', 'premium': False},
    'Aveo': {'fabricante': 'Aveo', 'premium': False},
}

# Namespace consistente para gerar UUIDs de marcas novas v5
NAMESPACE_MARCAS = uuid.UUID('6ba7b810-9dad-11d1-80b4-00c04fd430c8')

def gerar_uuid_marca(nome: str) -> str:
    """Gera um UUID v5 consistente para uma marca se ela não existir"""
    if not nome: return None
    if nome in MARCAS_EXISTENTES_IDS:
        return MARCAS_EXISTENTES_IDS[nome]
    return str(uuid.uuid5(NAMESPACE_MARCAS, nome.lower()))

def gerar_slug(texto: str) -> str:
    """Gera slug a partir do texto"""
    if not texto: return ""
    slug = texto.lower()
    mapping = {'à':'a','á':'a','â':'a','ã':'a','ä':'a','å':'a','è':'e','é':'e','ê':'e','ë':'e',
               'ì':'i','í':'i','î':'i','ï':'i','ò':'o','ó':'o','ô':'o','õ':'o','ö':'o','ù':'u',
               'ú':'u','û':'u','ü':'u','ç':'c'}
    for char, replacement in mapping.items():
        slug = slug.replace(char, replacement)
    slug = re.sub(r'[^a-z0-9]+', '-', slug)
    return slug.strip('-')

def extrair_marca(nome: str, categorias: str) -> Optional[str]:
    """Extrai a marca do nome do produto ou categorias"""
    texto = f"{nome} {categorias}"
    for marca in MARCAS_CONHECIDAS.keys():
        if marca.lower() in texto.lower():
            return marca
    return None

def parse_categorias(categorias: str) -> Tuple[str, str]:
    """Parse das categorias para extrair tipo_lente e finalidade"""
    cats_str = categorias.lower()
    
    tipo = 'mensal'
    if 'diária' in cats_str or 'diario' in cats_str or '1-day' in cats_str:
        tipo = 'diaria'
    elif 'quinzenal' in cats_str or 'quinzenais' in cats_str:
        tipo = 'quinzenal'
    elif 'mensal' in cats_str or 'mensais' in cats_str:
        tipo = 'mensal'
    elif 'anual' in cats_str or 'anuais' in cats_str:
        tipo = 'anual'
    
    finalidade = 'visao_simples'
    if 'astigmatismo' in cats_str or 'tórica' in cats_str or 'torica' in cats_str or 'astigmatic' in cats_str:
        finalidade = 'torica'
    elif 'multifocal' in cats_str or 'multifocais' in cats_str or 'presbiopia' in cats_str:
        finalidade = 'multifocal'
    elif 'colorida' in cats_str or 'coloridas' in cats_str or 'estética' in cats_str:
        finalidade = 'cosmetica'
    
    return tipo, finalidade

def determinar_material(marca: Optional[str]) -> str:
    """Determina o material baseado na marca"""
    if not marca: return 'hidrogel'
    marca_info = MARCAS_CONHECIDAS.get(marca, {})
    return 'silicone_hidrogel' if marca_info.get('premium', False) else 'hidrogel'

def converter_preco(preco_str: str) -> float:
    """Converte preço de centavos ou string para float"""
    try:
        preco_str = preco_str.strip().replace(',', '.')
        preco = float(preco_str)
        return preco / 100.0 if preco > 1000 else preco
    except:
        return 0.0

def processar_csv(arquivo: Path, fornecedor_id: str) -> List[Dict]:
    """Processa um arquivo CSV e retorna lista de lentes formatadas para o banco"""
    lentes = []
    if not arquivo.exists():
        print(f"Aviso: Arquivo {arquivo.name} não encontrado.")
        return []

    with open(arquivo, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get('http_status') != '200': continue
            
            nome = row['nome'].strip()
            categorias = row.get('categorias', '')
            marca_nome = extrair_marca(nome, categorias)
            tipo, finalidade = parse_categorias(categorias)
            
            preco_original = converter_preco(row.get('preco_original', '0'))
            preco_promocional = converter_preco(row.get('preco_promocional', '0'))
            preco_tabela = preco_promocional if preco_promocional > 0 else preco_original
            
            lente = {
                'fornecedor_id': fornecedor_id,
                'marca_id': gerar_uuid_marca(marca_nome) if marca_nome else None,
                'nome_produto': nome,
                'slug': gerar_slug(nome),
                'sku': row.get('sku', ''),
                'codigo_fornecedor': row.get('id', ''),
                'tipo_lente': tipo,
                'material': determinar_material(marca_nome),
                'finalidade': finalidade,
                'preco_custo': round(preco_original * 0.65, 2),
                'preco_tabela': preco_tabela,
                'dias_uso': {'diaria': 1, 'quinzenal': 15, 'mensal': 30, 'anual': 365}.get(tipo, 30),
                'unidades_por_caixa': 30 if tipo == 'diaria' else (6 if tipo == 'mensal' else 1),
                'descricao_curta': row.get('descricao', ''),
                'disponivel': True,
                'ativo': True,
                'metadata': json.dumps({
                    'url_original': row.get('url', ''),
                    'categorias_originais': categorias,
                    'scraping_at': row.get('timestamp', '')
                }, ensure_ascii=False)
            }
            lentes.append(lente)
    return lentes

def main():
    root_dir = Path(r'D:\projetos\sis_lens\povoar_banco\csv')
    output_dir = root_dir / 'banco'
    output_dir.mkdir(exist_ok=True)
    
    print("Iniciando processamento das lentes...")
    
    # Processar Lentenet
    lentes_lentenet = processar_csv(root_dir / 'lentenet.csv', ID_FORNECEDOR_LENTENET)
    print(f"Lentenet: {len(lentes_lentenet)} registros.")
    
    # Processar NewLentes
    lentes_newlentes = processar_csv(root_dir / 'newlentes.csv', ID_FORNECEDOR_NEWLENTES)
    print(f"NewLentes: {len(lentes_newlentes)} registros.")
    
    all_lentes = lentes_lentenet + lentes_newlentes
    
    # --- GERAR CSV DE MARCAS ---
    marcas_vistas = {}
    for l in all_lentes:
        mid = l['marca_id']
        if not mid: continue
        
        if mid not in marcas_vistas:
            # Encontrar o nome da marca original
            marca_nome = None
            for name, existing_id in MARCAS_EXISTENTES_IDS.items():
                if existing_id == mid: marca_nome = name; break
            
            if not marca_nome:
                for name in MARCAS_CONHECIDAS.keys():
                    if gerar_uuid_marca(name) == mid: marca_nome = name; break
            
            if not marca_nome: marca_nome = "Outra"

            info = MARCAS_CONHECIDAS.get(marca_nome, {'fabricante': marca_nome, 'premium': False})
            fab_nome = info.get('fabricante')
            fab_id = FABRICANTES_IDS.get(fab_nome) if fab_nome else None

            marcas_vistas[mid] = {
                'id': mid,
                'nome': marca_nome,
                'slug': gerar_slug(marca_nome),
                'fabricante': fab_nome,
                'fabricante_id': fab_id,
                'is_premium': info.get('premium'),
                'ativo': True
            }
    
    marcas_csv_path = output_dir / 'marcas_contato_final.csv'
    with open(marcas_csv_path, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['id', 'nome', 'slug', 'fabricante', 'fabricante_id', 'is_premium', 'ativo'])
        writer.writeheader()
        for m in marcas_vistas.values():
            writer.writerow(m)
            
    # --- GERAR CSV DE LENTES ---
    lentes_csv_path = output_dir / 'lentes_contato_final.csv'
    columns = [
        'fornecedor_id', 'marca_id', 'nome_produto', 'slug', 'sku', 
        'codigo_fornecedor', 'tipo_lente', 'material', 'finalidade', 
        'preco_custo', 'preco_tabela', 'dias_uso', 'unidades_por_caixa', 
        'descricao_curta', 'disponivel', 'ativo', 'metadata'
    ]
    
    # Nota: Não incluímos 'id' no CSV de lentes para o Supabase gerar o UUID serial/aleatório, 
    # ou podemos incluir uuid.uuid4() como fiz no dict. Vamos deixar o banco gerar para evitar conflitos de UUID manual se rodar 2x.
    
    with open(lentes_csv_path, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=columns)
        writer.writeheader()
        for l in all_lentes:
            # Remover o ID manual do dict se existir, para o banco gerar
            row = {k: v for k, v in l.items() if k in columns}
            writer.writerow(row)
            
    print(f"\nFinalizado!")
    print(f"Marcas exportadas: {marcas_csv_path}")
    print(f"Lentes exportadas: {lentes_csv_path}")
    print(f"Total de lentes: {len(all_lentes)}")

if __name__ == "__main__":
    main()
