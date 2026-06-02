-- Migration: tambah kolom tanggal_listing, final_maturity, kupon_freq ke obligasi_products
-- Jalankan di Supabase SQL Editor

ALTER TABLE obligasi_products
  ADD COLUMN IF NOT EXISTS tanggal_listing DATE,
  ADD COLUMN IF NOT EXISTS final_maturity  DATE,
  ADD COLUMN IF NOT EXISTS kupon_freq      INTEGER; -- frekuensi kupon dalam bulan: 1, 3, 6, 12

COMMENT ON COLUMN obligasi_products.tanggal_listing IS 'Tanggal listing/terbit obligasi';
COMMENT ON COLUMN obligasi_products.final_maturity  IS 'Tanggal terakhir jatuh tempo (final maturity)';
COMMENT ON COLUMN obligasi_products.kupon_freq      IS 'Frekuensi pembayaran kupon dalam bulan (1/3/6/12)';
