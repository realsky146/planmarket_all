import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/signup_vendor_page.dart';
import '../../services/api_service.dart';

class MarketDetailPage extends StatefulWidget {
  final Map<String, dynamic> market;
  const MarketDetailPage({super.key, required this.market});

  @override
  State<MarketDetailPage> createState() => _MarketDetailPageState();
}

class _MarketDetailPageState extends State<MarketDetailPage> {
  String? _selectedStallId;
  String? _userRole;
  Map<String, List<Map<String, dynamic>>> _stallsByZone = {};
  bool _isLoadingStalls = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    final marketId = int.tryParse(widget.market['id']?.toString() ?? '0') ?? 0;
    final result = await ApiService.getMarketStalls(marketId);

    if (!mounted) return;

    final Map<String, List<Map<String, dynamic>>> byZone = {};
    if (result['success'] == true) {
      final raw = result['data'] as List<dynamic>;
      for (final s in raw) {
        final sn = s['stall_number'] as String;
        final zone = sn.isNotEmpty ? 'โซน ${sn[0]}' : 'โซน ?';
        byZone.putIfAbsent(zone, () => []).add({
          'id': sn,
          'status': s['status'] ?? 'available',
        });
      }
    }

    setState(() {
      _userRole = role;
      _stallsByZone = byZone;
      _isLoadingStalls = false;
    });
  }

  Color _stallColor(String status, String stallId) {
    if (_selectedStallId == stallId) return const Color(0xFF2D9CDB);
    switch (status) {
      case 'available':
        return const Color(0xFF66BB6A);
      case 'pending':
        return const Color(0xFFFFB300);
      case 'booked':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  // ══════════════════════════════════════════════════════════
  // ✅ เช็คสิทธิ์ก่อนจอง
  // ══════════════════════════════════════════════════════════
  void _onStallTap(Map<String, dynamic> stall) {
    if (stall['status'] != 'available') return;

    // ถ้าเป็น vendor → เลือกล็อคได้ปกติ
    if (_userRole == 'vendor') {
      setState(() {
        _selectedStallId = _selectedStallId == stall['id'] ? null : stall['id'];
      });
      return;
    }

    // ถ้าเป็น customer หรือ ยังไม่ได้ login → แสดง Popup
    _showVendorRegisterDialog();
  }

  // ══════════════════════════════════════════════════════════
  // ✅ Popup "ต้องลงทะเบียนร้านค้า"
  // ══════════════════════════════════════════════════════════
  void _showVendorRegisterDialog() {
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
              // ── Header สีเขียว ─────────────────────────
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
                    // ── Icon ────────────────────────────
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
                      'สำหรับร้านค้าเท่านั้น',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Vendor Only',
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  children: [
                    // ── Info Box ───────────────────────
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
                              'การจองแผงล็อคสำหรับร้านค้าที่ลงทะเบียนแล้วเท่านั้น'
                              '\nต้องการลงทะเบียนร้านค้าหรือไม่?',
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

                    // ── Steps ──────────────────────────
                    _buildStep('1', 'ลงทะเบียนร้านค้า'),
                    _buildStep('2', 'รอการอนุมัติจากตลาด'),
                    _buildStep('3', 'จองแผงล็อคและเปิดร้านได้เลย!'),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ── Buttons ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    // ปุ่มยกเลิก
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'ยกเลิก',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ปุ่มยืนยัน
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
                            Navigator.pop(context); // ปิด dialog
                            // ✅ ไปหน้าลงทะเบียนร้านค้า
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpVendorPage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.storefront_rounded, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'ลงทะเบียนร้านค้า',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Step widget สำหรับแสดงขั้นตอน
  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF8CBC63),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    final market = widget.market;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, market),
              _buildLegend(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _isLoadingStalls
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                                color: Color(0xFF8CBC63)),
                          ),
                        )
                      : _stallsByZone.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text('ยังไม่มีแผงในตลาดนี้',
                                    style: GoogleFonts.kanit(
                                        color: Colors.grey)),
                              ),
                            )
                          : Column(
                              children: [
                                ..._stallsByZone.entries.expand((e) => [
                                      _buildZoneLabel(e.key),
                                      const SizedBox(height: 8),
                                      _buildStallGrid(e.value),
                                      const SizedBox(height: 16),
                                    ]),
                                const SizedBox(height: 8),
                              ],
                            ),
                ),
              ),
              _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> market) {
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.store_mall_directory_rounded,
              size: 60,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('กลับ',
                      style:
                          GoogleFonts.kanit(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(12),
            color: Colors.white.withOpacity(0.92),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  market['name'] ?? 'ตลาด',
                  style: GoogleFonts.kanit(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('📍 ${market['location'] ?? '-'}',
                    style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                Text('🕐 ${market['openTime'] ?? '-'}',
                    style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🗺️ กำลังเปิดแผนที่...',
                          style: GoogleFonts.kanit()),
                      duration: const Duration(seconds: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Color(0xFF8CBC63), size: 16),
                      Text(' แผนที่',
                          style: GoogleFonts.kanit(
                              fontSize: 12, color: const Color(0xFF8CBC63))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(const Color(0xFF66BB6A), 'ว่าง'),
          const SizedBox(width: 12),
          _legendItem(const Color(0xFFFFB300), 'รอชำระเงิน'),
          const SizedBox(width: 12),
          _legendItem(const Color(0xFFE53935), 'จองแล้ว'),
          const SizedBox(width: 12),
          _legendItem(const Color(0xFF2D9CDB), 'เลือกอยู่'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildZoneLabel(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFBDBDBD))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
        ),
        const Expanded(child: Divider(color: Color(0xFFBDBDBD))),
      ],
    );
  }

  Widget _buildStallGrid(List<Map<String, dynamic>> stalls) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: stalls.length,
      itemBuilder: (_, i) {
        final stall = stalls[i];
        final isAvailable = stall['status'] == 'available';
        return GestureDetector(
          // ✅ ทุก role กดได้ แต่ logic แยกใน _onStallTap
          onTap: () => _onStallTap(stall),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _stallColor(stall['status'], stall['id']),
              shape: BoxShape.circle,
              boxShadow: _selectedStallId == stall['id']
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2D9CDB).withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            // ✅ แสดง cursor ต่างกัน
            child: isAvailable ? null : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  // ── ปุ่มจองล็อค ─────────────────────────────────────────
  Widget _buildBookButton() {
    // ✅ ถ้าเป็น vendor และเลือกล็อคแล้ว → แสดงปุ่มจอง
    // ✅ ถ้าไม่ใช่ vendor → ปุ่มเป็นสีเทา
    final isVendor = _userRole == 'vendor';
    final canBook = isVendor && _selectedStallId != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ แสดง hint ถ้าไม่ใช่ vendor
          if (!isVendor)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'เฉพาะร้านค้าที่ลงทะเบียนแล้วเท่านั้น',
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canBook
                    ? const Color(0xFF8CBC63)
                    : !isVendor
                        ? const Color(0xFFE5E7EB)
                        : Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: canBook ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                if (!isVendor) {
                  // ✅ ไม่ใช่ vendor → แสดง popup
                  _showVendorRegisterDialog();
                } else if (canBook) {
                  // ✅ vendor + เลือกล็อคแล้ว → confirm จอง
                  _confirmBooking();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canBook
                        ? Icons.check_circle_outline_rounded
                        : !isVendor
                            ? Icons.storefront_outlined
                            : Icons.touch_app_rounded,
                    size: 20,
                    color: canBook
                        ? Colors.white
                        : !isVendor
                            ? const Color(0xFF8CBC63)
                            : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canBook
                        ? 'จองล็อค $_selectedStallId'
                        : !isVendor
                            ? 'ลงทะเบียนร้านค้าเพื่อจองล็อค'
                            : 'กรุณาเลือกล็อคที่ต้องการ',
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: canBook
                          ? Colors.white
                          : !isVendor
                              ? const Color(0xFF8CBC63)
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ยืนยันการจอง (สำหรับ Vendor) ────────────────────────
  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'ยืนยันการจอง',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'จองล็อค $_selectedStallId\nที่ ${widget.market['name'] ?? 'ตลาด'}\nใช่หรือไม่?',
          style: GoogleFonts.kanit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8CBC63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedStallId = null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('✅ จองล็อคสำเร็จแล้ว!', style: GoogleFonts.kanit()),
                  backgroundColor: const Color(0xFF8CBC63),
                ),
              );
            },
            child: Text('ยืนยัน', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }
}
