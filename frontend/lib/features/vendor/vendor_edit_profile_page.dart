import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════
// 🔌 API Service
// ══════════════════════════════════════════════════════════
class VendorEditProfileApiService {
  static const String baseUrl = 'https://api.planmarket.com/v1';

  // 🔌 TODO: GET $baseUrl/vendor/profile
  static Future<Map<String, dynamic>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'success': true,
      'data': {
        'shopName': 'ร้านมาลีผัดไทย',
        'name': 'นางสาวมาลี ขายดี',
        'shopCategory': 'อาหาร',
        'email': 'vendor@test.com',
        'phone': '082-345-6789',
        'shopDescription':
            'ผัดไทยสูตรต้นตำรับ เส้นนุ่ม ไข่สด รสชาติแบบดั้งเดิม',
        'image':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        'shopImage':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
        'openDays': 'ศุกร์ - อาทิตย์',
        'openTime': '17:00 - 22:00 น.',
        'priceRange': '฿',
        'menu': ['ผัดไทย', 'ผัดซีอิ๊ว', 'ราดหน้า'],
        'tags': ['อาหาร', 'ไทย'],
        'lineId': '@maleephadthai',
        'facebook': 'ร้านมาลีผัดไทย',
      },
    };
  }

  // 🔌 TODO: PUT $baseUrl/vendor/profile
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // 🔌 TODO: POST $baseUrl/upload
  static Future<String?> uploadImage(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return null;
  }
}

// ══════════════════════════════════════════════════════════
// VendorEditProfilePage
// ══════════════════════════════════════════════════════════
class VendorEditProfilePage extends StatefulWidget {
  const VendorEditProfilePage({super.key});

  @override
  State<VendorEditProfilePage> createState() => _VendorEditProfilePageState();
}

class _VendorEditProfilePageState extends State<VendorEditProfilePage> {
  bool _isLoading = true;
  bool _isSaving = false;

  // ── Controllers ───────────────────────────────────────
  final _shopNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _openDaysCtrl = TextEditingController();
  final _openTimeCtrl = TextEditingController();
  final _lineCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();
  final _menuCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────
  final String _priceRange = '฿';
  List<String> _menuItems = [];
  List<String> _tags = [];
  String _profileImageUrl = '';
  String _shopImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _openDaysCtrl.dispose();
    _openTimeCtrl.dispose();
    _lineCtrl.dispose();
    _fbCtrl.dispose();
    _menuCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final result = await VendorEditProfileApiService.getProfile();
      if (mounted && result['success'] == true) {
        final d = result['data'] as Map<String, dynamic>;
        setState(() {
          _shopNameCtrl.text = d['shopName'] ?? '';
          _nameCtrl.text = d['name'] ?? '';
          _categoryCtrl.text = d['shopCategory'] ?? '';
          _emailCtrl.text = d['email'] ?? '';
          _phoneCtrl.text = d['phone'] ?? '';
          _descCtrl.text = d['shopDescription'] ?? '';
          _openDaysCtrl.text = d['openDays'] ?? '';
          _openTimeCtrl.text = d['openTime'] ?? '';
          _menuItems = List<String>.from(d['menu'] ?? []);
          _tags = List<String>.from(d['tags'] ?? []);
          _profileImageUrl = d['image'] ?? '';
          _shopImageUrl = d['shopImage'] ?? '';
        });
      }
    } catch (_) {
      _showSnackbar('โหลดข้อมูลไม่สำเร็จ', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    // ✅ FIX #2: ลบ space ใน "_ save" → "_save"
    if (_shopNameCtrl.text.trim().isEmpty) {
      _showSnackbar('กรุณากรอกชื่อร้านค้า', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final ok = await VendorEditProfileApiService.updateProfile({
        'shopName': _shopNameCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'shopCategory': _categoryCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'shopDescription': _descCtrl.text.trim(),
        'openDays': _openDaysCtrl.text.trim(),
        'openTime': _openTimeCtrl.text.trim(),
        'priceRange': _priceRange,
        'menu': _menuItems,
        'tags': _tags,
      });
      if (!mounted) return;
      if (ok) {
        _showSnackbar('บันทึกข้อมูลสำเร็จ');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackbar('บันทึกไม่สำเร็จ', isError: true);
      }
    } catch (_) {
      _showSnackbar('เกิดข้อผิดพลาด', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
          child: Column(
            children: [
              // ── Wave Header ──────────────────────────
              _buildWaveHeader(),
              // ── Spacing สำหรับรูปโปรไฟล์ที่ล้นออกมา ──
              const SizedBox(height: 55),
              // ── Form ────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── ชื่อร้านค้า ──────────────────
                      _label('ชื่อร้านค้า'),
                      _field(
                        controller: _shopNameCtrl,
                        hint: 'กรุณากรอก...',
                      ),
                      const SizedBox(height: 14),

                      // ── ชื่อ-นามสกุล ─────────────────
                      _label('ชื่อ-นามสกุลเจ้าของร้าน'),
                      _field(
                        controller: _nameCtrl,
                        hint: 'กรุณากรอก...',
                      ),
                      const SizedBox(height: 14),

                      // ── ประเภทร้านค้า ─────────────────
                      _label('ประเภทร้านค้า'),
                      _field(
                        controller: _categoryCtrl,
                        hint: 'กรุณากรอกประเภท...',
                      ),
                      const SizedBox(height: 14),

                      // ── E-mail ────────────────────────
                      _label('E-mail'),
                      _field(
                        controller: _emailCtrl,
                        hint: 'กรุณากรอกอีเมล...',
                        enabled: false,
                        note: 'อีเมลไม่สามารถเปลี่ยนแปลงได้',
                      ),
                      const SizedBox(height: 14),

                      // ── เบอร์โทรศัพท์ ─────────────────
                      _label('เบอร์โทรศัพท์'),
                      _field(
                        controller: _phoneCtrl,
                        hint: 'กรุณากรอกเบอร์โทรศัพท์...',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),

                      // ── รายละเอียดร้าน ────────────────
                      _label('รายละเอียดร้าน'),
                      _field(
                        controller: _descCtrl,
                        hint: 'กรุณากรอกรายละเอียด...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),

                      // ── วันที่เปิด ────────────────────
                      _label('วันที่เปิด'),
                      _field(
                        controller: _openDaysCtrl,
                        hint: 'เช่น จันทร์ - ศุกร์',
                      ),
                      const SizedBox(height: 14),

                      // ── เวลาเปิด-ปิด ──────────────────
                      _label('เวลาเปิด - ปิด'),
                      _field(
                        controller: _openTimeCtrl,
                        hint: 'เช่น 17:00 - 23:00 น.',
                      ),
                      const SizedBox(height: 14),
                      // ── เมนู / สินค้า ─────────────────
                      _label('เมนู / สินค้า'),
                      const SizedBox(height: 4),
                      Text(
                        'เพิ่มเมนูหรือสินค้าที่ขายในร้าน',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildTagInput(
                        controller: _menuCtrl,
                        items: _menuItems,
                        hint: 'พิมพ์เมนูแล้วกด +',
                        chipColor: const Color(0xFFFFF3CD),
                        textColor: const Color(0xFFB45309),
                        onAdd: (v) {
                          if (v.isNotEmpty && !_menuItems.contains(v)) {
                            setState(() {
                              _menuItems.add(v);
                              _menuCtrl.clear();
                            });
                          }
                        },
                        onRemove: (v) => setState(() => _menuItems.remove(v)),
                      ),
                      const SizedBox(height: 14),

                      // ── Buttons ───────────────────────
                      Row(
                        children: [
                          // ยกเลิก
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  // ✅ FIX #6: ลบ ! ออกจาก Colors.grey
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(
                                  'ยกเลิก',
                                  style: GoogleFonts.kanit(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // บันทึก
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8CBC63),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                // ✅ FIX #2: _save (ไม่มี space)
                                onPressed: _isSaving ? null : _save,
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
                                        // ✅ FIX #4: เปลี่ยนจาก "สมัครบัญชี" → "บันทึก"
                                        'บันทึก',
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // Wave Header + รูปโปรไฟล์
  // ══════════════════════════════════════════════════════
  Widget _buildWaveHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Wave
        SizedBox(
          height: 120,
          width: double.infinity,
          child: CustomPaint(painter: _WavePainter()),
        ),
        // Back Button
        Positioned(
          top: 12,
          left: 8,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        // Title
        Positioned(
          top: 16,
          child: Text(
            'แก้ไขโปรไฟล์ร้านค้า',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // รูปโปรไฟล์ (ล้นออกมาจาก wave)
        Positioned(
          bottom: -45,
          child: GestureDetector(
            // 🔌 TODO: image picker
            onTap: () {},
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImageUrl.isNotEmpty
                        ? Image.network(
                            _profileImageUrl,
                            fit: BoxFit.cover,
                            // ✅ FIX #1: แก้ errorBuilder syntax
                            errorBuilder: (context, error, stackTrace) =>
                                _avatarPlaceholder(),
                          )
                        : _avatarPlaceholder(),
                  ),
                ),
                // Camera icon
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 26,
                    height: 26,
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
          ),
        ),
      ],
    );
  }

  // ✅ FIX #3: แก้สี icon ให้มองเห็นได้
  Widget _avatarPlaceholder() => Container(
        color: Colors.grey,
        child: const Icon(Icons.person_rounded, size: 50, color: Colors.white),
      );

  // ══════════════════════════════════════════════════════
  // Tag Input (เมนู / Tags)
  // ══════════════════════════════════════════════════════
  Widget _buildTagInput({
    required TextEditingController controller,
    required List<String> items,
    required String hint,
    required Color chipColor,
    required Color textColor,
    required Function(String) onAdd,
    required Function(String) onRemove,
    String prefix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  // ✅ FIX #6: ลบ ! ออก
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.kanit(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.kanit(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: onAdd,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onAdd(controller.text.trim()),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF8CBC63),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        // Chips
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix$item',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => onRemove(item),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // Reusable Widgets
  // ══════════════════════════════════════════════════════
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.kanit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            // ✅ FIX #7: disabled ใช้ grey แทน grey (เข้มเกิน)
            color: enabled ? Colors.white : Colors.grey,
            borderRadius: BorderRadius.circular(30),
            // ✅ FIX #6: ลบ ! ออก
            border: Border.all(color: Colors.grey),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            keyboardType: keyboardType,
            style: GoogleFonts.kanit(
              fontSize: 14,
              color: enabled ? const Color(0xFF1F2937) : Colors.grey,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.kanit(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
            ),
          ),
        ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 6),
            child: Text(
              note,
              style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// Wave Painter
// ══════════════════════════════════════════════════════════
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8CBC63)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 1.1,
        size.width * 0.5,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width,
        size.height * 0.9,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
