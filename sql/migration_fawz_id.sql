-- Migration: Add fawz_id column to customers table
-- Fawz ID format: F + 6 digit random number (e.g., F123456)

ALTER TABLE customers ADD COLUMN IF NOT EXISTS fawz_id TEXT UNIQUE;

-- Create index for faster lookup
CREATE INDEX IF NOT EXISTS idx_customers_fawz_id ON customers(fawz_id);
