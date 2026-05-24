import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vendor_shop_info_page.dart';
import 'vendor_market_list_page.dart';
import 'favorite_vendor_page.dart';
import 'profile_vendor_page.dart';
import '../../services/api_service.dart';
import '../widgets/rejection_handler_popup.dart';
import '../../models/recommendation_models.dart';
import '../../features/widgets/recommended_stall_card.dart';

class VendorHome extends StatefulWidget {
  final bool isRejectedOrLocked;
  final String statusType;
  final String rejectReason;

  const VendorHome({
    Key? key,
    this.isRejectedOrLocked = false,
    this.statusType = 'active',
    this.rejectReason = '',
  }) : super(key: key);

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int currentIndex = 2;
  String _selectedStatus = 'all';
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkRejectedBookings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVendorStatus();
    });
  }

  void _checkVendorStatus() {
    if (widget.statusType == 'pending') {
      _showStatusDialog(
        title: 'อยู่ระหว่างการตรวจสอบ',
        message: 'บัญชีร้านค้าของคุณกำลังได้รับการตรวจสอบจากผู้ดูแลระบบ',
        icon: Icons.hourglass_empty_rounded,
        iconColor: Colors.amber,
      );
    } else if (widget.isRejectedOrLocked) {
      bool isBanned = widget.statusType == 'banned';
      _showStatusDialog(
        title: isBanned ? 'บัญชีถูกระงับการใช้งาน' : 'ใบสมัครถูกปฏิเสธ',
        message: isBanned
            ? 'บัญชีของคุณถูกระงับ\nเหตุผล: ${widget.rejectReason}'
            : 'ข้อมูลการสมัครของคุณไม่ผ่านการอนุมัติ\nเหตุผล: ${widget.rejectReason}',
        icon: isBanned ? Icons.block_rounded : Icons.cancel_outlined,
        iconColor: Colors.red,
      );
    }
  }

  void _showStatusDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: widget.statusType == 'pending',
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.kanit(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('รับทราบ',
                style: GoogleFonts.kanit(
                    color: const Color(0xFF8CBC63),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ⭐ แก้ไข _loadData() เพิ่ม rejectReason
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('userId') ?? '0';
      final userId = int.tryParse(userIdStr) ?? 0;

      if (userId == 0) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final response = await ApiService.getUserBookings(userId);
      if (!mounted) return;

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> rawData = response['data'];
        setState(() {
          _bookings = rawData.map((b) {
            return {
              'id': b['id']?.toString() ?? '',
              'marketName': b['market_name'] ?? 'ไม่ระบุชื่อตลาด',
              'marketId': b['market_id']?.toString() ?? '',
              'stallNumber': b['stall_number'] ?? '',
              'startDate': b['start_date'] ?? b['created_at'] ?? '',
              'status': b['status'] ?? 'pending',
              'createdAt': b['created_at'] ?? '',
              // ⭐ เพิ่ม rejectReason
              'rejectReason': b['reject_reason'] ??
                  b['reason'] ??
                  'ข้อมูลไม่ผ่านการอนุมัติ',
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkRejectedBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;
      if (userId == 0) return;

      final response = await ApiService.getRejectedBookings(userId);
      if (response['success'] == true &&
          response['data'] != null &&
          (response['data'] as List).isNotEmpty) {
        final rejected = (response['data'] as List).first;
        if (mounted) {
          RejectionHandlerPopup.show(
            context,
            bookingId: rejected['id']?.toString() ?? '0',
            originalMarketId: rejected['market_id']?.toString() ?? '0',
            originalMarketName: rejected['market_name'] ?? 'ไม่ระบุชื่อตลาด',
            originalStallCode:
                rejected['stall_number'] ?? rejected['stall_code'] ?? 'ไม่ระบุ',
            rejectReason: rejected['reason'] ??
                rejected['reject_reason'] ??
                'ข้อมูลไม่ผ่านการอนุมัติ',
            onBookingSuccess: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('จองล็อคใหม่สำเร็จ! 🎉', style: GoogleFonts.kanit()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            onDismiss: () {
              final bookingId =
                  int.tryParse(rejected['id']?.toString() ?? '0') ?? 0;
              if (bookingId > 0) {
                ApiService.markBookingNotified(bookingId);
              }
              _loadData();
            },
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking rejected bookings: $e');
    }
  }

  int get _pendingCount =>
      _bookings.where((b) => b['status'] == 'pending').length;
  int get _approvedCount =>
      _bookings.where((b) => b['status'] == 'approved').length;
  int get _rejectedCount =>
      _bookings.where((b) => b['status'] == 'rejected').length;

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedStatus == 'all') return _bookings;
    return _bookings.where((b) => b['status'] == _selectedStatus).toList();
  }

  void _navigateToPage(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Widget? page;
      switch (index) {
        case 0:
          page = const VendorFavoritePage();
          break;
        case 1:
          page = const VendorMarketListPage();
          break;
        case 2:
          return;
        case 3:
          page = const VendorShopInfoPage();
          break;
        case 4:
          page = const VendorProfilePage();
          break;
      }
      if (page != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => page!));
      }
    });
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF8CBC63),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'สรุปการดำเนินการ',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _summaryCard('รออนุมัติ', _pendingCount,
                                const Color(0xFFFFB000), 'pending')),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _summaryCard('อนุมัติแล้ว', _approvedCount,
                                const Color(0xFF22C55E), 'approved')),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _summaryCard('ปฏิเสธ', _rejectedCount,
                                const Color(0xFFEF4444), 'rejected')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _filterTab('ทั้งหมด', 'all', const Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    _filterTab('รออนุมัติ', 'pending', const Color(0xFFFFB000)),
                    const SizedBox(width: 8),
                    _filterTab(
                        'อนุมัติแล้ว', 'approved', const Color(0xFF22C55E)),
                    const SizedBox(width: 8),
                    _filterTab('ปฏิเสธ', 'rejected', const Color(0xFFEF4444)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF8CBC63)))
                    : _filteredBookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text('ไม่มีการจองในหมวดนี้',
                                    style:
                                        GoogleFonts.kanit(color: Colors.grey)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFF8CBC63),
                            onRefresh: _loadData,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 100),
                              itemCount: _filteredBookings.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) =>
                                  _buildBookingCard(_filteredBookings[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color, String status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () =>
          setState(() => _selectedStatus = isSelected ? 'all' : status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.kanit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.kanit(
                fontSize: 11,
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTab(String label, String status, Color color) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ⭐ แก้ไข _buildBookingCard() เพิ่ม GestureDetector และปุ่มดูรายละเอียด
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF22C55E);
        statusText = 'อนุมัติแล้ว';
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusText = 'ปฏิเสธ';
        break;
      default:
        statusColor = const Color(0xFFFFB000);
        statusText = 'รออนุมัติ';
    }

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking['marketName'],
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.store, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'ล็อค: ${booking['stallNumber']}',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking['startDate'],
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (status == 'rejected') ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'การจองนี้ถูกปิดแล้ว',
                    style: GoogleFonts.kanit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
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

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF8CBC63),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = currentIndex == i;
          return GestureDetector(
            onTap: () => _navigateToPage(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  items[i]['label'] as String,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
