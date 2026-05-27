// lib/features/vendor/favorite_vendor_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_market/services/api_service.dart';
import 'package:plan_market/features/vendor/vendor_shop_info_page.dart';
import 'vendor_home.dart';
import 'vendor_market_list_page.dart';
import 'profile_vendor_page.dart';

class VendorFavoritePage extends StatefulWidget {
  const VendorFavoritePage({super.key});

  @override
  State<VendorFavoritePage> createState() => _VendorFavoritePageState();
}

class _VendorFavoritePageState extends State<VendorFavoritePage> {
  int currentIndex = 0;
  bool _isLoading = true;
  int? _userId;

  // ✅ เปลี่ยนเป็นเก็บตลาดที่ถูกใจ
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = int.tryParse(prefs.getString('userId') ?? '');
    if (_userId != null) {
      await _loadFavorites();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // ✅ โหลดตลาดที่ถูกใจจาก DB
  Future<void> _loadFavorites() async {
    if (_userId == null) return;

    final result = await ApiService.getMarketFavorites(_userId!);

    if (!result['success']) {
      if (mounted) setState(() => _favorites = []);
      return;
    }

    final raw = result['data'] as List<dynamic>;
    final favs = raw.map((e) {
      final m = e as Map<String, dynamic>;
      return {
        'id': m['market_id']?.toString() ?? '', // ใช้ market_id
        'name': m['name'] ?? '-', // ชื่อตลาด
        'category': 'ตลาด',
        'image': m['image_url'] ?? '',
        'isOpen': true, // default เปิด
        'location': m['location'] ?? '-', // ที่ตั้ง
        'isFavorite': true,
        'tags': <String>[],
        'type': 'market',
      };
    }).toList();

    if (mounted) setState(() => _favorites = favs);
  }

  // ✅ ลบตลาดออกจากถูกใจ → เรียก removeMarketFavorite
  Future<void> _removeFavorite(Map<String, dynamic> market) async {
    final marketId = int.tryParse(market['id']?.toString() ?? '') ?? 0;
    if (marketId == 0 || _userId == null) return;

    // Optimistic UI — เอาออกก่อน
    setState(() {
      _favorites.removeWhere((m) => m['id'] == market['id']);
    });

    final result = await ApiService.removeMarketFavorite(_userId!, marketId);

    if (!result['success']) {
      // Rollback ถ้า error
      setState(() => _favorites.add(market));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('เกิดข้อผิดพลาด กรุณาลองใหม่', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'นำตลาดออกจากรายการถูกใจแล้ว',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      switch (index) {
        case 0:
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => VendorMarketListPage()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => VendorHome()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VendorShopInfoPage()),
          );
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VendorProfilePage()),
          );
          break;
      }
    });
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
                height: 130,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => VendorHome()),
                              );
                            }
                          },
                        ),
                        // ✅ เปลี่ยน title
                        Text(
                          'ตลาดที่ถูกใจ',
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        if (_favorites.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              // ✅ เปลี่ยนเป็น "ตลาด"
                              '${_favorites.length} ตลาด',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── List ──
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF8CBC63)),
                          )
                        : _favorites.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                color: const Color(0xFF8CBC63),
                                onRefresh: _loadFavorites,
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                  itemCount: _favorites.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) =>
                                      _buildFavoriteCard(_favorites[i]),
                                ),
                              ),
                  ),
                ],
              ),

              // ── Bottom Nav ──
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 40,
              color: Color(0xFF8CBC63),
            ),
          ),
          const SizedBox(height: 16),
          // ✅ ข้อความ empty state ปรับเป็น "ตลาด"
          Text(
            'ยังไม่มีตลาดที่ถูกใจ',
            style: GoogleFonts.kanit(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'กดหัวใจที่การ์ดตลาดเพื่อบันทึก',
            style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8CBC63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => VendorMarketListPage()),
              );
            },
            icon: const Icon(Icons.search_rounded, size: 18),
            label: Text(
              'ค้นหาตลาด',
              style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Card สำหรับแสดงตลาด
  Widget _buildFavoriteCard(Map<String, dynamic> market) {
    final isOpen = market['isOpen'] as bool? ?? true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── รูปตลาด ──
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 110,
              height: 110,
              child: Image.network(
                market['image'] ?? '',
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF8CBC63),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF8CBC63).withOpacity(0.15),
                  child: const Center(
                    child: Icon(
                      Icons.storefront_rounded, // ✅ icon ตลาด
                      color: Color(0xFF8CBC63),
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── ข้อมูลตลาด ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อตลาด
                  Text(
                    market['name'] ?? '-',
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8CBC63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      market['category'] ?? 'ตลาด',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        color: const Color(0xFF6E9B4C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ที่ตั้ง
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          // ✅ ใช้ 'location' แทน 'marketName'
                          market['location'] ?? '-',
                          style: GoogleFonts.kanit(
                              fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(isOpen),
                ],
              ),
            ),
          ),

          // ── ปุ่มนำออก ──
          Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => _removeFavorite(market),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            isOpen ? 'เปิด' : 'ปิด',
            style: GoogleFonts.kanit(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
