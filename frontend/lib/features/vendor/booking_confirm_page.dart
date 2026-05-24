import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'vendor_home.dart';

class BookingConfirmPage extends StatefulWidget {
  final Map<String, dynamic> market;
  final Map<String, dynamic> stall;

  const BookingConfirmPage({
    super.key,
    required this.market,
    required this.stall,
  });

  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  bool _isBooking = false;

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;

      if (userId == 0) {
        _showErrorDialog('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่');
        return;
      }

      final stallId = int.tryParse(widget.stall['id']?.toString() ?? '0') ?? 0;

      final response = await ApiService.createBooking(
        userId: userId,
        stallId: stallId,
      );

      if (response['success'] == true) {
        if (mounted) _showSuccessDialog();
      } else {
        if (mounted) {
          _showErrorDialog(
            response['message'] ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error booking: $e');
      if (mounted) _showErrorDialog('เกิดข้อผิดพลาด กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header สีเขียว ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF8CBC63),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
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
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ส่งคำขอจองสำเร็จ!',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
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
              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── รายละเอียด ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8CBC63).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _confirmRow(
                            Icons.storefront_rounded,
                            'ตลาด',
                            widget.market['name'] ?? '-',
                          ),
                          const Divider(height: 16),
                          _confirmRow(
                            Icons.grid_view_rounded,
                            'แผง',
                            widget.stall['stallNumber'] ?? '-',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ── ข้อความแจ้งเตือน ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.amber.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'กำลังรอการอนุมัติจากเจ้าของตลาด\nระบบจะแจ้งเตือนเมื่อได้รับการอนุมัติ',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.amber.shade800,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── ปุ่มไปหน้าหลัก ──
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8CBC63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendorHome(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'กลับหน้าหลัก',
                          style: GoogleFonts.kanit(
                            fontWeight: FontWeight.bold,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'เกิดข้อผิดพลาด',
              style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ตกลง',
              style: GoogleFonts.kanit(color: const Color(0xFF8CBC63)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF8CBC63).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF6E9B4C)),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Column(
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF8CBC63),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
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
                Text(
                  'ยืนยันการจอง',
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Card สรุปการจอง ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สรุปการจอง',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _confirmRow(
                          Icons.storefront_rounded,
                          'ตลาด',
                          widget.market['name'] ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _confirmRow(
                          Icons.location_on_rounded,
                          'ที่ตั้ง',
                          widget.market['location'] ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _confirmRow(
                          Icons.grid_view_rounded,
                          'แผงที่เลือก',
                          widget.stall['stallNumber'] ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _confirmRow(
                          Icons.straighten_rounded,
                          'ขนาด',
                          widget.stall['size'] ?? 'ไม่ระบุ',
                        ),
                        const SizedBox(height: 12),
                        _confirmRow(
                          Icons.map_rounded,
                          'โซน',
                          widget.stall['zone'] ?? '-',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── ข้อมูลเพิ่มเติม ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8CBC63).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF8CBC63),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ข้อมูลการจอง',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '• หลังจากจองแล้ว กรุณารอการอนุมัติ\n'
                          '• เจ้าของตลาดจะพิจารณาคำขอของคุณ\n'
                          '• ระบบจะแจ้งเตือนผลการอนุมัติ',
                          style: GoogleFonts.kanit(
                            fontSize: 13,
                            color: const Color(0xFF374151),
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── ปุ่มยืนยัน ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
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
            child: Row(
              children: [
                // ── ปุ่มยกเลิก ──
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
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
                // ── ปุ่มยืนยัน ──
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8CBC63),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isBooking ? null : _confirmBooking,
                      child: _isBooking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'ยืนยันการจอง',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
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
