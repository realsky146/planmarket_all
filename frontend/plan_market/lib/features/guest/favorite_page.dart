import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan_market/features/guest/shop_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'market_detail_page.dart';
import 'market_list_page.dart';
import 'profile_page.dart';
import '../auth/select_role_page.dart';

// ══════════════════════════════════════════════════════════
// 🔌 API Service - พอ Backend พร้อมแก้แค่ไฟล์นี้
// ══════════════════════════════════════════════════════════
class FavoriteApiService {
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

  // ── ดึงร้านที่ถูกใจ ───────────────────────────────────
  // 🔌 TODO: GET $baseUrl/favorites
  //          Header: Authorization: Bearer <token>
  static Future<List<Map<String, dynamic>>> getFavorites(String token) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        // ── ข้อมูลพื้นฐานร้าน (ดึงจากตอนร้านลงทะเบียน) ──
        'id': 's001',
        'shopName': 'โกโก้ในตำนาน',
        'category': 'เครื่องดื่ม',
        'image': _img1, // รูปจากตอนร้านลงทะเบียน
        'isOpen': true,
        'status': 'เปิด',
        // ── เวลาและวันเปิด ─────────────────────────────
        'openDays': 'ศุกร์ - อาทิตย์',
        'openTime': '18:00 - 23:00 น.',
        // ── ตลาดที่ไปเปิด ──────────────────────────────
        'marketName': 'ตลาดจตุจักร',
        'distance': '1.2 กม.',
        // ── ระยะเวลาที่จะเปิดที่นี่ ────────────────────
        'rentalPeriod': '3 เดือน',
        'rentalStart': '1 ม.ค. 2568',
        'rentalEnd': '31 มี.ค. 2568',
        // ── เมนู/สินค้า ────────────────────────────────
        'menu': ['โกโก้เย็น', 'ชานม', 'ชาเขียว', 'น้ำผลไม้'],
        // ── ตารางออกร้าน (ดึงจากข้อมูลร้านลงทะเบียน) ──
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
        'tags': ['เครื่องดื่ม', 'ของหวาน'],
        'isFavorite': true,
      },
      {
        'id': 's002',
        'shopName': 'ร้านมาลีผัดไทย',
        'category': 'อาหารไทย',
        'image': _img3,
        'isOpen': true,
        'status': 'เปิด',
        'openDays': 'เสาร์ - อาทิตย์',
        'openTime': '17:00 - 22:00 น.',
        'marketName': 'ตลาดนัดรถไฟ',
        'distance': '4.2 กม.',
        'rentalPeriod': '6 เดือน',
        'rentalStart': '1 ธ.ค. 2567',
        'rentalEnd': '31 พ.ค. 2568',
        'menu': ['ผัดไทย', 'ผัดซีอิ๊ว', 'ราดหน้า', 'ผัดคะน้า'],
        'schedule': [
          {
            'marketName': 'ตลาดนัดรถไฟ',
            'day': 'เสาร์ - อาทิตย์',
            'time': '17:00 - 22:00',
            'distance': '4.2 กม.',
          },
        ],
        'tags': ['อาหาร', 'ของสด'],
        'isFavorite': true,
      },
      {
        'id': 's003',
        'shopName': 'ร้านแฟชั่นเกาหลี',
        'category': 'เสื้อผ้า',
        'image': _img4,
        'isOpen': false,
        'status': 'ปิด',
        'openDays': 'ทุกวัน',
        'openTime': '16:00 - 22:00 น.',
        'marketName': 'ตลาดเซฟวันโก',
        'distance': '7.2 กม.',
        'rentalPeriod': '1 เดือน',
        'rentalStart': '15 ม.ค. 2568',
        'rentalEnd': '14 ก.พ. 2568',
        'menu': ['เสื้อผ้าเกาหลี', 'กระเป๋า', 'เครื่องประดับ'],
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
        'tags': ['แฟชั่น', 'เสื้อผ้า'],
        'isFavorite': true,
      },
    ];
  }

  // ── Toggle ถูกใจ ──────────────────────────────────────
  // 🔌 TODO:
  //   POST   $baseUrl/favorites/$shopId  → เพิ่ม
  //   DELETE $baseUrl/favorites/$shopId  → ลบ
  static Future<bool> toggleFavorite(
      String shopId, bool isFavorite, String token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return !isFavorite;
  }
}

// ══════════════════════════════════════════════════════════
// FavoritePage
// ══════════════════════════════════════════════════════════
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  int currentIndex = 0;
  String? _userRole;
  String? _userToken;
  bool _isLoading = true;
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('role');
    _userToken = prefs.getString('token');

    if (_userRole != null && _userToken != null) {
      await _loadFavorites();
    }

    if (mounted) setState(() => _isLoading = false);

    // Guest → popup แนะนำ
    if (_userRole == null && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showRegisterSuggestionDialog();
      });
    }
  }

  Future<void> _loadFavorites() async {
    final data = await FavoriteApiService.getFavorites(_userToken ?? '');
    if (mounted) setState(() => _favorites = data);
  }

  // ✅ Toggle ถูกใจ
  Future<void> _toggleFavorite(Map<String, dynamic> shop) async {
    final newState = await FavoriteApiService.toggleFavorite(
      shop['id'],
      shop['isFavorite'] ?? true,
      _userToken ?? '',
    );
    setState(() {
      shop['isFavorite'] = newState;
      if (!newState) {
        _favorites.removeWhere((s) => s['id'] == shop['id']);
      }
    });

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
  // Popup แนะนำลงทะเบียน
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
                            color: const Color(0xFF8CBC63).withOpacity(0.3)),
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
  // ✅ Popup รายละเอียดร้าน (ปรับใหม่ตามที่ขอ)
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
                // ── Header ────────────────────────────
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
                      // ✅ ปุ่มถูกใจใน Header
                      GestureDetector(
                        onTap: () async {
                          await _toggleFavorite(shop);
                          setDialogState(() {});
                          if (!(shop['isFavorite'] ?? true)) {
                            Navigator.pop(context);
                          }
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

                // ── Scrollable Content ─────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ── Card หลัก ──────────────────
                        Container(
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
                              // ── รูปร้าน ───────────────
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
                                      // 🔌 รูปจากตอนร้านลงทะเบียน
                                      child: Image.network(
                                        shop['image'] ?? '',
                                        fit: BoxFit.cover,
                                        loadingBuilder: (_, child, progress) {
                                          if (progress == null) return child;
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
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF6E9B4C),
                                                const Color(0xFF8CBC63)
                                                    .withOpacity(0.5),
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
                                  // ✅ Status Badge บนรูป
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
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── ชื่อร้าน + ประเภท ──
                                    Text(
                                      shop['shopName'] ?? '-',
                                      style: GoogleFonts.kanit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // ── Info Rows ───────────
                                    _buildDetailRow(
                                      Icons.access_time_rounded,
                                      'เวลาเปิด',
                                      shop['openTime'] ?? '-',
                                    ),
                                    _buildDetailRow(
                                      Icons.calendar_today_rounded,
                                      'วันที่เปิด',
                                      shop['openDays'] ?? '-',
                                    ),
                                    _buildDetailRow(
                                      Icons.location_on_rounded,
                                      'ตลาด',
                                      shop['marketName'] ?? '-',
                                    ),
                                    _buildDetailRow(
                                      Icons.near_me_rounded,
                                      'ระยะทาง',
                                      shop['distance'] ?? '-',
                                    ),
                                    _buildDetailRow(
                                      Icons.date_range_rounded,
                                      'ระยะเวลาที่เปิดที่นี่',
                                      '${shop['rentalPeriod'] ?? '-'} '
                                          '(${shop['rentalStart'] ?? ''} - ${shop['rentalEnd'] ?? ''})',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── เมนู/สินค้า ────────────────
                        if (shop['menu'] != null &&
                            (shop['menu'] as List).isNotEmpty)
                          _buildSectionCard(
                            icon: Icons.restaurant_menu_rounded,
                            title: 'เมนู / สินค้า',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (shop['menu'] as List<String>).map((m) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFFB800)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    m,
                                    style: GoogleFonts.kanit(
                                      fontSize: 13,
                                      color: const Color(0xFFB45309),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // ── ตารางออกร้าน ───────────────
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
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s['marketName'] ?? '-',
                                              style: GoogleFonts.kanit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                            Text(
                                              '${s['day']}  •  ${s['time']}',
                                              style: GoogleFonts.kanit(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        s['distance'] ?? '',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          color: const Color(0xFF8CBC63),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // ── ปุ่ม Action ─────────────────
                        Row(
                          children: [
                            // ปุ่มลบออกจากถูกใจ
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await _toggleFavorite(shop);
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.heart_broken_rounded,
                                          color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'ลบออก',
                                        style: GoogleFonts.kanit(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // ปุ่มปิด
                            Expanded(
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
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'ปิด',
                                    style: GoogleFonts.kanit(
                                        fontWeight: FontWeight.bold),
                                  ),
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

  // ── Detail Row ────────────────────────────────────────────
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
                Text(
                  label,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Card ──────────────────────────────────────────
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
              Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
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
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MarketListPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      // แก้ทุกหน้าที่มี case 3: ใน _navigateToPage
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ShopListPage()));
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
              SizedBox(
                height: 160,
                width: double.infinity,
                child: CustomPaint(painter: _TopWavePainter()),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 22),
                        ),
                        Text(
                          'ร้านที่ถูกใจ',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // ✅ แสดงจำนวนร้านที่ถูกใจ
                        if (_userRole != null && _favorites.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_favorites.length} ร้าน',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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

  // ── Guest View ────────────────────────────────────────────
  Widget _buildGuestView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: GestureDetector(
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MarketListPage())),
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
                  Text('ค้นหาร้านค้า...',
                      style: GoogleFonts.kanit(
                          color: const Color(0xFF9CA3AF), fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
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
                    child: const Icon(Icons.favorite_border_rounded,
                        size: 40, color: Color(0xFF8CBC63)),
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
                    'ลงทะเบียนเพื่อบันทึกร้านที่ถูกใจ\nและติดตามร้านโปรดของคุณ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kanit(
                        fontSize: 13, color: Colors.grey, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8CBC63),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _showRegisterSuggestionDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text('ลงทะเบียนเพื่อเพิ่มร้านถูกใจ',
                              style: GoogleFonts.kanit(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
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
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MarketListPage())),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_rounded,
                              color: Color(0xFF8CBC63), size: 20),
                          const SizedBox(width: 8),
                          Text('ค้นหาตลาดและร้านค้า',
                              style: GoogleFonts.kanit(
                                  color: const Color(0xFF8CBC63),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
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

  // ── Logged In View ────────────────────────────────────────
  Widget _buildLoggedInView() {
    if (_favorites.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      color: const Color(0xFF8CBC63),
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _favorites.length,
        itemBuilder: (_, i) => _buildShopCard(_favorites[i]),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmpty() {
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
            child: const Icon(Icons.favorite_border,
                size: 40, color: Color(0xFF8CBC63)),
          ),
          const SizedBox(height: 16),
          Text('ยังไม่มีร้านที่ถูกใจ',
              style: GoogleFonts.kanit(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('กดหัวใจที่ร้านค้าเพื่อบันทึก',
              style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8CBC63),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ShopListPage())),
            child: Text('ค้นหาร้านค้า',
                style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Shop Card ─────────────────────────────────────────────
  Widget _buildShopCard(Map<String, dynamic> shop) {
    return GestureDetector(
      onTap: () => _showShopDetailDialog(shop),
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
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ รูปจาก network
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: 110,
                        height: 110,
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
                            color: const Color(0xFF8CBC63).withOpacity(0.15),
                            child: const Center(
                              child: Icon(Icons.store_mall_directory_rounded,
                                  color: Color(0xFF8CBC63), size: 44),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ข้อมูลร้าน
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 50, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop['shopName'] ?? '-',
                              style: GoogleFonts.kanit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: const Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              shop['category'] ?? '-',
                              style: GoogleFonts.kanit(
                                  fontSize: 12, color: const Color(0xFF6E9B4C)),
                            ),
                            const SizedBox(height: 4),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // ✅ Status Badge
                Positioned(
                  top: 10,
                  right: 44,
                  child: _buildStatusBadge(shop['isOpen'] ?? false),
                ),
                // ✅ ปุ่มถูกใจ / ลบ
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(shop),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.redAccent, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            // ── Tags ──────────────────────────────────
            if (shop['tags'] != null && (shop['tags'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: (shop['tags'] as List<String>)
                      .take(3)
                      .map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildTag(tag),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────
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

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  // ── Bottom Nav ────────────────────────────────────────────
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

// ── Wave Painter ──────────────────────────────────────────
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
