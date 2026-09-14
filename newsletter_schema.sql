-- ============================================================
-- newsletter_drafts
-- Menyimpan state editor Fixed Income Newsletter (newsletter-editor.html)
-- sebagai satu dokumen JSON. Menggantikan penyimpanan lama di JSONBin.io.
--
-- Pola: satu baris per "slug" (default 'default'), kolom `data` (JSONB)
-- berisi seluruh objek `state` dari editor. Save = UPSERT, Load = SELECT.
-- ============================================================

CREATE TABLE IF NOT EXISTS newsletter_drafts (
  slug        TEXT PRIMARY KEY DEFAULT 'default',  -- identifier draft (satu editor = 'default')
  data        JSONB       NOT NULL,                -- seluruh state newsletter (JSON)
  updated_by  TEXT,                                -- username/nama terakhir yang menyimpan
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── RLS ──
-- Project ini memakai anon key di sisi client, jadi izinkan anon
-- membaca & menulis tabel ini (mirror pendekatan tabel lain di project).
ALTER TABLE newsletter_drafts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow anon read newsletter_drafts"   ON newsletter_drafts;
DROP POLICY IF EXISTS "Allow anon insert newsletter_drafts" ON newsletter_drafts;
DROP POLICY IF EXISTS "Allow anon update newsletter_drafts" ON newsletter_drafts;

CREATE POLICY "Allow anon read newsletter_drafts"
  ON newsletter_drafts FOR SELECT TO anon USING (true);

CREATE POLICY "Allow anon insert newsletter_drafts"
  ON newsletter_drafts FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Allow anon update newsletter_drafts"
  ON newsletter_drafts FOR UPDATE TO anon USING (true) WITH CHECK (true);
