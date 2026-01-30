import pandas as pd
import os

folder = r'd:\projetos\sis_lens\povoar_banco\csv\banco'
files = [f for f in os.listdir(folder) if f.endswith('.csv')]
all_lenses = []

for f in files:
    try:
        df = pd.read_csv(os.path.join(folder, f))
        # Selecionar apenas as colunas que nos interessam
        df_subset = df[['nome_lente', 'preco_custo']].copy()
        df_subset['arquivo'] = f
        all_lenses.append(df_subset)
    except:
        continue

# Consolidar todas as lentes
full_df = pd.concat(all_lenses)

# Remover duplicatas (algumas lentes podem aparecer em mais de um arquivo) e custos zero
full_df = full_df[full_df['preco_custo'] > 0].drop_duplicates(subset=['nome_lente', 'preco_custo'])

# Top 5 Mais Baratas
cheapest = full_df.sort_values(by='preco_custo', ascending=True).head(5)

# Top 5 Mais Caras
expensive = full_df.sort_values(by='preco_custo', ascending=False).head(5)

print("\n--- AS 5 LENTES MAIS BARATAS (MENOR CUSTO) ---")
print(f"{'CUSTO':<10} | {'LENTE':<50} | {'LABORATÓRIO'}")
print("-" * 90)
for _, row in cheapest.iterrows():
    print(f"{row['preco_custo']:<10.2f} | {row['nome_lente'][:50]:<50} | {row['arquivo']}")

print("\n--- AS 5 LENTES MAIS CARAS (MAIOR CUSTO) ---")
print(f"{'CUSTO':<10} | {'LENTE':<50} | {'LABORATÓRIO'}")
print("-" * 90)
for _, row in expensive.iterrows():
    print(f"{row['preco_custo']:<10.2f} | {row['nome_lente'][:50]:<50} | {row['arquivo']}")
