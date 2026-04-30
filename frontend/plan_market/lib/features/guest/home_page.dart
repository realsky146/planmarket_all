import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/auth/select_role_page.dart';
import 'package:plan_market/features/guest/shop_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_page.dart';
import 'market_list_page.dart';
import 'market_detail_page.dart';
import 'profile_page.dart';

// ══════════════════════════════════════════════════════════
// 🔌 API Service
// ══════════════════════════════════════════════════════════
class HomeApiService {
  static const String baseUrl = 'https://api.planmarket.com/v1';

  static const _img1 =
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400';
  static const _img2 =
      'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=400';
  static const _img3 =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400';
  static const _img4 =
      'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400';
  static const _img5 =
      'https://images.unsplash.com/photo-1526367790999-0150786686a2?w=400';

  // 🔌 TODO: GET $baseUrl/markets?sort=nearest
  static Future<List<Map<String, dynamic>>> getRecommendedMarkets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'm001',
        'name': 'ตลาดจตุจักร (โซนกลางคืน)',
        'distance': '1.2 กม.',
        'location': 'จตุจักร กรุงเทพฯ',
        'openTime': '17:00 - 23:00',
        'isOpen': true,
        'totalStalls': 120,
        'availableStalls': 45,
        'tags': ['อาหาร', 'แฟชั่น', 'มือสอง'],
        'isFavorite': false,
        'image': _img1,
        'highlight': 'คนเยอะที่สุด',
        'eventCount': 3,
      },
      {
        'id': 'm002',
        'name': 'ตลาดนัดรถไฟ',
        'distance': '4.2 กม.',
        'location': 'รามอินทรา กรุงเทพฯ',
        'openTime': '18:00 - 23:00',
        'isOpen': true,
        'totalStalls': 80,
        'availableStalls': 20,
        'tags': ['วินเทจ', 'ของสะสม', 'อาหาร'],
        'isFavorite': false,
        'image': _img2,
        'highlight': 'มีงานพิเศษ',
        'eventCount': 1,
      },
      {
        'id': 'm003',
        'name': 'ตลาดเซฟวันโก',
        'distance': '7.2 กม.',
        'location': 'สวนหลวง กรุงเทพฯ',
        'openTime': '17:00 - 23:00',
        'isOpen': true,
        'totalStalls': 60,
        'availableStalls': 15,
        'tags': ['อาหาร', 'ของสด', 'ราคาถูก'],
        'isFavorite': false,
        'image': _img3,
        'highlight': 'ใกล้คุณ',
        'eventCount': 0,
      },
    ];
  }

  // 🔌 TODO: GET $baseUrl/shops?recommended=true
  static Future<List<Map<String, dynamic>>> getRecommendedShops() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 's001',
        'shopName': 'ร้านผัดไทยป้าแดง',
        'category': 'อาหารไทย',
        'marketName': 'ตลาดจตุจักร',
        'distance': '1.2 กม.',
        'isOpen': true,
        'image': _img3,
        'tags': ['อาหาร', 'ยอดนิยม'],
      },
      {
        'id': 's002',
        'shopName': 'ร้านส้มตำนางฟ้า',
        'category': 'อาหารอีสาน',
        'marketName': 'ตลาดนัดรถไฟ',
        'distance': '4.2 กม.',
        'isOpen': true,
        'image': _img4,
        'tags': ['อาหาร', 'เผ็ด'],
      },
      {
        'id': 's003',
        'shopName': 'ร้านของทะเลสดๆ',
        'category': 'อาหารทะเล',
        'marketName': 'ตลาดเซฟวันโก',
        'distance': '7.2 กม.',
        'isOpen': true,
        'image': _img5,
        'tags': ['ทะเล', 'สด'],
      },
      {
        'id': 's004',
        'shopName': 'โกโก้ในตำนาน',
        'category': 'เครื่องดื่ม',
        'marketName': 'ตลาดจตุจักร',
        'distance': '1.2 กม.',
        'isOpen': false,
        'image': _img1,
        'tags': ['เครื่องดื่ม', 'ของหวาน'],
      },
    ];
  }

  // 🔌 TODO: GET $baseUrl/favorites (Header: Authorization: Bearer <token>)
  static Future<List<Map<String, dynamic>>> getUserFavorites(
      String token) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 's001',
        'shopName': 'ร้านผัดไทยป้าแดง',
        'category': 'อาหารไทย',
        'marketName': 'ตลาดจตุจักร',
        'distance': '1.2 กม.',
        'isOpen': true,
        'image': _img3,
        'tags': ['อาหาร', 'ยอดนิยม'],
      },
      {
        'id': 's002',
        'shopName': 'ร้านส้มตำนางฟ้า',
        'category': 'อาหารอีสาน',
        'marketName': 'ตลาดนัดรถไฟ',
        'distance': '4.2 กม.',
        'isOpen': true,
        'image': _img4,
        'tags': ['อาหาร', 'เผ็ด'],
      },
    ];
  }

  // 🔌 TODO: POST/DELETE $baseUrl/favorites/$shopId
  static Future<bool> toggleFavorite(
      String shopId, bool isFavorite, String token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return !isFavorite;
  }
}

// ══════════════════════════════════════════════════════════
// HomePage
// ══════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2;
  String? _userRole;
  String? _userToken;
  bool _isLoading = true;

  List<Map<String, dynamic>> _recommendedShops = [];
  List<Map<String, dynamic>> _userFavorites = [];
  List<Map<String, dynamic>> _markets = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('role');
    _userToken = prefs.getString('token');

    await Future.wait([
      _loadMarkets(),
      _userRole != null && _userToken != null
          ? _loadUserFavorites()
          : _loadRecommendedShops(),
    ]);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMarkets() async {
    final markets = await HomeApiService.getRecommendedMarkets();
    if (mounted) setState(() => _markets = markets);
  }

  Future<void> _loadRecommendedShops() async {
    final shops = await HomeApiService.getRecommendedShops();
    if (mounted) setState(() => _recommendedShops = shops);
  }

  Future<void> _loadUserFavorites() async {
    final favs = await HomeApiService.getUserFavorites(_userToken!);
    if (mounted) setState(() => _userFavorites = favs);
  }

  Future<void> _toggleFavorite(Map<String, dynamic> shop) async {
    if (_userRole == null) {
      _showLoginRequiredDialog();
      return;
    }
    final newState = await HomeApiService.toggleFavorite(
      shop['id'],
      shop['isFavorite'] ?? false,
      _userToken ?? '',
    );
    setState(() {
      shop['isFavorite'] = newState;
      if (newState) {
        _userFavorites.add(shop);
      } else {
        _userFavorites.removeWhere((s) => s['id'] == shop['id']);
      }
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
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
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'บันทึกร้านที่ถูกใจ',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'เข้าสู่ระบบเพื่อบันทึกร้านที่ถูกใจ\nและดูได้ทุกครั้งที่เข้าใช้งาน',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text('ข้ามไปก่อน',
                                style: GoogleFonts.kanit(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8CBC63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SelectRolePage()),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_add_rounded, size: 18),
                                const SizedBox(width: 6),
                                Text('เข้าสู่ระบบ',
                                    style: GoogleFonts.kanit(
                                        fontWeight: FontWeight.bold)),
                              ],
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MarketListPage()));
        break;
      case 2:
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
                height: 180,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'หน้าแรก',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (_userRole != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _userRole == 'vendor' ? ' ผู้ค้า' : ' ลูกค้า',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ── Search Bar ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MarketListPage()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: Color(0xFF9CA3AF), size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'ค้นหาตลาด/เขต/ชื่อร้าน',
                              style: GoogleFonts.kanit(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ── Content ──────────────────────────────
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF8CBC63),
                      onRefresh: _initPage,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        children: [
                          _userRole != null
                              ? _buildUserFavoriteSection()
                              : _buildRecommendedShopsSection(),
                          const SizedBox(height: 20),
                          _buildRecommendedMarketsSection(),
                        ],
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

  // ══════════════════════════════════════════════════════════
  // Section ร้านแนะนำ (Guest)
  // ══════════════════════════════════════════════════════════
  Widget _buildRecommendedShopsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ร้านแนะนำใกล้คุณ',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                ),
                Text(
                  'Recommended Shops',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SelectRolePage()),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF8CBC63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF8CBC63).withOpacity(0.4)),
                ),
                child: Text(
                  '+ ลงทะเบียน',
                  style: GoogleFonts.kanit(
                    fontSize: 12,
                    color: const Color(0xFF8CBC63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9EB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8CBC63).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF8CBC63), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ลงทะเบียนเพื่อบันทึกร้านที่ถูกใจและดูได้ทุกครั้ง',
                  style: GoogleFonts.kanit(
                    fontSize: 12,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedShops.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              if (i == _recommendedShops.length) {
                return _buildViewMoreButton();
              }
              return _buildRecommendedShopCard(_recommendedShops[i]);
            },
          ),
        ),
      ],
    );
  }

  // ── Recommended Shop Card ────────────────────────────────
  Widget _buildRecommendedShopCard(Map<String, dynamic> shop) {
    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: Image.network(
                    shop['image'] ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF8CBC63)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.storefront_rounded,
                            color: Colors.white70, size: 36),
                      ),
                    ),
                  ),
                ),
              ),
              if (shop['highlight'] != null)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shop['highlight'],
                      style:
                          GoogleFonts.kanit(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(shop),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      shop['isFavorite'] == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: shop['isFavorite'] == true
                          ? Colors.redAccent
                          : Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shop['shopName'],
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    shop['marketName'],
                    style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  _buildStatusBadge(shop['isOpen'] ?? false, small: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── View More Button ─────────────────────────────────────
  Widget _buildViewMoreButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MarketListPage()),
      ),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF8CBC63).withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF8CBC63).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Color(0xFF8CBC63), size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'ดูทั้งหมด',
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8CBC63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Section ร้านที่ถูกใจ (User ที่ Login แล้ว)
  // ══════════════════════════════════════════════════════════
  Widget _buildUserFavoriteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ร้านที่ถูกใจ',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                ),
                Text(
                  'My Favorites',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FavoritePage())),
              child: Text(
                'ดูทั้งหมด',
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  color: const Color(0xFF8CBC63),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_userFavorites.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite_border_rounded,
                    color: Color(0xFF8CBC63), size: 40),
                const SizedBox(height: 8),
                Text(
                  'ยังไม่มีร้านที่ถูกใจ',
                  style: GoogleFonts.kanit(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'กดหัวใจที่ร้านไหนก็ได้เพื่อบันทึก',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _userFavorites.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                if (i == _userFavorites.length) {
                  return _buildViewMoreButton();
                }
                return _buildUserFavoriteCard(_userFavorites[i]);
              },
            ),
          ),
      ],
    );
  }

  // ── User Favorite Card ───────────────────────────────────
  Widget _buildUserFavoriteCard(Map<String, dynamic> shop) {
    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: Image.network(
                    shop['image'] ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF8CBC63)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.storefront_rounded,
                            color: Colors.white70, size: 36),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(shop),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite,
                        color: Colors.redAccent, size: 16),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shop['shopName'],
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    shop['marketName'],
                    style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  _buildStatusBadge(shop['isOpen'] ?? false, small: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Section ตลาดแนะนำ
  // ══════════════════════════════════════════════════════════
  Widget _buildRecommendedMarketsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ตลาดแนะนำ',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                ),
                Text(
                  'Recommended Markets',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ใกล้ที่สุด  ',
                      style:
                          GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                  Text('Nearest',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF8CBC63),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._markets.map((market) => _buildMarketCard(market)),
      ],
    );
  }

  // ── Market Card ──────────────────────────────────────────
  Widget _buildMarketCard(Map<String, dynamic> market) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MarketDetailPage(market: market)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 120,
                  child: Image.network(
                    market['image'] ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF8CBC63)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.store_mall_directory_rounded,
                            color: Colors.white70, size: 44),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusBadge(market['isOpen'] ?? false),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if ((market['eventCount'] ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🎉 มีงาน ${market['eventCount']} งาน',
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ),
                      Text(
                        '📍 ${market['distance']}',
                        style:
                            GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '🕐 ${market['openTime']}',
                        style:
                            GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (market['tags'] as List<String>)
                            .take(3)
                            .map((tag) => _buildTag(tag))
                            .toList(),
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

  // ══════════════════════════════════════════════════════════
  // Reusable Widgets
  // ══════════════════════════════════════════════════════════
  Widget _buildStatusBadge(bool isOpen, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF8CBC63) : Colors.grey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 5 : 6,
            height: small ? 5 : 6,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(
            isOpen ? 'เปิดอยู่' : 'ปิดแล้ว',
            style: GoogleFonts.kanit(
              fontSize: small ? 9 : 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: GoogleFonts.kanit(
          fontSize: 11,
          color: const Color(0xFFB45309),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.favorite_rounded, 'label': 'ถูกใจ'},
      {'icon': Icons.storefront_rounded, 'label': 'ตลาด'},
      {'icon': Icons.home_rounded, 'label': 'หน้าหลัก'},
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
                          Icon(items[i]['icon'] as IconData,
                              color: Colors.white
                                  .withOpacity(isSelected ? 0.0 : 0.8),
                              size: 22),
                          const SizedBox(height: 4),
                          Text(items[i]['label'] as String,
                              style: GoogleFonts.kanit(
                                  fontSize: 10,
                                  color: Colors.white
                                      .withOpacity(isSelected ? 0.0 : 0.8))),
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
                  child: Icon(items[currentIndex]['icon'] as IconData,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 4),
                Text(items[currentIndex]['label'] as String,
                    style: GoogleFonts.kanit(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ],
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
class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8CBC63)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.25, size.height, size.width * 0.5, size.height * 0.85)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.7, size.width, size.height * 0.9)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
