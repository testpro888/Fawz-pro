-- Follow Up Customers table
-- Menyimpan data follow up nasabah (manual atau via CSV upload)

CREATE TABLE IF NOT EXISTS follow_up_customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT,
  name TEXT,
  client_id TEXT,
  rdn TEXT,
  amount NUMERIC,
  porto TEXT,
  total_nilai_porto NUMERIC,
  phone TEXT,
  address TEXT,
  status TEXT DEFAULT 'Process' CHECK (status IN ('Process', 'Success', 'Cancel')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index untuk pencarian
CREATE INDEX IF NOT EXISTS idx_followup_email ON follow_up_customers(email);
CREATE INDEX IF NOT EXISTS idx_followup_status ON follow_up_customers(status);
CREATE INDEX IF NOT EXISTS idx_followup_client_id ON follow_up_customers(client_id);

-- RLS: enable
ALTER TABLE follow_up_customers ENABLE ROW LEVEL SECURITY;

-- Policy: allow all for authenticated/anon (sesuai pattern project ini)
CREATE POLICY "Allow all access" ON follow_up_customers
  FOR ALL USING (true) WITH CHECK (true);
