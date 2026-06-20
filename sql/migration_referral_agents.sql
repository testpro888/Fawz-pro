-- ============================================================
-- Migration: Referral Agents (Petik Profit)
-- Table: referral_agents
-- Jalankan di Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.referral_agents (
  id                 UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id          TEXT NOT NULL,
  client_name        TEXT,
  status             TEXT NOT NULL DEFAULT 'Free' CHECK (status IN ('Free','Premium')),
  durasi             INTEGER CHECK (durasi IN (1,6,12)),   -- NULL untuk Free
  tgl_langganan      DATE,
  target_amount      NUMERIC DEFAULT 10000000,
  comm_bawah_custom  NUMERIC,    -- NULL = pakai default
  comm_atas_custom   NUMERIC,    -- NULL = pakai default
  created_at         TIMESTAMPTZ DEFAULT NOW(),
  updated_at         TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX IF NOT EXISTS idx_referral_agents_client_id ON public.referral_agents(client_id);

-- Auto-update updated_at
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

-- RLS: aktifkan, izinkan semua operasi (anon key)
ALTER TABLE public.referral_agents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "referral_agents_all" ON public.referral_agents;
CREATE POLICY "referral_agents_all"
  ON public.referral_agents
  FOR ALL
  USING (true)
  WITH CHECK (true);
