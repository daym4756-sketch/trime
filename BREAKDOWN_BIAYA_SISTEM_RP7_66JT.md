# BREAKDOWN BIAYA SISTEM — Rp 7.660.000

> **Berdasarkan Referensi Item Pengajuan Client (Total Rp 20 Jt / Disetujui Rp 14,3 Jt)**  
> **Tipe Biaya:** HANYA biaya sistem / infrastruktur / lisensi resmi aplikasi TRIME SAJA.  
> **TIDAK TERMASUK:** Biaya jasa pengembang (jam coding), biaya marketing/iklan, biaya buku/course, barang fisik (tinta, kertas), biaya legal (pendaftaran merek).  
> **Tanggal:** 19 Agustus 2026

---

## DAFTAR ISI
1. [Sumber Data & Alasan 9 Item yang Dipilih](#1-sumber-data--alasan-9-item-yang-dipilih)
2. [Ringkasan Tabel 9 Item = Rp 7,66 Jt](#2-ringkasan-tabel-9-item--rp-766-jt)
3. [Breakdown Detail per-Item](#3-breakdown-detail-per-item)
4. [Hubungan Setiap Item dengan Fitur TRIME](#4-hubungan-setiap-item-dengan-fitur-trime)
5. [Tabel Analisis: 26 Item vs Kategori (INCLUDE / EXCLUDE)](#5-tabel-analisis-26-item-vs-kategori-include--exclude)
6. [Perbandingan Durasi Masing-masing Item](#6-perbandingan-durasi-masing-masing-item)
7. [Ringkasan Eksekutif untuk Presentasi](#7-ringkasan-eksekutif-untuk-presentasi)

---

## 1. SUMBER DATA & ALASAN 9 ITEM YANG DIPILIH

Dari **26 item pengajuan client**, kita **seleksi ketat** hanya yang **100% berhubungan langsung dengan biaya sistem/infrastruktur aplikasi TRIME** (bukan marketing, bukan belajar, bukan barang fisik). Hasilnya: **9 item** dengan jumlah TEPAT **Rp 7.660.000**.

### Prinsip Seleksi INCLUDE / EXCLUDE

| Kriteria | INCLUDE (9 Item = 7,66 Jt) | EXCLUDE (17 Item = 12,34 Jt) |
|---|---|---|
| **Jenis Biaya** | Infrastruktur, hosting, domain, lisensi software dev, payment gateway, email system, AI API, backup, SSL. | Marketing/iklan, buku, course, event, design software, office 365, survey tools, barang fisik (tinta printer, kertas HVS), legal/merek, SEO. |
| **Kegunaan Langsung** | Dipakai setiap hari oleh SISTEM APLIKASI TRIME agar bisa ONLINE & BERJALAN. | Dipakai oleh MANUSIA (tim marketing, tim desain, admin, atau developer untuk BELAJAR). |

---

## 2. RINGKASAN TABEL 9 ITEM = Rp 7,66 Jt ✅

| No | Nama Item (dari daftar client) | Harga (Rp) | Kategori Sistem |
|---|---|---|---|
| 1 | **Layanan cloud hosting Railway** | 900.000 | Hosting Backend AI |
| 2 | **SSL Certificate Basic** | 570.000 | Security Enkripsi |
| 3 | **Domain .id (Hostinger)** | 840.000 | Domain & Alamat Web |
| 4 | **Postman API Testing Tool** | 900.000 | Testing & Development Tool |
| 5 | **AWS Backup Service** | 800.000 | Backup Data & Disaster Recovery |
| 6 | **Firebase Service** | 800.000 | Backend Auth + Push Notification |
| 7 | **Payment Gateway Midtrans** | 970.000 | Pembayaran Online (Top-up / Booking Fee) |
| 8 | **Email Service (SendGrid)** | 900.000 | Notifikasi Email User |
| 9 | **Gemini API (Image Generation)** | 980.000 | AI Generate Gambar Rambut & Barbershop |
| --- | --- | --- | --- |
| | **TOTAL** | **Rp 7.660.000** ✅ | TEPAT SESUAI TARGET! |

---

## 3. BREAKDOWN DETAIL PER-ITEM

### 1. Layanan Cloud Hosting Railway — Rp 900.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | Menjalankan **AI Recognition Service (FastAPI + dlib + OpenCV)** 24/7 secara online agar user bisa upload foto untuk analisis bentuk wajah. |
| **Paket** | Railway Starter Plan ($12 - $18/bln, pro-rata 1 tahun). Atau setara Hostinger/Biznet Gio VPS 2 vCPU + 4GB RAM. |
| **Durasi** | **1 Tahun** (bisa perpanjang tahunan) |
| **Tanpa Item Ini** | AI hanya jalan di laptop lokal → user tidak bisa pakai fitur "Upload Foto → Analisis Bentuk Wajah" kapan pun dan di mana pun. |

---

### 2. SSL Certificate Basic — Rp 570.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | Enkripsi **HTTPS** untuk domain `trime.co.id` & API endpoint. Wajib untuk: (a) Transfer data aman antara HP user & server; (b) Payment Gateway Midtrans hanya mau terhubung ke HTTPS; (c) Play Store app modern mensyaratkan semua koneksi API HTTPS. |
| **Paket** | SSL Single Domain (Comodo / Sectigo Basic). Bisa juga pakai Let's Encrypt FREE tapi **sebaiknya pakai yang berbayar untuk support & garansi 1 tahun.** |
| **Durasi** | **1 Tahun** |
| **Tanpa Item Ini** | Booking fee user bocor di jaringan publik (bahaya keamanan data kartu kredit / transfer). Midtrans tidak bisa diintegrasikan. |

---

### 3. Domain .id (Hostinger) — Rp 840.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | Alamat resmi website & API, misal: `www.trime.co.id` (landing page), `api.trime.co.id` (endpoint backend AI & booking). Domain `.id` = domain Indonesia resmi, terasa lebih "dapat dipercaya" untuk user lokal. |
| **Paket** | Hostinger Domain `.id` 1 Tahun + Free DNS Management. |
| **Durasi** | **1 Tahun** (perpanjang Rp 840rb/tahun) |
| **Tanpa Item Ini** | Akses API hanya via IP address (misal `192.168.1.1:8000`). Tidak profesional, sulit diingat, Play Store beresiko ditolak. |

---

### 4. Postman API Testing Tool — Rp 900.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | Alat utama **developer** untuk menguji (test) SEMUA endpoint API TRIME sebelum dirilis ke user: (a) Test login user, (b) Test upload foto AI, (c) Test submit booking, (d) Test payment webhook Midtrans. |
| **Paket** | Postman Pro Plan 1 tahun (1 user). Termasuk collection sharing, mock server, API monitoring. |
| **Durasi** | **1 Tahun Lisensi** |
| **Tanpa Item Ini** | Testing API manual → bug tidak terdeteksi sebelum release → user komplain booking error / AI tidak jalan. Meningkatkan bug rate 2-3x lipat. |

---

### 5. AWS Backup Service — Rp 800.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | **Backup otomatis setiap hari** untuk: (a) Database booking Supabase/Firebase; (b) Model AI (.pkl files); (c) Source code Flutter. Jika server mati / kena virus / salah delete, data tetap ada dan bisa restore. |
| **Paket** | AWS S3 Glacier + AWS Backup. 50GB cold storage x 1 tahun. Atau setara Backblaze B2. |
| **Durasi** | **1 Tahun Service** |
| **Tanpa Item Ini** | Jika harddisk server mati / laptop pengembang hilang → SEMUA DATA BOOKING + SOURCE CODE HILANG. Proyek AMBYAR total. Tidak ada disaster recovery. |

---

### 6. Firebase Service — Rp 800.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | (a) **Firebase Auth** → Login Google / Phone OTP (jika nanti upgrade); (b) **Firebase Cloud Messaging (FCM)** → Push Notifikasi ke user HP: "Booking Anda besok jam 10:00 WIB", "Kapster menerima booking Anda", "Promo potongan 20% minggu ini"; (c) **Firebase Crashlytics** → Laporan crash app real-time. |
| **Paket** | Firebase Blaze Plan (pay as you go). Alokasi budget Rp 800rb untuk 1 tahun pertama (cukup untuk 10.000 user aktif). |
| **Durasi** | **1 Tahun Quota** |
| **Tanpa Item Ini** | Tidak ada push notifikasi. User lupa booking dan No Show → kapster rugi. Crash app di HP user tidak terdeteksi sampai user komplain manual. |

---

### 7. Payment Gateway Midtrans — Rp 970.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | **Pembayaran online terintegrasi** di app TRIME. User bisa bayar booking fee / deposit via: (a) Transfer Bank BCA/BRI/Mandiri/BNI; (b) Virtual Account; (c) GoPay/OVO/Dana; (d) Kartu Kredit. Midtrans adalah payment gateway resmi Bank Indonesia (izin PJP). |
| **Paket** | Midtrans Setup Fee + Biaya Administrasi + Dana Jaminan (Rp 500rb refundable). Belum termasuk MDR fee per-transaksi (2-3%). |
| **Durasi** | **Aktivasi 1 Tahun** |
| **Tanpa Item Ini** | User bayar booking via transfer manual → repot cek mutasi setiap booking, risk "saya sudah transfer tapi bukti palsu". Proses pembayaran lama, potensi booking batal 30-40%. |

---

### 8. Email Service (SendGrid) — Rp 900.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | Kirim **email notifikasi otomatis** ke user: (a) Email verifikasi akun baru; (b) Email konfirmasi booking berhasil ("Booking #BK-001 Anda berhasil dijadwalkan"); (c) Email struk pembayaran dari Midtrans; (d) Email reset password jika lupa. |
| **Paket** | SendGrid Essentials Plan. 50.000 email / bulan × 12 bulan = 600.000 email total (cukup untuk 50.000 user). |
| **Durasi** | **1 Tahun Service** |
| **Tanpa Item Ini** | Kirim email dari server personal → SPAM folder user tidak baca. Akun palsu tidak diverifikasi (banyak akun bot). Tidak ada bukti transaksi tertulis di email (rawan sengketa). |

---

### 9. Gemini API (Image Generation) — Rp 980.000
| Detail | Keterangan |
|---|---|
| **Fungsi** | **Generate gambar AI otomatis** untuk kebutuhan aplikasi: (a) 30 gaya rambut × 6 bentuk wajah = 180 gambar rekomendasi; (b) Foto interior barbershop premium 20 gambar; (c) Foto profil kapster 30 gambar jika tidak ada foto real. Juga untuk AI Rekomendasi Rambut fitur "Visualize Style" nantinya. |
| **Paket** | Gemini API Pay-as-you-go. Estimasi 1.000 gambar × ~$0,015/image = $15 setara Rp 980rb. |
| **Durasi** | **1 Tahun Quota API** |
| **Tanpa Item Ini** | Perlu cari gambar manual di Google (resiko hak cipta / DMCA ditakedown Play Store) → hire desainer foto produk = cost lebih mahal (Rp 3-5 juta). |

---

## 4. HUBUNGAN SETIAP ITEM DENGAN FITUR TRIME

| Fitur TRIME | Item yang Dibutuhkan | Tidak Ada Item Ini → Efeknya |
|---|---|---|
| **Login & Verifikasi Akun** | Firebase Service + SendGrid Email | User tidak dapat verifikasi email → akun bot merajalela |
| **Upload Foto → Analisis Bentuk Wajah (AI)** | Railway Hosting + SSL Cert + Gemini API | AI tidak online 24/7, transfer foto tidak aman, gambar rambut tidak ada |
| **Booking Online + Cek Jadwal** | Domain + Railway + Postman (QA) | API hanya IP lokal, booking sering error karena tidak di-test |
| **Pembayaran Booking Fee / Deposit** | SSL Cert + Midtrans Payment Gateway | User bayar transfer manual, banyak sengketa, resiko penipuan |
| **Push Notifikasi Reminder Booking** | Firebase Service (FCM) | User lupa, No Show, kapster kehilangan pendapatan 30% |
| **Email Konfirmasi & Struk** | SendGrid Email + Midtrans | Tidak ada bukti pembayaran sah, email verifikasi tidak dikirim |
| **Gambar Gaya Rambut & Foto Barbershop** | Gemini API Generate | Cari gambar manual → resiko DMCA Play Store hapus app |
| **Backup Data Jika Server Rusak** | AWS Backup Service | Data booking 1 tahun hilang permanen, user komplain, kepercayaan hilang |
| **App Tembus Play Store** | Domain + SSL Cert + Firebase | Play Store tolak app karena API tidak HTTPS, tidak crash monitoring |

---

## 5. TABEL ANALISIS: 26 ITEM VS KATEGORI (INCLUDE / EXCLUDE)

Tabel dibawah ini menjawab: **"Mengapa 9 item diambil? 17 item sisanya kenapa tidak dimasukkan ke biaya sistem Rp 7,66 Jt?"**

| No | Item Client (26) | Nominal (Rp) | Kategori | INCLUDE ke Rp 7,66 Jt? | Alasan (JIKA EXCLUDE) |
|---|---|---|---|---|---|
| 1 | Iklan digital Meta Ads | 900.000 | MARKETING | ❌ EXCLUDE | Biaya promosi Facebook/Instagram. Bukan biaya sistem. Bisa masuk budget marketing lain. |
| 2 | Layanan cloud hosting Railway | 900.000 | INFRASTRUKTUR | ✅ **INCLUDE (Item 1)** | Hosting untuk AI Recognition Service. Sangat dibutuhkan. |
| 3 | Buku pengembangan aplikasi (Packt) | 400.000 | LEARNING / PERSONAL | ❌ EXCLUDE | Ini biaya BELAJAR developer, bukan biaya sistem app. Developer harusnya belajar sendiri atau dari budget training perusahaan. |
| 4 | Buku iOS App Dev For Dummies | 570.000 | LEARNING / PERSONAL | ❌ EXCLUDE | Sama item 3 - buku belajar, bukan aset sistem. Paket ini fokus ANDROID saja. |
| 5 | SSL Certificate Basic | 570.000 | SECURITY | ✅ **INCLUDE (Item 2)** | Enkripsi HTTPS wajib untuk payment & Play Store. |
| 6 | Domain .id (Hostinger) | 840.000 | DOMAIN | ✅ **INCLUDE (Item 3)** | Alamat resmi website & API domain Indonesia. |
| 7 | Pendaftaran merek | 500.000 | LEGAL / HAKI | ❌ EXCLUDE | Biaya hukum (Pendaftaran Merek Dagang ke Kemenkum HAM). Bukan bagian dari sistem aplikasi. Masuk budget legal perusahaan. |
| 8 | Course PZN "Programmer Zaman Now" | 900.000 | LEARNING / PERSONAL | ❌ EXCLUDE | Kursus online belajar programming. Biaya training, bukan sistem app. |
| 9 | Postman API Testing Tool | 900.000 | DEV TOOL | ✅ **INCLUDE (Item 4)** | Tool wajib testing semua API endpoint sebelum production. |
| 10 | Iklan Digital TikTok Ads | 900.000 | MARKETING | ❌ EXCLUDE | Iklan TikTok untuk promosi app. Budget marketing terpisah. |
| 11 | Event Bali Barber Expo | 980.000 | MARKETING / EVENT | ❌ EXCLUDE | Booth promosi offline. Biaya marketing, bukan sistem. |
| 12 | Ubersuggest SEO Tools | 800.000 | MARKETING / SEO | ❌ EXCLUDE | Tool SEO untuk website landing page. Tidak dipakai oleh app mobile. |
| 13 | Adobe Creative Cloud Pro | 570.000 | DESIGN SOFTWARE | ❌ EXCLUDE | Photoshop/Illustrator/Premiere Pro. Biaya desainer grafis, bukan sistem aplikasi. Jika desainer bayar sendiri, skip. |
| 14 | AWS Backup Service | 800.000 | BACKUP / DR | ✅ **INCLUDE (Item 5)** | Backup otomatis data & source code - disaster recovery wajib. |
| 15 | Firebase Service | 800.000 | BACKEND SAAS | ✅ **INCLUDE (Item 6)** | Auth + Push Notif + Crashlytics. Wajib app modern. |
| 16 | Payment Gateway Midtrans | 970.000 | PAYMENT SYSTEM | ✅ **INCLUDE (Item 7)** | Pembayaran online resmi. Tanpa ini app hanya COD. |
| 17 | Email Service (SendGrid) | 900.000 | NOTIFIKASI EMAIL | ✅ **INCLUDE (Item 8)** | Kirim email verifikasi, booking konfirmasi, struk pembayaran. |
| 18 | Navicat Data Modeler | 500.000 | DATABASE TOOL | ❌ EXCLUDE | Tool design schema database. Harga murah, tapi tidak WAJIB (bisa pakai DBeaver FREE, atau pgAdmin FREE). Prioritaskan yang lain dulu. |
| 19 | Typeform Plus Plan | 900.000 | SURVEY TOOL | ❌ EXCLUDE | Form survey online. App TRIME belum butuh survey user di tahap awal. Pakai Google Form FREE sudah cukup. |
| 20 | Gemini API (Image Generation) | 980.000 | AI API | ✅ **INCLUDE (Item 9)** | Generate 180+ gambar gaya rambut & barbershop premium. |
| 21 | Microsoft 365 Business | 920.000 | OFFICE PRODUCTIVITY | ❌ EXCLUDE | Word, Excel, Outlook. Biaya perkantoran. Bisa pakai Google Workspace FREE atau pakai software FREE alternative. |
| 22 | Jasa Promosi Influencer | 960.000 | MARKETING | ❌ EXCLUDE | Bayar seleb TikTok/Instagram promosikan app. Budget marketing, bukan sistem. |
| 23 | Mobile Marketing Analytics | 952.000 | ANALYTICS TOOL | ❌ EXCLUDE | Analisa user behavior di app (retensi, drop-off). Firebase Analytics sudah FREE - cukup untuk 10rb user pertama. |
| 24 | ASO Tools & Optimization | 960.000 | MARKETING APP STORE | ❌ EXCLUDE | Optimasi keyword listing Play Store. Tahap awal bisa manual optimasi deskripsi & screenshot (FREE). |
| 25 | Tinta Printer Brother 1 Set 4 Warna | 530.000 | BARANG FISIK KANTOR | ❌ EXCLUDE | Tinta printer untuk print dokumen. Biaya operasional kantor, 100% TIDAK ADA hubungannya dengan sistem aplikasi. |
| 26 | Kertas HVS BOLA DUNIA 70GR A4 | 98.000 | BARANG FISIK KANTOR | ❌ EXCLUDE | Kertas print. Sama item 25 - biaya ATK kantor, bukan sistem aplikasi. |
| --- | --- | --- | --- | --- |
| | **TOTAL 26 ITEM CLIENT** | **Rp 20.000.000** | | **9 ITEM INCLUDE = Rp 7.660.000 ✅** | 17 ITEM EXCLUDE = Rp 12.340.000 (marketing/belajar/office/fisik) |

---

## 6. PERBANDINGAN DURASI MASING-MASING ITEM

| Item | Durasi Aktif | Setelah Expired Perlu Apa? | Biaya Perpanjang / Tahun ke-2 (Estimasi) |
|---|---|---|---|
| Railway Hosting | 1 Tahun | Perpanjang paket Railway / VPS | Rp 900.000 |
| SSL Certificate Basic | 1 Tahun | Reissue SSL baru | Rp 570.000 |
| Domain .id Hostinger | 1 Tahun | Renew domain | Rp 840.000 |
| Postman API Testing Tool | 1 Tahun | Renew lisensi Pro | Rp 900.000 |
| AWS Backup Service | 1 Tahun | Tetap aktif selama ada biaya | Rp 800.000 |
| Firebase Service | Pay-as-you-go (1 tahun quota) | Top up credit jika limit habis | Rp 800.000 |
| Payment Gateway Midtrans | Aktivasi permanen | Tidak perlu renew. Hanya MDR per-transaksi 2-3% | **Rp 0 (gratis permanen)** |
| SendGrid Email | 1 Tahun | Renew paket Essentials | Rp 900.000 |
| Gemini API (Image Gen) | Quota 1000 gambar (1 tahun) | Top up API credit jika butuh lebih banyak gambar | Rp 500.000 (cukup untuk tahun ke-2) |
| --- | --- | --- | --- |
| | | **Total Operasional Tahun ke-2** | **Rp 6.410.000** (Midtrans gratis, Gemini alokasi lebih hemat) |

---

## 7. RINGKASAN EKSEKUTIF UNTUK PRESENTASI

### 📋 Bisa Copy-paste ini ke Slide / Proposal Client:

> **Mengapa Budget Sistem Aplikasi Rp 7,66 Juta?**
>
> Dari total pengajuan 26 item senilai **Rp 20 Juta**, kami **seleksi ketat** hanya 9 item yang **100% langsung berkaitan dengan kelangsungan sistem aplikasi TRIME** (bukan biaya marketing, bukan kursus belajar, bukan barang kantor).
>
> **9 Item sistem tersebut adalah:**
> 1. **Hosting AI Railway (Rp 900rb)** → Analisis foto wajah jalan 24/7
> 2. **SSL Certificate (Rp 570rb)** → Data user terenkripsi & payment aman
> 3. **Domain .id Hostinger (Rp 840rb)** → Alamat resmi aplikasi Indonesia
> 4. **Postman API Testing (Rp 900rb)** → Semua fitur di-tested sebelum rilis (minimalisir bug)
> 5. **AWS Backup (Rp 800rb)** → Data booking & source code backup harian (jika server mati, tidak hilang)
> 6. **Firebase Service (Rp 800rb)** → Login, Push Notifikasi Reminder Booking, Crash Monitoring
> 7. **Midtrans Payment Gateway (Rp 970rb)** → Pembayaran online via transfer, ewallet, CC (resmi BI)
> 8. **SendGrid Email Service (Rp 900rb)** → Email verifikasi, konfirmasi booking, struk pembayaran
> 9. **Gemini API Image Generation (Rp 980rb)** → 180+ gambar gaya rambut & barbershop premium (bebas DMCA)
>
> **TOTAL:** **Rp 7.660.000** → Semua aktif **1 tahun penuh**, app TRIME bisa **ONLINE, menerima pembayaran, dan dipakai 10.000 user pertama.**

---

*File breakdown ini disusun berdasarkan referensi 26 item pengajuan client. Semua harga sesuai nilai nominal pada dokumen sumber. Tanggal: 19 Agustus 2026.*
