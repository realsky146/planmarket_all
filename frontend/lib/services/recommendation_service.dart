// lib/services/recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recommendation_models.dart';

class RecommendationService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS/Web

  /// ดึงล็อคแนะนำ
  Future<RecommendationResult> getRecommendations({
    required RejectionReason reason,
    required String originalMarketId,
    required String originalMarketName,
    required String originalStallCode,
    List<StallPreference> preferences = const [],
  }) async {
    try {
      // สร้าง query parameters
      final queryParams = {
        'reason': reason.index.toString(),
        if (preferences.isNotEmpty)
          'preferences': preferences.map((p) => p.index).join(','),
      };

      final uri = Uri.parse('$baseUrl/bookings/recommended/$originalMarketId')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      final data = json.decode(response.body);

      if (data['success'] == true) {
        final List<RecommendedStall> recommendations = [];

        for (var item in data['data'] ?? []) {
          recommendations.add(_mapToRecommendedStall(item, preferences));
        }

        return RecommendationResult(
          success: true,
          reason: reason,
          originalMarketName: originalMarketName,
          originalStallCode: originalStallCode,
          recommendations: recommendations,
        );
      } else {
        throw Exception(data['message'] ?? 'Failed to get recommendations');
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      rethrow;
    }
  }

  /// แปลงข้อมูลจาก API เป็น RecommendedStall
  RecommendedStall _mapToRecommendedStall(
    Map<String, dynamic> item,
    List<StallPreference> preferences,
  ) {
    // คำนวณ matchScore ตาม preferences ที่เลือก
    double matchScore = 70.0; // base score
    List<StallPreference> matchedPrefs = [];

    if (preferences.contains(StallPreference.cheapest)) {
      matchScore += 10;
      matchedPrefs.add(StallPreference.cheapest);
    }
    if (preferences.contains(StallPreference.nearby)) {
      matchScore += 5;
      matchedPrefs.add(StallPreference.nearby);
    }

    return RecommendedStall(
      id: item['id']?.toString() ?? '',
      marketId: item['id']?.toString() ?? '',
      marketName: item['name'] ?? 'ไม่ทราบชื่อ',
      stallCode: 'A${item['id'] ?? 1}', // สมมติ stall code
      zone: item['category'] ?? 'ทั่วไป',
      size: '3x3 ม.',
      price: (item['rental_price'] ?? 500).toDouble(),
      imageUrl: item['image_url'] ?? '',
      distance: 2.5, // สมมติระยะทาง
      trafficScore: item['available_zones'] != null
          ? (item['available_zones'] as int) * 10
          : 50,
      hasEvent: false,
      matchScore: matchScore.clamp(0, 100),
      matchedPreferences: matchedPrefs,
      isFromSameOwner: false,
    );
  }

  /// บันทึกการเลือกล็อค
  Future<bool> saveUserSelection({
    required String stallId,
    required String bookingId,
    required List<StallPreference> preferences,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'market_id': int.tryParse(stallId) ?? 1,
          'user_id': 10, // TODO: ใช้ user จริง
          'zone_id': 1,
          'booking_date':
              DateTime.now().toIso8601String().split('T'), // ✅ แก้ตรงนี้
          'total_price': 500,
          'from_recommendation': true,
          'original_booking_id': bookingId,
        }),
      );

      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Error saving selection: $e');
      return false;
    }
  }

  /// ปฏิเสธคำแนะนำทั้งหมด
  Future<void> declineAllRecommendations({required String bookingId}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/notified'),
      );
    } catch (e) {
      print('Error declining recommendations: $e');
    }
  }
}
