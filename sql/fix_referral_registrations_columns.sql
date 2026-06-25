-- ============================================================
-- Fix: Tambah kolom untuk referral_registrations
-- Digunakan oleh halaman referral-landing.html
-- Jalankan di Supabase SQL Editor
-- ============================================================

DO $$
BEGIN
  -- Kode referral agent yang digunakan saat pendaftaran
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'referral_code'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN referral_code TEXT;
  END IF;

  -- UUID agent dari tabel referral_agents
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agent_id'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agent_id UUID;
  END IF;

  -- Nama agent (denormalized untuk kemudahan query)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agent_name'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agent_name TEXT;
  END IF;
END $$;

-- Index untuk filter berdasarkan referral code
CREATE INDEX IF NOT EXISTS idx_referral_reg_code
  ON public.referral_registrations (referral_code);

CREATE INDEX IF NOT EXISTS idx_referral_reg_agent_id
  ON public.referral_registrations (agent_id);

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';
