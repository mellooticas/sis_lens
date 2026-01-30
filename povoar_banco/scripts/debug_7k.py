import pandas as pd
import os

folder = r'd:\projetos\sis_lens\povoar_banco\csv\banco'
files = [f for f in os.listdir(folder) if f.endswith('.csv')]

for f in files:
    try:
        df = pd.read_csv(os.path.join(folder, f))
        # Procurando preço de VENDA por volta de 7000
        matches = df[(df['preco_tabela'] >= 6000) | (df['preco_custo'] >= 3000)]
        if not matches.empty:
            for _, row in matches.iterrows():
                print(f"{f} | {row['nome_lente'][:50]:<50} | Custo: {row['preco_custo']:<8.2f} | Venda: {row['preco_tabela']:<8.2f}")
    except:
        continue
