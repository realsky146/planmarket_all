// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
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
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
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
        return {
          'success': true,
          'data': jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>
        };
      }
      return {'success': false, 'message': 'โหลดตลาดไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMarketStalls(int marketId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/markets/$marketId/stalls'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>
        };
      }
      return {'success': false, 'message': 'โหลดแผงไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOwnerMarkets(int ownerId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/markets/owner/$ownerId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>
        };
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
          .get(
            Uri.parse('$baseUrl/markets/owner/$ownerId/bookings'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>
        };
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
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (res.statusCode == 201) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'จองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getVendorBookings(int sellerId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/bookings/user/$sellerId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>
        };
      }
      return {'success': false, 'message': 'โหลดการจองไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserBookings(int userId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/bookings/user/$userId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = List<dynamic>.from(decoded['data']);
        }
        debugPrint('✅ getUserBookings: found ${data.length} bookings');
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'โหลดการจองไม่สำเร็จ', 'data': []};
    } catch (e) {
      debugPrint('❌ Error getUserBookings: $e');
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e',
        'data': []
      };
    }
  }

  static Future<Map<String, dynamic>> getRejectedBookings(int userId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/bookings/user/$userId/rejected'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = List<dynamic>.from(decoded['data']);
        }
        debugPrint('✅ getRejectedBookings: found ${data.length} rejected');
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': 'โหลดการจองที่ถูกปฏิเสธไม่สำเร็จ',
        'data': []
      };
    } catch (e) {
      debugPrint('❌ Error getRejectedBookings: $e');
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e',
        'data': []
      };
    }
  }

  static Future<Map<String, dynamic>> markBookingNotified(int bookingId) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/bookings/$bookingId/notified'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {
              'success': false,
              'message': body['message'] ?? 'อัปเดตสถานะแจ้งเตือนไม่สำเร็จ'
            };
    } catch (e) {
      debugPrint('❌ Error markBookingNotified: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> approveBooking(int bookingId) async {
    try {
      final res = await _client
          .patch(
            Uri.parse('$baseUrl/bookings/$bookingId/approve'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
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
          .patch(
            Uri.parse('$baseUrl/bookings/$bookingId/reject'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return res.statusCode == 200
          ? {'success': true, ...body}
          : {'success': false, 'message': body['message'] ?? 'ปฏิเสธไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Users
  // ============================================

  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/users'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = List<dynamic>.from(decoded['data']);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'โหลด users ไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> approveUser(int userId) async {
    try {
      final res = await _client
          .put(
            Uri.parse('$baseUrl/users/$userId'),
            headers: _headers,
            body: jsonEncode({'status': 'approved'}),
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
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
          .put(
            Uri.parse('$baseUrl/users/$userId'),
            headers: _headers,
            body: jsonEncode({'status': 'rejected'}),
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
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
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = List<dynamic>.from(decoded['data']);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'โหลดร้านค้าไม่สำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Shop Favorites (ถูกใจร้านค้า)
  // ============================================

  static Future<Map<String, dynamic>> getFavorites(int userId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/favorites/$userId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = List<dynamic>.from(decoded['data']);
        }
        debugPrint('✅ getFavorites: found ${data.length} favorites');
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': 'โหลดรายการถูกใจไม่สำเร็จ',
        'data': []
      };
    } catch (e) {
      debugPrint('❌ Error getFavorites: $e');
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e',
        'data': []
      };
    }
  }

  static Future<Map<String, dynamic>> addFavorite({
    required int userId,
    required int marketId,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/favorites/$userId'),
            headers: _headers,
            body: jsonEncode({'seller_id': marketId}),
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      debugPrint('✅ addFavorite response: $body');
      if (res.statusCode == 201) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'เพิ่มไม่สำเร็จ'};
    } catch (e) {
      debugPrint('❌ Error addFavorite: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeFavorite(
      int userId, int marketId) async {
    try {
      final res = await _client
          .delete(
            Uri.parse('$baseUrl/favorites/$userId/$marketId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      debugPrint('✅ removeFavorite response: $body');
      if (res.statusCode == 200) return {'success': true, ...body};
      return {'success': false, 'message': body['message'] ?? 'ลบไม่สำเร็จ'};
    } catch (e) {
      debugPrint('❌ Error removeFavorite: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // ✅ Market Favorites (ถูกใจตลาด) — NEW
  // ============================================

  /// ดึงรายการตลาดที่ถูกใจของ vendor
  static Future<Map<String, dynamic>> getMarketFavorites(int userId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/market-favorites?userId=$userId'),
            headers: _headers, // ✅ ใช้ getter ปกติ ไม่ต้อง await
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = List<dynamic>.from(decoded['data']);
        }
        debugPrint('✅ getMarketFavorites: found ${data.length} items');
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': 'โหลดตลาดที่ถูกใจไม่สำเร็จ',
        'data': []
      };
    } catch (e) {
      debugPrint('❌ getMarketFavorites error: $e');
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e',
        'data': []
      };
    }
  }

  /// เพิ่มตลาดในรายการถูกใจ
  static Future<Map<String, dynamic>> addMarketFavorite(
      int userId, int marketId) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$baseUrl/market-favorites'),
            headers: _headers,
            body: jsonEncode({'userId': userId, 'marketId': marketId}),
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      debugPrint('✅ addMarketFavorite response: $body');
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, ...body};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'เพิ่มตลาดถูกใจไม่สำเร็จ'
      };
    } catch (e) {
      debugPrint('❌ addMarketFavorite error: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  /// นำตลาดออกจากรายการถูกใจ
  static Future<Map<String, dynamic>> removeMarketFavorite(
      int userId, int marketId) async {
    try {
      final res = await _client
          .delete(
            Uri.parse('$baseUrl/market-favorites/$marketId?userId=$userId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      debugPrint('✅ removeMarketFavorite response: $body');
      if (res.statusCode == 200) return {'success': true, ...body};
      return {
        'success': false,
        'message': body['message'] ?? 'นำตลาดออกจากถูกใจไม่สำเร็จ'
      };
    } catch (e) {
      debugPrint('❌ removeMarketFavorite error: $e');
      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e'};
    }
  }

  // ============================================
  // Recommendations
  // ============================================

  static Future<Map<String, dynamic>> getRecommendedMarkets(
      int excludeMarketId) async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/bookings/recommended/$excludeMarketId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = List<dynamic>.from(decoded['data']);
        }
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': 'โหลดตลาดแนะนำไม่สำเร็จ',
        'data': []
      };
    } catch (e) {
      debugPrint('❌ Error getRecommendedMarkets: $e');
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อ server ได้: $e',
        'data': []
      };
    }
  }
}
