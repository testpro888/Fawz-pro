-- ================================================
-- Migration: Job Task Replies
-- Tabel untuk fitur diskusi/reply per task
-- ================================================

CREATE TABLE IF NOT EXISTS job_task_replies (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id      UUID NOT NULL REFERENCES job_tasks(id) ON DELETE CASCADE,
  body         TEXT NOT NULL,
  created_by   TEXT NOT NULL,   -- username
  created_role TEXT NOT NULL,   -- role saat kirim
  created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_jtr_task_id    ON job_task_replies(task_id);
CREATE INDEX IF NOT EXISTS idx_jtr_created_by ON job_task_replies(created_by);
CREATE INDEX IF NOT EXISTS idx_jtr_created_at ON job_task_replies(created_at);

-- Nonaktifkan RLS (custom auth, sama seperti job_tasks)
ALTER TABLE job_task_replies DISABLE ROW LEVEL SECURITY;

GRANT ALL ON job_task_replies TO anon;
GRANT ALL ON job_task_replies TO authenticated;
