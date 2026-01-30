import csv
from pathlib import Path

def normalize_name(name):
    return name.lower().strip()

def main():
    root_dir = Path(r'D:\projetos\sis_lens\povoar_banco\csv')
    solotica_file = root_dir / 'banco' / 'solótica.csv'
    lentenet_file = root_dir / 'lentenet.csv'
    newlentes_file = root_dir / 'newlentes.csv'

    # Carregar nomes existentes
    existing_products = set()
    
    # Lentenet
    if lentenet_file.exists():
        with open(lentenet_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                existing_products.add(normalize_name(row['nome']))

    # NewLentes
    if newlentes_file.exists():
        with open(newlentes_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                existing_products.add(normalize_name(row['nome']))
                
    print(f"Total de produtos existentes carregados: {len(existing_products)}")

    # Verificar Solótica
    duplicates = []
    new_items = []
    
    if solotica_file.exists():
        with open(solotica_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = normalize_name(row['nome'])
                if name in existing_products:
                    duplicates.append(name)
                else:
                    new_items.append(name)
    
    print(f"\nAnálise do arquivo solótica.csv:")
    print(f"Novos itens: {len(new_items)}")
    print(f"Duplicados (já existem): {len(duplicates)}")
    
    if duplicates:
        print("\nExemplos de duplicados:")
        for d in duplicates[:10]:
            print(f"- {d}")

if __name__ == "__main__":
    main()
