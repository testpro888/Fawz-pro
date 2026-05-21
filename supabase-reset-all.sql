-- ============================================================
-- FAWZ PRO — RESET & REBUILD SEMUA TABEL
-- Jalankan di Supabase SQL Editor
-- PERINGATAN: Semua data akan DIHAPUS!
-- ============================================================

-- DROP semua tabel (urutan penting karena FK)
DROP TABLE IF EXISTS saham_transaksi CASCADE;
DROP TABLE IF EXISTS bb_recommendations CASCADE;
DROP TABLE IF EXISTS bb_orders CASCADE;
DROP TABLE IF EXISTS pasar_sekunder_orders CASCADE;
DROP TABLE IF EXISTS reksadana_orders CASCADE;
DROP TABLE IF EXISTS reksadana_transactions CASCADE;
DROP TABLE IF EXISTS waran_orders CASCADE;
DROP TABLE IF EXISTS sales_activities CASCADE;
DROP TABLE IF EXISTS sales_commission_status CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS leads CASCADE;
DROP TABLE IF EXISTS link_clicks CASCADE;
DROP TABLE IF EXISTS customer_securities CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS obligasi_products CASCADE;
DROP TABLE IF EXISTS ipo_obligasi CASCADE;
DROP TABLE IF EXISTS reksadana CASCADE;
DROP TABLE IF EXISTS waran_terstruktur CASCADE;

-- ============================================================
-- 1. ACCOUNTS (login & user management)
-- ============================================================
CREATE TABLE accounts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  username    TEXT UNIQUE NOT NULL,
  password    TEXT NOT NULL,
  role        TEXT NOT NULL DEFAULT 'sales',
  created_by  TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Insert default head account
INSERT INTO accounts (name, username, password, role) 
VALUES ('Muhammad Razaq Arafi', 'fawzheadaccount', 'fawz12345', 'head_account');

-- ============================================================
-- 2. SALES (data sales/marketing)
-- ============================================================
CREATE TABLE sales (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode            TEXT UNIQUE NOT NULL,
  nama            TEXT NOT NULL,
  tipe            TEXT,
  status          TEXT,
  hp              TEXT,
  email           TEXT,
  kota            TEXT,
  npwp            TEXT,
  nik             TEXT,
  rekening        TEXT,
  bank            TEXT,
  nama_rekening   TEXT,
  passing_grade   NUMERIC,
  foto_diri_url   TEXT,
  foto_ktp_url    TEXT,
  foto_selfie_url TEXT,
  foto_tabungan_url TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 3. CUSTOMERS (nasabah)
-- ============================================================
CREATE TABLE customers (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id                 TEXT UNIQUE,
  client_name               TEXT NOT NULL,
  birth_date                DATE,
  ktp_number                TEXT,
  npwp                      TEXT,
  email                     TEXT,
  phone                     TEXT,
  occupation                TEXT,
  company_name              TEXT,
  nature_of_business        TEXT,
  position                  TEXT,
  address                   TEXT,
  ksei_single_id            TEXT,
  ksei_sub_account_no       TEXT,
  kpei_sub_account_no       TEXT,
  stp_ksei_sub_account_no   TEXT,
  stp_kpei_sub_account_no   TEXT,
  -- Relasi ke sales (opsional, bisa null)
  sales_id                  UUID REFERENCES sales(id) ON DELETE SET NULL,
  sales_person_name         TEXT,
  sales_person_id_legacy    TEXT,
  office_id                 TEXT,
  office_id_legacy          TEXT,
  office_name               TEXT,
  department_id             TEXT,
  department_id_legacy      TEXT,
  client_status             TEXT DEFAULT 'Aktif',
  client_status_description TEXT,
  active_date               DATE,
  closed_date               DATE,
  created_at                TIMESTAMPTZ DEFAULT now(),
  updated_at                TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 4. CUSTOMER SECURITIES (rekening sekuritas per nasabah)
-- ============================================================
CREATE TABLE customer_securities (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id           UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  sekuritas_name        TEXT DEFAULT 'Maybank',
  rdn_bank_name         TEXT,
  rdn_account_no        TEXT,
  sec_client_id         TEXT,
  sid                   TEXT,
  personal_bank_name    TEXT,
  personal_account_no   TEXT,
  personal_account_name TEXT,
  sort_order            INTEGER DEFAULT 0
);
CREATE INDEX idx_custsec_customer ON customer_securities(customer_id);

-- ============================================================
-- 5. OBLIGASI PRODUCTS (pasar sekunder, 4 kategori dalam 1 tabel)
-- ============================================================
CREATE TABLE obligasi_products (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category         TEXT NOT NULL,  -- 'gov-idr','gov-usd','korp-idr','korp-usd'
  seri             TEXT,
  kupon            NUMERIC,
  jatuh_tempo      TEXT,
  harga_jual       NUMERIC,
  harga_beli       NUMERIC,
  yield            NUMERIC,
  tanggal_update   TEXT,
  other_comment    TEXT,
  other_comment_by TEXT,
  created_at       TIMESTAMPTZ DEFAULT now(),
  updated_at       TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_obligasi_category ON obligasi_products(category);

-- ============================================================
-- 6. BB ORDERS (order obligasi bookbuilding)
-- ============================================================
CREATE TABLE bb_orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  jenis_transaksi   TEXT DEFAULT 'Beli',
  category          TEXT,
  seri              TEXT,
  isin_code         TEXT,
  mata_uang         TEXT DEFAULT 'IDR',
  rating            TEXT,
  jenis_obligasi    TEXT,
  kupon             NUMERIC,
  jatuh_tempo       TEXT,
  kupon_terakhir    TEXT,
  kupon_berikut     TEXT,
  harga_beli        NUMERIC,
  harga_jual        NUMERIC,
  harga_beli_sales  NUMERIC,
  harga_jual_sales  NUMERIC,
  harga_awal_beli   TEXT,
  ytm               NUMERIC,
  harga             TEXT,
  face_amount       NUMERIC,
  unit_amount       NUMERIC,
  deal_amount       NUMERIC,
  nominal           NUMERIC,
  kuota             TEXT,
  -- Relasi nasabah (by client_id text, bukan FK)
  client_id         TEXT,
  customer_name     TEXT,
  ksei_sid          TEXT,
  sekuritas_dipakai TEXT,
  -- Sales
  sales_pic         TEXT,
  sales_code        TEXT,
  office_name       TEXT,
  -- Tanggal
  tanggal_order     TEXT,
  settlement        TEXT,
  -- Status
  status            TEXT DEFAULT 'pending',
  verified_by       TEXT,
  verified_at       TIMESTAMPTZ,
  rejected_reason   TEXT,
  -- Meta
  catatan           TEXT,
  created_by        TEXT,
  updated_by        TEXT,
  created_at        TIMESTAMPTZ DEFAULT now(),
  updated_at        TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_bb_orders_status ON bb_orders(status);
CREATE INDEX idx_bb_orders_client ON bb_orders(client_id);

-- ============================================================
-- 7. BB RECOMMENDATIONS (rekomendasi obligasi)
-- ============================================================
CREATE TABLE bb_recommendations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ps_id         TEXT,
  category      TEXT,
  seri          TEXT,
  kupon         NUMERIC,
  jatuh_tempo   TEXT,
  harga_jual    NUMERIC,
  harga_beli    NUMERIC,
  yield         NUMERIC,
  spread        NUMERIC,
  comment       TEXT,
  comment_by    TEXT,
  comment_at    TIMESTAMPTZ,
  added_by      TEXT,
  added_at      TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 8. IPO OBLIGASI
-- ============================================================
CREATE TABLE ipo_obligasi (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seri            TEXT,
  penerbit        TEXT,
  kupon           NUMERIC,
  tenor           NUMERIC,
  jatuh_tempo     TEXT,
  tanggal_ipo     TEXT,
  tanggal_selesai TEXT,
  min_pembelian   NUMERIC,
  target_dana     NUMERIC,
  rating          TEXT,
  keterangan      TEXT,
  status          TEXT DEFAULT 'open',
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 9. PASAR SEKUNDER ORDERS
-- ============================================================
CREATE TABLE pasar_sekunder_orders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category        TEXT,
  seri            TEXT,
  kupon           NUMERIC,
  jatuh_tempo     TEXT,
  harga           NUMERIC,
  yield           NUMERIC,
  client_id       TEXT,
  client_name     TEXT,
  sales_name      TEXT,
  sales_code      TEXT,
  office_name     TEXT,
  nominal         NUMERIC,
  tipe            TEXT,
  settlement_date TEXT,
  status          TEXT DEFAULT 'pending',
  verified_by     TEXT,
  verified_at     TIMESTAMPTZ,
  notes           TEXT,
  created_by      TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 10. REKSADANA (produk)
-- ============================================================
CREATE TABLE reksadana (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama              TEXT,
  manajer_investasi TEXT,
  kategori          TEXT,
  nav               NUMERIC,
  nav_date          TEXT,
  return_1y         NUMERIC,
  return_ytd        NUMERIC,
  return_3y         NUMERIC,
  return_5y         NUMERIC,
  min_pembelian     NUMERIC,
  subscription_fee  NUMERIC,
  redemption_fee    NUMERIC,
  management_fee    NUMERIC,
  kustodian         TEXT,
  keterangan        TEXT,
  status            TEXT DEFAULT 'aktif',
  created_at        TIMESTAMPTZ DEFAULT now(),
  updated_at        TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 11. REKSADANA ORDERS
-- ============================================================
CREATE TABLE reksadana_orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id        TEXT,
  product_name      TEXT,
  kategori          TEXT,
  manajer_investasi TEXT,
  nav               NUMERIC,
  buyers            JSONB DEFAULT '[]',
  total_nominal     NUMERIC,
  estimasi_unit     NUMERIC,
  buyer_count       INTEGER,
  notes             TEXT,
  sales_name        TEXT,
  sales_role        TEXT,
  status            TEXT DEFAULT 'pending',
  created_at        TIMESTAMPTZ DEFAULT now(),
  updated_at        TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 12. REKSADANA TRANSACTIONS
-- ============================================================
CREATE TABLE reksadana_transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reksadana_id    TEXT,
  nama_produk     TEXT,
  kategori        TEXT,
  nominal         NUMERIC,
  nav             NUMERIC,
  unit            NUMERIC,
  tipe            TEXT,
  client_id       TEXT,
  client_name     TEXT,
  sales_name      TEXT,
  sales_code      TEXT,
  office_name     TEXT,
  status          TEXT DEFAULT 'pending',
  notes           TEXT,
  created_by      TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 13. WARAN TERSTRUKTUR (produk)
-- ============================================================
CREATE TABLE waran_terstruktur (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode          TEXT UNIQUE,
  nama          TEXT,
  underlying    TEXT,
  tipe          TEXT,
  strike_price  NUMERIC,
  exercise_date TEXT,
  rasio         NUMERIC,
  harga         NUMERIC,
  delta         NUMERIC,
  gearing       NUMERIC,
  penerbit      TEXT,
  keterangan    TEXT,
  created_by    TEXT,
  created_role  TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 14. WARAN ORDERS
-- ============================================================
CREATE TABLE waran_orders (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  waran_id      TEXT,
  kode          TEXT,
  nama          TEXT,
  underlying    TEXT,
  tipe          TEXT,
  harga         NUMERIC,
  nominal       NUMERIC,
  total_nominal NUMERIC,
  buyers        JSONB DEFAULT '[]',
  sales_name    TEXT,
  sales_code    TEXT,
  sales_role    TEXT,
  client_id     TEXT,
  client_name   TEXT,
  status        TEXT DEFAULT 'pending',
  notes         TEXT,
  created_by    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 15. SAHAM TRANSAKSI (input harian: amount + fee per nasabah)
-- ============================================================
CREATE TABLE saham_transaksi (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tanggal       DATE NOT NULL DEFAULT CURRENT_DATE,
  client_id     TEXT NOT NULL,
  client_name   TEXT NOT NULL,
  volume        NUMERIC DEFAULT 0,   -- amount transaksi (Rp)
  fee           NUMERIC DEFAULT 0,   -- fee yang didapatkan (Rp)
  sales_name    TEXT,
  catatan       TEXT,
  created_by    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_saham_tanggal ON saham_transaksi(tanggal);
CREATE INDEX idx_saham_client  ON saham_transaksi(client_id);

-- ============================================================
-- 16. SALES ACTIVITIES
-- ============================================================
CREATE TABLE sales_activities (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date          TEXT,
  sales_name    TEXT,
  sales_code    TEXT,
  tipe          TEXT,
  client_name   TEXT,
  client_id     TEXT,
  keterangan    TEXT,
  hasil         TEXT,
  follow_up     TEXT,
  created_by    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 17. TRANSACTIONS (laporan transaksi umum)
-- ============================================================
CREATE TABLE transactions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipe          TEXT,
  produk        TEXT,
  nominal       NUMERIC,
  client_id     TEXT,
  client_name   TEXT,
  sales_name    TEXT,
  sales_code    TEXT,
  office_name   TEXT,
  status        TEXT DEFAULT 'pending',
  notes         TEXT,
  created_by    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 18. LEADS (sales tracker)
-- ============================================================
CREATE TABLE leads (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT,
  phone         TEXT,
  email         TEXT,
  source        TEXT,
  sales_name    TEXT,
  sales_code    TEXT,
  status        TEXT DEFAULT 'new',
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 19. LINK CLICKS (sales tracker)
-- ============================================================
CREATE TABLE link_clicks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  url           TEXT,
  sales_name    TEXT,
  sales_code    TEXT,
  clicked_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 20. SALES COMMISSION STATUS
-- ============================================================
CREATE TABLE sales_commission_status (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id      TEXT UNIQUE,
  order_type    TEXT,
  paid          BOOLEAN DEFAULT false,
  paid_at       TIMESTAMPTZ,
  paid_by       TEXT,
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- DISABLE RLS untuk semua tabel (development mode)
-- ============================================================
ALTER TABLE accounts DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales DISABLE ROW LEVEL SECURITY;
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE customer_securities DISABLE ROW LEVEL SECURITY;
ALTER TABLE obligasi_products DISABLE ROW LEVEL SECURITY;
ALTER TABLE bb_orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE bb_recommendations DISABLE ROW LEVEL SECURITY;
ALTER TABLE ipo_obligasi DISABLE ROW LEVEL SECURITY;
ALTER TABLE pasar_sekunder_orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE reksadana DISABLE ROW LEVEL SECURITY;
ALTER TABLE reksadana_orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE reksadana_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE waran_terstruktur DISABLE ROW LEVEL SECURITY;
ALTER TABLE waran_orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE saham_transaksi DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales_activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE leads DISABLE ROW LEVEL SECURITY;
ALTER TABLE link_clicks DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales_commission_status DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- DONE! Semua tabel siap digunakan.
-- Langkah selanjutnya: migrasi data dari Firebase via export-firebase-customers.html
-- ============================================================
