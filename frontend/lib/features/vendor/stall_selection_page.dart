import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'booking_confirm_page.dart';

class StallSelectionPage extends StatefulWidget {
  final Map<String, dynamic> market;

  const StallSelectionPage({
    super.key,
    required this.market,
  });

  @override
  State<StallSelectionPage> createState() => _StallSelectionPageState();
}

class _StallSelectionPageState extends State<StallSelectionPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _stalls = [];
  String? _selectedStallId;
  String? _selectedStallNumber;

  @override
  void initState() {
    super.initState();
    _loadStalls();
  }

  Future<void> _loadStalls() async {
    setState(() => _isLoading = true);
    try {
      final marketId = widget.market['id']?.toString() ?? '';
      final response = await ApiService.getStalls(marketId);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> raw = response['data'];
        setState(() {
          _stalls = raw
              .map((s) => {
                    'id': s['id']?.toString() ?? '',
                    'stallNumber': s['stall_number'] ?? s['name'] ?? '-',
                    'size': s['size'] ?? 'ไม่ระบุ',
                    'price': s['price'] ?? s['price_per_day'] ?? 0,
                    'status': s['status'] ?? 'available',
                    'zone': s['zone'] ?? '-',
                  })
              .toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading stalls: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF8CBC63),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'เลือกแผง',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── ข้อมูลตลาด ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.market['name'] ?? '-',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.market['location'] ?? '-',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Legend ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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

          const SizedBox(height: 8),

          // ── Stall Grid ──────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF8CBC63),
                    ),
                  )
                : _stalls.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.grid_off_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ไม่พบข้อมูลแผง',
                              style: GoogleFonts.kanit(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF8CBC63),
                        onRefresh: _loadStalls,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _stalls.length,
                          itemBuilder: (_, i) => _buildStallCard(_stalls[i]),
                        ),
                      ),
          ),
        ],
      ),

      // ── ปุ่มยืนยัน ──────────────────────────────────
      bottomNavigationBar: _selectedStallId != null
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── แสดงแผงที่เลือก ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF8CBC63).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF8CBC63),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'แผงที่เลือก: $_selectedStallNumber',
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
                  // ── ปุ่มไปยืนยัน ──
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8CBC63),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final selectedStall = _stalls.firstWhere(
                          (s) => s['id'] == _selectedStallId,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmPage(
                              market: widget.market,
                              stall: selectedStall,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'ยืนยันแผงที่เลือก',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
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
          ? () {
              setState(() {
                if (_selectedStallId == stall['id']) {
                  // ยกเลิกการเลือก
                  _selectedStallId = null;
                  _selectedStallNumber = null;
                } else {
                  _selectedStallId = stall['id'];
                  _selectedStallNumber = stall['stallNumber'];
                }
              });
            }
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
              isSelected ? Icons.check_circle_rounded : Icons.store_rounded,
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
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
