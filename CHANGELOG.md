# Changelog — Fawz Pro

Semua perubahan signifikan pada project ini didokumentasikan di sini.

---

## [v1.8] — 2026-07-21

### ✨ New Features

#### Brand Logo Page
- Halaman **Brand Logo** baru di menu Tools
- Upload dan kelola logo brand per kategori
- Kelola warna brand dan dokumentasi font

---

## [v1.7.1] — 2026-07-21

### 🐛 Bug Fixes & UI Polish
- **WA Float** — tombol WhatsApp kini hanya tampilkan ikon saat idle, teks "Contact Person" & nomor muncul saat hover
- **WA Float** — logo WA diperbaiki agar fit penuh di kontainer (full cover, tanpa double background hijau)
- **Changelog Modal** — layout diubah dari bottom sheet menjadi modal persegi di tengah layar dengan animasi scale
- **Dashboard** — versi Fawz Pro (v1.7) ditampilkan di bagian bawah dashboard dengan tombol ⓘ untuk membuka changelog

---

## [v1.7] — 2026-07-20

### ✨ New Features

#### Job Report — Link & File Attachment
- Setiap task di Job Report kini mendukung **link referensi** (URL bebas) dan **file attachment** (upload gambar/dokumen)
- File diupload ke Supabase Storage bucket `job-attachments` dan URL-nya tersimpan di kolom `attachment_url`
- Nama file asli ditampilkan di UI lewat kolom `attachment_name`
- Migration SQL tersedia di `sql/migration_job_tasks_attachments.sql`

#### Customer — Follow Up
- Tambah status **"Under Follow Up"** pada halaman Follow Up Customer
- Kolom `porto` dan `total_nilai_porto` ditambahkan ke tabel follow up
- Halaman Follow Up Customer diluncurkan dengan fitur CSV upload, CRUD, dan navbar menu

#### Customer — Data Enrichment
- Kolom **email** dan **phone** kini muncul di tabel Client Volume >100 Juta

### 🐛 Bug Fixes
- Paginated fetch diperbaiki agar bisa load data lebih dari 1.000 baris
- Support delimiter semicolon dan quoted fields saat import CSV
- Batch CSV import diperbaiki untuk performa lebih baik

---

## [v1.6] — Influencer & Referral System

### ✨ New Features
- Sistem **Influencer Registration** — form publik di `influencer-register.html`, approval workflow di `influencer.html`
- Tab **Request** dan **Influencer List** di halaman manajemen influencer
- Halaman **Influencer Fan** di bawah menu Sales
- Dashboard khusus influencer (`dashboard-influencer.html`)
- **Referral Agent** system dengan halaman dan dashboard terpisah
- Notifikasi badge merah pada avatar profil untuk job report & reply baru

### 🐛 Bug Fixes
- Auto-select sales dari data customer
- Fix link referral ke `pp.ikutin.id/referral-agent/register`

---

## [v1.5] — Job Report System

### ✨ New Features
- Sistem **Job Report** menggantikan Daily Activity Report
- Role-based visibility: admin/head_account bisa lihat semua user
- Fitur **reply/diskusi per task** dengan indikator unread
- Stats berdasarkan last status per job
- Tombol delete job, pending badge di navbar

---

## [v1.4] — Sales & Commission

### ✨ New Features
- **Sales Tracker** dengan deteksi referral code
- **Commission Report** dengan layout cetak A4
- **Log Commission** dan **Commission Settings**
- Halaman **Daily Activity** untuk input kegiatan harian

---

## [v1.3] — Saham Trading System

### ✨ New Features
- Kalender grid transaksi saham (volume & fee dipisah)
- **Rekap Bulanan** dengan tabel scrollable max 10 baris
- Upload CSV format kalender (`NO, CLIENT CODE, NAMA, SALES, 1-31, TOTAL`)
- Bulk delete per tipe per bulan
- Searchable client ID dengan autocomplete dropdown

---

## [v1.2] — Fawz Point & Bond

### ✨ New Features
- Sistem **Fawz Point** dengan redemption
- **Bond Calculator** dan **Bond Transaction**
- Ranking berubah menjadi Rekap Transaksi

---

## [v1.1] — Core CRM

### ✨ New Features
- Halaman **Customer** dengan CRUD dan filter
- Check membership via Petik Profit (`pp.ikutin.id`)
- Analytics dashboard
- Halaman 404 custom

---

## [v1.0] — Initial Release

- Migrasi dari Firebase ke **Supabase**
- Setup login, navbar, dashboard
- GitHub Actions deployment ke GitHub Pages
- Konfigurasi singleton Supabase via `config.js`
