-- Migration: Add new columns to obligasi_products table
-- Run this in Supabase SQL Editor

ALTER TABLE obligasi_products
  ADD COLUMN IF NOT EXISTS bond_id          TEXT,
  ADD COLUMN IF NOT EXISTS name             TEXT,
  ADD COLUMN IF NOT EXISTS isin             TEXT,
  ADD COLUMN IF NOT EXISTS issuer           TEXT,
  ADD COLUMN IF NOT EXISTS bond_type        TEXT,
  ADD COLUMN IF NOT EXISTS bond_type2       TEXT,
  ADD COLUMN IF NOT EXISTS day_count_basis  TEXT,
  ADD COLUMN IF NOT EXISTS payment_type     TEXT,
  ADD COLUMN IF NOT EXISTS first_cpn_date   DATE,
  ADD COLUMN IF NOT EXISTS accrual_date     DATE,
  ADD COLUMN IF NOT EXISTS tanggal_listing  DATE,
  ADD COLUMN IF NOT EXISTS kupon_freq       INTEGER;

-- Fix seri dari bond_id untuk data yang sudah diimport
UPDATE obligasi_products
  SET seri = bond_id
  WHERE seri IS NULL AND bond_id IS NOT NULL;

-- Set category berdasarkan ISIN untuk data yang category-nya NULL
UPDATE obligasi_products SET category = CASE
  WHEN isin LIKE 'IDG%' OR isin LIKE 'IDP%' OR isin LIKE 'IDO%' OR isin LIKE 'IDQ%' THEN 'gov-idr'
  WHEN isin LIKE 'US%'  OR isin LIKE 'XS%'  THEN 'gov-usd'
  WHEN isin LIKE 'IDJ%' THEN 'korp-idr'
  ELSE 'korp-idr'
END WHERE category IS NULL;
