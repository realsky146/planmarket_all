// ════════════════════════════════════════════════════════
// vendor_home.dart
// ════════════════════════════════════════════════════════
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vendor_shop_info_page.dart';
import 'vendor_market_list_page.dart';
import 'favorite_vendor_page.dart';
import '../vendor/profile_vendor_page.dart';

// ════════════════════════════════════════════════════════
// ส่วนที่ 1: Mock Data
// ════════════════════════════════════════════════════════
class VendorMockData {
  static final List<Map<String, dynamic>> bookings = [
    {
      'id': 'bk001',
      'marketName': 'ตลาดจตุจักร (โซนกลางคืน)',
      'marketId': 'm001',
      'location': 'จตุจักร กรุงเทพฯ',
      'stallIds': ['A3', 'A4'],
      'startDate': '1 ม.ค. 2568',
      'endDate': '31 มี.ค. 2568',
      'totalDays': 45,
      'totalPrice': 27000,
      'status': 'pending',
      'createdAt': '20 ธ.ค. 2567',
      'image':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
      'bookingCode': 'BK-JJK-001',
      'zone': 'โซน A',
      'stallSize': '3x3 เมตร',
      'checkedIn': false,
      'note': '',
    },
    {
      'id': 'bk002',
      'marketName': 'ตลาดนัดรถไฟ',
      'marketId': 'm002',
      'location': 'รามอินทรา กรุงเทพฯ',
      'stallIds': ['B5'],
      'startDate': '1 ธ.ค. 2567',
      'endDate': '31 พ.ค. 2568',
      'totalDays': 60,
      'totalPrice': 15000,
      'status': 'approved',
      'createdAt': '15 พ.ย. 2567',
      'image':
          'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=200',
      'bookingCode': 'BK-RTF-002',
      'zone': 'โซน B',
      'stallSize': '2x2 เมตร',
      'checkedIn': false,
      'note': 'อนุมัติแล้ว กรุณาชำระเงินภายใน 24 ชม.',
    },
    {
      'id': 'bk003',
      'marketName': 'ตลาดเซฟวันโก',
      'marketId': 'm003',
      'location': 'สวนหลวง กรุงเทพฯ',
      'stallIds': ['C2', 'C3', 'C4'],
      'startDate': '15 ม.ค. 2568',
      'endDate': '14 ก.พ. 2568',
      'totalDays': 12,
      'totalPrice': 7200,
      'status': 'rejected',
      'createdAt': '10 ม.ค. 2568',
      'image':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200',
      'bookingCode': 'BK-SVG-003',
      'zone': 'โซน C',
      'stallSize': '3x4 เมตร',
      'checkedIn': false,
      'note': 'ล็อคที่เลือกถูกจองแล้ว กรุณาเลือกล็อคใหม่',
    },
    {
      'id': 'bk004',
      'marketName': 'ตลาดนัดสวนหลวง',
      'marketId': 'm004',
      'location': 'พระราม 4 กรุงเทพฯ',
      'stallIds': ['D1'],
      'startDate': '1 ก.พ. 2568',
      'endDate': '28 ก.พ. 2568',
      'totalDays': 8,
      'totalPrice': 1440,
      'status': 'approved',
      'createdAt': '25 ม.ค. 2568',
      'image':
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=200',
      'bookingCode': 'BK-SLW-004',
      'zone': 'โซน D',
      'stallSize': '2x3 เมตร',
      'checkedIn': true,
      'note': 'อนุมัติแล้ว ยินดีต้อนรับ!',
    },
  ];

  static final List<Map<String, dynamic>> notifications = [
    {
      'id': 'n001',
      'title': 'การจองได้รับการอนุมัติ',
      'body': 'ตลาดนัดรถไฟ อนุมัติการจองล็อค B5 ของคุณแล้ว',
      'type': 'approved',
      'isRead': false,
      'createdAt': '2 ชม. ที่แล้ว',
    },
    {
      'id': 'n002',
      'title': 'การจองถูกปฏิเสธ',
      'body': 'ตลาดเซฟวันโก ปฏิเสธการจองล็อค C2-C4 ของคุณ',
      'type': 'rejected',
      'isRead': false,
      'createdAt': '5 ชม. ที่แล้ว',
    },
    {
      'id': 'n003',
      'title': 'แจ้งเตือนการชำระเงิน',
      'body': 'กรุณาชำระเงินค่าเช่าล็อค B5 ภายใน 24 ชม.',
      'type': 'payment',
      'isRead': true,
      'createdAt': '1 วันที่แล้ว',
    },
  ];
}

// ════════════════════════════════════════════════════════
// ส่วนที่ 2: QR Code Painter
// ════════════════════════════════════════════════════════
class _QRCodePainter extends CustomPainter {
  final String data;
  final List<List<bool>> _matrix;

  _QRCodePainter(this.data) : _matrix = _generateMatrix(data);

  static List<List<bool>> _generateMatrix(String data) {
    final rng = Random(data.hashCode);
    const size = 25;
    return List.generate(
      size,
      (r) => List.generate(size, (c) {
        if (_isFinderPattern(r, c, size)) return true;
        if (_isFinderPatternInner(r, c, size)) return false;
        if (_isFinderPatternCore(r, c, size)) return true;
        return rng.nextBool();
      }),
    );
  }

  static bool _isFinderPattern(int r, int c, int size) =>
      (r < 7 && c < 7) || (r < 7 && c >= size - 7) || (r >= size - 7 && c < 7);

  static bool _isFinderPatternInner(int r, int c, int size) =>
      (r >= 1 && r <= 5 && c >= 1 && c <= 5) ||
      (r >= 1 && r <= 5 && c >= size - 6 && c <= size - 2) ||
      (r >= size - 6 && r <= size - 2 && c >= 1 && c <= 5);

  static bool _isFinderPatternCore(int r, int c, int size) =>
      (r >= 2 && r <= 4 && c >= 2 && c <= 4) ||
      (r >= 2 && r <= 4 && c >= size - 5 && c <= size - 3) ||
      (r >= size - 5 && r <= size - 3 && c >= 2 && c <= 4);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / _matrix.length;
    final paint = Paint()..style = PaintingStyle.fill;
    for (int r = 0; r < _matrix.length; r++) {
      for (int c = 0; c < _matrix[r].length; c++) {
        paint.color = _matrix[r][c] ? Colors.black : Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ════════════════════════════════════════════════════════
// ส่วนที่ 3: VendorHome
// ════════════════════════════════════════════════════════
class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int currentIndex = 2;
  String _selectedStatus = 'all';
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  final Map<String, bool> _shopOpenStatus = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _bookings = VendorMockData.bookings
            .map((b) => Map<String, dynamic>.from(b))
            .toList();
        _notifications = VendorMockData.notifications
            .map((n) => Map<String, dynamic>.from(n))
            .toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bookings = [];
        _notifications = [];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Computed ──────────────────────────────────────────
  int get _pendingCount =>
      _bookings.where((b) => b['status'] == 'pending').length;
  int get _approvedCount =>
      _bookings.where((b) => b['status'] == 'approved').length;
  int get _rejectedCount =>
      _bookings.where((b) => b['status'] == 'rejected').length;
  int get _unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedStatus == 'all') return _bookings;
    return _bookings.where((b) => b['status'] == _selectedStatus).toList();
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return result.toString();
  }

  // ── Navigation ────────────────────────────────────────
  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      switch (index) {
        case 0:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const VendorFavoritePage()));
          break;
        case 1:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const VendorMarketListPage()));
          break;
        case 3:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const VendorShopInfoPage()));
          break;
        case 4:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const VendorProfilePage()));
          break;
      }
    });
  }

  // ════════════════════════════════════════════════════════
  // QR Check-in Dialog (รวมจาก _showCheckinQR)
  // ════════════════════════════════════════════════════════
  void _showQRCheckin(Map<String, dynamic> booking) {
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
              // ── Header ──────────────────────────────
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
                      booking['marketName'] as String? ?? '-',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Content ─────────────────────────────
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
                        padding: const EdgeInsets.all(8),
                        child: CustomPaint(
                          painter: _QRCodePainter(
                            booking['bookingCode'] as String? ?? '-',
                          ),
                        ),
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
                      // Info Box
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
                      // Detail Grid
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
                      const SizedBox(height: 10),
                      // ── ปุ่มเปิด/ปิดร้าน ────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _shopOpenStatus[booking['id']] == true
                                    ? Colors.red.shade400
                                    : const Color(0xFF8CBC63),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () async {
                            final isOpen =
                                _shopOpenStatus[booking['id']] ?? false;
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            if (!mounted) return;
                            setState(
                                () => _shopOpenStatus[booking['id']] = !isOpen);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                            }
                          },
                          child: Text(
                            _shopOpenStatus[booking['id']] == true
                                ? 'ปิดร้าน 🔴'
                                : 'เปิดร้าน 🟢',
                            style:
                                GoogleFonts.kanit(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ── ปุ่มปิด Dialog ───────────────────
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

  // ── QR Detail Chip ────────────────────────────────────
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

  // ════════════════════════════════════════════════════════
  // Notification Dialog
  // ════════════════════════════════════════════════════════
  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setD) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CBC63),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'การแจ้งเตือน',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (var n in _notifications) {
                                n['isRead'] = true;
                              }
                            });
                            setD(() {});
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'อ่านทั้งหมด',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: _notifications.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.notifications_off_rounded,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text('ไม่มีการแจ้งเตือน',
                                  style: GoogleFonts.kanit(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) =>
                              _buildNotificationItem(_notifications[i], setD),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> n, StateSetter setD) {
    final isRead = n['isRead'] as bool;
    final type = n['type'] as String;
    Color typeColor;
    IconData typeIcon;

    switch (type) {
      case 'approved':
        typeColor = Colors.green;
        typeIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        typeColor = Colors.red;
        typeIcon = Icons.cancel_rounded;
        break;
      case 'payment':
        typeColor = Colors.orange;
        typeIcon = Icons.payment_rounded;
        break;
      default:
        typeColor = Colors.blue;
        typeIcon = Icons.notifications_rounded;
    }

    return GestureDetector(
      onTap: () {
        setState(() => n['isRead'] = true);
        setD(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : typeColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.grey.shade200 : typeColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n['title'],
                          style: GoogleFonts.kanit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    n['body'],
                    style: GoogleFonts.kanit(
                        fontSize: 12, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['createdAt'],
                    style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // Booking Detail Dialog
  // ════════════════════════════════════════════════════════
  void _showBookingDetail(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF22C55E);
        statusText = 'อนุมัติแล้ว';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusText = 'ปฏิเสธแล้ว';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFFFFB000);
        statusText = 'รออนุมัติ';
        statusIcon = Icons.hourglass_top_rounded;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'รายละเอียดการจอง',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildBookingDetailCard(
                          booking, statusColor, status, ctx),
                      const SizedBox(height: 12),
                      _buildBookingDetailActions(
                          booking, status, statusColor, ctx),
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

  Widget _buildBookingDetailCard(
    Map<String, dynamic> booking,
    Color statusColor,
    String status,
    BuildContext ctx,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.network(
                booking['image'] as String? ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: const Color(0xFFE8F5E9),
                  child: const Icon(Icons.storefront_rounded,
                      size: 40, color: Color(0xFF8CBC63)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['marketName'] as String? ?? '-',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking['location'] as String? ?? '-',
                        style:
                            GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                _detailRow(Icons.grid_view_rounded, 'ล็อคที่จอง',
                    (booking['stallIds'] as List).join(', ')),
                _detailRow(Icons.calendar_today_rounded, 'วันที่เริ่ม',
                    booking['startDate'] as String? ?? '-'),
                _detailRow(Icons.event_rounded, 'วันที่สิ้นสุด',
                    booking['endDate'] as String? ?? '-'),
                _detailRow(Icons.timelapse_rounded, 'จำนวนวัน',
                    '${booking['totalDays']} วัน'),
                _detailRow(Icons.receipt_rounded, 'หมายเลขจอง',
                    booking['id'] as String? ?? '-'),
                _detailRow(Icons.access_time_rounded, 'วันที่ส่งคำขอ',
                    booking['createdAt'] as String? ?? '-'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CBC63).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'ราคารวมทั้งหมด',
                          style: GoogleFonts.kanit(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '฿${_formatNumber(booking['totalPrice'] as int)}',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6E9B4C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((booking['note'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: statusColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'หมายเหตุจากตลาด',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                booking['note'] as String,
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailActions(
    Map<String, dynamic> booking,
    String status,
    Color statusColor,
    BuildContext ctx,
  ) {
    return Column(
      children: [
        if (status == 'approved') ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showQRCheckin(booking); // ✅ เปิด QR Dialog
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_rounded, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'ดู QR Code สำหรับเช็คอิน',
                      style: GoogleFonts.kanit(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payment_rounded,
                    color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'กรุณาชำระเงินภายใน 24 ชั่วโมง\nเพื่อยืนยันการจอง',
                    style: GoogleFonts.kanit(
                        fontSize: 12, color: Colors.green, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (status == 'rejected') ...[
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VendorMarketListPage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('จองใหม่',
                      style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
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
            child: Text('ปิด', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6E9B4C), size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                Text(
                  value,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════════════════
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'สรุปการดำเนินการ',
                            style: GoogleFonts.kanit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _buildNotificationBell(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _summaryCard('รออนุมัติ', _pendingCount,
                              const Color(0xFFFFB000), 'pending'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryCard('อนุมัติแล้ว', _approvedCount,
                              const Color(0xFF22C55E), 'approved'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryCard('ปฏิเสธ', _rejectedCount,
                              const Color(0xFFEF4444), 'rejected'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _filterTab('ทั้งหมด', 'all', const Color(0xFF6B7280)),
                        const SizedBox(width: 8),
                        _filterTab(
                            'รออนุมัติ', 'pending', const Color(0xFFFFB000)),
                        const SizedBox(width: 8),
                        _filterTab(
                            'อนุมัติแล้ว', 'approved', const Color(0xFF22C55E)),
                        const SizedBox(width: 8),
                        _filterTab(
                            'ปฏิเสธ', 'rejected', const Color(0xFFEF4444)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF8CBC63)))
                        : _filteredBookings.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                color: const Color(0xFF8CBC63),
                                onRefresh: _loadData,
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 100),
                                  itemCount: _filteredBookings.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) =>
                                      _buildBookingCard(_filteredBookings[i]),
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

  // ── Sub Widgets ───────────────────────────────────────
  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: _showNotificationDialog,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_rounded,
                color: Colors.white, size: 20),
          ),
          if (_unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_unreadCount',
                    style: GoogleFonts.kanit(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('ไม่มีการจองในหมวดนี้',
              style: GoogleFonts.kanit(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color, String status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () =>
          setState(() => _selectedStatus = isSelected ? 'all' : status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$count',
                style: GoogleFonts.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: GoogleFonts.kanit(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTab(String label, String status, Color color) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF22C55E);
        statusText = 'อนุมัติแล้ว';
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusText = 'ปฏิเสธ';
        break;
      default:
        statusColor = const Color(0xFFFFB000);
        statusText = 'รออนุมัติ';
    }

    return GestureDetector(
      onTap: () => _showBookingDetail(booking),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    bottomLeft: Radius.circular(status == 'approved' ? 0 : 12),
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 90,
                    child: Image.network(
                      booking['image'] as String? ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.storefront_rounded,
                            color: Color(0xFF8CBC63), size: 30),
                      ),
                    ),
                  ),
                ),
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
                                maxLines: 2,
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
                        const SizedBox(height: 4),
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '฿${_formatNumber(booking['totalPrice'] as int)}',
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF6E9B4C),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              ' • ${booking['totalDays']}วัน',
                              style: GoogleFonts.kanit(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              'ดูรายละเอียด →',
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                color: const Color(0xFF8CBC63),
                                fontWeight: FontWeight.w600,
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
            // ── แถบ QR (เฉพาะ approved) ────────────────
            if (status == 'approved') ...[
              if (_shopOpenStatus[booking['id']] == true)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                  color: Colors.green.withOpacity(0.1),
                  child: Text(
                    '🟢 ร้านเปิดอยู่',
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              GestureDetector(
                onTap: () => _showQRCheckin(booking),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CBC63).withOpacity(0.1),
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
                          color: Color(0xFF6E9B4C), size: 15),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'กดเพื่อดู QR Code สำหรับเช็คอิน',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: const Color(0xFF6E9B4C),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF6E9B4C), size: 11),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────
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
                children: List.generate(items.length, (i) {
                  final isSelected = currentIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToPage(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Icon(
                            items[i]['icon'] as IconData,
                            color: Colors.white
                                .withOpacity(isSelected ? 0.0 : 0.8),
                            size: 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i]['label'] as String,
                            style: GoogleFonts.kanit(
                              fontSize: 10,
                              color: Colors.white
                                  .withOpacity(isSelected ? 0.0 : 0.8),
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

// ════════════════════════════════════════════════════════
// Top Wave Painter
// ════════════════════════════════════════════════════════
class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF73A34F)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.78);
    path.quadraticBezierTo(size.width * 0.18, size.height * 0.98,
        size.width * 0.52, size.height * 0.56);
    path.quadraticBezierTo(
        size.width * 0.72, size.height * 1.02, size.width, size.height * 0.72);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
