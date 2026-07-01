-- Update referral agent codes yang masih pakai format lama (mengandung '-REF')
-- Format baru: PP + inisial 2 kata pertama nama + 2 angka random
-- Jalankan query ini di Supabase SQL Editor

-- 1. Lihat dulu agent mana yang masih pakai format lama
SELECT id, nama, client_id, agent_code
FROM referral_agents
WHERE agent_code LIKE '%-REF' OR agent_code = client_id;

-- 2. Update satu per satu dengan kode baru sesuai nama
--    Contoh: Muhammad Razaq Arafi → PPMR + 2 angka random
--    Sesuaikan kode di bawah dengan nama yang ada

UPDATE referral_agents
SET agent_code = 'PPMR' || LPAD(FLOOR(RANDOM() * 100)::TEXT, 2, '0')
WHERE agent_code = 'MR028N-REF'
  AND nama ILIKE 'Muhammad Razaq%';

-- Jika ada agent lain dengan format lama, tambahkan UPDATE serupa di sini
-- Format: PP + huruf pertama kata 1 + huruf pertama kata 2 + 2 digit random
-- Jika hanya 1 kata nama: PP + huruf pertama + 0 + 2 digit random
