-- ================================================
-- Migration: Job Report
-- Menggantikan Daily Activity Report
-- Tabel: job_tasks
-- ================================================

-- Tabel utama task
CREATE TABLE IF NOT EXISTS job_tasks (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  description     TEXT,
  assigned_role   TEXT NOT NULL,                   -- role tujuan task
  assigned_to     TEXT,                            -- username spesifik (opsional)
  created_by      TEXT NOT NULL,                   -- username pembuat
  created_role    TEXT NOT NULL,                   -- role pembuat
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','done')),
  priority        TEXT NOT NULL DEFAULT 'normal'
                    CHECK (priority IN ('low','normal','high','urgent')),
  due_date        DATE,
  created_at      TIMESTAMPTZ DEFAULT now(),
  assigned_at     TIMESTAMPTZ DEFAULT now(),
  done_at         TIMESTAMPTZ,
  done_by         TEXT,                            -- username yang acc done
  notes           TEXT,                            -- catatan saat acc done
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- Index performa
CREATE INDEX IF NOT EXISTS idx_jt_assigned_role ON job_tasks(assigned_role);
CREATE INDEX IF NOT EXISTS idx_jt_assigned_to   ON job_tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_jt_created_by    ON job_tasks(created_by);
CREATE INDEX IF NOT EXISTS idx_jt_status        ON job_tasks(status);
CREATE INDEX IF NOT EXISTS idx_jt_created_at    ON job_tasks(created_at);

-- Disable RLS (sesuaikan dengan kebijakan tim)
-- Atau aktifkan:
-- ALTER TABLE job_tasks ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "allow_all" ON job_tasks FOR ALL USING (true) WITH CHECK (true);
