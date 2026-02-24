import json
import locale
# Força separador decimal americano (ponto) independente do locale do SO (pt_BR usa vírgula)
locale.setlocale(locale.LC_NUMERIC, 'C')

# Carregar dados
with open("extracted_ranges.json", "r", encoding="utf-8") as f:
    ranges = json.load(f)

with open("extracted_lenses.json", "r", encoding="utf-8") as f:
    lenses = json.load(f)

def clean_sql(val):
    """Converte valor para SQL garantindo ponto como separador decimal (padrão americano/Postgres)."""
    if val is None: return "NULL"
    if isinstance(val, float):
        # repr() é locale-independente — sempre usa ponto decimal
        return repr(val)
    return str(val)

# 0. Gerar SQL para sincronizar Marcas e Fornecedores (Migration 247)
unique_brands = sorted(list(set(l['brand'] for l in lenses)))
sql_brands = [
    "-- SIS_DIGIAI - Migration 247 (BRAND & SUPPLIER SYNC)",
    "-- Objective: Ensure all brands/suppliers from Excel exist in the DB",
    "BEGIN;"
]

for b in unique_brands:
    brand_slug = b.lower().replace(' ', '_')
    safe_brand = b.replace("'", "''")
    # Inserir Fornecedor (na partição sales_finance)
    sql_brands.append(
        f"INSERT INTO sales_finance.suppliers (id, tenant_id, name, slug) "
        f"VALUES (public.legacy_uuid('supplier', '{brand_slug}'), '00000000-0000-0000-0000-000000000000', '{safe_brand}', '{brand_slug}') "
        f"ON CONFLICT (id) DO NOTHING;"
    )
    # Inserir Marca (na partição catalog_lenses)
    sql_brands.append(
        f"INSERT INTO catalog_lenses.brands (tenant_id, supplier_id, name) "
        f"VALUES ('00000000-0000-0000-0000-000000000000', public.legacy_uuid('supplier', '{brand_slug}'), '{safe_brand}') "
        f"ON CONFLICT (name) DO NOTHING;"
    )

sql_brands.append("COMMIT;")

with open("247_sync_brands_and_suppliers.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sql_brands))

# 1. Gerar SQL para lens_matrices
sql_matrices = [
    "-- SIS_DIGIAI - Migration 248 (PURE MASTER SEED)",
    "-- Objective: Populate technical range dictionary from Excel Source of Truth",
    "BEGIN;",
    "TRUNCATE TABLE catalog_lenses.lens_matrices CASCADE;",
    "INSERT INTO catalog_lenses.lens_matrices (tenant_id, spherical_min, spherical_max, cylindrical_min, cylindrical_max, addition_min, addition_max) VALUES"
]

def is_valid_range(r):
    """Filtra ranges com valores absurdos (dados corrompidos do Excel)."""
    sph_min, sph_max, cyl_min, cyl_max = r[0], r[1], r[2], r[3]
    # Valores esféricos fora de range óptico real
    if sph_min is not None and (abs(sph_min) > 30): return False
    if sph_max is not None and (abs(sph_max) > 30): return False
    # Valores cilíndricos claramente errados (ex: 220, 300, 640)
    if cyl_min is not None and (abs(cyl_min) > 20): return False
    if cyl_max is not None and (abs(cyl_max) > 20): return False
    # Deve ter pelo menos sph_min e sph_max válidos
    if sph_min is None or sph_max is None: return False
    return True

def sanitize_range(r):
    """Normaliza valores None onde a coluna é NOT NULL."""
    sph_min, sph_max, cyl_min, cyl_max, add_min, add_max = r
    # Lentes esféricas: cyl_min=None significa 0.0 (sem cilíndrico)
    if cyl_min is None and cyl_max is not None: cyl_min = 0.0
    if cyl_max is None and cyl_min is not None: cyl_max = 0.0
    # Se ambos cyl são None, é esférica pura → 0.0, 0.0
    if cyl_min is None and cyl_max is None:
        cyl_min, cyl_max = 0.0, 0.0
    return [sph_min, sph_max, cyl_min, cyl_max, add_min, add_max]

valid_ranges = [sanitize_range(r) for r in ranges if is_valid_range(r)]
print(f"Ranges válidos: {len(valid_ranges)} / {len(ranges)} (descartados: {len(ranges)-len(valid_ranges)})")

matrix_rows = []
for r in valid_ranges:
    row = f"('00000000-0000-0000-0000-000000000000', {clean_sql(r[0])}, {clean_sql(r[1])}, {clean_sql(r[2])}, {clean_sql(r[3])}, {clean_sql(r[4])}, {clean_sql(r[5])})"
    matrix_rows.append(row)

sql_matrices.append(",\n".join(matrix_rows) + ";")
sql_matrices.append("COMMIT;")

with open("248_populate_lens_matrices_seed.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sql_matrices))

# 2. Gerar SQL para re-import de lentes (Migration 249)
sql_lenses = [
    "-- SIS_DIGIAI - Migration 249 (MASTER LENS RE-IMPORT)",
    "-- Objective: Re-populate lenses table with data directly from Excel",
    "BEGIN;",
    "DELETE FROM catalog_lenses.lenses WHERE source_system = 'excel_sync';",
    "INSERT INTO catalog_lenses.lenses (id, tenant_id, supplier_id, brand_id, lens_name, price_cost, material, refractive_index, spherical_min, spherical_max, cylindrical_min, cylindrical_max, addition_min, addition_max, source_system)",
    "VALUES"
]

def map_material(mat_str, index):
    ms = str(mat_str).lower()
    if 'poli' in ms: return 'polycarbonate'
    if 'resina' in ms or 'cr' in ms or '1.50' in ms or '1.49' in ms: return 'cr39'
    if 'trivex' in ms: return 'trivex'
    if index and float(index) >= 1.6: return 'high_index'
    return 'cr39'

lens_rows = []
for l in lenses:
    brand_slug = l['brand'].lower().replace(' ', '_')
    material = map_material(l['material'], l['refractive_index'])
    
    # Escape quotes manually to avoid f-string issues
    safe_name = str(l['name']).replace("'", "''")
    safe_brand = str(l['brand']).replace("'", "''")
    
    row = (
        f"(public.legacy_uuid('lens_excel', '{safe_name}_{safe_brand}'), "
        f"'00000000-0000-0000-0000-000000000000', "
        f"public.legacy_uuid('supplier', '{brand_slug}'), "
        f"(SELECT id FROM catalog_lenses.brands WHERE name ILIKE '{safe_brand}' LIMIT 1), "
        f"'{safe_name}', "
        f"{l['cost']}, "
        f"'{material}', "
        f"{clean_sql(l['refractive_index'])}, "
        f"{clean_sql(l.get('sph_min'))}, {clean_sql(l.get('sph_max'))}, "
        f"{clean_sql(l.get('cyl_min'))}, {clean_sql(l.get('cyl_max'))}, "
        f"{clean_sql(l.get('add_min'))}, {clean_sql(l.get('add_max'))}, "
        f"'excel_sync')"
    )
    lens_rows.append(row)

sql_lenses.append(",\n".join(lens_rows) + ";")
sql_lenses.append("COMMIT;")

with open("249_reimport_lenses_from_excel.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sql_lenses))

print("Migrations 248 e 249 geradas com sucesso.")
