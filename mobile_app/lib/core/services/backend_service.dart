import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_state.dart';

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  bool _isInitialized = false;
  String _baseUrl = '';
  String _apiSecret = '';
  bool _enabled = true;

  Future<void> init({
    String? baseUrl,
    String? apiSecret,
    bool? enabled,
  }) async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}

    _baseUrl = baseUrl ??
        (dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:8001').replaceAll('localhost', '10.0.2.2');
    _apiSecret = apiSecret ?? dotenv.env['API_SECRET'] ?? 'trime_dev_secret';
    _enabled = enabled ??
        (dotenv.env['ENABLE_WA_NOTIF'] ?? 'true').toString().toLowerCase() != 'false';

    if (_baseUrl.endsWith('/')) {
      _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
    }

    _isInitialized = true;
    debugPrint('BackendService initialized | base: $_baseUrl | enabled: $_enabled');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': _apiSecret,
      };

  Future<bool> notifyBookingCreated({
    required BookingItem booking,
    required String customerPhone,
    String? barbershopName,
    String? ownerPhone,
  }) async {
    if (!_enabled || !_isInitialized) return false;

    try {
      final url = Uri.parse('$_baseUrl/booking/created');
      final payload = {
        'booking_id': booking.id,
        'customer_name': booking.customerName,
        'customer_phone': customerPhone,
        'barbershop_name': barbershopName ?? booking.barbershopId,
        'kapster_name': booking.kapsterName,
        'service_name': booking.serviceName,
        'booking_date': booking.date.toUtc().toIso8601String(),
        'price': booking.price,
        if (booking.notes != null && booking.notes!.isNotEmpty) 'notes': booking.notes,
        if (ownerPhone != null && ownerPhone.isNotEmpty) 'owner_phone': ownerPhone,
      };
      final resp = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
      debugPrint('notifyBookingCreated status=${resp.statusCode} body=${resp.body}');
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e) {
      debugPrint('notifyBookingCreated error: $e');
      return false;
    }
  }

  Future<bool> notifyBookingStatusChanged({
    required String bookingId,
    required String customerName,
    required String customerPhone,
    required String oldStatus,
    required String newStatus,
    required String barbershopName,
  }) async {
    if (!_enabled || !_isInitialized) return false;

    try {
      final url = Uri.parse('$_baseUrl/booking/status-changed');
      final payload = {
        'booking_id': bookingId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'old_status': oldStatus,
        'new_status': newStatus,
        'barbershop_name': barbershopName,
      };
      final resp = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
      debugPrint('notifyBookingStatusChanged status=${resp.statusCode}');
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e) {
      debugPrint('notifyBookingStatusChanged error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final url = Uri.parse('$_baseUrl/health');
      final resp = await http.get(url).timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'code': resp.statusCode};
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }
}

final BackendService backendService = BackendService();
