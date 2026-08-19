import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'app_state.dart';

class SupabaseConfig {
  // Supabase URL & Anon Key
  static String supabaseUrl = 'https://ttlladewtuhorjraipva.supabase.co';
  static String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0bGxhZGV3dHVob3JqcmFpcHZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwMTQ5MjUsImV4cCI6MjA5MTU5MDkyNX0.iDWdKSdYWJSWZ0j7HkV0Tlfa620RhR_SdjTHBu8KcA8';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  SupabaseClient? get client => _initialized ? Supabase.instance.client : null;

  Future<void> init({String? url, String? anonKey}) async {
    var finalUrl = url ?? SupabaseConfig.supabaseUrl;
    final finalKey = anonKey ?? SupabaseConfig.supabaseAnonKey;

    if (finalUrl.endsWith('/rest/v1/') || finalUrl.endsWith('/rest/v1')) {
      finalUrl = finalUrl.replaceAll(RegExp(r'/rest/v1/?$'), '');
    }

    if (finalUrl.isEmpty ||
        finalUrl == 'YOUR_SUPABASE_URL' ||
        finalKey.isEmpty ||
        finalKey == 'YOUR_SUPABASE_ANON_KEY') {
      debugPrint('Supabase: URL & Anon Key belum diisi. Berjalan dalam mode offline/local.');
      return;
    }

    try {
      await Supabase.initialize(
        url: finalUrl,
        // ignore: deprecated_member_use
        anonKey: finalKey,
      );
      _initialized = true;
      debugPrint('Supabase: Berhasil diinisialisasi! Terhubung ke $finalUrl');
    } catch (e) {
      debugPrint('Supabase init warning: $e');
    }
  }

  // ─── PROFILES / USERS ───
  Future<TrimeUser?> fetchProfileByIdOrPhone({String? id, String? phone, String? email}) async {
    if (!isInitialized || client == null) return null;
    try {
      Map<String, dynamic>? data;
      if (id != null && id.isNotEmpty) {
        final res = await client!.from('profiles').select().eq('id', id).maybeSingle();
        data = res;
      }
      if (data == null && phone != null && phone.isNotEmpty) {
        final res = await client!.from('profiles').select().eq('phone_number', phone).maybeSingle();
        data = res;
      }
      if (data == null && email != null && email.isNotEmpty) {
        final res = await client!.from('profiles').select().eq('email', email).maybeSingle();
        data = res;
      }
      if (data != null) {
        final roleStr = data['role'] as String?;
        return TrimeUser(
          id: data['id'] as String,
          name: data['name'] as String? ?? 'Pengguna TRIME',
          phoneNumber: data['phone_number'] as String? ?? '',
          email: data['email'] as String?,
          photoUrl: data['photo_url'] as String?,
          role: UserRole.values.firstWhere(
            (e) => e.name == roleStr,
            orElse: () => UserRole.pelanggan,
          ),
          createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Supabase fetchProfile error: $e');
    }
    return null;
  }

  // Cari profil berdasarkan username, phone, atau email (untuk login credentials)
  Future<TrimeUser?> fetchProfileByIdentifier(String identifier) async {
    if (!isInitialized || client == null) return null;
    try {
      // Coba cari berdasarkan phone_number
      Map<String, dynamic>? data;
      final byPhone = await client!.from('profiles').select().eq('phone_number', identifier).maybeSingle();
      data = byPhone;

      // Coba berdasarkan email
      if (data == null) {
        final byEmail = await client!.from('profiles').select().eq('email', identifier).maybeSingle();
        data = byEmail;
      }

      // Coba berdasarkan username
      if (data == null) {
        final byUsername = await client!.from('profiles').select().eq('username', identifier).maybeSingle();
        data = byUsername;
      }

      if (data != null) {
        final roleStr = data['role'] as String?;
        return TrimeUser(
          id: data['id'] as String,
          name: data['name'] as String? ?? 'Pengguna TRIME',
          phoneNumber: data['phone_number'] as String? ?? '',
          email: data['email'] as String?,
          photoUrl: data['photo_url'] as String?,
          role: UserRole.values.firstWhere(
            (e) => e.name == roleStr,
            orElse: () => UserRole.pelanggan,
          ),
          createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
          passwordHash: data['password_hash'] as String? ?? '',
          username: data['username'] as String? ?? '',
        );
      }
    } catch (e) {
      debugPrint('Supabase fetchProfileByIdentifier error: $e');
    }
    return null;
  }


  Future<void> upsertProfile(TrimeUser user) async {
    if (!isInitialized || client == null) return;
    try {
      final map = <String, dynamic>{
        'id': user.id,
        'name': user.name,
        'phone_number': user.phoneNumber,
        'email': user.email,
        'photo_url': user.photoUrl,
        'role': user.role.name,
        'created_at': user.createdAt.toIso8601String(),
      };
      if (user.username != null && user.username!.isNotEmpty) {
        map['username'] = user.username;
      }
      if (user.passwordHash != null && user.passwordHash!.isNotEmpty) {
        map['password_hash'] = user.passwordHash;
      }
      await client!.from('profiles').upsert(map);
      debugPrint('Supabase: Profil ${user.name} berhasil di-upsert!');
    } catch (e) {
      debugPrint('Supabase upsertProfile error: $e');
    }
  }

  // ─── BARBERSHOPS ───
  Future<List<BarbershopProfile>> fetchBarbershops() async {
    if (!isInitialized || client == null) return [];
    try {
      final List<dynamic> res = await client!.from('barbershops').select();
      return res.map((map) {
        final data = map as Map<String, dynamic>;
        return BarbershopProfile(
          id: data['id'] as String,
          ownerUserId: data['owner_user_id'] as String? ?? '',
          name: data['name'] as String? ?? 'Barbershop',
          address: data['address'] as String? ?? '',
          phone: data['phone'] as String? ?? '',
          hours: data['hours'] as String? ?? '',
          coverUrl: data['cover_url'] as String?,
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          isNew: data['is_new'] as bool? ?? false,
          gallery: (data['gallery'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase fetchBarbershops error: $e');
      return [];
    }
  }

  Future<void> upsertBarbershop(BarbershopProfile shop) async {
    if (!isInitialized || client == null) return;
    try {
      await client!.from('barbershops').upsert({
        'id': shop.id,
        'owner_user_id': shop.ownerUserId,
        'name': shop.name,
        'address': shop.address,
        'phone': shop.phone,
        'hours': shop.hours,
        'cover_url': shop.coverUrl,
        'latitude': shop.latitude,
        'longitude': shop.longitude,
        'rating': shop.rating,
        'is_new': shop.isNew,
        'gallery': shop.gallery,
      });
      debugPrint('Supabase: Barbershop ${shop.name} di-upsert!');
    } catch (e) {
      debugPrint('Supabase upsertBarbershop error: $e');
    }
  }

  // ─── KAPSTERS ───
  Future<List<KapsterProfile>> fetchKapsters() async {
    if (!isInitialized || client == null) return [];
    try {
      final List<dynamic> res = await client!.from('kapsters').select();
      return res.map((map) {
        final data = map as Map<String, dynamic>;
        return KapsterProfile(
          id: data['id'] as String,
          userId: data['user_id'] as String? ?? '',
          name: data['name'] as String? ?? 'Kapster',
          photoUrl: data['photo_url'] as String?,
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          specialties: (data['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          badgeType: data['badge_type'] as String? ?? '',
          isReady: data['is_ready'] as bool? ?? false,
          topRank: data['top_rank'] as String?,
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase fetchKapsters error: $e');
      return [];
    }
  }

  Future<void> upsertKapster(KapsterProfile kapster) async {
    if (!isInitialized || client == null) return;
    try {
      await client!.from('kapsters').upsert({
        'id': kapster.id,
        'user_id': kapster.userId,
        'name': kapster.name,
        'photo_url': kapster.photoUrl,
        'rating': kapster.rating,
        'specialties': kapster.specialties,
        'badge_type': kapster.badgeType,
        'is_ready': kapster.isReady,
        'top_rank': kapster.topRank,
        'latitude': kapster.latitude,
        'longitude': kapster.longitude,
      });
      debugPrint('Supabase: Kapster ${kapster.name} di-upsert!');
    } catch (e) {
      debugPrint('Supabase upsertKapster error: $e');
    }
  }

  // ─── BOOKINGS ───
  Future<List<BookingItem>> fetchBookings() async {
    if (!isInitialized || client == null) return [];
    try {
      final List<dynamic> res = await client!.from('bookings').select().order('created_at', ascending: false);
      return res.map((map) {
        final data = map as Map<String, dynamic>;
        return BookingItem(
          id: data['id'] as String,
          barbershopId: data['barbershop_name'] as String? ?? '',
          customerName: data['customer_name'] as String? ?? '',
          kapsterName: data['kapster_name'] as String? ?? '',
          serviceName: data['service_name'] as String? ?? '',
          price: (data['price'] as num?)?.toInt() ?? 0,
          date: DateTime.parse(data['booking_date'] as String),
          status: data['status'] as String? ?? 'pending',
          notes: data['notes'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase fetchBookings error: $e');
      return [];
    }
  }

  Future<void> createBooking(BookingItem booking) async {
    if (!isInitialized || client == null) return;
    try {
      await client!.from('bookings').insert({
        'id': booking.id,
        'customer_name': booking.customerName,
        'barbershop_name': booking.barbershopId,
        'kapster_name': booking.kapsterName,
        'service_name': booking.serviceName,
        'price': booking.price,
        'booking_date': booking.date.toIso8601String(),
        'status': booking.status,
        'notes': booking.notes,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Supabase: Booking ${booking.id} berhasil ditambahkan!');
    } catch (e) {
      debugPrint('Supabase createBooking error: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    if (!isInitialized || client == null) return;
    try {
      await client!.from('bookings').update({
        'status': newStatus,
      }).eq('id', bookingId);
      debugPrint('Supabase: Booking $bookingId diubah ke $newStatus!');
    } catch (e) {
      debugPrint('Supabase updateBookingStatus error: $e');
    }
  }
}

final SupabaseService supabaseService = SupabaseService();
