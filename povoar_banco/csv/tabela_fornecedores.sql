create table core.fornecedores (
  id uuid not null default gen_random_uuid (),
  nome text not null,
  razao_social text null,
  cnpj character varying(18) null,
  cep_origem character varying(9) null,
  cidade_origem text null,
  estado_origem character varying(2) null,
  prazo_visao_simples integer null default 7,
  prazo_multifocal integer null default 10,
  prazo_surfacada integer null default 12,
  prazo_free_form integer null default 15,
  frete_config jsonb null default '{"tipo": "PAC", "taxa_fixa": 25, "valor_minimo": 0, "frete_gratis_acima": 500}'::jsonb,
  desconto_volume jsonb null default '{"5_unidades": 0.03, "10_unidades": 0.05, "20_unidades": 0.08}'::jsonb,
  ativo boolean not null default true,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  deleted_at timestamp with time zone null,
  constraint fornecedores_pkey primary key (id),
  constraint fornecedores_cnpj_key unique (cnpj)
) TABLESPACE pg_default;

create index IF not exists idx_fornecedores_cnpj on core.fornecedores using btree (cnpj) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_fornecedores_nome on core.fornecedores using btree (nome) TABLESPACE pg_default
where
  (ativo = true);

create trigger trg_fornecedores_updated_at BEFORE
update on core.fornecedores for EACH row
execute FUNCTION core.update_fornecedores_timestamp ();