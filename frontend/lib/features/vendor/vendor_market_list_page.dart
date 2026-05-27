// vendor_market_list_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_market/features/vendor/vendor_shop_info_page.dart';
import 'vendor_home.dart';
import 'favorite_vendor_page.dart';
import 'profile_vendor_page.dart';
import '../../services/api_service.dart';
import '../../models/recommendation_models.dart';
import 'stall_selection_page.dart';

class VendorMarketListPage extends StatefulWidget {
  const VendorMarketListPage({super.key});
  @override
  State<VendorMarketListPage> createState() => _VendorMarketListPageState();
}

class _VendorMarketListPageState extends State<VendorMarketListPage> {
  int currentIndex = 1;
  final _searchCtrl = TextEditingController();
  String _searchText = '';
  bool _isLoading = true;
  int? _userId;
  List<Map<String, dynamic>> _markets = [];
  List<StallPreference> _savedPreferences = [];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = int.tryParse(prefs.getString('userId') ?? '');
    await _loadMarkets();
    await _checkPreferences();
  }

  // ── โหลดตลาดจาก API ──────────────────────────────────
  Future<void> _loadMarkets() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getMarkets();
      if (!mounted) return;
      if (result['success'] != true) {
        setState(() => _markets = []);
        return;
      }
      final raw = result['data'] as List<dynamic>;

      Set<String> favoriteIds = {};
      if (_userId != null) {
        final favResult = await ApiService.getMarketFavorites(_userId!);
        if (favResult['success'] == true) {
          final favData = favResult['data'] as List<dynamic>;
          favoriteIds = favData.map((e) => e['market_id'].toString()).toSet();
        }
      }

      setState(() {
        _markets = raw.map((m) {
          final totalStalls = (m['total_stalls'] as num?)?.toInt() ?? 0;
          final availableStalls = (m['available_stalls'] as num?)?.toInt() ?? 0;
          final marketId = m['id']?.toString() ?? '';
          return {
            'id': marketId,
            'name': m['name'] ?? '',
            'distance': '0.0 กม.',
            'location': m['location'] ?? m['description'] ?? '',
            'time':
                '${m['open_time'] ?? '08:00'} - ${m['close_time'] ?? '20:00'}',
            'isOpen': true,
            'tags': <String>[],
            'stallsAvailable': availableStalls,
            'totalStalls': totalStalls,
            'pricePerDay': (m['price_per_day'] as num?)?.toInt() ?? 0,
            'hasParking': (m['has_parking'] as num?)?.toInt() == 1,
            'hasAircon': (m['has_aircon'] as num?)?.toInt() == 1,
            'openWeekend': (m['open_weekend'] as num?)?.toInt() == 1,
            'traffic': 'ปานกลาง',
            'rating': double.tryParse(m['rating']?.toString() ?? '4.0') ?? 4.0,
            'isFavorite': favoriteIds.contains(marketId),
            'reason': 'แนะนำสำหรับคุณ',
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

  // ── Toggle Favorite ───────────────────────────────────
  Future<void> _toggleFavorite(Map<String, dynamic> market) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเข้าสู่ระบบก่อน', style: GoogleFonts.kanit()),
        ),
      );
      return;
    }

    final marketId = int.tryParse(market['id'].toString()) ?? 0;
    final isFav = market['isFavorite'] as bool;

    setState(() => market['isFavorite'] = !isFav);

    try {
      if (isFav) {
        await ApiService.removeMarketFavorite(_userId!, marketId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('นำออกจากรายการถูกใจแล้ว', style: GoogleFonts.kanit()),
              backgroundColor: Colors.grey,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await ApiService.addMarketFavorite(_userId!, marketId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('เพิ่มในรายการถูกใจแล้ว ❤️', style: GoogleFonts.kanit()),
              backgroundColor: const Color(0xFF8CBC63),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => market['isFavorite'] = isFav);
      debugPrint('❌ Toggle favorite error: $e');
    }
  }

  // ── Preference ────────────────────────────────────────
  Future<void> _checkPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('vendor_preferences');
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _savedPreferences = saved
            .split(',')
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>()
            .where((i) => i < StallPreference.values.length)
            .map((i) => StallPreference.values[i])
            .toList();
      });
    } else if (saved == null) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) _showPreferencePickerDialog(isFirstTime: true);
      }
    }
  }

  Future<void> _savePreferences(List<StallPreference> prefs) async {
    final spPrefs = await SharedPreferences.getInstance();
    final value = prefs.map((p) => p.index.toString()).join(',');
    await spPrefs.setString('vendor_preferences', value);
    setState(() => _savedPreferences = prefs);
  }

  void _showPreferencePickerDialog({bool isFirstTime = false}) {
    final temp = List<StallPreference>.from(_savedPreferences);
    showDialog(
      context: context,
      barrierDismissible: !isFirstTime,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CBC63),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(children: [
                    const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      isFirstTime ? 'คุณชอบตลาดแบบไหน?' : 'แก้ไขความต้องการ',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เลือกสิ่งที่คุณต้องการ\nเพื่อกรองตลาดที่เหมาะกับคุณ',
                      style: GoogleFonts.kanit(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StallPreference.values.map((pref) {
                      final selected = temp.contains(pref);
                      return GestureDetector(
                        onTap: () => setDialogState(() {
                          selected ? temp.remove(pref) : temp.add(pref);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? pref.color.withOpacity(0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color:
                                  selected ? pref.color : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(pref.icon,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                pref.title,
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selected
                                      ? pref.color
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(children: [
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8CBC63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _savePreferences(temp);
                        },
                        child: Text('บันทึก',
                            style:
                                GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (isFirstTime) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _savePreferences([]);
                        },
                        child: Text('ข้ามไปก่อน',
                            style: GoogleFonts.kanit(color: Colors.grey)),
                      ),
                    ],
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── ✅ preferenceScore (version เดียว ไม่ซ้ำ) ─────────
  double _preferenceScore(Map<String, dynamic> market) {
    if (_savedPreferences.isEmpty) return 0;

    double score = 0;
    final rating = (market['rating'] as num?)?.toDouble() ?? 4.0;
    final price = (market['pricePerDay'] as num?)?.toInt() ?? 999;
    final hasParking = market['hasParking'] as bool? ?? false;
    final hasAircon = market['hasAircon'] as bool? ?? false;
    final openWeekend = market['openWeekend'] as bool? ?? false;
    final available = (market['stallsAvailable'] as num?)?.toInt() ?? 0;

    for (final pref in _savedPreferences) {
      switch (pref) {
        case StallPreference.parking:
          score += hasParking ? 50 : 0;
          break;
        case StallPreference.aircon:
          score += hasAircon ? 50 : 0;
          break;
        case StallPreference.weekend:
          score += openWeekend ? 50 : 0;
          break;
        case StallPreference.cheapest:
          score += price > 0 ? (5000.0 / price).clamp(0, 50) : 50;
          break;
        case StallPreference.highTraffic:
          score += rating * 10;
          break;
        default:
          score += 10;
      }
    }

    // bonus แผงว่าง
    score += available * 0.5;
    return score;
  }

  // ── ✅ helper ตรวจว่าตรงกับ preference อย่างน้อย 1 ข้อ
  bool _matchesAnyPreference(Map<String, dynamic> m) {
    final hasParking = m['hasParking'] as bool? ?? false;
    final hasAircon = m['hasAircon'] as bool? ?? false;
    final openWeekend = m['openWeekend'] as bool? ?? false;
    final price = (m['pricePerDay'] as num?)?.toInt() ?? 999;
    final rating = (m['rating'] as num?)?.toDouble() ?? 0.0;

    for (final pref in _savedPreferences) {
      switch (pref) {
        case StallPreference.parking:
          if (hasParking) return true;
          break;
        case StallPreference.aircon:
          if (hasAircon) return true;
          break;
        case StallPreference.weekend:
          if (openWeekend) return true;
          break;
        case StallPreference.cheapest:
          if (price < 400) return true;
          break;
        case StallPreference.highTraffic:
          if (rating >= 4.0) return true;
          break;
        default:
          return true;
      }
    }
    return false;
  }

  // ── ✅ filter + sort ──────────────────────────────────
  List<Map<String, dynamic>> get _filteredMarkets {
    var list = List<Map<String, dynamic>>.from(_markets);

    // Search
    if (_searchText.isNotEmpty) {
      list = list.where((m) {
        final name = m['name'].toString().toLowerCase();
        final location = m['location'].toString().toLowerCase();
        final query = _searchText.toLowerCase();
        return name.contains(query) || location.contains(query);
      }).toList();
    }

    // ไม่มี preference → แสดงทั้งหมด
    if (_savedPreferences.isEmpty) return list;

    // กรองเฉพาะที่ตรงอย่างน้อย 1 ข้อ
    list = list.where(_matchesAnyPreference).toList();

    // เรียงตาม score มากไปน้อย
    list.sort((a, b) => _preferenceScore(b).compareTo(_preferenceScore(a)));

    // debug log
    for (final m in list) {
      debugPrint(
        '📊 ${m['name']} | score=${_preferenceScore(m).toStringAsFixed(1)}'
        ' | parking=${m['hasParking']}'
        ' | aircon=${m['hasAircon']}'
        ' | weekend=${m['openWeekend']}'
        ' | price=${m['pricePerDay']}',
      );
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
                  // Header + Search
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

                  // ── Preference chips ──────────────────
                  if (_savedPreferences.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [
                                Text('กรองตาม: ',
                                    style: GoogleFonts.kanit(
                                        fontSize: 11, color: Colors.grey)),
                                ..._savedPreferences.map((p) => Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: p.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: p.color.withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(p.icon,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                          const SizedBox(width: 3),
                                          Text(p.title,
                                              style: GoogleFonts.kanit(
                                                fontSize: 10,
                                                color: p.color,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                    )),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showPreferencePickerDialog,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: const Icon(Icons.tune_rounded,
                                  size: 16, color: Color(0xFF6B7280)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: GestureDetector(
                        onTap: () =>
                            _showPreferencePickerDialog(isFirstTime: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8CBC63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFF8CBC63).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tune_rounded,
                                  size: 14, color: Color(0xFF6E9B4C)),
                              const SizedBox(width: 6),
                              Text('ตั้งค่าความต้องการ',
                                  style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    color: const Color(0xFF6E9B4C),
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── รายการตลาด ────────────────────────
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF8CBC63)))
                        : _filteredMarkets.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.storefront_outlined,
                                        size: 48, color: Colors.grey),
                                    const SizedBox(height: 12),
                                    Text(
                                      _savedPreferences.isNotEmpty
                                          ? 'ไม่มีตลาดที่ตรงกับความต้องการของคุณ'
                                          : 'ไม่พบตลาดที่ค้นหา',
                                      style:
                                          GoogleFonts.kanit(color: Colors.grey),
                                    ),
                                    if (_savedPreferences.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _showPreferencePickerDialog,
                                        child: Text('เปลี่ยนความต้องการ',
                                            style: GoogleFonts.kanit(
                                                color:
                                                    const Color(0xFF8CBC63))),
                                      ),
                                    ],
                                  ],
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
    final available = (m['stallsAvailable'] as num?)?.toInt() ?? 0;
    final total = (m['totalStalls'] as num?)?.toInt() ?? 0;
    final traffic = m['traffic'] as String;
    final isFavorite = m['isFavorite'] as bool;
    final rating = (m['rating'] as num?)?.toDouble() ?? 4.0;

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

    // Match badges
    List<Widget> matchBadges = [];
    for (final pref in _savedPreferences) {
      bool matches = false;
      switch (pref) {
        case StallPreference.parking:
          matches = m['hasParking'] as bool? ?? false;
          break;
        case StallPreference.aircon:
          matches = m['hasAircon'] as bool? ?? false;
          break;
        case StallPreference.weekend:
          matches = m['openWeekend'] as bool? ?? false;
          break;
        case StallPreference.cheapest:
          matches = ((m['pricePerDay'] as num?)?.toInt() ?? 999) < 400;
          break;
        case StallPreference.highTraffic:
          matches = rating >= 4.0;
          break;
        default:
          matches = false;
      }
      if (matches) {
        matchBadges.add(Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: pref.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: pref.color.withOpacity(0.4), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(pref.icon, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 2),
            Text(pref.title,
                style: GoogleFonts.kanit(
                    fontSize: 9,
                    color: pref.color,
                    fontWeight: FontWeight.w600)),
          ]),
        ));
      }
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
                    Stack(children: [
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
                                color: Colors.grey.shade100,
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
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ]),
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
                                onTap: () => _toggleFavorite(m),
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
                          Row(children: [
                            const Icon(Icons.location_on,
                                size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 2),
                            Text(m['distance'] as String,
                                style: GoogleFonts.kanit(
                                    fontSize: 11,
                                    color: const Color(0xFF6B7280))),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time,
                                size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(m['time'] as String,
                                  style: GoogleFonts.kanit(
                                      fontSize: 11,
                                      color: const Color(0xFF6B7280)),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            _miniStat(Icons.grid_view, 'ว่าง $available/$total',
                                const Color(0xFF2D9CDB)),
                            const SizedBox(width: 8),
                            _miniStat(
                                Icons.people, 'คน: $traffic', trafficColor),
                            const SizedBox(width: 8),
                            const Icon(Icons.star_rounded,
                                size: 12, color: Color(0xFFFFB000)),
                            Text(' $rating',
                                style: GoogleFonts.kanit(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                if (matchBadges.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: matchBadges),
                  ),
                ],
                const SizedBox(height: 10),
                Row(children: [
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
                                child: Text(t,
                                    style: GoogleFonts.kanit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFB45309))),
                              ))
                          .toList(),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8CBC63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('฿${m['pricePerDay']}/วัน',
                        style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6E9B4C))),
                  ),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E9B4C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF6E9B4C).withOpacity(0.2)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 13, color: Color(0xFF6E9B4C)),
                  const SizedBox(width: 5),
                  Text(m['reason'] as String,
                      style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: const Color(0xFF6E9B4C),
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      available > 0 ? const Color(0xFF8CBC63) : Colors.grey,
                  foregroundColor:
                      available > 0 ? Colors.white : const Color(0xFF9CA3AF),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: available > 0
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StallSelectionPage(market: m),
                          ),
                        )
                    : null,
                child: Text(
                  available > 0 ? 'จองแผง' : 'เต็มแล้ว',
                  style: GoogleFonts.kanit(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String text, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 3),
      Text(text,
          style: GoogleFonts.kanit(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]);
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
            child: Column(children: [
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
                child: Icon(items[currentIndex]['icon'] as IconData,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 4),
              Text(items[currentIndex]['label'] as String,
                  style: GoogleFonts.kanit(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ]),
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
    path.quadraticBezierTo(size.width * 0.18, size.height * 0.98,
        size.width * 0.52, size.height * 0.56);
    path.quadraticBezierTo(
        size.width * 0.72, size.height * 1.02, size.width, size.height * 0.72);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
