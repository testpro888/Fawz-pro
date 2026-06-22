-- ============================================================
-- Tabel: referral_registrations
-- Untuk menyimpan data pendaftaran dari halaman referral-agent-regist.html
-- ============================================================

CREATE TABLE IF NOT EXISTS public.referral_registrations (
  id                uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  nama              text,
  email             text,
  phone             text,
  sekuritas         text,           -- 'Maybank Sekuritas' | 'Trimegah Sekuritas' | 'RHB Sekuritas'
  client_code       text,           -- kode client / SID (nullable jika belum punya akun)
  status            text DEFAULT 'sudah_terdaftar', -- 'sudah_terdaftar' | 'belum_terdaftar'
  confirmed_status  text DEFAULT 'pending',         -- 'pending' | 'confirmed' | 'rejected'
  admin_note        text,           -- catatan dari admin saat konfirmasi/tolak
  created_at        timestamptz DEFAULT now(),
  updated_at        timestamptz DEFAULT now()
);

-- Index untuk pencarian cepat
CREATE INDEX IF NOT EXISTS idx_referral_reg_email    ON public.referral_registrations (email);
CREATE INDEX IF NOT EXISTS idx_referral_reg_status   ON public.referral_registrations (confirmed_status);
CREATE INDEX IF NOT EXISTS idx_referral_reg_created  ON public.referral_registrations (created_at DESC);

-- RLS: aktifkan agar aman
ALTER TABLE public.referral_registrations ENABLE ROW LEVEL SECURITY;

-- Policy: siapapun (anon) boleh INSERT (dari form publik)
CREATE POLICY "allow_anon_insert" ON public.referral_registrations
  FOR INSERT TO anon WITH CHECK (true);

-- Policy: hanya authenticated user yang bisa SELECT & UPDATE (admin dashboard)
CREATE POLICY "allow_auth_select" ON public.referral_registrations
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "allow_auth_update" ON public.referral_registrations
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- Policy: anon juga boleh SELECT (untuk halaman publik yang baca status sendiri)
-- Hapus baris ini jika tidak diperlukan
CREATE POLICY "allow_anon_select" ON public.referral_registrations
  FOR SELECT TO anon USING (true);
