import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3001';
  static final _client = http.Client();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ============================================
  // Auth
  // ============================================
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
      return {
        'success': false,
        'message': body['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'
      };
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Markets
  // ============================================
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
          .get(Uri.parse('$baseUrl/markets/$marketId/stalls'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดแผงไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOwnerMarkets(int ownerId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/markets/owner/$ownerId'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดตลาดไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMarketOwnerBookings(
      int ownerId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/markets/owner/$ownerId/bookings'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดการจองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Bookings
  // ============================================
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
          .get(Uri.parse('$baseUrl/bookings/seller/$sellerId'),
              headers: _headers)
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
          .patch(Uri.parse('$baseUrl/bookings/$bookingId/approve'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {
              'success': false,
              'message': body['message'] ?? 'อนุมัติไม่สำเร็จ'
            };
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> rejectBooking(int bookingId) async {
    try {
      final res = await _client
          .patch(Uri.parse('$baseUrl/bookings/$bookingId/reject'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {'success': false, 'message': body['message'] ?? 'ปฏิเสธไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Users & Sellers (Admin)
  // ============================================
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/users'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลด users ไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> approveUser(int userId) async {
    try {
      final res = await _client
          .patch(Uri.parse('$baseUrl/users/$userId/approve'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {
              'success': false,
              'message': body['message'] ?? 'อนุมัติไม่สำเร็จ'
            };
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> rejectUser(int userId) async {
    try {
      final res = await _client
          .patch(Uri.parse('$baseUrl/bookings/user/$userId/rejected'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {'success': false, 'message': body['message'] ?? 'ปฏิเสธไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSellers() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/users/sellers'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดร้านค้าไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Favorites
  // ============================================
  static Future<Map<String, dynamic>> getFavorites(int userId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/favorites/$userId'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body) as List<dynamic>};
      }
      return {'success': false, 'message': 'โหลดรายการถูกใจไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> addFavorite({
    required int userId,
    required int sellerId,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/favorites'),
            headers: _headers,
            body: jsonEncode({'user_id': userId, 'seller_id': sellerId}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'เพิ่มไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeFavorite({
    required int userId,
    required int sellerId,
  }) async {
    try {
      final res = await _client
          .delete(
            Uri.parse('$baseUrl/favorites/$userId/$sellerId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'ลบไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Rejected Bookings & Recommendations
  // ============================================

  /// ดึง bookings ของ user
  static Future<Map<String, dynamic>> getUserBookings(int userId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/bookings/user/$userId'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] ?? []};
      }
      return {'success': false, 'message': 'โหลดการจองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  /// ดึง bookings ที่ถูกปฏิเสธ (ยังไม่ได้แจ้งเตือน)
  /// (ปรับเส้น Path ไปใช้ตัวสั้นตามโค้ดใหม่ที่คุณเพิ่มมาคือ /bookings/rejected/$userId)
  static Future<Map<String, dynamic>> getRejectedBookings(int userId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/bookings/rejected/$userId'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        // หากฝั่ง Backend ห่อข้อมูลไว้ใน 'data' ให้ใช้ body['data'] แต่ถ้าส่ง List มาตรงๆ ให้ปรับตาม Backend นะครับ
        return {'success': true, 'data': body['data'] ?? body};
      }
      return {'success': false, 'message': 'โหลดการจองที่ถูกปฏิเสธไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  /// ดึงข้อมูลการจองทั้งหมดของ user พร้อมสถานะ
  static Future<Map<String, dynamic>> getUserBookingsWithStatus(
      int userId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/bookings/user/$userId/status'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] ?? body};
      }
      return {'success': false, 'message': 'โหลดสถานะการจองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  /// Mark ว่าแจ้งเตือนแล้ว (ปรับใช้แบบ PATCH ตามที่คุณต้องการและใช้โครงสร้าง _client ส่วนกลาง)
  static Future<Map<String, dynamic>> markBookingNotified(int bookingId) async {
    try {
      final res = await _client
          .patch(Uri.parse('$baseUrl/bookings/$bookingId/notified'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {
              'success': false,
              'message': body['message'] ?? 'อัปเดตสถานะแจ้งเตือนไม่สำเร็จ'
            };
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  /// ดึงตลาดแนะนำ (ยกเว้นตลาดที่ถูกปฏิเสธ)
  static Future<Map<String, dynamic>> getRecommendedMarkets(
      int excludeMarketId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/bookings/recommended/$excludeMarketId'),
              headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] ?? []};
      }
      return {'success': false, 'message': 'โหลดตลาดแนะนำไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  /// ดึงล็อคแนะนำตาม preferences
  static Future<Map<String, dynamic>> getRecommendedStalls({
    required int userId,
    required String originalMarketId,
    List<String>? preferences,
    double? maxDistance,
    double? maxPrice,
  }) async {
    try {
      final queryParams = {
        'userId': userId.toString(),
        'originalMarketId': originalMarketId,
        if (preferences != null) 'preferences': preferences.join(','),
        if (maxDistance != null) 'maxDistance': maxDistance.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      };

      final uri = Uri.parse('$baseUrl/recommendations/stalls')
          .replace(queryParameters: queryParams);

      final res = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return {'success': true, 'data': body['data'] ?? body};
      }
      return {'success': false, 'message': 'โหลดแผงแนะนำไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }
} // สิ้นสุดคลาส ApiService อย่างถูกต้อง
