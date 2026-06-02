-- Migration: tambah kolom bonds_status ke bb_orders
-- Jalankan di Supabase SQL Editor

ALTER TABLE bb_orders
  ADD COLUMN IF NOT EXISTS bonds_status TEXT DEFAULT 'pending' CHECK (bonds_status IN ('pending','succeed','cancel')),
  ADD COLUMN IF NOT EXISTS bonds_updated_by TEXT,
  ADD COLUMN IF NOT EXISTS bonds_updated_at TIMESTAMPTZ;

-- Update existing verified orders yang belum punya bonds_status
UPDATE bb_orders
SET bonds_status = 'pending'
WHERE status = 'verified' AND bonds_status IS NULL;

COMMENT ON COLUMN bb_orders.bonds_status IS 'Status eksekusi obligasi: pending, succeed, cancel. Diisi setelah order di-approve.';
