import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Import หน้าจออื่นๆ ของคุณตามปกติ
import 'features/guest/home_page.dart';
import 'features/guest/profile_page.dart';
import 'features/vendor/vendor_home.dart';
import 'features/market_owner/market_owner_home.dart';
import 'features/market_owner/market_pending_page.dart';
import 'features/super_admin/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlanMarketApp());
}

class PlanMarketApp extends StatelessWidget {
  const PlanMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8CBC63),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
      locale: const Locale('th', 'TH'),
      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final status = prefs.getString('status') ?? 'active';

    // 🟢 ดึงเหตุผลการปฏิเสธที่ถูกบันทึกไว้ตอนกระบวนการล็อกอินสำเร็จ (Login)
    final rejectReason = prefs.getString('reject_reason') ?? '';

    if (!mounted) return;

    if (role == null) {
      _go(const HomePage());
      return;
    }

    switch (role) {
      case 'super_admin':
        _go(const AdminHome());
        break;
      case 'market_owner':
        if (status == 'approved') {
          _go(const MarketOwnerHome());
        } else if (status == 'pending') {
          _go(const MarketPendingPage());
        } else if (status == 'rejected') {
          // 🟢 บัญชีร้านค้าจริงที่โดนปฏิเสธ จะถูกส่งตัวมาที่หน้าจอนี้พร้อมส่งเหตุผลแนบไปด้วย
          _go(MarketRejectedPage(reason: rejectReason));
        } else {
          await prefs.clear();
          if (!mounted) return;
          _go(const HomePage());
        }
        break;
      case 'vendor':
        _go(VendorHome());
        break;
      case 'customer':
        _go(const HomePage());
        break;
      default:
        _go(const HomePage());
    }
  }

  void _go(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8CBC63),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Plan Market',
              style: GoogleFonts.kanit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ตลาดนัดออนไลน์',
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
            const SizedBox(height: 40),

            // 🧪 ปุ่มทางเข้าหน้าเทส API (ยังคงเปิดเก็บไว้ให้คุณกดเข้าไปจำลองสเตตัสหลังบ้านได้ง่ายๆ)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatusTestScreen()),
                );
              },
              icon: const Icon(Icons.science),
              label: const Text('🧪 เข้าหน้าทดสอบ Approve/Reject API',
                  style: TextStyle(fontFamily: 'Kanit')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8CBC63),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 🧪 คลาสหน้าจอทดสอบยิงตรงหา Backend (สำหรับผู้พัฒนาระบบใช้ทดสอบส่งสถานะ)
// =========================================================================
class StatusTestScreen extends StatefulWidget {
  const StatusTestScreen({super.key});

  @override
  State<StatusTestScreen> createState() => _StatusTestScreenState();
}

class _StatusTestScreenState extends State<StatusTestScreen> {
  final String baseUrl = 'http://localhost:3000';
  final int testBookingId = 1;
  bool _isLoading = false;

  Future<void> approveBooking(int id) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('$baseUrl/bookings/$id/approve');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        _showSnackBar('✅ อนุมัติการจองแผงสำเร็จ!', Colors.green);
      } else {
        _showSnackBar('❌ เกิดข้อผิดพลาด: ${result['message']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('❌ ไม่สามารถติดต่อหลังบ้านได้: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> rejectBooking(int id, String reasonText) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('$baseUrl/bookings/$id/reject');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reason': reasonText,
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success'] == true) {
        _showSnackBar(
            '🔴 ปฏิเสธการจองและบันทึกเหตุผลเรียบร้อย!', Colors.orange);
      } else {
        _showSnackBar('❌ เกิดข้อผิดพลาด: ${result['message']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('❌ ไม่สามารถติดต่อหลังบ้านได้: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Kanit')),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test API Booking Status',
            style: TextStyle(fontFamily: 'Kanit')),
        backgroundColor: const Color(0xFF8CBC63),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8CBC63)))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ทดสอบจองแผงค้า ID: $testBookingId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => approveBooking(testBookingId),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('กด Approve (อนุมัติ)',
                        style: TextStyle(fontFamily: 'Kanit')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      rejectBooking(testBookingId,
                          'แผงค้านี้ปิดปรับปรุงระบบไฟฟ้าชั่วคราว');
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('กด Reject (ปฏิเสธการจอง)',
                        style: TextStyle(fontFamily: 'Kanit')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// =========================================================================
// 🔴 หน้าจอจริงสำหรับร้านค้า (Market Owner) ที่สถานะระบบระบุว่าถูก "ปฏิเสธ" (Rejected)
// =========================================================================
class MarketRejectedPage extends StatelessWidget {
  final String reason;

  const MarketRejectedPage({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cancel_rounded,
              color: Colors.redAccent,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'คำขอเปิดบัญชีร้านค้าถูกปฏิเสธ',
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เหตุผลจากผู้ดูแลระบบ:',
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reason.isNotEmpty
                        ? reason
                        : 'ไม่ได้ระบุเหตุผลเด่นชัด กรุณาติดต่อเจ้าหน้าที่',
                    style:
                        GoogleFonts.kanit(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: ใส่แอ็กชันการติดต่อเจ้าหน้าที่ เช่นเปิดแอปโทรศัพท์หรือลิงก์ไปยัง Support
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('ติดต่อเจ้าหน้าที่ / แก้ไขข้อมูล',
                  style: TextStyle(fontFamily: 'Kanit')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // ล้างเซสชันขยะค้างออกเพื่อให้สลับไอดีได้
                if (!context.mounted) return;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomePage()));
              },
              child: const Text('กลับหน้าหลัก',
                  style: TextStyle(fontFamily: 'Kanit', color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
