-- Tabel transaksi saham harian (sederhana: volume + fee per nasabah)
DROP TABLE IF EXISTS saham_transaksi CASCADE;
CREATE TABLE IF NOT EXISTS saham_transaksi (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tanggal         DATE NOT NULL DEFAULT CURRENT_DATE,
  client_id       TEXT NOT NULL,
  client_name     TEXT NOT NULL,
  volume          NUMERIC DEFAULT 0,    -- amount transaksi (Rp)
  fee             NUMERIC DEFAULT 0,    -- fee yang didapatkan (Rp)
  sales_name      TEXT,
  catatan         TEXT,
  created_by      TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_saham_transaksi_tanggal ON saham_transaksi(tanggal);
CREATE INDEX IF NOT EXISTS idx_saham_transaksi_client  ON saham_transaksi(client_id);

ALTER TABLE saham_transaksi DISABLE ROW LEVEL SECURITY;
