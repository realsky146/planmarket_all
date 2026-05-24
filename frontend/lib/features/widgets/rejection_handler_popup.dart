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
  List<RecommendedStall> _recommendations = [];
  RecommendedStall? _selectedStall;
  final Set<StallPreference> _selectedPreferences = {};

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    try {
      final marketId = int.tryParse(widget.originalMarketId) ?? 0;
      final response = await ApiService.getRecommendedMarkets(marketId);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        setState(() {
          _recommendations = data.map((item) {
            return RecommendedStall(
              id: item['id']?.toString() ?? '',
              marketId: item['id']?.toString() ?? '',
              marketName: item['name'] ?? '',
              stallCode: item['stall_number'] ?? 'A01',
              zone: item['location'] ?? '',
              size: 'medium',
              price: (item['price'] ?? 0).toDouble(),
              imageUrl: item['image_url'] ?? '',
              distance: 0.0,
              trafficScore: (item['rating'] ?? 0) * 20,
              hasEvent: false,
              matchScore: 85.0,
              matchedPreferences: _selectedPreferences.toList(),
            );
          }).toList();
        });
      } else {
        setState(() => _recommendations = []);
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      setState(() => _recommendations = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedStall == null) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;
      final shopName = prefs.getString('userName') ?? 'ร้านค้า';

      final stallId = int.tryParse(_selectedStall!.id) ?? 0;

      if (userId == 0 || stallId == 0) {
        throw Exception('ข้อมูลไม่ครบถ้วน');
      }

      final response = await ApiService.createBooking(
        stallId: stallId,
        sellerId: userId,
        shopName: shopName,
      );

      if (response['success'] == true) {
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
            content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDismiss() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('แน่ใจหรือไม่?', style: GoogleFonts.kanit(fontSize: 18)),
        content: Text(
          'หากปิดหน้านี้ คุณจะต้องค้นหาและจองล็อคใหม่ด้วยตนเอง',
          style: GoogleFonts.kanit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('ยกเลิก', style: GoogleFonts.kanit(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CBC63)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('ปิดหน้านี้', style: GoogleFonts.kanit(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
    final titles = ['การจองถูกปฏิเสธ', 'เลือกความต้องการ', 'ล็อคแนะนำ', 'จองสำเร็จ'];
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
          const Icon(Icons.notification_important_rounded, color: Colors.white, size: 22),
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
              child: Text('ปิด', style: GoogleFonts.kanit(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep0();
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      default: return _buildStep0();
    }
  }

  // Step 0: แจ้งเตือนว่าถูกปฏิเสธ
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
            child: Icon(Icons.cancel_rounded, color: Colors.red.shade400, size: 48),
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
          if (widget.rejectReason != null && widget.rejectReason!.isNotEmpty) ...[
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
                    style: GoogleFonts.kanit(fontSize: 13, color: Colors.red.shade600),
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
                    Text('ตลาด', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                    Text(widget.originalMarketName, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ล็อค', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                    Text(widget.originalStallCode, style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => setState(() => _currentStep = 1),
              child: Text('หาล็อคใหม่ให้ฉัน', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleDismiss,
            child: Text('ไม่สนใจ ปิดหน้านี้', style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // Step 1: เลือก Preferences
  Widget _buildStep1() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'ต้องการล็อคแบบไหน?',
            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: StallPreference.values.length,
            itemBuilder: (context, index) {
              final pref = StallPreference.values[index];
              final isSelected = _selectedPreferences.contains(pref);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPreferences.remove(pref);
                    } else {
                      _selectedPreferences.add(pref);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF8CBC63).withOpacity(0.15) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF8CBC63) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(pref.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        pref.title,
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF6E9B4C) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CBC63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : () async {
                    await _loadRecommendations();
                    setState(() => _currentStep = 2);
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text('ค้นหาล็อคที่เหมาะสม', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: Text('ย้อนกลับ', style: GoogleFonts.kanit(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 2: แสดงผลลัพธ์
  Widget _buildStep2() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'ล็อคแนะนำสำหรับคุณ',
            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF8CBC63)))
              : _recommendations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('ไม่พบล็อคที่เหมาะสม', style: GoogleFonts.kanit(color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CBC63)),
                            onPressed: () => setState(() => _currentStep = 1),
                            child: Text('ปรับตัวกรอง', style: GoogleFonts.kanit(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _recommendations.length,
                      itemBuilder: (ctx, index) {
                        final stall = _recommendations[index];
                        final isSelected = _selectedStall?.id == stall.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStall = stall),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF8CBC63) : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.storefront_rounded, color: Color(0xFF8CBC63)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(stall.marketName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                                      Text('ล็อค: ${stall.stallCode}', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                                      Text('฿${stall.price.toInt()}/วัน', style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF6E9B4C), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF8CBC63)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        if (_selectedStall != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CBC63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _confirmBooking,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text('ยืนยันจองล็อคนี้', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }

  // Step 3: สำเร็จ
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF8CBC63), size: 80),
          const SizedBox(height: 16),
          Text(
            'จองสำเร็จแล้ว! 🎉',
            style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF8CBC63)),
          ),
          const SizedBox(height: 8),
          Text(
            'กำลังพาคุณไปหน้าการจอง...',
            style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Color(0xFF8CBC63), strokeWidth: 2),
        ],
      ),
    );
  }
}
