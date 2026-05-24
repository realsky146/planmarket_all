import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'vendor_home.dart';
import 'vendor_market_list_page.dart';
import 'favorite_vendor_page.dart';
import 'vendor_shop_info_page.dart';
import 'profile_vendor_page.dart';

class VendorBookingPage extends StatefulWidget {
  final Map<String, dynamic>? market;
  final String? marketId;
  final String? marketName;

  const VendorBookingPage({
    super.key,
    this.market,
    this.marketId,
    this.marketName,
  });

  @override
  State<VendorBookingPage> createState() => _VendorBookingPageState();
}

class _VendorBookingPageState extends State<VendorBookingPage> {
  int _currentIndex = 3;
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  String _selectedStatus = 'all';
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;

      if (_userId > 0) {
        final response = await ApiService.getUserBookings(_userId);
        if (response['success'] == true && response['data'] != null) {
          final List<dynamic> rawData = response['data'];
          setState(() {
            _bookings = rawData.map((b) => {
              'id': b['id']?.toString() ?? '',
              'marketName': b['market_name'] ?? 'ไม่ระบุตลาด',
              'marketId': b['market_id']?.toString() ?? '',
              'stallNumber': b['stall_number'] ?? '',
              'shopName': b['shop_name'] ?? '',
              'status': b['status'] ?? 'pending',
              'startDate': b['start_date'] ?? b['created_at'] ?? '',
              'endDate': b['end_date'] ?? '',
              'totalPrice': b['total_price'] ?? 0,
              'reason': b['reason'] ?? '',
              'createdAt': b['created_at'] ?? '',
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedStatus == 'all') return _bookings;
    return _bookings.where((b) => b['status'] == _selectedStatus).toList();
  }

  int get _pendingCount => _bookings.where((b) => b['status'] == 'pending').length;
  int get _approvedCount => _bookings.where((b) => b['status'] == 'approved').length;
  int get _rejectedCount => _bookings.where((b) => b['status'] == 'rejected').length;

  void _showQRCode(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => _QRDialog(booking: booking),
    );
  }

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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                        style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.kanit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _detailRow(Icons.storefront_rounded, 'ตลาด', booking['marketName']),
                    _detailRow(Icons.grid_view_rounded, 'ล็อค', booking['stallNumber']),
                    _detailRow(Icons.store_rounded, 'ชื่อร้าน', booking['shopName']),
                    _detailRow(Icons.calendar_today_rounded, 'วันที่จอง', booking['createdAt']),
                    if (booking['startDate'].isNotEmpty)
                      _detailRow(Icons.play_arrow_rounded, 'วันเริ่ม', booking['startDate']),
                    if (booking['endDate'].isNotEmpty)
                      _detailRow(Icons.stop_rounded, 'วันสิ้นสุด', booking['endDate']),
                    if (status == 'rejected' && booking['reason'].isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('เหตุผลที่ปฏิเสธ', style: GoogleFonts.kanit(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                            Text(booking['reason'], style: GoogleFonts.kanit(fontSize: 13, color: Colors.red.shade700)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (status == 'approved') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8CBC63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showQRCode(booking);
                          },
                          icon: const Icon(Icons.qr_code_rounded),
                          label: Text('ดู QR Code เช็คอิน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (status == 'rejected') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8CBC63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VendorMarketListPage()));
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('จองใหม่', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('ปิด', style: GoogleFonts.kanit(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF6E9B4C)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                Text(value.isEmpty ? '-' : value, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Widget? page;
      switch (index) {
        case 0: page = const VendorFavoritePage(); break;
        case 1: page = const VendorMarketListPage(); break;
        case 2: page = VendorHome(); break;
        case 3: return;
        case 4: page = const VendorProfilePage(); break;
      }
      if (page != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF8CBC63),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'ประวัติการจอง',
                  style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _summaryCard('รออนุมัติ', _pendingCount, const Color(0xFFFFB000), 'pending')),
                    const SizedBox(width: 8),
                    Expanded(child: _summaryCard('อนุมัติแล้ว', _approvedCount, const Color(0xFF22C55E), 'approved')),
                    const SizedBox(width: 8),
                    Expanded(child: _summaryCard('ปฏิเสธ', _rejectedCount, const Color(0xFFEF4444), 'rejected')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterTab('ทั้งหมด', 'all', const Color(0xFF6B7280)),
                const SizedBox(width: 8),
                _filterTab('รออนุมัติ', 'pending', const Color(0xFFFFB000)),
                const SizedBox(width: 8),
                _filterTab('อนุมัติแล้ว', 'approved', const Color(0xFF22C55E)),
                const SizedBox(width: 8),
                _filterTab('ปฏิเสธ', 'rejected', const Color(0xFFEF4444)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8CBC63)))
                : _filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text('ไม่มีการจองในหมวดนี้', style: GoogleFonts.kanit(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF8CBC63),
                        onRefresh: _loadData,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: _filteredBookings.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _buildBookingCard(_filteredBookings[i]),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _summaryCard(String label, int count, Color color, String status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = isSelected ? 'all' : status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text('$count', style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color)),
            Text(label, style: GoogleFonts.kanit(fontSize: 10, color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _filterTab(String label, String status, Color color) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 13,
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.storefront_rounded, color: Color(0xFF8CBC63)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['marketName'], style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('ล็อค: ${booking['stallNumber']}', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                        Text(booking['createdAt'], style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(statusText, style: GoogleFonts.kanit(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text('ดูรายละเอียด →', style: GoogleFonts.kanit(fontSize: 11, color: const Color(0xFF8CBC63))),
                    ],
                  ),
                ],
              ),
            ),
            if (status == 'approved')
              GestureDetector(
                onTap: () => _showQRCode(booking),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CBC63).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_rounded, size: 14, color: Color(0xFF6E9B4C)),
                      const SizedBox(width: 6),
                      Text('กดดู QR Code เช็คอิน', style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF6E9B4C), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.favorite_border_rounded, 'label': 'ถูกใจ'},
      {'icon': Icons.storefront_rounded, 'label': 'ตลาด'},
      {'icon': Icons.home_rounded, 'label': 'หน้าแรก'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'ร้านค้า'},
      {'icon': Icons.account_circle_rounded, 'label': 'โปรไฟล์'},
    ];

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF8CBC63),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _currentIndex == i;
          return GestureDetector(
            onTap: () => _navigateToPage(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[i]['icon'] as IconData, color: isSelected ? Colors.white : Colors.white.withOpacity(0.5), size: 24),
                const SizedBox(height: 4),
                Text(items[i]['label'] as String, style: GoogleFonts.kanit(fontSize: 11, color: isSelected ? Colors.white : Colors.white.withOpacity(0.5), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// QR Dialog
class _QRDialog extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _QRDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    final bookingId = booking['id'] ?? '';
    final qrData = 'PLANMARKET-BK-$bookingId';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF8CBC63),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text('QR Code เช็คอิน', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: Color(0xFF8CBC63)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking['marketName'] ?? '', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                              Text('ล็อค: ${booking['stallNumber']}', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF8CBC63), width: 2)),
                    child: CustomPaint(painter: _QRPainter(qrData)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF8CBC63).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('BK-${bookingId.toString().padLeft(6, '0')}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF6E9B4C), letterSpacing: 2)),
                  ),
                  const SizedBox(height: 4),
                  Text('รหัสการจอง', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade400, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text('แสดง QR Code นี้ให้เจ้าหน้าที่ตลาดเพื่อยืนยันการเข้าร้าน', style: GoogleFonts.kanit(fontSize: 11, color: Colors.blue.shade700))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.pop(context),
                      child: Text('ปิด', style: GoogleFonts.kanit(color: Colors.grey)),
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
}

class _QRPainter extends CustomPainter {
  final String data;
  _QRPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final hash = data.hashCode;
    const cells = 21;
    final cellSize = size.width / cells;

    for (int row = 0; row < cells; row++) {
      for (int col = 0; col < cells; col++) {
        bool isBlack = _isFinderZone(row, col, cells)
            ? _finderValue(row, col, cells)
            : ((hash ^ (row * 31 + col * 17)) % 3) != 0;

        paint.color = isBlack ? Colors.black : Colors.white;
        canvas.drawRect(Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize), paint);
      }
    }
  }

  bool _isFinderZone(int r, int c, int size) =>
      (r < 8 && c < 8) || (r < 8 && c >= size - 8) || (r >= size - 8 && c < 8);

  bool _finderValue(int r, int c, int size) {
    int lr = r < 8 ? r : r - (size - 8);
    int lc = c < 8 ? c : c - (size - 8);
    if (lr == 0 || lr == 6 || lc == 0 || lc == 6) return true;
    if (lr >= 2 && lr <= 4 && lc >= 2 && lc <= 4) return true;
    return false;
  }

  @override
  bool shouldRepaint(_) => false;
}

