import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════
// 🔌 API Services
// ══════════════════════════════════════════════════════════
class MarketLayoutApiService {
  static const String baseUrl = 'https://api.planmarket.com/v1';

  // 🔌 TODO: GET $baseUrl/markets/:id/layout
  static Future<Map<String, dynamic>> getMarketLayout(String marketId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'success': true,
      'data': {
        'marketId': marketId,
        'pricePerDay': 300,
        'zones': [
          {
            'zoneId': 'z001',
            'zoneName': 'โซน A (ประตู 1)',
            'rows': _mockRows('A', 8, 10, {
              'A3': 'booked',
              'A4': 'booked',
              'A5': 'pending',
              'A6': 'pending',
              'B3': 'booked',
              'B4': 'pending',
              'B5': 'pending',
              'B6': 'booked',
              'C3': 'pending',
              'C4': 'booked',
              'C5': 'booked',
              'C6': 'pending',
              'D3': 'pending',
              'D4': 'pending',
              'D5': 'booked',
              'D6': 'booked',
              'E3': 'booked',
              'E4': 'pending',
              'E5': 'pending',
              'E6': 'booked',
              'F3': 'booked',
              'F4': 'booked',
              'F5': 'pending',
              'F6': 'pending',
              'G3': 'pending',
              'G4': 'booked',
              'G5': 'booked',
              'G6': 'pending',
              'H3': 'booked',
              'H4': 'pending',
              'H5': 'booked',
              'H6': 'pending',
            }),
          },
          {
            'zoneId': 'z002',
            'zoneName': 'โซน B (ประตู 2)',
            'rows': _mockRows('I', 3, 8, {
              'I3': 'booked',
              'I5': 'pending',
              'J4': 'pending',
              'J6': 'booked',
              'K2': 'booked',
              'K7': 'pending',
            }),
          },
          {
            'zoneId': 'z003',
            'zoneName': 'โซน C (ประตู 3)',
            'rows': _mockRows('L', 2, 6, {
              'L2': 'booked',
              'M3': 'pending',
            }),
          },
        ],
      },
    };
  }

  static List<Map<String, dynamic>> _mockRows(
    String startLetter,
    int rowCount,
    int stallCount,
    Map<String, String> overrides,
  ) {
    final startCode = startLetter.codeUnitAt(0);
    return List.generate(rowCount, (i) {
      final letter = String.fromCharCode(startCode + i);
      return {
        'rowId': 'row_$letter',
        'rowLabel': letter,
        'stalls': List.generate(stallCount, (j) {
          final id = '$letter${j + 1}';
          return {
            'stallId': id,
            'status': overrides[id] ?? 'available',
            'pricePerDay': 300,
          };
        }),
      };
    });
  }

  // 🔌 TODO: GET $baseUrl/markets/:id/rules
  static Future<Map<String, dynamic>> getMarketRules(String marketId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'success': true,
      'data': {
        'rules': [
          {
            'icon': '🏪',
            'title': 'ขนาดล็อคและพื้นที่',
            'detail': 'ล็อคมาตรฐาน 2×2 เมตร ห้ามวางสินค้านอกพื้นที่ที่กำหนด '
                'และต้องรักษาทางเดินระหว่างล็อคให้โล่งตลอดเวลา',
          },
          {
            'icon': '⏰',
            'title': 'เวลาเปิด-ปิดร้าน',
            'detail':
                'เปิดร้านได้ตั้งแต่ 15:00 น. และต้องปิดร้านภายใน 23:00 น. '
                    'กรณีปิดก่อนเวลาต้องแจ้งล่วงหน้าอย่างน้อย 1 ชั่วโมง',
          },
          {
            'icon': '🧹',
            'title': 'ความสะอาดและสิ่งแวดล้อม',
            'detail':
                'ต้องทำความสะอาดพื้นที่หลังปิดร้านทุกครั้ง แยกขยะให้ถูกต้อง '
                    'ห้ามทิ้งน้ำมันหรือของเหลวลงท่อระบายน้ำ',
          },
          {
            'icon': '🔊',
            'title': 'เสียงและการส่งเสริมการขาย',
            'detail': 'ห้ามใช้เครื่องขยายเสียงที่รบกวนร้านข้างเคียง '
                'เปิดเพลงได้ในระดับเสียงไม่เกิน 70 เดซิเบล',
          },
          {
            'icon': '💳',
            'title': 'การชำระเงินและการยกเลิก',
            'detail': 'ชำระค่าเช่าล่วงหน้าภายใน 24 ชั่วโมงหลังได้รับอนุมัติ '
                'ยกเลิกก่อน 3 วันคืนเงิน 50% ยกเลิกน้อยกว่า 3 วันไม่คืนเงิน',
          },
          {
            'icon': '🚫',
            'title': 'สินค้าต้องห้าม',
            'detail': 'ห้ามจำหน่ายสินค้าผิดกฎหมาย สินค้าละเมิดลิขสิทธิ์ '
                'อาหารที่ไม่ผ่านมาตรฐานอนามัย และสัตว์มีชีวิตทุกชนิด',
          },
          {
            'icon': '🛡️',
            'title': 'ความรับผิดชอบ',
            'detail': 'ผู้เช่าต้องรับผิดชอบทรัพย์สินของตนเอง '
                'ตลาดไม่รับผิดชอบต่อการสูญหายหรือเสียหายของสินค้า',
          },
        ],
      },
    };
  }

  // 🔌 TODO: POST $baseUrl/bookings
  static Future<Map<String, dynamic>> createBooking({
    required String marketId,
    required List<String> stallIds,
    required DateTime startDate,
    required DateTime endDate,
    required List<int> selectedWeekdays,
    required int totalDays,
    required int totalPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'success': true,
      'data': {
        'bookingId': 'BK${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'marketId': marketId,
        'stallIds': stallIds,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'selectedWeekdays': selectedWeekdays,
        'totalDays': totalDays,
        'totalPrice': totalPrice,
        'createdAt': DateTime.now().toIso8601String(),
      },
      'message': 'ส่งคำขอจองสำเร็จ',
    };
  }
}

// ══════════════════════════════════════════════════════════
// VendorBookingPage
// ══════════════════════════════════════════════════════════
class VendorBookingPage extends StatefulWidget {
  final Map<String, dynamic> market;

  const VendorBookingPage({
    super.key,
    required this.market,
    required String marketId,
    required String marketName,
  });

  @override
  State<VendorBookingPage> createState() => _VendorBookingPageState();
}

class _VendorBookingPageState extends State<VendorBookingPage> {
  bool _isLoadingLayout = true;
  bool _isLoadingRules = false;

  List<Map<String, dynamic>> _zones = [];
  int _pricePerDay = 300;

  DateTime? _startDate;
  DateTime? _endDate;
  final Set<int> _selectedWeekdays = {};
  final List<String> _weekdayLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  final Set<String> _selectedStalls = {};
  List<Map<String, dynamic>> _marketRules = [];

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    setState(() => _isLoadingLayout = true);
    try {
      final result = await MarketLayoutApiService.getMarketLayout(
        widget.market['id'] ?? 'm001',
      );
      if (mounted && result['success'] == true) {
        setState(() {
          _zones = List<Map<String, dynamic>>.from(result['data']['zones']);
          _pricePerDay = (result['data']['pricePerDay'] as num?)?.toInt() ??
              (widget.market['pricePerDay'] as num?)?.toInt() ??
              300;
        });
      }
    } catch (e) {
      _showSnackbar('โหลดผังตลาดไม่สำเร็จ กรุณาลองใหม่', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingLayout = false);
    }
  }

  // ── คำนวณ ─────────────────────────────────────────────
  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    if (_selectedWeekdays.isEmpty) {
      return _endDate!.difference(_startDate!).inDays + 1;
    }
    int count = 0;
    DateTime cur = _startDate!;
    while (!cur.isAfter(_endDate!)) {
      if (_selectedWeekdays.contains(cur.weekday)) count++;
      cur = cur.add(const Duration(days: 1));
    }
    return count;
  }

  int get _totalPrice => _selectedStalls.length * _totalDays * _pricePerDay;

  // ── Format ─────────────────────────────────────────────
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    return '${date.day} ${months[date.month]} ${date.year + 543}';
  }

  String _getDurationText() {
    if (_startDate == null || _endDate == null) return '-';
    final diff = _endDate!.difference(_startDate!).inDays + 1;
    final months = diff ~/ 30;
    final days = diff % 30;
    if (months > 0 && days > 0) return '$months เดือน $days วัน';
    if (months > 0) return '$months เดือน';
    return '$diff วัน';
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final result = StringBuffer();
    final length = str.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(str[i]);
    }
    return result.toString();
  }

  // ── Actions ────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8CBC63),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _onStallTap(Map<String, dynamic> stall) {
    if (stall['status'] != 'available') return;
    setState(() {
      final id = stall['stallId'] as String;
      if (_selectedStalls.contains(id)) {
        _selectedStalls.remove(id);
      } else {
        _selectedStalls.add(id);
      }
    });
  }

  Color _stallColor(String status, bool isSelected) {
    if (isSelected) return const Color(0xFF2196F3);
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

  Future<void> _onBookingPressed() async {
    if (_selectedStalls.isEmpty) {
      _showSnackbar('กรุณาเลือกล็อคที่ต้องการจอง', isError: true);
      return;
    }
    if (_startDate == null || _endDate == null) {
      _showSnackbar('กรุณาเลือกช่วงวันที่จอง', isError: true);
      return;
    }
    if (_totalDays == 0) {
      _showSnackbar('กรุณาเลือกวันที่ขายให้ถูกต้อง', isError: true);
      return;
    }
    setState(() => _isLoadingRules = true);
    try {
      final result = await MarketLayoutApiService.getMarketRules(
        widget.market['id'] ?? 'm001',
      );
      if (mounted) {
        _marketRules = List<Map<String, dynamic>>.from(
          result['data']['rules'],
        );
        _showRulesDialog();
      }
    } catch (e) {
      _showSnackbar('โหลดกฎตลาดไม่สำเร็จ', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingRules = false);
    }
  }

  // ══════════════════════════════════════════════════════
  // Popup 1: กฎและเกณฑ์
  // ══════════════════════════════════════════════════════
  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6E9B4C), Color(0xFF8CBC63)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.gavel_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'กฎและเกณฑ์ของตลาด',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.market['name'] ?? 'ตลาด',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              // Rules
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFB800).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFB45309), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'กรุณาอ่านกฎและเกณฑ์ให้ครบถ้วนก่อนยืนยัน '
                                'การกดยอมรับถือว่าท่านรับทราบและยินยอมปฏิบัติตาม',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  color: const Color(0xFF92400E),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._marketRules.map(
                        (rule) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rule['icon'] ?? '•',
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rule['title'] ?? '',
                                      style: GoogleFonts.kanit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      rule['detail'] ?? '',
                                      style: GoogleFonts.kanit(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
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
              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
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
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'ปฏิเสธ',
                            style: GoogleFonts.kanit(
                              color: Colors.grey,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showConfirmDialog();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'ยอมรับและดำเนินการ',
                                style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.bold),
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

  // ══════════════════════════════════════════════════════
  // Popup 2: ยืนยันการจอง
  // ══════════════════════════════════════════════════════
  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setS) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
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
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8CBC63),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'สรุปรายละเอียดการจอง',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF8CBC63).withOpacity(0.3),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ตลาด
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8CBC63)
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.storefront_rounded,
                                          color: Color(0xFF6E9B4C),
                                          size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('ตลาด',
                                              style: GoogleFonts.kanit(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                          Text(
                                            widget.market['name'] ?? '-',
                                            style: GoogleFonts.kanit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const _Divider(),
                                _ConfirmRow(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'วันที่เริ่ม',
                                  value: _formatDate(_startDate),
                                ),
                                _ConfirmRow(
                                  icon: Icons.event_rounded,
                                  label: 'วันที่สิ้นสุด',
                                  value: _formatDate(_endDate),
                                ),
                                _ConfirmRow(
                                  icon: Icons.timelapse_rounded,
                                  label: 'ระยะเวลา',
                                  value: _getDurationText(),
                                ),
                                if (_selectedWeekdays.isNotEmpty)
                                  _ConfirmRow(
                                    icon: Icons.today_rounded,
                                    label: 'วันที่ขาย',
                                    value: (_selectedWeekdays.toList()..sort())
                                        .map((d) => _weekdayLabels[d - 1])
                                        .join(', '),
                                  ),
                                _ConfirmRow(
                                  icon: Icons.calendar_month_rounded,
                                  label: 'จำนวนวันขาย',
                                  value: '$_totalDays วัน',
                                  highlight: true,
                                ),
                                const _Divider(),
                                _ConfirmRow(
                                  icon: Icons.grid_view_rounded,
                                  label: 'ล็อคที่เลือก',
                                  value: _selectedStalls.toList().join(', '),
                                ),
                                _ConfirmRow(
                                  icon: Icons.numbers_rounded,
                                  label: 'จำนวนล็อค',
                                  value: '${_selectedStalls.length} ล็อค',
                                ),
                                const _Divider(),
                                _ConfirmRow(
                                  icon: Icons.payments_rounded,
                                  label: 'ราคาต่อล็อค/วัน',
                                  value: '฿$_pricePerDay',
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8CBC63)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF8CBC63)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ราคารวมทั้งหมด',
                                            style: GoogleFonts.kanit(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF374151),
                                            ),
                                          ),
                                          Text(
                                            '${_selectedStalls.length} ล็อค × $_totalDays วัน × ฿$_pricePerDay',
                                            style: GoogleFonts.kanit(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '฿${_formatNumber(_totalPrice)}',
                                        style: GoogleFonts.kanit(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF6E9B4C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Info Note
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: Colors.blue, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'หลังกดยืนยัน ระบบจะส่งคำขอไปยังเจ้าของตลาด '
                                    'รอการอนุมัติภายใน 24 ชั่วโมง',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      height: 1.5,
                                    ),
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
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFD1D5DB)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: isSubmitting
                                        ? null
                                        : () => Navigator.pop(ctx),
                                    child: Text(
                                      'ยกเลิก',
                                      style: GoogleFonts.kanit(
                                        color: Colors.grey,
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            setS(() => isSubmitting = true);
                                            await _submitBooking(ctx);
                                          },
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.send_rounded,
                                                  size: 18),
                                              const SizedBox(width: 6),
                                              Text(
                                                'ยืนยันการจอง',
                                                style: GoogleFonts.kanit(
                                                    fontWeight:
                                                        FontWeight.bold),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // Submit
  // ══════════════════════════════════════════════════════
  Future<void> _submitBooking(BuildContext dialogCtx) async {
    try {
      final result = await MarketLayoutApiService.createBooking(
        marketId: widget.market['id'] ?? 'm001',
        stallIds: _selectedStalls.toList(),
        startDate: _startDate!,
        endDate: _endDate!,
        selectedWeekdays: _selectedWeekdays.toList(),
        totalDays: _totalDays,
        totalPrice: _totalPrice,
      );
      if (!mounted) return;
      Navigator.pop(dialogCtx);
      if (result['success'] == true) {
        setState(() {
          _selectedStalls.clear();
          _startDate = null;
          _endDate = null;
          _selectedWeekdays.clear();
        });
        _showSuccessDialog(result['data']);
      } else {
        _showSnackbar(result['message'] ?? 'เกิดข้อผิดพลาด', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(dialogCtx);
      _showSnackbar('เกิดข้อผิดพลาด กรุณาลองใหม่', isError: true);
    }
  }

  // ══════════════════════════════════════════════════════
  // Popup 3: Success
  // ══════════════════════════════════════════════════════
  void _showSuccessDialog(Map<String, dynamic> bookingData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
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
                padding: const EdgeInsets.symmetric(vertical: 28),
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ส่งคำขอจองสำเร็จ!',
                      style: GoogleFonts.kanit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Booking Request Sent',
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9EB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8CBC63).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('หมายเลขการจอง',
                              style: GoogleFonts.kanit(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            bookingData['bookingId'] ?? '-',
                            style: GoogleFonts.kanit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF374151),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                        '1', 'รอเจ้าของตลาดอนุมัติ', 'ภายใน 24 ชั่วโมง', true),
                    _buildStep(
                        '2', 'รับการแจ้งเตือน', 'เมื่อได้รับการอนุมัติ', false),
                    _buildStep('3', 'ชำระเงินค่าเช่า',
                        'ภายใน 24 ชั่วโมงหลังอนุมัติ', false),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8CBC63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'กลับหน้าหลัก',
                          style: GoogleFonts.kanit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'ดูการจองของฉัน',
                        style: GoogleFonts.kanit(
                          color: const Color(0xFF8CBC63),
                          fontWeight: FontWeight.w600,
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

  // ══════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: _isLoadingLayout
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF8CBC63)),
                  const SizedBox(height: 16),
                  Text('กำลังโหลดผังตลาด...',
                      style: GoogleFonts.kanit(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDateSection(),
                        _buildLegend(),
                        const SizedBox(height: 4),
                        ..._zones.map((zone) => _buildZone(zone)),
                        _buildBottomNote(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _isLoadingLayout ? null : _buildBottomBar(),
    );
  }

  // ── Header ────────────────────────────────────────────
  // ✅ ดึงรูปจาก widget.market['image'] ที่ส่งมาจากหน้าก่อน
  Widget _buildHeader() {
    final marketImage = widget.market['image'] as String?;

    return Stack(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: marketImage != null && marketImage.isNotEmpty
              ? Image.network(
                  marketImage,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return _buildMockBanner();
                  },
                  errorBuilder: (_, __, ___) => _buildMockBanner(),
                )
              : _buildMockBanner(),
        ),
        // Back Button
        Positioned(
          top: 44,
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
                  Text('จองล็อค',
                      style:
                          GoogleFonts.kanit(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        // Market Info
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.48,
            padding: const EdgeInsets.fromLTRB(12, 44, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(-4, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.market['name'] ?? 'ตลาด',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.payments_rounded,
                        size: 13, color: Color(0xFF6E9B4C)),
                    const SizedBox(width: 4),
                    Text(
                      '฿$_pricePerDay / ล็อค / วัน',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        color: const Color(0xFF6E9B4C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (widget.market['location'] != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          widget.market['location'],
                          style: GoogleFonts.kanit(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _loadLayout,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8CBC63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF8CBC63).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded,
                            size: 12, color: Color(0xFF6E9B4C)),
                        const SizedBox(width: 4),
                        Text(
                          'รีเฟรชผัง',
                          style: GoogleFonts.kanit(
                            fontSize: 10,
                            color: const Color(0xFF6E9B4C),
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
      ],
    );
  }

  Widget _buildMockBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF66BB6A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_mall_directory_rounded,
                size: 44, color: Colors.white70),
            const SizedBox(height: 4),
            Text(
              widget.market['name'] ?? 'ตลาด',
              style: GoogleFonts.kanit(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ✅ Date Section (ปุ่มเล็กลง สีสบายตา) ────────────
  Widget _buildDateSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── เลือกช่วงวันที่ ──────────────────────────
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                'เลือกช่วงวันที่',
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ Date Range Button เล็กกระทัดรัด
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _startDate != null
                    ? const Color(0xFFF0F9EB)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _startDate != null
                      ? const Color(0xFF8CBC63).withOpacity(0.5)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 15,
                    color: _startDate != null
                        ? const Color(0xFF6E9B4C)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _startDate == null
                        ? Text(
                            'กดเพื่อเลือกช่วงวันที่',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                        : Row(
                            children: [
                              // วันเริ่ม
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'เริ่ม',
                                      style: GoogleFonts.kanit(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(_startDate),
                                      style: GoogleFonts.kanit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow
                              Icon(Icons.arrow_forward_rounded,
                                  size: 14, color: Colors.grey),
                              // วันสิ้นสุด
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'สิ้นสุด',
                                      style: GoogleFonts.kanit(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(_endDate),
                                      style: GoogleFonts.kanit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 6),
                  // Duration Badge
                  if (_startDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8CBC63).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getDurationText(),
                        style: GoogleFonts.kanit(
                          fontSize: 10,
                          color: const Color(0xFF6E9B4C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.edit_calendar_rounded,
                        size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── เลือกวันที่ขาย ───────────────────────────
          Row(
            children: [
              const Text('📆', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                'วันที่ขาย',
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(ไม่เลือก = ทุกวัน)',
                style: GoogleFonts.kanit(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ ปุ่มวันเล็ก สีอ่อน
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final isSelected = _selectedWeekdays.contains(day);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) {
                    _selectedWeekdays.remove(day);
                  } else {
                    _selectedWeekdays.add(day);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8CBC63)
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6E9B4C)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _weekdayLabels[i],
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // ── Summary Bar ──────────────────────────────
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryChip(
                    '📅',
                    'วันขาย',
                    '$_totalDays วัน',
                  ),
                  Container(width: 1, height: 24, color: Colors.grey),
                  _summaryChip(
                    '🏪',
                    'ล็อค',
                    '${_selectedStalls.length} ล็อค',
                  ),
                  Container(width: 1, height: 24, color: Colors.grey),
                  _summaryChip(
                    '💰',
                    'รวม',
                    '฿${_formatNumber(_totalPrice)}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryChip(String emoji, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.kanit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  // ── Legend ────────────────────────────────────────────
  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        children: [
          _legendItem(const Color(0xFF66BB6A), 'ว่าง'),
          _legendItem(const Color(0xFF2196F3), 'กำลังเลือก'),
          _legendItem(const Color(0xFFFFB300), 'รอชำระเงิน'),
          _legendItem(const Color(0xFFE53935), 'จองแล้ว'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.kanit(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  // ── Zone ──────────────────────────────────────────────
  Widget _buildZone(Map<String, dynamic> zone) {
    final rows = zone['rows'] as List<dynamic>;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFBDBDBD))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CBC63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8CBC63).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    zone['zoneName'] ?? '-',
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: const Color(0xFF6E9B4C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFBDBDBD))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: rows.map<Widget>((row) {
              final stalls = List<Map<String, dynamic>>.from(
                row['stalls'] as List,
              );
              return _buildRow(row['rowLabel'] ?? '', stalls);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String rowLabel, List<Map<String, dynamic>> stalls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            child: Text(
              rowLabel,
              style: GoogleFonts.kanit(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Wrap(
            spacing: 4,
            children: stalls.map((stall) {
              final stallId = stall['stallId'] as String;
              final status = stall['status'] as String;
              final isSelected = _selectedStalls.contains(stallId);
              final color = _stallColor(status, isSelected);
              return GestureDetector(
                onTap: () => _onStallTap(stall),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isSelected ? 28 : 22,
                  height: isSelected ? 28 : 22,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                      : Center(
                          child: Text(
                            stallId.replaceAll(RegExp(r'[A-Z]'), ''),
                            style: const TextStyle(
                                fontSize: 7, color: Colors.white70),
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFBDBDBD))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'กดวงกลมสีเขียวเพื่อเลือกล็อค',
              style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFBDBDBD))),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────
  Widget _buildBottomBar() {
    final canBook = _selectedStalls.isNotEmpty &&
        _startDate != null &&
        _endDate != null &&
        _totalDays > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedStalls.isEmpty
                      ? 'ยังไม่ได้เลือกล็อค'
                      : 'เลือก ${_selectedStalls.length} ล็อค'
                          '${_totalDays > 0 ? ' • $_totalDays วัน' : ''}',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
                if (canBook)
                  Text(
                    '฿${_formatNumber(_totalPrice)}',
                    style: GoogleFonts.kanit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8CBC63),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed:
                  (!canBook || _isLoadingRules) ? null : _onBookingPressed,
              child: _isLoadingRules
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart_checkout_rounded,
                            size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'จองล็อค',
                          style: GoogleFonts.kanit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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

  Widget _buildStep(
      String number, String title, String subtitle, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF8CBC63) : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF1F2937) : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.kanit()),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF8CBC63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Reusable Widgets
// ══════════════════════════════════════════════════════════
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Color(0xFFE5E7EB)),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF8CBC63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6E9B4C), size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  value,
                  style: GoogleFonts.kanit(
                    fontSize: highlight ? 14 : 13,
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                    color: highlight
                        ? const Color(0xFF6E9B4C)
                        : const Color(0xFF1F2937),
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
