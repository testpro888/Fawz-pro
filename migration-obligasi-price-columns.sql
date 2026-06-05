-- Migration: Add harga_modal, modal_to_sales, harga_to_customer columns
-- Run this in Supabase SQL Editor

ALTER TABLE obligasi_products
  ADD COLUMN IF NOT EXISTS harga_modal        NUMERIC(12,4),
  ADD COLUMN IF NOT EXISTS modal_to_sales     NUMERIC(12,4),
  ADD COLUMN IF NOT EXISTS harga_to_customer  NUMERIC(12,4);
