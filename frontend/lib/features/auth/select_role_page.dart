import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/auth/signin_page.dart';
import 'package:plan_market/features/guest/shop_list_page.dart';

import '../guest/home_page.dart';
import '../guest/favorite_page.dart';
import '../guest/market_list_page.dart';
import 'login_page.dart';

// lll
class SelectRolePage extends StatefulWidget {
  const SelectRolePage({super.key});

  @override
  State<SelectRolePage> createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {
  int currentIndex = 4; // โปรไฟล์ = active

  // ── Navigation ────────────────────────────────────────────
  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      switch (index) {
        case 0: // ถูกใจ
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FavoritePage()),
          );
          break;
        case 1: // ตลาด ✅ แก้จาก MarketListPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MarketListPage()),
          );
          break;
        case 2: // หน้าหลัก ✅ แก้จาก HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
          break;
        case 3: // ร้านค้า (ยังไม่มีหน้าจริง)
        // แก้ทุกหน้าที่มี case 3: ใน _navigateToPage
        case 3:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ShopListPage()));
          break;
        case 4: // โปรไฟล์ = อยู่หน้านี้แล้ว
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
                    child: Text(
                      'เลือกประเภทการใช้งาน',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Logo
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Image.asset(
                              'assets/images/market.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                size: 100,
                                color: Color(0xFF7AAA57),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Header Text
                          Text(
                            'ยินดีต้อนรับ',
                            style: GoogleFonts.kanit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          Text(
                            'กรุณาเลือกประเภทบัญชีที่ต้องการ',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Role Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                // ลูกค้า
                                _RoleButton(
                                  label: 'ลงทะเบียนลูกค้า',
                                  icon: Icons.person_rounded,
                                  description: 'ค้นหาตลาดและร้านค้าใกล้บ้าน',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignInPage(role: 'customer'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ร้านค้า
                                _RoleButton(
                                  label: 'ลงทะเบียนร้านค้า',
                                  icon: Icons.storefront_rounded,
                                  description: 'จองแผงและบริหารร้านค้า',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignInPage(role: 'vendor'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ตลาด
                                _RoleButton(
                                  label: 'ลงทะเบียนตลาด',
                                  icon: Icons.store_mall_directory_rounded,
                                  description: 'จัดการตลาดและแผงค้า',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignInPage(role: 'market'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ข้ามการลงทะเบียน
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                            ),
                            child: Text(
                              'ข้ามไปก่อน →',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 100), // padding ล่าง bottom nav
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Nav
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.favorite_border_rounded, 'label': 'ถูกใจ'},
      {'icon': Icons.storefront_rounded, 'label': 'ตลาด'},
      {'icon': Icons.home_rounded, 'label': 'หน้าหลัก'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'ร้านค้า'},
      {'icon': Icons.account_circle_rounded, 'label': 'โปรไฟล์'},
    ];

    final double itemWidth = MediaQuery.of(context).size.width / items.length;

    return SizedBox(
      height: 90,
      child: Stack(
        children: [
          // Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF8CBC63),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final isSelected = currentIndex == i;
                  return GestureDetector(
                    onTap: () => _navigateToPage(i),
                    child: SizedBox(
                      width: itemWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i]['icon'] as IconData,
                            color: Colors.white.withOpacity(
                              isSelected ? 0.0 : 0.8,
                            ),
                            size: 24,
                          ),
                          Text(
                            items[i]['label'] as String,
                            style: GoogleFonts.kanit(
                              fontSize: 10,
                              color: Colors.white.withOpacity(
                                isSelected ? 0.0 : 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Floating Active Button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: (itemWidth * currentIndex) + (itemWidth / 2) - 31,
            top: 2,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF6E9B4C),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                items[currentIndex]['icon'] as IconData,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// _RoleButton — เพิ่ม icon + description
// ══════════════════════════════════════════════════════════
class _RoleButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF374151),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            // Icon Circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8CBC63).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF8CBC63),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Text
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
                    description,
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),
          ],
        ),
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
