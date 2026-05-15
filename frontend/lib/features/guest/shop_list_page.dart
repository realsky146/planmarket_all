import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'market_list_page.dart';
import 'profile_page.dart';
import '../auth/select_role_page.dart';

// ══════════════════════════════════════════════════════════
// 🔌 API Service
// ══════════════════════════════════════════════════════════
class ShopApiService {
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
  static const _img6 =
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400';
  static const _img7 =
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400';
  static const _img8 =
      'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400';

  // 🔌 TODO: GET $baseUrl/shops
  static Future<List<Map<String, dynamic>>> getShops() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'id': 's001',
        'shopName': 'โกโก้ในตำนาน',
        'category': 'เครื่องดื่ม',
        'image': _img1,
        'isOpen': true,
        'rating': 4.9,
        'reviewCount': 340,
        'openDays': 'ศุกร์ - อาทิตย์',
        'openTime': '18:00 - 23:00 น.',
        'marketName': 'ตลาดจตุจักร',
        'distance': '1.2 กม.',
        'rentalPeriod': '3 เดือน',
        'rentalStart': '1 ม.ค. 2568',
        'rentalEnd': '31 มี.ค. 2568',
        'menu': ['โกโก้เย็น', 'ชานม', 'ชาเขียว', 'น้ำผลไม้'],
        'description': 'เครื่องดื่มสูตรต้นตำรับ รสชาติเข้มข้น ถูกปากคนไทย',
        'schedule': [
          {
            'marketName': 'ตลาดจตุจักร',
            'day': 'ศุกร์ - อาทิตย์',
            'time': '18:00 - 23:00',
            'distance': '1.2 กม.',
          },
          {
            'marketName': 'ตลาดนัดรถไฟ',
            'day': 'เสาร์',
            'time': '17:00 - 22:00',
            'distance': '4.2 กม.',
          },
        ],
        'tags': ['เครื่องดื่ม', 'ของหวาน', 'ยอดนิยม'],
        'isFavorite': false,
        'priceRange': '฿',
      },
      {
        'id': 's002',
        'shopName': 'ร้านมาลีผัดไทย',
        'category': 'อาหารไทย',
        'image': _img3,
        'isOpen': true,
        'rating': 4.7,
        'reviewCount': 215,
        'openDays': 'เสาร์ - อาทิตย์',
        'openTime': '17:00 - 22:00 น.',
        'marketName': 'ตลาดนัดรถไฟ',
        'distance': '4.2 กม.',
        'rentalPeriod': '6 เดือน',
        'rentalStart': '1 ธ.ค. 2567',
        'rentalEnd': '31 พ.ค. 2568',
        'menu': ['ผัดไทย', 'ผัดซีอิ๊ว', 'ราดหน้า', 'ผัดคะน้า'],
        'description': 'ผัดไทยสูตรโบราณ เส้นนุ่ม ไข่สด รสชาติแบบต้นตำรับ',
        'schedule': [
          {
            'marketName': 'ตลาดนัดรถไฟ',
            'day': 'เสาร์ - อาทิตย์',
            'time': '17:00 - 22:00',
            'distance': '4.2 กม.',
          },
        ],
        'tags': ['อาหาร', 'ไทย', 'เส้น'],
        'isFavorite': false,
        'priceRange': '฿',
      },
      {
        'id': 's003',
        'shopName': 'ร้านแฟชั่นเกาหลี',
        'category': 'เสื้อผ้า',
        'image': _img4,
        'isOpen': false,
        'rating': 4.5,
        'reviewCount': 178,
        'openDays': 'ทุกวัน',
        'openTime': '16:00 - 22:00 น.',
        'marketName': 'ตลาดเซฟวันโก',
        'distance': '7.2 กม.',
        'rentalPeriod': '1 เดือน',
        'rentalStart': '15 ม.ค. 2568',
        'rentalEnd': '14 ก.พ. 2568',
        'menu': ['เสื้อผ้าเกาหลี', 'กระเป๋า', 'เครื่องประดับ', 'หมวก'],
        'description': 'แฟชั่นเกาหลีสไตล์ K-Pop อัพเดทใหม่ทุกสัปดาห์',
        'schedule': [
          {
            'marketName': 'ตลาดเซฟวันโก',
            'day': 'ทุกวัน',
            'time': '16:00 - 22:00',
            'distance': '7.2 กม.',
          },
          {
            'marketName': 'ตลาดสวนลุม',
            'day': 'เสาร์ - อาทิตย์',
            'time': '17:00 - 23:00',
            'distance': '5.1 กม.',
          },
        ],
        'tags': ['แฟชั่น', 'เกาหลี', 'เสื้อผ้า'],
        'isFavorite': false,
        'priceRange': '฿฿',
      },
      {
        'id': 's004',
        'shopName': 'ร้านของทะเลสดๆ',
        'category': 'อาหารทะเล',
        'image': _img5,
        'isOpen': true,
        'rating': 4.6,
        'reviewCount': 290,
        'openDays': 'พฤหัส - อาทิตย์',
        'openTime': '17:00 - 23:00 น.',
        'marketName': 'ตลาดจตุจักร',
        'distance': '1.2 กม.',
        'rentalPeriod': '3 เดือน',
        'rentalStart': '1 ก.พ. 2568',
        'rentalEnd': '30 เม.ย. 2568',
        'menu': ['กุ้งย่าง', 'หอยนางรม', 'ปูนึ่ง', 'ปลาหมึกย่าง'],
        'description': 'อาหารทะเลสดจากทะเลทุกวัน ราคาเป็นกันเอง',
        'schedule': [
          {
            'marketName': 'ตลาดจตุจักร',
            'day': 'พฤหัส - อาทิตย์',
            'time': '17:00 - 23:00',
            'distance': '1.2 กม.',
          },
        ],
        'tags': ['ทะเล', 'สด', 'ย่าง'],
        'isFavorite': false,
        'priceRange': '฿฿',
      },
      {
        'id': 's005',
        'shopName': 'ขนมไทยป้าอ้อย',
        'category': 'ขนมหวาน',
        'image': _img8,
        'isOpen': true,
        'rating': 4.8,
        'reviewCount': 412,
        'openDays': 'เสาร์ - อาทิตย์',
        'openTime': '16:00 - 21:00 น.',
        'marketName': 'ตลาดปากเกร็ด',
        'distance': '12.0 กม.',
        'rentalPeriod': '6 เดือน',
        'rentalStart': '1 ม.ค. 2568',
        'rentalEnd': '30 มิ.ย. 2568',
        'menu': ['ทองหยิบ', 'ฝอยทอง', 'ขนมชั้น', 'วุ้นมะพร้าว'],
        'description': 'ขนมไทยโบราณ ทำสดทุกวัน ไม่ใส่สีไม่ใส่สารกันบูด',
        'schedule': [
          {
            'marketName': 'ตลาดปากเกร็ด',
            'day': 'เสาร์ - อาทิตย์',
            'time': '16:00 - 21:00',
            'distance': '12.0 กม.',
          },
          {
            'marketName': 'ตลาดนัดรถไฟ',
            'day': 'อาทิตย์',
            'time': '17:00 - 22:00',
            'distance': '4.2 กม.',
          },
        ],
        'tags': ['ขนมไทย', 'หวาน', 'โบราณ'],
        'isFavorite': false,
        'priceRange': '฿',
      },
      {
        'id': 's006',
        'shopName': 'Pizza & Pasta คุณพล',
        'category': 'อาหารตะวันตก',
        'image': _img6,
        'isOpen': false,
        'rating': 4.4,
        'reviewCount': 156,
        'openDays': 'ศุกร์ - อาทิตย์',
        'openTime': '18:00 - 23:00 น.',
        'marketName': 'ตลาดสวนลุมไนท์บาซาร์',
        'distance': '3.5 กม.',
        'rentalPeriod': '2 เดือน',
        'rentalStart': '15 ก.พ. 2568',
        'rentalEnd': '14 เม.ย. 2568',
        'menu': ['Pizza หน้าต่างๆ', 'Pasta', 'Garlic Bread', 'สลัด'],
        'description': 'พิซซ่าและพาสต้าอบใหม่ทุกจาน เตาอบหินแท้',
        'schedule': [
          {
            'marketName': 'ตลาดสวนลุมไนท์บาซาร์',
            'day': 'ศุกร์ - อาทิตย์',
            'time': '18:00 - 23:00',
            'distance': '3.5 กม.',
          },
        ],
        'tags': ['ฝรั่ง', 'พิซซ่า', 'พาสต้า'],
        'isFavorite': false,
        'priceRange': '฿฿',
      },
      {
        'id': 's007',
        'shopName': 'ส้มตำนางฟ้า',
        'category': 'อาหารอีสาน',
        'image': _img7,
        'isOpen': true,
        'rating': 4.7,
        'reviewCount': 325,
        'openDays': 'ทุกวัน',
        'openTime': '17:00 - 23:00 น.',
        'marketName': 'ตลาดจตุจักร',
        'distance': '1.2 กม.',
        'rentalPeriod': '12 เดือน',
        'rentalStart': '1 ม.ค. 2568',
        'rentalEnd': '31 ธ.ค. 2568',
        'menu': ['ส้มตำไทย', 'ส้มตำปู', 'ลาบ', 'น้ำตก', 'ไก่ย่าง'],
        'description': 'ส้มตำสูตรอีสานแท้ รสจัด เผ็ดแซ่บ ถูกใจคนชอบเผ็ด',
        'schedule': [
          {
            'marketName': 'ตลาดจตุจักร',
            'day': 'ทุกวัน',
            'time': '17:00 - 23:00',
            'distance': '1.2 กม.',
          },
        ],
        'tags': ['อีสาน', 'เผ็ด', 'ส้มตำ'],
        'isFavorite': false,
        'priceRange': '฿',
      },
      {
        'id': 's008',
        'shopName': 'Vintage Clothes Shop',
        'category': 'เสื้อผ้ามือสอง',
        'image': _img2,
        'isOpen': true,
        'rating': 4.3,
        'reviewCount': 98,
        'openDays': 'เสาร์ - อาทิตย์',
        'openTime': '15:00 - 22:00 น.',
        'marketName': 'ตลาดนัดรถไฟ',
        'distance': '4.2 กม.',
        'rentalPeriod': '3 เดือน',
        'rentalStart': '1 มี.ค. 2568',
        'rentalEnd': '31 พ.ค. 2568',
        'menu': ['เสื้อ Vintage', 'กางเกง', 'เดรส', 'แจ็คเก็ต'],
        'description': 'เสื้อผ้าวินเทจสไตล์ย้อนยุค คัดมาแล้วทุกตัว',
        'schedule': [
          {
            'marketName': 'ตลาดนัดรถไฟ',
            'day': 'เสาร์ - อาทิตย์',
            'time': '15:00 - 22:00',
            'distance': '4.2 กม.',
          },
        ],
        'tags': ['วินเทจ', 'มือสอง', 'แฟชั่น'],
        'isFavorite': false,
        'priceRange': '฿฿',
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
// ShopListPage
// ══════════════════════════════════════════════════════════
class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  int currentIndex = 3;
  String? _userRole;
  String? _userToken;
  bool _isLoading = true;
  String _searchText = '';
  String _selectedCategory = 'ทั้งหมด';

  List<Map<String, dynamic>> _shops = [];

  final List<String> _categories = [
    'ทั้งหมด',
    'อาหาร',
    'เครื่องดื่ม',
    'เสื้อผ้า',
    'ขนมหวาน',
    'ของสด',
    'อื่นๆ',
  ];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('role');
    _userToken = prefs.getString('token');
    await _loadShops();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadShops() async {
    final data = await ShopApiService.getShops();
    if (mounted) setState(() => _shops = data);
  }

  // ✅ Filter ร้านค้า
  List<Map<String, dynamic>> get _filteredShops {
    return _shops.where((shop) {
      final matchSearch = shop['shopName'].toString().toLowerCase().contains(
                _searchText.toLowerCase(),
              ) ||
          shop['category'].toString().toLowerCase().contains(
                _searchText.toLowerCase(),
              ) ||
          shop['marketName'].toString().toLowerCase().contains(
                _searchText.toLowerCase(),
              );

      final matchCategory = _selectedCategory == 'ทั้งหมด' ||
          shop['category'].toString().contains(_selectedCategory) ||
          (shop['tags'] as List).contains(_selectedCategory);

      return matchSearch && matchCategory;
    }).toList();
  }

  // ✅ Toggle ถูกใจ
  Future<void> _toggleFavorite(Map<String, dynamic> shop) async {
    if (_userRole == null) {
      _showLoginRequiredDialog();
      return;
    }

    final newState = await ShopApiService.toggleFavorite(
      shop['id'],
      shop['isFavorite'] ?? false,
      _userToken ?? '',
    );

    setState(() => shop['isFavorite'] = newState);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState ? 'เพิ่มในรายการถูกใจแล้ว' : 'นำออกจากรายการถูกใจแล้ว',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: newState ? const Color(0xFF8CBC63) : Colors.grey,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // Popup ให้ Login ก่อนถูกใจ
  // ══════════════════════════════════════════════════════════
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
              // Header
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
                    Text(
                      'Save Your Favorites',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
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
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF8CBC63), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ลงทะเบียนเพื่อบันทึกร้านที่ถูกใจ\n'
                              'และติดตามร้านโปรดของคุณได้ทุกที่!',
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
                    _buildBenefit(Icons.favorite_rounded, 'บันทึกร้านที่ถูกใจ'),
                    _buildBenefit(Icons.notifications_rounded,
                        'รับแจ้งเตือนเมื่อร้านเปิด'),
                    _buildBenefit(
                        Icons.history_rounded, 'ดูประวัติร้านที่เคยเยี่ยมชม'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFFD1D5DB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text('ข้ามไปก่อน',
                                  style: GoogleFonts.kanit(
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600)),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
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
                                  const Icon(Icons.person_add_rounded,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Text('ลงทะเบียน',
                                      style: GoogleFonts.kanit(
                                          fontWeight: FontWeight.bold)),
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
          Text(text,
              style: GoogleFonts.kanit(
                  fontSize: 13, color: const Color(0xFF374151))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Popup รายละเอียดร้าน
  // ══════════════════════════════════════════════════════════
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
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8CBC63).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────
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
                      Text(
                        'รายละเอียดร้านค้า',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // ✅ ปุ่มถูกใจ
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
                            shop['isFavorite'] == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: shop['isFavorite'] == true
                                ? Colors.red
                                : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content ─────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ── Card รูป + ข้อมูลหลัก ────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF8CBC63).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // รูปร้าน
                              Stack(
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
                                        loadingBuilder: (_, child, p) {
                                          if (p == null) return child;
                                          return Container(
                                            height: 180,
                                            color: Colors.grey,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF8CBC63),
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF6E9B4C),
                                                Color(0xFF8CBC63),
                                              ],
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.storefront_rounded,
                                              color: Colors.white70,
                                              size: 60,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Status Badge
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: shop['isOpen'] == true
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFE53935),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            shop['isOpen'] == true
                                                ? 'เปิดอยู่'
                                                : 'ปิดแล้ว',
                                            style: GoogleFonts.kanit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Price Range Badge
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        shop['priceRange'] ?? '฿',
                                        style: GoogleFonts.kanit(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ชื่อร้าน
                                    Text(
                                      shop['shopName'] ?? '-',
                                      style: GoogleFonts.kanit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Category + Rating
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8CBC63)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            shop['category'] ?? '-',
                                            style: GoogleFonts.kanit(
                                              fontSize: 12,
                                              color: const Color(0xFF6E9B4C),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.star_rounded,
                                            color: Color(0xFFFFB000), size: 16),
                                        Text(
                                          ' ${shop['rating']}',
                                          style: GoogleFonts.kanit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                        Text(
                                          ' (${shop['reviewCount']} รีวิว)',
                                          style: GoogleFonts.kanit(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Description
                                    if (shop['description'] != null)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Text(
                                          shop['description'],
                                          style: GoogleFonts.kanit(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    // Info rows
                                    _buildDetailRow(Icons.access_time_rounded,
                                        'เวลาเปิด', shop['openTime'] ?? '-'),
                                    _buildDetailRow(
                                        Icons.calendar_today_rounded,
                                        'วันที่เปิด',
                                        shop['openDays'] ?? '-'),
                                    _buildDetailRow(Icons.location_on_rounded,
                                        'ตลาดหลัก', shop['marketName'] ?? '-'),
                                    _buildDetailRow(Icons.near_me_rounded,
                                        'ระยะทาง', shop['distance'] ?? '-'),
                                    _buildDetailRow(
                                        Icons.date_range_rounded,
                                        'ระยะเวลาที่เปิดที่นี่',
                                        '${shop['rentalPeriod']} '
                                            '(${shop['rentalStart']} - ${shop['rentalEnd']})'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── เมนู/สินค้า ──────────────────
                        if (shop['menu'] != null &&
                            (shop['menu'] as List).isNotEmpty)
                          _buildSectionCard(
                            icon: Icons.restaurant_menu_rounded,
                            title: 'เมนู / สินค้า',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (shop['menu'] as List<String>)
                                  .map((m) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF3CD),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFFFFB800)
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(m,
                                            style: GoogleFonts.kanit(
                                              fontSize: 13,
                                              color: const Color(0xFFB45309),
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ))
                                  .toList(),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // ── ตารางออกร้าน ──────────────────
                        if (shop['schedule'] != null &&
                            (shop['schedule'] as List).isNotEmpty)
                          _buildSectionCard(
                            icon: Icons.map_rounded,
                            title: 'ตารางออกร้าน',
                            child: Column(
                              children:
                                  (shop['schedule'] as List).map<Widget>((s) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F9EB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF8CBC63)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8CBC63)
                                              .withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.storefront_rounded,
                                            color: Color(0xFF6E9B4C),
                                            size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(s['marketName'] ?? '-',
                                                style: GoogleFonts.kanit(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFF1F2937),
                                                )),
                                            Text('${s['day']}  •  ${s['time']}',
                                                style: GoogleFonts.kanit(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text(s['distance'] ?? '',
                                          style: GoogleFonts.kanit(
                                            fontSize: 12,
                                            color: const Color(0xFF8CBC63),
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // ── ปุ่ม Action ───────────────────
                        Row(
                          children: [
                            // ถูกใจ
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: shop['isFavorite'] == true
                                        ? Colors.red
                                        : const Color(0xFF8CBC63),
                                    foregroundColor: shop['isFavorite'] == true
                                        ? Colors.redAccent
                                        : Colors.white,
                                    elevation: 0,
                                    side: BorderSide(
                                      color: shop['isFavorite'] == true
                                          ? Colors.redAccent
                                          : Colors.transparent,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
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
                                      Icon(
                                        shop['isFavorite'] == true
                                            ? Icons.heart_broken_rounded
                                            : Icons.favorite_rounded,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        shop['isFavorite'] == true
                                            ? 'ลบออก'
                                            : 'ถูกใจ',
                                        style: GoogleFonts.kanit(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // ปิด
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFD1D5DB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('ปิด',
                                      style: GoogleFonts.kanit(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600)),
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
            width: 32,
            height: 32,
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
                Text(label,
                    style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8CBC63).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6E9B4C), size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Navigation
  // ══════════════════════════════════════════════════════════
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 3:
        break;
      case 4:
        _navigateToProfile();
        break;
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
              // Wave Header
              SizedBox(
                height: 160,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                children: [
                  // ── Header ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ร้านค้าทั้งหมด',
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_filteredShops.length} ร้าน',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Search Bar ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchText = v),
                      style: GoogleFonts.kanit(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'ค้นหาร้านค้า / ประเภท / ตลาด...',
                        hintStyle:
                            GoogleFonts.kanit(color: const Color(0xFFBDBDBD)),
                        prefixIcon: const Icon(Icons.search),
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
                  ),

                  // ── Category Filter ────────────────────
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6E9B4C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6E9B4C)
                                    : Colors.grey,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── List ────────────────────────────────
                  Expanded(
                    child: _filteredShops.isEmpty
                        ? Center(
                            child: Text(
                              'ไม่พบร้านค้าที่ค้นหา',
                              style: GoogleFonts.kanit(color: Colors.grey),
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFF8CBC63),
                            onRefresh: _loadShops,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: _filteredShops.length,
                              itemBuilder: (_, i) =>
                                  _buildShopCard(_filteredShops[i]),
                            ),
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

  // ── Shop Card ─────────────────────────────────────────────
  Widget _buildShopCard(Map<String, dynamic> shop) {
    return GestureDetector(
      onTap: () => _showShopDetailDialog(shop),
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
            // รูปร้าน
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      shop['image'] ?? '',
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, p) {
                        if (p == null) return child;
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
                            colors: [Color(0xFF6E9B4C), Color(0xFF8CBC63)],
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
              ],
            ),

            // ข้อมูล
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop['shopName'] ?? '-',
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ✅ ปุ่มถูกใจ
                        GestureDetector(
                          onTap: () => _toggleFavorite(shop),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: shop['isFavorite'] == true
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              shop['isFavorite'] == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: shop['isFavorite'] == true
                                  ? Colors.redAccent
                                  : Colors.grey,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Category
                    Text(
                      shop['category'] ?? '-',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: const Color(0xFF6E9B4C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ตลาด + ระยะทาง
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${shop['marketName']} • ${shop['distance']}',
                            style: GoogleFonts.kanit(
                                fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // เวลา
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          shop['openTime'] ?? '-',
                          style: GoogleFonts.kanit(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Rating + Status
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB000), size: 13),
                        Text(
                          ' ${shop['rating']}',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        Text(
                          ' (${shop['reviewCount']})',
                          style: GoogleFonts.kanit(
                              fontSize: 11, color: Colors.grey),
                        ),
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
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
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

  // ── Bottom Nav ────────────────────────────────────────────
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
      ..color = const Color(0xFF73A34F)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.98,
          size.width * 0.52, size.height * 0.56)
      ..quadraticBezierTo(
          size.width * 0.72, size.height * 1.02, size.width, size.height * 0.72)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
