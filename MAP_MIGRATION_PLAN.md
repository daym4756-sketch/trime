# MAP MIGRATION PLAN — TRIME V2
## Migrasi: `google_maps_flutter` → `flutter_map` + OpenStreetMap (100% Gratis Tanpa Billing)

### Tanggal: 2026-08-17
### Author: TRIME Engineering
### Status: **DRAFT — Siap Dieksekusi**

---

## 1. 🎯 Tujuan

Ganti seluruh dependensi map internal dari **Google Maps SDK** (memerlukan billing / CC) ke **`flutter_map` + OpenStreetMap** (100% GRATIS FOREVER, tanpa API key, tanpa verifikasi pembayaran).

### 1.1 Use Case Core (Wajib Berhasil 100%)
| No | Goal | Kriteria Sukses |
|---|---|---|
| 1 | **Lihat Lokasi Saya** | GPS dapat koordinat user → Marker cyan + pulsing circle → Camera auto-center ke user dengan zoom ≥ 15 |
| 2 | **Lihat Barber Terdekat** | 6 Barbershop (🔴) + 5 Kapster (🔵/🟣) tampil sebagai Marker di map, sesuai koordinat hardcoded Semarang |
| 3 | **Sort Jarak Realistis** | Pakai **Rumus Haversine Dart murni** (0 biaya API) menghitung jarak `user_pos ↔ toko_pos` → Sort list Rekomendasi ASCENDING |
| 4 | **Rute Navigasi Gratis** | Tap Marker / tombol "Rute" → **Deep Link ke Google Maps App External** dengan mode Directions (origin=user, dest=toko) — UX premium GRATIS |
| 5 | **Mini Map Preview Detail** | Di halaman detail barbershop, map mini height 180 menampilkan 1 marker toko + tile jalan nyata, tap → buka GMaps external |

---

## 2. 🏆 Final Stack Dipilih

| Komponen | Pilihan | Alasan |
|---|---|---|
| **Map Engine Flutter** | `flutter_map: ^8.3.0` | 100% pure-Dart, open-source, terbukti stabil (99 dependents pub.dev) |
| **Tile Source (Style)** | **CartoDB Positron** (`https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png`) | Style abu-abu modern — PALING MIRIP Google Maps Light, cocok tema Industrial AdminLTE |
| **User Geolocation** | `geolocator: ^13.0.1` (SUDAH ADA, TIDAK UBAH) | Native Android/iOS GPS — akurasi tinggi, support permission request |
| **Haversine Distance** | `dart:math` custom function | Hitung jarak offline 0 biaya, sesuai project hard constraint |
| **External Nav** | `url_launcher: ^6.3.0` (SUDAH ADA) + Deep Link GMaps `https://www.google.com/maps/dir/?api=1&...` | Turn-by-turn navigation 100% gratis, pakai app official |
| **Mini Map Preview** | `flutter_map` height=180, marker=1, gestures=disabled | Tile GRATIS, visual hidup, tap InkWell → launch GMaps |

### 2.1 Bukan Pilihan dan Alasannya
| Opsi | Alasan Ditolak |
|---|---|
| ❌ Google Maps SDK Official | Perlu billing account + verifikasi CC untuk mendapatkan $200 Free Tier |
| ❌ Mapbox SDK | SAMA SAJA PERLU CC saat signup untuk verifikasi account ownership, meskipun free tier ada |
| ❌ OSMdroid Native Android | Hanya untuk Android, Flutter tidak support native — repot di iOS nanti |

---

## 3. 📋 Step-by-Step Execution Plan

Estimasi total pengerjaan: **90 - 120 menit**
Dependencies check / verification: 20 menit

---

### ✅ STEP 0: Sebelum Mulai (Sanity Check)
```bash
cd d:\Project\TRIME\mobile_app
flutter analyze  # Pastikan baseline NO ISSUES FOUND (sudah pass di sesi sebelum)
```
**Target:** Exit code 0. Jika ada error → fix dulu sebelum migrasi.

---

### ✅ STEP 1: Update `pubspec.yaml`
**File**: [pubspec.yaml](file:///d:/Project/TRIME/mobile_app/pubspec.yaml)

| Action | Detail |
|---|---|
| ➖ HAPUS | `google_maps_flutter: ^2.9.0` |
| ➕ TAMBAHKAN | `flutter_map: ^8.3.0` |
| ➕ TAMBAHKAN | `latlong2: ^0.9.0` |

Jalankan:
```bash
cd d:\Project\TRIME\mobile_app
flutter pub get
```
Target output: `Got dependencies!` tanpa error version solving.

---

### ✅ STEP 2: Cleanup Konfigurasi Android & iOS

#### 2a. AndroidManifest.xml
**File**: [android/app/src/main/AndroidManifest.xml](file:///d:/Project/TRIME/mobile_app/android/app/src/main/AndroidManifest.xml#L29-L35)

HAPUS baris meta-data Google Maps (tidak diperlukan lagi):
```xml
<!-- HAPUS SELURUH BLOCK INI -->
<meta-data
    android:name="flutterEmbedding"
    android:value="2" />
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

⚠️ **JANGAN HAPUS baris `flutterEmbedding`** — hanya yang API_KEY Google Maps saja.

#### 2b. iOS AppDelegate (skip untuk sekarang)
Tidak ada yang perlu diubah karena tidak pernah setup GMSServices di AppDelegate.

---

### ✅ STEP 3: Implementasi Utils Haversine Distance
**File BARU** → `mobile_app/lib/core/utils/haversine_distance.dart`

Fungsi util global untuk:
- Hitung jarak kilometer antara 2 titik `(lat1,lng1)` dan `(lat2,lng2)`
- Rumus: Great-circle distance di Dart, gunakan `dart:math` `sin`, `cos`, `atan2`, `sqrt`
- Return: `double` dalam satuan **kilometer (km)**, presisi 2 desimal

Fungsi public:
```dart
double haversineDistanceKm(double lat1, double lng1, double lat2, double lng2);
List<T> sortByDistance<T>({
  required List<T> items,
  required LatLng userPos,
  required double Function(T) getLat,
  required double Function(T) getLng,
});
```

---

### ✅ STEP 4: Refactor Utama — `kapster_map_page.dart` (Kompleks 80%)
**File**: [features/kapster/pages/kapster_map_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/kapster/pages/kapster_map_page.dart)

#### 4.1 Import Cleanup
| Hapus Import | Tambahkan Import |
|---|---|
| `import 'package:google_maps_flutter/google_maps_flutter.dart';` | `import 'package:flutter_map/flutter_map.dart';` |
| `GoogleMapController? _mapController;` | `import 'package:latlong2/latlong.dart' as latlong;` — gunakan prefix `latlong.LatLng` vs project `LatLng` (karena ada name clash di class `BarbershopLocation`) |

Ubah deklarasi controller:
```dart
final MapController _mapController = MapController(); // flutter_map controller
```
Hapus `GoogleMapController? _mapController;` dan `LatLng? _currentLocation;` (ganti ke `latlong.LatLng`).

#### 4.2 Hapus class `_MapStreetPainter`
Fungsi painter fallback krem/kuning TIDAK DIPERLUKAN LAGI! Tile OSM CartoDB Positron sudah render jalan dengan warna real.

#### 4.3 Ganti `_buildMapLayer()` + Hilangkan VisualFallback
Sebelum = Stack(GoogleMap + _buildVisualMapFallback overlay)
SESUDAH:
```dart
Widget _buildMapLayer() {
  final userPos = _currentLocation!;
  return FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      initialCenter: userPos,
      initialZoom: 14,
      minZoom: 11,
      maxZoom: 19,
      interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
        subdomains: const ['a', 'b', 'c', 'd'],
        userAgentPackageName: 'com.trime.app',
        retinaMode: true,
      ),
      CircleLayer(circles: _buildUserAccuracyCircle(userPos)),
      MarkerLayer(markers: _buildAllMarkers()),
    ],
  );
}
```

#### 4.4 `_buildUserAccuracyCircle(latlong.LatLng pos)`
Return list 1 Circle dengan:
- `color: TrimeColors.secondaryBlue.withValues(alpha: 0.18)`
- `borderColor: TrimeColors.secondaryBlue.withValues(alpha: 0.5)`
- `borderStrokeWidth: 2`
- `radius: accuracyMeter` (nanti dari `Position.accuracy` hasil Geolocator)
- Fallback radius 50 meter jika tidak ada accuracy data

#### 4.5 `_buildAllMarkers()` — Semua Marker
1. **Marker User** (zIndex tertinggi):
   - `point: _currentLocation!`
   - `child: Container(...)` dengan Icon `Icons.person_pin_circle` warna CYAN, size 40, shadow
2. **6 Marker Barbershop** 🔴
   - Iterasi `_barbershops`
   - Icon `Icons.place` warna `Colors.red`, size 34
   - onTap → `setState(() => _selectedMarkerIdx = index)` + SnackBar
3. **5 Marker Kapster** 🔵 (regular) / 🟣 (exclusive)
   - Iterasi `_allKapsters`
   - Exclusive = `Colors.deepPurple`
   - Regular = `Colors.blue`
   - onTap → scroll bottom sheet + set selectedIdx

#### 4.6 Upgrade `_loadInitialLocation()`: Capture Accuracy
Tangkap `pos.accuracy` dari `Geolocator.getCurrentPosition()`, simpan ke field `double? _userAccuracy;` untuk pakai di Circle radius.

#### 4.7 Upgrade FAB "Lokasi Saya"
```dart
onPressed: () {
  if (_currentLocation == null) return;
  _mapController.move(_currentLocation!, 16); // LEBIH ZOOM IN
  ScaffoldMessenger.of(...).showSnackBar(...);
}
```

#### 4.8 Integrasi Haversine di InitState
Setelah `_currentLocation != null`:
```dart
// Sort _rekomendasiBarbershop ASCENDING by jarak real
_rekomendasiBarbershopSorted = sortByDistance<BarbershopLocation>(
  items: _rekomendasiBarbershop,
  userPos: _currentLocation!,
  getLat: (b) => b.latitude,
  getLng: (b) => b.longitude,
);
// Update juga field `distanceKm` display dari hasil haversine, bukan dummy
```

#### 4.9 Hapus function `_geoToRelativeOffset()`, `_buildMapPin()`, `_buildCurrentLocationPin()`, `_buildVisualMapFallback()`
Semua fungsi coordinate-to-pixel offset painter TIDAK DIPERLUKAN karena `flutter_map` handle projection otomatis.

---

### ✅ STEP 5: Refactor Detail Page — `barbershop_detail_page.dart`
**File**: [features/home/pages/barbershop_detail_page.dart](file:///d:/Project/TRIME/mobile_app/lib/features/home/pages/barbershop_detail_page.dart)

#### 5.1 Import Cleanup
| Hapus | Tambah |
|---|---|
| `google_maps_flutter.dart` | `flutter_map/flutter_map.dart` |
| `Set<Marker> previewMarkers = {}` yang hueRed dll | `latlong2` package |

#### 5.2 Rewrite `_buildMapPreview()` — Mini Map
**Hapus class `_MiniMapStreetPainter`** (tidak perlu).

Ganti seluruh `_buildMapPreview()` dengan:
```dart
Widget _buildMapPreview() {
  final lat = widget.barbershop.latitude;
  final lng = widget.barbershop.longitude;
  final bool hasCoords = (lat != null && lng != null);
  final shopPos = latlong.LatLng(lat ?? -6.9667, lng ?? 110.4167);

  return InkWell(
    onTap: _launchMaps,
    borderRadius: TrimeSpacing.radiusMd,
    child: Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.surfaceAlt),
      ),
      child: hasCoords
          ? Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: shopPos,
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(flags: 0), // NON-INTERACTIVE
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.trime.app',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: shopPos,
                        child: const Icon(Icons.place, color: Colors.red, size: 40, shadows: [Shadow(blurRadius: 4, color: Colors.black26)]),
                        width: 40, height: 40,
                      ),
                    ]),
                  ],
                ),
                // Bottom CTA gradient bar SAMA SEPERTI SEBELUMNYA
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                      ),
                    ),
                    child: Row(children: [
                      const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      const Expanded(child: Text('Lihat rute & lokasi di Google Maps', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                    ]),
                  ),
                ),
              ],
            )
          : _buildNoCoordsFallback(), // Icon location_off
    ),
  );
}
```

#### 5.3 Upgrade `_launchMaps()` — Support Origin User Position
Kalau di `appState` / shared preferences kita simpan last known user location → kirim sebagai `origin`:
```dart
Uri.parse(
  'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$destLat,$destLng&travelmode=driving'
);
```
Kalau tidak ada user location → hanya `destination=` (GMaps nanti otomatis minta origin di app).

---

### ✅ STEP 6: Cleanup `Barbershop` & Model Lain
- Field `latitude`/`longitude` di `Barbershop` base class **SUDAH DITAMBAHKAN sesi lalu** → `double? nullable` OK, tidak perlu ubah.
- **Class `BarbershopLocation` refactor pass to parent via `super()`** → SUDAH DILAKUKAN sesi lalu → skip.

---

### ✅ STEP 7: Global Search & Hapus Sisa `google_maps_flutter`
Command pencarian:
```bash
# Cek di seluruh project apakah masih ada sisa import / penggunaan
Select-String -Path "lib\**\*.dart" -Pattern "google_maps_flutter|BitmapDescriptor|GoogleMap|MapType\.normal" 2>$null
```
Jika ada penemuan → fix satu per satu.

---

### ✅ STEP 8: Static Analysis & Compile Check
```bash
cd d:\Project\TRIME
flutter analyze
```
Target: **No issues found!** (0 errors, 0 warnings, 0 infos).

Jika ada warning `unnecessary_underscores`, `deprecated_member_use`, `annotate_overrides` → fix segera sesuai checklist quality rules project.

---

### ✅ STEP 9: Manual Test di Device (Android)
9 Checklist yang **WAJIB PASS** sebelum mark selesai:

| # | Test Case | Expected Result |
|---|---|---|
| T1 | Buka Map Tab (Kapster) — allow GPS permission | Loading spinner → map muncul warna abu-abu CartoDB dengan JALAN NYATA |
| T2 | Lokasi user tampil | Marker cyan + pulsing circle biru muda ada tepat di posisi Semarang user |
| T3 | 6 Marker Barber merah terlihat | Persebaran sesuai koordinat (bukan terkumpul 1 titik) |
| T4 | 5 Marker Kapster biru/ungu terlihat | Jelas beda warna dari barber |
| T5 | Tap FAB "Lokasi Saya" | Camera animasi ke posisi user, zoom 16, muncul snackbar "Menuju lokasi kamu" |
| T6 | Tap marker merah (Master Cut) | Snackbar nama toko + bottom sheet tampilkan card Master Cut |
| T7 | Scroll list Rekomendasi bawah | Urut dari jarak terkecil (Haversine) di kiri |
| T8 | Buka detail "Master Cut" → section Lokasi | Mini map tampil jalan nyata + 1 marker merah tepat di toko |
| T9 | Tap mini map / tombol Rute | Pindah ke Google Maps App External → origin otomatis, destination Master Cut → rute langsung digambar |

---

## 4. 📁 File Changes Summary

| File | Action | Scope |
|---|---|---|
| `mobile_app/pubspec.yaml` | Edit | Hapus `google_maps_flutter`, Tambah `flutter_map: ^8.3.0`, `latlong2: ^0.9.0` |
| `mobile_app/android/app/src/main/AndroidManifest.xml` | Edit | Hapus `<meta-data com.google.android.geo.API_KEY>` |
| `mobile_app/lib/core/utils/haversine_distance.dart` | **NEW** | Fungsi util Haversine + sort by distance |
| `mobile_app/lib/features/kapster/pages/kapster_map_page.dart` | Large Rewrite (~80%) | Semua widget GoogleMap diganti FlutterMap, hapus painter fallback, tambah CircleLayer + MarkerLayer, integrasi Haversine |
| `mobile_app/lib/features/home/pages/barbershop_detail_page.dart` | Medium Rewrite (~40%) | `_buildMapPreview()` ganti GoogleMap mini → flutter_map, hapus `_MiniMapStreetPainter`, upgrade `_launchMaps()` |
| `mobile_app/lib/shared_widgets/card_barbershop.dart` | Skip | Sudah OK (field lat/lng nullable ditambahkan) |

**Estimasi Total Lines Changed:** ~650 lines (add + remove bersih)

---

## 5. 🔄 Rollback Plan (Jika Critical Issue Muncul)
Kalau ada issue tak terduga (mis. flutter_map performance buruk di Android lama):
1. `git checkout` atau revert commit migrasi
2. Kembalikan baris `google_maps_flutter: ^2.9.0` di pubspec.yaml
3. Kembalikan `<meta-data API_KEY>` di AndroidManifest
4. Paste API KEY Google Maps (jika sudah punya billing setup)
5. `flutter clean ; flutter pub get ; flutter analyze`

---

## 6. 🛣️ Future Roadmap (Setelah MVP Stabil)
| Fitur | Deskripsi | Cost |
|---|---|---|
| Offline Tile Cache | Pakai `flutter_map_cached_tile_provider` — simpan tile Semarang area 20km², hemat kuota user data | GRATIS |
| Clustering Marker | Kalau barbershop > 50, perlu package `flutter_map_marker_cluster` | GRATIS |
| Search Nominatim OSM | Cari nama jalan / kelurahan via API Nominatim (gratis rate limit 1/s) | GRATIS |
| Polyline rute via OpenRouteService | Gambar garis rute DI DALAM app (bukan cuma external GMaps) — Free Tier 2000 req/hari | GRATIS |

---

## 7. ✅ Definition of Done (DoD)
1. `flutter analyze` = **No issues found** (exit code 0)
2. 9 poin Manual Test Case (T1-T9) di atas = **100% PASS**
3. Tidak ada lagi import `google_maps_flutter` di manapun
4. Tidak ada reference ke `BitmapDescriptor`, `GoogleMapController`, `MapType`
5. Setiap marker di klik → terlihat InfoWindow / SnackBar nama
6. Device GPS off → fallback ke `_semarangCenter` dengan marker user placeholder, tidak crash

---

**END OF PLAN**
