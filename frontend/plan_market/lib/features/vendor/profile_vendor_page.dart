import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/select_role_page.dart';
import 'vendor_home.dart';
import 'vendor_market_list_page.dart';
import 'favorite_vendor_page.dart';
import 'vendor_shop_info_page.dart';
import 'vendor_edit_profile_page.dart';

// ══════════════════════════════════════════════════════════
// 🔌 API Service
// ══════════════════════════════════════════════════════════
class VendorProfileApiService {
  static const String baseUrl = 'https://api.planmarket.com/v1';

  // 🔌 TODO: GET $baseUrl/vendor/profile
  static Future<Map<String, dynamic>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'success': true,
      'data': {
        'name': 'นางสาวมาลี ขายดี',
        'email': 'vendor@test.com',
        'phone': '082-345-6789',
        'image':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        'memberSince': 'กุมภาพันธ์ 2567',
        'shopName': 'ร้านมาลีผัดไทย',
        'shopCategory': 'อาหาร',
      },
    };
  }

  // 🔌 TODO: PUT $baseUrl/vendor/profile
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}

// ══════════════════════════════════════════════════════════
// VendorProfilePage
// ══════════════════════════════════════════════════════════
class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  int currentIndex = 4;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  Map<String, dynamic> _profile = {};

  // Controllers สำหรับแก้ไข
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final result = await VendorProfileApiService.getProfile();
      if (mounted && result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _profile = data;
          _nameCtrl.text = data['name'] ?? '';
          _phoneCtrl.text = data['phone'] ?? '';
        });
      }
    } catch (e) {
      _showSnackbar('โหลดข้อมูลไม่สำเร็จ', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnackbar('กรุณากรอกชื่อบัญชี', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final ok = await VendorProfileApiService.updateProfile({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      if (!mounted) return;
      if (ok) {
        setState(() {
          _profile['name'] = _nameCtrl.text.trim();
          _profile['phone'] = _phoneCtrl.text.trim();
          _isEditing = false;
        });
        _showSnackbar('บันทึกข้อมูลสำเร็จ ✅');
      } else {
        _showSnackbar('บันทึกไม่สำเร็จ', isError: true);
      }
    } catch (_) {
      _showSnackbar('เกิดข้อผิดพลาด', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _cancelEdit() {
    setState(() {
      _nameCtrl.text = _profile['name'] ?? '';
      _phoneCtrl.text = _profile['phone'] ?? '';
      _isEditing = false;
    });
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.kanit()),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF8CBC63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // Logout
  // ══════════════════════════════════════════════════════
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ออกจากระบบ', style: GoogleFonts.kanit()),
        content: Text('ต้องการออกจากระบบใช่ไหม?', style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('ยกเลิก', style: GoogleFonts.kanit()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'ออกจากระบบ',
              style: GoogleFonts.kanit(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SelectRolePage()),
          (route) => false,
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════
  // Navigation
  // ══════════════════════════════════════════════════════
  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VendorFavoritePage()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VendorMarketListPage()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VendorHome()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VendorShopInfoPage()),
          );
          break;
        case 4:
          break;
      }
    });
  }

  // ══════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEEEEE),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8CBC63)),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: SafeArea(
          child: Stack(
            children: [
              // Wave background
              SizedBox(
                height: 160,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF8CBC63),
                      onRefresh: _loadProfile,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildProfileHeader(),
                            const SizedBox(height: 24),
                            _buildInfoSection(),
                            const SizedBox(height: 20),
                            _buildShopInfoButton(),
                            const SizedBox(height: 20),
                            _buildLogoutButton(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  // ── Profile Header ────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 16),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profile['image'] != null
                      ? Image.network(
                          _profile['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              // Camera button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CBC63),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'profile',
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Section ──────────────────────────────────────
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header row ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF8CBC63),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ข้อมูลส่วนตัว',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const Spacer(),
                  // ปุ่มแก้ไข / ยกเลิก
                  if (!_isEditing)
                    TextButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Color(0xFF8CBC63),
                      ),
                      label: Text(
                        'แก้ไข',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: const Color(0xFF8CBC63),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _cancelEdit,
                      child: Text(
                        'ยกเลิก',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 16, indent: 16, endIndent: 16),

            // ── ชื่อบัญชี ────────────────────────────
            _buildInfoRow(
              label: 'ชื่อบัญชี',
              value: _profile['name'] ?? '-',
              controller: _nameCtrl,
              isEditable: true,
              hint: 'กรุณากรอกชื่อ-นามสกุล',
            ),

            // ── เบอร์โทรศัพท์ ─────────────────────────
            _buildInfoRow(
              label: 'เบอร์โทรศัพท์',
              value: _profile['phone'] ?? '-',
              controller: _phoneCtrl,
              isEditable: true,
              hint: 'กรุณากรอกเบอร์โทรศัพท์',
              keyboardType: TextInputType.phone,
            ),

            // ── E-mail (แก้ไขไม่ได้) ──────────────────
            _buildInfoRow(
              label: 'E-mail',
              value: _profile['email'] ?? '-',
              controller: null,
              isEditable: false,
              hint: '',
              note: 'อีเมลไม่สามารถเปลี่ยนแปลงได้',
              isLast: true,
            ),

            // ── ปุ่มบันทึก (เมื่ออยู่ใน editing mode) ──
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8CBC63),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'บันทึกข้อมูล',
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required TextEditingController? controller,
    required bool isEditable,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? note,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, isLast ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.kanit(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          // แสดง TextField เมื่อแก้ไข และ field นั้น editable
          if (_isEditing && isEditable && controller != null)
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.kanit(color: Colors.grey, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color(0xFF8CBC63).withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF8CBC63),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FFF5),
              ),
            )
          else
            // แสดงข้อความปกติ
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      color: isEditable ? const Color(0xFF1F2937) : Colors.grey,
                    ),
                  ),
                ),
                if (!isEditable)
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
              ],
            ),
          if (note != null && (!_isEditing || !isEditable))
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                note,
                style: GoogleFonts.kanit(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Divider(height: 1, color: Colors.grey.shade100),
            ),
        ],
      ),
    );
  }

  // ── ปุ่มข้อมูลร้านค้า → VendorEditProfilePage ────────
  Widget _buildShopInfoButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VendorEditProfilePage(),
          ),
        ).then((_) => _loadProfile()),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'แก้ไขข้อมูลร้านค้า',
              style: GoogleFonts.kanit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logout Button ─────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _logout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'ออกจากระบบ',
              style: GoogleFonts.kanit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.favorite_border_rounded, 'label': 'ถูกใจ'},
      {'icon': Icons.storefront_rounded, 'label': 'ตลาด'},
      {'icon': Icons.home_rounded, 'label': 'หน้าแรก'},
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
                          const SizedBox(height: 10),
                          Icon(
                            items[i]['icon'] as IconData,
                            color: Colors.white.withOpacity(
                              isSelected ? 0.0 : 0.8,
                            ),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: (itemWidth * currentIndex) + (itemWidth / 2) - 31,
            top: 2,
            child: Column(
              children: [
                Container(
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
                const SizedBox(height: 4),
                Text(
                  items[currentIndex]['label'] as String,
                  style: GoogleFonts.kanit(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Wave Painter
// ══════════════════════════════════════════════════════════
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
