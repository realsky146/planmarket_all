import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/market_service.dart';

class MarketApprovalPage extends StatefulWidget {
  const MarketApprovalPage({super.key});

  @override
  State<MarketApprovalPage> createState() => _MarketApprovalPageState();
}

class _MarketApprovalPageState extends State<MarketApprovalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _pendingList = [];
  List<Map<String, dynamic>> _approvedList = [];
  List<Map<String, dynamic>> _rejectedList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // ✅ แก้: getAllMarkets() แทน getAllRequests()
    final all = await MarketService().getAllMarkets();

    setState(() {
      _pendingList = all.where((r) => r['status'] == 'pending').toList();
      _approvedList = all.where((r) => r['status'] == 'approved').toList();
      _rejectedList = all.where((r) => r['status'] == 'rejected').toList();
      _loading = false;
    });
  }

  // ── อนุมัติ ───────────────────────────────────────────────
  Future<void> _approve(Map<String, dynamic> request) async {
    final confirm = await _showConfirmDialog(
      title: 'อนุมัติตลาด',
      content: 'อนุมัติ "${request['marketName']}" ใช่ไหม?',
      confirmText: 'อนุมัติ',
      confirmColor: const Color(0xFF22C55E),
    );

    if (confirm == true && mounted) {
      await MarketService().approveMarket(request['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'อนุมัติ "${request['marketName']}" แล้ว',
              style: GoogleFonts.kanit(),
            ),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        _loadData();
      }
    }
  }

  // ── ปฏิเสธ ───────────────────────────────────────────────
  Future<void> _reject(Map<String, dynamic> request) async {
    final reasonCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'ปฏิเสธคำขอ',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ปฏิเสธ "${request['marketName']}"',
              style: GoogleFonts.kanit(),
            ),
            const SizedBox(height: 16),
            Text(
              'เหตุผล (ถ้ามี)',
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: GoogleFonts.kanit(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'กรอกเหตุผล...',
                hintStyle: GoogleFonts.kanit(
                  color: const Color(0xFFBDBDBD),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.kanit(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('ปฏิเสธ', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // ✅ แก้: ส่ง reason เป็น named parameter
      await MarketService().rejectMarket(
        request['id'],
        reason: reasonCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ปฏิเสธคำขอแล้ว', style: GoogleFonts.kanit()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        _loadData();
      }
    }

    reasonCtrl.dispose();
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Text(content, style: GoogleFonts.kanit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.kanit(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText, style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  // ── ดูรายละเอียด ──────────────────────────────────────────
  void _showDetail(Map<String, dynamic> r) {
    // ✅ แก้: เช็ค null ก่อนใช้ rejectReason
    final rejectReason = r['rejectReason']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            // หัว
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Color(0xFFB45309),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['marketName'] ?? '-',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ส่งเมื่อ ${r['submittedAt'] ?? '-'}',
                        style: GoogleFonts.kanit(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // ข้อมูล
            _detailRow(Icons.person, 'เจ้าของ', r['ownerName'] ?? '-'),
            const SizedBox(height: 12),
            _detailRow(Icons.email_outlined, 'อีเมล', r['email'] ?? '-'),
            const SizedBox(height: 12),
            _detailRow(Icons.phone_outlined, 'เบอร์โทร', r['phone'] ?? '-'),
            const SizedBox(height: 12),
            _detailRow(
              Icons.location_on_outlined,
              'ที่ตั้ง',
              r['location'] ?? '-',
            ),
            const SizedBox(height: 12),
            _detailRow(
              Icons.description_outlined,
              'รายละเอียด',
              r['description'] ?? '-',
            ),

            // ✅ เช็ค null และ empty ก่อนแสดง
            if (r['status'] == 'rejected' && rejectReason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'เหตุผล: $rejectReason',
                        style: GoogleFonts.kanit(
                          color: const Color(0xFFB91C1C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ปุ่ม (เฉพาะ pending)
            if (r['status'] == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _reject(r);
                      },
                      child: Text(
                        'ปฏิเสธ',
                        style: GoogleFonts.kanit(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _approve(r);
                      },
                      child: Text(
                        'อนุมัติ',
                        style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D9CDB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('ปิด', style: GoogleFonts.kanit()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: AppBar(
          title: Text(
            'คำขอลงทะเบียนตลาด',
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2D9CDB),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              // Tab 1: รออนุมัติ + Badge
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('รออนุมัติ', style: GoogleFonts.kanit()),
                    if (_pendingList.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_pendingList.length}',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(child: Text('อนุมัติแล้ว', style: GoogleFonts.kanit())),
              Tab(child: Text('ปฏิเสธแล้ว', style: GoogleFonts.kanit())),
            ],
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D9CDB)),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildList(
                    list: _pendingList,
                    emptyText: 'ไม่มีคำขอที่รออนุมัติ',
                    showActions: true,
                  ),
                  _buildList(
                    list: _approvedList,
                    emptyText: 'ยังไม่มีคำขอที่อนุมัติแล้ว',
                    showActions: false,
                  ),
                  _buildList(
                    list: _rejectedList,
                    emptyText: 'ยังไม่มีคำขอที่ปฏิเสธ',
                    showActions: false,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildList({
    required List<Map<String, dynamic>> list,
    required String emptyText,
    required bool showActions,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: GoogleFonts.kanit(
                color: const Color(0xFF9CA3AF),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF2D9CDB),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _requestCard(list[i], showActions),
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> r, bool showActions) {
    Color statusColor;
    Color statusBg;
    String statusText;
    IconData statusIcon;

    switch (r['status']) {
      case 'approved':
        statusColor = const Color(0xFF0F7A36);
        statusBg = const Color(0xFFDFF7E6);
        statusText = 'อนุมัติแล้ว';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = const Color(0xFFB91C1C);
        statusBg = const Color(0xFFFEE2E2);
        statusText = 'ปฏิเสธแล้ว';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFFB45309);
        statusBg = const Color(0xFFFFF3CD);
        statusText = 'รออนุมัติ';
        statusIcon = Icons.hourglass_empty;
    }

    // ✅ เช็ค null ก่อนใช้
    final rejectReason = r['rejectReason']?.toString() ?? '';

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // หัว card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.storefront,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['marketName'] ?? '-',
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r['ownerName'] ?? '-',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Info rows
                _miniInfoRow(
                  Icons.location_on_outlined,
                  r['location'] ?? '-',
                ),
                const SizedBox(height: 4),
                _miniInfoRow(Icons.phone_outlined, r['phone'] ?? '-'),
                const SizedBox(height: 4),
                _miniInfoRow(
                  Icons.calendar_today,
                  'ส่งเมื่อ ${r['submittedAt'] ?? '-'}',
                ),

                // เหตุผลปฏิเสธ ✅ เช็ค null + empty
                if (r['status'] == 'rejected' && rejectReason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'เหตุผล: $rejectReason',
                      style: GoogleFonts.kanit(
                        color: const Color(0xFFB91C1C),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ปุ่มด้านล่าง
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                // ดูรายละเอียด
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2D9CDB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _showDetail(r),
                    child: Text(
                      'ดูรายละเอียด',
                      style: GoogleFonts.kanit(
                        color: const Color(0xFF2D9CDB),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // ปุ่ม อนุมัติ/ปฏิเสธ (เฉพาะ pending)
                if (showActions) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => _reject(r),
                      child: Text(
                        'ปฏิเสธ',
                        style: GoogleFonts.kanit(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => _approve(r),
                      child: Text(
                        'อนุมัติ',
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.kanit(
              color: const Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            '$label :',
            style: GoogleFonts.kanit(
              color: const Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.kanit(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
