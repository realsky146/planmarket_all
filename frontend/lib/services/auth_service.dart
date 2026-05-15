import 'package:shared_preferences/shared_preferences.dart';
import 'mock_data.dart';

class AuthService {
  // ══════════════════════════════════════════════════════════
  // ✅ signIn — ใช้แค่ email, password, role (ไม่มี name, phone)
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final lookupRole = role == 'market' ? 'market_owner' : role;

      final user = MockData.users.firstWhere(
        (u) =>
            u['email'] == email &&
            u['password'] == password &&
            u['role'] == lookupRole,
        orElse: () => <String, dynamic>{},
      );

      if (user.isEmpty) {
        return {'success': false, 'message': 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'};
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', user['role']);
      await prefs.setString('status', user['status'] ?? 'active');
      await prefs.setString('email', email);
      await prefs.setString('userId', user['id']);

      return {
        'success': true,
        'user': user,
        'role': user['role'],
        'status': user['status'] ?? 'active',
      };
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ signUp — ใช้ name, email, password, phone, role
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // เช็คอีเมลซ้ำ
      final existing = MockData.users.any((u) => u['email'] == email);
      if (existing) {
        return {'success': false, 'message': 'อีเมลนี้ถูกใช้แล้ว'};
      }

      final newId = 'u${DateTime.now().millisecondsSinceEpoch}';

      final newUser = {
        'id': newId,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'status': 'active',
        'phone': phone,
        'createdAt': DateTime.now().toIso8601String(),
      };

      MockData.users.add(newUser);

      return {
        'success': true,
        'role': role,
        'userId': newId,
      };
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ signUpMarket — สมัครเจ้าของตลาด
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> signUpMarket({
    required String marketName,
    required String ownerName,
    required String email,
    required String password,
    required String phone,
    required String location,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final existing = MockData.users.any((u) => u['email'] == email);
      if (existing) {
        return {'success': false, 'message': 'อีเมลนี้ถูกใช้แล้ว'};
      }

      final newUserId = 'u${DateTime.now().millisecondsSinceEpoch}';
      final newMarketId = 'm${DateTime.now().millisecondsSinceEpoch}';

      MockData.users.add({
        'id': newUserId,
        'name': ownerName,
        'email': email,
        'password': password,
        'role': 'market_owner',
        'status': 'pending',
        'phone': phone,
        'marketName': marketName,
        'createdAt': DateTime.now().toIso8601String(),
      });

      MockData.markets.add({
        'id': newMarketId,
        'name': marketName,
        'ownerId': newUserId,
        'status': 'pending',
        'location': location,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'market_owner');
      await prefs.setString('status', 'pending');
      await prefs.setString('email', email);
      await prefs.setString('userId', newUserId);

      return {'success': true, 'role': 'market_owner', 'status': 'pending'};
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ logout
  // ══════════════════════════════════════════════════════════
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ══════════════════════════════════════════════════════════
  // ✅ getCurrentUser
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return null;

    try {
      return MockData.users.firstWhere((u) => u['email'] == email);
    } catch (_) {
      return null;
    }
  }
}
