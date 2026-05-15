// lib/features/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/guest/shop_list_page.dart';

import '../guest/home_page.dart';
import '../guest/favorite_page.dart';
import '../guest/market_list_page.dart';
import 'signin_page.dart'; // ✅ import SignInPage จากไฟล์ที่ถูกต้อง

// ✅ ชื่อ class ต้องเป็น LoginPage ไม่ใช่ SignInPage!
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int currentIndex = 4;

  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      switch (index) {
        case 0:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
          break;
        case 1:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const MarketListPage()));
          break;
        case 2:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const FavoritePage()));
          break;
        // แก้ทุกหน้าที่มี case 3: ใน _navigateToPage
        case 3:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ShopListPage()));
          break;
        case 4:
          // อยู่หน้านี้แล้ว
          break;
      }
    });
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
              // Content
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          // Logo
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Image.asset(
                              'assets/images/market.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                size: 90,
                                color: Color(0xFF7AAA57),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Plan Market',
                            style: GoogleFonts.kanit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          Text(
                            'เลือกประเภทผู้ใช้งาน',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Role Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              children: [
                                // ลูกค้า
                                _buildRoleButton(
                                  label: 'ลูกค้า',
                                  subtitle: 'ค้นหาและเยี่ยมชมตลาด',
                                  icon: Icons.person_rounded,
                                  color: const Color(0xFF8CBC63),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignInPage(role: 'customer'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // ร้านค้า
                                _buildRoleButton(
                                  label: 'ร้านค้า',
                                  subtitle: 'จองแผงและบริหารร้านค้า',
                                  icon: Icons.storefront_rounded,
                                  color: const Color(0xFF6E9B4C),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignInPage(role: 'vendor'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // เจ้าของตลาด
                                _buildRoleButton(
                                  label: 'เจ้าของตลาด',
                                  subtitle: 'จัดการตลาดและแผงค้า',
                                  icon: Icons.store_mall_directory_rounded,
                                  color: const Color(0xFF5A8A3C),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignInPage(role: 'market'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Admin (ไม่ต้องแสดงถ้าไม่ต้องการ)
                                _buildRoleButton(
                                  label: 'ผู้ดูแลระบบ',
                                  subtitle: 'จัดการและดูแลระบบทั้งหมด',
                                  icon: Icons.admin_panel_settings_rounded,
                                  color: const Color(0xFF2D9CDB),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignInPage(role: 'super_admin'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom Nav (ของเดิมที่มีอยู่แล้ว)
            ],
          ),
        ),
        // Bottom Navigation Bar ของเดิม
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    // ใส่ Bottom Nav ของเดิมที่มีอยู่แล้วในไฟล์นี้ครับ
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _navigateToPage,
      selectedItemColor: const Color(0xFF8CBC63),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'หน้าแรก'),
        BottomNavigationBarItem(icon: Icon(Icons.store_rounded), label: 'ตลาด'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded), label: 'ถูกใจ'),
        BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded), label: 'ร้านค้า'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: 'โปรไฟล์'),
      ],
    );
  }
}

class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF73A34F)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.98,
          size.width * 0.52, size.height * 0.56)
      ..quadraticBezierTo(
          size.width * 0.72, size.height * 1.02, size.width, size.height * 0.72)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// test all app
