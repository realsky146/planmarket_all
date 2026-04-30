import 'dart:convert';
import 'package:http/http.dart' as http;

/// เปลี่ยน baseUrl ตรงนี้ที่เดียว
/// Android Emulator  → 'http://10.0.2.2:3000'
/// iOS Simulator     → 'http://localhost:3000'
/// มือถือจริง        → 'http://192.168.x.x:3000'
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static final _client = http.Client();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Auth
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? imageUrl,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
              if (imageUrl != null) 'image_url': imageUrl,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'เกิดข้อผิดพลาด'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // Markets
  static Future<Map<String, dynamic>> getMarkets() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/markets'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดตลาดไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMarketStalls(int marketId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/markets/$marketId/stalls'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดแผงไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMarketOwnerBookings(int ownerId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/markets/owner/$ownerId/bookings'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดการจองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // Bookings
  static Future<Map<String, dynamic>> createBooking({
    required int stallId,
    required int sellerId,
    required String shopName,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/bookings'),
            headers: _headers,
            body: jsonEncode({
              'stall_id': stallId,
              'seller_id': sellerId,
              'shop_name': shopName,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'จองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getVendorBookings(int sellerId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/bookings/seller/$sellerId'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดการจองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> approveBooking(int bookingId) async {
    try {
      final res = await _client
          .patch(Uri.parse('$baseUrl/bookings/$bookingId/approve'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {'success': false, 'message': body['message'] ?? 'อนุมัติไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> rejectBooking(int bookingId) async {
    try {
      final res = await _client
          .patch(Uri.parse('$baseUrl/bookings/$bookingId/reject'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {'success': false, 'message': body['message'] ?? 'ปฏิเสธไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }
}