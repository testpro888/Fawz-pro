-- Migration: Add new columns to obligasi_products table
-- Run this in Supabase SQL Editor

ALTER TABLE obligasi_products
  ADD COLUMN IF NOT EXISTS bond_id         TEXT,
  ADD COLUMN IF NOT EXISTS name            TEXT,
  ADD COLUMN IF NOT EXISTS isin            TEXT,
  ADD COLUMN IF NOT EXISTS issuer          TEXT,
  ADD COLUMN IF NOT EXISTS bond_type       TEXT,
  ADD COLUMN IF NOT EXISTS bond_type2      TEXT,
  ADD COLUMN IF NOT EXISTS day_count_basis TEXT,
  ADD COLUMN IF NOT EXISTS payment_type    TEXT,
  ADD COLUMN IF NOT EXISTS first_cpn_date  DATE,
  ADD COLUMN IF NOT EXISTS accrual_date    DATE;
