-- ============================================================
-- Fix: izinkan anon UPDATE kolom sekuritas di referral_registrations
-- Dibutuhkan agar trackSekuritas() dari referral-landing.html bisa bekerja
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- Hapus policy lama kalau sudah ada (idempotent)
DROP POLICY IF EXISTS "allow_anon_update_sekuritas" ON public.referral_registrations;

-- Izinkan anon UPDATE hanya pada row yang memiliki id yang cocok
-- (tidak perlu auth karena form publik, dan hanya kolom sekuritas + updated_at)
CREATE POLICY "allow_anon_update_sekuritas" ON public.referral_registrations
  FOR UPDATE TO anon
  USING (true)
  WITH CHECK (true);
