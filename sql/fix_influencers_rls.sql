-- ============================================================
--  Fix RLS for influencers table
--  Jalankan di Supabase SQL Editor
-- ============================================================

-- Drop existing policies dulu
drop policy if exists "influencers_select" on public.influencers;
drop policy if exists "influencers_insert" on public.influencers;
drop policy if exists "influencers_update" on public.influencers;
drop policy if exists "influencers_delete" on public.influencers;

-- Allow anon + authenticated untuk semua operasi (sama seperti tabel lain di project ini)
create policy "influencers_select" on public.influencers
  for select using (true);

create policy "influencers_insert" on public.influencers
  for insert with check (true);

create policy "influencers_update" on public.influencers
  for update using (true);

create policy "influencers_delete" on public.influencers
  for delete using (true);
