-- ============================================================
-- Migration: referral_registrations — tambah field baru
-- Jalankan di Supabase SQL Editor
-- ============================================================

DO $$
BEGIN
  -- NIK (Nomor Induk Kependudukan)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'nik'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN nik TEXT;
  END IF;

  -- No RDN (hanya untuk yang sudah terdaftar)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'no_rdn'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN no_rdn TEXT;
  END IF;

  -- Kode Referral (dari agen)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'referral_code'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN referral_code TEXT;
  END IF;

  -- Kode Influencer (opsional)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'influencer_code'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN influencer_code TEXT;
  END IF;

  -- Persetujuan ketentuan (JSON array of checked items)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agreement_terms'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agreement_terms JSONB;
  END IF;

  -- Tanda tangan digital (nama lengkap yang diketik)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agreement_signature'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agreement_signature TEXT;
  END IF;

  -- Timestamp saat user menyetujui / tanda tangan
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agreement_timestamp'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agreement_timestamp TIMESTAMPTZ;
  END IF;

  -- Promosi opsional (apakah user centang promo)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'agree_promo'
  ) THEN
    ALTER TABLE public.referral_registrations ADD COLUMN agree_promo BOOLEAN DEFAULT FALSE;
  END IF;

END $$;

-- Index untuk pencarian berdasarkan NIK
CREATE INDEX IF NOT EXISTS idx_referral_reg_nik
  ON public.referral_registrations (nik);
