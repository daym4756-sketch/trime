# TATACARA PENGGUNAAN APLIKASI TRIME

> **TRIME** - Aplikasi Mobile Booking Barbershop Tanpa Biaya API.
> Semua data disimpan secara **lokal di perangkat** (SharedPreferences) sehingga tidak perlu backend/server untuk tahap demo/awal.

---

## DAFTAR ISI

1. [Gambaran Umum & Role Pengguna](#1-gambaran-umum--role-pengguna)
2. [Prasyarat Sistem](#2-prasyarat-sistem)
3. [Cara Install & Jalankan Aplikasi](#3-cara-install--jalankan-aplikasi)
4. [Role 1 - PELANGGAN (Customer)](#4-role-1---pelanggan-customer)
5. [Role 2 - MITRA (Pemilik Barbershop)](#5-role-2---mitra-pemilik-barbershop)
6. [Role 3 - KAPSTER (Tukang Cukur)](#6-role-3---kapster-tukang-cukur)
7. [Fitur Unggulan](#7-fitur-unggulan)
8. [FAQ & Troubleshooting](#8-faq--troubleshooting)

---

## 1. GAMBARAN UMUM & ROLE PENGGUNA

Aplikasi TRIME memiliki **3 Role Pengguna** yang bisa dipilih saat login:

| Role | Akses Fitur Utama |
|---|---|
| 👤 **PELANGGAN** | Cari barbershop & kapster terdekat via peta, Booking, Analisis AI model rambut, Favorit |
| 🏪 **MITRA** | Setup profil toko, Tambah layanan & kapster internal, Kelola booking masuk, Lihat pendapatan |
| 💈 **KAPSTER** | Setup profil kapster, Atur jadwal slot ketersediaan, Kelola bookingan, Atur notifikasi |

> 💡 **Catatan**: Untuk mencoba semua role, kamu bisa login berganti-ganti akun di halaman Login.

---

## 2. PRASYARAT SISTEM

- **Flutter SDK** versi 3.x atau lebih baru
- **Android Studio / VS Code** dengan Flutter plugin terpasang
- **Perangkat Android** (minimal SDK 21 / Lollipop) atau **Emulator Android**
- **Koneksi internet** (untuk load tile peta CartoDB, upload foto opsional)
- **Lokasi GPS** diaktifkan (untuk fitur pencarian terdekat & auto-center peta)

---

## 3. CARA INSTALL & JALANKAN APLIKASI

### Langkah 1: Buka Project
```
Folder Project: d:\Project\TRIME\mobile_app\
```

### Langkah 2: Install Dependencies
Jalankan di terminal (folder `mobile_app`):
```powershell
cd d:\Project\TRIME\mobile_app
flutter pub get
```

### Langkah 3: Hubungkan Perangkat / Jalankan Emulator
- Pastikan perangkat Android terhubung via USB dengan **Debug Mode ON**
- Atau jalankan emulator Android melalui Android Studio

### Langkah 4: Jalankan Aplikasi
```powershell
flutter run
```
> ⏳ Tunggu hingga proses build selesai dan aplikasi terbuka di perangkatmu.

### Langkah 5: Verifikasi Awal
Saat pertama kali membuka aplikasi:
1. Izinkan **Akses Lokasi** (penting untuk pencarian terdekat)
2. Izinkan **Akses Kamera & Galeri** (opsional, untuk AI analisis wajah & upload foto)
3. Kamu akan masuk ke **Halaman Splash** lalu ke **Halaman Login**

---

## 4. ROLE 1 - PELANGGAN (CUSTOMER)

Berikut alur lengkap penggunaan sebagai **Pelanggan**:

### 4.1 Login sebagai Pelanggan
1. Di halaman Login, pilih **"Masuk sebagai Pelanggan"**
2. Masukkan nomor HP (bebas untuk demo, misal `081234567890`)
3. Masukkan OTP (untuk demo: ketik `1234`)
4. Selesai! Kamu masuk ke **Home Page Pelanggan**

### 4.2 Home Page (3 Tab Utama)
Setelah login, ada 3 tab di bagian atas:

#### 📍 Tab 1: BARBERKU (Daftar Barbershop)
- Menampilkan **semua barbershop** yang sudah didaftarkan oleh Mitra
- **Filter**: `📍 Area Terdekat` (urut jarak) atau `⭐ Rating Terbaik` (urut rating)
- **Fitur Kartu**:
  - Tap tombol **❤️** = Tambah/Hapus Favorit
  - Tap tombol **BOOK** = Langsung booking di toko tersebut
  - Tap **kartu** = Buka Detail Barbershop

> 💡 **Empty State**: Jika belum ada barbershop, akan muncul pesan "Belum ada Barbershop yang terdaftar". Kamu bisa login sebagai Mitra untuk menambahkannya dulu.

#### 💈 Tab 2: KAPSTERKU (Daftar Kapster)
- Menampilkan **semua kapster** (baik kapster independen maupun kapster internal toko)
- Tap kartu kapster → Muncul **Bottom Sheet** dengan opsi:
  - **💈 Booking** = Buat booking dengan kapster ini
  - **💬 Chat** = Buka WhatsApp untuk chat (dummy nomor untuk demo)
  - **❤️** = Tambah ke Favorit

#### 🤖 Tab 3: RAMBUTKU (AI Analisis Wajah)
- Fitur rekomendasi model rambut berbasis **Analisis Bentuk Wajah AI**
- Langkah:
  1. Tap **📷 Ambil Foto**
  2. Pilih foto wajah dari Kamera atau Galeri
  3. AI akan menganalisis bentuk wajah (oval, bulat, persegi, dll)
  4. Hasil rekomendasi model rambut ditampilkan di halaman Result

### 4.3 Halaman Detail Barbershop
Dari tab BARBERKU, tap salah satu kartu toko untuk membuka detail:

| Bagian | Keterangan |
|---|---|
| **Hero Cover** | Foto cover toko, tap ❤️ untuk favorit, tap share untuk bagikan |
| **Header Info** | Nama toko, Rating, Status Buka/Tutup, Alamat, Jarak dari lokasimu |
| **Action Row** | Chat WA → Rute di Google Maps → Buka Peta |
| **📍 Lokasi** | Mini map preview lokasi toko (non-interactive). Tap untuk buka Google Maps & navigasi rute |
| **💈 Kapster di Toko** | Daftar kapster yang bekerja di toko ini. Tap untuk booking personal |
| **✨ Daftar Layanan** | List layanan + harga + durasi (misal: Potong Rambut - Rp 50.000 - 45 menit) |
| **📸 Galeri** | Foto-foto portofolio hasil potong rambut toko |
| **Bottom CTA** | Tombol `💈 Booking Sekarang` untuk booking di toko ini |

### 4.4 Fitur Peta (KapsterMapPage)
Dari Home Page, tap **ikon Map** (kanan atas appbar):

1. **Tab KAPSTER** = Peta interaktif
   - Marker **Biru Ungu** = Kapster
   - Marker **Merah** = Barbershop
   - Marker **Cyan** = Lokasi kamu (dengan lingkaran akurasi)
   - FAB **"Lokasi Saya"** = Auto-center kamera ke posisi kamu
   - **Draggable Bottom Sheet**:
     - Rekomendasi Kapster terdekat
     - Rekomendasi 3 Barbershop terdekat (horizontal list)
     - Jika marker dipilih: tombol **Rute ke [nama]** untuk buka Google Maps navigation

2. **Tab BARBERSHOP** = Grid view semua barbershop (sama seperti tab BARBERKU)
3. **Tab PROMO** = Placeholder (coming soon)

### 4.5 Proses Booking
1. Dari kartu barbershop/kapster, tap **BOOK**
2. Masuk ke **Booking Calendar Page**:
   - Pilih **tanggal** di kalender
   - Pilih **slot waktu** yang tersedia
   - Pilih **kapster** (jika dari toko) atau **toko** (jika dari kapster)
   - Pilih **layanan** yang diinginkan
   - Tap **Konfirmasi Booking**
3. Booking otomatis masuk ke daftar booking Mitra & Kapster terkait
4. Pelanggan bisa lihat booking di tab **Jadwal** (bottom nav)

---

## 5. ROLE 2 - MITRA (Pemilik Barbershop)

Alur penggunaan sebagai **Pemilik Barbershop / Mitra**:

### 5.1 Login sebagai Mitra
1. Di halaman Login, pilih **"Masuk sebagai Mitra"**
2. Masukkan nomor HP & OTP `1234`
3. Otomatis masuk ke **Barber Dashboard Page** (4 Tab)

### 5.2 Setup Toko (Pertama Kali)
Saat pertama login sebagai Mitra, toko masih **kosong**. Ikuti langkah setup:

#### Tab 4: 🗂️ DATA TOKO (Setup Awal)

##### a. Setup Identitas Toko
- Di **AppBar Header** (bagian atas berwarna biru tua):
  - Tap **nama toko** → Edit nama barbershop
  - Tap **alamat** → Edit alamat lengkap
  - Tap **nomor WA** → Edit nomor WhatsApp toko
  - Tap **jam operasional** → Edit jam buka (contoh: `09:00 - 21:00 Buka`)
  - Tap **ikon kamera** (kanan atas) → Upload cover foto toko dari galeri

##### b. Atur Lokasi Toko (Penting!)
Scroll ke bawah ke section **"Lokasi Toko di Peta"**:
1. Tap **"Ubah Titik Lokasi"** (di bawah map preview)
2. Dialog muncul → Tap **"Gunakan Lokasi Saya"** (untuk pakai GPS lokasi kamu saat ini)
3. Atau isi manual:
   - **Latitude** (cth: `-6.9680` untuk Semarang)
   - **Longitude** (cth: `110.4150`)
4. Tap **Simpan**
5. Marker lokasi toko akan muncul di map preview

##### c. Tambah Galeri Foto
Section **"Galeri Toko"**:
- Tap **"Tambah"** (kanan atas section)
- Atau tap kartu **"+ Tambah"** di grid
- Pilih foto dari galeri (bisa foto interior, eksterior, hasil potongan)
- Hapus foto: Tap **✖️ merah** di pojok kanan atas foto

##### d. Tambah Kapster Internal Toko
Section **"Daftar Kapster"**:
1. Tap **"Tambah"**
2. Isi dialog:
   - **Nama Kapster** (wajib)
   - **Spesialisasi** (default: Umum, bisa Fade, Pompadour, dll)
3. Tap **Tambah**
4. Kapster muncul di list dengan:
   - **Switch** (kanan) = Aktif / Nonaktifkan kapster
   - **🗑️** = Hapus kapster dari toko

##### e. (Opsional) Setup Tab 3: ✨ LAYANAN
1. Tap tab **"Layanan"** (tab ke-3)
2. Tap **"Tambah"**
3. Isi form:
   - **Nama Layanan** (cth: Potong Rambut + Cuci)
   - **Harga (Rp)** (cth: 50000)
   - **Durasi** (cth: 45 menit)
4. Tap **Tambah**
5. Layanan muncul di list → Tap **🗑️** untuk menghapus

---

### 5.3 Kelola Dashboard Harian

#### Tab 1: 📊 RINGKASAN (Overview)
Menampilkan **4 Stat Card**:
- 💰 **Pendapatan Hari Ini** = Total booking yang status `Selesai` hari ini
- ✅ **Booking Selesai** = Jumlah booking status done
- ⏳ **Perlu Konfirmasi** = Jumlah booking status pending
- 📅 **Booking Aktif** = Jumlah booking status confirmed

Di bawahnya: **Booking Terbaru** (3 booking terakhir). Tap **Lihat Semua** untuk pindah ke tab Booking.

#### Tab 2: 📋 BOOKING
List **semua booking** dari pelanggan:
- Setiap booking menampilkan:
  - ID Booking
  - **Badge Status**:
    - 🟠 **Menunggu** (pending) = Perlu konfirmasi
    - 🔵 **Dikonfirmasi** (confirmed) = Sudah dikonfirmasi
    - 🟢 **Selesai** (done) = Selesai dikerjakan
  - Nama Customer, Nama Layanan, Nama Kapster
  - Tanggal & Jam booking
  - Harga
- Action (jika belum done):
  - **"Hubungi WA"** = Buka WhatsApp customer
  - **✅ Ikon hijau** = Update status:
    - `pending` → `confirmed` (konfirmasi booking)
    - `confirmed` → `done` (tandai selesai)

---

## 6. ROLE 3 - KAPSTER (Tukang Cukur)

Alur penggunaan sebagai **Kapster Independen**:

### 6.1 Login sebagai Kapster
1. Di halaman Login, pilih **"Masuk sebagai Kapster"**
2. Masukkan nomor HP & OTP `1234`
3. Masuk ke **Kapster Dashboard Page** (3 Tab)

### 6.2 Setup Profil Kapster (Pertama Kali)

#### Setup di Header AppBar (bagian gradien biru tua):
- Tap **avatar (lingkaran kiri atas)** → Upload foto profil kapster
- Tap **nama kapster** → Edit nama lengkap
- Tap **badge** (contoh: "Tap pilih badge") → Pilih badge (opsional):
  - Tidak Ada / Kapster Baru / Kapster Profesional / Master Barber / Top Rated
- Tap **spesialisasi** (contoh: "Tap atur spesialisasi") → Edit daftar spesialisasi (pisahkan dengan koma, cth: `Fade, Pompadour, Undercut`)

Di bawahnya ada **4 Quick Stat**:
- Selesai · Pending · Slot Kosong · Pendapatan Hari Ini

---

### 6.3 Kelola Jadwal & Booking

#### Tab 1: 📅 JADWAL (Atur Slot Ketersediaan)
Ini fitur **TERPENTING** untuk kapster. Secara default, SEMUA slot = **Libur**.

##### Cara Baca Slot:
| Warna | Status | Arti |
|---|---|---|
| 🟩 Hijau | **Tersedia** | Bisa menerima booking di jam ini |
| 🟥 Merah | **Penuh** | Sudah ada booking / penuh |
| ⬜ Abu | **Libur** | Tidak menerima booking |

##### Cara Ubah Status Slot:
1. Pilih **hari** (Senin - Minggu) di strip atas (yang ada titik biru = hari ini)
2. **Tap slot waktu** (grid 4 kolom) untuk ubah status:
   - Tap 1x: `Libur` → `Tersedia` (hijau)
   - Tap 2x: `Tersedia` → `Penuh` (merah)
   - Tap 3x: `Penuh` → `Libur` (abu)
3. Ulangi untuk semua hari & slot

##### Shortcut Cepat (di bawah grid):
- 📌 **"Tandai Hari Ini Libur Semua"** = Semua slot untuk hari yang dipilih jadi Libur
- ✅ **"Buka Semua Slot Hari Ini (09:00 - 21:00)"** = Semua slot jam kerja jadi Tersedia (hijau)

> 📌 **Catatan**: Slot 08:00 - 21:00 (27 slot per hari). Aturlah sesuai jam kerjamu!

#### Tab 2: 📋 BOOKING
List **semua booking** yang ditugaskan ke kapster ini:
- Sama seperti booking di Mitra, tapi difilter hanya booking dengan `kapsterName = nama kamu`
- Action:
  - **Hubungi WA** = Chat customer
  - Jika `pending`: tap **✅ hijau** = Konfirmasi (confirmed)
  - Jika `confirmed`: tap **✅ biru** = Tandai Selesai (done)

#### Tab 3: 🔔 PENGINGAT (Reminder Settings)

##### Bagian Atur Notifikasi (Toggle Switch):
| Opsi | Default | Fungsi |
|---|---|---|
| Bookingan Baru Masuk | ON | Notifikasi saat ada booking baru |
| Pengingat 15 Menit Sebelum | ON | Ingatkan 15 menit sebelum jadwal |
| Pengingat 1 Jam Sebelum | OFF | Ingatkan 1 jam sebelum jadwal |
| Notifikasi WhatsApp | ON | Kirim pesan WA otomatis (dummy untuk demo) |

##### Bagian Pengingat Hari Ini:
- Menampilkan **list booking hari ini** yang belum selesai
- Setiap item ada: Ikon jam, Waktu booking, Judul booking, Layanan
- Tap item = (placeholder) Lihat detail booking

---

## 7. FITUR UNGGULAN

### 🗺️ Fitur Peta Tanpa Biaya (Zero-Cost Mapping)
- ✅ Menggunakan **`flutter_map` + CartoDB Positron tiles** (GRATIS, open source)
- ❌ **TIDAK menggunakan Google Maps SDK** → Tidak ada biaya API key sama sekali
- ✅ Pencarian terdekat pakai **rumus Haversine** di client-side (tidak perlu Distance Matrix API)
- ✅ **Deep Link Google Maps** untuk navigasi rute (buka app Google Maps eksternal)

### 🤖 AI Rekomendasi Model Rambut
- Analisis bentuk wajah dari foto (kamera/galeri)
- Memberikan rekomendasi model rambut yang cocok
- Fitur edukatif untuk pelanggan sebelum booking

### 💾 Offline-First Architecture
- Semua data disimpan **lokal di SharedPreferences** (perangkat):
  - Profil Barbershop (nama, alamat, lokasi, layanan, kapster, galeri)
  - Profil Kapster (nama, foto, spesialisasi, rating, dll)
  - Data Booking (status, tanggal, harga, dll)
  - Daftar Favorit
  - Lokasi user terakhir
- **Tidak perlu koneksi internet terus-menerus** (hanya butuh untuk load tile peta & AI service jika online)

### 🎨 Empty State yang Ramah Pengguna
Setiap section/data yang kosong akan menampilkan **empty state card** dengan:
- Ikon ilustrasi
- Pesan deskriptif jelas tentang **mengapa kosong**
- Instruksi **apa yang harus dilakukan** untuk mengisinya
- Misal: "Belum ada Barbershop. Login sebagai Mitra untuk menambahkan toko Anda."

---

## 8. FAQ & TROUBLESHOOTING

### Q1: Aplikasi tidak bisa deteksi lokasi?
**Solusi:**
1. Pastikan **GPS/Lokasi** di perangkatmu AKTIF
2. Pastikan kamu sudah **Izinkan Akses Lokasi** saat dialog permission muncul
3. Jika masih error: Aplikasi otomatis fallback ke **Titik Kota Semarang** (-6.9667, 110.4167) sebagai lokasi default

### Q2: Data yang saya input hilang setelah tutup aplikasi?
**Solusi:**
- Tidak seharusnya hilang! Semua data otomatis disimpan ke SharedPreferences saat kamu tap **Simpan / Tambah / Persist**
- Verifikasi: Coba tutup lalu buka kembali aplikasi → Data tetap harus ada
- Jika masih hilang: Pastikan tidak menghapus **Data Aplikasi** di Settings Android

### Q3: Halaman Home / Peta kosong (tidak ada barbershop/kapster)?
**Solusi:**
1. Ini **NORMAL** untuk pertama kali! Data dummy sudah dihapus sesuai standar clean code.
2. Kamu perlu **menambah data sendiri**:
   - Login sebagai **MITRA** → Setup toko + layanan + kapster internal
   - Login sebagai **KAPSTER** → Setup profil + atur jadwal slot
3. Setelah data ditambahkan, login kembali sebagai **PELANGGAN** → Data akan muncul otomatis

### Q4: Bagaimana cara reset semua data aplikasi?
**Solusi:**
- Di Android: `Settings → Apps → TRIME → Storage → Clear Data`
- Atau uninstall lalu install ulang aplikasi
- ⚠️ **Peringatan**: Semua data (profil toko, booking, favorit) akan TERHAPUS PERMANEN

### Q5: Flutter analyze error?
**Solusi:**
```powershell
cd d:\Project\TRIME\mobile_app
flutter clean
flutter pub get
flutter analyze
```
Hasil yang diharapkan: **0 issues found** ✅ (semua kode sudah sesuai standar)

### Q6: Build APK untuk produksi?
```powershell
cd d:\Project\TRIME\mobile_app
flutter build apk --release
```
APK hasil build ada di: `build/app/outputs/flutter-apk/app-release.apk`

---

## 9. LOKASI FILE PENTING (REFERENSI DEVELOPER)

| File | Keterangan |
|---|---|
| [main.dart](file:///d:/Project/TRIME/mobile_app/lib/main.dart) | Entry point aplikasi |
| [app_state.dart](file:///d:/Project/TRIME/mobile_app/lib/core/services/app_state.dart) | State management + model data (BarbershopProfile, KapsterProfile, Booking, dll) |
| [home_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/home/pages/home_page.dart) | Home Page Pelanggan (3 tab) |
| [kapster_map_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/kapster/pages/kapster_map_page.dart) | Halaman Peta interaktif |
| [barbershop_detail_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/home/pages/barbershop_detail_page.dart) | Detail Barbershop |
| [barber_dashboard_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/home/pages/barber_dashboard_page.dart) | Dashboard Mitra |
| [kapster_dashboard_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/home/pages/kapster_dashboard_page.dart) | Dashboard Kapster |
| [haversine_distance.dart](file:///d:/Project/TRIME/mobile_app/lib/core/utils/haversine_distance.dart) | Rumus perhitungan jarak Haversine (zero-cost) |
| [pubspec.yaml](file:///d:/Project/TRIME/mobile_app/pubspec.yaml) | List dependencies Flutter |

---

**SELAMAT MENGGUNAKAN APLIKASI TRIME!** 💈✨

Jika ada pertanyaan lebih lanjut, lihat file:
- [IMPLEMENTATION_PLAN.md](file:///d:/Project/TRIME/IMPLEMENTATION_PLAN.md)
- [MAP_MIGRATION_PLAN.md](file:///d:/Project/TRIME/MAP_MIGRATION_PLAN.md)
