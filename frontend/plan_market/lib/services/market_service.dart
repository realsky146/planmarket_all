import 'mock_data.dart';

class MarketService {
  // ── ตลาดที่ approved (Guest/Vendor ใช้) ────────────────────
  Future<List<Map<String, dynamic>>> getMarkets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.markets.where((m) => m['status'] == 'approved').toList();
  }

  // ── คำขอรออนุมัติ (Admin) ──────────────────────────────────
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.markets.where((m) => m['status'] == 'pending').toList();
  }

  // ── ตลาดทั้งหมด (Admin) ────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllMarkets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(MockData.markets);
  }

  // ── ดึงตลาดตาม ID ─────────────────────────────────────────
  Future<Map<String, dynamic>?> getMarketById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return MockData.markets.firstWhere((m) => m['id'] == id);
    } catch (_) {
      return null;
    }
  }

  // ── อนุมัติตลาด ────────────────────────────────────────────
  Future<Map<String, dynamic>> approveMarket(String marketId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final index = MockData.markets.indexWhere((m) => m['id'] == marketId);
      if (index == -1) {
        return {'success': false, 'message': 'ไม่พบตลาด'};
      }

      MockData.markets[index] = {
        ...MockData.markets[index],
        'status': 'approved',
      };

      // ✅ อัพเดต owner status ด้วย
      final ownerId = MockData.markets[index]['ownerId'];
      final userIndex = MockData.users.indexWhere((u) => u['id'] == ownerId);
      if (userIndex != -1) {
        MockData.users[userIndex] = {
          ...MockData.users[userIndex],
          'status': 'approved',
        };
      }

      return {'success': true, 'message': 'อนุมัติตลาดสำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  // ── ปฏิเสธตลาด ─────────────────────────────────────────────
  Future<Map<String, dynamic>> rejectMarket(
    String marketId, {
    String reason = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final index = MockData.markets.indexWhere((m) => m['id'] == marketId);
      if (index == -1) {
        return {'success': false, 'message': 'ไม่พบตลาด'};
      }

      MockData.markets[index] = {
        ...MockData.markets[index],
        'status': 'rejected',
        'rejectReason': reason,
      };

      final ownerId = MockData.markets[index]['ownerId'];
      final userIndex = MockData.users.indexWhere((u) => u['id'] == ownerId);
      if (userIndex != -1) {
        MockData.users[userIndex] = {
          ...MockData.users[userIndex],
          'status': 'rejected',
        };
      }

      return {'success': true, 'message': 'ปฏิเสธตลาดสำเร็จ'};
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  // ── ดึงการจอง Vendor ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getVendorBookings(String vendorId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.bookings.where((b) => b['vendorId'] == vendorId).toList();
  }

  // ⬇️ ยังขาด! เพิ่มให้ครบ ─────────────────────────────────

  // ✅ ดึงตลาดของ Owner คนนั้น
  Future<List<Map<String, dynamic>>> getMarketsByOwner(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.markets.where((m) => m['ownerId'] == ownerId).toList();
  }

  // ✅ ดึงการจองของตลาดนั้น (Market Owner ใช้)
  Future<List<Map<String, dynamic>>> getBookingsByMarket(
      String marketId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.bookings.where((b) => b['marketId'] == marketId).toList();
  }

  // ✅ อนุมัติ/ปฏิเสธ การจอง (Market Owner ใช้)
  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = MockData.bookings.indexWhere((b) => b['id'] == bookingId);
    if (index == -1) {
      return {'success': false, 'message': 'ไม่พบการจอง'};
    }
    MockData.bookings[index] = {
      ...MockData.bookings[index],
      'status': status,
    };
    return {'success': true, 'message': 'อัพเดตสถานะสำเร็จ'};
  }
}
