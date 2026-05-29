-- Migration: Add new columns to obligasi_products table
-- Fields: rating, last_coupon_date, next_coupon_date, due_date, penerbit

ALTER TABLE obligasi_products
ADD COLUMN IF NOT EXISTS rating TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS last_coupon_date TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS next_coupon_date TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS due_date TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS penerbit TEXT DEFAULT NULL;

-- Add comment for documentation
COMMENT ON COLUMN obligasi_products.rating IS 'Rating obligasi (hanya untuk korporasi), contoh: AAA, AA+, A, BBB+';
COMMENT ON COLUMN obligasi_products.last_coupon_date IS 'Tanggal kupon terakhir dibayarkan';
COMMENT ON COLUMN obligasi_products.next_coupon_date IS 'Tanggal kupon berikutnya';
COMMENT ON COLUMN obligasi_products.due_date IS 'Due date / tanggal jatuh tempo pembayaran';
COMMENT ON COLUMN obligasi_products.penerbit IS 'Nama penerbit obligasi (otomatis dari kode series untuk korporasi)';
