import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../market_owner/market_pending_page.dart';
import '../guest/home_page.dart';
import '../guest/favorite_page.dart';
import '../guest/market_list_page.dart';

class SignUpMarketPage extends StatefulWidget {
  const SignUpMarketPage({super.key});

  @override
  State<SignUpMarketPage> createState() => _SignUpMarketPageState();
}

class _SignUpMarketPageState extends State<SignUpMarketPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _marketNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _errorMsg; // ✅ ประกาศถูกต้อง

  @override
  void dispose() {
    _marketNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMsg = null; // ✅ แก้: ลบช่องว่างออก
    });

    try {
      final result = await AuthService().signUpMarket(
        marketName: _marketNameCtrl.text.trim(),
        ownerName: _ownerNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );

      if (mounted) {
        setState(() => _loading = false);

        // ✅ แก้: เช็ค == true ป้องกัน null
        if (result['success'] == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MarketPendingPage()),
            (route) => false,
          );
        } else {
          setState(() =>
              _errorMsg = result['message'] ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMsg = 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
        });
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 0, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'ลงทะเบียนตลาด',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // ── ข้อมูลตลาด ──────────────────
                            _sectionTitle('🏪 ข้อมูลตลาด'),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: _marketNameCtrl,
                              label: 'ชื่อตลาด',
                              icon: Icons.store_mall_directory_rounded,
                              validator: (v) =>
                                  v!.isEmpty ? 'กรุณากรอกชื่อตลาด' : null,
                            ),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: _locationCtrl,
                              label: 'ที่ตั้ง / ย่าน',
                              icon: Icons.location_on_outlined,
                              validator: (v) =>
                                  v!.isEmpty ? 'กรุณากรอกที่ตั้ง' : null,
                            ),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: _descCtrl,
                              label: 'รายละเอียดตลาด',
                              icon: Icons.description_outlined,
                              maxLines: 3,
                              validator: (v) =>
                                  v!.isEmpty ? 'กรุณากรอกรายละเอียด' : null,
                            ),
                            const SizedBox(height: 20),

                            // ── ข้อมูลเจ้าของ ───────────────
                            _sectionTitle('👤 ข้อมูลเจ้าของตลาด'),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: _ownerNameCtrl,
                              label: 'ชื่อ-นามสกุล',
                              icon: Icons.person_outline_rounded,
                              validator: (v) =>
                                  v!.isEmpty ? 'กรุณากรอกชื่อ-นามสกุล' : null,
                            ),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: _phoneCtrl,
                              label: 'เบอร์โทรศัพท์',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v!.length < 10
                                  ? 'กรุณากรอกเบอร์โทรให้ครบ'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // ── ข้อมูลบัญชี ─────────────────
                            _sectionTitle('🔑 ข้อมูลบัญชี'),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: _emailCtrl,
                              label: 'อีเมล',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => !v!.contains('@')
                                  ? 'รูปแบบอีเมลไม่ถูกต้อง'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            _buildField(
                              controller: _passCtrl,
                              label: 'รหัสผ่าน (อย่างน้อย 6 ตัว)',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscure,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFFBDBDBD),
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) => v!.length < 6
                                  ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // ── หมายเหตุ ────────────────────
                            _buildNoteBox(),

                            // ── Error ────────────────────────
                            if (_errorMsg != null) ...[
                              const SizedBox(height: 12),
                              _buildErrorBox(),
                            ],

                            const SizedBox(height: 24),

                            // ── ปุ่ม ─────────────────────────
                            _buildButtons(),
                            const SizedBox(height: 100),
                          ],
                        ),
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
                child: _buildBottomNav(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Widget Builders
  // ══════════════════════════════════════════════════════════

  Widget _sectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.kanit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF8CBC63),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.kanit(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.kanit(
          fontSize: 13,
          color: Colors.grey,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF8CBC63), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF8CBC63),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB000).withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB45309),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'หลังสมัครแล้ว ระบบจะส่งข้อมูลให้ผู้ดูแลระบบตรวจสอบ\nกรุณารอการอนุมัติก่อนเข้าใช้งาน',
              style: GoogleFonts.kanit(
                fontSize: 12,
                color: const Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMsg!,
              style: GoogleFonts.kanit(
                color: const Color(0xFFB91C1C),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        // ยกเลิก
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.kanit(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ส่งคำขอ
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'ส่งคำขอ',
                      style: GoogleFonts.kanit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      {'icon': Icons.favorite_border_rounded, 'label': 'ถูกใจ'},
      {'icon': Icons.storefront_rounded, 'label': 'ตลาด'},
      {'icon': Icons.home_rounded, 'label': 'หน้าหลัก'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'ร้านค้า'},
      {'icon': Icons.account_circle_rounded, 'label': 'โปรไฟล์'},
    ];

    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF8CBC63),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  ...List.generate(items.length, (i) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          switch (i) {
                            case 0:
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FavoritePage(),
                                ),
                              );
                              break;
                            case 1:
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MarketListPage(),
                                ),
                              );
                              break;
                            case 2:
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                              );
                              break;
                            // case 3, 4 → ยังไม่มีหน้า
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[i]['icon'] as IconData,
                              color: Colors.white.withOpacity(0.85),
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              items[i]['label'] as String,
                              style: GoogleFonts.kanit(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 64),
                ],
              ),
            ),
          ),

          // Profile Button
          Positioned(
            right: 12,
            bottom: 6,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF6E9B4C),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
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
    // ✅ แก้: size.width _0.18 → size.width * 0.18
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
