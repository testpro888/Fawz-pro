-- Migration: Add fawz_id column to customers table
-- Fawz ID format: F + 6 digit random number (e.g., F123456)
-- NOTE: fawz_id is NOT unique per row — customers with same base Client ID
-- (e.g., RW028Y and RW028N) will share the same Fawz ID

ALTER TABLE customers ADD COLUMN IF NOT EXISTS fawz_id TEXT;

-- Create index for faster lookup (not unique, karena bisa shared)
CREATE INDEX IF NOT EXISTS idx_customers_fawz_id ON customers(fawz_id);
