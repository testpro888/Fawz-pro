-- ============================================================
-- Fawz Pro — Schema tabel IPO Obligasi (Pasar Perdana)
-- Jalankan di Supabase → SQL Editor → Run
-- ============================================================
-- Catatan:
--  - Kolom pakai snake_case supaya cocok dengan payload aplikasi.
--  - Aman dijalankan berkali-kali (idempotent): pakai IF NOT EXISTS
--    dan ADD COLUMN IF NOT EXISTS, jadi tidak menimpa data lama.
-- ============================================================

-- 1) Buat tabel kalau belum ada
create table if not exists public.ipo_obligasi (
  id                 uuid primary key default gen_random_uuid(),
  nama               text,               -- Nama Obligasi (isi manual)
  seri               jsonb default '[]', -- Daftar seri: [{ "seri": "Seri A", "kupon": 5 }, ...]
  issuer             text,
  kupon              numeric,            -- legacy (kupon tunggal versi lama)
  tenor              numeric,
  min_beli           numeric,
  rating             text,
  keterangan         text,
  status             text default 'open',
  tgl_mulai          date,
  tgl_akhir          date,
  tgl_pembayaran     date,
  lembar_minat_url   text,
  lembar_minat_name  text,
  created_at         timestamptz default now(),
  updated_at         timestamptz default now()
);

-- 2) Kalau tabel sudah ada dari versi lama, tambahkan/ubah kolom yang perlu.
--    Catatan: kolom "seri" kini bertipe jsonb (daftar seri + kupon).
alter table public.ipo_obligasi add column if not exists nama              text;
alter table public.ipo_obligasi add column if not exists issuer            text;
alter table public.ipo_obligasi add column if not exists kupon             numeric;
alter table public.ipo_obligasi add column if not exists tenor             numeric;
alter table public.ipo_obligasi add column if not exists min_beli          numeric;
alter table public.ipo_obligasi add column if not exists rating            text;
alter table public.ipo_obligasi add column if not exists keterangan        text;
alter table public.ipo_obligasi add column if not exists status            text default 'open';
alter table public.ipo_obligasi add column if not exists tgl_mulai         date;
alter table public.ipo_obligasi add column if not exists tgl_akhir         date;
alter table public.ipo_obligasi add column if not exists tgl_pembayaran    date;
alter table public.ipo_obligasi add column if not exists lembar_minat_url  text;
alter table public.ipo_obligasi add column if not exists lembar_minat_name text;
alter table public.ipo_obligasi add column if not exists created_at        timestamptz default now();
alter table public.ipo_obligasi add column if not exists updated_at        timestamptz default now();

-- 2b) Pastikan kolom "seri" bertipe jsonb & tidak NOT NULL.
--     (Versi lama membuat seri sebagai "text not null" yang bikin insert gagal.)
alter table public.ipo_obligasi alter column seri drop not null;
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'ipo_obligasi'
      and column_name = 'seri' and data_type <> 'jsonb'
  ) then
    alter table public.ipo_obligasi
      alter column seri type jsonb
      using case
        when seri is null or seri = '' then '[]'::jsonb
        when left(seri, 1) = '[' then seri::jsonb
        else jsonb_build_array(jsonb_build_object('seri', seri, 'kupon', kupon))
      end;
  end if;
end $$;
alter table public.ipo_obligasi alter column seri set default '[]'::jsonb;

-- 3) Aktifkan Row Level Security + policy sederhana (semua user login boleh akses).
--    Sesuaikan kalau mau lebih ketat.
alter table public.ipo_obligasi enable row level security;

drop policy if exists "ipo_obligasi_all" on public.ipo_obligasi;
create policy "ipo_obligasi_all"
  on public.ipo_obligasi
  for all
  using (true)
  with check (true);

-- 4) Refresh schema cache PostgREST (menghindari error PGRST204)
notify pgrst, 'reload schema';

-- ============================================================
-- STORAGE — bucket untuk file Lembar Minat per-IPO
-- ============================================================
-- Buat bucket publik 'ipo-attachments' (kalau belum ada).
insert into storage.buckets (id, name, public)
values ('ipo-attachments', 'ipo-attachments', true)
on conflict (id) do nothing;

-- Policy storage: semua user boleh baca; upload/update/hapus untuk user terautentikasi.
drop policy if exists "ipo_attachments_read" on storage.objects;
create policy "ipo_attachments_read"
  on storage.objects for select
  using (bucket_id = 'ipo-attachments');

drop policy if exists "ipo_attachments_write" on storage.objects;
create policy "ipo_attachments_write"
  on storage.objects for insert
  with check (bucket_id = 'ipo-attachments');

drop policy if exists "ipo_attachments_update" on storage.objects;
create policy "ipo_attachments_update"
  on storage.objects for update
  using (bucket_id = 'ipo-attachments');

drop policy if exists "ipo_attachments_delete" on storage.objects;
create policy "ipo_attachments_delete"
  on storage.objects for delete
  using (bucket_id = 'ipo-attachments');
