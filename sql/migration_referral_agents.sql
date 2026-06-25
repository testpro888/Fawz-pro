-- ============================================================
-- Migration: Referral Agents
-- Table: referral_agents
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- ── BUAT TABEL (jika belum ada) ────────────────────────────
CREATE TABLE IF NOT EXISTS public.referral_agents (
  id                 UUID         DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identitas agent (dari form publik referral-agent-regist.html)
  nama               TEXT,
  email              TEXT,
  phone              TEXT,
  domisili           TEXT,
  tanggal_lahir      DATE,
  pekerjaan          TEXT,
  lama_investasi     TEXT,

  -- Sekuritas & kode referral
  sekuritas          TEXT,
  agent_code         TEXT UNIQUE,
  referral_url       TEXT,

  -- Untuk agent yang sudah punya akun (isian admin)
  client_id          TEXT,
  client_name        TEXT,

  -- Status langganan
  status             TEXT NOT NULL DEFAULT 'Free'
                     CHECK (status IN ('Free', 'Premium')),
  durasi             INTEGER CHECK (durasi IN (1, 6, 12)),
  tgl_langganan      DATE,

  -- Target & komisi
  target_amount      NUMERIC DEFAULT 10000000,
  fee_below_pct      NUMERIC,   -- % fee di BAWAH target, NULL = pakai default sistem
  fee_above_pct      NUMERIC,   -- % fee di ATAS  target, NULL = pakai default sistem
  comm_bawah_custom  NUMERIC,   -- alias lama fee_below_pct (untuk backward compat)
  comm_atas_custom   NUMERIC,   -- alias lama fee_above_pct (untuk backward compat)

  created_at         TIMESTAMPTZ DEFAULT NOW(),
  updated_at         TIMESTAMPTZ DEFAULT NOW()
);

-- ── TAMBAH KOLOM YANG MUNGKIN BELUM ADA (jika tabel sudah exist) ──
DO $$
BEGIN
  -- Identitas
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='nama')           THEN ALTER TABLE public.referral_agents ADD COLUMN nama TEXT; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='email')          THEN ALTER TABLE public.referral_agents ADD COLUMN email TEXT; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='phone')          THEN ALTER TABLE public.referral_agents ADD COLUMN phone TEXT; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='domisili')       THEN ALTER TABLE public.referral_agents ADD COLUMN domisili TEXT; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='tanggal_lahir')  THEN ALTER TABLE public.referral_agents ADD COLUMN tanggal_lahir DATE; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='pekerjaan')      THEN ALTER TABLE public.referral_agents ADD COLUMN pekerjaan TEXT; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='lama_investasi') THEN ALTER TABLE public.referral_agents ADD COLUMN lama_investasi TEXT; END IF;

  -- Kode referral
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='agent_code')    THEN ALTER TABLE public.referral_agents ADD COLUMN agent_code TEXT; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='referral_url')   THEN ALTER TABLE public.referral_agents ADD COLUMN referral_url TEXT; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='sekuritas')      THEN ALTER TABLE public.referral_agents ADD COLUMN sekuritas TEXT; END IF;

  -- Admin fields
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='client_name')   THEN ALTER TABLE public.referral_agents ADD COLUMN client_name TEXT; END IF;

  -- Komisi baru
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='fee_below_pct') THEN ALTER TABLE public.referral_agents ADD COLUMN fee_below_pct NUMERIC; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='fee_above_pct') THEN ALTER TABLE public.referral_agents ADD COLUMN fee_above_pct NUMERIC; END IF;

  -- Kolom lama (backward compat)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='comm_bawah_custom') THEN ALTER TABLE public.referral_agents ADD COLUMN comm_bawah_custom NUMERIC; END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='referral_agents' AND column_name='comm_atas_custom')  THEN ALTER TABLE public.referral_agents ADD COLUMN comm_atas_custom  NUMERIC; END IF;
END $$;

-- ── UNIQUE INDEX agent_code ────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS idx_referral_agents_agent_code_unique
  ON public.referral_agents (agent_code)
  WHERE agent_code IS NOT NULL;

-- ── INDEX BIASA ────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_referral_agents_client_id ON public.referral_agents (client_id);
CREATE INDEX IF NOT EXISTS idx_referral_agents_email     ON public.referral_agents (email);
CREATE INDEX IF NOT EXISTS idx_referral_agents_created   ON public.referral_agents (created_at DESC);

-- ── AUTO-UPDATE updated_at ─────────────────────────────────
CREATE OR REPLACE FUNCTION update_referral_agents_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_referral_agents_updated_at ON public.referral_agents;
CREATE TRIGGER trg_referral_agents_updated_at
  BEFORE UPDATE ON public.referral_agents
  FOR EACH ROW EXECUTE FUNCTION update_referral_agents_updated_at();

-- ── RLS ────────────────────────────────────────────────────
ALTER TABLE public.referral_agents ENABLE ROW LEVEL SECURITY;

-- Izinkan anon INSERT (dari form publik)
DROP POLICY IF EXISTS "referral_agents_anon_insert" ON public.referral_agents;
CREATE POLICY "referral_agents_anon_insert"
  ON public.referral_agents FOR INSERT TO anon WITH CHECK (true);

-- Izinkan authenticated SELECT/UPDATE/DELETE (admin dashboard)
DROP POLICY IF EXISTS "referral_agents_auth_all" ON public.referral_agents;
CREATE POLICY "referral_agents_auth_all"
  ON public.referral_agents FOR ALL TO authenticated
  USING (true) WITH CHECK (true);

-- Izinkan anon SELECT (untuk cek kode referral dari halaman publik)
DROP POLICY IF EXISTS "referral_agents_anon_select" ON public.referral_agents;
CREATE POLICY "referral_agents_anon_select"
  ON public.referral_agents FOR SELECT TO anon USING (true);
