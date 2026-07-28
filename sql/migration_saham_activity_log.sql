-- ============================================================
-- Migration: saham_activity_log
-- Mencatat semua aktivitas user di halaman Transaksi Saham:
--   tambah, edit, hapus, lihat detail, export CSV, bulk delete
-- ============================================================

create table if not exists public.saham_activity_log (
  id          bigserial primary key,
  created_at  timestamptz not null default now(),

  -- Siapa yang melakukan aksi
  username    text not null,           -- user.username
  user_name   text not null,           -- user.name (display name)
  user_role   text,                    -- user.role

  -- Aksi apa
  action      text not null,           -- 'tambah' | 'edit' | 'hapus' | 'detail' | 'export' | 'bulk_delete'

  -- Target transaksi (opsional untuk bulk / export)
  tx_id       text,                    -- saham_transaksi.id
  tx_tanggal  date,
  tx_client_id   text,
  tx_client_name text,
  tx_type     text,                    -- 'volume' | 'fee' | 'keduanya'
  tx_volume   numeric,
  tx_fee      numeric,

  -- Konteks tambahan
  notes       text                     -- misal: bulan yang dihapus, jumlah baris export, dll
);

-- Index untuk query history terbaru
create index if not exists idx_saham_activity_log_created_at
  on public.saham_activity_log (created_at desc);

create index if not exists idx_saham_activity_log_username
  on public.saham_activity_log (username);

-- RLS: semua user yang sudah login bisa insert; hanya head_account yg bisa select
alter table public.saham_activity_log enable row level security;

-- Insert: semua authenticated user
do $$ begin
  if not exists (
    select 1 from pg_policies
    where tablename = 'saham_activity_log' and policyname = 'saham_log_insert'
  ) then
    execute 'create policy "saham_log_insert" on public.saham_activity_log for insert to anon with check (true)';
  end if;
end $$;

-- Select: semua authenticated user (ditampilkan di UI, difilter per role di JS)
do $$ begin
  if not exists (
    select 1 from pg_policies
    where tablename = 'saham_activity_log' and policyname = 'saham_log_select'
  ) then
    execute 'create policy "saham_log_select" on public.saham_activity_log for select to anon using (true)';
  end if;
end $$;
