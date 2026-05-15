import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/select_role_page.dart'; // ✅ แก้: ใช้ SelectRolePage แทน LoginPage
import '../guest/home_page.dart';

class MarketPendingPage extends StatelessWidget {
  const MarketPendingPage({super.key});

  // ✅ Logout แล้วไป SelectRolePage
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'ออกจากระบบ',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'ต้องการออกจากระบบใช่ไหม?',
          style: GoogleFonts.kanit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('ยกเลิก', style: GoogleFonts.kanit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('ออกจากระบบ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SelectRolePage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: SafeArea(
          child: Stack(
            children: [
              // Wave Header
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),

              Column(
                children: [
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'สถานะการสมัคร',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // ── ไอคอนสถานะ ─────────────────
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFB000).withOpacity(0.3),
                                width: 4,
                              ),
                            ),
                            child: const Icon(
                              Icons.hourglass_empty_rounded,
                              size: 60,
                              color: Color(0xFFFFB000),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── หัวข้อ ──────────────────────
                          Text(
                            'รอการอนุมัติ',
                            style: GoogleFonts.kanit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'คำขอลงทะเบียนตลาดของคุณ\nถูกส่งไปยังผู้ดูแลระบบแล้ว',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Card ขั้นตอน ────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ขั้นตอนการอนุมัติ',
                                  style: GoogleFonts.kanit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _stepItem(
                                  step: 1,
                                  title: 'ส่งคำขอสมัครแล้ว',
                                  subtitle: 'ระบบได้รับข้อมูลของคุณแล้ว',
                                  isDone: true,
                                  isActive: false,
                                ),
                                _divider(),
                                _stepItem(
                                  step: 2,
                                  title: 'ผู้ดูแลระบบตรวจสอบ',
                                  subtitle:
                                      'กำลังตรวจสอบข้อมูล ใช้เวลา 1-3 วันทำการ',
                                  isDone: false,
                                  isActive: true,
                                ),
                                _divider(),
                                _stepItem(
                                  step: 3,
                                  title: 'ได้รับการอนุมัติ',
                                  subtitle: 'เข้าใช้งานระบบจัดการตลาดได้ทันที',
                                  isDone: false,
                                  isActive: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Card แจ้งเตือน ───────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2D9CDB).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFF2D9CDB),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'เราจะแจ้งผลการอนุมัติผ่านอีเมลที่คุณลงทะเบียนไว้',
                                    style: GoogleFonts.kanit(
                                      fontSize: 13,
                                      color: const Color(0xFF0369A1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── ปุ่ม กลับหน้าหลัก ───────────
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8CBC63),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                              ),
                              icon: const Icon(Icons.home_rounded, size: 18),
                              label: Text(
                                'กลับหน้าหลัก',
                                style: GoogleFonts.kanit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── ปุ่ม ออกจากระบบ ─────────────
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              // ✅ แก้: เรียก _logout() แทน LoginPage(role:'')
                              onPressed: () => _logout(context),
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFF6B7280),
                                size: 18,
                              ),
                              label: Text(
                                'ออกจากระบบ',
                                style: GoogleFonts.kanit(
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step Item ─────────────────────────────────────────────
  Widget _stepItem({
    required int step,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
  }) {
    final Color circleColor;
    final Color textColor;
    final IconData icon;

    if (isDone) {
      circleColor = const Color(0xFF22C55E);
      textColor = const Color(0xFF374151);
      icon = Icons.check_rounded;
    } else if (isActive) {
      circleColor = const Color(0xFFFFB000);
      textColor = const Color(0xFF374151);
      icon = Icons.hourglass_empty_rounded;
    } else {
      circleColor = const Color(0xFFD1D5DB);
      textColor = const Color(0xFF9CA3AF);
      icon = Icons.circle_outlined;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),

          // Step Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.kanit(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Container(
        width: 2,
        height: 16,
        color: const Color(0xFFE5E7EB),
      ),
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────
class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF73A34F)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.78);
    path.quadraticBezierTo(
      size.width * 0.18,
      size.height * 0.98,
      size.width * 0.52,
      size.height * 0.56,
    );
    path.quadraticBezierTo(
      size.width * 0.72,
      size.height * 1.02,
      size.width,
      size.height * 0.72,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
