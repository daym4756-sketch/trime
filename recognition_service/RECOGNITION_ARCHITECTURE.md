# RECOGNITION SERVICE ARCHITECTURE MAP

Dokumen ini menjelaskan bagaimana berbagai alat rekognisi digabungkan ke dalam layanan tunggal untuk TRIME. Tujuannya adalah untuk memudahkan pemeliharaan (maintenance) dan skalabilitas.

## 📂 Struktur Folder (Mapping)

Semua komponen rekognisi sekarang dipusatkan di folder `recognition_service/`:

| Folder | Sumber Asli (Original Tool) | Fungsi & Peran |
|---|---|---|
| `engines/birefnet/` | `Recognation/BiRefNet/` | Penghapusan background (Segmentation). |
| `engines/face_shape/` | `Recognation/Hairstyle-Recommendation-System/` | Klasifikasi bentuk wajah (Oval, Round, dll). |
| `models/` | Berbagai subfolder `.pkl` & `.dat` | Tempat penyimpanan bobot model (weights) dan scaler. |
| `common/` | - | Kode utilitas bersama (image processing, base classes). |
| `api/` | - | Endpoint API untuk diakses oleh Mobile App & Backend Utama. |

## 📱 Mobile App Integration

Integrasi di sisi [mobile_app](file:///d:/Project/TRIME/mobile_app) dilakukan melalui:

*   **Service Layer**: [ai_service.dart](file:///d:/Project/TRIME/mobile_app/lib/core/services/ai_service.dart) menangani komunikasi Multipart Request ke server AI.
*   **Feature Integration**: [home_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/home/pages/home_page.dart) sekarang memiliki alur kamera -> kirim ke AI -> tampilkan hasil.
*   **Result Display**: [ai_result_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/rambutku/pages/ai_result_page.dart) menampilkan data dinamis dari hasil analisis AI.

## 🔗 Pemetaan Komponen (Logic Flow)

Sistem ini bekerja secara modular. Setiap "Engine" memiliki interface yang sama:

1.  **Input**: Citra mentah (Raw Image) dari user.
2.  **Pre-process**: Dilakukan oleh `common/image_utils.py`.
3.  **Process**:
    *   `BiRefNetEngine`: Menghasilkan mask dan memotong background.
    *   `FaceShapeEngine`: Menggunakan dlib untuk landmark dan SVM untuk klasifikasi.
4.  **Output**: Data terstruktur (JSON) dan Citra hasil proses (PNG transparan).

## 🧠 Orkestrasi Multi-Result (Revisi 6)

Sesuai pembaruan fitur AI Recognition, sistem sekarang mengeluarkan **3-5 rekomendasi gaya** (bukan cuma 1). Berikut mapping logikanya:

### Alur Data Baru (Mobile ↔ Server AI)
```
[User Upload Foto]
        ↓
[ai_service.dart]  ← request multipart
        ↓
[Server API /recognize]
        ├─ engines/birefnet        → segmentation (hapus background)
        ├─ engines/face_shape      → klasifikasi 7 bentuk wajah + confidence
        ├─ engines/hair_type       → deteksi tipe rambut (Lurus/Ikal/Keriting/Tipis/Tebal)
        └─ recommendation_engine   → generator 5 gaya + matchScore + why_it_fits
        ↓
[FaceAnalysisResult JSON]  ← return ke Flutter
        ├─ faceShape        : "oval" | "round" | "square" | "heart" | "oblong" | "diamond" | "triangle"
        ├─ faceDetails      : String penjelasan bentuk wajah 3-4 kalimat (Bahasa Indonesia)
        ├─ hairType         : "Lurus" | "Ikal" | "Keriting" | "Tipis" | "Tebal"
        ├─ confidence       : double 0.82 - 0.96
        └─ recommendations  : List<HairRecommendation> (panjang 3-5, terurut matchScore tertinggi)
               ├─ styleName         : "Pompadour" / "Side Part" / "Undercut" / "Quiff" / "French Crop"
               ├─ description       : deskripsi gaya singkat
               ├─ whyItFits         : penjelasan mengapa cocok untuk faceShape user
               ├─ imageUrl          : URL trae text_to_image dinamis per gaya
               ├─ matchScore        : double 0.xx (diurut DESC)
               ├─ estimatedPriceLow / High  : range harga Rupiah
               ├─ estimatedMinutes  : estimasi durasi potong
               ├─ suitableHairTypes : List<String> tipe rambut yang cocok
               └─ difficultyLevel   : "Mudah" | "Sedang" | "Sulit" (perawatan sehari-hari)
```

### Fallback Offline Mode (Client-side)
Jika server AI tidak terjangkau, `ai_service.dart` mengembalikan data demo untuk `faceShape = "oval"` sehingga user tetap bisa menjelajahi UI horizontal scroll di [ai_result_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/rambutku/pages/ai_result_page.dart).

### UI Mapping
- **ProfileSummary Card** ← menampilkan `faceShape`, `hairType`, `faceDetails`, `confidence`
- **Horizontal Scroll List** ← `ListView.builder` untuk setiap `HairRecommendation`, tinggi 260px, lebar 190px
- **Recommendation Detail Card** ← menampilkan gaya terpilih (indeks state `_selectedRecommendationIdx`) dengan highlight `why_it_fits`
- **Book Action** ← navigasi ke BookingCalendar dengan kapster preset

---

## 🛠️ Strategi Maintenance

Untuk menjaga kode tetap rapi dan mudah dikelola:

*   **Engine Isolation**: Jangan mencampur logika BiRefNet dengan FaceShape. Gunakan folder `engines/` masing-masing.
*   **Centralized Config**: Semua path ke model, API keys, dan parameter AI diatur dalam `config.py`.
*   **Version Control for Models**: File `.pkl` dan `.dat` besar harus dikelola versinya (misal: `face_shape_v1.pkl`).
*   **API Documentation**: Endpoint didefinisikan secara eksplisit di folder `api/` menggunakan FastAPI untuk dokumentasi otomatis.
*   **Multi-Result Contract**: Saat menambah engine baru, wajib implementasikan `HairRecommendation` contract (field di atas) supaya UI horizontal scroll tidak perlu diubah.

---
*Dibuat untuk memudahkan transisi dari riset AI ke implementasi produksi.*
*Diperbarui sesuai Revisi 6 (Multi-Result Engine & UI Horizontal Scroll).*
