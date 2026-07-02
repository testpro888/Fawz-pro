-- ============================================================
-- Migration: Tambah kolom influencer_code di referral_registrations
-- Menyimpan kode influencer (opsional) yang diisi saat pendaftaran agen
-- Jalankan di Supabase SQL Editor
-- ============================================================

DO $$
BEGIN
  -- influencer_code: kode influencer yang mereferensikan pendaftar (opsional)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'referral_registrations'
      AND column_name  = 'influencer_code'
  ) THEN
    ALTER TABLE public.referral_registrations
      ADD COLUMN influencer_code TEXT;
  END IF;
END $$;

-- Index untuk query by influencer_code
CREATE INDEX IF NOT EXISTS idx_referral_reg_influencer_code
  ON public.referral_registrations (influencer_code)
  WHERE influencer_code IS NOT NULL;

-- Refresh schema cache Supabase
NOTIFY pgrst, 'reload schema';
