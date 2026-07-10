-- ============================================================
-- Migration: Tambah kolom confirmed_status di register_landing
-- Untuk menyimpan status lead (pending/registered/cancel)
-- Jalankan di Supabase SQL Editor
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'register_landing'
      AND column_name  = 'confirmed_status'
  ) THEN
    ALTER TABLE public.register_landing
      ADD COLUMN confirmed_status TEXT DEFAULT 'pending';
  END IF;
END $$;

-- Index untuk filter berdasarkan status
CREATE INDEX IF NOT EXISTS idx_register_landing_status
  ON public.register_landing (confirmed_status);

-- Policy: izinkan anon UPDATE status (jika belum ada policy UPDATE untuk anon)
-- Hapus/sesuaikan jika sudah ada policy yang mengcover
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'register_landing'
      AND policyname = 'allow_anon_update_status'
  ) THEN
    EXECUTE 'CREATE POLICY "allow_anon_update_status" ON public.register_landing FOR UPDATE TO anon USING (true) WITH CHECK (true)';
  END IF;
END $$;
