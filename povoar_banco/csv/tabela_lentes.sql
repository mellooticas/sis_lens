create table lens_catalog.lentes (
  id uuid not null default gen_random_uuid (),
  fornecedor_id uuid not null,
  marca_id uuid null,
  grupo_canonico_id uuid null,
  nome_lente text not null,
  nome_canonizado text null,
  slug text null,
  sku character varying(100) null,
  codigo_fornecedor character varying(100) null,
  tipo_lente lens_catalog.tipo_lente not null,
  material lens_catalog.material_lente not null,
  indice_refracao lens_catalog.indice_refracao not null,
  categoria lens_catalog.categoria_lente not null,
  tratamento_antirreflexo boolean not null default false,
  tratamento_antirrisco boolean not null default false,
  tratamento_uv boolean not null default false,
  tratamento_blue_light boolean not null default false,
  tratamento_fotossensiveis lens_catalog.tratamento_foto null default 'nenhum'::lens_catalog.tratamento_foto,
  diametro_mm integer null,
  curva_base numeric(4, 2) null,
  espessura_centro_mm numeric(4, 2) null,
  eixo_optico character varying(50) null,
  grau_esferico_min numeric(5, 2) null,
  grau_esferico_max numeric(5, 2) null,
  grau_cilindrico_min numeric(5, 2) null,
  grau_cilindrico_max numeric(5, 2) null,
  adicao_min numeric(3, 2) null,
  adicao_max numeric(3, 2) null,
  preco_custo numeric(10, 2) not null default 0,
  preco_venda_sugerido numeric(10, 2) not null default 0,
  margem_lucro numeric(5, 2) null,
  estoque_disponivel integer null default 0,
  estoque_minimo integer null default 0,
  lead_time_dias integer null,
  status lens_catalog.status_lente not null default 'ativo'::lens_catalog.status_lente,
  ativo boolean not null default true,
  peso integer null default 50,
  metadata jsonb null default '{}'::jsonb,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  deleted_at timestamp with time zone null,
  sku_fornecedor character varying null,
  codigo_original character varying null,
  nome_comercial text null,
  descricao_curta text null,
  linha_produto character varying null,
  custo_base numeric(10, 2) null default 0,
  preco_tabela numeric(10, 2) null default 0,
  preco_fabricante numeric(10, 2) null,
  esferico_min numeric(4, 2) null,
  esferico_max numeric(4, 2) null,
  cilindrico_min numeric(4, 2) null,
  cilindrico_max numeric(4, 2) null,
  dnp_min integer null,
  dnp_max integer null,
  prazo_entrega integer null default 7,
  obs_prazo text null,
  peso_frete numeric null default 50.0,
  exige_receita_especial boolean null default false,
  disponivel boolean null default true,
  diametro integer null,
  espessura_central numeric null,
  peso_aproximado numeric null,
  ar boolean null default false,
  antirrisco boolean null default false,
  hidrofobico boolean null default false,
  antiembaçante boolean null default false,
  blue boolean null default false,
  uv400 boolean null default false,
  polarizado boolean null default false,
  digital boolean null default false,
  free_form boolean null default false,
  indoor boolean null default false,
  drive boolean null default false,
  fotossensivel text null default 'nenhum'::text,
  destaque boolean null default false,
  novidade boolean null default false,
  data_lancamento date null,
  data_descontinuacao date null,
  descricao_completa text null,
  contraindicacoes text null,
  observacoes text null,
  beneficios text[] null,
  indicacoes text[] null,
  constraint lentes_pkey primary key (id),
  constraint lentes_slug_key unique (slug),
  constraint lentes_fornecedor_id_fkey foreign KEY (fornecedor_id) references core.fornecedores (id),
  constraint lentes_grupo_canonico_id_fkey foreign KEY (grupo_canonico_id) references lens_catalog.grupos_canonicos (id),
  constraint lentes_marca_id_fkey foreign KEY (marca_id) references lens_catalog.marcas (id)
) TABLESPACE pg_default;

create index IF not exists idx_lentes_fornecedor on lens_catalog.lentes using btree (fornecedor_id) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_lentes_marca on lens_catalog.lentes using btree (marca_id) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_lentes_grupo on lens_catalog.lentes using btree (grupo_canonico_id) TABLESPACE pg_default;

create index IF not exists idx_lentes_tipo on lens_catalog.lentes using btree (tipo_lente) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_lentes_grupo_canonico on lens_catalog.lentes using btree (grupo_canonico_id) TABLESPACE pg_default;

create index IF not exists idx_lentes_material on lens_catalog.lentes using btree (material) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_lentes_indice on lens_catalog.lentes using btree (indice_refracao) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_lentes_categoria on lens_catalog.lentes using btree (categoria) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_lentes_status on lens_catalog.lentes using btree (status) TABLESPACE pg_default;

create index IF not exists idx_lentes_slug on lens_catalog.lentes using btree (slug) TABLESPACE pg_default;

create index IF not exists idx_lentes_nome_canonizado on lens_catalog.lentes using btree (nome_canonizado) TABLESPACE pg_default;

create index IF not exists idx_lentes_preco on lens_catalog.lentes using btree (preco_venda_sugerido) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_lentes_sku on lens_catalog.lentes using btree (sku) TABLESPACE pg_default;

create index IF not exists gin_lentes_metadata on lens_catalog.lentes using gin (metadata) TABLESPACE pg_default;

create index IF not exists idx_lentes_sku_forn on lens_catalog.lentes using btree (sku_fornecedor) TABLESPACE pg_default;

create index IF not exists idx_lentes_nome_com on lens_catalog.lentes using btree (nome_comercial) TABLESPACE pg_default;

create index IF not exists idx_lentes_preco_v3 on lens_catalog.lentes using btree (preco_tabela) TABLESPACE pg_default;

create index IF not exists idx_lentes_sku_v4 on lens_catalog.lentes using btree (sku_fornecedor) TABLESPACE pg_default;

create trigger trg_calcular_preco_venda BEFORE INSERT
or
update OF preco_custo on lens_catalog.lentes for EACH row
execute FUNCTION lens_catalog.fn_calcular_preco_venda ();

create trigger trg_lente_delete
after DELETE on lens_catalog.lentes for EACH row
execute FUNCTION lens_catalog.trigger_deletar_lente_atualizar_grupo ();

create trigger trg_lente_insert_update BEFORE INSERT
or
update on lens_catalog.lentes for EACH row
execute FUNCTION lens_catalog.trigger_atualizar_grupo_canonico ();

create trigger trg_lentes_generate_slug BEFORE INSERT
or
update on lens_catalog.lentes for EACH row
execute FUNCTION lens_catalog.generate_lente_slug ();

create trigger trg_lentes_updated_at BEFORE
update on lens_catalog.lentes for EACH row
execute FUNCTION lens_catalog.update_lentes_timestamp ();