-- ============================================================
--  Tabel: influencers
--  Daftar client yang menjadi influencer Fawz Pro
--  Jalankan di Supabase SQL Editor
-- ============================================================

create table if not exists public.influencers (
  id            bigserial primary key,
  client_id     text,                    -- Client ID dari tabel customers
  nama          text not null,
  email         text,
  phone         text,
  fans          bigint default null,     -- Jumlah followers/fans
  client_count  int    default null,     -- Jumlah client yang direferral influencer
  revenue       numeric default null,   -- Revenue (perhitungan menyusul)
  note          text   default null,    -- Catatan / platform / niche
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- Index untuk pencarian cepat
create index if not exists influencers_client_id_idx on public.influencers (client_id);
create index if not exists influencers_nama_idx      on public.influencers using gin (to_tsvector('simple', nama));

-- RLS
alter table public.influencers enable row level security;

-- Policy: authenticated users (admin/sales) bisa baca & tulis
create policy "influencers_select" on public.influencers
  for select using (auth.role() = 'authenticated' or auth.role() = 'anon');

create policy "influencers_insert" on public.influencers
  for insert with check (auth.role() = 'authenticated');

create policy "influencers_update" on public.influencers
  for update using (auth.role() = 'authenticated');

create policy "influencers_delete" on public.influencers
  for delete using (auth.role() = 'authenticated');

-- Trigger updated_at
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists trg_influencers_updated_at on public.influencers;
create trigger trg_influencers_updated_at
  before update on public.influencers
  for each row execute function public.set_updated_at();
