import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/auth/select_role_page.dart';
import 'package:plan_market/features/guest/shop_list_page.dart';
import 'package:plan_market/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_page.dart';
import 'market_list_page.dart';
import 'market_detail_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2;
  String? _userRole;
  int? _userId;
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
    _userId = int.tryParse(prefs.getString('userId') ?? '');
    final futures = [_loadMarkets(), _loadRecommendedShops()];
    if (_userRole != null && _userId != null) {
      futures.add(_loadUserFavorites());
    }
    await Future.wait(futures);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMarkets() async {
    final result = await ApiService.getMarkets();
    if (!result['success']) {
      if (mounted) setState(() => _markets = []);
      return;
    }
    final raw = result['data'] as List<dynamic>;
    final markets = raw.map((e) {
      final m = e as Map<String, dynamic>;
      final openTime = m['open_time'] ?? '08:00';
      final closeTime = m['close_time'] ?? '20:00';
      return {
        'id': m['id'],
        'name': m['name'] ?? '',
        'location': m['location'] ?? '',
        'openTime': '$openTime - $closeTime',
        'isOpen': true,
        'totalStalls': m['total_stalls'] ?? 0,
        'availableStalls': m['available_stalls'] ?? 0,
        'tags': <String>[],
        'isFavorite': false,
        'image': m['image_url'],
        'eventCount': 0,
        'rating': m['rating'] ?? 4.0,
      };
    }).toList();
    if (mounted) setState(() => _markets = markets);
  }

  Future<void> _loadRecommendedShops() async {
    final result = await ApiService.getSellers();
    if (!result['success']) {
      if (mounted) setState(() => _recommendedShops = []);
      return;
    }
    final raw = result['data'] as List<dynamic>;
    final shops = raw.map((e) {
      final s = e as Map<String, dynamic>;
      return {
        'id': s['id'],
        'shopName': s['shop_name'] ?? s['name'] ?? '-',
        'category': 'ร้านค้า',
        'marketName': s['market_name'] ?? '-',
        'isOpen': s['is_open'] == 1,
        'image': s['image_url'] ?? '',
        'isFavorite': false,
        'tags': <String>[],
      };
    }).toList();
    if (mounted) setState(() => _recommendedShops = shops);
  }

  Future<void> _loadUserFavorites() async {
    final result = await ApiService.getFavorites(_userId!);
    if (!result['success']) {
      if (mounted) setState(() => _userFavorites = []);
      return;
    }
    final raw = result['data'] as List<dynamic>;
    final favs = raw.map((e) {
      final s = e as Map<String, dynamic>;
      return {
        'id': s['seller_id'],
        'shopName': s['shop_name'] ?? s['name'] ?? '-',
        'category': 'ร้านค้า',
        'marketName': s['market_name'] ?? '-',
        'isOpen': s['is_open'] == 1,
        'image': s['image_url'] ?? '',
        'isFavorite': true,
        'tags': <String>[],
      };
    }).toList();
    if (mounted) {
      setState(() {
        _userFavorites = favs;
        final favIds = favs.map((f) => f['id']).toSet();
        for (final s in _recommendedShops) {
          s['isFavorite'] = favIds.contains(s['id']);
        }
      });
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> shop) async {
    if (_userRole == null || _userId == null) {
      _showLoginRequiredDialog();
      return;
    }
    final sellerId = int.tryParse(shop['id']?.toString() ?? '') ?? 0;
    if (sellerId == 0) return;
    final isFav = shop['isFavorite'] == true;
    if (isFav) {
      await ApiService.removeFavorite(
          _userId!, int.tryParse(shop['id']?.toString() ?? '0') ?? 0);
    } else {
      await ApiService.addFavorite(userId: _userId!, marketId: sellerId);
    }
    setState(() {
      shop['isFavorite'] = !isFav;
      if (!isFav) {
        if (!_userFavorites.any((s) => s['id'] == shop['id'])) {
          _userFavorites.add(Map.from(shop));
        }
      } else {
        _userFavorites.removeWhere((s) => s['id'] == shop['id']);
      }
      for (final s in _recommendedShops) {
        if (s['id'] == shop['id']) s['isFavorite'] = !isFav;
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'หน้าหลัก',
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
                              _userRole == 'vendor' ? '🏪 ผู้ค้า' : '🛍 ลูกค้า',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
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
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF8CBC63),
                      onRefresh: _initPage,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        children: [
                          if (_userRole != null &&
                              _userFavorites.isNotEmpty) ...[
                            _buildUserFavoriteSection(),
                            const SizedBox(height: 20),
                          ],
                          _buildRecommendedShopsSection(),
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
            if (_userRole == null)
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
        if (_userRole == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9EB),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF8CBC63).withOpacity(0.3)),
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
                      if ((market['location'] ?? '').toString().isNotEmpty)
                        Text(
                          '📍 ${market['location']}',
                          style: GoogleFonts.kanit(
                              fontSize: 12, color: Colors.grey),
                        ),
                      Text(
                        '🕐 ${market['openTime'] ?? ''}',
                        style:
                            GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: ((market['tags'] as List?)?.cast<String>() ??
                                <String>[])
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
