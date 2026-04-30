import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../auth/select_role_page.dart';

class MarketOwnerHome extends StatefulWidget {
  const MarketOwnerHome({super.key});

  @override
  State<MarketOwnerHome> createState() => _MarketOwnerHomeState();
}

class _MarketOwnerHomeState extends State<MarketOwnerHome> {
  int _currentIndex = 0;

  final _pages = const [
    _DashboardTab(),
    _StallLayoutTab(),
    _BookingTab(),
    _VendorTab(),
    _BroadcastTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: _pages[_currentIndex],
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
        'label': 'แดชบอร์ด'
      },
      {'icon': Icons.map_outlined, 'activeIcon': Icons.map, 'label': 'ผังตลาด'},
      {
        'icon': Icons.assignment_outlined,
        'activeIcon': Icons.assignment,
        'label': 'การจอง'
      },
      {
        'icon': Icons.store_outlined,
        'activeIcon': Icons.store,
        'label': 'ร้านค้า'
      },
      {
        'icon': Icons.campaign_outlined,
        'activeIcon': Icons.campaign,
        'label': 'ประกาศ'
      },
    ];

    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF8CBC63),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8CBC63).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(items.length, (i) {
                  final isSelected = _currentIndex == i;
                  final isCenter = i == items.length ~/ 2;
                  if (isCenter) return const Expanded(child: SizedBox());
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected
                                ? items[i]['activeIcon'] as IconData
                                : items[i]['icon'] as IconData,
                            color: Colors.white
                                .withOpacity(isSelected ? 1.0 : 0.6),
                            size: isSelected ? 24 : 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i]['label'] as String,
                            style: GoogleFonts.kanit(
                              fontSize: 9,
                              color: Colors.white
                                  .withOpacity(isSelected ? 1.0 : 0.6),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
          Positioned(
            bottom: 16,
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = items.length ~/ 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: _currentIndex == items.length ~/ 2
                      ? const Color(0xFF5A8A3C)
                      : const Color(0xFF6E9B4C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8CBC63).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _currentIndex == items.length ~/ 2
                      ? items[items.length ~/ 2]['activeIcon'] as IconData
                      : items[items.length ~/ 2]['icon'] as IconData,
                  color: Colors.white,
                  size: 26,
                ),
              ),
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
class _WaveHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8CBC63)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.95,
        size.width * 0.35, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.55,
        size.width * 0.65, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.85, size.height * 0.95, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════
// Mock Data Models
// ══════════════════════════════════════════════════════════
class StallModel {
  final String id;
  final String zone;
  final String stallNumber;
  final bool isBooked;
  final String shopName;
  final double pricePerDay;

  const StallModel({
    required this.id,
    required this.zone,
    required this.stallNumber,
    required this.isBooked,
    required this.shopName,
    required this.pricePerDay,
  });

  factory StallModel.fromJson(Map<String, dynamic> json) => StallModel(
        id: json['id'] ?? '',
        zone: json['zone'] ?? '',
        stallNumber: json['stall_number'] ?? '',
        isBooked: json['is_booked'] ?? false,
        shopName: json['shop_name'] ?? '',
        pricePerDay: (json['price_per_day'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'zone': zone,
        'stall_number': stallNumber,
        'is_booked': isBooked,
        'shop_name': shopName,
        'price_per_day': pricePerDay,
      };
}

class BookingRequestModel {
  final String id;
  final String shopName;
  final String stallId;
  final String stallNumber;
  final String zone;
  final String type;
  final String date;
  final String status;
  final String vendorPhone;
  final String vendorEmail;

  const BookingRequestModel({
    required this.id,
    required this.shopName,
    required this.stallId,
    required this.stallNumber,
    required this.zone,
    required this.type,
    required this.date,
    required this.status,
    required this.vendorPhone,
    required this.vendorEmail,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) =>
      BookingRequestModel(
        id: json['id'] ?? '',
        shopName: json['shop_name'] ?? '',
        stallId: json['stall_id'] ?? '',
        stallNumber: json['stall_number'] ?? '',
        zone: json['zone'] ?? '',
        type: json['type'] ?? '',
        date: json['date'] ?? '',
        status: json['status'] ?? 'pending',
        vendorPhone: json['vendor_phone'] ?? '',
        vendorEmail: json['vendor_email'] ?? '',
      );
}

// ── Mock Data ──
final List<StallModel> mockStalls = [
  ...List.generate(
      20,
      (i) => StallModel(
            id: 'stall_a_${i + 1}',
            zone: 'โซน A',
            stallNumber: 'A${(i + 1).toString().padLeft(2, '0')}',
            isBooked: i % 3 == 0,
            shopName: i % 3 == 0 ? 'ร้าน A${i + 1}' : '',
            pricePerDay: 200,
          )),
  ...List.generate(
      15,
      (i) => StallModel(
            id: 'stall_b_${i + 1}',
            zone: 'โซน B',
            stallNumber: 'B${(i + 1).toString().padLeft(2, '0')}',
            isBooked: i % 4 == 0,
            shopName: i % 4 == 0 ? 'ร้าน B${i + 1}' : '',
            pricePerDay: 250,
          )),
  ...List.generate(
      18,
      (i) => StallModel(
            id: 'stall_c_${i + 1}',
            zone: 'โซน C',
            stallNumber: 'C${(i + 1).toString().padLeft(2, '0')}',
            isBooked: i % 2 == 0,
            shopName: i % 2 == 0 ? 'ร้าน C${i + 1}' : '',
            pricePerDay: 180,
          )),
  ...List.generate(
      12,
      (i) => StallModel(
            id: 'stall_d_${i + 1}',
            zone: 'โซน D',
            stallNumber: 'D${(i + 1).toString().padLeft(2, '0')}',
            isBooked: i % 5 == 0,
            shopName: i % 5 == 0 ? 'ร้าน D${i + 1}' : '',
            pricePerDay: 150,
          )),
];

final List<BookingRequestModel> mockBookings = [
  const BookingRequestModel(
    id: 'bk001',
    shopName: 'ร้านอาชียะ',
    stallId: 'stall_b_1',
    stallNumber: 'B01',
    zone: 'โซน B',
    type: 'รายวัน',
    date: '27 ก.พ. 2026',
    status: 'pending',
    vendorPhone: '081-234-5678',
    vendorEmail: 'achia@email.com',
  ),
  const BookingRequestModel(
    id: 'bk002',
    shopName: 'ร้านมานี',
    stallId: 'stall_a_3',
    stallNumber: 'A03',
    zone: 'โซน A',
    type: 'รายเดือน',
    date: 'มี.ค. 2026',
    status: 'pending',
    vendorPhone: '082-345-6789',
    vendorEmail: 'manee@email.com',
  ),
  const BookingRequestModel(
    id: 'bk003',
    shopName: 'ร้านสมชาย',
    stallId: 'stall_c_2',
    stallNumber: 'C02',
    zone: 'โซน C',
    type: 'รายสัปดาห์',
    date: '1-7 มี.ค. 2026',
    status: 'approved',
    vendorPhone: '083-456-7890',
    vendorEmail: 'somchai@email.com',
  ),
  const BookingRequestModel(
    id: 'bk004',
    shopName: 'ร้านวิไล',
    stallId: 'stall_d_5',
    stallNumber: 'D05',
    zone: 'โซน D',
    type: 'รายวัน',
    date: '28 ก.พ. 2026',
    status: 'rejected',
    vendorPhone: '084-567-8901',
    vendorEmail: 'wilai@email.com',
  ),
];

// ══════════════════════════════════════════════════════════
// Tab 1: Dashboard
// ══════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  Widget _statCard(String label, String value, Color bgColor,
      {Color textColor = const Color(0xFF1F2937), VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
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
                child: Text(value,
                    style: GoogleFonts.kanit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.kanit(
                      fontSize: 11, color: textColor.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllStallsPopup(BuildContext context) {
    final zones = ['โซน A', 'โซน B', 'โซน C', 'โซน D'];
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    const Icon(Icons.grid_view_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('แผงทั้งหมด',
                          style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'รวม ${mockStalls.length} แผง',
                        style: GoogleFonts.kanit(
                            fontSize: 11, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
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
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(const Color(0xFF22C55E), 'ว่าง'),
                    const SizedBox(width: 20),
                    _legendDot(const Color(0xFFEF4444), 'จองแล้ว'),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: zones.map((zone) {
                    final zoneStalls =
                        mockStalls.where((s) => s.zone == zone).toList();
                    final bookedCount =
                        zoneStalls.where((s) => s.isBooked).length;
                    final freeCount = zoneStalls.length - bookedCount;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8CBC63).withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(zone,
                                    style: GoogleFonts.kanit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: const Color(0xFF4A7C3F))),
                                const Spacer(),
                                _miniChip(
                                    'ว่าง $freeCount', const Color(0xFF22C55E)),
                                const SizedBox(width: 6),
                                _miniChip('จอง $bookedCount',
                                    const Color(0xFFEF4444)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: zoneStalls.map((stall) {
                                return GestureDetector(
                                  onTap: () => _showStallDetail(context, stall),
                                  child: Container(
                                    width: 48,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: stall.isBooked
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        stall.stallNumber
                                            .replaceAll(RegExp(r'[A-Z]'), ''),
                                        style: GoogleFonts.kanit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.kanit(fontSize: 12)),
      ],
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.kanit(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _showStallDetail(BuildContext context, StallModel stall) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: stall.isBooked
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFDFF7E6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                stall.isBooked ? Icons.store : Icons.store_outlined,
                color: stall.isBooked
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF22C55E),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text('แผง ${stall.stallNumber}',
                style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogRow('โซน', stall.zone),
            const SizedBox(height: 6),
            _dialogRow('สถานะ', stall.isBooked ? 'จองแล้ว' : 'ว่าง'),
            if (stall.isBooked) ...[
              const SizedBox(height: 6),
              _dialogRow('ร้านค้า', stall.shopName),
            ],
            const SizedBox(height: 6),
            _dialogRow('ราคา/วัน', '฿${stall.pricePerDay.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ปิด', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Row(
      children: [
        Text('$label : ',
            style: GoogleFonts.kanit(
                fontSize: 13, color: const Color(0xFF6B7280))),
        Text(value,
            style:
                GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStalls = mockStalls.length;
    final freeStalls = mockStalls.where((s) => !s.isBooked).length;
    final pendingBookings =
        mockBookings.where((b) => b.status == 'pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Stack(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(painter: _WaveHeaderPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, totalStalls, freeStalls, pendingBookings),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      _sectionTitle('รายรับวันนี้'),
                      const SizedBox(height: 8),
                      _buildRevenueCard(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle('คำขอจองล่าสุด'),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'ดูทั้งหมด →',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: const Color(0xFF8CBC63),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...mockBookings
                          .where((b) => b.status == 'pending')
                          .take(3)
                          .map((b) => _bookingRequestCard(context, b)),
                      const SizedBox(height: 16),
                      _sectionTitle('ประกาศด่วน'),
                      const SizedBox(height: 8),
                      _broadcastCard(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int total, int free, int pending) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('สวัสดี เจ้าของตลาด',
                      style: GoogleFonts.kanit(
                          color: Colors.white70, fontSize: 13)),
                  Text('ตลาดจตุจักร',
                      style: GoogleFonts.kanit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('ออกจากระบบ', style: GoogleFonts.kanit()),
                        content: Text('ต้องการออกจากระบบใช่ไหม?',
                            style: GoogleFonts.kanit()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('ยกเลิก', style: GoogleFonts.kanit()),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('ออกจากระบบ',
                                style: GoogleFonts.kanit(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await AuthService().logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SelectRolePage()),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard(
                'แผงทั้งหมด',
                '$total',
                Colors.white,
                onTap: () => _showAllStallsPopup(context),
              ),
              const SizedBox(width: 12),
              _statCard('ว่าง', '$free', const Color(0xFFDFF7E6),
                  textColor: const Color(0xFF22C55E)),
              const SizedBox(width: 12),
              _statCard('รออนุมัติ', '$pending', const Color(0xFFFFF3CD),
                  textColor: const Color(0xFFFFB000)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('รายรับรวม',
                  style: GoogleFonts.kanit(
                      color: const Color(0xFF6B7280), fontSize: 13)),
              const SizedBox(height: 4),
              Text('฿12,500',
                  style: GoogleFonts.kanit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8CBC63))),
              const SizedBox(height: 4),
              Text('ค้างชำระ: 3 ราย',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.red)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined,
                color: Color(0xFF8CBC63), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: GoogleFonts.kanit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151)));
  }

  Widget _bookingRequestCard(
      BuildContext context, BookingRequestModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF8CBC63),
            child: Icon(Icons.store, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.shopName,
                    style: GoogleFonts.kanit(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                    'แผง ${booking.stallNumber} ${booking.zone} • ${booking.type}',
                    style: GoogleFonts.kanit(
                        color: const Color(0xFF6B7280), fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8CBC63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => _showBookingDetail(context, booking),
            child: Text('ดูคำขอ',
                style: GoogleFonts.kanit(
                    fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBookingDetail(BuildContext context, BookingRequestModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB000),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('คำขอจองแผง',
                          style: GoogleFonts.kanit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _detailTile(Icons.store, 'ร้านค้า', booking.shopName),
                    _detailTile(Icons.grid_view_rounded, 'แผง',
                        '${booking.stallNumber} (${booking.zone})'),
                    _detailTile(
                        Icons.repeat_rounded, 'ประเภทการจอง', booking.type),
                    _detailTile(
                        Icons.calendar_today_rounded, 'วันที่', booking.date),
                    _detailTile(
                        Icons.phone_rounded, 'เบอร์โทร', booking.vendorPhone),
                    _detailTile(
                        Icons.email_rounded, 'อีเมล', booking.vendorEmail),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'ปฏิเสธคำขอของ ${booking.shopName}',
                                    style: GoogleFonts.kanit()),
                                backgroundColor: const Color(0xFFEF4444),
                              ));
                            },
                            child: Text('ปฏิเสธ',
                                style: GoogleFonts.kanit(
                                    color: const Color(0xFFEF4444))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8CBC63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'อนุมัติคำขอของ ${booking.shopName} แล้ว',
                                    style: GoogleFonts.kanit()),
                                backgroundColor: const Color(0xFF8CBC63),
                              ));
                            },
                            child: Text('อนุมัติ', style: GoogleFonts.kanit()),
                          ),
                        ),
                      ],
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

  Widget _detailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8CBC63)),
          const SizedBox(width: 8),
          Text('$label : ',
              style: GoogleFonts.kanit(
                  fontSize: 13, color: const Color(0xFF6B7280))),
          Expanded(
            child: Text(value,
                style: GoogleFonts.kanit(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _broadcastCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: _BroadcastTab(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF8CBC63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.campaign,
                  color: Color(0xFF8CBC63), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ส่งประกาศถึงผู้เช่าทุกคน',
                      style: GoogleFonts.kanit(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('กดเพื่อไปหน้าประกาศ',
                      style: GoogleFonts.kanit(
                          fontSize: 11, color: const Color(0xFF9CA3AF))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tab 2: Stall Layout
// ══════════════════════════════════════════════════════════
class _StallLayoutTab extends StatefulWidget {
  const _StallLayoutTab();

  @override
  State<_StallLayoutTab> createState() => _StallLayoutTabState();
}

class _StallLayoutTabState extends State<_StallLayoutTab> {
  String _selectedZone = 'โซน A';
  final _zones = ['โซน A', 'โซน B', 'โซน C', 'โซน D'];

  List<StallModel> get _currentStalls =>
      mockStalls.where((s) => s.zone == _selectedZone).toList();

  @override
  Widget build(BuildContext context) {
    final stalls = _currentStalls;
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text('ผังตลาด',
            style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8CBC63),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(const Color(0xFF22C55E), 'ว่าง'),
                const SizedBox(width: 24),
                _legendItem(const Color(0xFFEF4444), 'จองแล้ว'),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _zones.map((z) {
                final selected = z == _selectedZone;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(z,
                        style: GoogleFonts.kanit(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600)),
                    selected: selected,
                    selectedColor: const Color(0xFF8CBC63),
                    onSelected: (_) => setState(() => _selectedZone = z),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: stalls.length,
              itemBuilder: (_, i) {
                final stall = stalls[i];
                return GestureDetector(
                  onTap: () => _showStallInfo(stall),
                  child: Container(
                    decoration: BoxDecoration(
                      color: stall.isBooked
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        stall.stallNumber.replaceAll(RegExp(r'[A-Z]'), ''),
                        style: GoogleFonts.kanit(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStallInfo(StallModel stall) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stall.isBooked
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFDFF7E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stall.isBooked ? Icons.store : Icons.store_outlined,
                    color: stall.isBooked
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 12),
                Text('แผง ${stall.stallNumber}',
                    style: GoogleFonts.kanit(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            if (stall.isBooked) ...[
              _infoRow(Icons.store, 'ร้านค้า', stall.shopName),
              const SizedBox(height: 8),
              _infoRow(Icons.grid_view, 'แผง', stall.stallNumber),
              const SizedBox(height: 8),
              _infoRow(Icons.location_on, 'โซน', stall.zone),
              const SizedBox(height: 8),
              _infoRow(Icons.attach_money, 'ราคา/วัน',
                  '฿${stall.pricePerDay.toStringAsFixed(0)}'),
            ] else
              Center(
                child: Text('แผงนี้ว่างอยู่',
                    style: GoogleFonts.kanit(
                        color: const Color(0xFF22C55E),
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CBC63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('ปิด', style: GoogleFonts.kanit()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text('$label : ',
            style: GoogleFonts.kanit(
                color: const Color(0xFF6B7280), fontSize: 13)),
        Text(value,
            style:
                GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.kanit(fontSize: 13)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tab 3: Booking
// ══════════════════════════════════════════════════════════
class _BookingTab extends StatefulWidget {
  const _BookingTab();

  @override
  State<_BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<_BookingTab> {
  late List<Map<String, dynamic>> _requests;

  @override
  void initState() {
    super.initState();
    _requests = mockBookings
        .map((b) => {
              'id': b.id,
              'shop': b.shopName,
              'stall': b.stallNumber,
              'zone': b.zone,
              'type': b.type,
              'date': b.date,
              'status': b.status,
              'phone': b.vendorPhone,
              'email': b.vendorEmail,
            })
        .toList();
  }

  void _updateStatus(int index, String status) =>
      setState(() => _requests[index]['status'] = status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text('การจองแผง',
            style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8CBC63),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = _requests[i];
          final isPending = r['status'] == 'pending';
          final isApproved = r['status'] == 'approved';

          Color statusColor;
          String statusText;
          Color statusBg;

          if (isPending) {
            statusColor = const Color(0xFFB45309);
            statusBg = const Color(0xFFFFF3CD);
            statusText = 'รออนุมัติ';
          } else if (isApproved) {
            statusColor = const Color(0xFF0F7A36);
            statusBg = const Color(0xFFDFF7E6);
            statusText = 'อนุมัติแล้ว';
          } else {
            statusColor = const Color(0xFFB91C1C);
            statusBg = const Color(0xFFFEE2E2);
            statusText = 'ปฏิเสธแล้ว';
          }

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF8CBC63),
                      child: Icon(Icons.store, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['shop']!,
                              style: GoogleFonts.kanit(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('แผง ${r['stall']} ${r['zone']} • ${r['type']}',
                              style: GoogleFonts.kanit(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(statusText,
                          style: GoogleFonts.kanit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(r['date']!,
                        style: GoogleFonts.kanit(
                            fontSize: 12, color: const Color(0xFF9CA3AF))),
                    const SizedBox(width: 12),
                    const Icon(Icons.phone, size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(r['phone']!,
                        style: GoogleFonts.kanit(
                            fontSize: 12, color: const Color(0xFF9CA3AF))),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _updateStatus(i, 'rejected'),
                          child: Text('ปฏิเสธ',
                              style: GoogleFonts.kanit(
                                  color: const Color(0xFFEF4444))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8CBC63),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _updateStatus(i, 'approved'),
                          child: Text('อนุมัติ', style: GoogleFonts.kanit()),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tab 4: Vendor (ตัดส่วน Score ออกแล้ว)
// ══════════════════════════════════════════════════════════
class _VendorTab extends StatelessWidget {
  const _VendorTab();

  static const _vendors = [
    {'name': 'ร้านอาชียะ', 'type': 'อาหาร', 'stall': 'B01'},
    {'name': 'ร้านมานี', 'type': 'เสื้อผ้า', 'stall': 'A03'},
    {'name': 'ร้านสมชาย', 'type': 'มือสอง', 'stall': 'C02'},
    {'name': 'ร้านวิไล', 'type': 'ของใช้', 'stall': 'D05'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text('ร้านค้าในตลาด',
            style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8CBC63),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _vendors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final v = _vendors[i];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                // ── Avatar ──
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CBC63).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF8CBC63), width: 2),
                  ),
                  child: const Center(
                    child:
                        Icon(Icons.store, color: Color(0xFF8CBC63), size: 24),
                  ),
                ),
                const SizedBox(width: 14),

                // ── ชื่อร้าน / ประเภท / แผง ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v['name'] as String,
                          style: GoogleFonts.kanit(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${v['type']} • แผง ${v['stall']}',
                          style: GoogleFonts.kanit(
                              color: const Color(0xFF6B7280), fontSize: 12)),
                    ],
                  ),
                ),

                // ── ปุ่ม Info ──
                IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: Color(0xFF6B7280), size: 20),
                  onPressed: () => _showDetail(context, v),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, Object> v) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v['name'] as String,
                style: GoogleFonts.kanit(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _infoRow('ประเภท', v['type'] as String),
            const SizedBox(height: 8),
            _infoRow('แผง', v['stall'] as String),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CBC63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('ปิด', style: GoogleFonts.kanit()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text('$label : ',
            style: GoogleFonts.kanit(
                color: const Color(0xFF6B7280), fontSize: 13)),
        Text(value,
            style:
                GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tab 5: Broadcast
// ══════════════════════════════════════════════════════════
class _BroadcastTab extends StatefulWidget {
  const _BroadcastTab();

  @override
  State<_BroadcastTab> createState() => _BroadcastTabState();
}

class _BroadcastTabState extends State<_BroadcastTab> {
  final _msgCtrl = TextEditingController();
  String _target = 'ทุกคนในตลาด';
  final _targets = ['ทุกคนในตลาด', 'ผู้เช่าวันนี้', 'เฉพาะโซน A', 'เฉพาะโซน B'];

  final List<Map<String, dynamic>> _broadcastHistory = [
    {
      'message': 'วันนี้ตลาดปิดเวลา 22:00 น.',
      'target': 'ทุกคนในตลาด',
      'time': 'เมื่อกี้'
    },
    {
      'message': 'พรุ่งนี้มีการซ่อมแซมระบบไฟ',
      'target': 'เฉพาะโซน A',
      'time': 'เมื่อวาน'
    },
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text('ส่งประกาศ',
            style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8CBC63),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('ส่งถึง',
              style: GoogleFonts.kanit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: const Color(0xFF374151))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _target,
                isExpanded: true,
                style: GoogleFonts.kanit(),
                items: _targets
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text(t, style: GoogleFonts.kanit())))
                    .toList(),
                onChanged: (v) => setState(() => _target = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('ข้อความ',
              style: GoogleFonts.kanit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: const Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: _msgCtrl,
            maxLines: 5,
            style: GoogleFonts.kanit(),
            decoration: InputDecoration(
              hintText: 'พิมพ์ข้อความประกาศ...',
              hintStyle: GoogleFonts.kanit(color: const Color(0xFFBDBDBD)),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF8CBC63), width: 1.5)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.send),
              label: Text('ส่งประกาศ',
                  style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () {
                if (_msgCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('กรุณากรอกข้อความ', style: GoogleFonts.kanit()),
                    backgroundColor: const Color(0xFFEF4444),
                  ));
                  return;
                }
                setState(() {
                  _broadcastHistory.insert(0, {
                    'message': _msgCtrl.text.trim(),
                    'target': _target,
                    'time': 'เมื่อกี้',
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('ส่งประกาศถึง "$_target" แล้ว',
                      style: GoogleFonts.kanit()),
                  backgroundColor: const Color(0xFF8CBC63),
                ));
                _msgCtrl.clear();
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('ประกาศล่าสุด',
              style: GoogleFonts.kanit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: const Color(0xFF374151))),
          const SizedBox(height: 8),
          ..._broadcastHistory.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8CBC63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(b['target'],
                              style: GoogleFonts.kanit(
                                  fontSize: 10,
                                  color: const Color(0xFF4A7C3F))),
                        ),
                        Text(b['time'],
                            style: GoogleFonts.kanit(
                                fontSize: 11, color: const Color(0xFF9CA3AF))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(b['message'],
                        style: GoogleFonts.kanit(
                            color: const Color(0xFF374151), fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
