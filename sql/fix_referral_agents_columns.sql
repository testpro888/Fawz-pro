-- ============================================================
-- Fix: Tambah kolom yang hilang di tabel referral_agents
-- Kolom: fee_status, target_fee, fee_target_pct
-- Jalankan di Supabase SQL Editor
-- ============================================================

DO $$
BEGIN
  -- fee_status: 'free' | 'premium'
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_agents'
      AND column_name  = 'fee_status'
  ) THEN
    ALTER TABLE public.referral_agents
      ADD COLUMN fee_status TEXT DEFAULT 'free'
      CHECK (fee_status IN ('free', 'premium'));
  END IF;

  -- target_fee: nominal target transaksi (Rp)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_agents'
      AND column_name  = 'target_fee'
  ) THEN
    ALTER TABLE public.referral_agents
      ADD COLUMN target_fee NUMERIC DEFAULT 10000000;
  END IF;

  -- fee_target_pct: % fee ON target (di atas target)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_agents'
      AND column_name  = 'fee_target_pct'
  ) THEN
    ALTER TABLE public.referral_agents
      ADD COLUMN fee_target_pct NUMERIC;
  END IF;

  -- influencer: kolom untuk data influencer (reserved, belum dipakai)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_agents'
      AND column_name  = 'influencer'
  ) THEN
    ALTER TABLE public.referral_agents
      ADD COLUMN influencer TEXT;
  END IF;
END $$;

-- Refresh schema cache Supabase (jalankan ini terakhir)
NOTIFY pgrst, 'reload schema';
