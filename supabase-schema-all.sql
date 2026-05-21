-- ============================================================
-- FAWZ PRO — Supabase Schema Lengkap
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- DROP semua tabel (kecuali customers, sales, customer_securities yang sudah ada)
DROP TABLE IF EXISTS bb_recommendations CASCADE;
DROP TABLE IF EXISTS bb_orders CASCADE;
DROP TABLE IF EXISTS obligasi_products CASCADE;
DROP TABLE IF EXISTS ipo_obligasi CASCADE;
DROP TABLE IF EXISTS pasar_sekunder_orders CASCADE;
DROP TABLE IF EXISTS waran_orders CASCADE;
DROP TABLE IF EXISTS waran_terstruktur CASCADE;
DROP TABLE IF EXISTS reksadana_orders CASCADE;
DROP TABLE IF EXISTS reksadana_transactions CASCADE;
DROP TABLE IF EXISTS reksadana CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS sales_activities CASCADE;
DROP TABLE IF EXISTS leads CASCADE;
DROP TABLE IF EXISTS link_clicks CASCADE;
DROP TABLE IF EXISTS sales_commission_status CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;

-- ── 1. ACCOUNTS (profile/auth) ──────────────────────────────
CREATE TABLE IF NOT EXISTS accounts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT,
  username      TEXT UNIQUE NOT NULL,
  password      TEXT,
  role          TEXT DEFAULT 'sales',
  created_by    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- ── 2. OBLIGASI PASAR SEKUNDER (4 tabel digabung 1) ─────────
CREATE TABLE IF NOT EXISTS obligasi_products (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category       TEXT NOT NULL, -- 'gov-idr','gov-usd','korp-idr','korp-usd'
  seri           TEXT,
  kupon          NUMERIC,
  jatuh_tempo    TEXT,
  harga_jual     NUMERIC,
  harga_beli     NUMERIC,
  yield          NUMERIC,
  tanggal_update TEXT,
  other_comment  TEXT,
  other_comment_by TEXT,
  created_at     TIMESTAMPTZ DEFAULT now(),
  updated_at     TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_obligasi_products_category ON obligasi_products(category);

-- ── 3. BB ORDERS (Bookbuilding Obligasi) ────────────────────
CREATE TABLE IF NOT EXISTS bb_orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Jenis & Produk
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
  -- Harga
  harga_beli        NUMERIC,
  harga_jual        NUMERIC,
  harga_beli_sales  NUMERIC,
  harga_jual_sales  NUMERIC,
  harga_awal_beli   TEXT,
  ytm               NUMERIC,
  harga             TEXT,
  -- Nominal
  face_amount       NUMERIC,
  unit_amount       NUMERIC,
  deal_amount       NUMERIC,
  nominal           NUMERIC,
  kuota             TEXT,
  -- Nasabah
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
CREATE INDEX IF NOT EXISTS idx_bb_orders_client_id  ON bb_orders(client_id);
CREATE INDEX IF NOT EXISTS idx_bb_orders_status     ON bb_orders(status);

-- ── 4. BB RECOMMENDATIONS ────────────────────────────────────
CREATE TABLE IF NOT EXISTS bb_recommendations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ps_id         TEXT,           -- id produk obligasi
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

-- ── 5. IPO OBLIGASI ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ipo_obligasi (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seri            TEXT,
  penerbit        TEXT,
  kupon           NUMERIC,
  jatuh_tempo     TEXT,
  tanggal_ipo     TEXT,
  tanggal_selesai TEXT,
  min_pembelian   NUMERIC,
  satuan          NUMERIC,
  rating          TEXT,
  keterangan      TEXT,
  status          TEXT DEFAULT 'aktif',
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 6. PASAR SEKUNDER ORDERS ─────────────────────────────────
CREATE TABLE IF NOT EXISTS pasar_sekunder_orders (
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
  lot             NUMERIC,
  tipe            TEXT,   -- 'beli' / 'jual'
  settlement_date TEXT,
  status          TEXT DEFAULT 'pending',
  verified_by     TEXT,
  verified_at     TIMESTAMPTZ,
  notes           TEXT,
  created_by      TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 7. WARAN TERSTRUKTUR ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS waran_terstruktur (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode          TEXT UNIQUE,
  nama          TEXT,
  underlying    TEXT,
  tipe          TEXT,   -- 'call'/'put'
  strike_price  NUMERIC,
  exercise_date TEXT,
  rasio         NUMERIC,
  harga         NUMERIC,
  delta         NUMERIC,
  gearing       NUMERIC,
  penerbit      TEXT,
  keterangan    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ── 8. WARAN ORDERS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS waran_orders (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  waran_id      TEXT,
  kode          TEXT,
  nama          TEXT,
  underlying    TEXT,
  tipe          TEXT,
  harga         NUMERIC,
  nominal       NUMERIC,
  lot           NUMERIC,
  buyers        JSONB DEFAULT '[]',   -- [{name, nominal}]
  sales_name    TEXT,
  sales_code    TEXT,
  client_id     TEXT,
  client_name   TEXT,
  status        TEXT DEFAULT 'pending',
  notes         TEXT,
  created_by    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ── 9. REKSADANA PRODUK ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS reksadana (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nama            TEXT,
  manajer_investasi TEXT,
  kategori        TEXT,   -- 'Pasar Uang','Pendapatan Tetap','Campuran','Saham','Index','Syariah'
  nav             NUMERIC,
  nav_date        TEXT,
  return_1y       NUMERIC,
  return_ytd      NUMERIC,
  return_3y       NUMERIC,
  return_5y       NUMERIC,
  min_pembelian   NUMERIC,
  min_top_up      NUMERIC,
  kustodian       TEXT,
  keterangan      TEXT,
  status          TEXT DEFAULT 'aktif',
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 10. REKSADANA ORDERS ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS reksadana_orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id        TEXT,
  product_name      TEXT,
  kategori          TEXT,
  manajer_investasi TEXT,
  nav               NUMERIC,
  buyers            JSONB DEFAULT '[]',   -- [{name, nominal}]
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
CREATE INDEX IF NOT EXISTS idx_reksadana_orders_product ON reksadana_orders(product_id);
CREATE INDEX IF NOT EXISTS idx_reksadana_orders_sales   ON reksadana_orders(sales_name);

-- ── 11. REKSADANA TRANSACTIONS ───────────────────────────────
CREATE TABLE IF NOT EXISTS reksadana_transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reksadana_id    TEXT,
  nama_produk     TEXT,
  kategori        TEXT,
  nominal         NUMERIC,
  nav             NUMERIC,
  unit            NUMERIC,
  tipe            TEXT,   -- 'pembelian'/'penjualan'/'switching'
  client_id       TEXT,
  client_name     TEXT,
  sales_name      TEXT,
  sales_code      TEXT,
  office_name     TEXT,
  status          TEXT DEFAULT 'pending',
  verified_by     TEXT,
  verified_at     TIMESTAMPTZ,
  notes           TEXT,
  created_by      TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ── 12. TRANSACTIONS (sales-transaction) ─────────────────────
CREATE TABLE IF NOT EXISTS transactions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipe          TEXT,   -- 'obligasi','reksadana','saham','waran'
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

-- ── 13. SALES ACTIVITY ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS sales_activities (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date          TEXT,
  sales_name    TEXT,
  sales_code    TEXT,
  tipe          TEXT,   -- 'call','meeting','email','visit', dll
  client_name   TEXT,
  client_id     TEXT,
  keterangan    TEXT,
  hasil         TEXT,
  follow_up     TEXT,
  created_by    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ── 14. LEADS (sales-tracker) ────────────────────────────────
CREATE TABLE IF NOT EXISTS leads (
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

-- ── 15. LINK CLICKS (sales-tracker) ─────────────────────────
CREATE TABLE IF NOT EXISTS link_clicks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  url           TEXT,
  sales_name    TEXT,
  sales_code    TEXT,
  clicked_at    TIMESTAMPTZ DEFAULT now()
);

-- ── 16. SALES COMMISSION STATUS ──────────────────────────────
CREATE TABLE IF NOT EXISTS sales_commission_status (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id      TEXT UNIQUE,   -- id dari bb_orders / pasar_sekunder_orders / reksadana_transactions
  order_type    TEXT,          -- 'bb','sekunder','reksadana'
  paid          BOOLEAN DEFAULT false,
  paid_at       TIMESTAMPTZ,
  paid_by       TEXT,
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- RLS: Disable untuk development (aktifkan sesuai kebutuhan)
-- ============================================================
ALTER TABLE accounts                DISABLE ROW LEVEL SECURITY;
ALTER TABLE obligasi_products       DISABLE ROW LEVEL SECURITY;
ALTER TABLE bb_orders               DISABLE ROW LEVEL SECURITY;
ALTER TABLE bb_recommendations      DISABLE ROW LEVEL SECURITY;
ALTER TABLE ipo_obligasi            DISABLE ROW LEVEL SECURITY;
ALTER TABLE pasar_sekunder_orders   DISABLE ROW LEVEL SECURITY;
ALTER TABLE waran_terstruktur       DISABLE ROW LEVEL SECURITY;
ALTER TABLE waran_orders            DISABLE ROW LEVEL SECURITY;
ALTER TABLE reksadana               DISABLE ROW LEVEL SECURITY;
ALTER TABLE reksadana_orders        DISABLE ROW LEVEL SECURITY;
ALTER TABLE reksadana_transactions  DISABLE ROW LEVEL SECURITY;
ALTER TABLE transactions            DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales_activities        DISABLE ROW LEVEL SECURITY;
ALTER TABLE leads                   DISABLE ROW LEVEL SECURITY;
ALTER TABLE link_clicks             DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales_commission_status DISABLE ROW LEVEL SECURITY;
