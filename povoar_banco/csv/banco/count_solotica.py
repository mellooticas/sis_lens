import csv
from pathlib import Path

def main():
    marcas_file = Path(r'D:\projetos\sis_lens\povoar_banco\csv\banco\marcas_contato_final.csv')
    lentes_file = Path(r'D:\projetos\sis_lens\povoar_banco\csv\banco\lentes_contato_final.csv')

    solotica_ids = set()
    
    # 1. Obter IDs das marcas Solótica
    with open(marcas_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if 'Solótica' in row['fabricante']:
                solotica_ids.add(row['id'])
    
    print(f"IDs de Marcas Solótica encontrados: {len(solotica_ids)}")
    print(solotica_ids)

    # 2. Contar lentes com esses IDs
    count = 0
    with open(lentes_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['marca_id'] in solotica_ids:
                count += 1
    
    print(f"Total de lentes Solótica no banco: {count}")

if __name__ == "__main__":
    main()
