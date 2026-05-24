import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/guest/shop_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/select_role_page.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'market_list_page.dart';

class GuestProfilePage extends StatefulWidget {
  const GuestProfilePage({super.key});
  @override
  State<GuestProfilePage> createState() => _GuestProfilePageState();
}

class _GuestProfilePageState extends State<GuestProfilePage> {
  int currentIndex = 4;
  String _userName = '';
  String _userEmail = '';
  final _nameCtrl = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? prefs.getString('name') ?? '-';
      _userEmail = prefs.getString('email') ?? '-';
    });
    _nameCtrl.text = _userName;
  }

  Future<void> _saveName() async {
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    setState(() {
      _userName = newName;
      _isEditingName = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกชื่อเรียบร้อยแล้ว', style: GoogleFonts.kanit()),
          backgroundColor: const Color(0xFF8CBC63),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ออกจากระบบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากระบบใช่ไหม?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก', style: GoogleFonts.kanit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8CBC63),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('ออกจากระบบ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectRolePage()),
        );
      }
    }
  }

  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoritePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MarketListPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ShopListPage()));
        break;
      case 4:
        break;
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
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          // ── Avatar icon (ไม่มีรูป ใช้แค่ไอคอน) ──
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          // ── ชื่อแสดงใต้ icon ──
                          Text(
                            _userName.isEmpty ? '-' : _userName,
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userEmail.isEmpty ? '-' : _userEmail,
                            style: GoogleFonts.kanit(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // ── Form ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── ชื่อบัญชี ──
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ชื่อบัญชี',
                                          style: GoogleFonts.kanit(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF374151))),
                                      GestureDetector(
                                        onTap: () {
                                          if (_isEditingName) {
                                            _saveName();
                                          } else {
                                            setState(() => _isEditingName = true);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _isEditingName
                                                ? const Color(0xFF8CBC63)
                                                : const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _isEditingName ? 'บันทึก' : 'แก้ไข',
                                            style: GoogleFonts.kanit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _isEditingName ? Colors.white : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _isEditingName
                                      ? TextField(
                                          controller: _nameCtrl,
                                          autofocus: true,
                                          style: GoogleFonts.kanit(fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: 'กรอกชื่อบัญชี',
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Color(0xFF8CBC63), width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Color(0xFF8CBC63), width: 2),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                              onPressed: () => setState(() {
                                                _isEditingName = false;
                                                _nameCtrl.text = _userName;
                                              }),
                                            ),
                                          ),
                                        )
                                      : _infoBox(_userName.isEmpty ? '-' : _userName),
                                  const SizedBox(height: 16),
                                  // ── E-mail ──
                                  Text('E-mail',
                                      style: GoogleFonts.kanit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF374151))),
                                  const SizedBox(height: 8),
                                  _infoBox(_userEmail.isEmpty ? '-' : _userEmail),
                                  const SizedBox(height: 8),
                                  Text('อีเมลไม่สามารถเปลี่ยนแปลงได้',
                                      style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // ── ปุ่มออกจากระบบ ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: _logout,
                                child: Text('ออกจากระบบ',
                                    style: GoogleFonts.kanit(
                                        color: Colors.red, fontWeight: FontWeight.w600, fontSize: 15)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: GoogleFonts.kanit(color: const Color(0xFF374151), fontSize: 13)),
    );
  }

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
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0, left: 0, right: 0,
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
                          const SizedBox(height: 10),
                          Icon(items[i]['icon'] as IconData,
                              color: Colors.white.withOpacity(isSelected ? 0.0 : 0.8), size: 24),
                          const SizedBox(height: 4),
                          Text(items[i]['label'] as String,
                              style: GoogleFonts.kanit(
                                  fontSize: 10, color: Colors.white.withOpacity(isSelected ? 0.0 : 0.8))),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: (itemWidth * currentIndex) + (itemWidth / 2) - 31,
            top: 2,
            child: Column(
              children: [
                Container(
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E9B4C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Icon(items[currentIndex]['icon'] as IconData, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 4),
                Text(items[currentIndex]['label'] as String,
                    style: GoogleFonts.kanit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF73A34F)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.78);
    path.quadraticBezierTo(size.width * 0.18, size.height * 0.98, size.width * 0.52, size.height * 0.56);
    path.quadraticBezierTo(size.width * 0.72, size.height * 1.02, size.width, size.height * 0.72);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}