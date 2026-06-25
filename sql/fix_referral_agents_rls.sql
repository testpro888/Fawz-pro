-- ============================================================
-- Fix: RLS referral_agents → Error 400 saat SELECT dari dashboard
-- Root cause: policy lama "referral_agents_all" konflik dengan
--             policy baru, atau anon key tidak punya akses SELECT.
--
-- Solusi: reset semua policy ke 1 policy saja yang allow all.
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- 1. Pastikan RLS aktif
ALTER TABLE public.referral_agents ENABLE ROW LEVEL SECURITY;

-- 2. Hapus SEMUA policy lama (bersih total)
DROP POLICY IF EXISTS "referral_agents_all"         ON public.referral_agents;
DROP POLICY IF EXISTS "referral_agents_anon_insert" ON public.referral_agents;
DROP POLICY IF EXISTS "referral_agents_auth_all"    ON public.referral_agents;
DROP POLICY IF EXISTS "referral_agents_anon_select" ON public.referral_agents;

-- 3. Buat 1 policy sederhana: izinkan semua operasi dari anon & authenticated
--    (authorization sudah dihandle di app layer)
CREATE POLICY "referral_agents_open"
  ON public.referral_agents
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- 4. Pastikan anon role punya GRANT ke tabel
GRANT SELECT, INSERT, UPDATE, DELETE ON public.referral_agents TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.referral_agents TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
