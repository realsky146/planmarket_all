import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/recommendation_models.dart';
import '../../services/api_service.dart';

class RejectionHandlerPopup extends StatefulWidget {
  final String originalMarketId;
  final String originalMarketName;
  final String originalStallCode;
  final String bookingId;
  final String? rejectReason;
  final RejectionReason? reason;
  final VoidCallback? onBookingSuccess;
  final VoidCallback? onDismiss;

  const RejectionHandlerPopup({
    super.key,
    required this.originalMarketId,
    required this.originalMarketName,
    required this.originalStallCode,
    required this.bookingId,
    this.rejectReason,
    this.reason,
    this.onBookingSuccess,
    this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required String originalMarketId,
    required String originalMarketName,
    required String originalStallCode,
    required String bookingId,
    String? rejectReason,
    RejectionReason? reason,
    VoidCallback? onBookingSuccess,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RejectionHandlerPopup(
        originalMarketId: originalMarketId,
        originalMarketName: originalMarketName,
        originalStallCode: originalStallCode,
        bookingId: bookingId,
        rejectReason: rejectReason,
        reason: reason,
        onBookingSuccess: onBookingSuccess,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<RejectionHandlerPopup> createState() => _RejectionHandlerPopupState();
}

class _RejectionHandlerPopupState extends State<RejectionHandlerPopup> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1 state — market selection
  List<Map<String, dynamic>> _markets = [];
  List<Map<String, dynamic>> _rankedMarkets = []; // up to 3, in rank order
  List<StallPreference> _savedPreferences = [];

  // Step 2 state — stall selection
  List<Map<String, dynamic>> _stalls = [];
  String? _selectedStallId;
  String? _selectedStallNumber;
  String _selectedMarketName = '';

  // ── Load saved preferences ──────────────────────────────────────

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('vendor_preferences') ?? '';
    if (saved.isNotEmpty) {
      setState(() {
        _savedPreferences = saved
            .split(',')
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>()
            .where((i) => i < StallPreference.values.length)
            .map((i) => StallPreference.values[i])
            .toList();
      });
    }
  }

  // ── Load available markets ──────────────────────────────────────

  Future<void> _loadAvailableMarkets() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getMarkets();
      if (result['success'] == true && result['data'] != null) {
        final raw = result['data'] as List<dynamic>;

        var markets = raw
            .where((m) =>
                ((m['available_stalls'] as num?)?.toInt() ?? 0) > 0)
            .map((m) => {
                  'id': m['id']?.toString() ?? '',
                  'name': m['name'] ?? '',
                  'location': m['location'] ?? m['description'] ?? '',
                  'availableStalls':
                      (m['available_stalls'] as num?)?.toInt() ?? 0,
                  'totalStalls':
                      (m['total_stalls'] as num?)?.toInt() ?? 0,
                  'rating': double.tryParse(
                          m['rating']?.toString() ?? '4.0') ??
                      4.0,
                  'pricePerDay':
                      (m['price_per_day'] as num?)?.toInt() ?? 0,
                  'image': m['image_url'] ?? '',
                })
            .toList();

        if (_savedPreferences.isNotEmpty) {
          markets.sort(
              (a, b) => _preferenceScore(b).compareTo(_preferenceScore(a)));
        }

        setState(() => _markets = markets);
      }
    } catch (e) {
      debugPrint('❌ Error loading markets: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _preferenceScore(Map<String, dynamic> market) {
    double score = 0;
    final available = (market['availableStalls'] as num?)?.toInt() ?? 0;
    final rating = (market['rating'] as num?)?.toDouble() ?? 4.0;
    final price = (market['pricePerDay'] as num?)?.toInt() ?? 0;

    score += available.toDouble();
    score += rating * 5;

    for (final pref in _savedPreferences) {
      switch (pref) {
        case StallPreference.cheapest:
          score += price > 0 ? (200.0 / price) : 20;
          break;
        case StallPreference.highTraffic:
          score += rating * 8;
          break;
        default:
          score += 5;
      }
    }
    return score;
  }

  // ── Load stalls for the rank-1 market ──────────────────────────

  Future<void> _loadStalls(int marketId, String marketName) async {
    setState(() {
      _isLoading = true;
      _selectedMarketName = marketName;
      _selectedStallId = null;
      _selectedStallNumber = null;
    });
    try {
      final result = await ApiService.getMarketStalls(marketId);
      if (result['success'] == true && result['data'] != null) {
        final raw = result['data'] as List<dynamic>;
        setState(() {
          _stalls = raw
              .map((s) => {
                    'id': s['id']?.toString() ?? '',
                    'stallNumber':
                        s['stall_number'] ?? s['name'] ?? '-',
                    'size': s['size'] ?? 'ไม่ระบุ',
                    'status': s['status'] ?? 'available',
                    'zone': s['zone'] ?? '-',
                  })
              .toList();
        });
      } else {
        setState(() => _stalls = []);
      }
    } catch (e) {
      debugPrint('❌ Error loading stalls: $e');
      setState(() => _stalls = []);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 2;
        });
      }
    }
  }

  // ── Confirm booking ─────────────────────────────────────────────

  Future<void> _confirmBooking() async {
    if (_selectedStallId == null) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final sellerId =
          int.tryParse(prefs.getString('userId') ?? '0') ?? 0;
      final shopName = prefs.getString('userName') ?? 'ร้านค้า';
      final stallId = int.tryParse(_selectedStallId!) ?? 0;

      if (sellerId == 0 || stallId == 0) {
        throw Exception('ข้อมูลไม่ครบถ้วน');
      }

      final response = await ApiService.createBooking(
        stallId: stallId,
        sellerId: sellerId,
        shopName: shopName,
      );

      if (response['success'] == true) {
        // mark original rejected booking as notified ทันทีที่จองสำเร็จ
        final originalBookingId = int.tryParse(widget.bookingId) ?? 0;
        if (originalBookingId > 0) {
          await ApiService.markBookingNotified(originalBookingId);
        }
        setState(() => _currentStep = 3);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
          widget.onBookingSuccess?.call();
        }
      } else {
        throw Exception(response['message'] ?? 'จองไม่สำเร็จ');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e',
                style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Dismiss handler ─────────────────────────────────────────────

  Future<void> _handleDismiss() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            Text('แน่ใจหรือไม่?', style: GoogleFonts.kanit(fontSize: 18)),
        content: Text(
          'หากปิดหน้านี้ คุณจะต้องค้นหาและจองล็อคใหม่ด้วยตนเอง',
          style: GoogleFonts.kanit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('ยกเลิก',
                style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('ปิดหน้านี้',
                style: GoogleFonts.kanit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final bookingId = int.tryParse(widget.bookingId) ?? 0;
      if (bookingId > 0) {
        await ApiService.markBookingNotified(bookingId);
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onDismiss?.call();
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(child: _buildCurrentStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const titles = [
      'การจองถูกปฏิเสธ',
      'เลือกตลาด',
      'เลือกล็อค',
      'จองสำเร็จ'
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF8CBC63),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.notification_important_rounded,
              color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titles[_currentStep.clamp(0, 3)],
              style: GoogleFonts.kanit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (_currentStep < 3)
            TextButton(
              onPressed: _handleDismiss,
              child: Text('ปิด',
                  style: GoogleFonts.kanit(
                      color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildStep0();
    }
  }

  // ── Step 0: Rejection notification ─────────────────────────────

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cancel_rounded,
                color: Colors.red.shade400, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'การจองถูกปฏิเสธ',
            style: GoogleFonts.kanit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.rejectReason != null &&
              widget.rejectReason!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เหตุผลที่ถูกปฏิเสธ',
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.rejectReason!,
                    style: GoogleFonts.kanit(
                        fontSize: 13, color: Colors.red.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ตลาด',
                        style: GoogleFonts.kanit(
                            fontSize: 13, color: Colors.grey)),
                    Text(
                      widget.originalMarketName,
                      style: GoogleFonts.kanit(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ล็อค',
                        style: GoogleFonts.kanit(
                            fontSize: 13, color: Colors.grey)),
                    Text(
                      widget.originalStallCode,
                      style: GoogleFonts.kanit(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CBC63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await _loadSavedPreferences();
                      await _loadAvailableMarkets();
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                          _currentStep = 1;
                        });
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'หาตลาดใหม่ให้ฉัน',
                      style: GoogleFonts.kanit(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleDismiss,
            child: Text('ไม่สนใจ ปิดหน้านี้',
                style:
                    GoogleFonts.kanit(fontSize: 14, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Market selection ────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      children: [
        // Saved preference chips
        if (_savedPreferences.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'ความต้องการ: ',
                      style: GoogleFonts.kanit(
                          fontSize: 11, color: Colors.grey),
                    ),
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
                                  style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 3),
                              Text(
                                p.title,
                                style: GoogleFonts.kanit(
                                  fontSize: 10,
                                  color: p.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        // Instruction
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'เลือกตลาดที่ต้องการ (สูงสุด 3 อันดับ)',
            style: GoogleFonts.kanit(
                fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        // Market list
        Expanded(
          child: _markets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('ไม่พบตลาดที่มีล็อคว่าง',
                          style: GoogleFonts.kanit(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  itemCount: _markets.length,
                  itemBuilder: (_, i) =>
                      _buildMarketRankCard(_markets[i]),
                ),
        ),
        // Bottom: rank preview + confirm button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_rankedMarkets.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color:
                            const Color(0xFF8CBC63).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ตลาดที่เลือก:',
                        style: GoogleFonts.kanit(
                            fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      ...List.generate(
                        _rankedMarkets.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8CBC63),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _rankedMarkets[i]['name'] as String,
                                style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rankedMarkets.isNotEmpty
                        ? const Color(0xFF8CBC63)
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed:
                      _rankedMarkets.isNotEmpty && !_isLoading
                          ? () {
                              final top = _rankedMarkets[0];
                              final marketId = int.tryParse(
                                      top['id'].toString()) ??
                                  0;
                              _loadStalls(
                                  marketId, top['name'] as String);
                            }
                          : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'ดูล็อคของตลาดอันดับ 1',
                          style: GoogleFonts.kanit(
                            fontWeight: FontWeight.bold,
                            color: _rankedMarkets.isNotEmpty
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: Text('ย้อนกลับ',
                    style: GoogleFonts.kanit(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketRankCard(Map<String, dynamic> market) {
    final rankIndex =
        _rankedMarkets.indexWhere((m) => m['id'] == market['id']);
    final isSelected = rankIndex >= 0;
    final rank = rankIndex + 1;
    final available =
        (market['availableStalls'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _rankedMarkets.removeWhere((m) => m['id'] == market['id']);
          } else if (_rankedMarkets.length < 3) {
            _rankedMarkets.add(market);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('เลือกได้สูงสุด 3 ตลาด',
                    style: GoogleFonts.kanit()),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF0FDF4)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8CBC63)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8CBC63)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6E9B4C)
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: isSelected
                    ? Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(Icons.add_rounded,
                        color: Colors.grey.shade400, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // Market info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market['name'] as String,
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    market['location'] as String,
                    style: GoogleFonts.kanit(
                        fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Available stalls badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                        const Color(0xFF8CBC63).withOpacity(0.4)),
              ),
              child: Text(
                'ว่าง $available',
                style: GoogleFonts.kanit(
                  fontSize: 11,
                  color: const Color(0xFF6E9B4C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Stall selection ─────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      children: [
        // Market info bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.storefront_rounded,
                  color: Color(0xFF8CBC63), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _selectedMarketName,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _legendItem(const Color(0xFF8CBC63), 'ว่าง'),
              const SizedBox(width: 16),
              _legendItem(const Color(0xFFEF4444), 'ไม่ว่าง'),
              const SizedBox(width: 16),
              _legendItem(const Color(0xFF3B82F6), 'เลือกแล้ว'),
            ],
          ),
        ),
        // Stall grid
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF8CBC63)))
              : _stalls.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.grid_off_rounded,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('ไม่พบข้อมูลล็อค',
                              style:
                                  GoogleFonts.kanit(color: Colors.grey)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _stalls.length,
                      itemBuilder: (_, i) =>
                          _buildStallCard(_stalls[i]),
                    ),
        ),
        // Selected stall info + confirm
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_selectedStallId != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF8CBC63)
                            .withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF8CBC63), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'ล็อคที่เลือก: $_selectedStallNumber',
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedStallId != null
                        ? const Color(0xFF8CBC63)
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _selectedStallId != null && !_isLoading
                      ? _confirmBooking
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'ยืนยันจองล็อคนี้',
                          style: GoogleFonts.kanit(
                            fontWeight: FontWeight.bold,
                            color: _selectedStallId != null
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _currentStep = 1;
                  _selectedStallId = null;
                  _selectedStallNumber = null;
                }),
                child: Text('เลือกตลาดใหม่',
                    style: GoogleFonts.kanit(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStallCard(Map<String, dynamic> stall) {
    final status = stall['status'] as String;
    final isAvailable = status == 'available';
    final isSelected = _selectedStallId == stall['id'];

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected) {
      bgColor = const Color(0xFF3B82F6);
      borderColor = const Color(0xFF3B82F6);
      textColor = Colors.white;
    } else if (isAvailable) {
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFF8CBC63);
      textColor = const Color(0xFF374151);
    } else {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFEF4444);
      textColor = Colors.grey;
    }

    return GestureDetector(
      onTap: isAvailable
          ? () => setState(() {
                if (_selectedStallId == stall['id']) {
                  _selectedStallId = null;
                  _selectedStallNumber = null;
                } else {
                  _selectedStallId = stall['id'];
                  _selectedStallNumber = stall['stallNumber'];
                }
              })
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.store_rounded,
              color: isSelected
                  ? Colors.white
                  : isAvailable
                      ? const Color(0xFF8CBC63)
                      : const Color(0xFFEF4444),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              stall['stallNumber'],
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              isAvailable ? 'ว่าง' : 'ไม่ว่าง',
              style: GoogleFonts.kanit(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : isAvailable
                        ? const Color(0xFF6E9B4C)
                        : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
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
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  // ── Step 3: Success ─────────────────────────────────────────────

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF8CBC63), size: 80),
          const SizedBox(height: 16),
          Text(
            'จองสำเร็จแล้ว! 🎉',
            style: GoogleFonts.kanit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8CBC63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กำลังพาคุณไปหน้าการจอง...',
            style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
              color: Color(0xFF8CBC63), strokeWidth: 2),
        ],
      ),
    );
  }
}
