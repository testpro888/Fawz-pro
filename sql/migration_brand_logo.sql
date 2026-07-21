-- ============================================================
-- Migration: Brand Logo & Palette
-- Dibuat: 2026-07-21
-- Tabel: brand_logos, brand_palette
-- Storage bucket: brand-assets
-- ============================================================

-- ── 1. BRAND LOGOS ──
CREATE TABLE IF NOT EXISTS brand_logos (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  category      text NOT NULL CHECK (category IN ('primary','secondary','icon','monochrome')),
  format        text NOT NULL,
  file_path     text NOT NULL,
  file_url      text NOT NULL,
  bg_color      text NOT NULL DEFAULT '#ffffff',
  bg_label      text NOT NULL DEFAULT 'Putih',
  uploaded_by   text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- Index untuk filter per kategori
CREATE INDEX IF NOT EXISTS idx_brand_logos_category ON brand_logos (category);

-- ── 2. BRAND PALETTE ──
CREATE TABLE IF NOT EXISTS brand_palette (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  color_name    text NOT NULL,
  color_hex     text NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- ── 3. ROW LEVEL SECURITY ──
ALTER TABLE brand_logos  ENABLE ROW LEVEL SECURITY;
ALTER TABLE brand_palette ENABLE ROW LEVEL SECURITY;

-- Read: semua authenticated user bisa lihat
CREATE POLICY "brand_logos_read_all" ON brand_logos
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "brand_palette_read_all" ON brand_palette
  FOR SELECT USING (auth.role() = 'authenticated');

-- Write: hanya anon key (semua request dari app) — akses dikontrol di aplikasi
-- Kalau mau strict: ganti dengan check via metadata / service role
CREATE POLICY "brand_logos_write_all" ON brand_logos
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "brand_palette_write_all" ON brand_palette
  FOR ALL USING (true) WITH CHECK (true);

-- ── 4. STORAGE BUCKET ──
-- Jalankan via Supabase Dashboard → Storage → New bucket: "brand-assets" (public)
-- Atau via SQL:
-- INSERT INTO storage.buckets (id, name, public) VALUES ('brand-assets', 'brand-assets', true)
-- ON CONFLICT (id) DO NOTHING;
