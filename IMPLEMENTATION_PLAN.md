# REVISED IMPLEMENTATION PLAN TRIME (V2)

> Aplikasi Marketplace Barbershop Terintegrasi yang Menghubungkan Mitra, Kapster, dan Pelanggan dalam Satu Ekosistem Digital.
> **Status**: Mobile App terinstal (Android 14). Menuju Fase Penyempurnaan Fitur & Integrasi AI.

---

## 1. PENYEMPURNAAN ARSITEKTUR & ASSET
Berdasarkan revisi terbaru, rencana ini memprioritaskan validitas visual dan kelengkapan fungsional.

### 🖼️ Aset Visual & Gambar Contoh (Revisi 1)
| Kategori | Strategi Penyediaan | Deskripsi |
|---|---|---|
| **Barbershop** | `https://core-normal.traeapi.us/api/ide/v1/text_to_image?prompt=modern+luxury+barbershop+interior+semarang+realistic&image_size=landscape_16_9` | Interior premium untuk profil barbershop |
| **Kapster** | `https://core-normal.traeapi.us/api/ide/v1/text_to_image?prompt=professional+barber+man+smiling+apron+portrait&image_size=portrait_4_3` | Foto profil kapster mitra |
| **Model Rambut (AI)** | `https://core-normal.traeapi.us/api/ide/v1/text_to_image?prompt={style}+haircut+on+man+face+shape+{face_shape}&image_size=square_hd` | Katalog dinamis berdasarkan hasil recognation |

---

## 2. RENCANA PENGEMBANGAN FITUR (URGENT REVISIONS)

### 🔹 Revisi 2: Fitur Login & Registrasi (Missing)
*   **Implementasi**: Menambahkan `features/auth` di Flutter.
*   **Alur**: Screen Splash -> Login/Register -> OTP WhatsApp (Twilio/Meta) -> Home.
*   **Teknologi**: Supabase Auth / Firebase Auth untuk manajemen user session.

### 🔹 Revisi 3 & 5: Perbaikan Jadwal & Aksi Button
*   **Jadwal**: Debugging `booking_calendar` widget. Sinkronisasi dengan `availability_slots` di database.
*   **Interaktivitas**: Menghubungkan semua `PrimaryButton` ke navigasi atau service API. Menghapus pesan `print()` dan menggantinya dengan aksi nyata (Booking, Favorite, Chat).

### 🔹 Revisi 4: Integrasi Peta (Map View)
*   **Google Maps SDK**: Menampilkan pin marker untuk barbershop terdekat di halaman [kapster_map_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/kapster/pages/kapster_map_page.dart).
*   **Geocoding**: Konversi alamat teks ke koordinat (Lat/Lng) secara otomatis saat onboarding mitra.

---

## 3. PENYEMPURNAAN AI RECOGNATION (Revisi 6)
AI akan dikembangkan dari sistem 1-hasil menjadi sistem konsultasi personal yang lengkap.

### 🛠️ Alur Analisis AI Baru
1.  **Multi-Result Engine**: Server akan memberikan **3-5 rekomendasi gaya rambut** (bukan hanya 1).
2.  **Detailed Profiling**: Output API tidak hanya `face_shape`, tapi juga:
    *   `hair_type`: (Lurus, Ikal, Keriting, Tipis, Tebal).
    *   `face_details`: Penjelasan bentuk wajah (misal: "Wajah Kotak ditandai dengan rahang yang kuat").
3.  **Consultation Insight**: Menambahkan kolom `why_it_fits` (Mengapa gaya ini cocok untuk bentuk wajah tersebut).
4.  **UI/UX Update**: [ai_result_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/rambutku/pages/ai_result_page.dart) akan menampilkan *Horizontal Scroll* untuk pilihan gaya rambut.

---

## 4. TIMELINE REVISI (FASE 1.5 - "THE POLISH PHASE")

| Minggu | Target Teknis | Deliverable |
|---|---|---|
| **W1** | **Auth & Maps** | Login/Register aktif + Marker Maps muncul di HP |
| **W2** | **Asset & UI Action** | Semua gambar menggunakan API Image + Semua tombol berfungsi |
| **W3** | **AI Multi-Result** | API Backend mengirimkan 5 rekomendasi gaya |
| **W4** | **Testing & Bugfix** | Perbaikan total fitur Jadwal & Final QA di HP Android 14 |

---

## 5. MAPPING MAINTENANCE (REVISI)
Semua file baru harus mengikuti struktur `recognition_service` yang sudah dibuat:
- [ai_service.dart](file:///d:/Project/TRIME/mobile_app/lib/core/services/ai_service.dart) -> Menangani request multi-result.
- [RECOGNITION_ARCHITECTURE.md](file:///d:/Project/TRIME/recognition_service/RECOGNITION_ARCHITECTURE.md) -> Update logika orkestrasi 5 hasil.
