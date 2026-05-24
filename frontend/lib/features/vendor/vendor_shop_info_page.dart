import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vendor_home.dart';
import 'vendor_market_list_page.dart';
import 'favorite_vendor_page.dart';
import 'profile_vendor_page.dart';
import 'vendor_edit_profile_page.dart';
import '../../services/api_service.dart';

class VendorShopInfoPage extends StatefulWidget {
  const VendorShopInfoPage({super.key});

  @override
  State<VendorShopInfoPage> createState() => _VendorShopInfoPageState();
}

class _VendorShopInfoPageState extends State<VendorShopInfoPage> {
  int _currentIndex = 3;
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  String _userName = '';
  String _userImage = '';
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
      _userName = prefs.getString('userName') ?? '';
      _userImage = prefs.getString('userImage') ?? '';

      if (_userId > 0) {
        final response = await ApiService.getUserBookings(_userId);
        if (response['success'] == true && response['data'] != null) {
          final List<dynamic> rawData = response['data'];
          setState(() {
            _bookings = rawData
                .where((b) => b['status'] == 'approved')
                .map((b) => {
                      'id': b['id']?.toString() ?? '',
                      'marketName': b['market_name'] ?? '',
                      'stallNumber': b['stall_number'] ?? '',
                      'shopName': b['shop_name'] ?? '',
                      'status': b['status'] ?? '',
                      'startDate': b['start_date'] ?? b['created_at'] ?? '',
                      'endDate': b['end_date'] ?? '',
                      'marketId': b['market_id']?.toString() ?? '',
                    })
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading shop info: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showQRCode(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => _QRDialog(booking: booking, userName: _userName),
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
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
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
                  'ข้อมูลร้านค้า',
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _userImage.isNotEmpty ? NetworkImage(_userImage) : null,
                  backgroundColor: Colors.white,
                  child: _userImage.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Color(0xFF8CBC63))
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  _userName.isEmpty ? 'ร้านค้า' : _userName,
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Booking List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'ประวัติการจอง',
                  style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_bookings.length} รายการ',
                  style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8CBC63)))
                : _bookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.store_outlined, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text('ยังไม่มีการจองที่อนุมัติแล้ว', style: GoogleFonts.kanit(color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CBC63)),
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const VendorMarketListPage()),
                              ),
                              child: Text('ค้นหาตลาด', style: GoogleFonts.kanit(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF8CBC63),
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _bookings.length,
                          itemBuilder: (_, i) => _buildBookingCard(_bookings[i]),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Color(0xFF8CBC63)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['marketName'],
                        style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.grid_view_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'ล็อค: ${booking['stallNumber']}',
                            style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            booking['startDate'],
                            style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'เช็คอินแล้ว',
                    style: GoogleFonts.kanit(fontSize: 11, color: const Color(0xFF22C55E), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showQRCode(booking),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF8CBC63).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF6E9B4C)),
                  const SizedBox(width: 6),
                  Text(
                    'กดเพื่อดู QR Code สำหรับเช็คอิน',
                    style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF6E9B4C), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
                Icon(
                  items[i]['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  items[i]['label'] as String,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// QR Code Dialog
class _QRDialog extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String userName;

  const _QRDialog({required this.booking, required this.userName});

  @override
  Widget build(BuildContext context) {
    final bookingId = booking['id'] ?? '';
    final marketId = booking['marketId'] ?? '';
    final qrData = 'PLANMARKET-BK-$bookingId-MK-$marketId';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF8CBC63),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'QR Code เช็คอิน',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Market Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: Color(0xFF8CBC63)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['marketName'] ?? '',
                                style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'ล็อค: ${booking['stallNumber']} • ${booking['startDate']}',
                                style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // QR Code
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF8CBC63), width: 2),
                    ),
                    child: CustomPaint(
                      painter: _QRPainter(qrData),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8CBC63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'BK-${bookingId.toString().padLeft(6, '0')}',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6E9B4C),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'รหัสการจอง',
                    style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade400, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'แสดง QR Code นี้ให้เจ้าหน้าที่ตลาดเพื่อยืนยันการเข้าร้าน',
                            style: GoogleFonts.kanit(fontSize: 11, color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

// QR Code Painter
class _QRPainter extends CustomPainter {
  final String data;
  _QRPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = data.hashCode;
    const cells = 21;
    final cellSize = size.width / cells;

    for (int row = 0; row < cells; row++) {
      for (int col = 0; col < cells; col++) {
        bool isBlack = false;

        // Finder patterns (corners)
        if (_isFinderPattern(row, col, cells)) {
          isBlack = _finderPatternValue(row, col);
        } else {
          isBlack = ((random ^ (row * 31 + col * 17)) % 3) != 0;
        }

        paint.color = isBlack ? Colors.black : Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }
  }

  bool _isFinderPattern(int r, int c, int size) {
    return (r < 8 && c < 8) || (r < 8 && c >= size - 8) || (r >= size - 8 && c < 8);
  }

  bool _finderPatternValue(int r, int c) {
    int localR = r;
    int localC = c;
    if (r >= 14) localR = r - 14;
    if (c >= 14) localC = c - 14;

    if (localR == 0 || localR == 6 || localC == 0 || localC == 6) return true;
    if (localR >= 2 && localR <= 4 && localC >= 2 && localC <= 4) return true;
    return false;
  }

  @override
  bool shouldRepaint(_) => false;
}
