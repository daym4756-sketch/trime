# ESTIMASI BIAYA & HARGA JUAL PROYEK TRIME

> **TRIME - Marketplace Barbershop Terintegrasi**  
> **Versi Dokumen**: 1.1  
> **Tanggal**: 19 Agustus 2026  
> **Status**: Estimasi berdasarkan codebase saat ini  
> **Update**: Menambahkan Paket Khusus Rp 26,5 Juta (Section 9)

---

## DAFTAR ISI
1. [Ringkasan Proyek](#1-ringkasan-proyek)
2. [Breakdown Biaya Pengembangan](#2-breakdown-biaya-pengembangan)
3. [Biaya Bahan / Lisensi / Infrastruktur (Opsional)](#3-biaya-bahan--lisensi--infrastruktur-opsional)
4. [Biaya Jasa Pengembangan](#4-biaya-jasa-pengembangan)
5. [Total Biaya Keseluruhan](#5-total-biaya-keseluruhan)
6. [Rekomendasi Harga Jual](#6-rekomendasi-harga-jual)
7. [Strategi Paket Penawaran](#7-strategi-paket-penawaran)
8. [Catatan Tambahan](#8-catatan-tambahan)
9. [PAKET KHUSUS: HARGA PATAH Rp 26,5 JUTA](#9-paket-khusus-harga-patah-rp-265-juta)

---

## 1. RINGKASAN PROYEK

TRIME adalah aplikasi mobile marketplace barbershop dengan 3 komponen utama:

| Komponen | Deskripsi Singkat | Jumlah File |
|---|---|---|
| **Mobile App (Flutter)** | Aplikasi Android/iOS/Web dengan 15 halaman, 8 widget custom, state management, 3 role user (Pelanggan, Kapster, Mitra Barber) | 33 `.dart` |
| **AI Recognition Service (Python)** | Backend FastAPI untuk analisis bentuk wajah menggunakan Computer Vision (dlib + OpenCV) + ML Model (SVM + PCA) | 4 `.py` + 3 model |
| **Dokumentasi** | Panduan implementasi, migrasi peta, tata cara penggunaan role-based | 3 `.md` |

### Fitur Utama yang Sudah Jadi:
- ✅ Autentikasi 3 role (Splash → Login → OTP → Dashboard) via Firebase Auth
- ✅ Google Sign-In + Supabase Integration
- ✅ Booking System: Kalender jadwal, slot waktu 30 menit (08:00-21:00), status booking
- ✅ Map View: `flutter_map` dengan marker barbershop, deteksi lokasi user, auto-center, jarak Haversine
- ✅ AI Rekomendasi Rambut: Upload foto → analisis bentuk wajah → rekomendasi gaya
- ✅ Favorit Barbershop/Kapster
- ✅ 2 Dashboard terpisah (Mitra Barber vs Kapster)
- ✅ Halaman Detail Barbershop dengan mini-map preview
- ✅ Sistem rating & badge exclusive
- ✅ Theme system (Design Tokens: Color, Spacing, Typography via Google Fonts)

---

## 2. BREAKDOWN BIAYA PENGEMBANGAN

Estimasi berdasarkan effort (jam kerja) x tarif standar pengembang Flutter/Python di Indonesia (mid-level).

### 2.1 Mobile App (Flutter) — 33 File

| Modul | Jumlah File | Effort (Jam) | Tarif/Jam (Rp) | Subtotal (Rp) | Keterangan |
|---|---|---|---|---|---|
| **Core Services** | 5 | 48 | 150.000 | 7.200.000 | `app_state.dart`, `auth_service.dart`, `supabase_service.dart`, `ai_service.dart`, `haversine_distance.dart` |
| **Auth Flow** | 4 | 40 | 150.000 | 6.000.000 | Splash, Login, OTP (pinput), Akun Page. Integrasi Firebase Auth + Google Sign In |
| **Home & Dashboard** | 4 | 56 | 150.000 | 8.400.000 | Home, Barbershop Detail, Barber Dashboard, Kapster Dashboard |
| **Booking System** | 2 | 52 | 150.000 | 7.800.000 | Booking Calendar (slot 30 menit), Jadwal Page dengan 4 status booking |
| **Map & Location** | 1 | 36 | 150.000 | 5.400.000 | `kapster_map_page.dart` — flutter_map, marker, geolocator, jarak Haversine, minimap preview |
| **AI & Rambutku** | 1 | 24 | 150.000 | 3.600.000 | `ai_result_page.dart` — tampil hasil analisis AI |
| **Favorite** | 1 | 12 | 150.000 | 1.800.000 | Favorite list barbershop/kapster |
| **App Scaffold & Bottom Nav** | 1 | 16 | 150.000 | 2.400.000 | `app_scaffold.dart`, `bottom_nav_bar.dart` |
| **Shared Widgets** | 8 | 40 | 150.000 | 6.000.000 | Card Barbershop, Card Kapster, Primary Button, Rating Stars, Badge Exclusive, Smart Image, Trime Logo |
| **Theme System** | 3 | 16 | 150.000 | 2.400.000 | Color Tokens, Spacing Tokens, App Theme + Google Fonts |
| **Main & Config** | 1 | 8 | 150.000 | 1.200.000 | `main.dart` — bootstrap, dependency injection |
| **Unit Test** | 1 | 8 | 150.000 | 1.200.000 | `widget_test.dart` |
| **Setup Android/iOS/Web** | — | 24 | 150.000 | 3.600.000 | Gradle config, Firebase google-services.json, iOS Info.plist, Web manifest |
| **Asset: Image Generation** | — | 16 | 100.000 | 1.600.000 | Prompt engineering + generate gambar AI untuk barbershop, kapster, model rambut |
| **Debugging & Refactoring** | — | 48 | 150.000 | 7.200.000 | Null safety fixes, migrasi enum→String status, cleanup dummy data, 0 warning flutter analyze |
| **QA & Testing (Android 14)** | — | 24 | 120.000 | 2.880.000 | Build APK debug, test manual di perangkat fisik |
| --- | --- | --- | --- | --- | --- |
| **SUBTOTAL MOBILE APP** | **33** | **468** | — | **68.680.000** | |

---

### 2.2 AI Recognition Service (Python/FastAPI) — 4 File + 3 Model

| Komponen | Effort (Jam) | Tarif/Jam (Rp) | Subtotal (Rp) | Keterangan |
|---|---|---|---|---|
| **FastAPI Server Setup** | 8 | 180.000 | 1.440.000 | `main.py` — endpoint `/analyze/face-shape` + startup event load model |
| **Face Shape Engine** | 40 | 180.000 | 7.200.000 | Preprocessing citra, deteksi landmark (dlib), ekstraksi fitur geometris |
| **ML Training Pipeline** | 48 | 200.000 | 9.600.000 | Training SVM RBF, PCA dimensionality reduction, Standard Scaler — `svm_rbf_best.pkl`, `pca.pkl`, `scaler.pkl` |
| **Image Utilities** | 12 | 180.000 | 2.160.000 | `image_utils.py`, `base_engine.py` — load image, augmentasi dasar |
| **Config & Environment** | 4 | 180.000 | 720.000 | `config.py` — host, port, path model |
| **Dependencies: dlib, OpenCV, PyMuPDF** | 8 | 150.000 | 1.200.000 | Setup native binding dlib (khusus Windows agak ribet), scikit-learn, scipy, numpy |
| **Testing Endpoint API** | 8 | 150.000 | 1.200.000 | Test upload berbagai format gambar, edge case (tidak ada wajah, blur, multiple faces) |
| --- | --- | --- | --- | --- |
| **SUBTOTAL AI SERVICE** | **128** | — | **23.520.000** | |

---

### 2.3 Dokumentasi Proyek — 3 File

| Dokumen | Effort (Jam) | Tarif/Jam (Rp) | Subtotal (Rp) | Keterangan |
|---|---|---|---|---|
| `IMPLEMENTATION_PLAN.md` | 8 | 120.000 | 960.000 | V2: Arsitektur, rencana fitur, timeline 4 minggu, aset visual |
| `MAP_MIGRATION_PLAN.md` | 4 | 120.000 | 480.000 | Migrasi Google Maps → flutter_map (zero-cost strategy) |
| `TATACARA_PENGGUNAAN.md` | 12 | 120.000 | 1.440.000 | Panduan role-based: Pelanggan, Kapster, Mitra Barber (step-by-step) |
| --- | --- | --- | --- | --- |
| **SUBTOTAL DOKUMENTASI** | **24** | — | **2.880.000** | |

---

### 2.4 Rekap Biaya Pengembangan (Coding + Design + QA)

| Komponen | Total Effort (Jam) | Total Biaya (Rp) |
|---|---|---|
| Mobile App (Flutter) | 468 | 68.680.000 |
| AI Recognition Service (Python) | 128 | 23.520.000 |
| Dokumentasi | 24 | 2.880.000 |
| --- | --- | --- |
| **TOTAL PENGEMBANGAN** | **620 jam** | **Rp 95.080.000** |

---

## 3. BIAYA BAHAN / LISENSI / INFRASTRUKTUR (OPSIONAL)

Biaya ini **di luar biaya pengembangan** dan bergantung pada deployment strategy. Untuk start awal (cost-conscious), bisa mulai dari **Rp 0** menggunakan free tier.

### 3.1 Hosting & Backend

| Layanan | Tier Gratis | Harga Minimum (Mulai Bayar) | Harga Bulanan (Produksi Ringan) | Untuk Apa |
|---|---|---|---|---|
| **Supabase (Auth + DB + Storage)** | ✅ 500MB DB, 1GB Storage, 50K MAU | Rp 0 | Rp 90.000 (~$6 Pro Plan) | Autentikasi user, database booking, penyimpanan gambar profil |
| **Firebase Auth** | ✅ Unlimited Auth untuk email/password & Google Sign-In | Rp 0 | Rp 0 (selalu free untuk Auth) | Login OTP, Google Sign-In |
| **VPS / Cloud (AI Recognition)** | — | — | Rp 150.000 – 300.000/bln (2 vCPU, 4GB RAM) | Menjalankan FastAPI + dlib + OpenCV. Catatan: dlib butuh RAM min 2GB |
| **Render / Railway (Python)** | ✅ 500 jam/bulan free tier (sleep setelah 15 menit) | Rp 0 | Rp 135.000 – 270.000/bln (Starter $9-$18) | Alternatif VPS untuk deploy FastAPI |
| **Domain (.com / .id)** | — | Rp 150.000 – 350.000/tahun | Sama | `trime-app.com` atau `trime.co.id` (opsional, bisa pakai subdomain gratis dari Render/Railway) |

### 3.2 SDK & API Pihak Ketiga

| Layanan | Tier Gratis | Harga Minimum | Untuk Apa |
|---|---|---|---|
| **flutter_map + CartoDB Positron Tiles** | ✅ 100% Free (OpenStreetMap tile) | Rp 0 | ✅ **Sudah dipakai — zero cost mapping strategy** (tidak pakai Google Maps SDK berbayar) |
| **Geolocator (GPS)** | ✅ Free (system location service Android/iOS) | Rp 0 | Deteksi lokasi user di Map View |
| **Google Fonts** | ✅ Free untuk semua font (SIL OFL License) | Rp 0 | Typography app theme |
| **Image Generation AI** | — | Variatif | Generate gambar placeholder barbershop/kapster. Bisa ganti dengan foto real (free) |
| **Trae AI Image API (Internal)** | ✅ Sesuai kapasitas project | Rp 0 | Sudah dipakai via URL endpoint Text-to-Image |
| **Twilio / Meta (WhatsApp OTP)** | ❌ Tidak ada free tier real | ~Rp 150 – 300 per SMS OTP | **OPSIONAL**: Saat ini OTP di app masih pakai dummy/placeholder. Jika ingin OTP beneran via WA, butuh biaya per-sms |

### 3.3 Android Play Store & Apple App Store

| Layanan | Biaya | Keterangan |
|---|---|---|
| **Google Play Console** | $25 (~Rp 400.000) **ONCE** (sekali bayar seumur hidup) | Wajib untuk publish APK ke Play Store. Bisa pakai akun pribadi |
| **Apple Developer Program** | $99/tahun (~Rp 1.600.000/tahun) | Wajib untuk publish ke App Store. **Jika target cuma Android, skip dulu** |

### 3.4 Rekap Biaya Operasional Bulanan (3 Skenario)

| Item | 🟢 **Skenario Hemat (MVP)** | 🟡 **Skenario Menengah** | 🔴 **Skenario Produksi** |
|---|---|---|---|
| Supabase | FREE | FREE | Rp 90.000 |
| Hosting AI (FastAPI) | Rp 0 (Render free tier — sleep) | Rp 150.000 | Rp 270.000 |
| Domain | — | Rp 25.000 (pro-rata) | Rp 25.000 |
| OTP WhatsApp | DUMMY / Skip | Rp 100.000 | Rp 300.000 |
| Lain-lain (cadangan) | Rp 50.000 | Rp 75.000 | Rp 150.000 |
| --- | --- | --- | --- |
| **Total / bulan** | **Rp 50.000** | **Rp 400.000** | **Rp 835.000** |
| **Total / tahun** | **Rp 600.000** | **Rp 4.800.000** | **Rp 10.020.000** |
| + Apple Developer (jika perlu iOS) | — | + Rp 1.600.000/thn | + Rp 1.600.000/thn |
| + Google Play Console (once) | + Rp 400.000 (sekali) | + Rp 400.000 (sekali) | + Rp 400.000 (sekali) |

---

## 4. BIAYA JASA PENGEMBANGAN

Biaya jasa adalah **bagian dari total biaya pengembangan (Section 2)**. Berikut breakdown berdasarkan jenis keahlian:

| Jenis Keahlian | Total Jam | Tarif/Jam | Subtotal (Rp) | % Komponen |
|---|---|---|---|---|
| **Flutter Mobile Developer** | 420 jam | Rp 150.000 | 63.000.000 | 66,3% |
| **Python/ML Engineer** | 108 jam | Rp 180.000 – 200.000 | 19.440.000 | 20,4% |
| **UI/UX (Widget + Theme Design)** | 48 jam | Rp 130.000 | 6.240.000 | 6,6% |
| **QA Tester** | 32 jam | Rp 120.000 | 3.840.000 | 4,0% |
| **Technical Writer (Dokumentasi)** | 24 jam | Rp 120.000 | 2.880.000 | 3,0% |
| **Project Management (overhead)** | (included) | — | (sudah di-include di atas) | — |
| --- | --- | --- | --- | --- |
| **TOTAL JASA** | **632 jam** | — | **Rp 95.400.000** | **100%** |

> **Catatan**: Terdapat selisih ~Rp 320.000 dengan section 2 karena pembulatan tarif. Angka final di Section 5 yang dipakai.

---

## 5. TOTAL BIAYA KESELURUHAN

| Kategori | Biaya (Rp) | Keterangan |
|---|---|---|
| **5.1 Biaya Pengembangan (Sekali Bayar)** | | |
| Mobile App Flutter | 68.680.000 | 33 file, 15 halaman, 3 role user |
| AI Recognition Service (Python) | 23.520.000 | FastAPI + dlib + OpenCV + SVM Model |
| Dokumentasi Proyek | 2.880.000 | 3 file MD komprehensif |
| **Subtotal Pengembangan** | **95.080.000** | |
| | | |
| **5.2 Biaya Publikasi (One-Time)** | | |
| Google Play Console (sekali seumur hidup) | 400.000 | Wajib untuk publish ke Play Store |
| Apple Developer Program (opsional) | 1.600.000 | Hanya jika mau publish ke App Store |
| **Subtotal Publikasi** | **Rp 400.000 – 2.000.000** | |
| | | |
| **5.3 Biaya Operasional Tahun Pertama** | | |
| Skenario Hemat (MVP Free Tier) | 600.000 | 50k/bulan x 12 |
| Skenario Menengah | 4.800.000 | 400k/bulan x 12 |
| Skenario Produksi | 10.020.000 | 835k/bulan x 12 |
| | | |
| **5.4 TOTAL GRAND TOTAL (Tahun Pertama)** | | |
| 🟢 **MVP Hemat (Android only + Free Tier)** | **Rp 96.080.000** | = 95.080jt + 400rb publish + 600rb ops |
| 🟡 **Menengah (Android + Hosted AI)** | **Rp 100.280.000** | = 95.080jt + 400rb + 4.8jt |
| 🔴 **Produksi Penuh (Android + iOS + Serius)** | **Rp 108.700.000** | = 95.080jt + 2jt publish + 10.02jt ops + 1.6jt Apple |

---

## 6. REKOMENDASI HARGA JUAL

Setelah menghitung biaya, tambahkan margin keuntungan wajar untuk proyek software development (standar industri 30%–60% bergantung kompleksitas dan risiko).

### 6.1 Margin yang Disarankan

| Strategi | Margin | Digunakan Saat |
|---|---|---|
| **Konservatif** | 30% | Client lama / internal project / buka portofolio |
| **Normal** | 45% | Harga pasar standar untuk freelance / agency kecil |
| **Agency / Premium** | 60% | Branded agency, ada after-sales support resmi, warranty extended |

### 6.2 Harga Jual yang Patok

| Skenario Produk | Harga Modal (Cost) | + 30% | + 45% | + 60% |
|---|---|---|---|---|
| 🟢 **MVP Hemat (Rekomendasi Awal)** | Rp 96.080.000 | **Rp 124.904.000** | **Rp 139.316.000** | **Rp 153.728.000** |
| 🟡 **Menengah** | Rp 100.280.000 | Rp 130.364.000 | Rp 145.406.000 | Rp 160.448.000 |
| 🔴 **Produksi Penuh** | Rp 108.700.000 | Rp 141.310.000 | Rp 157.615.000 | Rp 173.920.000 |

### 6.3 ⭐ REKOMENDASI HARGA AKHIR YANG DIPATOK

> **Untuk menjual ke klien / mitra bisnis:**

| Paket | Harga Jual (Rp) | Bulatkan Jadi | Catatan |
|---|---|---|---|
| **PAKET MVP** (Fitur seperti codebase sekarang) | Rp 125.000.000 | **Rp 125 Juta** | ✅ Cocok untuk pitching awal, fitur komplet, AI recognition aktif, map zero-cost |
| **PAKET STANDAR** (MVP + Hosting 1 thn skenario menengah + Support 3 bulan) | Rp 150.000.000 | **Rp 150 Juta** | ✅ **Paling recommended untuk dijual** — terasa "premium" tapi tidak terlalu mahal |
| **PAKET PREMIUM** (Full Android+iOS, OTP WA beneran, Support 1 tahun, Training tim internal) | Rp 185.000.000 – 200.000.000 | **Rp 185 – 200 Juta** | Untuk klien enterprise / mitra yang serius scale-up |

---

## 7. STRATEGI PAKET PENAWARAN

### 7.1 Struktur Pembayaran (Termin)

Untuk proyek software, disarankan pembayaran bertahap agar cash flow sehat dan risiko terbagi:

| Termin | % dari Harga | Waktu Pembayaran | Deliverable |
|---|---|---|---|
| **DP / Termin 1** | 40% | Sebelum mulai kerja (atau saat kontrak ditandatangani) | Project kickoff, repo setup, access |
| **Termin 2** | 30% | Setelah Mobile App UI + Auth selesai & di-test | APK demo: Login, 3 role dashboard, map, booking |
| **Termin 3** | 20% | Setelah AI Recognition terintegrasi + semua fitur jalan | Full app demo + source code handover |
| **Termin 4 (Pelunasan)** | 10% | Setelah User Acceptance Test (UAT) + Publish ke Play Store | App live di Play Store + Dokumentasi lengkap |

Contoh untuk **Paket Standar Rp 150 Juta**:
- Termin 1: Rp 60 Juta
- Termin 2: Rp 45 Juta
- Termin 3: Rp 30 Juta
- Termin 4: Rp 15 Juta

---

### 7.2 Add-On / Up-Sell (Biaya Tambahan di Luar Paket)

Gunakan ini sebagai peluang pendapatan tambahan jika client request fitur di luar scope:

| Add-On | Harga (Rp) | Keterangan |
|---|---|---|
| **Publish ke Apple App Store** | + 15.000.000 | Setup iOS, test iPhone, submit App Store + 1 tahun Apple Developer |
| **OTP WhatsApp Real (Twilio/Meta)** | + 8.000.000 + biaya per-SMS | Setup Twilio/Meta Business, webhook OTP, verifikasi nomor sender |
| **Push Notifikasi (Firebase Cloud Messaging)** | + 6.000.000 | Notif booking reminder, notif status ke kapster/mitra |
| **Chat In-App (Supabase Realtime)** | + 12.000.000 | Chat antar pelanggan ↔ kapster / mitra |
| **Fitur Review & Rating (lengkap + filter)** | + 7.500.000 | Sistem rating terintegrasi DB, filter ulasan, reply owner |
| **Admin Web Dashboard (Laravel / React)** | + 40.000.000 – 60.000.000 | Dashboard admin web untuk manage semua user, booking, laporan keuangan |
| **Maintenance Bulanan** | 2.500.000 – 4.000.000 / bulan | Bug fix minor, update OS compatibility, minor feature request (< 4 jam) |
| **Training / Workshop ke Tim Klien** | + 3.000.000 / sesi | 3 jam training penggunaan sistem untuk 5-10 orang |

---

## 8. CATATAN TAMBAHAN

### 8.1 Risiko yang Perlu Diperhatikan dalam Harga

| Risiko | Dampak Biaya | Mitigasi |
|---|---|---|
| **dlib Compilation** | Hosting AI tidak sembarangan (butuh native build) | Naikkan skenario hosting ke min 4GB RAM, atau pakai Docker pre-built |
| **Kualitas Model AI** | Jika akurasi SVM kurang dari 70%, client minta retrain | Siapkan budget retrain model ~Rp 5-8jt tambahan jika dataset bertambah |
| **Performance Flutter Map** | Tile loading lambat di area rural | Tambahkan cache tile di app (sudah ada `cached_network_image`, extend untuk map) |
| **Play Store Approval** | App bisa ditolak Google karena "mengumpulkan data user tanpa izin" | Pastikan Privacy Policy + Data Disclosure di Play Store listing — masukkan di Section 5 biaya publikas |

### 8.2 Saran Negosiasi dengan Klien

1. **Kalau client bilang "terlalu mahal"**: Potong scope (misal: AI service dibuat statis dulu, atau iOS dicabut) — jangan potong kualitas / jam kerja pengembang.
2. **Jangan jual source code sebelum LUNAS**: Serahkan hanya APK debug di termin 2 & 3, full source code di Termin 4 (pelunasan).
3. **Masukkan klausul perubahan scope**: Setiap perubahan fitur di luar draf awal = Change Request = biaya tambahan per jam (Rp 180.000/jam untuk Flutter, Rp 220.000/jam untuk Python/ML).
4. **Garansi maintenance 3 bulan GRATIS** untuk Paket Standar ke atas — ini nilai jual besar untuk client.

### 8.3 Format Invoice / Kwitansi

Struktur invoice yang disarankan:
```
1. PENGEMBANGAN SISTEM INFORMASI TRIME
   a. Mobile Application (Flutter)        Rp ........
   b. AI Recognition Service (Python)     Rp ........
   c. Dokumentasi Proyek                  Rp ........

2. BIAYA PUBLIKASI DAN INFRASTRUKTUR
   a. Google Play Console                 Rp 400.000
   b. Hosting & Domain (1 tahun)          Rp ........

3. BIAYA PELATIHAN & TRANSFER ILMU        Rp ........ (opsional)

4. PAJAK PPN 11%                          Rp ........ (jika PT)
---------------------------------------------------------
TOTAL                                       Rp ........
```

---

## RANGKUMAN CEPAT

| Yang Perlu Diingat | Angka |
|---|---|
| **Biaya Pengembangan (Cost)** | **Rp 95 – 109 Juta** |
| **Harga Jual Minimal (Margin 30%)** | **Rp 125 Juta** |
| **Harga Jual Recommended (Paket Standar)** | **Rp 150 Juta** |
| **Harga Jual Premium (Full Support)** | **Rp 185 – 200 Juta** |
| **Biaya Operasional / bulan** | **Rp 50rb – 835rb** |
| **Struktur Pembayaran** | **40% - 30% - 20% - 10%** |
| **Maintenance Bulanan** | **Rp 2,5 – 4 Juta / bulan** |

---

---

## 9. PAKET KHUSUS: HARGA PATAH Rp 26,5 JUTA

> **Target Harga Jual:** **Rp 26.500.000** (dua puluh enam juta lima ratus ribu rupiah)  
> **Catatan Penting:** Harga ini **78–80% lebih murah** dari MVP standar Rp 125 juta, sehingga **scope harus disesuaikan secara drastis**. TIDAK bisa menyertakan semua fitur yang ada di codebase sekarang. Paket ini cocok untuk: MVP ultra-minimal, klien dengan budget ketat, atau untuk memenangkan tender persaingan harga.

---

### 9.1 Scope yang DAPAT Disediakan (INCLUDE)

Agar harga tetap sehat dengan margin wajar, berikut fitur-fitur yang **masuk** dalam paket 26,5 juta:

#### ✅ Mobile App (Flutter) — Android Only
| Fitur | Detail |
|---|---|
| **Splash Screen** | Logo TRIME + loading 2 detik |
| **Login (tanpa OTP)** | Hanya **Login via Nomor HP + Password static** (didaftarkan manual), tidak ada OTP WA/SMS real |
| **1 Role User SAJA** | Hanya **role PELANGGAN** (kapster dan mitra belum ada dashboard terpisah) |
| **Home Page** | List barbershop dengan card sederhana (gambar + nama + rating + jarak) |
| **Detail Barbershop** | Foto, alamat, deskripsi, list kapster, jam operasional |
| **Map View SEDERHANA** | `flutter_map` + CartoDB Positron, **marker static** (input manual lat/lng di hardcode), TANPA geolocator GPS real |
| **Booking SEDERHANA** | Pilih tanggal + slot waktu (30 menit), booking disimpan di **SharedPreferences LOCAL SAJA** (TIDAK ke Supabase), status: pending/selesai |
| **Favorite** | Simpan favorit barbershop di SharedPreferences local |
| **Profil Akun** | Halaman edit nama + nomor HP (data local) |
| **Theme** | Menggunakan design tokens yang sudah ada (color/spacing) + Google Fonts |
| **3 Shared Widget** | Card Barbershop, Primary Button, Rating Stars (saja) |
| **Bottom Nav Bar** | 4 tab: Home, Map, Booking, Akun |

#### ✅ AI Recognition (TAPI — SIMPLIFIED)
| Fitur | Detail |
|---|---|
| **Rekomendasi Rambut STATIS** | TIDAK pakai FastAPI server + dlib. Ganti dengan: **pilihan dropdown manual bentuk wajah (6 opsi: Oval, Kotak, Bundar, Panjang, Hati, Diamond)** → menampilkan 3 rekomendasi gaya rambut berbasis aturan (rule-based) saja. TANPA upload foto, TANPA analisis AI. |
| **Gambar Gaya Rambut** | 3 gambar static per bentuk wajah (total 18 gambar) yang di-generate AI sekali di awal |

#### ✅ Dokumentasi (Minimal)
| Dokumen | Detail |
|---|---|
| **Panduan Pengguna (Ringkas)** | 1 file MD untuk role Pelanggan saja |
| **Source Code** | Di-serahkan saat lunas (tanpa dokumentasi teknis mendalam) |

#### ✅ Deployment (Minimal)
| Item | Detail |
|---|---|
| **APK Debug** | 1 build APK debug untuk testing di Android |
| **TIDAK termasuk** | Biaya Play Console, hosting, domain, atau publish ke Play Store |

---

### 9.2 Scope yang TIDAK Termasuk (EXCLUDE) — Jangan Lupa Sampaikan ke Klien!

Ini bagian PENTING untuk disampaikan secara EXPLICIT ke klien agar tidak ada ekspektasi yang salah:

| ❌ TIDAK Termasuk | Alasan Dikecualikan |
|---|---|
| **OTP WhatsApp/SMS Real** | Butuh biaya langganan Twilio/Meta + integrasi yang kompleks. Ganti dengan password static. |
| **Google Sign-In / Firebase Auth** | Butuh konfigurasi Firebase project, SHA-1, verifikasi domain. |
| **Role Kapster & Mitra Barber** | Dua dashboard terpisah itu butuh effort ~200 jam coding. Di skip untuk paket ini. |
| **Supabase Backend / Database Online** | Booking & user tersimpan LOCAL (SharedPreferences). TIDAK sync antar device. |
| **AI Face Shape Detection (Upload Foto)** | dlib + OpenCV + ML inference butuh server mahal + training data mahal. |
| **GPS Geolocator Real** | Deteksi lokasi, auto-center kamera, izin runtime, handling GPS off — complexity tinggi. Ganti marker static. |
| **Mini-Map di Detail Page** | Skip untuk kurangi effort. |
| **iOS Version** | Hanya Android. iOS = Apple Developer $99/tahun + effort setup XCode. |
| **Publish ke Play Store** | $25 Google Play Console + proses listing + asset grafis (feature graphic, icon, screenshot) — ini cost klien. |
| **Chat In-App, Push Notification** | Dua fitur ini bernilai ~Rp 20 jutaan jika di-include. |
| **Sistem Rating User-submitted** | Rating ditampilkan tapi static (hardcoded), bukan input user real. |
| **Badge Exclusive** | Skip untuk kurangi effort. |
| **Maintenance Gratisan** | Tidak ada garansi maintenance. Maintenance = biaya tambahan terpisah. |
| **Training / Workshop** | Tidak ada pelatihan untuk tim klien. |

> **Pesan untuk klien:** "Paket 26,5 Juta ini adalah **starter pack / launching pad** — semua fitur excluded di atas bisa ditambahkan nanti bertahap dengan biaya terpisah ketika budget sudah ada."

---

### 9.3 Breakdown Detail Harga Rp 26,5 Juta

#### 9.3.1 Breakdown Berdasarkan Biaya vs Margin

| Komponen | Nominal (Rp) | % dari Harga Jual |
|---|---|---|
| **COGS / Biaya Produksi (Effort Pengembang)** | **Rp 21.200.000** | **80%** |
| **Lain-lain / Contingency (Listrik, Wifi, dll)** | **Rp 530.000** | **2%** |
| **LABA / MARGIN KOTOR** | **Rp 4.770.000** | **18%** |
| --- | --- | --- |
| **TOTAL HARGA JUAL** | **Rp 26.500.000** | **100%** |

> **Catatan Margin 18%:** Ini margin tipis (standar agency 30–60%), **jangan sampai ada scope creep** (penambahan fitur dadakan). Kalau klien minta 1 fitur tambahan saja, langsung tagih Change Request minimal Rp 1,5 juta.

---

#### 9.3.2 Breakdown Biaya Bahan (Material Cost) — Rp 0 (Nol Rupiah)

Untuk paket ini, **tidak ada biaya bahan/lisensi sama sekali** (semua pakai teknologi free/open-source):

| Bahan/Lisensi | Harga | Keterangan |
|---|---|---|
| Flutter SDK | FREE | Open-source dari Google |
| flutter_map + CartoDB Positron Tiles | FREE | Zero-cost mapping strategy ✅ |
| Google Fonts | FREE | License SIL OFL 1.1 |
| SharedPreferences (local storage) | FREE | Plugin Flutter resmi |
| Android Studio + Gradle | FREE | Google official tools |
| Python Libraries (jika ada nanti) | FREE | Semua open-source |
| **TOTAL BIAYA BAHAN** | **Rp 0** | Semua pakai free stack |

> Alasan biaya bahan nol: Karena semua backend, AI, storage kita buat FULL LOCAL dan pakai OSS (Open Source Software). Client hanya bayar **biaya jasa coding murni**.

---

#### 9.3.3 Breakdown Biaya Jasa (Development Effort) — Rp 21.200.000

Ini bagian terbesar (80% dari harga jual). Breakdown per-modul dengan tarif **junior-mid level = Rp 100.000/jam** (lebih rendah dari mid-level 150k, sesuai paket harga murah):

| # | Modul / Fitur | Effort (Jam) | Tarif/Jam (Rp) | Subtotal (Rp) | Keterangan Detail |
|---|---|---|---|---|---|
| 1 | **Project Setup & Config** | 8 | 100.000 | 800.000 | Init Flutter project, pubspec dependencies, analysis_options, Android manifest, splash screen config |
| 2 | **Theme System (Design Tokens)** | 8 | 100.000 | 800.000 | Color tokens, spacing tokens, app_theme.dart, Google Fonts setup |
| 3 | **Shared Widgets (3 widget)** | 16 | 100.000 | 1.600.000 | PrimaryButton, CardBarbershop, RatingStars (tanpa Badge, tanpa SmartImage, tanpa CardKapster) |
| 4 | **Bottom Nav Bar + App Scaffold** | 8 | 100.000 | 800.000 | 4 tab: Home, Map, Booking, Akun — scaffold skeleton navigation |
| 5 | **Auth: Login Screen (Simple)** | 16 | 100.000 | 1.600.000 | Form No HP + Password, validasi, simpan session via SharedPreferences local, TANPA OTP, TANPA Firebase |
| 6 | **Splash Screen** | 4 | 100.000 | 400.000 | Logo TRIME 2 detik → redirect ke login/home |
| 7 | **Home Page: List Barbershop** | 24 | 100.000 | 2.400.000 | ListView dengan CardBarbershop, dummy data hardcoded 10 barbershop, pull to refresh sederhana |
| 8 | **Detail Barbershop Page** | 24 | 100.000 | 2.400.000 | Hero image, deskripsi, jam operasional, list kapster (static), button booking (navigasi ke booking page), TANPA mini-map |
| 9 | **Map View (Marker Static)** | 20 | 100.000 | 2.000.000 | flutter_map + CartoDB, 10 marker hardcoded, tap marker → buka detail page, TANPA GPS/geolocator |
| 10 | **Booking System (Local)** | 32 | 100.000 | 3.200.000 | Kalender tanggal, slot 30 menit (08:00-21:00), pilih kapster, submit booking → simpan ke SharedPreferences, halaman My Booking dengan status pending/selesai |
| 11 | **Favorite Feature (Local)** | 8 | 100.000 | 800.000 | Toggle favorite di card/ detail, simpan ke SharedPreferences, halaman list favorite |
| 12 | **Profil Akun Page** | 8 | 100.000 | 800.000 | Tampil nama + no HP (hardcoded dari login), button logout (clear session) |
| 13 | **Rekomendasi Rambut STATIC (Rule-Based)** | 16 | 100.000 | 1.600.000 | Dropdown pilih 6 bentuk wajah → tampil 3 card rekomendasi gaya rambut (gambar static + nama gaya + alasan), TANPA upload foto/AI |
| 14 | **Asset: Generate Gambar AI** | 12 | 80.000 | 960.000 | 10 gambar interior barbershop + 18 gambar gaya rambut (6 bentuk wajah × 3 gaya) via Trae Text-to-Image API |
| 15 | **Integrasi & Debugging** | 32 | 100.000 | 3.200.000 | Pastikan navigasi antar halaman lancar, null safety, perbaiki bug yang muncul saat test APK, 0 critical error |
| 16 | **Build APK Debug + QA Ringan** | 12 | 80.000 | 960.000 | Flutter build APK debug, install di 1-2 perangkat Android fisik, test manual flow utama, catat bug ringkas |
| 17 | **Dokumentasi Pengguna (Ringkas)** | 4 | 100.000 | 400.000 | 1 file MD: Cara install APK, login, booking, favorite, lihat rekomendasi rambut |
| --- | --- | --- | --- | --- | --- |
| | **TOTAL JASA** | **252 jam** | — | **Rp 21.200.000** | |

> **Tarif Rp 100.000/jam** ini adalah tarif **junior-mid entry level** (atau rate "promo" untuk menang project). Jika kamu sebagai pengembang solo, ini rate yang acceptable untuk dapet pengalaman + portfolio.

---

#### 9.3.4 Breakdown per Kategori Fitur untuk Presentasi ke Klien

Agar mudah dipresentasikan, bagikan menjadi 4 bagian besar yang mudah dipahami non-teknis:

| Kategori | Harga (Rp) | Isinya |
|---|---|---|
| **A. Desain & Tampilan Aplikasi** | **Rp 3.200.000** | Theme system design tokens, 3 shared widget custom, Bottom Nav, Splash Screen, asset gambar AI |
| **B. Autentikasi & Profil Pengguna** | **Rp 2.800.000** | Login No HP + Password (local), session management, halaman Profil Akun, Logout |
| **C. Fitur Marketplace Barbershop** | **Rp 10.800.000** | Home List Barbershop, Detail Barbershop, Map View Static Marker, Booking System (local slot 30 menit), Favorite Barbershop |
| **D. Fitur Rekomendasi Rambut** | **Rp 1.600.000** | Pilih bentuk wajah manual, 3 rekomendasi gaya rambut per kategori, gambar referensi AI |
| **E. QA, Build APK, & Dokumentasi** | **Rp 2.320.000** | Integrasi seluruh modul, debugging, build APK debug, test manual di HP, panduan pengguna ringkas |
| **F. Overhead & Laba (18%)** | **Rp 5.780.000** | Kontinjensi + margin untuk pengembang |
| --- | --- | --- |
| **TOTAL** | **Rp 26.500.000** | |

---

### 9.4 Saran Struktur Pembayaran untuk Paket 26,5 Juta

Karena margin tipis, **struktur pembayaran harus ketat** agar arus kas aman:

| Termin | % | Nominal (Rp) | Waktu Bayar | Deliverable |
|---|---|---|---|---|
| **DP (Termin 1)** | **50%** | **Rp 13.250.000** | Hari ini / kontrak tanda tangan | Project kickoff, repo setup, kirim desain wireframe PDF 1 halaman |
| **Termin 2** | **30%** | **Rp 7.950.000** | Setelah UI + 50% fitur jadi (tampilan home + detail + map + login) | Kirim APK demo v0.5 untuk client coba di HP |
| **Termin 3 (Pelunasan)** | **20%** | **Rp 5.300.000** | Semua fitur SELESAI & QA pass | Kirim APK debug final + source code via ZIP/GitHub (setelah uang masuk) |

> **JANGAN berikan source code sebelum LUNAS 100%** — karena ini harga sudah sangat murah, risiko client "kabur" harus di-minimalisir.

---

### 9.5 Contoh Surat Penawaran / Invoice untuk Paket Rp 26,5 Juta

Bisa copy-paste ini untuk dikirim ke klien:

```
SURAT PENAWARAN JASA PENGEMBANGAN APLIKASI TRIME (PAKET STARTER)
----------------------------------------------------------------

1. PENGEMBANGAN MOBILE APPLICATION (ANDROID) — FLUTTER
   a. Design System & UI Components              Rp 3.200.000
   b. Autentikasi Login & Profil User            Rp 2.800.000
   c. Marketplace (List + Detail + Map + Booking + Favorite)  Rp 10.800.000
   d. Fitur Rekomendasi Gaya Rambut              Rp 1.600.000
   e. Quality Assurance, Build APK, Dokumentasi  Rp 2.320.000
   f. Overhead & Margin                          Rp 5.780.000
----------------------------------------------------------------
SUBTOTAL                                         Rp 26.500.000
PPN 0% (jika perorangan/PT belum wajib PPN)      Rp 0
----------------------------------------------------------------
TOTAL YANG HARUS DIBAYAR                         Rp 26.500.000


CATATAN PENTING (DIBACA SEBELUM TANDA TANGAN):
- Paket ini hanya untuk 1 role user (Pelanggan)
- Booking tersimpan di local device (tidak sync cloud)
- Rekomendasi rambut berdasarkan pilihan bentuk wajah manual
  (bukan upload foto / AI detection)
- Map menggunakan marker statis (tanpa deteksi lokasi GPS real)
- Tidak termasuk biaya publish ke Google Play Store
- Tidak termasuk maintenance & update fitur setelah selesai
- Penambahan fitur di luar scope = Change Request dengan
  tarif Rp 150.000/jam (minimal 10 jam per request)


SKEMA PEMBAYARAN:
- Termin 1 (DP 50%)    : Rp 13.250.000  -> Saat kontrak
- Termin 2 (30%)       : Rp 7.950.000   -> Setelah UI + 50% fitur
- Termin 3 (Lunas 20%) : Rp 5.300.000   -> Setelah final & serah terima
```

---

### 9.6 Daftar Harga Upgrade (Up-Sell Setelah Project Selesai)

Ini peluang kamu untung lebih banyak nanti, ketika klien sudah suka dan mau menambah fitur. **Siapkan daftar ini sebelum menandatangani kontrak**, sehingga klien tahu kalau fitur excluded tidak akan "diberi gratis":

| # | Fitur Upgrade | Harga Upgrade (Rp) | Kapan Bisa Ditawarkan |
|---|---|---|---|
| 1 | **Publish ke Google Play Store** | + Rp 1.500.000 | Setelah APK final jadi |
| 2 | **OTP WhatsApp Real (Twilio)** | + Rp 8.000.000 | Saat klien punya user 100+ orang |
| 3 | **Dashboard Kapster (Role ke-2)** | + Rp 8.500.000 | Fase 2, ketika ada mitra kapster |
| 4 | **Dashboard Mitra Barber (Role ke-3)** | + Rp 9.500.000 | Fase 2, ketika ada mitra barbershop |
| 5 | **Integrasi Supabase (Cloud Sync)** | + Rp 12.000.000 | Saat booking perlu cross-device |
| 6 | **AI Face Shape Detection (Upload Foto)** | + Rp 20.000.000 | Fase 3, monetisasi fitur premium |
| 7 | **GPS Geolocator + Auto-Center Map** | + Rp 4.000.000 | Kapan saja (effort rendah, high impact) |
| 8 | **iOS Version (App Store)** | + Rp 15.000.000 | Saat user banyak yang pakai iPhone |
| 9 | **Push Notification Booking Reminder** | + Rp 6.000.000 | Setelah Supabase terintegrasi |
| 10 | **Maintenance Bulanan** | Rp 1.200.000/bln | Kontrak bulanan mulai bulan ke-2 |
| --- | --- | --- | --- |
| | **Total jika semua upgrade diambil** | **Rp 85.500.000** | Sama dengan MVP standar |

> Strategi jitu: **Jual murah dulu (Rp 26,5 jt) buat dapet project**, **dapatkan trust klien**, **jual upgrade bertahap 3-6 bulan kedepan**. Total akhir pendapatan bisa tembus **Rp 100 Juta+** dari klien yang sama.

---

### 9.7 Risiko yang Perlu Diwaspadai (Paket Murah)

| Risiko | Dampak | Solusi |
|---|---|---|
| **Scope Creep (Klien minta tambah fitur gratis)** | Margin ludes, kerja jadi tidak bayar | TULIS secara hitam-putih di kontrak apa saja yang INCLUDE/EXCLUDE. Setiap request baru = Change Request + form tertulis + bayar dulu. |
| **Klien bilang "kan sebelumnya Rp 125 juta, sekarang murah banget pasti jelek"** | Klien ragu kualitas | Jelaskan perbedaan scope dengan lisan + dokumen: "Rp 26,5 Juta = starter pack (8 modul inti). Rp 125 Juta = full version (25+ modul, 3 role, AI real, cloud, iOS+Android)." |
| **Effort melebihi 252 jam** | Margin jadi minus | Batasi waktu per-modul. Jika 1 modul lebih dari estimasi, potong kualitas non-kritis (misal: skip animasi kecil, atau tampilkan text saja bukan card mewah). |
| **APK tidak jalan di HP klien** | Repute buruk | Test minimal di 2 perangkat Android berbeda sebelum kirim APK demo. |
| **Klien minta refund di tengah jalan** | Uang hilang, kerja sia-sia | DP 50% TIDAK BOLEH di-refund dengan alasan apapun (masuk di klausul kontrak). |

---

### 9.8 Ringkasan Paket Rp 26,5 Juta

| Ringkasan Cepat | Angka |
|---|---|
| **Harga Jual Final** | **Rp 26.500.000** |
| **Biaya Bahan (Material)** | **Rp 0** (Semua OSS free) |
| **Biaya Jasa (Effort)** | **Rp 21.200.000** (252 jam @ Rp 100k/jam) |
| **Margin Kotor** | **Rp 4.770.000** (18%) |
| **Fitur Utama Disediakan** | Login, Home, Detail, Map Static, Booking Local, Favorite, Profil, Rekomendasi Rambut Rule-Based |
| **Platform** | **Android Only** (APK debug) |
| **Role User** | Hanya **Pelanggan** (1 role) |
| **Storage** | **Local SharedPreferences** (bukan cloud) |
| **Pembayaran** | **50% - 30% - 20%** |
| **Potensi Upsell Total** | **Rp 85.500.000** (jika semua upgrade diambil) |

---

---

## 10. ESTIMASI BIAYA SOLO DEVELOPER (KERJA SENDIRI DALAM 1 BULAN)

> **Konteks:** Kamu mengerjakan sendiri proyek ini sebagai **solo developer** dalam waktu **1 bulan (±22 hari kerja)**. Kita hitung biaya dari sudut pandang **pengeluaran riil yang keluar dari kantongmu** (out-of-pocket cost) + **opportunity cost** (nilai waktu yang kamu korbankan).

---

### 10.1 Perbandingan Dua Sudut Pandang Biaya

| Jenis Biaya | Penjelasan | Cocok Untuk |
|---|---|---|
| **A. Biaya Out-of-Pocket (Pengeluaran Riil)** | Uang beneran yang keluar dari rekening: listrik, wifi, hosting, beli aset, dll. | Menghitung "modal berapa yang harus disiapkan" |
| **B. Biaya + Opportunity Cost** | Out-of-pocket + harga waktu jam kerja kamu. Ini biaya yang "sesungguhnya" (jika kamu tidak ngerjain TRIME, kamu bisa dapat uang dari projek lain). | Untuk kalkulasi bisnis / menentukan harga jual yang sehat |

---

### 10.2 SKENARIO A: BIAYA OUT-OF-POCKET (PENGELUARAN RIIL SAJA)

Ini hitungan **uang beneran yang harus kamu keluarkan dari kantong** selama 1 bulan mengerjakan TRIME paket Rp 26,5 Juta.

#### 10.2.1 Biaya Bulanan Rutin (Operasional Bulanan)

| Item | Biaya / Bulan (Rp) | Keterangan |
|---|---|---|
| **Listrik Rumah (tambahan karena coding)** | 300.000 – 450.000 | Laptop + 2 monitor menyala 8-10 jam/hari, 22 hari. Estimasi kenaikan listrik 30% dari normal. |
| **Internet WiFi** | 250.000 – 400.000 | Minimal 30 Mbps (butuh cepat untuk download dependency Flutter, push GitHub, generate gambar AI). |
| **Kuota Cadangan (jika WiFi error)** | 50.000 – 100.000 | Kuota hotspot HP untuk emergency 1-2 hari. |
| **Makan & Kopi (tambahan coding marathon)** | 600.000 – 900.000 | 22 hari × Rp 30-40rb/hari (kopi + snack saat overtime). Opsional tapi realistis 😅 |
| **Cloud Storage Backup (GitHub + Google Drive)** | FREE – 50.000 | GitHub Private repo FREE, Google Drive 15GB FREE, atau beli Google One 100GB jika perlu. |
| --- | --- | --- |
| **Subtotal Rutin / Bulan** | **Rp 1.200.000 – Rp 1.900.000** | |

#### 10.2.2 Biaya One-Time (Sekali Bayar Selama Proyek, Bisa Dipakai Berulang)

| Item | Biaya Sekali (Rp) | Keterangan | Dipakai Ulang? |
|---|---|---|---|
| **Alat Kerja (Laptop)** | TIDAK DIHITUNG | Jika kamu sudah punya laptop, anggap ini sunk cost. Jika belum punya, ini biaya besar (Rp 8-15 juta untuk laptop layak Flutter). | ✅ Bisa dipakai proyek lain |
| **Flutter SDK + Android Studio** | FREE | Resmi dari Google. | ✅ Selamanya |
| **Android Device Testing (HP Android)** | TIDAK DIHITUNG | Pakai HP pribadi. Jika harus beli HP testing baru: Rp 2-3 juta (entry level Android 11+). | ✅ Bisa dipakai berulang |
| **Google Play Console (jika akan publish)** | 400.000 | ($25, sekali bayar seumur hidup). **TIDAK WAJIB** untuk paket Rp 26,5 jt (hanya APK debug). | ✅ Sekali bayar untuk selamanya, semua app kamu |
| **Trae AI Image API (Generate gambar barbershop + rambut)** | FREE / TERCOVER | Sudah termasuk kapasitas project ini via Trae IDE. | ✅ Tergantung kuota project |
| **Domain (opsional, untuk AI service nanti)** | 250.000 – 350.000 | Contoh: `trime-app.com` per tahun. **SKIP untuk paket starter.** | 1 tahun |
| **Coffee / Spotify / Coding Playlist** | (sudah termasuk di Makan & Kopi) | — | — |
| --- | --- | --- | --- |
| **Subtotal One-Time (minimal)** | **Rp 0 – Rp 400.000** | Jika publish baru keluar Rp 400rb. | |

#### 10.2.3 Rekap Biaya Out-of-Pocket Total 1 Bulan

| Kategori | Skenario Hemat (Rp) | Skenario Normal (Rp) |
|---|---|---|
| **Rutin (Operasional)** | 1.200.000 | 1.900.000 |
| **One-Time** | 0 | 400.000 |
| --- | --- | --- |
| **TOTAL KELUAR DARI KANTONG** | **Rp 1.200.000** | **Rp 2.300.000** |

> 🎉 **Wow! Cuma sekitar Rp 1,2 – 2,3 juta yang benar-benar keluar dari kantongmu.** Ini karena kita pakai **stack 100% open-source/free** + kamu sudah punya alat kerja (laptop + HP). Sisanya **profit murni** jika kamu jual seharga Rp 26,5 juta.

---

### 10.3 SKENARIO B: TAMBAH OPPORTUNITY COST (NILAI WAKTU KAMU)

Ini **biaya sesungguhnya** dari sudut pandang bisnis. Karena setiap jam kamu ngerjain TRIME = setiap jam kamu **tidak bisa** ngerjain projek lain yang menghasilkan uang.

#### 10.3.1 Berapa Nilai 1 Jam Kerjamu?

Kita hitung berdasarkan rate freelance standar untuk skill Flutter + Python dasar:

| Level Developer | Rate/Jam (Rp) | Asumsi Jika Kamu Level Ini |
|---|---|---|
| **Entry Level / Junior (baru lulus bootcamp, < 1 tahun)** | **Rp 50.000 – 80.000** | Jika kamu baru belajar Flutter 3-6 bulan, projek TRIME adalah projek pertama/ kedua kamu. |
| **Junior-Mid (1-2 tahun pengalaman)** | **Rp 100.000 – 130.000** | Sudah pernah deliver 2-3 app Flutter, tahu state management, bisa debugging dasar. **Ini level yang sesuai untuk paket starter TRIME.** |
| **Mid Level (2-3 tahun)** | Rp 150.000 – 180.000 | Bisa handle 3 role user, integrasi backend kompleks. Kalau kamu level ini, sebaiknya jangan jual cuma Rp 26,5 jt (harganya terlalu murah untukmu). |
| **Senior (3+ tahun)** | Rp 200.000+ | Expert di Flutter, CI/CD, performance optimization. |

#### 10.3.2 Berapa Total Jam Kerja dalam 1 Bulan?

Target selesai **1 bulan = 22 hari kerja** (dengan target 8 jam efektif/hari). Tapi realistis untuk solo developer, **efektif cuma 6-7 jam/hari** (sisanya istirahat, scroll sosmed, debugging bug random).

| Asumsi Jam Efektif | Total Jam/Bulan |
|---|---|
| 22 hari × 6 jam/hari | **132 jam** (realistis untuk manusia biasa) |
| 22 hari × 7 jam/hari | **154 jam** (agak kerja keras) |
| 22 hari × 8 jam/hari | **176 jam** (overtime, fokus banget) |

> Tapi ingat! Estimasi effort di Section 9 untuk paket Rp 26,5 jt itu **252 jam total**. Jadi jika kamu target selesai **1 BULAN**, kamu harus kerja **sekitar 11,5 jam/hari** (252 ÷ 22 hari). Ini **kerja lembur tiap hari** (setara kerja fulltime + 3-4 jam overtime setiap hari).
>
> Solusi realistis: Perpanjang deadline jadi **6 minggu (±30 hari)** = 8,4 jam/hari, atau **7 minggu** = nyaman 7 jam/hari tanpa lembur berlebihan.

#### 10.3.3 Kalkulasi Opportunity Cost

Pakai **rate Junior-Mid Rp 100.000/jam** (sesuai paket starter):

| Jika Kamu Selesai Dalam | Total Jam Kerja | Opportunity Cost (@ Rp 100k/jam) | + Out-of-Pocket | **Biaya TOTAL (Sesi B)** |
|---|---|---|---|---|
| **1 bulan (22 hari, 11,5 jam/hari — LEMBUR PARAH)** | ~252 jam | Rp 25.200.000 | Rp 1,9 jt | **Rp 27.100.000** |
| **6 minggu (30 hari, 8,4 jam/hari — MASIH AKAN)** | ~252 jam | Rp 25.200.000 | Rp 2,5 jt (× 1,3 bulan) | **Rp 27.700.000** |
| **7 minggu (35 hari, 7,2 jam/hari — NYAMAN)** | ~252 jam | Rp 25.200.000 | Rp 2,9 jt (× 1,6 bulan) | **Rp 28.100.000** |

> ⚠️ **PENTING!** Jika kamu jual paket ini cuma **Rp 26,5 juta**, dan Opportunity Cost saja sudah **Rp 25,2 juta** (plus operasional Rp 1,9 jt), artinya **margin kamu cuma sekitar Rp -600.000 s/d -1,6 juta (RUGI tipis)** jika dikerjakan dalam 1 bulan dengan rate Rp 100k/jam.
>
> **Ini alasan mengapa:**
> - Harga Rp 26,5 juta **hanya masuk akal jika:**
>   1. Kamu rate **Entry Level @ Rp 50-60k/jam** → Opp Cost cuma Rp 12,6–15,1 jt → Profit **Rp 9,4–12,4 jt**
>   2. Atau kamu **extend deadline jadi 1,5 bulan** dan naikkan harga jadi Rp 30–35 juta
>   3. Atau ini **projek portfolio pertama** kamu, uangnya dihitung nanti dari up-sell bulan-bulan berikutnya

---

### 10.4 RINGKASAN FINAL: BERAPA BIAYA DEVELOPER DALAM 1 BULAN?

| Pertanyaan | Jawaban Singkat |
|---|---|
| **Uang beneran yang keluar dari kantong?** | **Cuma Rp 1,2 – 2,3 juta** (listrik, wifi, makan, kopi). |
| **Biaya sebenarnya (Opportunity Cost + Operasional)?** | **Rp 27 – 28 juta** jika kamu valued @ Rp 100k/jam. |
| **Apakah Rp 26,5 jt cukup untuk bayar developer lain?** | **TIDAK.** Gaji freelance Flutter sebulan saja minimal Rp 5–8 juta, ditambah AI Python Rp 3–5 juta = sudah Rp 8–13 juta tanpa margin. Lebih realistis jika dikerjakan **solo developer junior/motivated beginner**. |
| **Berapa profit bersihku (uang yang benar-benar netto ke tabungan)?** | Jika out-of-pocket Rp 2 jt → **Rp 26,5 jt - Rp 2 jt = Rp 24,5 JUTA PROFIT KOTOR.** Tapi jika kamu hitung "gaji" untuk dirimu sendiri @ Rp 50k/jam → Rp 252 jam × 50k = Rp 12,6 jt gaji + sisanya Rp 11,9 jt laba. |
| **Berapa "gaji" kamu per bulan dari projek ini?** | Jika selesai 1 bulan → **Rp 24,5 juta / bulan** (setelah potong operasional). Itu **gaji di atas rata-rata fresh graduate IT!** |

---

### 10.5 SUPAYA TETAP PROFITABLE DI HARGA Rp 26,5 JUTA (TIPS SOLO DEV)

1. **Kurangi scope lagi jika bisa:** Jika 252 jam terasa terlalu banyak, potong:
   - Skip fitur Favorite (hemat 8 jam = Rp 800rb if dihitung)
   - Skip rekomendasi rambut (hemat 16 jam = Rp 1,6 jt)
   - Map View bisa diganti list dengan card "Alamat + Link Google Maps" (hemat 20 jam = Rp 2 jt)
   - **Total potongan: 44 jam = ~Rp 4,4 juta lebih cepat selesai**

2. **Reuse code sebesar-besarnya:** 33 file di codebase TRIME ini **sudah ada dan bisa jadi referensi copy-paste!** Kalau kamu pakai ini sebagai template, effort bisa berkurang **30-50%** → dari 252 jam jadi **126-176 jam** → selesai 1 bulan dengan 6-8 jam/hari normal! ✨

3. **Jangan perfectionist di tahap awal:** Animasi kecil, pixel-perfect yang cuma 2px off, atau error handling edge case — bisa ditambahkan nanti sebagai "premium polish" berbayar. Yang penting flow UTAMA jalan (login → lihat list → booking → simpan).

4. **Naikkan harga tipis jika memungkinkan:** Rp 26,5 → **Rp 28,5 juta** (naik Rp 2 juta) — itu cuma beda tipis di mata klien, tapi **margin kamu langsung naik 10%**.

---

---

*Dokumen ini dibuat berdasarkan analisis codebase tanggal 19 Agustus 2026. Harga dapat berubah seiring penambahan fitur atau perubahan scope proyek.*
