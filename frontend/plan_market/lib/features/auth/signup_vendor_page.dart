import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../vendor/vendor_home.dart';

class SignUpVendorPage extends StatefulWidget {
  const SignUpVendorPage({super.key});

  @override
  State<SignUpVendorPage> createState() => _SignUpVendorPageState();
}

class _SignUpVendorPageState extends State<SignUpVendorPage> {
  // ── Controllers ──────────────────────────────────────────
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  String? _selectedCategory;
  bool _loading = false;
  String? _errorMsg;

  // ── ตัวเลือกประเภทร้านค้า ─────────────────────────────────
  final List<String> _categories = [
    'อาหาร',
    'เครื่องดื่ม',
    'เสื้อผ้า',
    'ของสด',
    'ของใช้',
    'ของตกแต่ง',
    'อื่นๆ',
  ];

  // ── ตัวเลือกความต้องการพิเศษ ─────────────────────────────
  final Map<String, bool> _utilities = {
    'ไฟ': false,
    'น้ำ': false,
  };

  final List<String> _extras = []; // เพิ่มเติมที่ user พิมพ์เอง
  final _extraCtrl = TextEditingController();

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────
  Future<void> _handleSignUp() async {
    // Validate
    if (_shopNameCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'กรุณากรอกชื่อร้านค้า');
      return;
    }
    if (_ownerNameCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'กรุณากรอกชื่อ-นามสกุลเจ้าของร้าน');
      return;
    }
    if (_selectedCategory == null) {
      setState(() => _errorMsg = 'กรุณาเลือกประเภทร้านค้า');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'กรุณากรอกอีเมล');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'กรุณากรอกเบอร์โทรศัพท์');
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final result = await AuthService().signUp(
        name: _ownerNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: '123456', // default — เพิ่มช่อง password ได้ทีหลัง
        phone: _phoneCtrl.text.trim(),
        role: 'vendor',
      );

      if (mounted) {
        setState(() => _loading = false);

        if (result['success'] == true) {
          // บันทึก session
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', 'vendor');
          await prefs.setString('status', 'active');
          await prefs.setString('email', _emailCtrl.text.trim());

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const VendorHome()),
            (route) => false,
          );
        } else {
          setState(() => _errorMsg = result['message'] ?? 'สมัครไม่สำเร็จ');
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
              // ── Wave Header ──────────────────────────────
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title Bar ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Text(
                          'Sign up',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable Content ──────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // ── Avatar ────────────────────
                          _buildAvatar(),
                          const SizedBox(height: 12),

                          // ── Sign up Badge ─────────────
                          _buildSignUpBadge(),
                          const SizedBox(height: 20),

                          // ── Form ──────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Error Message
                                if (_errorMsg != null) _buildErrorBox(),

                                // ชื่อร้านค้า
                                _buildLabel('ชื่อร้านค้า'),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _shopNameCtrl,
                                  hint: 'กรุณากรอก...',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 14),

                                // ชื่อ-นามสกุลเจ้าของร้าน
                                _buildLabel('ชื่อ-นามสกุลเจ้าของร้าน'),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _ownerNameCtrl,
                                  hint: 'กรุณากรอก...',
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 14),

                                // ประเภทร้านค้า (Dropdown)
                                _buildLabel('ประเภทร้านค้า'),
                                const SizedBox(height: 6),
                                _buildCategoryDropdown(),
                                const SizedBox(height: 14),

                                // E-mail
                                _buildLabel('E-mail'),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _emailCtrl,
                                  hint: 'กรุณากรอกอีเมล...',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),

                                // เบอร์โทรศัพท์
                                _buildLabel('เบอร์โทรศัพท์'),
                                const SizedBox(height: 6),
                                _buildTextField(
                                  controller: _phoneCtrl,
                                  hint: 'กรุณากรอกเบอร์โทรศัพท์...',
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 14),

                                // ── ความต้องการพิเศษ ──────
                                _buildUtilitiesSection(),
                                const SizedBox(height: 14),

                                // ── เพิ่มเติม ─────────────
                                _buildExtrasSection(),
                                const SizedBox(height: 28),

                                // ── ปุ่ม ──────────────────
                                _buildButtons(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
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

  // ══════════════════════════════════════════════════════════
  // Widget Builders
  // ══════════════════════════════════════════════════════════

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 56,
              color: Colors.white,
            ),
          ),
          // ปุ่มเพิ่มรูป
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF8CBC63),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8CBC63),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8CBC63).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'Sign up',
          style: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMsg!,
                style: GoogleFonts.kanit(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedCategory != null
              ? const Color(0xFF8CBC63)
              : const Color(0xFFE5E7EB),
          width: _selectedCategory != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: Text(
            'กรุณากรอกประเภท...',
            style: GoogleFonts.kanit(
              color: const Color(0xFFBDBDBD),
              fontSize: 13,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFBDBDBD),
          ),
          isExpanded: true,
          style: GoogleFonts.kanit(fontSize: 13, color: Colors.black87),
          items: _categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(cat, style: GoogleFonts.kanit(fontSize: 13)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }

  // ── ความต้องการสิ่งอำนวยความสะดวกเพิ่มเติม ───────────────
  Widget _buildUtilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ต้องการสิ่งอำนวยความสะดวกเพิ่มเติม',
          style: GoogleFonts.kanit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _utilities.keys.map((key) {
            final isSelected = _utilities[key]!;
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () =>
                    setState(() => _utilities[key] = !_utilities[key]!),
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Radio Circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSelected ? const Color(0xFF8CBC63) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8CBC63)
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      key,
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF8CBC63)
                            : const Color(0xFF374151),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── เพิ่มเติม (Tag input) ──────────────────────────────────
  Widget _buildExtrasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เพิ่มเติม...',
          style: GoogleFonts.kanit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),

        // Tag chips ที่เพิ่มแล้ว
        if (_extras.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _extras.map((tag) {
              return Chip(
                label: Text(tag, style: GoogleFonts.kanit(fontSize: 12)),
                backgroundColor: const Color(0xFF8CBC63).withOpacity(0.15),
                deleteIconColor: const Color(0xFF8CBC63),
                side: const BorderSide(color: Color(0xFF8CBC63), width: 0.8),
                onDeleted: () {
                  setState(() => _extras.remove(tag));
                },
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              );
            }).toList(),
          ),

        if (_extras.isNotEmpty) const SizedBox(height: 6),

        // Input เพิ่ม tag ใหม่
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _extraCtrl,
                style: GoogleFonts.kanit(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'พิมพ์แล้วกด +',
                  hintStyle: GoogleFonts.kanit(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
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
                ),
                onSubmitted: _addExtra,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _addExtra(_extraCtrl.text),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF8CBC63),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addExtra(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_extras.contains(trimmed)) {
      setState(() {
        _extras.add(trimmed);
        _extraCtrl.clear();
      });
    }
  }

  Widget _buildButtons() {
    return Row(
      children: [
        // ปุ่มยกเลิก
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.kanit(color: const Color(0xFF6B7280)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ปุ่มสมัครบัญชี
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              onPressed: _loading ? null : _handleSignUp,
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
                      'สมัครบัญชี',
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

  // ── Reusable Helpers ──────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.kanit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.kanit(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.kanit(
          color: const Color(0xFFBDBDBD),
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: suffixIcon,
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
      ),
    );
  }
}

// ── Wave Painter ──────────────────────────────────────────────
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
