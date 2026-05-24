import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/vendor/vendor_shop_info_page.dart';
import 'vendor_home.dart';
import 'favorite_vendor_page.dart';
import 'profile_vendor_page.dart';
import '../../services/api_service.dart'; // ⭐ เปลี่ยนมาใช้ ApiService โดยตรง
import 'stall_selection_page.dart';

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
  bool _isLoading = true;
  final _filters = ['แนะนำ', 'ใกล้ฉัน', 'คนเยอะ', 'ราคาถูก', 'เปิดอยู่'];
  List<Map<String, dynamic>> _markets = [];

  @override
  void initState() {
    super.initState();
    _loadMarkets();
  }

  // ⭐ แก้ไข _loadMarkets() ให้ดึงข้อมูลจาก API จริง
  Future<void> _loadMarkets() async {
    setState(() => _isLoading = true);
    try {
      // ⭐ ใช้ ApiService.getMarkets() แทน VendorService
      final result = await ApiService.getMarkets();
      if (!mounted) return;

      if (result['success'] != true) {
        setState(() => _markets = []);
        return;
      }

      final raw = result['data'] as List<dynamic>;

      setState(() {
        _markets = raw.map((m) {
          // ⭐ ดึงข้อมูลจาก API ให้ครบ
          final totalStalls = m['total_stalls'] ?? 0;
          final availableStalls = m['available_stalls'] ?? 1;

          return {
            'id': m['id']?.toString() ?? '',
            'name': m['name'] ?? '',
            'distance': '0.0 กม.',
            'location': m['location'] ?? m['description'] ?? '',
            'time':
                '${m['open_time'] ?? '08:00'} - ${m['close_time'] ?? '20:00'}',
            'isOpen': true,
            'tags': <String>[],
            'stallsAvailable': availableStalls,
            'totalStalls': totalStalls,
            'pricePerDay': m['price_per_day'] ?? 0,
            'traffic': 'ปานกลาง',
            'rating': double.tryParse(m['rating']?.toString() ?? '4.0') ?? 4.0,
            'isFavorite': false,
            'reason': 'แนะนำสำหรับคุณ',
            // ⭐ ดึงรูปภาพจาก API
            'image': m['image_url'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('❌ Error loading markets: $e');
      if (!mounted) return;
      setState(() => _markets = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Filter ────────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredMarkets {
    var list = List<Map<String, dynamic>>.from(_markets);

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

    switch (_selectedFilter) {
      case 'ใกล้ฉัน':
        list.sort((a, b) {
          final da = double.tryParse(
                  (a['distance'] as String).replaceAll(' กม.', '')) ??
              0;
          final db = double.tryParse(
                  (b['distance'] as String).replaceAll(' กม.', '')) ??
              0;
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
              context, MaterialPageRoute(builder: (_) => VendorHome()));
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
                height: 160,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                children: [
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
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF8CBC63)))
                        : _filteredMarkets.isEmpty
                            ? Center(
                                child: Text(
                                  'ไม่พบตลาดที่ค้นหา',
                                  style: GoogleFonts.kanit(color: Colors.grey),
                                ),
                              )
                            : RefreshIndicator(
                                color: const Color(0xFF8CBC63),
                                onRefresh: _loadMarkets,
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 100),
                                  itemCount: _filteredMarkets.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) =>
                                      _buildMarketCard(_filteredMarkets[i]),
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

  Widget _buildMarketCard(Map<String, dynamic> m) {
    final isOpen = m['isOpen'] as bool;
    final tags = (m['tags'] as List).cast<String>();
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
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 2),
                              Text(
                                m['distance'] as String,
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
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
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
                // ⭐ แก้ปุ่มจองให้ไปหน้า StallSelectionPage
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
                  // ⭐ แก้ไขตรงนี้ - ไม่มี syntax error แล้ว
                  onPressed: available > 0
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StallSelectionPage(
                                market: m,
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
