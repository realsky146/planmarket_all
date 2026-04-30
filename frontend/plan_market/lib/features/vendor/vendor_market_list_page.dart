import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/vendor/vendor_shop_info_page.dart';
import 'vendor_home.dart';
import 'favorite_vendor_page.dart';
import 'profile_vendor_page.dart';
import 'vendor_booking_page.dart';

class VendorMarketListPage extends StatefulWidget {
  const VendorMarketListPage({super.key});

  @override
  State<VendorMarketListPage> createState() => _VendorMarketListPageState();
}

class _VendorMarketListPageState extends State<VendorMarketListPage> {
  int currentIndex = 1;
  String _selectedFilter = 'แนะนำ';
  final _searchCtrl = TextEditingController();
  String _searchText = '';

  final _filters = ['แนะนำ', 'ใกล้ฉัน', 'คนเยอะ', 'ราคาถูก', 'เปิดอยู่'];

  // 🔌 Mock ตลาด (ดึงจาก API ทีหลัง)
  final List<Map<String, dynamic>> _markets = [
    {
      'id': 'm001',
      'name': 'ตลาดจตุจักร (โซนกลางคืน)',
      'distance': '1.2 กม.',
      'location': 'จตุจักร กรุงเทพฯ',
      'time': '17:00 - 23:00 น.',
      'isOpen': true,
      'tags': ['อาหาร', 'แฟชั่น', 'มือสอง'],
      'stallsAvailable': 12,
      'totalStalls': 120,
      'pricePerDay': 300,
      'traffic': 'สูง',
      'rating': 4.8,
      'isFavorite': true,
      'reason': 'ใกล้คุณที่สุด',
      'image':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
    },
    {
      'id': 'm002',
      'name': 'ตลาดนัดรถไฟ',
      'distance': '4.2 กม.',
      'location': 'รามอินทรา กรุงเทพฯ',
      'time': '18:00 - 23:00 น.',
      'isOpen': true,
      'tags': ['อาหาร', 'แฟชั่น', 'มือสอง'],
      'stallsAvailable': 25,
      'totalStalls': 200,
      'pricePerDay': 250,
      'traffic': 'สูงมาก',
      'rating': 4.9,
      'isFavorite': false,
      'reason': 'คนเดินเยอะที่สุด',
      'image':
          'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=400',
    },
    {
      'id': 'm003',
      'name': 'ตลาดเซฟวันโก',
      'distance': '7.2 กม.',
      'location': 'สวนหลวง กรุงเทพฯ',
      'time': '17:00 - 23:00 น.',
      'isOpen': false,
      'tags': ['อาหาร', 'ของใช้'],
      'stallsAvailable': 40,
      'totalStalls': 150,
      'pricePerDay': 200,
      'traffic': 'ปานกลาง',
      'rating': 4.5,
      'isFavorite': false,
      'reason': 'แผงว่างเยอะ',
      'image':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
    },
    {
      'id': 'm004',
      'name': 'ตลาดนัดสวนหลวง',
      'distance': '3.5 กม.',
      'location': 'พระราม 4 กรุงเทพฯ',
      'time': '16:00 - 22:00 น.',
      'isOpen': true,
      'tags': ['อาหาร', 'เสื้อผ้า'],
      'stallsAvailable': 8,
      'totalStalls': 80,
      'pricePerDay': 180,
      'traffic': 'สูง',
      'rating': 4.6,
      'isFavorite': false,
      'reason': 'ราคาถูกที่สุด',
      'image':
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400',
    },
  ];

  // ── Filter ────────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredMarkets {
    var list = List<Map<String, dynamic>>.from(_markets);

    // Search
    if (_searchText.isNotEmpty) {
      list = list
          .where((m) =>
              m['name'].toString().toLowerCase().contains(
                    _searchText.toLowerCase(),
                  ) ||
              m['location'].toString().toLowerCase().contains(
                    _searchText.toLowerCase(),
                  ))
          .toList();
    }

    // Filter
    switch (_selectedFilter) {
      case 'ใกล้ฉัน':
        list.sort((a, b) {
          final da =
              double.parse((a['distance'] as String).replaceAll(' กม.', ''));
          final db =
              double.parse((b['distance'] as String).replaceAll(' กม.', ''));
          return da.compareTo(db);
        });
        break;
      case 'คนเยอะ':
        final order = ['สูงมาก', 'สูง', 'ปานกลาง', 'ต่ำ'];
        list.sort((a, b) => order
            .indexOf(a['traffic'] as String)
            .compareTo(order.indexOf(b['traffic'] as String)));
        break;
      case 'ราคาถูก':
        list.sort((a, b) =>
            (a['pricePerDay'] as int).compareTo(b['pricePerDay'] as int));
        break;
      case 'เปิดอยู่':
        list = list.where((m) => m['isOpen'] == true).toList();
        break;
    }
    return list;
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
        case 2:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const VendorHome()));
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════
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
                height: 160,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),

              Column(
                children: [
                  // ── Header ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🏪 ตลาดแนะนำสำหรับคุณ',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ── Search Bar ─────────────────────
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchText = v),
                          style: GoogleFonts.kanit(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'ค้นหาตลาด / เขต...',
                            hintStyle: GoogleFonts.kanit(
                                color: const Color(0xFF9CA3AF)),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF9CA3AF), size: 20),
                            suffixIcon: _searchText.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      setState(() => _searchText = '');
                                    },
                                    child: const Icon(Icons.close,
                                        color: Color(0xFF9CA3AF), size: 18),
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Filter Chips ─────────────────────────
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final f = _filters[i];
                        final selected = _selectedFilter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF6E9B4C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF6E9B4C)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              f,
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Market List ──────────────────────────
                  Expanded(
                    child: _filteredMarkets.isEmpty
                        ? Center(
                            child: Text(
                              'ไม่พบตลาดที่ค้นหา',
                              style: GoogleFonts.kanit(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: _filteredMarkets.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) =>
                                _buildMarketCard(_filteredMarkets[i]),
                          ),
                  ),
                ],
              ),

              // Bottom Nav
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

  // ══════════════════════════════════════════════════════
  // Market Card
  // ══════════════════════════════════════════════════════
  Widget _buildMarketCard(Map<String, dynamic> m) {
    final isOpen = m['isOpen'] as bool;
    final tags = m['tags'] as List<String>;
    final available = m['stallsAvailable'] as int;
    final total = m['totalStalls'] as int;
    final traffic = m['traffic'] as String;
    final isFavorite = m['isFavorite'] as bool;
    final rating = m['rating'] as double;

    Color trafficColor;
    switch (traffic) {
      case 'สูงมาก':
        trafficColor = const Color(0xFFEF4444);
        break;
      case 'สูง':
        trafficColor = const Color(0xFFFFB000);
        break;
      default:
        trafficColor = const Color(0xFF22C55E);
    }

    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ รูปตลาดจาก Network
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              m['image'] ?? '',
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, p) {
                                if (p == null) return child;
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF8CBC63),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.storefront,
                                    color: Color(0xFF9CA3AF), size: 36),
                              ),
                            ),
                          ),
                        ),
                        // ✅ Badge เปิด/ปิด
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ชื่อ + ถูกใจ
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  m['name'] as String,
                                  style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                    () => m['isFavorite'] = !isFavorite),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // ระยะทาง + เวลา
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 2),
                              Text(
                                '${m['distance']}',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.access_time,
                                  size: 12, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  m['time'] as String,
                                  style: GoogleFonts.kanit(
                                    fontSize: 11,
                                    color: const Color(0xFF6B7280),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Stats: แผงว่าง + Traffic + Rating
                          Row(
                            children: [
                              _miniStat(
                                Icons.grid_view,
                                'ว่าง $available/$total',
                                const Color(0xFF2D9CDB),
                              ),
                              const SizedBox(width: 8),
                              _miniStat(
                                Icons.people,
                                'คน: $traffic',
                                trafficColor,
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.star_rounded,
                                  size: 12, color: Color(0xFFFFB000)),
                              Text(
                                ' $rating',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Tags + ราคา
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1A8),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    t,
                                    style: GoogleFonts.kanit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    // ราคา
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8CBC63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '฿${m['pricePerDay']}/วัน',
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6E9B4C),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── เหตุผลแนะนำ + ปุ่มจอง ──────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                // เหตุผล
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E9B4C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF6E9B4C).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 13, color: Color(0xFF6E9B4C)),
                      const SizedBox(width: 5),
                      Text(
                        m['reason'] as String,
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: const Color(0xFF6E9B4C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ✅ ปุ่มจองแผง → ส่ง market data ครบ
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        available > 0 ? const Color(0xFF8CBC63) : Colors.grey,
                    foregroundColor:
                        available > 0 ? Colors.white : const Color(0xFF9CA3AF),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: available > 0
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendorBookingPage(
                                // ✅ ส่งข้อมูลตลาดครบ
                                market: m,
                                marketId: m['id'] as String,
                                marketName: m['name'] as String,
                              ),
                            ),
                          )
                      : null,
                  child: Text(
                    available > 0 ? 'จองแผง' : 'เต็มแล้ว',
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.kanit(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // Bottom Nav
  // ══════════════════════════════════════════════════════
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
                            color: Colors.white
                                .withOpacity(isSelected ? 0.0 : 0.8),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
