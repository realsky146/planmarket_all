import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vendor_edit_profile_page.dart';
import 'vendor_home.dart';

// ══════════════════════════════════════════════════════════
// Mock Data
// ══════════════════════════════════════════════════════════
class VendorShopInfoMockData {
  static Map<String, dynamic> get profile => {
        'success': true,
        'data': {
          'name': 'นางสาวมาลี ขายดี',
          'email': 'vendor@test.com',
          'phone': '082-345-6789',
          'image':
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
          'lineId': '@maleephadthai',
          'facebook': 'ร้านมาลีผัดไทย',
        },
      };

  static List<Map<String, dynamic>> get bookingHistory => [
        {
          'id': 'bk_h001',
          'marketName': 'ตลาดจตุจักร',
          'stallIds': ['A3', 'A4'],
          'startDate': '1 ม.ค. 2568',
          'endDate': '31 มี.ค. 2568',
          'totalDays': 45,
          'totalPrice': 27000,
          'status': 'approved',
          'checkedIn': true,
          'image':
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
          'bookingCode': 'BK-JJK-001',
          'location': 'จตุจักร กรุงเทพฯ',
          'zone': 'โซน A',
          'stallSize': '3x3 เมตร',
          'rentalRate': 600,
          'note': 'อนุมัติแล้ว กรุณาเช็คอินก่อนเปิดร้าน',
        },
        {
          'id': 'bk_h002',
          'marketName': 'ตลาดนัดรถไฟ',
          'stallIds': ['B5'],
          'startDate': '1 ธ.ค. 2567',
          'endDate': '31 พ.ค. 2568',
          'totalDays': 60,
          'totalPrice': 15000,
          'status': 'approved',
          'checkedIn': false,
          'image':
              'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=200',
          'bookingCode': 'BK-RTF-002',
          'location': 'รามอินทรา กรุงเทพฯ',
          'zone': 'โซน B',
          'stallSize': '2x2 เมตร',
          'rentalRate': 250,
          'note': 'กรุณาเช็คอินภายใน 30 นาทีก่อนเปิดตลาด',
        },
        {
          'id': 'bk_h003',
          'marketName': 'ตลาดเซฟวันโก',
          'stallIds': ['C2'],
          'startDate': '1 ก.ค. 2567',
          'endDate': '30 ก.ย. 2567',
          'totalDays': 30,
          'totalPrice': 9000,
          'status': 'completed',
          'checkedIn': true,
          'image':
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200',
          'bookingCode': 'BK-SVG-003',
          'location': 'สวนหลวง กรุงเทพฯ',
          'zone': 'โซน C',
          'stallSize': '3x4 เมตร',
          'rentalRate': 300,
          'note': 'การจองเสร็จสิ้นแล้ว',
        },
      ];
}

// ══════════════════════════════════════════════════════════
// VendorShopInfoPage
// ══════════════════════════════════════════════════════════
class VendorShopInfoPage extends StatefulWidget {
  const VendorShopInfoPage({super.key});

  @override
  State<VendorShopInfoPage> createState() => _VendorShopInfoPageState();
}

class _VendorShopInfoPageState extends State<VendorShopInfoPage> {
  bool _isLoading = true;
  String _profileImageUrl = '';
  String _profileName = '';
  List<Map<String, dynamic>> _bookingHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ✅ FIX: โหลดจาก mock แยกกัน ไม่ใช้ Future.wait + cast ผิด
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      final profile = VendorShopInfoMockData.profile;
      final history = VendorShopInfoMockData.bookingHistory;

      if (profile['success'] == true) {
        final d = profile['data'] as Map<String, dynamic>;
        setState(() {
          _profileName = d['name'] as String? ?? '';
          _profileImageUrl = d['image'] as String? ?? '';
          _bookingHistory =
              history.map((b) => Map<String, dynamic>.from(b)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('โหลดข้อมูลไม่สำเร็จ', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ FIX: formatNumber ถูกต้อง
  String _formatNumber(int n) {
    final str = n.toString();
    final result = StringBuffer();
    final length = str.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(str[i]);
    }
    return result.toString();
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
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
  // QR Check-in Dialog
  // ══════════════════════════════════════════════════════
  void _showCheckinQR(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6E9B4C), Color(0xFF8CBC63)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_rounded,
                        color: Colors.white, size: 32),
                    const SizedBox(height: 6),
                    Text(
                      'QR Code เช็คอิน',
                      style: GoogleFonts.kanit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      booking['marketName'] ?? '-',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // Content — Scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      // QR Code
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF8CBC63).withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: _buildMockQR(
                            booking['bookingCode'] as String? ?? '-'),
                      ),
                      const SizedBox(height: 12),

                      // Booking Code
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9EB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8CBC63).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'รหัสการจอง',
                              style: GoogleFonts.kanit(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              booking['bookingCode'] as String? ?? '-',
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF374151),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ✅ Info Box — แก้สีพื้นหลัง
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'แสดง QR Code นี้ให้เจ้าหน้าที่ตลาด\nเพื่อยืนยันการเข้าออกร้าน',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ✅ Detail Grid — แก้สีพื้นหลัง
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _qrDetailChip(
                                  '🏪',
                                  'ล็อค',
                                  (booking['stallIds'] as List).join(', '),
                                ),
                                _qrDetailChip(
                                  '📍',
                                  'โซน',
                                  booking['zone'] as String? ?? '-',
                                ),
                                _qrDetailChip(
                                  booking['checkedIn'] == true ? '✅' : '⏳',
                                  'สถานะ',
                                  booking['checkedIn'] == true
                                      ? 'เช็คอินแล้ว'
                                      : 'ยังไม่เช็คอิน',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _qrDetailChip(
                                  '📅',
                                  'เริ่ม',
                                  booking['startDate'] as String? ?? '-',
                                ),
                                _qrDetailChip(
                                  '📅',
                                  'สิ้นสุด',
                                  booking['endDate'] as String? ?? '-',
                                ),
                                _qrDetailChip(
                                  '📐',
                                  'ขนาด',
                                  booking['stallSize'] as String? ?? '-',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Note
                      if ((booking['note'] as String? ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9EC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded,
                                  color: Colors.orange, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  booking['note'] as String,
                                  style: GoogleFonts.kanit(
                                    fontSize: 11,
                                    color: Colors.orange.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('ปิด',
                              style: GoogleFonts.kanit(color: Colors.grey)),
                        ),
                      ),
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

  // ✅ Mock QR ด้วย CustomPainter แทน Icon
  Widget _buildMockQR(String code) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(painter: _SimpleQRPainter(code)),
        ),
        const SizedBox(height: 6),
        Text(
          code,
          style: GoogleFonts.kanit(
            fontSize: 11,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _qrDetailChip(String emoji, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
          Text(
            value,
            style: GoogleFonts.kanit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF374151),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
              _buildWaveHeader(),
              const SizedBox(height: 55),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── ประวัติการจอง ─────────────────
                      _sectionHeader('ประวัติการจอง'),
                      const SizedBox(height: 10),
                      if (_bookingHistory.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text('ยังไม่มีประวัติการจอง',
                                  style: GoogleFonts.kanit(color: Colors.grey)),
                            ],
                          ),
                        )
                      else
                        ..._bookingHistory.map((b) => _buildHistoryCard(b)),

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

  // ── Menu Card ─────────────────────────────────────────
  Widget _menuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF8CBC63)).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? const Color(0xFF8CBC63), size: 20),
        ),
        title: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ── History Card ──────────────────────────────────────
  Widget _buildHistoryCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final checkedIn = booking['checkedIn'] as bool;

    Color statusColor;
    String statusText;

    if (status == 'completed') {
      statusColor = Colors.grey;
      statusText = 'เสร็จสิ้น';
    } else if (checkedIn) {
      statusColor = const Color(0xFF22C55E);
      statusText = 'เช็คอินแล้ว';
    } else {
      statusColor = const Color(0xFF8CBC63);
      statusText = 'อนุมัติแล้ว';
    }

    return GestureDetector(
      onTap: status != 'completed' ? () => _showCheckinQR(booking) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // รูปตลาด
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    bottomLeft: Radius.circular(status != 'completed' ? 0 : 12),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 95,
                    child: Image.network(
                      booking['image'] as String? ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.storefront_rounded,
                            color: Color(0xFF8CBC63), size: 28),
                      ),
                    ),
                  ),
                ),
                // ข้อมูล
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                booking['marketName'] as String? ?? '-',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusText,
                                style: GoogleFonts.kanit(
                                  fontSize: 10,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.grid_view_rounded,
                                size: 11, color: Colors.grey),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                'ล็อค: ${(booking['stallIds'] as List).join(', ')}',
                                style: GoogleFonts.kanit(
                                    fontSize: 11, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.date_range_rounded,
                                size: 11, color: Colors.grey),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${booking['startDate']} - ${booking['endDate']}',
                                style: GoogleFonts.kanit(
                                    fontSize: 11, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // ✅ ราคาแสดงถูกต้อง
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '฿${_formatNumber(booking['totalPrice'] as int)}',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF6E9B4C),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              ' • ${booking['totalDays']} วัน',
                              style: GoogleFonts.kanit(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            const Spacer(),
                            if (status != 'completed')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8CBC63).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.qr_code_rounded,
                                        size: 11, color: Color(0xFF6E9B4C)),
                                    const SizedBox(width: 3),
                                    Text(
                                      'QR เช็คอิน',
                                      style: GoogleFonts.kanit(
                                        fontSize: 10,
                                        color: const Color(0xFF6E9B4C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ✅ แถบ QR ด้านล่าง (เฉพาะ approved)
            if (status != 'completed')
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF8CBC63).withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(
                        color: const Color(0xFF8CBC63).withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_rounded,
                        color: Color(0xFF6E9B4C), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'กดเพื่อดู QR Code สำหรับเช็คอิน',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        color: const Color(0xFF6E9B4C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Wave Header ───────────────────────────────────────
  Widget _buildWaveHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 120,
          width: double.infinity,
          child: CustomPaint(painter: _WavePainter()),
        ),
        Positioned(
          top: 12,
          left: 8,
          child: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const VendorHome()),
                );
              }
            },
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        Positioned(
          top: 18,
          child: Text(
            'ข้อมูลร้านค้า',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: -45,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F5E9),
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
                      errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                    )
                  : _avatarPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder() => Container(
        color: const Color(0xFFE8F5E9),
        child: const Icon(Icons.person_rounded,
            size: 50, color: Color(0xFF8CBC63)),
      );

  Widget _sectionHeader(String title) => Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF374151),
        ),
      );
}

// ══════════════════════════════════════════════════════════
// Simple QR Painter (จำลอง)
// ══════════════════════════════════════════════════════════
class _SimpleQRPainter extends CustomPainter {
  final String data;
  _SimpleQRPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.fill;

    final rng = data.hashCode;
    const cells = 21;
    final cellSize = size.width / cells;

    // วาด cells แบบ pseudo-random
    for (int r = 0; r < cells; r++) {
      for (int c = 0; c < cells; c++) {
        final val = (rng ^ (r * 31 + c * 17)) % 3;
        if (val == 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }

    // Finder patterns มุม 3 มุม
    _drawFinder(canvas, paint, 0, 0, cellSize);
    _drawFinder(canvas, paint, cells - 7, 0, cellSize);
    _drawFinder(canvas, paint, 0, cells - 7, cellSize);
  }

  void _drawFinder(Canvas canvas, Paint paint, int row, int col, double cs) {
    // กรอบนอก 7x7
    paint.color = const Color(0xFF374151);
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 7; c++) {
        final isOuter = r == 0 || r == 6 || c == 0 || c == 6;
        final isInner = r >= 2 && r <= 4 && c >= 2 && c <= 4;
        if (isOuter || isInner) {
          canvas.drawRect(
            Rect.fromLTWH((col + c) * cs, (row + r) * cs, cs, cs),
            paint,
          );
        } else {
          paint.color = Colors.white;
          canvas.drawRect(
            Rect.fromLTWH((col + c) * cs, (row + r) * cs, cs, cs),
            paint,
          );
          paint.color = const Color(0xFF374151);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
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
      ..quadraticBezierTo(size.width * 0.25, size.height * 1.1,
          size.width * 0.5, size.height * 0.85)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.6, size.width, size.height * 0.9)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
