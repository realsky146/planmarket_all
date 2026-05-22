import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class VendorService {
  static Future<int?> _getSellerId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    return id != null ? int.tryParse(id) : null;
  }

  Future<List<Map<String, dynamic>>> getMyBookings() async {
    final sellerId = await _getSellerId();
    if (sellerId == null) return [];

    final result = await ApiService.getVendorBookings(sellerId);
    if (!result['success']) return [];

    final raw = result['data'] as List<dynamic>;
    return raw.map((e) => _mapBooking(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> bookStall({
    required int stallId,
    required String shopName,
  }) async {
    final sellerId = await _getSellerId();
    if (sellerId == null) {
      return {'success': false, 'message': 'กรุณาเข้าสู่ระบบก่อน'};
    }

    return ApiService.createBooking(
      stallId: stallId,
      sellerId: sellerId,
      shopName: shopName,
    );
  }

  Future<List<Map<String, dynamic>>> getMarkets() async {
    final result = await ApiService.getMarkets();
    if (!result['success']) return [];
    final raw = result['data'] as List<dynamic>;
    return raw.map((e) => _mapMarket(e as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> getMarketStalls(int marketId) async {
    final result = await ApiService.getMarketStalls(marketId);
    if (!result['success']) return [];
    final raw = result['data'] as List<dynamic>;
    return raw.map((e) => e as Map<String, dynamic>).toList();
  }

  Map<String, dynamic> _mapBooking(Map<String, dynamic> raw) {
    return {
      'id': raw['id'].toString(),
      'shopName': raw['shop_name'] ?? '',
      'status': raw['status'] ?? 'pending',
      'stallNumber': raw['stall_number'] ?? '',
      'marketName': raw['market_name'] ?? '',
      'marketId': raw['market_id']?.toString() ?? '',
      'createdAt': raw['created_at'] ?? '',
    };
  }

  Map<String, dynamic> _mapMarket(Map<String, dynamic> raw) {
    return {
      'id': raw['id'].toString(),
      'name': raw['name'] ?? '',
      'description': raw['description'] ?? '',
      'ownerId': raw['owner_id']?.toString() ?? '',
      'imageUrl': raw['image_url'],
      'status': 'approved',
      'isOpen': true,
      'rating': 4.0,
      'totalStalls': 0,
      'availableStalls': 0,
    };
  }
}