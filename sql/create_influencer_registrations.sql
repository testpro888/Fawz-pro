-- ============================================================
-- Tabel: influencer_registrations
-- Untuk menyimpan data pendaftaran dari halaman influencer-register.html
-- Jalankan di Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.influencer_registrations (
  id          uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  nama        text    NOT NULL,
  email       text    NOT NULL,
  sekuritas   text    NOT NULL,   -- 'Maybank Sekuritas' | 'Trimegah Sekuritas'
  client_code text    NOT NULL,
  status      text    DEFAULT 'pending',  -- 'pending' | 'approved' | 'rejected'
  admin_note  text,                        -- catatan dari admin
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- Index untuk pencarian cepat
CREATE INDEX IF NOT EXISTS idx_influencer_reg_email   ON public.influencer_registrations (email);
CREATE INDEX IF NOT EXISTS idx_influencer_reg_status  ON public.influencer_registrations (status);
CREATE INDEX IF NOT EXISTS idx_influencer_reg_created ON public.influencer_registrations (created_at DESC);

-- RLS: aktifkan
ALTER TABLE public.influencer_registrations ENABLE ROW LEVEL SECURITY;

-- Siapapun (anon) boleh INSERT dari form publik
CREATE POLICY "allow_anon_insert" ON public.influencer_registrations
  FOR INSERT TO anon WITH CHECK (true);

-- Hanya authenticated (admin) yang bisa SELECT, UPDATE, DELETE
CREATE POLICY "allow_auth_all" ON public.influencer_registrations
  FOR ALL TO authenticated USING (true) WITH CHECK (true);
