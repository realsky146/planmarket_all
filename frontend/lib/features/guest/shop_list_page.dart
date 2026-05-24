import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'market_list_page.dart';
import 'profile_page.dart';
import '../auth/select_role_page.dart';
import '../../services/api_service.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});
  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  int currentIndex = 3;
  String? _userRole;
  int? _userId;
  bool _isLoading = true;
  String _searchText = '';
  String _selectedCategory = 'ทั้งหมด';
  List<Map<String, dynamic>> _shops = [];

  final List<String> _categories = [
    'ทั้งหมด', 'อาหาร', 'เครื่องดื่ม', 'เสื้อผ้า', 'ขนมหวาน', 'ของสด', 'อื่นๆ',
  ];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('role');
    _userId = int.tryParse(prefs.getString('userId') ?? '');
    await _loadShops();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadShops() async {
    final result = await ApiService.getSellers();
    debugPrint('getSellers result: ' + result['success'].toString() + ' data: ' + ((result['data'] as List?)?.length ?? 0).toString());
    if (!result['success']) return;
    final raw = result['data'] as List<dynamic>;

    Set<dynamic> favIds = {};
    if (_userId != null) {
      final favResult = await ApiService.getFavorites(_userId!);
      if (favResult['success'] == true) {
        final favList = favResult['data'] as List<dynamic>;
        favIds = favList.map((f) => f['seller_id']).toSet();
      }
    }

    final shops = raw.map((s) {
      return {
        'id': s['id'],
        'shopName': s['shop_name'] ?? s['name'] ?? '-',
        'category': 'ร้านค้า',
        'image': s['image_url'],
        'isOpen': s['status'] == 'approved',
        'rating': 4.5,
        'reviewCount': 0,
        'openDays': '-',
        'openTime': '-',
        'marketName': s['market_name'] ?? '-',
        'distance': '-',
        'rentalPeriod': '-',
        'rentalStart': '-',
        'rentalEnd': '-',
        'menu': <String>[],
        'description': '',
        'schedule': <Map<String, dynamic>>[],
        'tags': <String>[],
        'isFavorite': favIds.contains(s['id']),
        'priceRange': '฿',
      };
    }).toList();

    if (mounted) setState(() => _shops = shops);
  }

  List<Map<String, dynamic>> get _filteredShops {
    return _shops.where((shop) {
      final matchSearch =
          shop['shopName'].toString().toLowerCase().contains(_searchText.toLowerCase()) ||
          shop['category'].toString().toLowerCase().contains(_searchText.toLowerCase()) ||
          shop['marketName'].toString().toLowerCase().contains(_searchText.toLowerCase());
      final matchCategory = _selectedCategory == 'ทั้งหมด' ||
          shop['category'].toString().contains(_selectedCategory) ||
          (shop['tags'] as List).contains(_selectedCategory);
      return matchSearch && matchCategory;
    }).toList();
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
      await ApiService.removeFavorite(_userId!, sellerId);
    } else {
      await ApiService.addFavorite(userId: _userId!, marketId: sellerId);
    }
    setState(() => shop['isFavorite'] = !isFav);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isFav ? 'เพิ่มในรายการถูกใจแล้ว' : 'นำออกจากรายการถูกใจแล้ว',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: !isFav ? const Color(0xFF8CBC63) : Colors.grey,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showLoginRequiredDialog() {
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
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text('บันทึกร้านที่ถูกใจ',
                        style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Save Your Favorites',
                        style: GoogleFonts.kanit(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildBenefit(Icons.favorite_rounded, 'บันทึกร้านที่ถูกใจ'),
                    _buildBenefit(Icons.notifications_rounded, 'รับแจ้งเตือนเมื่อร้านเปิด'),
                    _buildBenefit(Icons.history_rounded, 'ดูประวัติร้านที่เคยเยี่ยมชม'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text('ข้ามไปก่อน',
                                style: GoogleFonts.kanit(color: const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8CBC63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) => const SelectRolePage()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_add_rounded, size: 18),
                                const SizedBox(width: 6),
                                Text('ลงทะเบียน',
                                    style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
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

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8CBC63), size: 18),
          ),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF374151))),
        ],
      ),
    );
  }

  void _showShopDetailDialog(Map<String, dynamic> shop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8CBC63).withOpacity(0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CBC63),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                      ),
                      Text('รายละเอียดร้านค้า',
                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          if (_userRole == null) {
                            Navigator.pop(context);
                            _showLoginRequiredDialog();
                            return;
                          }
                          await _toggleFavorite(shop);
                          setDialogState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            shop['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                            color: shop['isFavorite'] == true ? Colors.red : Colors.white,
                            size: 22,
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF8CBC63).withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                                child: SizedBox(
                                  height: 180,
                                  width: double.infinity,
                                  child: Image.network(
                                    shop['image'] ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      color: const Color(0xFF8CBC63).withOpacity(0.3),
                                      child: const Center(
                                        child: Icon(Icons.storefront_rounded, color: Colors.white70, size: 60),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(shop['shopName'] ?? '-',
                                        style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                                    const SizedBox(height: 8),
                                    _buildDetailRow(Icons.access_time_rounded, 'เวลาเปิด', shop['openTime'] ?? '-'),
                                    _buildDetailRow(Icons.calendar_today_rounded, 'วันที่เปิด', shop['openDays'] ?? '-'),
                                    _buildDetailRow(Icons.location_on_rounded, 'ตลาดหลัก', shop['marketName'] ?? '-'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: shop['isFavorite'] == true
                                        ? Colors.redAccent : const Color(0xFF8CBC63),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                  onPressed: () async {
                                    if (_userRole == null) {
                                      Navigator.pop(context);
                                      _showLoginRequiredDialog();
                                      return;
                                    }
                                    await _toggleFavorite(shop);
                                    setDialogState(() {});
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(shop['isFavorite'] == true
                                          ? Icons.heart_broken_rounded : Icons.favorite_rounded, size: 18),
                                      const SizedBox(width: 6),
                                      Text(shop['isFavorite'] == true ? 'ลบออก' : 'ถูกใจ',
                                          style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('ปิด',
                                      style: GoogleFonts.kanit(color: Colors.grey, fontWeight: FontWeight.w600)),
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6E9B4C), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                Text(value, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    if (!mounted) return;
    if (role == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SelectRolePage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GuestProfilePage()));
    }
  }

  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoritePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MarketListPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 3:
        break;
      case 4:
        _navigateToProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEEEEE),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8CBC63))),
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
                height: 160,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ร้านค้าทั้งหมด',
                            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${_filteredShops.length} ร้าน',
                              style: GoogleFonts.kanit(fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchText = v),
                      style: GoogleFonts.kanit(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'ค้นหาร้านค้า / ประเภท / ตลาด...',
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
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6E9B4C) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6E9B4C) : Colors.grey,
                              ),
                            ),
                            child: Text(cat,
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _filteredShops.isEmpty
                        ? Center(child: Text('ไม่พบร้านค้าที่ค้นหา', style: GoogleFonts.kanit(color: Colors.grey)))
                        : RefreshIndicator(
                            color: const Color(0xFF8CBC63),
                            onRefresh: _loadShops,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: _filteredShops.length,
                              itemBuilder: (_, i) => _buildShopCard(_filteredShops[i]),
                            ),
                          ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return GestureDetector(
      onTap: () => _showShopDetailDialog(shop),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 100, height: 100,
                child: Image.network(
                  shop['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF6E9B4C), Color(0xFF8CBC63)]),
                    ),
                    child: const Center(child: Icon(Icons.storefront_rounded, color: Colors.white70, size: 36)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(shop['shopName'] ?? '-',
                              style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1F2937)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        GestureDetector(
                          onTap: () => _toggleFavorite(shop),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: shop['isFavorite'] == true
                                  ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              shop['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                              color: shop['isFavorite'] == true ? Colors.redAccent : Colors.grey,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(shop['category'] ?? '-',
                        style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF6E9B4C), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text('${shop['marketName']} • ${shop['distance']}',
                              style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Spacer(),
                        _buildStatusBadge(shop['isOpen'] ?? false),
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
          Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(isOpen ? 'เปิด' : 'ปิด',
              style: GoogleFonts.kanit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
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
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF8CBC63),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
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
                              color: Colors.white.withOpacity(isSelected ? 0.0 : 0.8), size: 22),
                          const SizedBox(height: 4),
                          Text(items[i]['label'] as String,
                              style: GoogleFonts.kanit(fontSize: 10, color: Colors.white.withOpacity(isSelected ? 0.0 : 0.8))),
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
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E9B4C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Icon(items[currentIndex]['icon'] as IconData, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 4),
                Text(items[currentIndex]['label'] as String,
                    style: GoogleFonts.kanit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
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
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.98, size.width * 0.52, size.height * 0.56)
      ..quadraticBezierTo(size.width * 0.72, size.height * 1.02, size.width, size.height * 0.72)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}