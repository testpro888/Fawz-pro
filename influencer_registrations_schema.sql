-- Create influencer_registrations table
-- This table stores registration requests from influencers who register via pp.ikutin

CREATE TABLE IF NOT EXISTS influencer_registrations (
  id BIGSERIAL PRIMARY KEY,
  nama TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  sekuritas TEXT,
  client_code TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_influencer_registrations_status ON influencer_registrations(status);
CREATE INDEX IF NOT EXISTS idx_influencer_registrations_email ON influencer_registrations(email);
CREATE INDEX IF NOT EXISTS idx_influencer_registrations_created_at ON influencer_registrations(created_at DESC);

-- Add RLS (Row Level Security) policies if needed
-- ALTER TABLE influencer_registrations ENABLE ROW LEVEL SECURITY;

-- Example policy: allow authenticated users to read all registrations
-- CREATE POLICY "Allow authenticated users to read registrations" 
-- ON influencer_registrations FOR SELECT 
-- TO authenticated 
-- USING (true);

-- Example policy: allow authenticated users to insert and update
-- CREATE POLICY "Allow authenticated users to insert registrations" 
-- ON influencer_registrations FOR INSERT 
-- TO authenticated 
-- WITH CHECK (true);

-- CREATE POLICY "Allow authenticated users to update registrations" 
-- ON influencer_registrations FOR UPDATE 
-- TO authenticated 
-- USING (true);
