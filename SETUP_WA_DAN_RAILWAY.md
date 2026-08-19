# Panduan Setup: WhatsApp Alert + Railway Deploy

Dokumen ini menjelaskan cara mengaktifkan **notifikasi WhatsApp** untuk booking (alert saat booking + reminder 30 menit sebelum) dan mendeploy backend ke **Railway** (fix error cv2/dlib).

---

## 1. Ringkasan Alur Kerja

```
User buat Booking di Flutter App
    │
    ▼
backend_service.dart memanggil POST /booking/created
    │
    ▼
recognition_service (FastAPI) ──┬──> Kirim WA ke Customer (booking berhasil)
                                ├──> Kirim WA ke Owner (jika owner_phone diset)
                                └──> Schedule reminder 30 menit sebelum booking via APScheduler
                                                                          │
                                                                          ▼
                                                         Ketika waktu H-30 menit: kirim WA reminder
```

**Endpoint backend baru** (semua butuh header `x-api-key: <API_SECRET>`):
| Endpoint | Fungsi |
|----------|--------|
| `POST /booking/created` | Trigger WA booking baru + schedule reminder |
| `POST /booking/status-changed` | Trigger WA status (confirm/cancel/done) + cancel reminder |
| `POST /booking/send-reminder` | Kirim reminder manual |
| `GET  /booking/jobs` | List reminder yang terjadwal |
| `POST /booking/cancel-reminder/{id}` | Cancel reminder |
| `POST /wa/test` | Test kirim WA |
| `GET  /health` | Cek status service |

---

## 2. Pilih & Daftar WhatsApp Gateway

Untuk Indonesia, **3 opsi termudah** (pilih 1):

### 🥇 Opsi A: FONNTE (Rekomendasi — Termudah & termurah)
1. Buka https://fonnte.com → Daftar akun
2. Login → Pilih menu **Device** → Tambah Device → Scan QR WA dengan HP
3. Setelah device terhubung, copy **Token Device** (Authorization header)
4. Harga: ~Rp 25k/bulan unlimited (untuk 1 device)

### 🥈 Opsi B: WHACENTER
1. Buka https://app.whacenter.com → Daftar
2. Tambah device → Scan QR → copy `device_id` (token)
3. Harga: ~Rp 50k/bulan

### 🥉 Opsi C: TWILIO (Internasional, tidak pakai QR)
1. Daftar https://twilio.com → Aktifkan WhatsApp Sandbox
2. Copy Account SID, Auth Token, dan nomor WA from
3. Cocok untuk production global, tapi mahal untuk Indonesia

---

## 3. Setup Backend (Recognition Service)

### Step 1: Copy & isi `.env`
```bash
cd recognition_service
copy .env.example .env
# (Windows: copy .env.example .env)
# (Linux/Mac: cp .env.example .env)
```

Edit file `recognition_service/.env`:
```ini
# ─── API Settings ───
API_HOST=0.0.0.0
API_PORT=8001
API_SECRET=GANTI_DENGAN_RANDOM_STRING_PANJANG  # ← WAJIB ganti! Ini password API kamu

# ─── WhatsApp: FONNTE (contoh) ───
WA_PROVIDER=fonnte
WA_FONNTE_TOKEN=YOUR_FONNTE_TOKEN_DISINI       # ← Paste token Fonnte
WA_FONNTE_BASE_URL=https://api.fonnte.com/send

# ─── Reminder ───
REMINDER_MINUTES_BEFORE=30
SCHEDULER_ENABLED=true
ENABLE_WA_NOTIF=true

# ─── Supabase ───
SUPABASE_URL=https://ttlladewtuhorjraipva.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY
SUPABASE_SERVICE_KEY=YOUR_SERVICE_ROLE_KEY
```

### Step 2: Test running lokal
```bash
cd recognition_service

# (1) Jika pakai venv project:
.venv\Scripts\activate   # Windows
# source .venv/bin/activate   # Linux/Mac

# (2) Install tambahan package (jika belum):
pip install python-dotenv APScheduler requests pydantic-settings supabase

# (3) Jalankan:
python main.py
```

Buka http://localhost:8001 → harusnya muncul JSON status service.

### Step 3: Test kirim WA dengan curl/Postman
```bash
curl -X POST http://localhost:8001/wa/test ^
  -H "Content-Type: application/json" ^
  -H "x-api-key: GANTI_DENGAN_RANDOM_STRING_PANJANG" ^
  -d "{\"phone\":\"081234567890\",\"message\":\"Test WA dari TRIME!\"}"
```
(Ganti API key dan nomor teleponmu)

---

## 4. Deploy ke Railway (Fix cv2/dlib Error)

### Masalah yang dulu terjadi:
Error `cv2` / `ImportError: libGL.so.1` / `dlib` gagal compile di Railway **karena container Debian/Ubuntu kurang library sistem (libgl1, libglib, libsm, libboost, cmake untuk dll)**.

### Solusi (Sudah saya fix di Dockerfile):
File `Dockerfile` di root project **sudah diupdate** dengan semua library sistem + timezone Jakarta.

### Step-by-step Deploy ke Railway:

#### 1. Push project ke GitHub (jika belum)
```bash
git init
git add .
git commit -m "add WA notif + fix docker"
git branch -M main
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```

#### 2. Buat Project di Railway
- Buka https://railway.app → Login → **New Project** → **Deploy from GitHub repo**
- Pilih repo kamu → tunggu sampai detect Dockerfile (Railway auto-detect)

#### 3. Setting Variables di Railway Dashboard
Pilih service kamu → menu **Variables** → **Add Variable**:
| Key | Value |
|-----|-------|
| `API_SECRET` | `string_random_panjang_misal_Tr1m3B4ck3nd!2026` |
| `WA_PROVIDER` | `fonnte` |
| `WA_FONNTE_TOKEN` | `token_fonnte_kamu` |
| `ENABLE_WA_NOTIF` | `true` |
| `SCHEDULER_ENABLED` | `true` |
| `TZ` | `Asia/Jakarta` |
| `SUPABASE_URL` | `https://ttlladewtuhorjraipva.supabase.co` |
| `SUPABASE_ANON_KEY` | `...` |
| `SUPABASE_SERVICE_KEY` | `...` |

> ⚠️ **PENTING:** JANGAN pakai file `.env` di Railway — isi semua lewat dashboard Variables!

#### 4. Setting Port
Railway kadang auto-set port. Pastikan:
- Menu **Settings** → **Networking** → Pastikan port **8001** di-expose (Railway biasanya auto-detect dari `EXPOSE 8001` di Dockerfile)

#### 5. Deploy!
- Klik **Deploy** dan tunggu build selesai
- Jika build sukses, Railway akan kasih URL `https://<service-name>.up.railway.app`
- Buka URL itu → cek jika JSON status muncul

### 💡 Jika dlib/cv2 masih error di Railway:
Tambahkan ke Variables Railway:
```
ENABLE_FACE_ANALYSIS=false
```
Ini akan **menonaktifkan face shape engine** (dlib + cv2) tapi WA notification TETAP BERJALAN. WA notifikasi tidak butuh OpenCV/dlib sama sekali.

---

## 5. Setup Flutter App (Client)

### Step 1: Copy `.env`
```bash
cd mobile_app
copy .env.example .env
```

Edit `mobile_app/.env`:
```ini
# Untuk emulator Android (Railway production):
BACKEND_BASE_URL=https://<service-kamu>.up.railway.app

# Untuk localhost dev (emulator):
# BACKEND_BASE_URL=http://10.0.2.2:8001
# Untuk dev physical device (pakai ngrok):
# BACKEND_BASE_URL=https://xxxx-xx-xx-xx.ngrok-free.app

SUPABASE_URL=https://ttlladewtuhorjraipva.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY

ENABLE_WA_NOTIF=true
```

### Step 2: Tambah `API_SECRET` ke `.env` Flutter (rekomendasi)
Flutter client mengirim `x-api-key` header. Karena file env mobile app dibaca juga, **tambahkan** di `mobile_app/.env`:
```ini
API_SECRET=string_random_panjang_SAMA_DENGAN_BACKEND
```

### Step 3: Install package Flutter
```bash
cd mobile_app
flutter pub get
```

### Step 4: Test Booking → Cek WA Masuk
- Jalankan app → buat booking dengan **customerPhone** diisi nomor WA kamu
- Seketika itu juga:
  - ✅ WA "Booking berhasil" masuk ke nomor pelanggan
  - ✅ (jika owner_phone diset) WA "Booking baru masuk" ke pemilik toko
  - ✅ Reminder otomatis di-schedule 30 menit sebelum booking

---

## 6. Dapatkan Nomor HP Pengguna untuk Notif

WA notifikasi **butuh nomor HP customer**. Karena itu pastikan:

1. Saat **register/signup**, user mengisi no HP (sudah ada field `phoneNumber` di `TrimeUser`)
2. Saat **booking**, kode kamu memanggil `addBooking()` dengan parameter `customerPhone`:
```dart
final String noHpUser = authService.currentUser?.phoneNumber ?? "";
final String? noHpOwner = appState.barbershopByIdOrName(shopName)?.phone;

appState.addBooking(
  barbershop: barbershop,
  kapster: kapster,
  dateTime: slot,
  serviceName: service.name,
  price: service.price,
  notes: catatan,
  customerName: namaUser,
  customerPhone: noHpUser,       // ← WAJIB: untuk notif customer
  ownerPhone: noHpOwner,         // ← Opsional: notif ke owner toko
);
```

---

## 7. Ngrok (untuk test lokal dengan HP fisik)

Jika kamu test backend di laptop tapi app jalan di HP fisik (bukan emulator), kamu butuh ngrok:

1. Download https://ngrok.com
2. Jalankan:
   ```bash
   ngrok http 8001
   ```
3. Copy URL `https://xxxx.ngrok-free.app` → set sebagai `BACKEND_BASE_URL` di `.env` Flutter

---

## 8. Troubleshooting CV2/dlib di Railway

| Error | Solusi |
|-------|--------|
| `ImportError: libGL.so.1: cannot open shared object file` | Dockerfile sudah include `libgl1-mesa-glx` — rebuild dengan variable `NIXPACKS_APT_PACKAGES=libgl1,libglib2.0-0,libsm6,libxext6,libxrender-dev` |
| `dlib` compile fail memori | Dockerfile pakai conda-forge untuk prebuilt dlib binary (tidak compile from source) |
| Build timeout / lambat | Enable **Build Cache** di Railway settings |
| Lepas dari dlib sementara | Set `ENABLE_FACE_ANALYSIS=false` di Variables → Service restart → WA tetap jalan |

---

## 9. Rekomendasi Biaya Bulanan (Estimasi)

| Komponen | Harga Estimasi |
|----------|---------------|
| Railway Hobby Plan | $5 / ~Rp 80rb |
| Fonnte (1 device WA) | Rp 25.000 / bulan |
| Supabase Free Tier | Rp 0 |
| Firebase Auth Free | Rp 0 |
| **Total** | **~Rp 105.000 / bulan** |

Ini **jauh lebih murah** dari biaya yang ada di dokumen breakdown sistem, dan sudah cover semua kebutuhan notifikasi + backend.

---

Selesai! Jika ada step yang error, paste errornya ke saya ya!
