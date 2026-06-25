-- ================================================
-- Fix: RLS Policy untuk tabel job_tasks
-- Jalankan di Supabase SQL Editor
-- ================================================

-- 1. Pastikan RLS dinonaktifkan (cara paling simpel untuk custom auth)
ALTER TABLE job_tasks DISABLE ROW LEVEL SECURITY;

-- === ATAU ===
-- Jika ingin tetap pakai RLS, gunakan ini sebagai gantinya:
-- (hapus baris DISABLE di atas, lalu jalankan ini)

-- ALTER TABLE job_tasks ENABLE ROW LEVEL SECURITY;

-- -- Hapus semua policy lama dulu (jika ada)
-- DROP POLICY IF EXISTS "allow_all"    ON job_tasks;
-- DROP POLICY IF EXISTS "allow_select" ON job_tasks;
-- DROP POLICY IF EXISTS "allow_insert" ON job_tasks;
-- DROP POLICY IF EXISTS "allow_update" ON job_tasks;
-- DROP POLICY IF EXISTS "allow_delete" ON job_tasks;

-- -- Buat policy baru yang izinkan semua operasi dari anon key
-- CREATE POLICY "allow_all" ON job_tasks
--   FOR ALL
--   TO anon, authenticated
--   USING (true)
--   WITH CHECK (true);

-- 2. Pastikan anon role punya akses ke tabel
GRANT ALL ON job_tasks TO anon;
GRANT ALL ON job_tasks TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
