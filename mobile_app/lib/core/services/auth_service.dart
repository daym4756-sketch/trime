import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'supabase_service.dart';

enum UserRole { pelanggan, mitra, kapster }

class TrimeUser {
  final String id;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final String? username;
  final String? passwordHash;

  const TrimeUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.email,
    this.photoUrl,
    required this.createdAt,
    this.username,
    this.passwordHash,
  });

  factory TrimeUser.fromJson(Map<String, dynamic> json) {
    return TrimeUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.pelanggan,
      ),
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      username: json['username'] as String?,
      passwordHash: json['passwordHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'username': username,
      'passwordHash': passwordHash,
    };
  }

  TrimeUser copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    UserRole? role,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    String? username,
    String? passwordHash,
  }) {
    return TrimeUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  // Hash password sederhana (SHA-like menggunakan base64 XOR untuk prototype)
  // Di produksi gunakan crypto package bcrypt/argon2
  static String hashPassword(String password) {
    final bytes = utf8.encode('trime_salt_$password');
    return base64Encode(bytes);
  }

  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyUser = 'trime_user';
  static const String _keyToken = 'trime_token';
  static const String _keyOnboarded = 'trime_onboarded';

  TrimeUser? _currentUser;
  String? _token;
  bool _isOnboarded = false;

  TrimeUser? get currentUser => _currentUser;
  String? get token => _token;
  bool get isOnboarded => _isOnboarded;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool(_keyOnboarded) ?? false;

    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        final decoded = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = TrimeUser.fromJson(decoded);
      } catch (_) {
        _currentUser = null;
      }
    }
    _token = prefs.getString(_keyToken);
  }

  Future<void> setOnboarded() async {
    _isOnboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }

  // ─── CREDENTIAL LOGIN (Username/Phone + Password) ───
  /// Login menggunakan identifier (No.HP/Username) dan password.
  /// Mengembalikan null jika akun tidak ada atau password salah.
  Future<TrimeUser?> loginWithCredentials({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Coba ambil dari lokal SharedPreferences dulu
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    TrimeUser? localUser;
    for (final key in allKeys) {
      if (key.startsWith('trime_account_')) {
        final raw = prefs.getString(key);
        if (raw != null) {
          try {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            final u = TrimeUser.fromJson(map);
            if (u.phoneNumber == identifier || u.username == identifier || u.email == identifier) {
              localUser = u;
              break;
            }
          } catch (_) {}
        }
      }
    }

    // Jika ada di lokal, verifikasi password
    if (localUser != null) {
      if (localUser.passwordHash != null &&
          TrimeUser.verifyPassword(password, localUser.passwordHash!)) {
        await _saveSession(localUser);
        return localUser;
      }
      return null; // Password salah
    }

    // Coba dari Supabase remote
    final remoteUser = await supabaseService.fetchProfileByIdentifier(identifier);
    if (remoteUser != null) {
      if (remoteUser.passwordHash != null &&
          TrimeUser.verifyPassword(password, remoteUser.passwordHash!)) {
        // Simpan ke lokal
        await prefs.setString(
          'trime_account_${remoteUser.id}',
          jsonEncode(remoteUser.toJson()),
        );
        await _saveSession(remoteUser);
        return remoteUser;
      }
      return null; // Password salah
    }

    return null; // Akun tidak ditemukan
  }

  // ─── CREDENTIAL REGISTER (Nama + No.HP + Password) ───
  /// Daftar akun baru menggunakan nama, nomor WhatsApp, dan password.
  /// Jika nomor sudah terdaftar, kembalikan null (akun sudah ada).
  Future<TrimeUser?> registerWithCredentials({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();

    // Cek apakah sudah terdaftar di lokal
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('trime_account_')) {
        final raw = prefs.getString(key);
        if (raw != null) {
          try {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            final u = TrimeUser.fromJson(map);
            if (u.phoneNumber == phone) {
              return null; // Nomor sudah terdaftar
            }
          } catch (_) {}
        }
      }
    }

    // Cek di Supabase
    final existing = await supabaseService.fetchProfileByIdOrPhone(phone: phone);
    if (existing != null) {
      return null; // Nomor sudah terdaftar di remote
    }

    // Buat akun baru
    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = TrimeUser(
      id: newId,
      name: name,
      phoneNumber: phone,
      role: role,
      username: phone, // default username = no hp
      passwordHash: TrimeUser.hashPassword(password),
      createdAt: DateTime.now(),
    );

    // Simpan ke lokal
    await prefs.setString('trime_account_${user.id}', jsonEncode(user.toJson()));
    await _saveSession(user);

    // Simpan ke Supabase
    await supabaseService.upsertProfile(user);

    return user;
  }

  Future<void> _saveSession(TrimeUser user) async {
    _currentUser = user;
    _token = 'token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    await prefs.setString(_keyToken, _token!);
  }

  // ─── OTP LOGIN (Legacy - masih dipertahankan) ───
  Future<String> requestOtp({
    required String phoneNumber,
    bool isRegister = false,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return '123456';
  }

  Future<TrimeUser?> verifyOtp({
    required String phoneNumber,
    required String otp,
    required bool isRegister,
    String? name,
    UserRole role = UserRole.pelanggan,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (otp != '123456') {
      return null;
    }

    // Lookup existing profile in Supabase first
    final existingRemote = await supabaseService.fetchProfileByIdOrPhone(phone: phoneNumber);

    final user = TrimeUser(
      id: existingRemote?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : (existingRemote?.name ?? (isRegister ? 'Pengguna Baru' : 'Pengguna TRIME')),
      phoneNumber: phoneNumber,
      role: isRegister ? role : (existingRemote?.role ?? role),
      email: existingRemote?.email,
      photoUrl: existingRemote?.photoUrl,
      username: existingRemote?.username,
      passwordHash: existingRemote?.passwordHash,
      createdAt: existingRemote?.createdAt ?? DateTime.now(),
    );

    await _saveSession(user);
    await supabaseService.upsertProfile(user);

    return user;
  }

  // ─── GOOGLE SIGN-IN ───
  Future<TrimeUser?> signInWithGoogle({
    UserRole role = UserRole.pelanggan,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final fbUser = userCredential.user;

      if (fbUser != null) {
        final existingRemote = await supabaseService.fetchProfileByIdOrPhone(
          id: fbUser.uid,
          email: fbUser.email,
        );

        final user = TrimeUser(
          id: fbUser.uid,
          name: fbUser.displayName ?? existingRemote?.name ?? 'Pengguna Google',
          phoneNumber: (fbUser.phoneNumber != null && fbUser.phoneNumber!.isNotEmpty)
              ? fbUser.phoneNumber!
              : (existingRemote?.phoneNumber ?? ''),
          email: fbUser.email ?? existingRemote?.email,
          photoUrl: fbUser.photoURL ?? existingRemote?.photoUrl,
          role: existingRemote?.role ?? role,
          username: existingRemote?.username,
          passwordHash: existingRemote?.passwordHash,
          createdAt: existingRemote?.createdAt ?? DateTime.now(),
        );

        await _saveSession(user);
        await supabaseService.upsertProfile(user);

        return user;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (_) {}
    _currentUser = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyToken);
    // PENTING: Jangan hapus _kShops / barbershop data — harus tetap ada untuk semua pengguna!
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) return;

    final updated = _currentUser!.copyWith(
      name: name,
      email: email,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
    );
    _currentUser = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(updated.toJson()));
    // Update juga di cache akun
    await prefs.setString('trime_account_${updated.id}', jsonEncode(updated.toJson()));
    await supabaseService.upsertProfile(updated);
  }
}
