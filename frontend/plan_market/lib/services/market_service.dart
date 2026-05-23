import 'api_service.dart';

class MarketService {
  Future<List<Map<String, dynamic>>> getMarkets() async {
    final result = await ApiService.getMarkets();
    if (!result['success']) return [];
    final raw = result['data'] as List<dynamic>;
    return raw.map((e) => _mapMarket(e as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMarkets() async => getMarkets();

  // TODO: เพิ่ม GET /markets?status=pending ใน backend
  Future<List<Map<String, dynamic>>> getPendingRequests() async => [];

  Future<Map<String, dynamic>?> getMarketById(String id) async {
    final markets = await getMarkets();
    try {
      return markets.firstWhere((m) => m['id'].toString() == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMarketsByOwner(String ownerId) async {
    final all = await getMarkets();
    return all.where((m) => m['ownerId']?.toString() == ownerId).toList();
  }

  Future<List<Map<String, dynamic>>> getMarketStalls(int marketId) async {
    final result = await ApiService.getMarketStalls(marketId);
    if (!result['success']) return [];
    final raw = result['data'] as List<dynamic>;
    return raw.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getMarketOwnerBookings(String ownerId) async {
    final id = int.tryParse(ownerId) ?? 0;
    final result = await ApiService.getMarketOwnerBookings(id);
    if (!result['success']) return [];
    final raw = result['data'] as List<dynamic>;
    return raw.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getVendorBookings(String vendorId) async {
    final id = int.tryParse(vendorId) ?? 0;
    final result = await ApiService.getVendorBookings(id);
    if (!result['success']) return [];
    final raw = result['data'] as List<dynamic>;
    return raw.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final id = int.tryParse(bookingId) ?? 0;
    if (status == 'approved') return ApiService.approveBooking(id);
    if (status == 'rejected') return ApiService.rejectBooking(id);
    return {'success': false, 'message': 'status ไม่ถูกต้อง'};
  }

  Future<Map<String, dynamic>> approveMarket(String userId) async {
    final id = int.tryParse(userId) ?? 0;
    return ApiService.approveUser(id);
  }

  Future<Map<String, dynamic>> rejectMarket(String userId, {String reason = ''}) async {
    final id = int.tryParse(userId) ?? 0;
    return ApiService.rejectUser(id);
  }

  Future<List<Map<String, dynamic>>> getMarketOwnerUsers() async {
    final result = await ApiService.getUsers();
    if (!result['success']) return [];
    final raw = result['data'] as List<dynamic>;
    return raw
        .where((u) => (u as Map<String, dynamic>)['role'] == 'market')
        .map((u) => {
              'id': u['id'].toString(),
              'marketName': u['name'] ?? '-',
              'ownerName': u['name'] ?? '-',
              'email': u['email'] ?? '-',
              'status': u['status'] ?? 'pending',
              'phone': '-',
              'location': '-',
              'submittedAt': '-',
            })
        .toList();
  }

  Map<String, dynamic> _mapMarket(Map<String, dynamic> raw) {
    return {
      'id': raw['id'],
      'name': raw['name'] ?? '',
      'description': raw['description'] ?? '',
      'ownerId': raw['owner_id'],
      'imageUrl': raw['image_url'],
      'status': 'approved',
      'location': raw['location'] ?? '',
      'openTime': raw['open_time'] ?? '08:00',
      'closeTime': raw['close_time'] ?? '20:00',
      'isOpen': true,
      'rating': raw['rating'] ?? 4.0,
      'totalStalls': raw['total_stalls'] ?? 0,
      'availableStalls': raw['available_stalls'] ?? 0,
    };
  }
}