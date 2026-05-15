import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/auth/select_role_page.dart';
import 'package:plan_market/features/guest/shop_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'favorite_page.dart';
import 'home_page.dart';
import 'market_detail_page.dart';


class MarketListPage extends StatefulWidget {
  const MarketListPage({super.key});
  @override
  State<MarketListPage> createState() => _MarketListPageState();
}

class _MarketListPageState extends State<MarketListPage> {
  int currentIndex = 1;
  String _searchText = '';
  String? _userRole;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _markets = [
    {
      'id': 'm001',
      'name': 'ตลาดจตุจักร (โซนกลางคืน)',
      'distance': '1.2 กม.',
      'location': 'จตุจักร กรุงเทพฯ',
      'openTime': '17:00 - 23:00',
      'isOpen': true,
      'rating': 4.8,
      'totalStalls': 120,
      'availableStalls': 45,
      'openShops': 75, // เพิ่ม key openShops เพื่อใช้แสดงผล
      'tags': ['อาหาร', 'แฟชั่น', 'มือสอง'],
      'isFavorite': false,
      'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
    },
    {
      'id': 'm002',
      'name': 'ตลาดนัดรถไฟ',
      'distance': '4.2 กม.',
      'location': 'รามอินทรา กรุงเทพฯ',
      'openTime': '18:00 - 23:00',
      'isOpen': true,
      'rating': 4.5,
      'totalStalls': 80,
      'availableStalls': 20,
      'openShops': 60,
      'tags': ['อาหาร', 'ของสด'],
      'isFavorite': true,
      'image': 'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=400',
    },
    {
      'id': 'm003',
      'name': 'ตลาดนัดสวนลุม',
      'distance': '6.5 กม.',
      'location': 'พระราม 4 กรุงเทพฯ',
      'openTime': '17:00 - 22:00',
      'isOpen': false,
      'rating': 4.3,
      'totalStalls': 60,
      'availableStalls': 0,
      'openShops': 0,
      'tags': ['ของสด', 'อาหาร'],
      'isFavorite': false,
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // ✅ โหลด role จาก SharedPreferences
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role');
      _isLoading = false;
    });
    // ✅ ถ้าไม่มี session → แสดง popup แนะนำลงทะเบียน
    if (_userRole == null && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showRegisterSuggestionDialog();
      });
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ Popup แนะนำลงทะเบียน
  // ══════════════════════════════════════════════════════════
  void _showRegisterSuggestionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
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
              // ── Header ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6E9B4C), Color(0xFF8CBC63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ค้นหาตลาดใกล้คุณ',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Discover Markets Near You',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Body ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Info Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9EB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF8CBC63).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF8CBC63),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ลงทะเบียนเพื่อเข้าถึงตลาดครบทุกแห่ง\nและรับสิทธิพิเศษมากมาย!',
                              style: GoogleFonts.kanit(
                                fontSize: 13,
                                color: const Color(0xFF374151),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Benefits
                    _buildBenefit(Icons.storefront_rounded, 'ดูตลาดครบทุกแห่งในกรุงเทพฯ'),
                    _buildBenefit(Icons.map_rounded, 'ดูแผนที่และเส้นทางไปตลาด'),
                    _buildBenefit(Icons.favorite_rounded, 'บันทึกตลาดและร้านที่ถูกใจ'),
                    _buildBenefit(Icons.notifications_rounded, 'รับแจ้งเตือนตลาดใหม่'),
                    const SizedBox(height: 20),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFD1D5DB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'ข้ามไปก่อน',
                                style: GoogleFonts.kanit(
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8CBC63),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SelectRolePage(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_add_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ลงทะเบียน',
                                    style: GoogleFonts.kanit(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8CBC63), size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.kanit(
              fontSize: 13,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Navigation
  // ══════════════════════════════════════════════════════════
  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const FavoritePage()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ShopListPage()));
        break;
      case 4:
        _navigateToProfile();
        break;
    }
  }

  Future<void> _navigateToProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    if (!mounted) return;
    if (role == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const SelectRolePage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const GuestProfilePage()));
    }
  }

  // ══════════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════════
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
          child: Stack(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Text(
                      'ตลาดทั้งหมด',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✅ แยก UI ตาม role
                  Expanded(
                    child: _userRole == null
                        ? _buildGuestView()
                        : _buildLoggedInView(),
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

  // ══════════════════════════════════════════════════════════
  // ✅ Guest View
  // ══════════════════════════════════════════════════════════
  Widget _buildGuestView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                const SizedBox(width: 10),
                Text(
                  'ค้นหาตลาด...',
                  style: GoogleFonts.kanit(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
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
                      Icons.storefront_rounded,
                      size: 40,
                      color: Color(0xFF8CBC63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่ได้เข้าสู่ระบบ',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ลงทะเบียนเพื่อดูตลาดทั้งหมด\nและค้นหาร้านค้าที่ถูกใจ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8CBC63),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => _showRegisterSuggestionDialog(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'ลงทะเบียนเพื่อดูตลาดทั้งหมด',
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8CBC63)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_rounded, color: Color(0xFF8CBC63), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'กลับหน้าหลัก',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF8CBC63),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // ✅ Logged In View
  // ══════════════════════════════════════════════════════════
  Widget _buildLoggedInView() {
    final filtered = _markets.where((m) {
      return m['name'].toString().contains(_searchText) ||
          m['location'].toString().contains(_searchText);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _searchText = v),
            style: GoogleFonts.kanit(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ค้นหาตลาด...',
              hintStyle: GoogleFonts.kanit(color: const Color(0xFFBDBDBD)),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'ไม่พบตลาดที่ค้นหา',
                    style: GoogleFonts.kanit(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildMarketCard(filtered[i]),
                ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // ✅ Market Card
  // ══════════════════════════════════════════════════════════
  Widget _buildMarketCard(Map<String, dynamic> market) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MarketDetailPage(market: market)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.network(
                  market['image'] ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
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
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            market['name'],
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              market['isFavorite'] = !market['isFavorite'];
                            }),
                            child: Icon(
                              market['isFavorite']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: market['isFavorite']
                                  ? Colors.redAccent
                                  : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '📍 ${market['location']} (${market['distance']})',
                      style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '🕐 ${market['openTime']}',
                      style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: market['isOpen']
                                ? const Color(0xFFDFF7E6)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'เปิดอยู่ ${market['openShops'] ?? 0}/${market['totalStalls']} ร้าน',
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: market['isOpen']
                                  ? const Color(0xFF0F7A36)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB000), size: 14),
                        Text(
                          ' ${market['rating']}',
                          style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Bottom Nav
  // ══════════════════════════════════════════════════════════
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
                            color: Colors.white.withOpacity(isSelected ? 0.0 : 0.8),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i]['label'] as String,
                            style: GoogleFonts.kanit(
                              fontSize: 10,
                              color: Colors.white.withOpacity(isSelected ? 0.0 : 0.8),
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
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(
          size.width * 0.18, size.height * 0.98, size.width * 0.52, size.height * 0.56)
      ..quadraticBezierTo(
          size.width * 0.72, size.height * 1.02, size.width, size.height * 0.72)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}