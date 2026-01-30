import pandas as pd
import os

folder = r'd:\projetos\sis_lens\povoar_banco\csv\banco'
files = [f for f in os.listdir(folder) if f.endswith('.csv')]
all_high = []

for f in files:
    try:
        df = pd.read_csv(os.path.join(folder, f))
        temp_df = df[['nome_lente', 'preco_custo']].copy()
        temp_df['arquivo'] = f
        all_high.append(temp_df)
    except:
        continue

full_df = pd.concat(all_high)
top_10 = full_df.sort_values(by='preco_custo', ascending=False).head(10)

print(f"{'CUSTO':<10} | {'LENTE':<50} | {'ARQUIVO'}")
print("-" * 90)
for _, row in top_10.iterrows():
    print(f"{row['preco_custo']:<10.2f} | {row['nome_lente'][:50]:<50} | {row['arquivo']}")
