-- Tambah kolom untuk menyimpan data legacy dari Firebase
-- Jalankan ini di Supabase SQL Editor sebelum migrasi

-- Kolom untuk nama sales (karena sales_id di Firebase bukan UUID)
ALTER TABLE customers 
  ADD COLUMN IF NOT EXISTS sales_person_name TEXT,
  ADD COLUMN IF NOT EXISTS sales_person_id_legacy TEXT,
  ADD COLUMN IF NOT EXISTS office_id_legacy TEXT,
  ADD COLUMN IF NOT EXISTS department_id_legacy TEXT;

-- Update customer_securities yang sekuritas_name-nya kosong/null → set ke 'Maybank'
UPDATE customer_securities
SET sekuritas_name = 'Maybank'
WHERE sekuritas_name IS NULL OR sekuritas_name = '';

-- Hapus duplikat customer_securities (simpan hanya yang sort_order terkecil per customer)
DELETE FROM customer_securities
WHERE id NOT IN (
  SELECT DISTINCT ON (customer_id) id
  FROM customer_securities
  ORDER BY customer_id, sort_order ASC, id ASC
);

-- Verifikasi: cek customer yang punya lebih dari 1 securities
SELECT customer_id, COUNT(*) as jumlah
FROM customer_securities
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Verifikasi kolom berhasil ditambah
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'customers'
ORDER BY ordinal_position;
