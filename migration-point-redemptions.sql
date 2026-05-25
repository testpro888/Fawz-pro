-- ============================================================
-- Migration: Tabel point_redemptions untuk sistem Fawz Point
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- Tabel untuk menyimpan riwayat penukaran point nasabah
CREATE TABLE IF NOT EXISTS point_redemptions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id       TEXT NOT NULL,
  client_name     TEXT NOT NULL,
  points_redeemed INTEGER NOT NULL CHECK (points_redeemed >= 1),
  redeemed_by     TEXT NOT NULL,
  redemption_date DATE NOT NULL DEFAULT CURRENT_DATE,
  catatan         TEXT,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- Index untuk pencarian berdasarkan client
CREATE INDEX IF NOT EXISTS idx_point_redemptions_client ON point_redemptions(client_id);

-- Index untuk pengurutan berdasarkan tanggal (terbaru dulu)
CREATE INDEX IF NOT EXISTS idx_point_redemptions_date ON point_redemptions(redemption_date DESC);

-- Disable RLS (sesuai pola existing)
ALTER TABLE point_redemptions DISABLE ROW LEVEL SECURITY;
