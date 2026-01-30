import pandas as pd
import os

def split_so_blocos():
    file_path = r'D:\projetos\sis_lens\povoar_banco\csv\so_blocos.xlsx'
    output_dir = r'D:\projetos\sis_lens\povoar_banco\csv'
    
    print(f"Lendo arquivo: {file_path}")
    
    # Carregar o Excel para ver os nomes das abas
    xl = pd.ExcelFile(file_path)
    print(f"Abas encontradas: {xl.sheet_names}")
    
    for sheet in xl.sheet_names:
        df = pd.read_excel(file_path, sheet_name=sheet)
        
        # Normalizar nome do arquivo de saída
        safe_name = sheet.lower().replace(' ', '_').replace('-', '_')
        output_file = os.path.join(output_dir, f"so_blocos_{safe_name}.csv")
        
        # Salvar como CSV
        df.to_csv(output_file, index=False, encoding='utf-8-sig')
        print(f"Exportado: {output_file} ({len(df)} linhas)")

if __name__ == "__main__":
    split_so_blocos()
