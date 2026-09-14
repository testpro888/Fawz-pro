-- ============================================================
-- Dealer Report (dealer-report.html)
-- Menyimpan data nasabah & transaksi trading untuk halaman Dealer Report.
-- Akses halaman dibatasi ke role 'admin' atau username 'fawzheadaccount'
-- (guard di sisi client). Di sisi DB memakai anon key seperti tabel lain.
--
-- Prefix `dealer_` dipakai agar tidak bentrok dengan tabel lain di project.
-- ============================================================

-- ── NASABAH ──
-- Client ID sebagai primary key (mis. 'CL001', 'M0085N', dst)
CREATE TABLE IF NOT EXISTS dealer_nasabah (
  id          TEXT PRIMARY KEY,          -- Client ID (uppercase)
  nama        TEXT        NOT NULL,       -- Nama lengkap nasabah
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── TRANSAKSI ──
-- id memakai epoch millis (Date.now()) yang digenerate di client
CREATE TABLE IF NOT EXISTS dealer_transaksi (
  id          BIGINT PRIMARY KEY,        -- Date.now() dari client
  tgl         DATE        NOT NULL,       -- tanggal order (YYYY-MM-DD)
  cid         TEXT        NOT NULL,       -- Client ID (relasi ke dealer_nasabah.id)
  nama        TEXT,                       -- snapshot nama nasabah
  kode        TEXT        NOT NULL,       -- kode saham (mis. BBCA)
  trx         TEXT        NOT NULL,       -- 'BUY' | 'SELL'
  qty         NUMERIC     NOT NULL,       -- jumlah lot
  harga       NUMERIC     NOT NULL,       -- harga per lembar (Rp)
  total       NUMERIC     NOT NULL,       -- qty * harga * 100 (Rp)
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT dealer_transaksi_cid_fkey
    FOREIGN KEY (cid) REFERENCES dealer_nasabah (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_dealer_transaksi_tgl ON dealer_transaksi (tgl);
CREATE INDEX IF NOT EXISTS idx_dealer_transaksi_cid ON dealer_transaksi (cid);

-- ── RLS ──
-- Project memakai anon key di client, jadi izinkan anon read/write
-- (mirror pendekatan tabel lain di project).
ALTER TABLE dealer_nasabah   ENABLE ROW LEVEL SECURITY;
ALTER TABLE dealer_transaksi ENABLE ROW LEVEL SECURITY;

-- dealer_nasabah
DROP POLICY IF EXISTS "Allow anon read dealer_nasabah"   ON dealer_nasabah;
DROP POLICY IF EXISTS "Allow anon insert dealer_nasabah" ON dealer_nasabah;
DROP POLICY IF EXISTS "Allow anon update dealer_nasabah" ON dealer_nasabah;
DROP POLICY IF EXISTS "Allow anon delete dealer_nasabah" ON dealer_nasabah;

CREATE POLICY "Allow anon read dealer_nasabah"
  ON dealer_nasabah FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anon insert dealer_nasabah"
  ON dealer_nasabah FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Allow anon update dealer_nasabah"
  ON dealer_nasabah FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon delete dealer_nasabah"
  ON dealer_nasabah FOR DELETE TO anon USING (true);

-- dealer_transaksi
DROP POLICY IF EXISTS "Allow anon read dealer_transaksi"   ON dealer_transaksi;
DROP POLICY IF EXISTS "Allow anon insert dealer_transaksi" ON dealer_transaksi;
DROP POLICY IF EXISTS "Allow anon update dealer_transaksi" ON dealer_transaksi;
DROP POLICY IF EXISTS "Allow anon delete dealer_transaksi" ON dealer_transaksi;

CREATE POLICY "Allow anon read dealer_transaksi"
  ON dealer_transaksi FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anon insert dealer_transaksi"
  ON dealer_transaksi FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Allow anon update dealer_transaksi"
  ON dealer_transaksi FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon delete dealer_transaksi"
  ON dealer_transaksi FOR DELETE TO anon USING (true);
