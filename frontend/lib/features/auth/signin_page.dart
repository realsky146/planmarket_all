import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../guest/home_page.dart';
import '../vendor/vendor_home.dart';
import '../market_owner/market_owner_home.dart';
import '../market_owner/market_pending_page.dart';
import '../super_admin/admin_home.dart';
import 'signup_page.dart';
import 'signup_vendor_page.dart';
import 'signup_market_page.dart';
import '../../services/auth_service.dart';

class SignInPage extends StatefulWidget {
  final String role;
  const SignInPage({super.key, required this.role});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String get _roleLabel {
    switch (widget.role) {
      case 'customer':
        return 'ลูกค้า';
      case 'vendor':
        return 'ร้านค้า';
      case 'market':
        return 'เจ้าของตลาด';
      case 'super_admin':
        return 'ผู้ดูแลระบบ';
      default:
        return widget.role;
    }
  }

  Future<void> _signIn() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'กรุณากรอกอีเมลและรหัสผ่าน');
      return;
    }

    // ✅ แก้ไข: เติมวงเล็บปีกกาปิดที่หายไปตรงนี้
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final result = await AuthService().signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        role: widget.role,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (result['success'] == true) {
        final user = result['user'] ?? {};
        final String currentRole = result['role'] ?? widget.role;
        final String status = user['status'] ?? result['status'] ?? 'active';
        final String rejectReason =
            user['reject_reason'] ?? 'เอกสารไม่ชัดเจนหรือข้อมูลไม่ครบถ้วน';

        _navigateByRole(
          role: currentRole,
          status: status,
          rejectReason: rejectReason,
        );
      } else {
        setState(() =>
            _errorMsg = result['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
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

  // ✅ แก้ไข: รวมฟังก์ชัน _navigateByRole เป็นหนึ่งเดียว ไม่ให้ซ้ำซ้อน
  void _navigateByRole({
    required String role,
    required String status,
    String rejectReason = '',
  }) {
    Widget page;

    bool isRejectedOrLocked = (status == 'rejected' || status == 'banned');

    switch (role) {
      case 'super_admin':
        page = const AdminHome();
        break;

      case 'market_owner':
      case 'market':
        if (status == 'approved') {
          page = const MarketOwnerHome();
        } else {
          page = const MarketPendingPage();
        }
        break;

      case 'vendor':
        page = page = VendorHome(
          isRejectedOrLocked: isRejectedOrLocked,
          statusType: status,
          rejectReason: rejectReason,
        );
        break;

      case 'customer':
      default:
        page = const HomePage();
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  void _goToSignUp() {
    Widget signUpPage;
    switch (widget.role) {
      case 'vendor':
        signUpPage = const SignUpVendorPage();
        break;
      case 'market':
        signUpPage = const SignUpMarketPage();
        break;
      default:
        signUpPage = SignUpPage(role: widget.role);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => signUpPage),
    );
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
                          const SizedBox(height: 60),
                          SizedBox(
                            width: 160,
                            height: 160,
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
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 20, 24, 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'เข้าสู่ระบบ — $_roleLabel',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.kanit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ยินดีต้อนรับกลับมา',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.kanit(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_errorMsg != null) _buildErrorBox(),
                                  const SizedBox(height: 16),
                                  _buildFieldLabel('E-mail'),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.kanit(fontSize: 13),
                                    decoration: _inputStyle(
                                      'กรุณากรอกอีเมล...',
                                      prefixIcon: Icons.email_outlined,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFieldLabel('Password'),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _passCtrl,
                                    obscureText: _obscure,
                                    style: GoogleFonts.kanit(fontSize: 13),
                                    decoration: _inputStyle(
                                      'กรุณากรอกรหัสผ่าน...',
                                      prefixIcon: Icons.lock_outline_rounded,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: const Color(0xFFBDBDBD),
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 32),
                                      ),
                                      child: Text(
                                        'ลืมรหัสผ่าน?',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          color: const Color(0xFF8CBC63),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 46,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Color(0xFFD1D5DB)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              'ยกเลิก',
                                              style: GoogleFonts.kanit(
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SizedBox(
                                          height: 46,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF8CBC63),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                            ),
                                            onPressed:
                                                _loading ? null : _signIn,
                                            child: _loading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    'เข้าสู่ระบบ',
                                                    style: GoogleFonts.kanit(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 46,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFF8CBC63)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: _goToSignUp,
                                      icon: const Icon(
                                        Icons.person_add_outlined,
                                        color: Color(0xFF8CBC63),
                                        size: 18,
                                      ),
                                      label: Text(
                                        'สร้างบัญชีใหม่',
                                        style: GoogleFonts.kanit(
                                          color: const Color(0xFF8CBC63),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (widget.role == 'customer') ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const HomePage()),
                                        (route) => false,
                                      ),
                                      child: Text(
                                        'ใช้งานแบบ Guest (ไม่สมัครบัญชี)',
                                        style: GoogleFonts.kanit(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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

  Widget _buildErrorBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.kanit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.kanit(color: const Color(0xFFBDBDBD), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFFBDBDBD), size: 20)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8CBC63), width: 1.5),
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
