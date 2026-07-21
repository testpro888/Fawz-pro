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
  category      text NOT NULL CHECK (category IN ('primary','secondary','icon','monochrome','text')),
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

-- ── 3. ROW LEVEL SECURITY — TABLE ──
ALTER TABLE brand_logos  ENABLE ROW LEVEL SECURITY;
ALTER TABLE brand_palette ENABLE ROW LEVEL SECURITY;

-- Drop existing policies jika ada
DROP POLICY IF EXISTS "brand_logos_read_all"  ON brand_logos;
DROP POLICY IF EXISTS "brand_logos_write_all" ON brand_logos;
DROP POLICY IF EXISTS "brand_palette_read_all"  ON brand_palette;
DROP POLICY IF EXISTS "brand_palette_write_all" ON brand_palette;

-- Read & Write: izinkan semua (akses dikontrol di aplikasi via role check)
CREATE POLICY "brand_logos_read_all"  ON brand_logos  FOR SELECT USING (true);
CREATE POLICY "brand_logos_write_all" ON brand_logos  FOR ALL    USING (true) WITH CHECK (true);

CREATE POLICY "brand_palette_read_all"  ON brand_palette FOR SELECT USING (true);
CREATE POLICY "brand_palette_write_all" ON brand_palette FOR ALL    USING (true) WITH CHECK (true);

-- ── 4. STORAGE BUCKET — buat via Dashboard atau jalankan ini ──
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'brand-assets',
  'brand-assets',
  true,
  20971520,  -- 20 MB
  ARRAY['image/png','image/jpeg','image/svg+xml','image/webp','application/pdf',
        'application/postscript','application/illustrator']
)
ON CONFLICT (id) DO NOTHING;

-- ── 5. STORAGE RLS POLICIES ──
-- Drop existing
DROP POLICY IF EXISTS "brand_assets_select" ON storage.objects;
DROP POLICY IF EXISTS "brand_assets_insert" ON storage.objects;
DROP POLICY IF EXISTS "brand_assets_delete" ON storage.objects;

-- Semua orang bisa lihat (public bucket)
CREATE POLICY "brand_assets_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'brand-assets');

-- Semua authenticated / anon bisa upload (akses dikontrol di app)
CREATE POLICY "brand_assets_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'brand-assets');

-- Semua bisa delete (akses dikontrol di app)
CREATE POLICY "brand_assets_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'brand-assets');
