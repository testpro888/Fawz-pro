-- ================================================
-- Migration: Job Tasks — Attachment & Link Support
-- Menambah kolom attachment dan link referensi
-- pada tabel job_tasks
-- ================================================

-- Kolom link referensi (URL teks bebas)
ALTER TABLE job_tasks
  ADD COLUMN IF NOT EXISTS link_ref TEXT;

-- Kolom URL file/gambar (setelah upload ke Supabase Storage)
ALTER TABLE job_tasks
  ADD COLUMN IF NOT EXISTS attachment_url TEXT;

-- Nama file asli untuk ditampilkan di UI
ALTER TABLE job_tasks
  ADD COLUMN IF NOT EXISTS attachment_name TEXT;

-- ================================================
-- Supabase Storage: buat bucket "job-attachments"
-- Jalankan di Supabase Dashboard → Storage → New Bucket
-- Nama: job-attachments
-- Public: true  (agar URL bisa diakses langsung)
-- ================================================

-- Storage policy: izinkan upload oleh semua user authenticated/anon
-- (sesuai pola project ini yang pakai anon key)
-- Buat policy ini di Supabase Dashboard → Storage → job-attachments → Policies
-- Atau jalankan SQL berikut:

INSERT INTO storage.buckets (id, name, public)
VALUES ('job-attachments', 'job-attachments', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "job_attachments_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'job-attachments');

CREATE POLICY "job_attachments_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'job-attachments');

CREATE POLICY "job_attachments_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'job-attachments');
