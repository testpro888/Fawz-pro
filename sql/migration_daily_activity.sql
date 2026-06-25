-- ================================================
-- Migration: Daily Activity Report
-- Tabel: daily_activity_jobs & daily_activity_entries
-- ================================================

-- Tabel jobdesk
CREATE TABLE IF NOT EXISTS daily_activity_jobs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  start_date   DATE NOT NULL,
  description  TEXT,
  created_by   TEXT NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- Tabel entri progress per jobdesk
CREATE TABLE IF NOT EXISTS daily_activity_entries (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id       UUID NOT NULL REFERENCES daily_activity_jobs(id) ON DELETE CASCADE,
  entry_date   DATE NOT NULL,
  status       TEXT NOT NULL CHECK (status IN ('inprogress','pending','finished','cancelled','returned')),
  notes        TEXT,
  created_by   TEXT NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- Index untuk performa
CREATE INDEX IF NOT EXISTS idx_daj_created_by   ON daily_activity_jobs(created_by);
CREATE INDEX IF NOT EXISTS idx_daj_start_date   ON daily_activity_jobs(start_date);
CREATE INDEX IF NOT EXISTS idx_dae_job_id       ON daily_activity_entries(job_id);
CREATE INDEX IF NOT EXISTS idx_dae_entry_date   ON daily_activity_entries(entry_date);

-- Disable RLS (sesuaikan dengan kebijakan tim)


-- Atau aktifkan RLS + policy jika diperlukan:
-- ALTER TABLE daily_activity_jobs    ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE daily_activity_entries ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "allow_all" ON daily_activity_jobs    FOR ALL USING (true) WITH CHECK (true);
-- CREATE POLICY "allow_all" ON daily_activity_entries FOR ALL USING (true) WITH CHECK (true);
