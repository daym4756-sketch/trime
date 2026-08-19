import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared_widgets/card_barbershop.dart';
import '../../shared_widgets/card_kapster.dart';
import 'supabase_service.dart';

class AvailabilitySlot {
  final DateTime start;
  final bool isAvailable;

  const AvailabilitySlot({
    required this.start,
    required this.isAvailable,
  });
}

class BookingItem {
  final String id;
  final String barbershopId;
  final String customerName;
  final String serviceName;
  final String kapsterName;
  final DateTime date;
  final int price;
  final String status;
  final String? notes;

  const BookingItem({
    required this.id,
    required this.barbershopId,
    required this.customerName,
    required this.serviceName,
    required this.kapsterName,
    required this.date,
    required this.price,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'barbershopId': barbershopId,
        'customerName': customerName,
        'serviceName': serviceName,
        'kapsterName': kapsterName,
        'date': date.toIso8601String(),
        'price': price,
        'status': status,
        'notes': notes,
      };

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
        id: json['id'] as String,
        barbershopId: json['barbershopId'] as String? ?? '',
        customerName: json['customerName'] as String,
        serviceName: json['serviceName'] as String,
        kapsterName: json['kapsterName'] as String,
        date: DateTime.parse(json['date'] as String),
        price: json['price'] as int? ?? 0,
        status: json['status'] as String,
        notes: json['notes'] as String?,
      );
}

class BarbershopProfile {
  final String id;
  final String ownerUserId;
  final String name;
  final String address;
  final String phone;
  final String hours;
  final String? coverUrl;
  final double? latitude;
  final double? longitude;
  final double rating;
  final bool isNew;
  final List<String> gallery;
  final List<ServiceItem> services;
  final List<BarbershopKapster> kapsters;

  const BarbershopProfile({
    required this.id,
    required this.ownerUserId,
    required this.name,
    this.address = '',
    this.phone = '',
    this.hours = '',
    this.coverUrl,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.isNew = false,
    this.gallery = const [],
    this.services = const [],
    this.kapsters = const [],
  });

  BarbershopProfile copyWith({
    String? id,
    String? ownerUserId,
    String? name,
    String? address,
    String? phone,
    String? hours,
    String? coverUrl,
    double? latitude,
    double? longitude,
    double? rating,
    bool? isNew,
    List<String>? gallery,
    List<ServiceItem>? services,
    List<BarbershopKapster>? kapsters,
  }) {
    return BarbershopProfile(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      hours: hours ?? this.hours,
      coverUrl: coverUrl ?? this.coverUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      isNew: isNew ?? this.isNew,
      gallery: gallery ?? this.gallery,
      services: services ?? this.services,
      kapsters: kapsters ?? this.kapsters,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'name': name,
        'address': address,
        'phone': phone,
        'hours': hours,
        'coverUrl': coverUrl,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
        'isNew': isNew,
        'gallery': gallery,
        'services': services.map((s) => s.toJson()).toList(),
        'kapsters': kapsters.map((k) => k.toJson()).toList(),
      };

  factory BarbershopProfile.fromJson(Map<String, dynamic> json) {
    return BarbershopProfile(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String? ?? '',
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      coverUrl: json['coverUrl'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isNew: json['isNew'] as bool? ?? false,
      gallery: (json['gallery'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      services: ((json['services'] as List<dynamic>?) ?? [])
          .map((e) => ServiceItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
      kapsters: ((json['kapsters'] as List<dynamic>?) ?? [])
          .map((e) => BarbershopKapster.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
    );
  }
}

class ServiceItem {
  final int id;
  final String name;
  final int price;
  final String duration;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'duration': duration,
      };

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        duration: json['duration'] as String? ?? '45 menit',
      );
}

class BarbershopKapster {
  final int id;
  final String name;
  final String? photoUrl;
  final double rating;
  final String specialty;
  final bool isActive;

  const BarbershopKapster({
    required this.id,
    required this.name,
    this.photoUrl,
    this.rating = 0.0,
    this.specialty = 'Umum',
    this.isActive = true,
  });

  BarbershopKapster copyWith({
    int? id,
    String? name,
    String? photoUrl,
    double? rating,
    String? specialty,
    bool? isActive,
  }) {
    return BarbershopKapster(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      specialty: specialty ?? this.specialty,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'rating': rating,
        'specialty': specialty,
        'isActive': isActive,
      };

  factory BarbershopKapster.fromJson(Map<String, dynamic> json) =>
      BarbershopKapster(
        id: json['id'] as int,
        name: json['name'] as String,
        photoUrl: json['photoUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        specialty: json['specialty'] as String? ?? 'Umum',
        isActive: json['isActive'] as bool? ?? true,
      );
}

class KapsterProfile {
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;
  final double rating;
  final List<String> specialties;
  final String badgeType;
  final bool isReady;
  final String? topRank;
  final double? latitude;
  final double? longitude;

  const KapsterProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.rating = 0.0,
    this.specialties = const [],
    this.badgeType = '',
    this.isReady = false,
    this.topRank,
    this.latitude,
    this.longitude,
  });

  KapsterProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? photoUrl,
    double? rating,
    List<String>? specialties,
    String? badgeType,
    bool? isReady,
    String? topRank,
    double? latitude,
    double? longitude,
  }) {
    return KapsterProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      specialties: specialties ?? this.specialties,
      badgeType: badgeType ?? this.badgeType,
      isReady: isReady ?? this.isReady,
      topRank: topRank ?? this.topRank,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'photoUrl': photoUrl,
        'rating': rating,
        'specialties': specialties,
        'badgeType': badgeType,
        'isReady': isReady,
        'topRank': topRank,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory KapsterProfile.fromJson(Map<String, dynamic> json) => KapsterProfile(
        id: json['id'] as String,
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String,
        photoUrl: json['photoUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        specialties: (json['specialties'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        badgeType: json['badgeType'] as String? ?? '',
        isReady: json['isReady'] as bool? ?? false,
        topRank: json['topRank'] as String?,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
      );
}

class AppState extends ChangeNotifier {
  static const String _kFavBarbers = 'trime_fav_barbers';
  static const String _kFavKapsters = 'trime_fav_kapsters';
  static const String _kBookings = 'trime_bookings';
  static const String _kShops = 'trime_shops_v2';
  static const String _kKapsters = 'trime_kapsters_v2';
  static const String _kLastLat = 'trime_last_lat';
  static const String _kLastLng = 'trime_last_lng';

  final Set<String> _favoriteBarbershopIds = {};
  final Set<String> _favoriteKapsterIds = {};
  final List<BookingItem> _bookings = [];
  final List<BarbershopProfile> _barbershops = [];
  final List<KapsterProfile> _kapsters = [];

  double? _lastKnownLat;
  double? _lastKnownLng;

  Set<String> get favoriteBarbershopIds => Set.unmodifiable(_favoriteBarbershopIds);
  Set<String> get favoriteKapsterIds => Set.unmodifiable(_favoriteKapsterIds);
  List<BookingItem> get bookings => List.unmodifiable(_bookings);
  List<BarbershopProfile> get barbershops => List.unmodifiable(_barbershops);
  List<KapsterProfile> get kapsters => List.unmodifiable(_kapsters);
  double? get lastKnownLat => _lastKnownLat;
  double? get lastKnownLng => _lastKnownLng;

  Future<void> updateLastKnownLocation(double lat, double lng) async {
    _lastKnownLat = lat;
    _lastKnownLng = lng;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLastLat, lat);
    await prefs.setDouble(_kLastLng, lng);
    notifyListeners();
  }

  bool isFavoriteBarbershop(String nameOrId) =>
      _favoriteBarbershopIds.contains(nameOrId);

  bool isFavoriteKapster(String name) => _favoriteKapsterIds.contains(name);

  void toggleFavoriteBarbershop(String nameOrId) {
    if (isFavoriteBarbershop(nameOrId)) {
      _favoriteBarbershopIds.remove(nameOrId);
    } else {
      _favoriteBarbershopIds.add(nameOrId);
    }
    _persistFavs();
    notifyListeners();
  }

  void toggleFavoriteKapster(String name) {
    if (isFavoriteKapster(name)) {
      _favoriteKapsterIds.remove(name);
    } else {
      _favoriteKapsterIds.add(name);
    }
    _persistFavs();
    notifyListeners();
  }

  List<Barbershop> filterFavoriteBarbershops(List<Barbershop> all) {
    return all.where((Barbershop b) => isFavoriteBarbershop(b.name)).toList();
  }

  List<Kapster> filterFavoriteKapsters(List<Kapster> all) {
    return all.where((Kapster k) => isFavoriteKapster(k.nama)).toList();
  }

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    // Muat favorit
    final favB = prefs.getStringList(_kFavBarbers);
    if (favB != null) {
      _favoriteBarbershopIds
        ..clear()
        ..addAll(favB);
    }
    final favK = prefs.getStringList(_kFavKapsters);
    if (favK != null) {
      _favoriteKapsterIds
        ..clear()
        ..addAll(favK);
    }

    // Muat lokasi terakhir
    if (prefs.containsKey(_kLastLat)) {
      _lastKnownLat = prefs.getDouble(_kLastLat);
      _lastKnownLng = prefs.getDouble(_kLastLng);
    }

    // Kumpulkan toko: gabungkan lokal + Supabase dengan dedup by ID
    final Map<String, BarbershopProfile> shopMap = {};

    // 1. Muat dari lokal SharedPreferences
    final rawShops = prefs.getStringList(_kShops);
    if (rawShops != null) {
      for (final s in rawShops) {
        try {
          final p = BarbershopProfile.fromJson(jsonDecode(s) as Map<String, dynamic>);
          shopMap[p.id] = p;
        } catch (_) {}
      }
    }

    // 2. Muat dari Supabase (prioritas lebih tinggi — timpa lokal jika ada ID sama)
    if (supabaseService.isInitialized) {
      try {
        final remoteShops = await supabaseService.fetchBarbershops();
        for (final p in remoteShops) {
          shopMap[p.id] = p;
        }
      } catch (e) {
        debugPrint('loadAll: fetchBarbershops error: $e');
      }
    }

    _barbershops
      ..clear()
      ..addAll(shopMap.values.toList());

    // Fallback demo jika belum ada toko sama sekali
    if (_barbershops.isEmpty) {
      _barbershops.addAll([
        const BarbershopProfile(
          id: 'shop_demo_1',
          ownerUserId: 'owner_1',
          name: 'Barberking Premium',
          address: 'Jl. Sudirman No. 45, Jakarta',
          phone: '081234567890',
          hours: 'Buka 09:00 - 21:00',
          rating: 4.9,
          latitude: -6.2088,
          longitude: 106.8456,
          isNew: false,
        ),
        const BarbershopProfile(
          id: 'shop_demo_2',
          ownerUserId: 'owner_2',
          name: 'Gentlemen Cut Barbershop',
          address: 'Jl. Gatot Subroto No. 12, Jakarta',
          phone: '081987654321',
          hours: 'Buka 10:00 - 22:00',
          rating: 4.8,
          latitude: -6.2297,
          longitude: 106.8167,
          isNew: true,
        ),
        const BarbershopProfile(
          id: 'shop_demo_3',
          ownerUserId: 'owner_3',
          name: 'Vintage Hair Studio',
          address: 'Jl. Senopati No. 88, Jakarta',
          phone: '081122334455',
          hours: 'Buka 09:00 - 20:00',
          rating: 4.7,
          latitude: -6.2345,
          longitude: 106.8090,
          isNew: false,
        ),
      ]);
    }

    // Kumpulkan kapster: gabungkan lokal + Supabase dengan dedup by ID
    final Map<String, KapsterProfile> kapsterMap = {};
    final rawKap = prefs.getStringList(_kKapsters);
    if (rawKap != null) {
      for (final s in rawKap) {
        try {
          final k = KapsterProfile.fromJson(jsonDecode(s) as Map<String, dynamic>);
          kapsterMap[k.id] = k;
        } catch (_) {}
      }
    }
    if (supabaseService.isInitialized) {
      try {
        final remoteKapsters = await supabaseService.fetchKapsters();
        for (final k in remoteKapsters) {
          kapsterMap[k.id] = k;
        }
      } catch (e) {
        debugPrint('loadAll: fetchKapsters error: $e');
      }
    }
    _kapsters
      ..clear()
      ..addAll(kapsterMap.values.toList());

    // Kumpulkan booking: gabungkan lokal + Supabase dengan dedup by ID
    final Map<String, BookingItem> bookingMap = {};
    final rawBookings = prefs.getStringList(_kBookings);
    if (rawBookings != null) {
      for (final s in rawBookings) {
        try {
          final b = BookingItem.fromJson(jsonDecode(s) as Map<String, dynamic>);
          bookingMap[b.id] = b;
        } catch (_) {}
      }
    }
    if (supabaseService.isInitialized) {
      try {
        final remoteBookings = await supabaseService.fetchBookings();
        for (final b in remoteBookings) {
          bookingMap[b.id] = b;
        }
      } catch (e) {
        debugPrint('loadAll: fetchBookings error: $e');
      }
    }
    _bookings
      ..clear()
      ..addAll(bookingMap.values.toList());

    notifyListeners();
  }

  Future<void> _persistFavs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFavBarbers, _favoriteBarbershopIds.toList());
    await prefs.setStringList(_kFavKapsters, _favoriteKapsterIds.toList());
  }

  Future<void> _persistBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kBookings,
      _bookings.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  Future<void> _persistShops() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kShops,
      _barbershops.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  Future<void> _persistKapsters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kKapsters,
      _kapsters.map((k) => jsonEncode(k.toJson())).toList(),
    );
  }

  String addBooking({
    Barbershop? barbershop,
    Kapster? kapster,
    required DateTime dateTime,
    required String serviceName,
    required double price,
    String? notes,
    String? customerName,
  }) {
    final id = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final b = BookingItem(
      id: id,
      barbershopId: barbershop?.name ?? '',
      customerName: customerName ?? 'Customer',
      serviceName: serviceName,
      kapsterName: kapster?.nama ?? '',
      date: dateTime,
      price: price.toInt(),
      status: 'pending',
      notes: notes,
    );
    _bookings.add(b);
    _persistBookings();
    supabaseService.createBooking(b);
    notifyListeners();
    return id;
  }

  void addBookingRaw(BookingItem b) {
    _bookings.add(b);
    _persistBookings();
    supabaseService.createBooking(b);
    notifyListeners();
  }

  void updateBookingStatus(String id, String status) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx < 0) return;
    final old = _bookings[idx];
    _bookings[idx] = BookingItem(
      id: old.id,
      barbershopId: old.barbershopId,
      customerName: old.customerName,
      serviceName: old.serviceName,
      kapsterName: old.kapsterName,
      date: old.date,
      price: old.price,
      status: status,
      notes: old.notes,
    );
    _persistBookings();
    supabaseService.updateBookingStatus(id, status);
    notifyListeners();
  }

  void cancelBooking(String id) {
    updateBookingStatus(id, 'cancelled');
  }

  List<BookingItem> bookingsForUser(String userIdOrRole) {
    return _bookings;
  }

  List<BookingItem> get upcomingBookings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _bookings.where((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      final isPastOrCancelled = b.status == 'done' || b.status == 'cancelled';
      return bDate.isAfter(today.subtract(const Duration(days: 1))) && !isPastOrCancelled;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<BookingItem> get pastBookings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _bookings.where((b) {
      final bDate = DateTime(b.date.year, b.date.month, b.date.day);
      final isDoneOrCancelled = b.status == 'done' || b.status == 'cancelled';
      return bDate.isBefore(today) || isDoneOrCancelled;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<AvailabilitySlot> generateAvailabilitySlots(DateTime date) {
    final slots = <AvailabilitySlot>[];
    final dayStart = DateTime(date.year, date.month, date.day, 8, 0);
    const totalSlots = 27;
    for (int i = 0; i < totalSlots; i++) {
      final start = dayStart.add(Duration(minutes: 30 * i));
      final end = start.add(const Duration(minutes: 30));
      final isBooked = _bookings.any((b) {
        if (b.status == 'cancelled' || b.status == 'done') return false;
        return !(b.date.isBefore(start) || !b.date.isBefore(end));
      });
      slots.add(AvailabilitySlot(start: start, isAvailable: !isBooked));
    }
    return slots;
  }

  Future<void> updateUserLocation(double lat, double lng) async {
    _lastKnownLat = lat;
    _lastKnownLng = lng;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLastLat, lat);
    await prefs.setDouble(_kLastLng, lng);
    notifyListeners();
  }

  final Map<String, String> _activeShopIdByOwner = {};

  /// Mendapatkan SEMUA barbershop milik seorang Mitra
  List<BarbershopProfile> barbershopsForOwner(String ownerUserId) {
    if (ownerUserId.isEmpty) return [];
    return _barbershops.where((b) => b.ownerUserId == ownerUserId).toList();
  }

  /// Mendapatkan Barbershop AKTIF yang sedang dikelola oleh Mitra
  BarbershopProfile activeBarbershopForOwner(String ownerUserId) {
    final owned = barbershopsForOwner(ownerUserId);
    if (owned.isNotEmpty) {
      final selectedId = _activeShopIdByOwner[ownerUserId];
      if (selectedId != null) {
        final match = owned.firstWhere((b) => b.id == selectedId, orElse: () => owned.first);
        return match;
      }
      return owned.first;
    }
    // Jika belum punya toko sama sekali, buat toko default pertama
    final defaultShop = BarbershopProfile(
      id: 'shop_${ownerUserId}_${DateTime.now().millisecondsSinceEpoch}',
      ownerUserId: ownerUserId,
      name: 'Barbershop Saya',
      address: '',
      phone: '',
      hours: '09:00 - 21:00',
    );
    _barbershops.add(defaultShop);
    _activeShopIdByOwner[ownerUserId] = defaultShop.id;
    _persistShops();
    supabaseService.upsertBarbershop(defaultShop);
    return defaultShop;
  }

  /// Mengganti toko yang aktif dikelola oleh Mitra
  void setActiveBarbershopForOwner(String ownerUserId, String shopId) {
    _activeShopIdByOwner[ownerUserId] = shopId;
    notifyListeners();
  }

  /// Membuat toko barbershop BARU untuk Mitra yang sama
  Future<BarbershopProfile> createNewBarbershopForOwner(String ownerUserId, {String? name}) async {
    final ownedCount = barbershopsForOwner(ownerUserId).length;
    final newShopName = name ?? 'Barbershop Cabang ${ownedCount + 1}';
    final newShop = BarbershopProfile(
      id: 'shop_${ownerUserId}_${DateTime.now().millisecondsSinceEpoch}',
      ownerUserId: ownerUserId,
      name: newShopName,
      address: '',
      phone: '',
      hours: '09:00 - 21:00',
      isNew: true,
    );
    _barbershops.add(newShop);
    _activeShopIdByOwner[ownerUserId] = newShop.id;
    await _persistShops();
    await supabaseService.upsertBarbershop(newShop);
    notifyListeners();
    return newShop;
  }

  BarbershopProfile? barbershopByIdOrName(String idOrName) {
    try {
      return _barbershops.firstWhere(
        (b) => b.id == idOrName || b.name.toLowerCase() == idOrName.toLowerCase(),
      );
    } on StateError catch (_) {
      return null;
    }
  }

  Future<void> upsertBarbershop(BarbershopProfile profile) async {
    final idx = _barbershops.indexWhere((b) => b.id == profile.id);
    if (idx >= 0) {
      _barbershops[idx] = profile;
    } else {
      _barbershops.add(profile);
    }
    _activeShopIdByOwner[profile.ownerUserId] = profile.id;
    await _persistShops();
    await supabaseService.upsertBarbershop(profile);
    notifyListeners();
  }

  KapsterProfile? kapsterForUser(String userId) {
    try {
      return _kapsters.firstWhere((k) => k.userId == userId);
    } on StateError catch (_) {
      return null;
    }
  }

  Future<void> upsertKapster(KapsterProfile profile) async {
    final idx = _kapsters.indexWhere((k) => k.id == profile.id);
    if (idx >= 0) {
      _kapsters[idx] = profile;
    } else {
      _kapsters.add(profile);
    }
    await _persistKapsters();
    await supabaseService.upsertKapster(profile);
    notifyListeners();
  }
}

final AppState appState = AppState();
