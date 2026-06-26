-- ============================================================
-- Migration: referral_registrations
-- Tambah kolom yang dibutuhkan oleh referral-landing.html
-- Jalankan di Supabase SQL Editor
-- ============================================================

DO $$
BEGIN
  -- Kolom kode referral (dari input user)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'referral_code'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN referral_code TEXT;
  END IF;

  -- Kolom agent_id (FK ke referral_agents.id)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agent_id'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agent_id UUID;
  END IF;

  -- Kolom agent_name (snapshot nama agent saat registrasi)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agent_name'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agent_name TEXT;
  END IF;
END $$;

-- Index untuk filter by agent
CREATE INDEX IF NOT EXISTS idx_referral_reg_agent_id
  ON public.referral_registrations (agent_id);

CREATE INDEX IF NOT EXISTS idx_referral_reg_referral_code
  ON public.referral_registrations (referral_code);
