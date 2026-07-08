# Update Influencer Management System

## Perubahan yang Dilakukan

### 1. **influencer.html** - Halaman Utama Management
Halaman influencer.html telah diubah menjadi sistem dengan 2 tab:

#### **Tab 1: Request**
- Menampilkan daftar request dari influencer yang mendaftar melalui pp.ikutin (influencer-register.html)
- Kolom yang ditampilkan:
  - `#` - Nomor urut
  - `Date` - Tanggal registrasi
  - `Email` - Email pendaftar
  - `Nama` - Nama lengkap pendaftar
  - `No. WA` - Nomor WhatsApp
  - `Client ID` - Kode client di sekuritas
  - `Sekuritas` - Nama sekuritas yang digunakan
  - `Status` - Status registrasi dengan 2 level:
    - Level 1 (Status Kelengkapan): Req Sales / Lengkap
    - Level 2 (Status Approval): Pending / Approved / Rejected
  - `Action` - Tombol Accept/Reject atau status untuk yang sudah diproses

#### **Tab 2: Influencer List**
- Menampilkan daftar influencer yang sudah aktif/approved
- Mempertahankan struktur tabel yang sudah ada sebelumnya
- Menampilkan informasi: Influencer, Client ID, Email, No. HP, Revenue, Fans, Jumlah Client, Tgl. Tambah, Aksi

### 2. **influencer-register.html** - Form Registrasi
Ditambahkan field baru:
- **No. WhatsApp** - Field untuk nomor WhatsApp yang akan dihubungi oleh admin

Field yang ada:
- Nama Lengkap
- Email
- No. WhatsApp (BARU)
- Sekuritas (Maybank/Trimegah)
- Client Code

Data disimpan ke tabel `influencer_registrations` dengan status `pending`.

### 3. **Database Schema**
File: `influencer_registrations_schema.sql`

Tabel baru: `influencer_registrations`
- `id` - Primary key (auto increment)
- `nama` - Nama lengkap (TEXT, NOT NULL)
- `email` - Email (TEXT, NOT NULL)
- `phone` - Nomor WhatsApp (TEXT)
- `sekuritas` - Nama sekuritas (TEXT)
- `client_code` - Kode client (TEXT)
- `status` - Status approval: pending/approved/rejected (TEXT, DEFAULT 'pending')
- `created_at` - Tanggal registrasi (TIMESTAMPTZ)
- `updated_at` - Tanggal update (TIMESTAMPTZ)

## Cara Setup Database

1. Login ke Supabase Dashboard
2. Buka SQL Editor
3. Copy isi file `influencer_registrations_schema.sql`
4. Jalankan SQL query
5. Tabel `influencer_registrations` akan terbuat otomatis

## Fitur Utama

### Untuk Admin (di influencer.html):
1. **Melihat Request**: Admin dapat melihat semua request yang masuk di tab "Request"
2. **Approve Request**: Klik tombol "✓ Accept" untuk menyetujui request
3. **Reject Request**: Klik tombol "✗ Reject" untuk menolak request
4. **Search & Filter**: Dapat mencari request berdasarkan nama, email, atau client ID
5. **Status Tracking**: Melihat status kelengkapan data dan status approval

### Untuk Influencer (di influencer-register.html):
1. Mengisi form pendaftaran
2. Submit form
3. Menerima konfirmasi bahwa data sudah terkirim
4. Menunggu review dari admin (1-3 hari kerja)

## Flow Proses

```
Influencer Register (pp.ikutin)
    ↓
Data masuk ke tabel influencer_registrations (status: pending)
    ↓
Admin melihat di Tab "Request" 
    ↓
Admin review data
    ↓
Admin klik Accept atau Reject
    ↓
Status berubah menjadi approved/rejected
```

## Style & UI

- Menggunakan desain yang konsisten dengan dashboard Fawz Pro
- Badge dengan warna berbeda untuk setiap status:
  - **Req Sales**: Kuning (data belum lengkap)
  - **Lengkap**: Biru (data sudah lengkap)
  - **Pending**: Orange (menunggu review)
  - **Approved**: Hijau (disetujui)
  - **Rejected**: Merah (ditolak)

## Catatan Penting

1. Pastikan tabel `influencer_registrations` sudah dibuat di Supabase sebelum menggunakan fitur ini
2. Pastikan RLS (Row Level Security) sudah dikonfigurasi dengan benar di Supabase
3. File `config.js` harus berisi konfigurasi Supabase yang valid
4. Untuk production, pastikan mengaktifkan policy RLS yang sesuai

## File yang Diubah/Dibuat

1. ✅ `influencer.html` - Diubah (tambah tab Request & Influencer List)
2. ✅ `influencer-register.html` - Diubah (tambah field No. WhatsApp)
3. ✅ `influencer_registrations_schema.sql` - Dibuat baru (schema database)
4. ✅ `INFLUENCER_UPDATE_README.md` - Dibuat baru (dokumentasi)
