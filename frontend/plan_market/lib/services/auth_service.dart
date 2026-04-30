import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // ══════════════════════════════════════════════════════════
  // signIn
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    // Super Admin — hardcode
    if (email == 'admin@planmarket.com') {
      if (password == 'admin1234') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'super_admin');
        await prefs.setString('status', 'active');
        await prefs.setString('email', email);
        await prefs.setString('userId', '0');
        await prefs.setString('userName', 'Super Admin');
        return {
          'success': true,
          'role': 'super_admin',
          'status': 'active',
          'user': {'id': 0, 'name': 'Super Admin', 'email': email, 'role': 'super_admin'},
        };
      }
      return {'success': false, 'message': 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'};
    }

    final result = await ApiService.login(email: email, password: password);
    if (!result['success']) return result;

    final user = result['user'] as Map<String, dynamic>;
    final dbRole = user['role'] as String;
    final flutterRole = _dbRoleToFlutter(dbRole);

    if (role != 'super_admin' && role != 'customer') {
      final expectedDb = _flutterRoleToDb(role);
      if (dbRole != expectedDb) {
        return {'success': false, 'message': 'บัญชีนี้ไม่ใช่ประเภท "${_roleLabel(role)}"'};
      }
    }

    final status = (user['status'] as String?) ?? 'approved';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', flutterRole);
    await prefs.setString('status', status);
    await prefs.setString('email', email);
    await prefs.setString('userId', user['id'].toString());
    await prefs.setString('userName', (user['name'] as String?) ?? '');

    return {
      'success': true,
      'role': flutterRole,
      'status': status,
      'user': {...user, 'role': flutterRole},
    };
  }

  // ══════════════════════════════════════════════════════════
  // signUp — vendor
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    if (role == 'customer') {
      return {
        'success': false,
        'message': 'ระบบยังไม่รองรับการสมัครลูกค้า กรุณาใช้งานในฐานะ Guest',
      };
    }

    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
      role: _flutterRoleToDb(role),
    );
    if (!result['success']) return result;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    await prefs.setString('status', 'active');
    await prefs.setString('email', email);
    await prefs.setString('userId', result['userId'].toString());
    await prefs.setString('userName', name);

    return {'success': true, 'role': role, 'userId': result['userId'].toString()};
  }

  // ══════════════════════════════════════════════════════════
  // signUpMarket — เจ้าของตลาด
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
    final result = await ApiService.register(
      name: ownerName,
      email: email,
      password: password,
      role: 'market',
    );
    if (!result['success']) return result;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', 'market_owner');
    await prefs.setString('status', 'pending');
    await prefs.setString('email', email);
    await prefs.setString('userId', result['userId'].toString());
    await prefs.setString('userName', ownerName);

    return {'success': true, 'role': 'market_owner', 'status': 'pending'};
  }

  // ══════════════════════════════════════════════════════════
  // logout
  // ══════════════════════════════════════════════════════════
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ══════════════════════════════════════════════════════════
  // getCurrentUser
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return null;
    return {
      'id': userId,
      'email': prefs.getString('email') ?? '',
      'name': prefs.getString('userName') ?? '',
      'role': prefs.getString('role') ?? '',
      'status': prefs.getString('status') ?? 'active',
    };
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  static String _flutterRoleToDb(String r) {
    if (r == 'vendor') return 'seller';
    if (r == 'market_owner' || r == 'market') return 'market';
    return r;
  }

  static String _dbRoleToFlutter(String r) {
    if (r == 'seller') return 'vendor';
    if (r == 'market') return 'market_owner';
    return r;
  }

  static String _roleLabel(String r) {
    if (r == 'vendor') return 'ร้านค้า';
    if (r == 'market_owner' || r == 'market') return 'เจ้าของตลาด';
    return r;
  }
}